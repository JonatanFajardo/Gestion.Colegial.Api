/* =============================================================================
   062 · Disciplina: casos  (espejo de Skuul: incidents, incident_participants,
         incident_actions, incident_status_changes, incident_notes)

   - Un caso guarda qué pasó, quiénes participaron, qué hizo el colegio y cómo avanzó.
   - Tipos: conducta y protección del menor. Un caso de protección es RESERVADO: solo lo
     leen quienes tienen "Ver casos reservados", quien lo reportó y quien lo atiende.
   - Estados: reportado → en_revision → derivado → con_medidas → resuelto → cerrado
     (transiciones permitidas en FN_CasoDisciplina_Siguientes). Resuelto y cerrado ya no
     aceptan acciones ni notas; cerrado es de solo lectura; resuelto se puede reabrir.
   - Nada se edita después: los cambios de estado y las notas solo se agregan.
   - Quien reporta = usuario (seguridad.tbUsuarios); quien atiende y responsables = empleados.

   Crear SIEMPRE con QUOTED_IDENTIFIER ON (índices filtrados y OPENJSON).
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ---------------------------------------------------------------- Tablas */
IF OBJECT_ID('app.tbCasosDisciplina') IS NULL
BEGIN
    CREATE TABLE app.tbCasosDisciplina
    (
        Cas_Id             int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbCasosDisciplina PRIMARY KEY,
        Cas_Referencia     varchar(30)    NOT NULL,
        Cas_Tipo           varchar(20)    NOT NULL CONSTRAINT DF_tbCasosDisciplina_Tipo DEFAULT ('conducta'),
        Cas_Estado         varchar(20)    NOT NULL CONSTRAINT DF_tbCasosDisciplina_Estado DEFAULT ('reportado'),
        Cas_EsReservado    bit            NOT NULL CONSTRAINT DF_tbCasosDisciplina_EsReservado DEFAULT (0),
        Cas_Resumen        nvarchar(255)  NOT NULL,
        Cas_Descripcion    nvarchar(max)  NULL,
        Cas_Lugar          nvarchar(150)  NULL,
        Cas_FechaOcurrio   datetime2(0)   NOT NULL,
        Ani_Id             int            NULL CONSTRAINT FK_tbCasosDisciplina_tbAnioLectivo REFERENCES app.tbAnioLectivo (Ani_Id),
        Pan_Id             int            NULL CONSTRAINT FK_tbCasosDisciplina_tbPeriodosAnio REFERENCES app.tbPeriodosAnio (Pan_Id),
        Cas_UsuarioReporta int            NULL,
        Emp_IdAtiende      int            NULL CONSTRAINT FK_tbCasosDisciplina_Atiende REFERENCES app.tbEmpleados (Emp_Id),
        Cas_FechaRegistra  datetime2(0)   NOT NULL CONSTRAINT DF_tbCasosDisciplina_FechaRegistra DEFAULT (SYSDATETIME()),
        Cas_FechaModifica  datetime2(0)   NULL,
        CONSTRAINT UQ_tbCasosDisciplina_Referencia UNIQUE (Cas_Referencia),
        CONSTRAINT CK_tbCasosDisciplina_Tipo CHECK (Cas_Tipo IN ('conducta','proteccion')),
        CONSTRAINT CK_tbCasosDisciplina_Estado CHECK (Cas_Estado IN ('reportado','en_revision','derivado','con_medidas','resuelto','cerrado'))
    );

    CREATE INDEX IX_tbCasosDisciplina_Estado ON app.tbCasosDisciplina (Cas_Estado) INCLUDE (Cas_Tipo, Cas_EsReservado);
    CREATE INDEX IX_tbCasosDisciplina_Fecha  ON app.tbCasosDisciplina (Cas_FechaOcurrio DESC);
END
GO

