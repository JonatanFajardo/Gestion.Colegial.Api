/* =============================================================================
   084 · Inicio de sesión seguro

   Contraseñas
   - La API guarda las contraseñas con PBKDF2-HMAC-SHA256, sal aleatoria por usuario y 600 000
     iteraciones: "v2$iteraciones$sal$huella" (unos 80 caracteres; Usu_Contraseña es varchar(255)).
     La huella se calcula en la API (Gestion.Colegial.Business/Seguridad/Contrasenas.cs).
   - Las contraseñas viejas (SHA-256 sin sal, 64 caracteres hexadecimales) se convierten solas al
     formato nuevo la próxima vez que el usuario entra con la contraseña correcta.
   - seguridad.PR_tbUsuarios_GuardarContrasena es el ÚNICO procedimiento para cambiar la contraseña
     de un usuario existente (cambio, restablecimiento, conversión, activación de cuentas). Solo
     acepta el formato nuevo.
   - seguridad.PR_tbUsuarios_DatosLogin devuelve la huella guardada para compararla en la API.

   Transición con el código anterior
   - Mientras el ADM y la API anteriores sigan usando esta misma base, al convertir una contraseña
     se guarda también su huella vieja en Usu_ContrasenaLegado, y el procedimiento del código
     anterior (seguridad.UDP_tbUsuarios_Login, misma firma y mismas columnas) la acepta. Así un
     usuario que entró con el código nuevo sigue entrando con el anterior.
   - Cuando todo corra con el código nuevo:  EXEC seguridad.PR_tbUsuarios_CerrarTransicionContrasenas;
     borra esas huellas viejas y deja de guardarlas. El estado vive en la propiedad extendida
     "TransicionContrasenas" de seguridad.tbUsuarios (abierta | cerrada): correr este script otra
     vez no reabre una transición cerrada.

   Límite de intentos
   - seguridad.tbIntentosLogin cuenta los fallos por usuario ('u:<usuario>') y por IP ('ip:<ip>').
     Al llegar al máximo dentro de la ventana, esa clave queda bloqueada un tiempo. Los números
     (5 por usuario, 20 por IP, ventana y bloqueo de 15 minutos) se configuran en la API.
   - Cada intento se cuenta ANTES de revisar la contraseña (PR_tbIntentosLogin_Reservar) y se
     descuenta si resulta correcta: varios intentos simultáneos no pasan del máximo.
   - Los fallos de usuarios que existen y los bloqueos quedan en seguridad.tbBitacora.

   Prefijo: Ilo_. Errores 50084.
   Idempotente: se puede correr varias veces.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ─────────────────────────────── Columnas ─────────────────────────────── */
-- La huella nueva necesita unos 80 caracteres; se asegura un mínimo de 255.
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID(N'seguridad.tbUsuarios') AND name = N'Usu_Contraseña' AND max_length < 255)
    ALTER TABLE seguridad.tbUsuarios ALTER COLUMN [Usu_Contraseña] varchar(255) NOT NULL;
GO

-- La IP del navegador puede ser IPv6 (hasta 45 caracteres).
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID(N'seguridad.tbUsuarios') AND name = N'Usu_Ip' AND max_length < 45)
    ALTER TABLE seguridad.tbUsuarios ALTER COLUMN Usu_Ip varchar(45) NULL;
GO

-- Huella vieja (SHA-256) solo mientras dure la transición; NULL en lo demás.
IF COL_LENGTH(N'seguridad.tbUsuarios', N'Usu_ContrasenaLegado') IS NULL
    ALTER TABLE seguridad.tbUsuarios ADD Usu_ContrasenaLegado varchar(64) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.extended_properties
               WHERE class = 1 AND major_id = OBJECT_ID(N'seguridad.tbUsuarios') AND minor_id = 0
                 AND name = N'TransicionContrasenas')
    EXEC sys.sp_addextendedproperty
        @name = N'TransicionContrasenas', @value = N'abierta',
        @level0type = N'SCHEMA', @level0name = N'seguridad',
        @level1type = N'TABLE',  @level1name = N'tbUsuarios';
