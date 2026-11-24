/* =============================================================================
   082 · Portal de padres  (espejo de Skuul: portal de familias, invitaciones de cuenta
         y bandeja de solicitudes)

   - Rol "Encargado" con la pantalla "Portal de padres". Un usuario Encargado no tiene empleado
     (Emp_Id = 0) y queda ligado a su encargado en seguridad.tbUsuariosEncargados.
   - app.tbInvitacionesPortal: Secretaría genera un enlace de un solo uso (se guarda solo la huella
     SHA-256 del código), con vencimiento. Estados: pendiente | aceptada | revocada (vencida se
     calcula). Al invitar de nuevo, la invitación pendiente anterior queda revocada.
     Si el encargado ya tiene cuenta, aceptar la invitación le pone una contraseña nueva.
   - app.tbSolicitudesPortal (+ historial): el encargado pide algo sobre uno de sus hijos
     (justificar una falta, cita, constancia u otro). Estados:
       nueva → en_proceso → atendida | rechazada ;  nueva | en_proceso → retirada (solo la familia).
     Una solicitud no cambia nada por sí sola (igual que en Skuul): es un mensaje con estado.
   - Toda lectura del portal recibe el usuario (lo pone la API con el usuario firmado) y se
     limita a los alumnos ligados a su encargado.
   - Permisos: "Portal de padres" (Encargado), "Invitaciones al portal" (secretaria),
     "Solicitudes del portal" (secretaria, director). El admin pasa todo.
   - Prefijos: Inv_, Sol_, Soh_. Errores 50082-50089.
   Idempotente: se puede correr varias veces.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ─────────────────────────────── Rol Encargado ─────────────────────────────── */
IF NOT EXISTS (SELECT 1 FROM seguridad.tbRoles WHERE LOWER(LTRIM(RTRIM(Rol_Descripcion))) = N'encargado')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM seguridad.tbRoles WHERE Rol_Id = 1008)
    BEGIN
        SET IDENTITY_INSERT seguridad.tbRoles ON;
        INSERT INTO seguridad.tbRoles (Rol_Id, Rol_Descripcion, Rol_Estado, Rol_EsEliminado, Rol_UsuarioRegistra, Rol_FechaRegistra)
        VALUES (1008, N'Encargado', 1, 0, 1, GETDATE());
        SET IDENTITY_INSERT seguridad.tbRoles OFF;
    END
    ELSE
        INSERT INTO seguridad.tbRoles (Rol_Descripcion, Rol_Estado, Rol_EsEliminado, Rol_UsuarioRegistra, Rol_FechaRegistra)
        VALUES (N'Encargado', 1, 0, 1, GETDATE());
END
GO

/* ─────────────────────────────── Tablas ─────────────────────────────── */
IF OBJECT_ID(N'seguridad.tbUsuariosEncargados', N'U') IS NULL
BEGIN
    CREATE TABLE seguridad.tbUsuariosEncargados
    (
        Usu_Id            int      NOT NULL,
        Enc_Id            int      NOT NULL,
        Uen_FechaRegistra datetime NOT NULL CONSTRAINT DF_tbUsuariosEncargados_Fecha DEFAULT (GETDATE()),
        CONSTRAINT PK_tbUsuariosEncargados PRIMARY KEY CLUSTERED (Usu_Id),
        CONSTRAINT UQ_tbUsuariosEncargados_Enc UNIQUE (Enc_Id),
        CONSTRAINT FK_tbUsuariosEncargados_Usuarios FOREIGN KEY (Usu_Id) REFERENCES seguridad.tbUsuarios (Usu_Id),
        CONSTRAINT FK_tbUsuariosEncargados_Encargados FOREIGN KEY (Enc_Id) REFERENCES app.tbEncargados (Enc_Id)
    );
END
GO