IF OBJECT_ID('app.tbCasosDisciplinaPersonas') IS NULL
BEGIN
    CREATE TABLE app.tbCasosDisciplinaPersonas
    (
        Cpe_Id    int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbCasosDisciplinaPersonas PRIMARY KEY,
        Cas_Id    int           NOT NULL CONSTRAINT FK_tbCasosDisciplinaPersonas_Caso REFERENCES app.tbCasosDisciplina (Cas_Id) ON DELETE CASCADE,
        Alu_Id    int           NULL     CONSTRAINT FK_tbCasosDisciplinaPersonas_Alumno REFERENCES app.tbAlumnos (Alu_Id),
        Emp_Id    int           NULL     CONSTRAINT FK_tbCasosDisciplinaPersonas_Empleado REFERENCES app.tbEmpleados (Emp_Id),
        Cpe_Papel varchar(20)   NOT NULL CONSTRAINT DF_tbCasosDisciplinaPersonas_Papel DEFAULT ('implicado'),
        Cpe_Nota  nvarchar(255) NULL,
        CONSTRAINT CK_tbCasosDisciplinaPersonas_Papel CHECK (Cpe_Papel IN ('implicado','afectado','testigo','reporta','atiende'))
    );
    CREATE INDEX IX_tbCasosDisciplinaPersonas_Caso   ON app.tbCasosDisciplinaPersonas (Cas_Id);
    CREATE INDEX IX_tbCasosDisciplinaPersonas_Alumno ON app.tbCasosDisciplinaPersonas (Alu_Id) WHERE Alu_Id IS NOT NULL;
END
GO

IF OBJECT_ID('app.tbCasosDisciplinaAcciones') IS NULL
BEGIN
    CREATE TABLE app.tbCasosDisciplinaAcciones
    (
        Cac_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbCasosDisciplinaAcciones PRIMARY KEY,
        Cas_Id              int            NOT NULL CONSTRAINT FK_tbCasosDisciplinaAcciones_Caso REFERENCES app.tbCasosDisciplina (Cas_Id) ON DELETE CASCADE,
        Cac_Tipo            nvarchar(100)  NOT NULL,
        Cac_Descripcion     nvarchar(1000) NOT NULL,
        Cac_FechaLimite     date           NULL,
        Cac_FechaHecha      datetime2(0)   NULL,
        Emp_IdResponsable   int            NULL CONSTRAINT FK_tbCasosDisciplinaAcciones_Responsable REFERENCES app.tbEmpleados (Emp_Id),
        Cac_UsuarioRegistra int            NULL,
        Cac_FechaRegistra   datetime2(0)   NOT NULL CONSTRAINT DF_tbCasosDisciplinaAcciones_FechaRegistra DEFAULT (SYSDATETIME())
    );
    CREATE INDEX IX_tbCasosDisciplinaAcciones_Caso ON app.tbCasosDisciplinaAcciones (Cas_Id);
END
GO

IF OBJECT_ID('app.tbCasosDisciplinaEstados') IS NULL
BEGIN
    CREATE TABLE app.tbCasosDisciplinaEstados
    (
        Ces_Id      int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbCasosDisciplinaEstados PRIMARY KEY,
        Cas_Id      int           NOT NULL CONSTRAINT FK_tbCasosDisciplinaEstados_Caso REFERENCES app.tbCasosDisciplina (Cas_Id) ON DELETE CASCADE,
        Ces_De      varchar(20)   NOT NULL,
        Ces_A       varchar(20)   NOT NULL,
        Ces_Motivo  nvarchar(500) NULL,
        Ces_Usuario int           NULL,
        Ces_Fecha   datetime2(0)  NOT NULL CONSTRAINT DF_tbCasosDisciplinaEstados_Fecha DEFAULT (SYSDATETIME())
    );
    CREATE INDEX IX_tbCasosDisciplinaEstados_Caso ON app.tbCasosDisciplinaEstados (Cas_Id, Ces_Id);
END
GO

IF OBJECT_ID('app.tbCasosDisciplinaNotas') IS NULL
BEGIN
    CREATE TABLE app.tbCasosDisciplinaNotas
    (
        Cno_Id        int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbCasosDisciplinaNotas PRIMARY KEY,
        Cas_Id        int           NOT NULL CONSTRAINT FK_tbCasosDisciplinaNotas_Caso REFERENCES app.tbCasosDisciplina (Cas_Id) ON DELETE CASCADE,
        Cno_Texto     nvarchar(max) NOT NULL,
        Cno_EsPrivada bit           NOT NULL CONSTRAINT DF_tbCasosDisciplinaNotas_EsPrivada DEFAULT (1),
        Cno_Usuario   int           NULL,
        Cno_Fecha     datetime2(0)  NOT NULL CONSTRAINT DF_tbCasosDisciplinaNotas_Fecha DEFAULT (SYSDATETIME())
    );
    CREATE INDEX IX_tbCasosDisciplinaNotas_Caso ON app.tbCasosDisciplinaNotas (Cas_Id, Cno_Id);
END
GO

/* ---------------------------------------------------------------- Funciones */

