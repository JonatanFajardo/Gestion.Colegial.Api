-- =====================================================================
-- Script 054: Enfoque de enseñanza por año lectivo (Fase 3)
-- Espejo del "Instructional Model" de Skuul. 1 registro por año lectivo.
-- Define la agrupación predeterminada de los grupos para el año:
--   grupo_fijo        → un mismo grupo todo el día (homeroom).
--   hibrido           → un grupo, con excepciones.
--   horario_materias  → horario de materias separadas (cada materia su bloque).
-- Crea:
--   app.tbEnfoqueAnio             — la entidad (FK y UNIQUE a app.tbAnioLectivo.Ani_Id).
--   app.PR_tbEnfoqueAnio_Find     — devuelve el enfoque del año (@value = Ani_Id), o vacío.
--   app.PR_tbEnfoqueAnio_Set      — upsert: si existe UPDATE, si no INSERT; devuelve el Ani_Id.
-- Convención: idempotente (IF EXISTS + DROP/CREATE). Baja lógica, nunca físico.
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- Tabla app.tbEnfoqueAnio
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[tbEnfoqueAnio]') IS NULL
BEGIN
    CREATE TABLE [app].[tbEnfoqueAnio]
    (
        [Enf_Id]              INT            IDENTITY(1,1) NOT NULL,
        [Ani_Id]             INT            NOT NULL,
        [Enf_Modelo]         VARCHAR(30)    NOT NULL,
        [Enf_Razon]          VARCHAR(500)   NULL,
        [Enf_EsEliminado]    BIT            NOT NULL CONSTRAINT DF_tbEnfoqueAnio_EsEliminado DEFAULT (0),
        [Enf_UsuarioRegistra] INT           NULL,
        [Enf_FechaRegistra]  DATETIME       NOT NULL CONSTRAINT DF_tbEnfoqueAnio_FechaReg    DEFAULT (GETDATE()),
        [Enf_UsuarioModifica] INT           NULL,
        [Enf_FechaModifica]  DATETIME       NULL,
        CONSTRAINT [PK_tbEnfoqueAnio] PRIMARY KEY CLUSTERED ([Enf_Id] ASC),
        CONSTRAINT [UQ_tbEnfoqueAnio_Ani] UNIQUE ([Ani_Id]),
        CONSTRAINT [FK_tbEnfoqueAnio_tbAnioLectivo] FOREIGN KEY ([Ani_Id])
            REFERENCES [app].[tbAnioLectivo] ([Ani_Id])
    );
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbEnfoqueAnio_Find  (@value = Ani_Id → el enfoque del año, o vacío)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbEnfoqueAnio_Find]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbEnfoqueAnio_Find]
GO
CREATE PROCEDURE [app].[PR_tbEnfoqueAnio_Find]
    @value INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Enf_Id,
        Ani_Id,
        Enf_Modelo,
        Enf_Razon
    FROM    [app].[tbEnfoqueAnio]
    WHERE   Ani_Id = @value
        AND Enf_EsEliminado = 0;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbEnfoqueAnio_Set  (upsert: UPDATE si existe, INSERT si no; devuelve Ani_Id)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbEnfoqueAnio_Set]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbEnfoqueAnio_Set]
GO
CREATE PROCEDURE [app].[PR_tbEnfoqueAnio_Set]
    @Ani_Id     INT,
    @Enf_Modelo VARCHAR(30),
    @Enf_Razon  VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM [app].[tbEnfoqueAnio] WHERE Ani_Id = @Ani_Id AND Enf_EsEliminado = 0)
    BEGIN
        UPDATE  [app].[tbEnfoqueAnio]
        SET     Enf_Modelo        = @Enf_Modelo,
                Enf_Razon         = @Enf_Razon,
                Enf_FechaModifica = GETDATE()
        WHERE   Ani_Id = @Ani_Id
            AND Enf_EsEliminado = 0;
    END
    ELSE
    BEGIN
        INSERT INTO [app].[tbEnfoqueAnio]
            (Ani_Id, Enf_Modelo, Enf_Razon, Enf_EsEliminado, Enf_FechaRegistra)
        VALUES
            (@Ani_Id, @Enf_Modelo, @Enf_Razon, 0, GETDATE());
    END

    SELECT @Ani_Id AS Ani_Id;
END
GO