IF OBJECT_ID(N'app.tbInvitacionesPortal', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbInvitacionesPortal
    (
        Inv_Id             int          IDENTITY(1,1) NOT NULL,
        Enc_Id             int          NOT NULL,
        Inv_TokenHash      char(64)     NOT NULL,
        Inv_Vence          datetime     NOT NULL,
        Inv_Estado         varchar(10)  NOT NULL CONSTRAINT DF_tbInvitacionesPortal_Estado DEFAULT ('pendiente'),
        Usu_IdInvita       int          NOT NULL,
        Inv_FechaRegistra  datetime     NOT NULL CONSTRAINT DF_tbInvitacionesPortal_Fecha DEFAULT (GETDATE()),
        Inv_FechaAceptada  datetime     NULL,
        Usu_IdCuenta       int          NULL,
        Inv_FechaRevocada  datetime     NULL,
        Usu_IdRevoca       int          NULL,
        CONSTRAINT PK_tbInvitacionesPortal PRIMARY KEY CLUSTERED (Inv_Id),
        CONSTRAINT UQ_tbInvitacionesPortal_Token UNIQUE (Inv_TokenHash),
        CONSTRAINT CK_tbInvitacionesPortal_Estado CHECK (Inv_Estado IN ('pendiente', 'aceptada', 'revocada')),
        CONSTRAINT FK_tbInvitacionesPortal_Encargados FOREIGN KEY (Enc_Id) REFERENCES app.tbEncargados (Enc_Id)
    );
    CREATE INDEX IX_tbInvitacionesPortal_Enc ON app.tbInvitacionesPortal (Enc_Id, Inv_Id DESC);
END
GO

IF OBJECT_ID(N'app.tbSolicitudesPortal', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbSolicitudesPortal
    (
        Sol_Id             int            IDENTITY(1,1) NOT NULL,
        Enc_Id             int            NOT NULL,
        Alu_Id             int            NOT NULL,
        Usu_IdSolicita     int            NOT NULL,
        Sol_Tipo           varchar(12)    NOT NULL,
        Sol_Asunto         nvarchar(150)  NOT NULL,
        Sol_Detalle        nvarchar(2000) NULL,
        Sol_FechaFalta     date           NULL,
        Sol_Estado         varchar(12)    NOT NULL CONSTRAINT DF_tbSolicitudesPortal_Estado DEFAULT ('nueva'),
        Sol_Respuesta      nvarchar(2000) NULL,
        Usu_IdAtiende      int            NULL,
        Sol_FechaAtiende   datetime       NULL,
        Sol_FechaRegistra  datetime       NOT NULL CONSTRAINT DF_tbSolicitudesPortal_Fecha DEFAULT (GETDATE()),
        Sol_FechaModifica  datetime       NULL,
        CONSTRAINT PK_tbSolicitudesPortal PRIMARY KEY CLUSTERED (Sol_Id),
        CONSTRAINT CK_tbSolicitudesPortal_Tipo CHECK (Sol_Tipo IN ('justificar', 'cita', 'constancia', 'otro')),
        CONSTRAINT CK_tbSolicitudesPortal_Estado CHECK (Sol_Estado IN ('nueva', 'en_proceso', 'atendida', 'rechazada', 'retirada')),
        CONSTRAINT FK_tbSolicitudesPortal_Encargados FOREIGN KEY (Enc_Id) REFERENCES app.tbEncargados (Enc_Id),
        CONSTRAINT FK_tbSolicitudesPortal_Alumnos FOREIGN KEY (Alu_Id) REFERENCES app.tbAlumnos (Alu_Id)
    );
    CREATE INDEX IX_tbSolicitudesPortal_Estado ON app.tbSolicitudesPortal (Sol_Estado, Sol_Id DESC);
    CREATE INDEX IX_tbSolicitudesPortal_Enc ON app.tbSolicitudesPortal (Enc_Id, Alu_Id);
END
GO

IF OBJECT_ID(N'app.tbSolicitudesPortalHistorial', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbSolicitudesPortalHistorial
    (
        Soh_Id             int            IDENTITY(1,1) NOT NULL,
        Sol_Id             int            NOT NULL,
        Soh_EstadoAnterior varchar(12)    NULL,
        Soh_EstadoNuevo    varchar(12)    NOT NULL,
        Soh_Comentario     nvarchar(2000) NULL,
        Usu_Id             int            NOT NULL,
        Soh_Fecha          datetime       NOT NULL CONSTRAINT DF_tbSolicitudesPortalHistorial_Fecha DEFAULT (GETDATE()),
        CONSTRAINT PK_tbSolicitudesPortalHistorial PRIMARY KEY CLUSTERED (Soh_Id),
        CONSTRAINT FK_tbSolicitudesPortalHistorial_Sol FOREIGN KEY (Sol_Id) REFERENCES app.tbSolicitudesPortal (Sol_Id)
    );
    CREATE INDEX IX_tbSolicitudesPortalHistorial_Sol ON app.tbSolicitudesPortalHistorial (Sol_Id, Soh_Id);
END
GO

/* ─────────────────────────────── Funciones ─────────────────────────────── */

-- Encargado del usuario (solo si la cuenta está activa, no suspendida ni eliminada).
CREATE OR ALTER FUNCTION app.FN_Portal_Encargado (@Usu_Id int)
RETURNS int
AS
BEGIN
    RETURN (
        SELECT TOP (1) ue.Enc_Id
        FROM seguridad.tbUsuariosEncargados ue
        INNER JOIN seguridad.tbUsuarios u ON u.Usu_Id = ue.Usu_Id
        WHERE ue.Usu_Id = @Usu_Id
          AND u.Usu_EsActivo = 1 AND ISNULL(u.Usu_Suspendido, 0) = 0 AND ISNULL(u.Usu_EsEliminado, 0) = 0);
END
GO

-- 1 si el alumno está ligado al encargado del usuario.
CREATE OR ALTER FUNCTION app.FN_Portal_PuedeVer (@Usu_Id int, @Alu_Id int)
RETURNS bit
AS
BEGIN
    RETURN CASE WHEN EXISTS (
        SELECT 1
        FROM app.tbEncargados_tbAlumnos ea
        WHERE ea.Enc_Id = app.FN_Portal_Encargado(@Usu_Id) AND ea.Alu_Id = @Alu_Id) THEN 1 ELSE 0 END;
END
GO

-- Nombre completo de una persona.
CREATE OR ALTER FUNCTION app.FN_Portal_NombrePersona (@Per_Id int)
RETURNS nvarchar(250)
AS
BEGIN
    RETURN (
        SELECT LTRIM(RTRIM(CONCAT_WS(N' ',
                   NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''),
                   NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), N''),
                   NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''),
                   NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N''))))
        FROM app.tbPersonas p WHERE p.Per_Id = @Per_Id);
END
GO

-- Estado de una invitación: aceptada y revocada mandan; pendiente pasada de fecha = vencida.
CREATE OR ALTER FUNCTION app.FN_Portal_EstadoInvitacion (@Estado varchar(10), @Vence datetime)
RETURNS varchar(10)
AS
BEGIN
    RETURN CASE WHEN @Estado = 'pendiente' AND @Vence < GETDATE() THEN 'vencida' ELSE @Estado END;
END
GO

/* ─────────────────────────── Portal (familia) ─────────────────────────── */

-- Quién es el encargado del usuario (vacío si la cuenta no está ligada).
CREATE OR ALTER PROCEDURE app.PR_Portal_Encargado
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Enc_Id int = app.FN_Portal_Encargado(@Usu_Id);
    SELECT e.Enc_Id,
           app.FN_Portal_NombrePersona(e.Per_Id) AS Enc_Nombre,
           p.Per_PrimerNombre                   AS Enc_PrimerNombre,
           p.Per_CorreoElectronico              AS Enc_Correo,
           p.Per_Telefono                       AS Enc_Telefono
    FROM app.tbEncargados e
    INNER JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id
    WHERE e.Enc_Id = @Enc_Id;
END
GO