GO

/* ─────────────────────────────── Tabla de intentos ─────────────────────────────── */
IF OBJECT_ID(N'seguridad.tbIntentosLogin', N'U') IS NULL
BEGIN
    CREATE TABLE seguridad.tbIntentosLogin
    (
        Ilo_Clave           nvarchar(150) NOT NULL CONSTRAINT PK_tbIntentosLogin PRIMARY KEY,
        Ilo_Fallos          int           NOT NULL,
        Ilo_PrimerFallo     datetime2(0)  NOT NULL,
        Ilo_UltimoFallo     datetime2(0)  NOT NULL,
        Ilo_BloqueadoHasta  datetime2(0)  NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_tbIntentosLogin_UltimoFallo'
                                            AND object_id = OBJECT_ID(N'seguridad.tbIntentosLogin'))
    CREATE INDEX IX_tbIntentosLogin_UltimoFallo ON seguridad.tbIntentosLogin (Ilo_UltimoFallo);
GO

/* ─────────────────────────────── Datos para iniciar sesión ─────────────────────────────── */
-- Por nombre (inicio de sesión) o por Id (cambio de contraseña). La comparación se hace en la API.
CREATE OR ALTER PROCEDURE seguridad.PR_tbUsuarios_DatosLogin
    @Usu_Name nvarchar(100) = NULL,
    @Usu_Id   int           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        u.Usu_Id,
        u.Usu_Name,
        u.Emp_Id,
        u.Rol_Id,
        r.Rol_Descripcion          AS Rol_Nombre,
        u.[Usu_Contraseña]         AS Usu_Contrasena,
        CAST(CASE WHEN u.Usu_EsActivo = 1
                   AND ISNULL(u.Usu_Suspendido, 0) = 0
                   AND ISNULL(u.Usu_EsEliminado, 0) = 0 THEN 1 ELSE 0 END AS int) AS Habilitado
    FROM seguridad.tbUsuarios u
    INNER JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
    WHERE (@Usu_Id IS NOT NULL AND u.Usu_Id = @Usu_Id)
       OR (@Usu_Id IS NULL AND u.Usu_Name = LTRIM(RTRIM(@Usu_Name)))
    ORDER BY Habilitado DESC, u.Usu_Id;
END
GO

