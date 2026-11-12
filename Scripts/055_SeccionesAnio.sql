-- =====================================================================
-- Script 055: Secciones por Año + Profesor Guía (Fase 4 — Clases y profesores)
-- Contexto: espejo de "academic_cycle_sections" de Skuul. Representa las
--           secciones VIVAS de UN año lectivo (Ani_Id) con su docente guía
--           (homeroom). La estructura de catálogo (Nivel/Grado/Sección/
--           Modalidad) ya existe; esto la "instancia" para el año de trabajo.
-- Crea:
--   app.tbSeccionesAnio                 — la entidad (prefijo Sea_).
--   app.PR_tbSeccionesAnio_List         — secciones de un año (+ descripciones).
--   app.PR_tbSeccionesAnio_Find         — una sección por Sea_Id (para editar).
--   app.PR_tbSeccionesAnio_Insert       — alta, devuelve NewId.
--   app.PR_tbSeccionesAnio_Update       — modifica.
--   app.PR_tbSeccionesAnio_Delete       — baja lógica (Sea_EsEliminado=1).
-- Estado (Sea_Estado): 1 Borrador · 2 Planificada · 3 Activa ·
--                      4 Suspendida · 5 Cerrada · 6 Archivada.
-- Convención: idempotente (IF EXISTS + DROP/CREATE). Baja lógica, nunca físico.
-- Columnas verificadas (nov-2026) contra sys.columns:
--   tbNivelesEducativos(Niv_Id, Niv_Descripcion)
--   tbCursosNiveles     (Cun_Id, Cun_Descripcion, Niv_Id)   -- grado académico
--   tbSecciones         (Sec_Id, Sec_Descripcion)
--   tbModalidades       (Mda_Id, Mda_Descripcion)
--   tbEmpleados(Emp_Id, Per_Id) -> tbPersonas(Per_PrimerNombre,
--                   Per_SegundoNombre, Per_ApellidoPaterno, Per_ApellidoMaterno)
-- =====================================================================

USE [DB_GestionColegial]
GO

-- Requerido por la columna computada persistida + índice filtrado.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ──────────────────────────────────────────────────────────────────────
-- Tabla app.tbSeccionesAnio
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[tbSeccionesAnio]') IS NULL
BEGIN
    CREATE TABLE [app].[tbSeccionesAnio]
    (
        [Sea_Id]              INT          IDENTITY(1,1) NOT NULL,
        [Ani_Id]             INT          NOT NULL,
        [Niv_Id]             INT          NOT NULL,
        [Cun_Id]             INT          NOT NULL,
        [Sec_Id]             INT          NOT NULL,
        [Mda_Id]             INT          NULL,
        [Emp_Id]             INT          NULL,   -- Profesor guía (homeroom)
        [Sea_Nombre]         VARCHAR(60)  NULL,   -- Etiqueta visible, ej. "7mo A"
        [Sea_Cupo]           INT          NULL,
        [Sea_Estado]         TINYINT      NOT NULL CONSTRAINT DF_tbSeccionesAnio_Estado      DEFAULT (2),
        [Sea_EsEliminado]    BIT          NOT NULL CONSTRAINT DF_tbSeccionesAnio_EsEliminado DEFAULT (0),
        [Sea_UsuarioRegistra] INT         NULL,
        [Sea_FechaRegistra]  DATETIME     NOT NULL CONSTRAINT DF_tbSeccionesAnio_FechaReg    DEFAULT (GETDATE()),
        [Sea_UsuarioModifica] INT         NULL,
        [Sea_FechaModifica]  DATETIME     NULL,
        -- Clave auxiliar para el UNIQUE (ISNULL(Mda_Id,0)):
        [Sea_MdaKey] AS (ISNULL([Mda_Id],0)) PERSISTED,
        CONSTRAINT [PK_tbSeccionesAnio] PRIMARY KEY CLUSTERED ([Sea_Id] ASC),
        CONSTRAINT [FK_tbSeccionesAnio_Anio]      FOREIGN KEY ([Ani_Id]) REFERENCES [app].[tbAnioLectivo]([Ani_Id]),
        CONSTRAINT [FK_tbSeccionesAnio_Nivel]     FOREIGN KEY ([Niv_Id]) REFERENCES [app].[tbNivelesEducativos]([Niv_Id]),
        CONSTRAINT [FK_tbSeccionesAnio_Grado]     FOREIGN KEY ([Cun_Id]) REFERENCES [app].[tbCursosNiveles]([Cun_Id]),
        CONSTRAINT [FK_tbSeccionesAnio_Seccion]   FOREIGN KEY ([Sec_Id]) REFERENCES [app].[tbSecciones]([Sec_Id]),
        CONSTRAINT [FK_tbSeccionesAnio_Modalidad] FOREIGN KEY ([Mda_Id]) REFERENCES [app].[tbModalidades]([Mda_Id]),
        CONSTRAINT [FK_tbSeccionesAnio_Empleado]  FOREIGN KEY ([Emp_Id]) REFERENCES [app].[tbEmpleados]([Emp_Id])
    );

    -- UNIQUE (Ani_Id, Niv_Id, Cun_Id, Sec_Id, ISNULL(Mda_Id,0)) solo sobre filas vivas,
    -- para que una sección dada de baja pueda recrearse.
    CREATE UNIQUE NONCLUSTERED INDEX [UQ_tbSeccionesAnio_Combo]
        ON [app].[tbSeccionesAnio] ([Ani_Id], [Niv_Id], [Cun_Id], [Sec_Id], [Sea_MdaKey])
        WHERE [Sea_EsEliminado] = 0;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbSeccionesAnio_List  (@Ani_Id -> secciones vivas del año + descripciones)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbSeccionesAnio_List]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbSeccionesAnio_List]