-- Hora de Honduras (UTC-6, sin horario de verano): el contenedor de SQL corre en UTC.
CREATE OR ALTER FUNCTION app.FN_AhoraHonduras ()
RETURNS datetime2(0)
AS
BEGIN
    RETURN CAST(SWITCHOFFSET(SYSDATETIMEOFFSET(), '-06:00') AS datetime2(0));
END
GO

-- Nombre visible de un usuario: el del empleado ligado o, si no tiene, su nombre de usuario.
CREATE OR ALTER FUNCTION app.FN_NombreUsuario (@Usu_Id int)
RETURNS nvarchar(200)
AS
BEGIN
    RETURN (
        SELECT TOP (1) COALESCE(
                   NULLIF(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N'')), N''),
                   u.Usu_Name)
        FROM seguridad.tbUsuarios u
        LEFT JOIN app.tbEmpleados e ON e.Emp_Id = u.Emp_Id
        LEFT JOIN app.tbPersonas  p ON p.Per_Id = e.Per_Id
        WHERE u.Usu_Id = @Usu_Id);
END
GO

CREATE OR ALTER FUNCTION app.FN_NombreEmpleado (@Emp_Id int)
RETURNS nvarchar(200)
AS
BEGIN
    RETURN (
        SELECT TOP (1) CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''))
        FROM app.tbEmpleados e
        JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id
        WHERE e.Emp_Id = @Emp_Id);
END
GO

-- Estados a los que puede pasar un caso (mismo orden que Skuul: el primero es la sugerencia).
CREATE OR ALTER FUNCTION app.FN_CasoDisciplina_Siguientes (@Estado varchar(20))
RETURNS TABLE
AS
RETURN
    SELECT v.Estado, v.Orden
    FROM (VALUES
        ('reportado',   'en_revision', 1), ('reportado',   'derivado',    2), ('reportado',   'con_medidas', 3),
        ('reportado',   'resuelto',    4), ('reportado',   'cerrado',     5),
        ('en_revision', 'derivado',    1), ('en_revision', 'con_medidas', 2), ('en_revision', 'resuelto',    3),
        ('en_revision', 'cerrado',     4),
        ('derivado',    'en_revision', 1), ('derivado',    'con_medidas', 2), ('derivado',    'resuelto',    3),
        ('derivado',    'cerrado',     4),
        ('con_medidas', 'en_revision', 1), ('con_medidas', 'resuelto',    2), ('con_medidas', 'cerrado',     3),
        ('resuelto',    'cerrado',     1), ('resuelto',    'en_revision', 2)
    ) v (Desde, Estado, Orden)
    WHERE v.Desde = @Estado;
GO

-- ¿Puede esta persona leer el caso? (reservado: permiso de reservados, quien reportó o quien atiende)
CREATE OR ALTER FUNCTION app.FN_CasoDisciplina_Legible (@Cas_Id int, @VerReservados bit, @Usu_Id int, @Emp_Id int)
RETURNS TABLE
AS
RETURN
    SELECT c.Cas_Id
    FROM app.tbCasosDisciplina c
    WHERE c.Cas_Id = @Cas_Id
      AND (   c.Cas_EsReservado = 0
           OR @VerReservados = 1
           OR (@Emp_Id IS NOT NULL AND c.Emp_IdAtiende = @Emp_Id)
           OR (@Usu_Id IS NOT NULL AND c.Cas_UsuarioReporta = @Usu_Id));
GO

/* ---------------------------------------------------------------- Lecturas */

-- Listado (más reciente primero), 20 por página. TotalFilas = total con los filtros.
CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplina_List
    @Estado        varchar(20) = NULL,
    @Tipo          varchar(20) = NULL,
    @SoloAbiertos  bit         = 0,
    @VerReservados bit         = 0,
    @Usu_Id        int         = NULL,
    @Emp_Id        int         = NULL,
    @Pagina        int         = 1,
    @Tamano        int         = 20