/* ─────────────────────────────── Guardar contraseña ─────────────────────────────── */
-- ÚNICO punto para cambiar la contraseña de un usuario existente.
--   @Contrasena          huella en formato nuevo (v2$...), calculada en la API.
--   @ContrasenaLegado    huella vieja: solo al convertir una contraseña vieja; se guarda mientras la
--                        transición esté abierta. En cambios y restablecimientos va NULL (se borra).
--   @ContrasenaEsperada  si viene, solo se guarda cuando la actual sigue siendo esa (evita pisar un
--                        cambio hecho al mismo tiempo).
--   @Bit_*               si viene @Bit_Accion, deja el registro en la bitácora.
-- Responde { Filas } (0 = no se guardó).
CREATE OR ALTER PROCEDURE seguridad.PR_tbUsuarios_GuardarContrasena
    @Usu_Id              int,
    @Contrasena          varchar(255),
    @ContrasenaLegado    varchar(64)  = NULL,
    @ContrasenaEsperada  varchar(255) = NULL,
    @Bit_UsuId           int          = NULL,
    @Bit_Accion          varchar(50)  = NULL,
    @Bit_Ip              varchar(45)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Contrasena IS NULL OR LEN(@Contrasena) < 20 OR LEFT(@Contrasena, 3) <> 'v2$'
        THROW 50084, N'La contraseña debe llegar en el formato seguro.', 1;
    IF @ContrasenaLegado IS NOT NULL
       AND (LEN(@ContrasenaLegado) <> 64 OR @ContrasenaLegado COLLATE Latin1_General_BIN2 LIKE '%[^0-9a-fA-F]%')
        THROW 50084, N'La huella anterior no es válida.', 1;

    DECLARE @Abierta bit = CASE WHEN EXISTS (
        SELECT 1 FROM sys.extended_properties
        WHERE class = 1 AND major_id = OBJECT_ID(N'seguridad.tbUsuarios') AND minor_id = 0
          AND name = N'TransicionContrasenas' AND CONVERT(nvarchar(20), value) = N'abierta') THEN 1 ELSE 0 END;
    DECLARE @Filas int;

    BEGIN TRAN;
        UPDATE seguridad.tbUsuarios
        SET [Usu_Contraseña]       = @Contrasena,
            Usu_ContrasenaLegado   = CASE WHEN @Abierta = 1 THEN @ContrasenaLegado END,
            Usu_fechaModificacion  = GETDATE()
        WHERE Usu_Id = @Usu_Id
          AND (@ContrasenaEsperada IS NULL
               OR [Usu_Contraseña] COLLATE Latin1_General_BIN2 = @ContrasenaEsperada COLLATE Latin1_General_BIN2);
        SET @Filas = @@ROWCOUNT;

        IF @Filas > 0 AND @Bit_Accion IS NOT NULL
            INSERT INTO seguridad.tbBitacora (Usu_Id, Bit_Accion, Bit_Tabla, Bit_RegistroId, Bit_Descripcion, Bit_Ip)
            VALUES (ISNULL(@Bit_UsuId, @Usu_Id), @Bit_Accion, 'seguridad.tbUsuarios', @Usu_Id, NULL, @Bit_Ip);
    COMMIT;

    SELECT @Filas AS Filas;
END
GO

/* ─────────────────────────────── Cierre de la transición ─────────────────────────────── */
-- Correr UNA vez cuando el ADM y la API anteriores ya no usen esta base.
CREATE OR ALTER PROCEDURE seguridad.PR_tbUsuarios_CerrarTransicionContrasenas
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Limpiados int;

    BEGIN TRAN;
        IF EXISTS (SELECT 1 FROM sys.extended_properties
                   WHERE class = 1 AND major_id = OBJECT_ID(N'seguridad.tbUsuarios') AND minor_id = 0
                     AND name = N'TransicionContrasenas')
            EXEC sys.sp_updateextendedproperty
                @name = N'TransicionContrasenas', @value = N'cerrada',
                @level0type = N'SCHEMA', @level0name = N'seguridad',
                @level1type = N'TABLE',  @level1name = N'tbUsuarios';
        ELSE
            EXEC sys.sp_addextendedproperty
                @name = N'TransicionContrasenas', @value = N'cerrada',
                @level0type = N'SCHEMA', @level0name = N'seguridad',
                @level1type = N'TABLE',  @level1name = N'tbUsuarios';

        UPDATE seguridad.tbUsuarios SET Usu_ContrasenaLegado = NULL WHERE Usu_ContrasenaLegado IS NOT NULL;
        SET @Limpiados = @@ROWCOUNT;
    COMMIT;

    SELECT @Limpiados AS Limpiados;
END
GO