-- Hijos ligados al encargado del usuario, con un resumen para la tarjeta de inicio.
CREATE OR ALTER PROCEDURE app.PR_Portal_Hijos
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Enc_Id int = app.FN_Portal_Encargado(@Usu_Id);
    DECLARE @Hoy date = CAST(GETDATE() AS date);

    SELECT a.Alu_Id,
           app.FN_Portal_NombrePersona(a.Per_Id)              AS Alu_Nombre,
           p.Per_PrimerNombre                                AS Alu_PrimerNombre,
           p.Per_Imagen                                      AS Alu_Imagen,
           a.AnioCursado                                     AS Anio,
           niv.Niv_Descripcion                               AS Nivel,
           cun.Cun_Descripcion                               AS Grado,
           s.Sec_Descripcion                                 AS Seccion,
           LTRIM(RTRIM(REPLACE(REPLACE(c.Cur_Nombre, CHAR(13), ''), CHAR(10), ''))) AS Curso,
           par.Par_Descripcion                               AS Parentesco,
           ISNULL(est.Est_Descripcion, N'')                   AS Estado,
           ISNULL(cx.Pendiente, 0)                           AS SaldoPendiente,
           ISNULL(cx.Vencido, 0)                             AS SaldoVencido,
           ISNULL(asi.Ausencias, 0)                          AS Ausencias,
           ISNULL(asi.Tardanzas, 0)                          AS Tardanzas,
           ISNULL(asi.Registros, 0)                          AS RegistrosAsistencia,
           nt.Promedio                                       AS PromedioPublicado,
           ISNULL(sol.Abiertas, 0)                           AS SolicitudesAbiertas
    FROM app.tbEncargados_tbAlumnos ea
    INNER JOIN app.tbAlumnos a            ON a.Alu_Id = ea.Alu_Id
    INNER JOIN app.tbPersonas p           ON p.Per_Id = a.Per_Id
    LEFT  JOIN app.tbParentescos par      ON par.Par_Id = ea.Par_Id
    LEFT  JOIN app.tbNivelesEducativos niv ON niv.Niv_Id = a.Niv_Id
    LEFT  JOIN app.tbCursosNiveles cun    ON cun.Cun_Id = a.Cun_Id
    LEFT  JOIN app.tbSecciones s          ON s.Sec_Id = a.Sec_Id
    LEFT  JOIN app.tbCursos c             ON c.Cur_Id = a.Cur_Id
    LEFT  JOIN app.tbEstados est          ON est.Est_Id = a.Est_Id
    OUTER APPLY (SELECT SUM(cc.Cco_MontoPendiente) AS Pendiente,
                        SUM(CASE WHEN cc.Cco_FechaVencimiento < @Hoy THEN cc.Cco_MontoPendiente ELSE 0 END) AS Vencido
                 FROM finanza.tbCuentasCobrar cc
                 WHERE cc.Alu_Id = a.Alu_Id AND cc.Cco_EsEliminado = 0 AND cc.Cco_MontoPendiente > 0) cx
    OUTER APPLY (SELECT COUNT(*) AS Registros,
                        SUM(CASE WHEN x.Asi_Estado = 'A' THEN 1 ELSE 0 END) AS Ausencias,
                        SUM(CASE WHEN x.Asi_Estado = 'T' THEN 1 ELSE 0 END) AS Tardanzas
                 FROM app.tbAsistencia x
                 WHERE x.Alu_Id = a.Alu_Id AND x.Asi_EsEliminado = 0 AND YEAR(x.Asi_Fecha) = YEAR(@Hoy)) asi
    OUTER APPLY (SELECT CAST(AVG(CAST(n.Not_Nota AS decimal(7,2))) AS decimal(5,2)) AS Promedio
                 FROM app.tbNotas n
                 WHERE n.Alu_Id = a.Alu_Id AND n.Not_EsActivo = 1 AND n.Not_EsEliminado = 0
                   AND EXISTS (SELECT 1 FROM app.tbCierresParcial cp
                               WHERE cp.Cpa_Anio = YEAR(n.[Not_Año]) AND cp.Sem_Id = n.Sem_Id
                                 AND cp.Pac_Id = n.Pac_Id AND cp.Cpa_Publicado = 1)
                   AND YEAR(n.[Not_Año]) = a.AnioCursado) nt
    OUTER APPLY (SELECT COUNT(*) AS Abiertas
                 FROM app.tbSolicitudesPortal sp
                 WHERE sp.Enc_Id = @Enc_Id AND sp.Alu_Id = a.Alu_Id AND sp.Sol_Estado IN ('nueva', 'en_proceso')) sol
    WHERE ea.Enc_Id = @Enc_Id
      AND ISNULL(p.Per_EsEliminado, 0) = 0
    ORDER BY p.Per_FechaNacimiento DESC, a.Alu_Id;
END
GO

-- 1 fila { Puede } : la API la usa antes de reutilizar lecturas existentes (estado de cuenta, calendario).
CREATE OR ALTER PROCEDURE app.PR_Portal_PuedeVer
    @Usu_Id int,
    @Alu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT app.FN_Portal_PuedeVer(@Usu_Id, @Alu_Id) AS Puede;
END
GO

-- Notas de los parciales PUBLICADOS (app.tbCierresParcial), con el concepto de la escala.
CREATE OR ALTER PROCEDURE app.PR_Portal_Notas
    @Usu_Id int,
    @Alu_Id int,
    @Anio   int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF app.FN_Portal_PuedeVer(@Usu_Id, @Alu_Id) = 0 RETURN;
    IF @Anio IS NULL SELECT @Anio = AnioCursado FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id;

    SELECT n.Mat_Id,
           m.Mat_Nombre,
           n.Sem_Id,
           sem.Sem_Descripcion,
           n.Pac_Id,
           pac.Pac_Descripcion,
           CAST(n.Not_Nota AS decimal(5,2))                   AS Nota,
           app.FN_EscalaConcepto(CAST(n.Not_Nota AS decimal(5,2))) AS Concepto,
           CAST(CASE WHEN EXISTS (SELECT 1 FROM app.tbEscalaNotas e
                                  WHERE e.Esc_EsEliminado = 0 AND e.Esc_Aprueba = 1
                                    AND n.Not_Nota >= e.Esc_NotaDesde AND n.Not_Nota <= e.Esc_NotaHasta)
                     THEN 1 ELSE 0 END AS bit)                  AS Aprueba,
           cp.Cpa_FechaPublicacion                             AS FechaPublicacion,
           (SELECT MIN(e.Esc_NotaDesde) FROM app.tbEscalaNotas e
            WHERE e.Esc_EsEliminado = 0 AND e.Esc_Aprueba = 1)  AS NotaMinima
    FROM app.tbNotas n
    INNER JOIN app.tbCierresParcial cp ON cp.Cpa_Anio = @Anio AND cp.Sem_Id = n.Sem_Id
                                      AND cp.Pac_Id = n.Pac_Id AND cp.Cpa_Publicado = 1
    INNER JOIN app.tbMaterias m        ON m.Mat_Id = n.Mat_Id
    LEFT  JOIN app.tbSemestres sem     ON sem.Sem_Id = n.Sem_Id
    LEFT  JOIN app.tbParciales pac     ON pac.Pac_Id = n.Pac_Id
    WHERE n.Alu_Id = @Alu_Id
      AND YEAR(n.[Not_Año]) = @Anio
      AND n.Not_EsActivo = 1 AND n.Not_EsEliminado = 0
    ORDER BY m.Mat_Nombre, n.Sem_Id, n.Pac_Id;