GO
CREATE PROCEDURE [app].[PR_tbSeccionesAnio_List]
    @Ani_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.Sea_Id,
        s.Ani_Id,
        s.Niv_Id,
        n.Niv_Descripcion,
        s.Cun_Id,
        g.Cun_Descripcion,
        s.Sec_Id,
        sc.Sec_Descripcion,
        s.Mda_Id,
        m.Mda_Descripcion,
        s.Emp_Id,
        LTRIM(RTRIM(
            ISNULL(p.Per_PrimerNombre, '') + ' ' +
            ISNULL(p.Per_ApellidoPaterno, '') + ' ' +
            ISNULL(p.Per_ApellidoMaterno, '')
        ))                                          AS Emp_Nombre,
        s.Sea_Nombre,
        s.Sea_Cupo,
        s.Sea_Estado,
        CASE s.Sea_Estado
            WHEN 1 THEN 'Borrador'
            WHEN 2 THEN 'Planificada'
            WHEN 3 THEN 'Activa'
            WHEN 4 THEN 'Suspendida'
            WHEN 5 THEN 'Cerrada'
            WHEN 6 THEN 'Archivada'
            ELSE 'Desconocido'
        END                                         AS Sea_EstadoDescripcion
    FROM        [app].[tbSeccionesAnio]        s
    INNER JOIN  [app].[tbNivelesEducativos]    n  ON n.Niv_Id  = s.Niv_Id
    INNER JOIN  [app].[tbCursosNiveles]        g  ON g.Cun_Id  = s.Cun_Id
    INNER JOIN  [app].[tbSecciones]            sc ON sc.Sec_Id = s.Sec_Id
    LEFT  JOIN  [app].[tbModalidades]          m  ON m.Mda_Id  = s.Mda_Id
    LEFT  JOIN  [app].[tbEmpleados]            e  ON e.Emp_Id  = s.Emp_Id
    LEFT  JOIN  [app].[tbPersonas]             p  ON p.Per_Id  = e.Per_Id
    WHERE       s.Sea_EsEliminado = 0
        AND     s.Ani_Id = @Ani_Id
    ORDER BY    n.Niv_Descripcion, g.Cun_Descripcion, sc.Sec_Descripcion;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbSeccionesAnio_Find  (@value = Sea_Id -> fila cruda para editar)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbSeccionesAnio_Find]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbSeccionesAnio_Find]