AS
BEGIN
    SET NOCOUNT ON;
    SET @Estado = NULLIF(LTRIM(RTRIM(@Estado)), '');
    SET @Tipo   = NULLIF(LTRIM(RTRIM(@Tipo)), '');
    IF @Pagina IS NULL OR @Pagina < 1 SET @Pagina = 1;
    IF @Tamano IS NULL OR @Tamano NOT BETWEEN 1 AND 100 SET @Tamano = 20;

    SELECT c.Cas_Id, c.Cas_Referencia, c.Cas_Tipo, c.Cas_Estado, c.Cas_EsReservado, c.Cas_Resumen,
           c.Cas_Lugar, c.Cas_FechaOcurrio, c.Emp_IdAtiende,
           app.FN_NombreEmpleado(c.Emp_IdAtiende) AS Atiende,
           (SELECT COUNT(*) FROM app.tbCasosDisciplinaPersonas p WHERE p.Cas_Id = c.Cas_Id) AS Personas,
           COUNT(*) OVER () AS TotalFilas
    FROM app.tbCasosDisciplina c
    WHERE (   c.Cas_EsReservado = 0
           OR @VerReservados = 1
           OR (@Emp_Id IS NOT NULL AND c.Emp_IdAtiende = @Emp_Id)
           OR (@Usu_Id IS NOT NULL AND c.Cas_UsuarioReporta = @Usu_Id))
      AND (@Estado IS NULL OR c.Cas_Estado = @Estado)
      AND (@Tipo   IS NULL OR c.Cas_Tipo   = @Tipo)
      AND (@SoloAbiertos = 0 OR c.Cas_Estado IN ('reportado','en_revision','derivado','con_medidas'))
    ORDER BY c.Cas_FechaOcurrio DESC, c.Cas_Id DESC
    OFFSET (@Pagina - 1) * @Tamano ROWS FETCH NEXT @Tamano ROWS ONLY;
END
GO

-- Cuántos casos legibles siguen necesitando trabajo.
CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplina_Abiertos
    @VerReservados bit = 0,
    @Usu_Id        int = NULL,
    @Emp_Id        int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS Abiertos
    FROM app.tbCasosDisciplina c
    WHERE c.Cas_Estado IN ('reportado','en_revision','derivado','con_medidas')
      AND (   c.Cas_EsReservado = 0
           OR @VerReservados = 1
           OR (@Emp_Id IS NOT NULL AND c.Emp_IdAtiende = @Emp_Id)
           OR (@Usu_Id IS NOT NULL AND c.Cas_UsuarioReporta = @Usu_Id));
END
GO

-- Un caso. Sin fila si no existe o la persona no lo puede leer.
CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplina_Find
    @Cas_Id        int,
    @VerReservados bit = 0,
    @Usu_Id        int = NULL,
    @Emp_Id        int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.Cas_Id, c.Cas_Referencia, c.Cas_Tipo, c.Cas_Estado, c.Cas_EsReservado, c.Cas_Resumen,
           c.Cas_Descripcion, c.Cas_Lugar, c.Cas_FechaOcurrio, c.Cas_FechaRegistra,
           c.Ani_Id, a.Ani_Nombre, c.Pan_Id, pa.Pan_Nombre,
           c.Cas_UsuarioReporta, app.FN_NombreUsuario(c.Cas_UsuarioReporta) AS Reporta,
           c.Emp_IdAtiende, app.FN_NombreEmpleado(c.Emp_IdAtiende) AS Atiende,
           (SELECT COUNT(*) FROM app.tbCasosDisciplinaAcciones x WHERE x.Cas_Id = c.Cas_Id AND x.Cac_FechaHecha IS NULL) AS Pendientes,
           CAST(CASE WHEN (@Emp_Id IS NOT NULL AND c.Emp_IdAtiende = @Emp_Id)
                       OR (@Usu_Id IS NOT NULL AND c.Cas_UsuarioReporta = @Usu_Id) THEN 1 ELSE 0 END AS bit) AS EsDeLaPersona
    FROM app.tbCasosDisciplina c
    JOIN app.FN_CasoDisciplina_Legible(@Cas_Id, @VerReservados, @Usu_Id, @Emp_Id) l ON l.Cas_Id = c.Cas_Id
    LEFT JOIN app.tbAnioLectivo  a  ON a.Ani_Id  = c.Ani_Id
    LEFT JOIN app.tbPeriodosAnio pa ON pa.Pan_Id = c.Pan_Id;
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplinaPersonas_List
    @Cas_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Cpe_Id, p.Alu_Id, p.Emp_Id, p.Cpe_Papel, p.Cpe_Nota,
           COALESCE(
               CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(pa.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(pa.Per_ApellidoPaterno)), N'')),
               app.FN_NombreEmpleado(p.Emp_Id)) AS Nombre,
           pa.Per_Identidad AS Identidad,
           NULLIF(CONCAT_WS(N' ', cn.Cun_Descripcion, s.Sec_Descripcion), N'') AS Ubicacion
    FROM app.tbCasosDisciplinaPersonas p
    LEFT JOIN app.tbAlumnos       al ON al.Alu_Id = p.Alu_Id
    LEFT JOIN app.tbPersonas      pa ON pa.Per_Id = al.Per_Id
    LEFT JOIN app.tbCursosNiveles cn ON cn.Cun_Id = al.Cun_Id
    LEFT JOIN app.tbSecciones     s  ON s.Sec_Id  = al.Sec_Id
    WHERE p.Cas_Id = @Cas_Id
    ORDER BY p.Cpe_Id;
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplinaAcciones_List
    @Cas_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT a.Cac_Id, a.Cac_Tipo, a.Cac_Descripcion, a.Cac_FechaLimite, a.Cac_FechaHecha,
           a.Emp_IdResponsable, app.FN_NombreEmpleado(a.Emp_IdResponsable) AS Responsable
    FROM app.tbCasosDisciplinaAcciones a
    WHERE a.Cas_Id = @Cas_Id
    ORDER BY a.Cac_Id;
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplinaEstados_List
    @Cas_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.Ces_Id, e.Ces_De, e.Ces_A, e.Ces_Motivo, e.Ces_Fecha, app.FN_NombreUsuario(e.Ces_Usuario) AS Usuario
    FROM app.tbCasosDisciplinaEstados e
    WHERE e.Cas_Id = @Cas_Id
    ORDER BY e.Ces_Id;
