/* 087 · Usuarios y sesiones.
   1) Sello de sesión (seguridad.tbUsuarios.Usu_SelloSesion): cambia cuando se cambia la contraseña, se
      desactiva la cuenta o se cambia el rol. El ADM lo guarda en la cookie de login y cierra las
      sesiones cuyo sello ya no coincide.
   2) Crear y editar usuarios con la misma regla de nombre (letras, números, punto, guion y guion bajo,
      4 a 50 caracteres, sin espacios) y sin dejar un error falso en el registro (los procedimientos de
      crear, editar y eliminar apagaban el conteo de filas y la API lo leía como "ninguna fila").
   Va después de 084 y 085. Se puede correr varias veces. */
USE DB_GestionColegial;
GO

IF COL_LENGTH(N'seguridad.tbUsuarios', N'Usu_SelloSesion') IS NULL
    ALTER TABLE seguridad.tbUsuarios
        ADD Usu_SelloSesion uniqueidentifier NOT NULL
            CONSTRAINT DF_tbUsuarios_SelloSesion DEFAULT (NEWID()) WITH VALUES;
GO

/* ─────────────── Datos para iniciar sesión (agrega el sello) ─────────────── */
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
                   AND ISNULL(u.Usu_EsEliminado, 0) = 0 THEN 1 ELSE 0 END AS int) AS Habilitado,
        CONVERT(varchar(36), u.Usu_SelloSesion) AS Usu_SelloSesion
    FROM seguridad.tbUsuarios u
    INNER JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
    WHERE (@Usu_Id IS NOT NULL AND u.Usu_Id = @Usu_Id)
       OR (@Usu_Id IS NULL AND u.Usu_Name = LTRIM(RTRIM(@Usu_Name)))
    ORDER BY Habilitado DESC, u.Usu_Id;
END
GO

/* ─────────────── Estado de la sesión de un usuario (lo consulta el ADM cada pocos minutos) ─────────────── */
-- Responde { Habilitado (1 = activa, no suspendida, no eliminada), Sello }. Sin fila = la cuenta no existe.
CREATE OR ALTER PROCEDURE seguridad.PR_tbUsuarios_EstadoSesion
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(CASE WHEN u.Usu_EsActivo = 1
                      AND ISNULL(u.Usu_Suspendido, 0) = 0
                      AND ISNULL(u.Usu_EsEliminado, 0) = 0 THEN 1 ELSE 0 END AS int) AS Habilitado,
           CONVERT(varchar(36), u.Usu_SelloSesion) AS Sello
    FROM seguridad.tbUsuarios u
    WHERE u.Usu_Id = @Usu_Id;
END
GO

/* ─────────────── Guardar contraseña: ahora también renueva el sello ─────────────── */
-- Igual que antes (misma firma y mismo resultado). El sello cambia en todo cambio de contraseña, salvo en la
-- conversión de formato que se hace al iniciar sesión (ahí @ContrasenaEsperada viene lleno).
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
            Usu_SelloSesion        = CASE WHEN @ContrasenaEsperada IS NULL THEN NEWID() ELSE Usu_SelloSesion END,
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

/* ─────────────── Crear usuario ─────────────── */
-- Sin SET NOCOUNT ON: la API cuenta las filas afectadas y con el conteo apagado leía "ninguna fila" (-1).
CREATE OR ALTER PROCEDURE Seguridad.UDP_tbUsuarios_Insert
    @Usu_Name      NVARCHAR(50),
    @Usu_Contrasena VARCHAR(255),
    @Rol_Id         INT,
    @Emp_Id         INT