END
GO

-- Asistencia del alumno en el año (cada clase registrada).
CREATE OR ALTER PROCEDURE app.PR_Portal_Asistencia
    @Usu_Id int,
    @Alu_Id int,
    @Anio   int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF app.FN_Portal_PuedeVer(@Usu_Id, @Alu_Id) = 0 RETURN;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());

    SELECT asi.Asi_Id,
           asi.Asi_Fecha,
           asi.Asi_Estado,
           asi.Asi_Observacion,
           m.Mat_Nombre,
           hi.Hor_Hora AS HoraInicio
    FROM app.tbAsistencia asi
    INNER JOIN app.tbHorarios h  ON h.Hor_Id = asi.Hor_Id
    INNER JOIN app.tbMaterias m  ON m.Mat_Id = h.Mat_Id
    LEFT  JOIN app.tbHoras hi    ON hi.Hor_Id = h.Hor_HoraInicio
    WHERE asi.Alu_Id = @Alu_Id AND YEAR(asi.Asi_Fecha) = @Anio AND asi.Asi_EsEliminado = 0
    ORDER BY asi.Asi_Fecha DESC, hi.Hor_Hora;
END
GO

-- Solicitudes que hizo el encargado del usuario (de un hijo o de todos los que sigue teniendo ligados).
CREATE OR ALTER PROCEDURE app.PR_Portal_Solicitudes
    @Usu_Id int,
    @Alu_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Enc_Id int = app.FN_Portal_Encargado(@Usu_Id);

    SELECT sp.Sol_Id, sp.Alu_Id,
           p.Per_PrimerNombre AS Alu_PrimerNombre,
           sp.Sol_Tipo, sp.Sol_Asunto, sp.Sol_Detalle, sp.Sol_FechaFalta,
           sp.Sol_Estado, sp.Sol_Respuesta, sp.Sol_FechaAtiende,
           sp.Sol_FechaRegistra
    FROM app.tbSolicitudesPortal sp
    INNER JOIN app.tbEncargados_tbAlumnos ea ON ea.Enc_Id = sp.Enc_Id AND ea.Alu_Id = sp.Alu_Id
    INNER JOIN app.tbAlumnos a  ON a.Alu_Id = sp.Alu_Id
    INNER JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id
    WHERE sp.Enc_Id = @Enc_Id
      AND (@Alu_Id IS NULL OR sp.Alu_Id = @Alu_Id)
    ORDER BY CASE WHEN sp.Sol_Estado IN ('nueva', 'en_proceso') THEN 0 ELSE 1 END, sp.Sol_Id DESC;
END
GO

-- Nueva solicitud del encargado sobre uno de sus hijos. Responde { Sol_Id, Sol_Estado }.
CREATE OR ALTER PROCEDURE app.PR_Portal_Solicitudes_Crear
    @Usuario    int,
    @Alu_Id     int,
    @Tipo       varchar(12),
    @Asunto     nvarchar(150),
    @Detalle    nvarchar(2000) = NULL,
    @FechaFalta date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Enc_Id int = app.FN_Portal_Encargado(@Usuario);
    SET @Asunto = NULLIF(LTRIM(RTRIM(@Asunto)), N'');
    SET @Detalle = NULLIF(LTRIM(RTRIM(@Detalle)), N'');

    IF @Enc_Id IS NULL OR app.FN_Portal_PuedeVer(@Usuario, @Alu_Id) = 0
        THROW 50082, N'No puede hacer solicitudes sobre este alumno.', 1;
    IF @Tipo NOT IN ('justificar', 'cita', 'constancia', 'otro')
        THROW 50083, N'Elija qué tipo de solicitud quiere hacer.', 1;
    IF @Asunto IS NULL
        THROW 50083, N'Escriba un asunto corto para su solicitud.', 1;
    IF @Tipo = 'justificar' AND @FechaFalta IS NULL
        THROW 50083, N'Indique la fecha de la falta que quiere justificar.', 1;
    IF @FechaFalta IS NOT NULL AND @FechaFalta > CAST(GETDATE() AS date)
        THROW 50083, N'La fecha de la falta no puede ser futura.', 1;
    IF @Tipo <> 'justificar' SET @FechaFalta = NULL;

    BEGIN TRAN;
        IF EXISTS (SELECT 1 FROM app.tbSolicitudesPortal WITH (UPDLOCK, HOLDLOCK)
                   WHERE Enc_Id = @Enc_Id AND Alu_Id = @Alu_Id AND Sol_Tipo = @Tipo
                     AND Sol_Asunto = @Asunto AND Sol_Estado IN ('nueva', 'en_proceso'))
            THROW 50084, N'Ya hizo esta misma solicitud y el colegio todavía no la responde.', 1;

        INSERT INTO app.tbSolicitudesPortal (Enc_Id, Alu_Id, Usu_IdSolicita, Sol_Tipo, Sol_Asunto, Sol_Detalle, Sol_FechaFalta)
        VALUES (@Enc_Id, @Alu_Id, @Usuario, @Tipo, @Asunto, @Detalle, @FechaFalta);
        DECLARE @Sol_Id int = SCOPE_IDENTITY();

        INSERT INTO app.tbSolicitudesPortalHistorial (Sol_Id, Soh_EstadoAnterior, Soh_EstadoNuevo, Soh_Comentario, Usu_Id)
        VALUES (@Sol_Id, NULL, 'nueva', NULL, @Usuario);
    COMMIT;

    SELECT @Sol_Id AS Sol_Id, CAST('nueva' AS varchar(12)) AS Sol_Estado;