END
GO

-- Notas de un caso. Una nota privada solo la leen quienes atienden el caso
-- (permiso de reservados, quien reportó o quien atiende).
CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplinaNotas_List
    @Cas_Id        int,
    @VerReservados bit = 0,
    @Usu_Id        int = NULL,
    @Emp_Id        int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT n.Cno_Id, n.Cno_Texto, n.Cno_EsPrivada, n.Cno_Fecha, app.FN_NombreUsuario(n.Cno_Usuario) AS Usuario
    FROM app.tbCasosDisciplinaNotas n
    JOIN app.tbCasosDisciplina c ON c.Cas_Id = n.Cas_Id
    WHERE n.Cas_Id = @Cas_Id
      AND (   n.Cno_EsPrivada = 0
           OR @VerReservados = 1
           OR (@Emp_Id IS NOT NULL AND c.Emp_IdAtiende = @Emp_Id)
           OR (@Usu_Id IS NOT NULL AND c.Cas_UsuarioReporta = @Usu_Id))
    ORDER BY n.Cno_Id;
END
GO

-- Alumnos que se pueden nombrar en un caso (activos), con su identidad y ubicación.
CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplina_Alumnos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT al.Alu_Id,
           CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), N''),
                     NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N'')) AS Nombre,
           p.Per_Identidad AS Identidad,
           NULLIF(CONCAT_WS(N' ', cn.Cun_Descripcion, s.Sec_Descripcion), N'') AS Ubicacion
    FROM app.tbAlumnos al
    JOIN app.tbPersonas p            ON p.Per_Id  = al.Per_Id
    LEFT JOIN app.tbCursosNiveles cn ON cn.Cun_Id = al.Cun_Id
    LEFT JOIN app.tbSecciones     s  ON s.Sec_Id  = al.Sec_Id
    WHERE p.Per_EsEliminado = 0
      AND ISNULL(al.Est_Id, 1) IN (1, 2)
    ORDER BY p.Per_PrimerNombre, p.Per_ApellidoPaterno;
END
GO

-- Empleados que pueden atender un caso o ser responsables de una acción.
CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplina_Empleados
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.Emp_Id,
           CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N'')) AS Nombre,
           c.Car_Descripcion AS Cargo
    FROM app.tbEmpleados e
    JOIN app.tbPersonas p    ON p.Per_Id = e.Per_Id
    LEFT JOIN app.tbCargos c ON c.Car_Id = e.Car_Id
    WHERE p.Per_EsEliminado = 0
    ORDER BY p.Per_PrimerNombre, p.Per_ApellidoPaterno;
END
GO

/* ---------------------------------------------------------------- Escrituras */