AS
BEGIN
    SET @Usu_Name = LTRIM(RTRIM(@Usu_Name));
    IF @Usu_Name IS NULL OR LEN(@Usu_Name) < 4 OR LEN(@Usu_Name) > 50
       OR @Usu_Name COLLATE Latin1_General_BIN2 LIKE N'%[^-a-zA-Z0-9._]%'
        THROW 50090, N'El usuario debe tener entre 4 y 50 caracteres: letras, números, punto, guion o guion bajo, sin espacios.', 1;
    IF EXISTS (SELECT 1 FROM Seguridad.tbUsuarios WHERE Usu_Name = @Usu_Name AND Usu_EsEliminado = 0)
        THROW 50090, N'Ese nombre de usuario ya está en uso.', 1;

    DECLARE @sql NVARCHAR(MAX);
    DECLARE @colName NVARCHAR(128);
    SELECT @colName = c.name FROM sys.columns c WHERE c.object_id = OBJECT_ID('Seguridad.tbUsuarios') AND c.column_id = 4;
    SET @sql = N'INSERT INTO Seguridad.tbUsuarios (Usu_Name, ' + QUOTENAME(@colName) + N', Rol_Id, Emp_Id, Usu_EsActivo, Usu_EsEliminado, Usu_FechaCreacion) VALUES (@p1, @p2, @p3, @p4, 1, 0, GETDATE())';
    EXEC sp_executesql @sql, N'@p1 NVARCHAR(50), @p2 VARCHAR(255), @p3 INT, @p4 INT', @Usu_Name, @Usu_Contrasena, @Rol_Id, @Emp_Id;
END
GO

/* ─────────────── Editar usuario ─────────────── */
-- Misma firma. Sin SET NOCOUNT ON (ver Insert). Misma regla de nombre que al crear. El sello cambia si
-- cambia el rol o si la cuenta pasa de activa a inactiva.
CREATE OR ALTER PROCEDURE Seguridad.UDP_tbUsuarios_Update
    @Usu_Id         INT,
    @Usu_Name       NVARCHAR(50),
    @Rol_Id         INT,
    @Emp_Id         INT,
    @Usu_EsActivo   BIT
AS
BEGIN
    SET @Usu_Name = LTRIM(RTRIM(@Usu_Name));
    IF @Usu_Name IS NULL OR LEN(@Usu_Name) < 4 OR LEN(@Usu_Name) > 50
       OR @Usu_Name COLLATE Latin1_General_BIN2 LIKE N'%[^-a-zA-Z0-9._]%'
        THROW 50090, N'El usuario debe tener entre 4 y 50 caracteres: letras, números, punto, guion o guion bajo, sin espacios.', 1;
    IF EXISTS (SELECT 1 FROM Seguridad.tbUsuarios WHERE Usu_Name = @Usu_Name AND Usu_EsEliminado = 0 AND Usu_Id <> @Usu_Id)
        THROW 50090, N'Ese nombre de usuario ya está en uso.', 1;

    UPDATE Seguridad.tbUsuarios
    SET Usu_Name = @Usu_Name,
        Rol_Id = @Rol_Id,
        Emp_Id = @Emp_Id,
        Usu_EsActivo = @Usu_EsActivo,
        Usu_SelloSesion = CASE WHEN Rol_Id <> @Rol_Id OR (Usu_EsActivo = 1 AND @Usu_EsActivo = 0)
                               THEN NEWID() ELSE Usu_SelloSesion END,
        Usu_fechaModificacion = GETDATE()
    WHERE Usu_Id = @Usu_Id;
END
GO

/* ─────────────── Eliminar usuario (borrado lógico) ─────────────── */
CREATE OR ALTER PROCEDURE Seguridad.UDP_tbUsuarios_Delete
    @Usu_Id INT
AS
BEGIN
    UPDATE Seguridad.tbUsuarios
    SET Usu_EsEliminado = 1,
        Usu_EsActivo = 0,
        Usu_SelloSesion = NEWID(),
        Usu_fechaModificacion = GETDATE()
    WHERE Usu_Id = @Usu_Id;
END
GO