END
GO

-- La familia retira una solicitud que sigue abierta. Responde { Sol_Id, Sol_Estado }.
CREATE OR ALTER PROCEDURE app.PR_Portal_Solicitudes_Retirar
    @Usuario int,
    @Sol_Id  int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Enc_Id int = app.FN_Portal_Encargado(@Usuario), @Estado varchar(12), @Dueno int;

    BEGIN TRAN;
        SELECT @Estado = Sol_Estado, @Dueno = Enc_Id
        FROM app.tbSolicitudesPortal WITH (UPDLOCK, HOLDLOCK)
        WHERE Sol_Id = @Sol_Id;

        IF @Estado IS NULL OR @Enc_Id IS NULL OR @Dueno <> @Enc_Id
            THROW 50082, N'No se encontró la solicitud.', 1;
        IF @Estado NOT IN ('nueva', 'en_proceso')
            THROW 50085, N'El colegio ya cerró esta solicitud; no se puede retirar.', 1;

        UPDATE app.tbSolicitudesPortal SET Sol_Estado = 'retirada', Sol_FechaModifica = GETDATE() WHERE Sol_Id = @Sol_Id;
        INSERT INTO app.tbSolicitudesPortalHistorial (Sol_Id, Soh_EstadoAnterior, Soh_EstadoNuevo, Soh_Comentario, Usu_Id)
        VALUES (@Sol_Id, @Estado, 'retirada', N'La familia retiró la solicitud.', @Usuario);
    COMMIT;

    SELECT @Sol_Id AS Sol_Id, CAST('retirada' AS varchar(12)) AS Sol_Estado;
END
GO

/* ─────────────────────── Bandeja de solicitudes (colegio) ─────────────────────── */

