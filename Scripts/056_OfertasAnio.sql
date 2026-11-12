-- =====================================================================
-- Script 056: Ofertas de Asignatura por Año (Fase 5 — capa multi-año)
-- Contexto: espejo de course_offerings + teaching_assignments de Skuul.
--           La "oferta" = una materia que se dicta en el año lectivo,
--           para un grado/sección, con un docente asignado.
-- Crea:
--   app.tbOfertasAnio                 — la entidad (prefijo Ofa_).
--   app.PR_tbOfertasAnio_List         — ofertas de un año (+ descripciones JOIN).
--   app.PR_tbOfertasAnio_Find         — una oferta por Ofa_Id.
--   app.PR_tbOfertasAnio_Insert       — alta, devuelve NewId.
--   app.PR_tbOfertasAnio_Update       — modifica.
--   app.PR_tbOfertasAnio_Delete       — baja lógica (Ofa_EsEliminado=1).
-- Ciclo de vida (Ofa_Estado): 1 Borrador · 2 Programada · 3 Activa ·
--                             4 Suspendida · 5 Cerrada · 6 Archivada.
-- Convención: idempotente (IF EXISTS + DROP/CREATE). Baja lógica, nunca físico.
--
-- NOTA DE ACOPLAMIENTO:
--   * Sea_Id (sección-año) referencia app.tbSeccionesAnio, que crea otro script
--     y puede NO existir todavía → se deja como INT NULL SIN FK.
--   * Pan_Id (período) referencia app.tbPeriodosAnio (ya existe), pero por la
--     misma razón de independencia entre fases se deja como INT NULL SIN FK.
--   Cuando esas tablas estén estables se pueden agregar las FK en un script posterior.
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- Tabla app.tbOfertasAnio
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[tbOfertasAnio]') IS NULL
BEGIN
    CREATE TABLE [app].[tbOfertasAnio]
    (
        [Ofa_Id]              INT        IDENTITY(1,1) NOT NULL,
        [Ani_Id]             INT        NOT NULL,                 -- Año lectivo (FK)
        [Mat_Id]             INT        NOT NULL,                 -- Materia (FK)
        [Cun_Id]             INT        NULL,                     -- Grado académico (FK, opcional)
        [Sea_Id]             INT        NULL,                     -- Sección-año (SIN FK; tabla en paralelo)
        [Emp_Id]             INT        NULL,                     -- Docente = empleado (FK, opcional)
        [Pan_Id]             INT        NULL,                     -- Período (SIN FK; tabla en paralelo)
        [Ofa_HorasSemana]    INT        NULL,                     -- Horas semanales
        [Ofa_Estado]         TINYINT    NOT NULL CONSTRAINT DF_tbOfertasAnio_Estado      DEFAULT (1),
        [Ofa_EsEliminado]    BIT        NOT NULL CONSTRAINT DF_tbOfertasAnio_EsEliminado DEFAULT (0),
        [Ofa_UsuarioRegistra] INT       NULL,
        [Ofa_FechaRegistra]  DATETIME   NOT NULL CONSTRAINT DF_tbOfertasAnio_FechaReg    DEFAULT (GETDATE()),
        [Ofa_UsuarioModifica] INT       NULL,
        [Ofa_FechaModifica]  DATETIME   NULL,
        CONSTRAINT [PK_tbOfertasAnio] PRIMARY KEY CLUSTERED ([Ofa_Id] ASC),
        CONSTRAINT [FK_tbOfertasAnio_AnioLectivo] FOREIGN KEY ([Ani_Id]) REFERENCES [app].[tbAnioLectivo] ([Ani_Id]),
        CONSTRAINT [FK_tbOfertasAnio_Materia]     FOREIGN KEY ([Mat_Id]) REFERENCES [app].[tbMaterias] ([Mat_Id]),
        CONSTRAINT [FK_tbOfertasAnio_Grado]       FOREIGN KEY ([Cun_Id]) REFERENCES [app].[tbCursosNiveles] ([Cun_Id]),
        CONSTRAINT [FK_tbOfertasAnio_Empleado]    FOREIGN KEY ([Emp_Id]) REFERENCES [app].[tbEmpleados] ([Emp_Id])
        -- Sea_Id / Pan_Id: SIN FK a propósito (ver nota de acoplamiento arriba).
    );
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbOfertasAnio_List  (@Ani_Id = año lectivo; con descripciones por JOIN)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbOfertasAnio_List]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbOfertasAnio_List]
GO
CREATE PROCEDURE [app].[PR_tbOfertasAnio_List]
    @Ani_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.Ofa_Id,
        o.Ani_Id,
        o.Mat_Id,
        m.Mat_Nombre,
        o.Cun_Id,
        c.Cun_Descripcion,
        o.Sea_Id,
        o.Emp_Id,
        LTRIM(RTRIM(
            ISNULL(p.Per_PrimerNombre, '') + ' ' +
            ISNULL(p.Per_ApellidoPaterno, '') + ' ' +
            ISNULL(p.Per_ApellidoMaterno, '')
        ))                                          AS Emp_Nombre,
        o.Pan_Id,
        o.Ofa_HorasSemana,
        o.Ofa_Estado,
        CASE o.Ofa_Estado
            WHEN 1 THEN 'Borrador'
            WHEN 2 THEN 'Programada'
            WHEN 3 THEN 'Activa'
            WHEN 4 THEN 'Suspendida'
            WHEN 5 THEN 'Cerrada'
            WHEN 6 THEN 'Archivada'
            ELSE 'Desconocido'
        END                                         AS Ofa_EstadoDescripcion
    FROM    [app].[tbOfertasAnio]   o
    INNER JOIN [app].[tbMaterias]       m ON m.Mat_Id = o.Mat_Id
    LEFT  JOIN [app].[tbCursosNiveles]  c ON c.Cun_Id = o.Cun_Id
    LEFT  JOIN [app].[tbEmpleados]      e ON e.Emp_Id = o.Emp_Id
    LEFT  JOIN [app].[tbPersonas]       p ON p.Per_Id = e.Per_Id
    WHERE   o.Ofa_EsEliminado = 0
        AND o.Ani_Id = @Ani_Id
    ORDER BY c.Cun_Descripcion, m.Mat_Nombre;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbOfertasAnio_Find  (@value = Ofa_Id)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbOfertasAnio_Find]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbOfertasAnio_Find]