/* ─────────────────────────────── Procedimiento del código anterior ─────────────────────────────── */
-- Misma firma y mismas columnas de siempre. Único cambio: acepta también la huella vieja guardada
-- durante la transición (usuarios que ya entraron con el código nuevo).
CREATE OR ALTER PROCEDURE seguridad.UDP_tbUsuarios_Login
    @Usu_Name NVARCHAR(100),
    @Usu_Contrasena VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            u.Usu_Id,
            u.Usu_Name,
            u.Emp_Id,
            u.Rol_Id,
            r.Rol_Descripcion AS Rol_Nombre,
            u.Usu_EsActivo,
            u.Usu_Suspendido,
            u.Usu_EsEliminado,
            CASE
                WHEN u.Usu_Name = @Usu_Name
                     AND (u.[Usu_Contraseña] = @Usu_Contrasena OR u.Usu_ContrasenaLegado = @Usu_Contrasena)
                     AND u.Usu_EsActivo = 1
                     AND ISNULL(u.Usu_Suspendido, 0) = 0
                     AND ISNULL(u.Usu_EsEliminado, 0) = 0
                THEN 1
                ELSE 0
            END AS IsAuthenticated,
            CASE
                WHEN u.Usu_Name = @Usu_Name
                     AND (u.[Usu_Contraseña] = @Usu_Contrasena OR u.Usu_ContrasenaLegado = @Usu_Contrasena)
                     AND u.Usu_EsActivo = 1
                     AND ISNULL(u.Usu_Suspendido, 0) = 0
                     AND ISNULL(u.Usu_EsEliminado, 0) = 0
                THEN 'Login exitoso'
                WHEN NOT EXISTS (SELECT 1 FROM seguridad.tbUsuarios WHERE Usu_Name = @Usu_Name)
                THEN 'Usuario no encontrado'
                WHEN NOT (u.[Usu_Contraseña] = @Usu_Contrasena OR ISNULL(u.Usu_ContrasenaLegado, '') = @Usu_Contrasena)
                THEN 'Contrasena incorrecta'
                WHEN u.Usu_EsActivo = 0
                THEN 'Usuario inactivo'
                WHEN ISNULL(u.Usu_Suspendido, 0) = 1
                THEN 'Usuario suspendido'
                WHEN ISNULL(u.Usu_EsEliminado, 0) = 1
                THEN 'Usuario eliminado'
                ELSE 'Error de autenticacion'
            END AS Message
        FROM
            seguridad.tbUsuarios u
            INNER JOIN seguridad.tbRoles r ON u.Rol_Id = r.Rol_Id
        WHERE
            u.Usu_Name = @Usu_Name;

    END TRY
    BEGIN CATCH
        SELECT
            0 AS Usu_Id,
            NULL AS Usu_Name,
            NULL AS Emp_Id,
            NULL AS Rol_Id,
            NULL AS Rol_Nombre,
            0 AS Usu_EsActivo,
            0 AS Usu_Suspendido,
            0 AS Usu_EsEliminado,
            0 AS IsAuthenticated,
            ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

/* ─────────────────────────────── Límite de intentos ─────────────────────────────── */
-- Reemplazado por PR_tbIntentosLogin_Reservar (consultar primero y contar después dejaba pasar
-- varios intentos simultáneos).
DROP PROCEDURE IF EXISTS seguridad.PR_tbIntentosLogin_Consultar;
GO