/* ─────────────── Portal: aceptar la invitación (renueva el sello cuando la cuenta ya existía) ─────────────── */
-- Idéntico al de 085, salvo Usu_SelloSesion en el UPDATE de la cuenta existente.
CREATE OR ALTER PROCEDURE app.PR_Portal_Invitaciones_Aceptar
    @TokenHash  char(64),
    @Usu_Name   nvarchar(50),
    @Contrasena varchar(255)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Inv_Id int, @Enc_Id int, @Estado varchar(10), @Vence datetime, @Usu_Id int, @Rol_Id int;
    SET @Usu_Name = NULLIF(LTRIM(RTRIM(@Usu_Name)), N'');

    SELECT TOP (1) @Rol_Id = Rol_Id FROM seguridad.tbRoles
    WHERE LOWER(LTRIM(RTRIM(Rol_Descripcion))) = N'encargado' AND Rol_EsEliminado = 0 ORDER BY Rol_Id;
    IF @Rol_Id IS NULL
        THROW 50089, N'El portal de padres no está configurado (falta el rol Encargado).', 1;
    IF @Usu_Name IS NULL OR LEN(@Usu_Name) < 4 OR @Usu_Name COLLATE Latin1_General_BIN2 LIKE N'%[^-a-zA-Z0-9._]%'
        THROW 50089, N'El usuario debe tener al menos 4 caracteres: letras, números, punto, guion o guion bajo, sin espacios.', 1;

    BEGIN TRAN;
        SELECT @Inv_Id = Inv_Id, @Enc_Id = Enc_Id, @Estado = Inv_Estado, @Vence = Inv_Vence
        FROM app.tbInvitacionesPortal WITH (UPDLOCK, HOLDLOCK)
        WHERE Inv_TokenHash = LOWER(@TokenHash);

        IF @Inv_Id IS NULL OR @Estado <> 'pendiente' OR @Vence < GETDATE()
            THROW 50089, N'Este enlace de invitación ya no es válido. Pida uno nuevo al colegio.', 1;

        SELECT @Usu_Id = Usu_Id FROM seguridad.tbUsuariosEncargados WITH (UPDLOCK, HOLDLOCK) WHERE Enc_Id = @Enc_Id;

        IF EXISTS (SELECT 1 FROM seguridad.tbUsuarios WITH (UPDLOCK, HOLDLOCK)
                   WHERE Usu_Name = @Usu_Name AND (@Usu_Id IS NULL OR Usu_Id <> @Usu_Id))
            THROW 50089, N'Ese nombre de usuario ya está en uso. Elija otro.', 1;

        IF @Usu_Id IS NULL
        BEGIN
            INSERT INTO seguridad.tbUsuarios (Emp_Id, Usu_Name, [Usu_Contraseña], Rol_Id, Usu_EsActivo, Usu_Suspendido, Usu_EsEliminado, Usu_FechaCreacion)
            VALUES (0, @Usu_Name, @Contrasena, @Rol_Id, 1, 0, 0, GETDATE());
            SET @Usu_Id = SCOPE_IDENTITY();
            INSERT INTO seguridad.tbUsuariosEncargados (Usu_Id, Enc_Id) VALUES (@Usu_Id, @Enc_Id);
        END
        ELSE
            UPDATE seguridad.tbUsuarios
            SET Usu_Name = @Usu_Name, [Usu_Contraseña] = @Contrasena, Usu_ContrasenaLegado = NULL, Rol_Id = @Rol_Id,
                Usu_EsActivo = 1, Usu_EsEliminado = 0, Usu_SelloSesion = NEWID(), Usu_fechaModificacion = GETDATE()
            WHERE Usu_Id = @Usu_Id;

        UPDATE app.tbInvitacionesPortal
        SET Inv_Estado = 'aceptada', Inv_FechaAceptada = GETDATE(), Usu_IdCuenta = @Usu_Id
        WHERE Inv_Id = @Inv_Id;
    COMMIT;

    SELECT @Usu_Id AS Usu_Id, @Usu_Name AS Usu_Name;
END
GO

/* ─────────────── Docente: ya no liga ni desliga encargados ─────────────── */
-- Ligar o desligar encargados lo exige "Editar alumnos" (o Matrícula nueva / Crear alumnos). Esa pantalla
-- además deja editar los datos del alumno, algo que el docente no necesita para su trabajo (cuaderno de
-- notas, asistencia, plan de clases): se le quita. Lo conservan admin y secretaría.
DELETE rp
FROM seguridad.tbRolesPantallas rp
INNER JOIN seguridad.tbPantallas p ON p.Pan_Id = rp.Pan_Id
WHERE rp.Rol_Id = 2 AND p.Pan_Descripcion = N'Editar alumnos';
GO
