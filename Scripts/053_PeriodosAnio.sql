-- =====================================================================
-- Script 053: Períodos de reporte del año lectivo (Fase 2)
-- Contexto: espejo de los "reporting periods" de Skuul. Cada año lectivo
--           (app.tbAnioLectivo) se subdivide en períodos de evaluación/
--           reporte (parciales, semestres, trimestres, bimestres, otros)
--           con fechas de inicio/fin y su propio orden.
-- Crea:
--   app.tbPeriodosAnio                — la entidad (prefijo Pan_).
--   app.PR_tbPeriodosAnio_List        — lista períodos de un año (por @value=Ani_Id, ordenados por Pan_Orden).
--   app.PR_tbPeriodosAnio_Find        — un período por Pan_Id (@value).
--   app.PR_tbPeriodosAnio_Insert      — alta, devuelve NewId.
--   app.PR_tbPeriodosAnio_Update      — modifica.
--   app.PR_tbPeriodosAnio_Delete      — baja lógica (Pan_EsEliminado=1).
-- Estado (Pan_Estado): reusa el ciclo de vida del año →
--   1 Borrador · 2 Programado · 3 Abierto · 4 Cerrando · 5 Cerrado · 6 Archivado.
-- Convención: idempotente (IF EXISTS + DROP/CREATE). Baja lógica, nunca físico.
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- Tabla app.tbPeriodosAnio
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[tbPeriodosAnio]') IS NULL
BEGIN
    CREATE TABLE [app].[tbPeriodosAnio]
    (
        [Pan_Id]              INT            IDENTITY(1,1) NOT NULL,
        [Ani_Id]             INT            NOT NULL,
        [Pan_Nombre]         VARCHAR(40)    NOT NULL,
        [Pan_Tipo]           VARCHAR(20)    NOT NULL CONSTRAINT DF_tbPeriodosAnio_Tipo        DEFAULT ('parcial'),
        [Pan_Orden]          SMALLINT       NOT NULL CONSTRAINT DF_tbPeriodosAnio_Orden       DEFAULT (1),
        [Pan_FechaInicio]    DATE           NULL,
        [Pan_FechaFin]       DATE           NULL,
        [Pan_Estado]         TINYINT        NOT NULL CONSTRAINT DF_tbPeriodosAnio_Estado      DEFAULT (1),
        [Pan_EsActivo]       BIT            NOT NULL CONSTRAINT DF_tbPeriodosAnio_EsActivo    DEFAULT (1),
        [Pan_EsEliminado]    BIT            NOT NULL CONSTRAINT DF_tbPeriodosAnio_EsEliminado DEFAULT (0),
        [Pan_UsuarioRegistra] INT           NULL,
        [Pan_FechaRegistra]  DATETIME       NOT NULL CONSTRAINT DF_tbPeriodosAnio_FechaReg    DEFAULT (GETDATE()),
        [Pan_UsuarioModifica] INT           NULL,
        [Pan_FechaModifica]  DATETIME       NULL,
        CONSTRAINT [PK_tbPeriodosAnio] PRIMARY KEY CLUSTERED ([Pan_Id] ASC),
        CONSTRAINT [FK_tbPeriodosAnio_tbAnioLectivo] FOREIGN KEY ([Ani_Id])
            REFERENCES [app].[tbAnioLectivo] ([Ani_Id]),
        CONSTRAINT [UQ_tbPeriodosAnio_AnioNombre] UNIQUE ([Ani_Id], [Pan_Nombre])
    );
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbPeriodosAnio_List  (@value = Ani_Id; ordenado por Pan_Orden)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbPeriodosAnio_List]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbPeriodosAnio_List]
GO
CREATE PROCEDURE [app].[PR_tbPeriodosAnio_List]
    @value INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.Pan_Id,
        p.Ani_Id,
        p.Pan_Nombre,
        p.Pan_Tipo,
        p.Pan_Orden,
        p.Pan_FechaInicio,
        p.Pan_FechaFin,
        p.Pan_Estado,
        CASE p.Pan_Estado
            WHEN 1 THEN 'Borrador'
            WHEN 2 THEN 'Programado'
            WHEN 3 THEN 'Abierto'
            WHEN 4 THEN 'Cerrando'
            WHEN 5 THEN 'Cerrado'
            WHEN 6 THEN 'Archivado'
            ELSE 'Desconocido'
        END                                         AS Pan_EstadoDescripcion,
        p.Pan_EsActivo
    FROM    [app].[tbPeriodosAnio] p
    WHERE   p.Pan_EsEliminado = 0
        AND p.Ani_Id = @value
    ORDER BY p.Pan_Orden ASC, p.Pan_Id ASC;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbPeriodosAnio_Find  (@value = Pan_Id)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbPeriodosAnio_Find]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbPeriodosAnio_Find]