-- Se llama ANTES de revisar la contraseña. En un solo paso, con las filas tomadas:
--   - si el usuario o la IP ya están bloqueados, no cuenta nada y responde Permitido = 0;
--   - si no, cuenta el intento como fallo para el usuario y la IP (si la contraseña resulta
--     correcta, PR_tbIntentosLogin_RegistrarExito lo descuenta) y, si llegan al máximo, el
--     bloqueo empieza ya para los siguientes intentos. Este intento sí se revisa.
-- Así varios intentos al mismo tiempo no pasan del máximo.
-- Responde { Permitido, Segundos, BloqueoUsuario, BloqueoIp }:
--   Permitido = 0: Segundos que faltan del bloqueo vigente.
--   Permitido = 1: Segundos del bloqueo que inició este intento (0 = ninguno) y quién quedó bloqueado.
CREATE OR ALTER PROCEDURE seguridad.PR_tbIntentosLogin_Reservar
    @Usuario         nvarchar(100),
    @Ip              varchar(45)  = NULL,
    @MaxUsuario      int          = 5,
    @MaxIp           int          = 20,
    @VentanaMinutos  int          = 15,
    @BloqueoMinutos  int          = 15
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Ahora datetime2(0) = SYSUTCDATETIME();
    DECLARE @Desde datetime2(0) = DATEADD(MINUTE, -@VentanaMinutos, @Ahora);
    DECLARE @Claves TABLE (Clave nvarchar(150) PRIMARY KEY, Maximo int NOT NULL, EsUsuario bit NOT NULL);
    DECLARE @Bloqueos TABLE (EsUsuario bit NOT NULL);
    DECLARE @Vigente int;

    SET @Usuario = LEFT(LOWER(LTRIM(RTRIM(ISNULL(@Usuario, N'')))), 100);
    SET @Ip = NULLIF(LTRIM(RTRIM(@Ip)), '');
    IF @Usuario <> N'' AND @MaxUsuario > 0 INSERT INTO @Claves VALUES (N'u:' + @Usuario, @MaxUsuario, 1);
    IF @Ip IS NOT NULL AND @MaxIp > 0      INSERT INTO @Claves VALUES (N'ip:' + @Ip, @MaxIp, 0);

    -- Limpieza: lo que lleva más de un día sin fallos y sin bloqueo vigente.
    DELETE TOP (200) FROM seguridad.tbIntentosLogin
    WHERE Ilo_UltimoFallo < DATEADD(DAY, -1, @Ahora)
      AND (Ilo_BloqueadoHasta IS NULL OR Ilo_BloqueadoHasta < @Ahora);

    BEGIN TRAN;
        -- Las claves (existan o no) quedan tomadas hasta el COMMIT: los intentos simultáneos esperan su turno.
        SELECT @Vigente = MAX(CASE WHEN t.Ilo_BloqueadoHasta > @Ahora THEN DATEDIFF(SECOND, @Ahora, t.Ilo_BloqueadoHasta) END)
        FROM @Claves c
        LEFT JOIN seguridad.tbIntentosLogin t WITH (UPDLOCK, HOLDLOCK) ON t.Ilo_Clave = c.Clave;

        IF @Vigente IS NULL
        BEGIN
            INSERT INTO seguridad.tbIntentosLogin (Ilo_Clave, Ilo_Fallos, Ilo_PrimerFallo, Ilo_UltimoFallo)
            SELECT c.Clave, 0, @Ahora, @Ahora
            FROM @Claves c
            WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbIntentosLogin t WITH (UPDLOCK, HOLDLOCK) WHERE t.Ilo_Clave = c.Clave);

            -- Conteo nuevo si la ventana ya pasó o si hubo un bloqueo (aquí ya vencido).
            UPDATE t
            SET Ilo_Fallos         = CASE WHEN t.Ilo_PrimerFallo < @Desde OR t.Ilo_BloqueadoHasta IS NOT NULL THEN 1 ELSE t.Ilo_Fallos + 1 END,
                Ilo_PrimerFallo    = CASE WHEN t.Ilo_PrimerFallo < @Desde OR t.Ilo_BloqueadoHasta IS NOT NULL THEN @Ahora ELSE t.Ilo_PrimerFallo END,
                Ilo_BloqueadoHasta = NULL,
                Ilo_UltimoFallo    = @Ahora
            FROM seguridad.tbIntentosLogin t
            INNER JOIN @Claves c ON c.Clave = t.Ilo_Clave;

            UPDATE t
            SET Ilo_BloqueadoHasta = DATEADD(MINUTE, @BloqueoMinutos, @Ahora)
            OUTPUT c.EsUsuario INTO @Bloqueos (EsUsuario)
            FROM seguridad.tbIntentosLogin t
            INNER JOIN @Claves c ON c.Clave = t.Ilo_Clave
            WHERE t.Ilo_Fallos >= c.Maximo;
        END
    COMMIT;

    SELECT CAST(CASE WHEN @Vigente IS NULL THEN 1 ELSE 0 END AS int) AS Permitido,
           ISNULL(@Vigente, CASE WHEN EXISTS (SELECT 1 FROM @Bloqueos) THEN @BloqueoMinutos * 60 ELSE 0 END) AS Segundos,
           CAST(CASE WHEN EXISTS (SELECT 1 FROM @Bloqueos WHERE EsUsuario = 1) THEN 1 ELSE 0 END AS int) AS BloqueoUsuario,
           CAST(CASE WHEN EXISTS (SELECT 1 FROM @Bloqueos WHERE EsUsuario = 0) THEN 1 ELSE 0 END AS int) AS BloqueoIp;