CREATE OR ALTER PROCEDURE app.PR_Portal_Bandeja_List
    @Estado varchar(12)   = NULL,   -- NULL = todas; 'abiertas' = nueva + en_proceso
    @Tipo   varchar(12)   = NULL,
    @Texto  nvarchar(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Texto = NULLIF(LTRIM(RTRIM(@Texto)), N'');

    SELECT TOP (500)
           sp.Sol_Id, sp.Sol_Tipo, sp.Sol_Asunto, sp.Sol_FechaFalta, sp.Sol_Estado,
           sp.Sol_FechaRegistra, sp.Sol_FechaAtiende,
           sp.Alu_Id, app.FN_Portal_NombrePersona(a.Per_Id) AS Alu_Nombre,
           cun.Cun_Descripcion AS Grado, s.Sec_Descripcion AS Seccion,
           sp.Enc_Id, app.FN_Portal_NombrePersona(e.Per_Id) AS Enc_Nombre,
           ua.Usu_Name AS AtendidoPor
    FROM app.tbSolicitudesPortal sp
    INNER JOIN app.tbAlumnos a    ON a.Alu_Id = sp.Alu_Id
    INNER JOIN app.tbPersonas pa  ON pa.Per_Id = a.Per_Id
    INNER JOIN app.tbEncargados e ON e.Enc_Id = sp.Enc_Id
    INNER JOIN app.tbPersonas pe  ON pe.Per_Id = e.Per_Id
    LEFT  JOIN app.tbCursosNiveles cun ON cun.Cun_Id = a.Cun_Id
    LEFT  JOIN app.tbSecciones s  ON s.Sec_Id = a.Sec_Id
    LEFT  JOIN seguridad.tbUsuarios ua ON ua.Usu_Id = sp.Usu_IdAtiende
    WHERE (@Estado IS NULL
           OR (@Estado = 'abiertas' AND sp.Sol_Estado IN ('nueva', 'en_proceso'))
           OR sp.Sol_Estado = @Estado)
      AND (@Tipo IS NULL OR sp.Sol_Tipo = @Tipo)
      AND (@Texto IS NULL
           OR sp.Sol_Asunto LIKE N'%' + @Texto + N'%'
           OR CONCAT_WS(N' ', pa.Per_PrimerNombre, pa.Per_SegundoNombre, pa.Per_ApellidoPaterno, pa.Per_ApellidoMaterno) LIKE N'%' + @Texto + N'%'
           OR CONCAT_WS(N' ', pe.Per_PrimerNombre, pe.Per_SegundoNombre, pe.Per_ApellidoPaterno, pe.Per_ApellidoMaterno) LIKE N'%' + @Texto + N'%')
    ORDER BY CASE sp.Sol_Estado WHEN 'nueva' THEN 0 WHEN 'en_proceso' THEN 1 ELSE 2 END, sp.Sol_Id DESC;
END
GO

CREATE OR ALTER PROCEDURE app.PR_Portal_Bandeja_Resumen
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Mes date = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    SELECT SUM(CASE WHEN Sol_Estado = 'nueva' THEN 1 ELSE 0 END)      AS Nuevas,
           SUM(CASE WHEN Sol_Estado = 'en_proceso' THEN 1 ELSE 0 END) AS EnProceso,
           SUM(CASE WHEN Sol_Estado = 'atendida' AND Sol_FechaAtiende >= @Mes THEN 1 ELSE 0 END)  AS AtendidasMes,
           SUM(CASE WHEN Sol_Estado = 'rechazada' AND Sol_FechaAtiende >= @Mes THEN 1 ELSE 0 END) AS RechazadasMes
    FROM app.tbSolicitudesPortal;
END
GO

CREATE OR ALTER PROCEDURE app.PR_Portal_Bandeja_Find
    @Sol_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT sp.Sol_Id, sp.Sol_Tipo, sp.Sol_Asunto, sp.Sol_Detalle, sp.Sol_FechaFalta, sp.Sol_Estado,
           sp.Sol_Respuesta, sp.Sol_FechaRegistra, sp.Sol_FechaAtiende,
           sp.Alu_Id, app.FN_Portal_NombrePersona(a.Per_Id) AS Alu_Nombre,
           cun.Cun_Descripcion AS Grado, s.Sec_Descripcion AS Seccion,
           sp.Enc_Id, app.FN_Portal_NombrePersona(e.Per_Id) AS Enc_Nombre,
           pe.Per_Telefono AS Enc_Telefono, pe.Per_CorreoElectronico AS Enc_Correo,
           par.Par_Descripcion AS Parentesco,
           us.Usu_Name AS SolicitadoPor, ua.Usu_Name AS AtendidoPor
    FROM app.tbSolicitudesPortal sp
    INNER JOIN app.tbAlumnos a    ON a.Alu_Id = sp.Alu_Id
    INNER JOIN app.tbEncargados e ON e.Enc_Id = sp.Enc_Id
    INNER JOIN app.tbPersonas pe  ON pe.Per_Id = e.Per_Id
    LEFT  JOIN app.tbEncargados_tbAlumnos ea ON ea.Enc_Id = sp.Enc_Id AND ea.Alu_Id = sp.Alu_Id
    LEFT  JOIN app.tbParentescos par ON par.Par_Id = ea.Par_Id
    LEFT  JOIN app.tbCursosNiveles cun ON cun.Cun_Id = a.Cun_Id
    LEFT  JOIN app.tbSecciones s  ON s.Sec_Id = a.Sec_Id
    LEFT  JOIN seguridad.tbUsuarios us ON us.Usu_Id = sp.Usu_IdSolicita
    LEFT  JOIN seguridad.tbUsuarios ua ON ua.Usu_Id = sp.Usu_IdAtiende
    WHERE sp.Sol_Id = @Sol_Id;
END
GO

CREATE OR ALTER PROCEDURE app.PR_Portal_Bandeja_Historial
    @Sol_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT h.Soh_Id, h.Soh_EstadoAnterior, h.Soh_EstadoNuevo, h.Soh_Comentario, h.Soh_Fecha,
           u.Usu_Name,
           CAST(CASE WHEN ue.Usu_Id IS NULL THEN 0 ELSE 1 END AS bit) AS EsFamilia
    FROM app.tbSolicitudesPortalHistorial h
    LEFT JOIN seguridad.tbUsuarios u ON u.Usu_Id = h.Usu_Id
    LEFT JOIN seguridad.tbUsuariosEncargados ue ON ue.Usu_Id = h.Usu_Id
    WHERE h.Sol_Id = @Sol_Id
    ORDER BY h.Soh_Id;
END
GO

-- El colegio cambia el estado. Atender o rechazar exige respuesta (la familia la ve).
CREATE OR ALTER PROCEDURE app.PR_Portal_Bandeja_Cambiar
    @Usuario   int,
    @Sol_Id    int,
    @Estado    varchar(12),
    @Respuesta nvarchar(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Actual varchar(12);
    SET @Respuesta = NULLIF(LTRIM(RTRIM(@Respuesta)), N'');

    IF @Estado NOT IN ('en_proceso', 'atendida', 'rechazada')
        THROW 50086, N'Elija un estado válido.', 1;
    IF @Estado IN ('atendida', 'rechazada') AND @Respuesta IS NULL
        THROW 50086, N'Escriba la respuesta para la familia.', 1;

    BEGIN TRAN;
        SELECT @Actual = Sol_Estado FROM app.tbSolicitudesPortal WITH (UPDLOCK, HOLDLOCK) WHERE Sol_Id = @Sol_Id;
        IF @Actual IS NULL
            THROW 50086, N'No se encontró la solicitud.', 1;
        IF @Actual = 'retirada'
            THROW 50087, N'La familia retiró esta solicitud; ya no se puede cambiar.', 1;
        IF @Actual NOT IN ('nueva', 'en_proceso')
            THROW 50087, N'Esta solicitud ya está cerrada; no se puede cambiar.', 1;
        IF @Actual = @Estado
            THROW 50087, N'La solicitud ya está en ese estado.', 1;

        UPDATE app.tbSolicitudesPortal
        SET Sol_Estado = @Estado,
            Sol_Respuesta = CASE WHEN @Estado IN ('atendida', 'rechazada') THEN @Respuesta ELSE Sol_Respuesta END,
            Usu_IdAtiende = @Usuario,
            Sol_FechaAtiende = CASE WHEN @Estado IN ('atendida', 'rechazada') THEN GETDATE() ELSE Sol_FechaAtiende END,
            Sol_FechaModifica = GETDATE()
        WHERE Sol_Id = @Sol_Id;

        INSERT INTO app.tbSolicitudesPortalHistorial (Sol_Id, Soh_EstadoAnterior, Soh_EstadoNuevo, Soh_Comentario, Usu_Id)
        VALUES (@Sol_Id, @Actual, @Estado, @Respuesta, @Usuario);
    COMMIT;

    SELECT @Sol_Id AS Sol_Id, @Estado AS Sol_Estado;
END
GO

/* ─────────────────────────── Invitaciones al portal ─────────────────────────── */

-- Encargados con su acceso al portal. Estado de acceso:
--   activo | suspendido (tiene cuenta) · pendiente | vencida | revocada (última invitación) · sin_invitar.
CREATE OR ALTER PROCEDURE app.PR_Portal_Invitaciones_List
    @Texto  nvarchar(100) = NULL,
    @Estado varchar(12)   = NULL,
    @SoloConHijos bit     = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET @Texto = NULLIF(LTRIM(RTRIM(@Texto)), N'');

    WITH base AS (
        SELECT e.Enc_Id,
               app.FN_Portal_NombrePersona(e.Per_Id) AS Enc_Nombre,
               p.Per_Identidad AS Enc_Identidad, p.Per_Telefono AS Enc_Telefono, p.Per_CorreoElectronico AS Enc_Correo,
               h.Hijos, h.HijosNombres,
               u.Usu_Id, u.Usu_Name,
               CAST(CASE WHEN u.Usu_Id IS NOT NULL AND ISNULL(u.Usu_Suspendido, 0) = 0 AND u.Usu_EsActivo = 1 THEN 1 ELSE 0 END AS bit) AS CuentaActiva,
               inv.Inv_Id, inv.Inv_FechaRegistra, inv.Inv_Vence, ui.Usu_Name AS InvitadoPor,
               app.FN_Portal_EstadoInvitacion(inv.Inv_Estado, inv.Inv_Vence) AS InvEstado
        FROM app.tbEncargados e
        INNER JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id
        OUTER APPLY (SELECT COUNT(*) AS Hijos,
                            STRING_AGG(CAST(pa.Per_PrimerNombre + N' ' + pa.Per_ApellidoPaterno AS nvarchar(max)), N', ') AS HijosNombres
                     FROM app.tbEncargados_tbAlumnos ea
                     INNER JOIN app.tbAlumnos a ON a.Alu_Id = ea.Alu_Id
                     INNER JOIN app.tbPersonas pa ON pa.Per_Id = a.Per_Id
                     WHERE ea.Enc_Id = e.Enc_Id) h
        LEFT JOIN seguridad.tbUsuariosEncargados ue ON ue.Enc_Id = e.Enc_Id
        LEFT JOIN seguridad.tbUsuarios u ON u.Usu_Id = ue.Usu_Id AND ISNULL(u.Usu_EsEliminado, 0) = 0
        OUTER APPLY (SELECT TOP (1) i.* FROM app.tbInvitacionesPortal i WHERE i.Enc_Id = e.Enc_Id ORDER BY i.Inv_Id DESC) inv
        LEFT JOIN seguridad.tbUsuarios ui ON ui.Usu_Id = inv.Usu_IdInvita
        WHERE ISNULL(p.Per_EsEliminado, 0) = 0
    ), conEstado AS (
        SELECT b.*,
               CAST(CASE WHEN b.Usu_Id IS NOT NULL AND b.CuentaActiva = 1 THEN 'activo'
                         WHEN b.Usu_Id IS NOT NULL THEN 'suspendido'
                         WHEN b.InvEstado IN ('pendiente', 'vencida', 'revocada') THEN b.InvEstado
                         ELSE 'sin_invitar' END AS varchar(12)) AS EstadoAcceso
        FROM base b
    )
    SELECT TOP (300) *
    FROM conEstado
    WHERE (@SoloConHijos = 0 OR Hijos > 0)
      AND (@Estado IS NULL OR EstadoAcceso = @Estado)
      AND (@Texto IS NULL OR Enc_Nombre LIKE N'%' + @Texto + N'%' OR Enc_Identidad LIKE N'%' + @Texto + N'%'
           OR HijosNombres LIKE N'%' + @Texto + N'%' OR Usu_Name LIKE N'%' + @Texto + N'%')
    ORDER BY CASE EstadoAcceso WHEN 'pendiente' THEN 0 WHEN 'vencida' THEN 1 WHEN 'sin_invitar' THEN 2 ELSE 3 END, Enc_Nombre;
END
GO

-- Indicadores de la pantalla de invitaciones (solo encargados con hijos ligados).
CREATE OR ALTER PROCEDURE app.PR_Portal_Invitaciones_Resumen
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS ConHijos,
           SUM(CASE WHEN u.Usu_Id IS NOT NULL AND u.Usu_EsActivo = 1 AND ISNULL(u.Usu_Suspendido, 0) = 0 THEN 1 ELSE 0 END) AS Activos,
           SUM(CASE WHEN u.Usu_Id IS NULL AND app.FN_Portal_EstadoInvitacion(inv.Inv_Estado, inv.Inv_Vence) = 'pendiente' THEN 1 ELSE 0 END) AS Pendientes,
           SUM(CASE WHEN u.Usu_Id IS NULL AND ISNULL(app.FN_Portal_EstadoInvitacion(inv.Inv_Estado, inv.Inv_Vence), '') <> 'pendiente' THEN 1 ELSE 0 END) AS SinAcceso
    FROM app.tbEncargados e
    INNER JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id AND ISNULL(p.Per_EsEliminado, 0) = 0
    LEFT JOIN seguridad.tbUsuariosEncargados ue ON ue.Enc_Id = e.Enc_Id
    LEFT JOIN seguridad.tbUsuarios u ON u.Usu_Id = ue.Usu_Id AND ISNULL(u.Usu_EsEliminado, 0) = 0
    OUTER APPLY (SELECT TOP (1) i.Inv_Estado, i.Inv_Vence FROM app.tbInvitacionesPortal i WHERE i.Enc_Id = e.Enc_Id ORDER BY i.Inv_Id DESC) inv
    WHERE EXISTS (SELECT 1 FROM app.tbEncargados_tbAlumnos ea WHERE ea.Enc_Id = e.Enc_Id);
END
GO

-- Nueva invitación: revoca la pendiente anterior. La API genera el código y manda solo su huella.
-- Responde { Inv_Id, Inv_Vence, Enc_Nombre }.
CREATE OR ALTER PROCEDURE app.PR_Portal_Invitaciones_Crear
    @Usuario   int,
    @Enc_Id    int,
    @TokenHash char(64),
    @Horas     int = 72
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM app.tbEncargados e INNER JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id
                   WHERE e.Enc_Id = @Enc_Id AND ISNULL(p.Per_EsEliminado, 0) = 0)
        THROW 50088, N'No se encontró el encargado.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbEncargados_tbAlumnos WHERE Enc_Id = @Enc_Id)
        THROW 50088, N'Este encargado no tiene alumnos ligados; primero lígelo a su hijo.', 1;
    IF @Horas IS NULL OR @Horas < 1 OR @Horas > 720 SET @Horas = 72;

    BEGIN TRAN;
        UPDATE app.tbInvitacionesPortal WITH (UPDLOCK, HOLDLOCK)
        SET Inv_Estado = 'revocada', Inv_FechaRevocada = GETDATE(), Usu_IdRevoca = @Usuario
        WHERE Enc_Id = @Enc_Id AND Inv_Estado = 'pendiente';

        INSERT INTO app.tbInvitacionesPortal (Enc_Id, Inv_TokenHash, Inv_Vence, Usu_IdInvita)
        VALUES (@Enc_Id, LOWER(@TokenHash), DATEADD(HOUR, @Horas, GETDATE()), @Usuario);
        DECLARE @Inv_Id int = SCOPE_IDENTITY();
    COMMIT;

    SELECT i.Inv_Id, i.Inv_Vence, app.FN_Portal_NombrePersona(e.Per_Id) AS Enc_Nombre
    FROM app.tbInvitacionesPortal i INNER JOIN app.tbEncargados e ON e.Enc_Id = i.Enc_Id
    WHERE i.Inv_Id = @Inv_Id;
END
GO

-- Detener la invitación pendiente de un encargado. Responde { Inv_Id }.
CREATE OR ALTER PROCEDURE app.PR_Portal_Invitaciones_Revocar
    @Usuario int,
    @Enc_Id  int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Inv_Id int;
    UPDATE app.tbInvitacionesPortal
    SET Inv_Estado = 'revocada', Inv_FechaRevocada = GETDATE(), Usu_IdRevoca = @Usuario, @Inv_Id = Inv_Id
    WHERE Enc_Id = @Enc_Id AND Inv_Estado = 'pendiente';
    IF @Inv_Id IS NULL
        THROW 50088, N'Este encargado no tiene una invitación pendiente.', 1;
    SELECT @Inv_Id AS Inv_Id;
END
GO

-- Suspender o reactivar la cuenta de portal de un encargado. Responde { Usu_Id }.
CREATE OR ALTER PROCEDURE app.PR_Portal_Acceso_Cambiar
    @Usuario   int,
    @Enc_Id    int,
    @Suspender bit
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Usu_Id int;
    SELECT @Usu_Id = ue.Usu_Id FROM seguridad.tbUsuariosEncargados ue WHERE ue.Enc_Id = @Enc_Id;
    IF @Usu_Id IS NULL
        THROW 50088, N'Este encargado todavía no tiene cuenta en el portal.', 1;
    UPDATE seguridad.tbUsuarios
    SET Usu_Suspendido = @Suspender, Usu_fechaModificacion = GETDATE()
    WHERE Usu_Id = @Usu_Id;
    SELECT @Usu_Id AS Usu_Id;
END
GO

-- Página pública de la invitación: qué dice el enlace (sin datos sensibles).
-- Estado: pendiente | vencida | revocada | aceptada | no_existe.
CREATE OR ALTER PROCEDURE app.PR_Portal_Invitaciones_Info
    @TokenHash char(64)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM app.tbInvitacionesPortal WHERE Inv_TokenHash = LOWER(@TokenHash))
    BEGIN
        SELECT CAST('no_existe' AS varchar(10)) AS Estado, CAST(NULL AS nvarchar(250)) AS Enc_Nombre,
               CAST(NULL AS nvarchar(max)) AS Hijos, CAST(NULL AS nvarchar(50)) AS UsuarioExistente,
               CAST(NULL AS datetime) AS Inv_Vence;
        RETURN;
    END

    SELECT app.FN_Portal_EstadoInvitacion(i.Inv_Estado, i.Inv_Vence) AS Estado,
           p.Per_PrimerNombre AS Enc_Nombre,
           (SELECT STRING_AGG(CAST(pa.Per_PrimerNombre AS nvarchar(max)), N', ')
            FROM app.tbEncargados_tbAlumnos ea
            INNER JOIN app.tbAlumnos a ON a.Alu_Id = ea.Alu_Id
            INNER JOIN app.tbPersonas pa ON pa.Per_Id = a.Per_Id
            WHERE ea.Enc_Id = i.Enc_Id) AS Hijos,
           u.Usu_Name AS UsuarioExistente,
           i.Inv_Vence
    FROM app.tbInvitacionesPortal i
    INNER JOIN app.tbEncargados e ON e.Enc_Id = i.Enc_Id
    INNER JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id
    LEFT JOIN seguridad.tbUsuariosEncargados ue ON ue.Enc_Id = i.Enc_Id
    LEFT JOIN seguridad.tbUsuarios u ON u.Usu_Id = ue.Usu_Id
    WHERE i.Inv_TokenHash = LOWER(@TokenHash);