GO
CREATE PROCEDURE [app].[PR_tbPeriodosAnio_Find]
    @value INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Pan_Id,
        Ani_Id,
        Pan_Nombre,
        Pan_Tipo,
        Pan_Orden,
        Pan_FechaInicio,
        Pan_FechaFin,
        Pan_Estado,
        Pan_EsActivo
    FROM    [app].[tbPeriodosAnio]
    WHERE   Pan_Id = @value
        AND Pan_EsEliminado = 0;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbPeriodosAnio_Insert  (devuelve NewId)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbPeriodosAnio_Insert]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbPeriodosAnio_Insert]
GO
CREATE PROCEDURE [app].[PR_tbPeriodosAnio_Insert]
    @Ani_Id               INT,
    @Pan_Nombre           VARCHAR(40),
    @Pan_Tipo             VARCHAR(20) = 'parcial',
    @Pan_Orden            SMALLINT = 1,
    @Pan_FechaInicio      DATE = NULL,
    @Pan_FechaFin         DATE = NULL,
    @Pan_Estado           TINYINT = 1,
    @Pan_UsuarioRegistra  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [app].[tbPeriodosAnio]
        (Ani_Id, Pan_Nombre, Pan_Tipo, Pan_Orden, Pan_FechaInicio, Pan_FechaFin,
         Pan_Estado, Pan_EsActivo, Pan_EsEliminado, Pan_UsuarioRegistra, Pan_FechaRegistra)
    VALUES
        (@Ani_Id, @Pan_Nombre, @Pan_Tipo, @Pan_Orden, @Pan_FechaInicio, @Pan_FechaFin,
         @Pan_Estado, 1, 0, @Pan_UsuarioRegistra, GETDATE());

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbPeriodosAnio_Update
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbPeriodosAnio_Update]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbPeriodosAnio_Update]
GO
CREATE PROCEDURE [app].[PR_tbPeriodosAnio_Update]
    @Pan_Id               INT,
    @Ani_Id               INT,
    @Pan_Nombre           VARCHAR(40),
    @Pan_Tipo             VARCHAR(20),
    @Pan_Orden            SMALLINT,
    @Pan_FechaInicio      DATE = NULL,
    @Pan_FechaFin         DATE = NULL,
    @Pan_Estado           TINYINT,
    @Pan_UsuarioModifica  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE  [app].[tbPeriodosAnio]
    SET     Ani_Id              = @Ani_Id,
            Pan_Nombre          = @Pan_Nombre,
            Pan_Tipo            = @Pan_Tipo,
            Pan_Orden           = @Pan_Orden,
            Pan_FechaInicio     = @Pan_FechaInicio,
            Pan_FechaFin        = @Pan_FechaFin,
            Pan_Estado          = @Pan_Estado,
            Pan_UsuarioModifica = @Pan_UsuarioModifica,
            Pan_FechaModifica   = GETDATE()
    WHERE   Pan_Id = @Pan_Id;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbPeriodosAnio_Delete  (baja lógica)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbPeriodosAnio_Delete]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbPeriodosAnio_Delete]
GO
CREATE PROCEDURE [app].[PR_tbPeriodosAnio_Delete]
    @value INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE  [app].[tbPeriodosAnio]
    SET     Pan_EsEliminado = 1
    WHERE   Pan_Id = @value;
END
GO