-- Registrar un caso con sus personas. @Personas = JSON [{"Alu_Id":1,"Papel":"implicado","Nota":"..."}].
-- Devuelve Cas_Id y la referencia (CASO-AA-XXXXXX).
CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplina_Registrar
    @Cas_Resumen      nvarchar(255),
    @Cas_Tipo         varchar(20),
    @Cas_Descripcion  nvarchar(max) = NULL,
    @Cas_Lugar        nvarchar(150) = NULL,
    @Cas_FechaOcurrio datetime2(0),
    @Emp_IdAtiende    int           = NULL,
    @Personas         nvarchar(max) = NULL,
    @Usuario          int           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Cas_Resumen     = LTRIM(RTRIM(ISNULL(@Cas_Resumen, N'')));
    SET @Cas_Descripcion = NULLIF(LTRIM(RTRIM(@Cas_Descripcion)), N'');
    SET @Cas_Lugar       = NULLIF(LTRIM(RTRIM(@Cas_Lugar)), N'');
    SET @Personas        = NULLIF(LTRIM(RTRIM(@Personas)), N'');

    IF @Cas_Resumen = N''
        THROW 50030, N'Escriba un resumen del caso.', 1;
    IF @Cas_Tipo IS NULL OR @Cas_Tipo NOT IN ('conducta','proteccion')
        THROW 50031, N'Elija el tipo de caso.', 1;
    IF @Cas_FechaOcurrio IS NULL OR YEAR(@Cas_FechaOcurrio) NOT BETWEEN 2000 AND 2100
        THROW 50032, N'Indique cuándo ocurrió.', 1;
    IF @Cas_FechaOcurrio > DATEADD(MINUTE, 1, app.FN_AhoraHonduras())
        THROW 50033, N'No se puede registrar un caso con una fecha que todavía no ha pasado.', 1;
    IF @Emp_IdAtiende IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM app.tbEmpleados e JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id
            WHERE e.Emp_Id = @Emp_IdAtiende AND p.Per_EsEliminado = 0)
        THROW 50034, N'Elija a alguien que trabaje en el colegio.', 1;
    IF @Personas IS NOT NULL AND ISJSON(@Personas) = 0
        THROW 50035, N'Revise la lista de personas.', 1;

    DECLARE @Lista TABLE (Fila int IDENTITY(1,1), Alu_Id int NULL, Papel varchar(20) NULL, Nota nvarchar(400) NULL);
    IF @Personas IS NOT NULL
        INSERT INTO @Lista (Alu_Id, Papel, Nota)
        SELECT j.Alu_Id, LTRIM(RTRIM(j.Papel)), NULLIF(LTRIM(RTRIM(j.Nota)), N'')
        FROM OPENJSON(@Personas) WITH (Alu_Id int '$.Alu_Id', Papel varchar(20) '$.Papel', Nota nvarchar(400) '$.Nota') j
        WHERE j.Alu_Id IS NOT NULL;   -- una fila sin alumno simplemente no se usó

    IF (SELECT COUNT(*) FROM @Lista) > 20
        THROW 50036, N'Un caso admite hasta 20 personas.', 1;
    IF EXISTS (SELECT 1 FROM @Lista WHERE Papel IS NULL OR Papel NOT IN ('implicado','afectado','testigo','reporta','atiende'))
        THROW 50037, N'Elija por qué aparece cada persona.', 1;
    IF EXISTS (SELECT 1 FROM @Lista WHERE LEN(Nota) > 255)
        THROW 50038, N'La nota de cada persona admite hasta 255 caracteres.', 1;
    IF EXISTS (SELECT 1 FROM @Lista l WHERE NOT EXISTS (SELECT 1 FROM app.tbAlumnos a WHERE a.Alu_Id = l.Alu_Id))
        THROW 50039, N'Uno de los alumnos elegidos ya no existe.', 1;

    DECLARE @Ani_Id int = (SELECT TOP (1) Ani_Id FROM app.FN_AnioLectivoDeFecha(CAST(@Cas_FechaOcurrio AS date)));
    DECLARE @Pan_Id int = (
        SELECT TOP (1) pa.Pan_Id FROM app.tbPeriodosAnio pa
        WHERE pa.Ani_Id = @Ani_Id AND pa.Pan_EsEliminado = 0
          AND CAST(@Cas_FechaOcurrio AS date) BETWEEN pa.Pan_FechaInicio AND pa.Pan_FechaFin
        ORDER BY pa.Pan_Orden);

    DECLARE @Referencia varchar(30), @Intentos int = 0;
    WHILE 1 = 1
    BEGIN
        SET @Referencia = 'CASO-' + RIGHT(CONVERT(char(4), YEAR(app.FN_AhoraHonduras())), 2) + '-'
                        + UPPER(LEFT(REPLACE(CONVERT(varchar(36), NEWID()), '-', ''), 6));
        IF NOT EXISTS (SELECT 1 FROM app.tbCasosDisciplina WHERE Cas_Referencia = @Referencia) BREAK;
        SET @Intentos += 1;
        IF @Intentos > 20 THROW 50040, N'No se pudo generar la referencia del caso. Intente de nuevo.', 1;
    END

    DECLARE @Cas_Id int;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO app.tbCasosDisciplina
            (Cas_Referencia, Cas_Tipo, Cas_Estado, Cas_EsReservado, Cas_Resumen, Cas_Descripcion, Cas_Lugar,
             Cas_FechaOcurrio, Ani_Id, Pan_Id, Cas_UsuarioReporta, Emp_IdAtiende, Cas_FechaRegistra)
        VALUES
            (@Referencia, @Cas_Tipo, 'reportado', CASE WHEN @Cas_Tipo = 'proteccion' THEN 1 ELSE 0 END, @Cas_Resumen,
             @Cas_Descripcion, @Cas_Lugar, @Cas_FechaOcurrio, @Ani_Id, @Pan_Id, @Usuario, @Emp_IdAtiende, app.FN_AhoraHonduras());
        SET @Cas_Id = SCOPE_IDENTITY();

        INSERT INTO app.tbCasosDisciplinaPersonas (Cas_Id, Alu_Id, Cpe_Papel, Cpe_Nota)
        SELECT @Cas_Id, l.Alu_Id, l.Papel, l.Nota FROM @Lista l ORDER BY l.Fila;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Cas_Id AS Cas_Id, @Referencia AS Cas_Referencia;