END
GO

-- Contraseña incorrecta (el intento ya se contó en PR_tbIntentosLogin_Reservar): deja el fallo en la
-- bitácora y, si ese intento inició un bloqueo, también el bloqueo. Solo para usuarios que existen.
-- Responde { Filas } (registros de bitácora).
CREATE OR ALTER PROCEDURE seguridad.PR_tbIntentosLogin_RegistrarFallo
    @Usu_Id          int          = NULL,
    @Ip              varchar(45)  = NULL,
    @Motivo          varchar(500) = NULL,
    @BloqueoUsuario  bit          = 0,
    @BloqueoIp       bit          = 0,
    @BloqueoMinutos  int          = 15
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Filas int = 0;

    IF @Usu_Id IS NOT NULL AND EXISTS (SELECT 1 FROM seguridad.tbUsuarios WHERE Usu_Id = @Usu_Id)
    BEGIN
        BEGIN TRAN;
            INSERT INTO seguridad.tbBitacora (Usu_Id, Bit_Accion, Bit_Tabla, Bit_RegistroId, Bit_Descripcion, Bit_Ip)
            VALUES (@Usu_Id, 'Inicio de sesión fallido', 'seguridad.tbUsuarios', @Usu_Id, LEFT(@Motivo, 500), @Ip);
            SET @Filas = 1;

            INSERT INTO seguridad.tbBitacora (Usu_Id, Bit_Accion, Bit_Tabla, Bit_RegistroId, Bit_Descripcion, Bit_Ip)
            SELECT @Usu_Id, 'Inicio de sesión bloqueado', 'seguridad.tbUsuarios', @Usu_Id,
                   CONCAT('Bloqueado ', @BloqueoMinutos, ' minutos por demasiados intentos fallidos', b.Texto), @Ip
            FROM (SELECT ' con este usuario.' AS Texto WHERE @BloqueoUsuario = 1
                  UNION ALL
                  SELECT ' desde esta IP.' WHERE @BloqueoIp = 1) b;
            SET @Filas += @@ROWCOUNT;
        COMMIT;
    END

    SELECT @Filas AS Filas;
END
GO

-- Contraseña correcta: el usuario empieza de cero y a la IP se le descuenta el intento reservado
-- (una entrada correcta no cuenta como fallo, pero tampoco borra los fallos de la IP: una cuenta
-- propia no sirve para seguir probando otras).
CREATE OR ALTER PROCEDURE seguridad.PR_tbIntentosLogin_RegistrarExito
    @Usuario nvarchar(100),
    @Ip      varchar(45) = NULL,
    @MaxIp   int         = 20
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Filas int;
    SET @Usuario = LEFT(LOWER(LTRIM(RTRIM(ISNULL(@Usuario, N'')))), 100);
    SET @Ip = NULLIF(LTRIM(RTRIM(@Ip)), '');

    BEGIN TRAN;
        DELETE FROM seguridad.tbIntentosLogin WHERE Ilo_Clave = N'u:' + @Usuario;
        SET @Filas = @@ROWCOUNT;

        UPDATE seguridad.tbIntentosLogin
        SET Ilo_Fallos         = Ilo_Fallos - 1,
            Ilo_BloqueadoHasta = CASE WHEN Ilo_Fallos - 1 < @MaxIp THEN NULL ELSE Ilo_BloqueadoHasta END
        WHERE Ilo_Clave = N'ip:' + @Ip AND Ilo_Fallos > 0;
    COMMIT;

    SELECT @Filas AS Filas;
END
GO