END
GO

-- Aceptar la invitación: crea la cuenta Encargado (o le pone contraseña nueva si ya existe) y
-- marca el enlace como usado. @Contrasena llega ya convertida en huella (mismo hash que el login).
-- Responde { Usu_Id, Usu_Name }.
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
    IF @Usu_Name IS NULL OR LEN(@Usu_Name) < 4 OR @Usu_Name LIKE N'%[^a-zA-Z0-9._-]%'
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
            SET Usu_Name = @Usu_Name, [Usu_Contraseña] = @Contrasena, Rol_Id = @Rol_Id,
                Usu_EsActivo = 1, Usu_EsEliminado = 0, Usu_fechaModificacion = GETDATE()
            WHERE Usu_Id = @Usu_Id;

        UPDATE app.tbInvitacionesPortal
        SET Inv_Estado = 'aceptada', Inv_FechaAceptada = GETDATE(), Usu_IdCuenta = @Usu_Id
        WHERE Inv_Id = @Inv_Id;
    COMMIT;

    SELECT @Usu_Id AS Usu_Id, @Usu_Name AS Usu_Name;
END
GO

/* ─────────────────────────────── Permisos ─────────────────────────────── */
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200), Grupo nvarchar(50));
INSERT INTO @Pantallas (Nombre, Roles, Grupo) VALUES
    (N'Portal de padres',        N'|encargado|',            N'Portal'),
    (N'Invitaciones al portal',  N'|admin|secretaria|',     N'Alumnos'),
    (N'Solicitudes del portal',  N'|admin|secretaria|director|', N'Alumnos');

INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
SELECT x.Nombre, 1, 0, x.Grupo
FROM @Pantallas x
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas p WHERE p.Pan_Descripcion = x.Nombre);

INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN @Pantallas x ON x.Nombre = p.Pan_Descripcion
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0
                        AND x.Roles LIKE N'%|' + LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) + N'|%'
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas y WHERE y.Rol_Id = r.Rol_Id AND y.Pan_Id = p.Pan_Id);
GO