END
GO

-- Mover el caso de estado. Bloquea la fila: si dos personas lo mueven a la vez, decide el estado leído bajo el bloqueo.
CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplina_CambiarEstado
    @Cas_Id  int,
    @Estado  varchar(20),
    @Motivo  nvarchar(500) = NULL,
    @Usuario int           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Actual varchar(20) = (SELECT Cas_Estado FROM app.tbCasosDisciplina WITH (UPDLOCK, HOLDLOCK) WHERE Cas_Id = @Cas_Id);
        IF @Actual IS NULL
            THROW 50041, N'El caso ya no existe.', 1;

        IF @Actual <> @Estado
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM app.FN_CasoDisciplina_Siguientes(@Actual) WHERE Estado = @Estado)
                THROW 50042, N'El caso no puede pasar a ese estado desde el estado actual.', 1;

            UPDATE app.tbCasosDisciplina
            SET Cas_Estado = @Estado, Cas_FechaModifica = app.FN_AhoraHonduras()
            WHERE Cas_Id = @Cas_Id;

            INSERT INTO app.tbCasosDisciplinaEstados (Cas_Id, Ces_De, Ces_A, Ces_Motivo, Ces_Usuario, Ces_Fecha)
            VALUES (@Cas_Id, @Actual, @Estado, @Motivo, @Usuario, app.FN_AhoraHonduras());
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT Cas_Id, Cas_Estado FROM app.tbCasosDisciplina WHERE Cas_Id = @Cas_Id;
END
GO

-- Algo que el colegio hará por el caso. Solo en un caso abierto.
CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplinaAcciones_Agregar
    @Cas_Id            int,
    @Cac_Tipo          nvarchar(100),
    @Cac_Descripcion   nvarchar(1000),
    @Cac_FechaLimite   date = NULL,
    @Emp_IdResponsable int  = NULL,
    @Usuario           int  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Cac_Tipo        = LTRIM(RTRIM(ISNULL(@Cac_Tipo, N'')));
    SET @Cac_Descripcion = LTRIM(RTRIM(ISNULL(@Cac_Descripcion, N'')));

    IF NOT EXISTS (SELECT 1 FROM app.tbCasosDisciplina WHERE Cas_Id = @Cas_Id)
        THROW 50041, N'El caso ya no existe.', 1;
    IF EXISTS (SELECT 1 FROM app.tbCasosDisciplina WHERE Cas_Id = @Cas_Id AND Cas_Estado IN ('resuelto','cerrado'))
        THROW 50043, N'Este caso ya terminó. Reábralo antes de agregar una acción.', 1;
    IF @Cac_Tipo = N''
        THROW 50044, N'Diga qué tipo de paso es.', 1;
    IF @Cac_Descripcion = N''
        THROW 50045, N'Diga qué tiene que pasar.', 1;
    IF @Emp_IdResponsable IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM app.tbEmpleados e JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id
            WHERE e.Emp_Id = @Emp_IdResponsable AND p.Per_EsEliminado = 0)
        THROW 50034, N'Elija a alguien que trabaje en el colegio.', 1;

    INSERT INTO app.tbCasosDisciplinaAcciones
        (Cas_Id, Cac_Tipo, Cac_Descripcion, Cac_FechaLimite, Emp_IdResponsable, Cac_UsuarioRegistra, Cac_FechaRegistra)
    VALUES (@Cas_Id, @Cac_Tipo, @Cac_Descripcion, @Cac_FechaLimite, @Emp_IdResponsable, @Usuario, app.FN_AhoraHonduras());

    SELECT CAST(SCOPE_IDENTITY() AS int) AS Cac_Id;