GO
CREATE PROCEDURE [app].[PR_tbOfertasAnio_Find]
    @value INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Ofa_Id,
        Ani_Id,
        Mat_Id,
        Cun_Id,
        Sea_Id,
        Emp_Id,
        Pan_Id,
        Ofa_HorasSemana,
        Ofa_Estado
    FROM    [app].[tbOfertasAnio]
    WHERE   Ofa_Id = @value
        AND Ofa_EsEliminado = 0;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbOfertasAnio_Insert  (devuelve NewId)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbOfertasAnio_Insert]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbOfertasAnio_Insert]
GO
CREATE PROCEDURE [app].[PR_tbOfertasAnio_Insert]
    @Ani_Id              INT,
    @Mat_Id              INT,
    @Cun_Id              INT = NULL,
    @Sea_Id              INT = NULL,
    @Emp_Id              INT = NULL,
    @Pan_Id              INT = NULL,
    @Ofa_HorasSemana     INT = NULL,
    @Ofa_Estado          TINYINT = 1,
    @Ofa_UsuarioRegistra INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [app].[tbOfertasAnio]
        (Ani_Id, Mat_Id, Cun_Id, Sea_Id, Emp_Id, Pan_Id, Ofa_HorasSemana,
         Ofa_Estado, Ofa_EsEliminado, Ofa_UsuarioRegistra, Ofa_FechaRegistra)
    VALUES
        (@Ani_Id, @Mat_Id, @Cun_Id, @Sea_Id, @Emp_Id, @Pan_Id, @Ofa_HorasSemana,
         ISNULL(NULLIF(@Ofa_Estado, 0), 1), 0, @Ofa_UsuarioRegistra, GETDATE());

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbOfertasAnio_Update
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbOfertasAnio_Update]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbOfertasAnio_Update]
GO
CREATE PROCEDURE [app].[PR_tbOfertasAnio_Update]
    @Ofa_Id              INT,
    @Ani_Id              INT,
    @Mat_Id              INT,
    @Cun_Id              INT = NULL,
    @Sea_Id              INT = NULL,
    @Emp_Id              INT = NULL,
    @Pan_Id              INT = NULL,
    @Ofa_HorasSemana     INT = NULL,
    @Ofa_Estado          TINYINT,
    @Ofa_UsuarioModifica INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE  [app].[tbOfertasAnio]
    SET     Ani_Id              = @Ani_Id,
            Mat_Id              = @Mat_Id,
            Cun_Id              = @Cun_Id,
            Sea_Id              = @Sea_Id,
            Emp_Id              = @Emp_Id,
            Pan_Id              = @Pan_Id,
            Ofa_HorasSemana     = @Ofa_HorasSemana,
            Ofa_Estado          = ISNULL(NULLIF(@Ofa_Estado, 0), 1),
            Ofa_UsuarioModifica = @Ofa_UsuarioModifica,
            Ofa_FechaModifica   = GETDATE()
    WHERE   Ofa_Id = @Ofa_Id;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbOfertasAnio_Delete  (baja lógica)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbOfertasAnio_Delete]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbOfertasAnio_Delete]
GO
CREATE PROCEDURE [app].[PR_tbOfertasAnio_Delete]
    @value INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE  [app].[tbOfertasAnio]
    SET     Ofa_EsEliminado   = 1,
            Ofa_FechaModifica = GETDATE()
    WHERE   Ofa_Id = @value;
END
GO