GO
CREATE PROCEDURE [app].[PR_tbSeccionesAnio_Find]
    @value INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Sea_Id,
        Ani_Id,
        Niv_Id,
        Cun_Id,
        Sec_Id,
        Mda_Id,
        Emp_Id,
        Sea_Nombre,
        Sea_Cupo,
        Sea_Estado
    FROM    [app].[tbSeccionesAnio]
    WHERE   Sea_Id = @value
        AND Sea_EsEliminado = 0;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbSeccionesAnio_Insert  (alta, devuelve NewId)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbSeccionesAnio_Insert]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbSeccionesAnio_Insert]
GO
CREATE PROCEDURE [app].[PR_tbSeccionesAnio_Insert]
    @Ani_Id               INT,
    @Niv_Id               INT,
    @Cun_Id               INT,
    @Sec_Id               INT,
    @Mda_Id               INT = NULL,
    @Emp_Id               INT = NULL,
    @Sea_Nombre           VARCHAR(60) = NULL,
    @Sea_Cupo             INT = NULL,
    @Sea_Estado           TINYINT = 2,
    @Sea_UsuarioRegistra  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [app].[tbSeccionesAnio]
        (Ani_Id, Niv_Id, Cun_Id, Sec_Id, Mda_Id, Emp_Id, Sea_Nombre, Sea_Cupo,
         Sea_Estado, Sea_EsEliminado, Sea_UsuarioRegistra, Sea_FechaRegistra)
    VALUES
        (@Ani_Id, @Niv_Id, @Cun_Id, @Sec_Id, @Mda_Id, @Emp_Id, @Sea_Nombre, @Sea_Cupo,
         ISNULL(NULLIF(@Sea_Estado, 0), 2), 0, @Sea_UsuarioRegistra, GETDATE());

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbSeccionesAnio_Update
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbSeccionesAnio_Update]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbSeccionesAnio_Update]
GO
CREATE PROCEDURE [app].[PR_tbSeccionesAnio_Update]
    @Sea_Id               INT,
    @Ani_Id               INT,
    @Niv_Id               INT,
    @Cun_Id               INT,
    @Sec_Id               INT,
    @Mda_Id               INT = NULL,
    @Emp_Id               INT = NULL,
    @Sea_Nombre           VARCHAR(60) = NULL,
    @Sea_Cupo             INT = NULL,
    @Sea_Estado           TINYINT = 2,
    @Sea_UsuarioModifica  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE  [app].[tbSeccionesAnio]
    SET     Ani_Id              = @Ani_Id,
            Niv_Id              = @Niv_Id,
            Cun_Id              = @Cun_Id,
            Sec_Id              = @Sec_Id,
            Mda_Id              = @Mda_Id,
            Emp_Id              = @Emp_Id,
            Sea_Nombre          = @Sea_Nombre,
            Sea_Cupo            = @Sea_Cupo,
            Sea_Estado          = ISNULL(NULLIF(@Sea_Estado, 0), 2),
            Sea_UsuarioModifica = @Sea_UsuarioModifica,
            Sea_FechaModifica   = GETDATE()
    WHERE   Sea_Id = @Sea_Id;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbSeccionesAnio_Delete  (baja lógica)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbSeccionesAnio_Delete]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbSeccionesAnio_Delete]
GO
CREATE PROCEDURE [app].[PR_tbSeccionesAnio_Delete]
    @Sea_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE  [app].[tbSeccionesAnio]
    SET     Sea_EsEliminado   = 1,
            Sea_FechaModifica  = GETDATE()
    WHERE   Sea_Id = @Sea_Id;
END
GO