END
GO

-- Marcar una acción como hecha. Solo en un caso abierto.
CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplinaAcciones_Completar
    @Cas_Id  int,
    @Cac_Id  int,
    @Usuario int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM app.tbCasosDisciplina WHERE Cas_Id = @Cas_Id AND Cas_Estado IN ('resuelto','cerrado'))
        THROW 50046, N'Este caso ya terminó. Reábralo antes de cambiar sus acciones.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbCasosDisciplinaAcciones WHERE Cac_Id = @Cac_Id AND Cas_Id = @Cas_Id)
        THROW 50047, N'La acción ya no existe.', 1;

    UPDATE app.tbCasosDisciplinaAcciones
    SET Cac_FechaHecha = app.FN_AhoraHonduras()
    WHERE Cac_Id = @Cac_Id AND Cas_Id = @Cas_Id AND Cac_FechaHecha IS NULL;

    SELECT @Cac_Id AS Cac_Id;
END
GO

-- Agregar una nota (no se puede editar después). Solo en un caso abierto.
CREATE OR ALTER PROCEDURE app.PR_tbCasosDisciplinaNotas_Agregar
    @Cas_Id        int,
    @Cno_Texto     nvarchar(max),
    @Cno_EsPrivada bit = 1,
    @Usuario       int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Cno_Texto = LTRIM(RTRIM(ISNULL(@Cno_Texto, N'')));

    IF NOT EXISTS (SELECT 1 FROM app.tbCasosDisciplina WHERE Cas_Id = @Cas_Id)
        THROW 50041, N'El caso ya no existe.', 1;
    IF EXISTS (SELECT 1 FROM app.tbCasosDisciplina WHERE Cas_Id = @Cas_Id AND Cas_Estado IN ('resuelto','cerrado'))
        THROW 50048, N'Este caso ya terminó. Reábralo antes de escribir una nota.', 1;
    IF @Cno_Texto = N''
        THROW 50049, N'Escriba la nota.', 1;
    IF LEN(@Cno_Texto) > 5000
        THROW 50050, N'La nota admite hasta 5000 caracteres.', 1;

    INSERT INTO app.tbCasosDisciplinaNotas (Cas_Id, Cno_Texto, Cno_EsPrivada, Cno_Usuario, Cno_Fecha)
    VALUES (@Cas_Id, @Cno_Texto, ISNULL(@Cno_EsPrivada, 1), @Usuario, app.FN_AhoraHonduras());

    SELECT CAST(SCOPE_IDENTITY() AS int) AS Cno_Id;
END
GO

/* ---------------------------------------------------------------- Pantallas y permisos */
-- Igual que Skuul (solo la administración): admin y dirección.
--   Casos de disciplina          = ver el listado y los casos
--   Registrar caso de disciplina = registrar un caso
--   Atender casos de disciplina  = mover de estado, agregar acciones y notas
--   Ver casos reservados         = leer los casos de protección del menor y las notas privadas
DECLARE @Pantallas TABLE (Nombre nvarchar(100));
INSERT INTO @Pantallas VALUES (N'Casos de disciplina'), (N'Registrar caso de disciplina'),
                              (N'Atender casos de disciplina'), (N'Ver casos reservados');

INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
SELECT x.Nombre, 1, 0, 'Academico'
FROM @Pantallas x
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas p WHERE p.Pan_Descripcion = x.Nombre);

INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN @Pantallas x ON x.Nombre = p.Pan_Descripcion
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0
                        AND LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) IN ('admin', 'director')
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas y WHERE y.Rol_Id = r.Rol_Id AND y.Pan_Id = p.Pan_Id);
GO
