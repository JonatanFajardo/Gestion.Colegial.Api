-- =====================================================================
-- Script 058: Matrícula por Año + Promociones (Expediente / Transcript)
-- Contexto: espejo de "academic_year_student_record" + "promotions" de Skuul
--           (hueco #1 — capa multi-año). Registra la matrícula de un alumno
--           en UN año lectivo y una sección-año, y permite promover a los
--           alumnos de una sección-año de un año al siguiente.
-- Crea:
--   app.tbMatriculaAnio                     — la entidad (prefijo Mta_).
--   app.PR_tbMatriculaAnio_ListBySeccion    — alumnos de una sección-año.
--   app.PR_tbMatriculaAnio_Expediente       — historial del alumno por año.
--   app.PR_tbMatriculaAnio_Enroll           — inserta o reactiva; devuelve NewId.
--   app.PR_tbMatriculaAnio_Promover         — promueve una sección-año completa.
-- Estado (Mta_Estado): 1 Activa · 2 Promovido · 3 Repite · 4 Retirado · 5 Graduado.
-- Convención: idempotente (IF EXISTS + DROP/CREATE). Baja lógica, nunca físico.
-- Columnas verificadas (nov-2026) contra sys.columns:
--   tbAlumnos(Alu_Id, Per_Id) -> tbPersonas(Per_PrimerNombre, Per_SegundoNombre,
--                                 Per_ApellidoPaterno, Per_ApellidoMaterno)
--   tbAnioLectivo(Ani_Id, Ani_Anio, Ani_Nombre)
--   tbSeccionesAnio(Sea_Id, Sea_Nombre)
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- Tabla app.tbMatriculaAnio
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[tbMatriculaAnio]') IS NULL
BEGIN
    CREATE TABLE [app].[tbMatriculaAnio]
    (
        [Mta_Id]              INT      IDENTITY(1,1) NOT NULL,
        [Alu_Id]             INT      NOT NULL,
        [Ani_Id]             INT      NOT NULL,
        [Sea_Id]             INT      NULL,
        [Mta_Estado]         TINYINT  NOT NULL CONSTRAINT DF_tbMatriculaAnio_Estado      DEFAULT (1),
        [Mta_EsEliminado]    BIT      NOT NULL CONSTRAINT DF_tbMatriculaAnio_EsEliminado DEFAULT (0),
        [Mta_UsuarioRegistra] INT     NULL,
        [Mta_FechaRegistra]  DATETIME NOT NULL CONSTRAINT DF_tbMatriculaAnio_FechaReg    DEFAULT (GETDATE()),
        [Mta_UsuarioModifica] INT     NULL,
        [Mta_FechaModifica]  DATETIME NULL,
        CONSTRAINT [PK_tbMatriculaAnio] PRIMARY KEY CLUSTERED ([Mta_Id] ASC),
        CONSTRAINT [UQ_tbMatriculaAnio_AluAnio] UNIQUE ([Alu_Id], [Ani_Id]),
        CONSTRAINT [FK_tbMatriculaAnio_Alumno]  FOREIGN KEY ([Alu_Id]) REFERENCES [app].[tbAlumnos]([Alu_Id]),
        CONSTRAINT [FK_tbMatriculaAnio_Anio]    FOREIGN KEY ([Ani_Id]) REFERENCES [app].[tbAnioLectivo]([Ani_Id]),
        CONSTRAINT [FK_tbMatriculaAnio_Seccion] FOREIGN KEY ([Sea_Id]) REFERENCES [app].[tbSeccionesAnio]([Sea_Id])
    );
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbMatriculaAnio_ListBySeccion  (@Sea_Id -> alumnos de esa sección-año)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbMatriculaAnio_ListBySeccion]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbMatriculaAnio_ListBySeccion]
GO
CREATE PROCEDURE [app].[PR_tbMatriculaAnio_ListBySeccion]
    @Sea_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        mt.Mta_Id,
        mt.Alu_Id,
        a.Per_Id,
        LTRIM(RTRIM(
            ISNULL(p.Per_PrimerNombre, '') + ' ' +
            ISNULL(p.Per_SegundoNombre, '') + ' ' +
            ISNULL(p.Per_ApellidoPaterno, '') + ' ' +
            ISNULL(p.Per_ApellidoMaterno, '')
        ))                                          AS Alu_Nombre,
        mt.Ani_Id,
        mt.Sea_Id,
        mt.Mta_Estado,
        CASE mt.Mta_Estado
            WHEN 1 THEN 'Activa'
            WHEN 2 THEN 'Promovido'
            WHEN 3 THEN 'Repite'
            WHEN 4 THEN 'Retirado'
            WHEN 5 THEN 'Graduado'
            ELSE 'Desconocido'
        END                                         AS Mta_EstadoDescripcion
    FROM        [app].[tbMatriculaAnio]  mt
    INNER JOIN  [app].[tbAlumnos]        a ON a.Alu_Id = mt.Alu_Id
    LEFT  JOIN  [app].[tbPersonas]       p ON p.Per_Id = a.Per_Id
    WHERE       mt.Sea_Id = @Sea_Id
        AND     mt.Mta_EsEliminado = 0
    ORDER BY    Alu_Nombre;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbMatriculaAnio_Expediente  (@Alu_Id -> historial del alumno por año)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbMatriculaAnio_Expediente]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbMatriculaAnio_Expediente]
GO
CREATE PROCEDURE [app].[PR_tbMatriculaAnio_Expediente]
    @Alu_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        mt.Mta_Id,
        mt.Alu_Id,
        mt.Ani_Id,
        an.Ani_Anio,
        an.Ani_Nombre,
        mt.Sea_Id,
        se.Sea_Nombre,
        mt.Mta_Estado,
        CASE mt.Mta_Estado
            WHEN 1 THEN 'Activa'
            WHEN 2 THEN 'Promovido'
            WHEN 3 THEN 'Repite'
            WHEN 4 THEN 'Retirado'
            WHEN 5 THEN 'Graduado'
            ELSE 'Desconocido'
        END                                         AS Mta_EstadoDescripcion
    FROM        [app].[tbMatriculaAnio]   mt
    INNER JOIN  [app].[tbAnioLectivo]     an ON an.Ani_Id = mt.Ani_Id
    LEFT  JOIN  [app].[tbSeccionesAnio]   se ON se.Sea_Id = mt.Sea_Id
    WHERE       mt.Alu_Id = @Alu_Id
        AND     mt.Mta_EsEliminado = 0
    ORDER BY    an.Ani_Anio DESC;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbMatriculaAnio_Enroll  (inserta o reactiva la matrícula del alumno)
--   Respeta UNIQUE (Alu_Id, Ani_Id): si ya existe fila (viva o eliminada),
--   la reactiva y actualiza la sección; si no, inserta. Devuelve NewId.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbMatriculaAnio_Enroll]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbMatriculaAnio_Enroll]
GO
CREATE PROCEDURE [app].[PR_tbMatriculaAnio_Enroll]
    @Alu_Id               INT,
    @Ani_Id               INT,
    @Sea_Id               INT = NULL,
    @Mta_UsuarioRegistra  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id INT = (
        SELECT TOP 1 Mta_Id FROM [app].[tbMatriculaAnio]
        WHERE Alu_Id = @Alu_Id AND Ani_Id = @Ani_Id
    );

    IF @id IS NOT NULL
    BEGIN
        UPDATE  [app].[tbMatriculaAnio]
        SET     Sea_Id             = @Sea_Id,
                Mta_Estado         = 1,                 -- Activa
                Mta_EsEliminado    = 0,
                Mta_UsuarioModifica = @Mta_UsuarioRegistra,
                Mta_FechaModifica  = GETDATE()
        WHERE   Mta_Id = @id;
    END
    ELSE
    BEGIN
        INSERT INTO [app].[tbMatriculaAnio]
            (Alu_Id, Ani_Id, Sea_Id, Mta_Estado, Mta_EsEliminado, Mta_UsuarioRegistra, Mta_FechaRegistra)
        VALUES
            (@Alu_Id, @Ani_Id, @Sea_Id, 1, 0, @Mta_UsuarioRegistra, GETDATE());

        SET @id = CAST(SCOPE_IDENTITY() AS INT);
    END

    SELECT @id AS NewId;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbMatriculaAnio_Promover
--   Por cada alumno Activo (1) en (@Ani_Origen,@Sea_Origen):
--     1) marca su matrícula origen como Promovido (2).
--     2) inserta matrícula Activa (1) en (@Ani_Destino,@Sea_Destino)
--        si el alumno aún no tiene matrícula en @Ani_Destino.
--   Todo en una transacción. Devuelve el conteo de promovidos.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbMatriculaAnio_Promover]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbMatriculaAnio_Promover]
GO
CREATE PROCEDURE [app].[PR_tbMatriculaAnio_Promover]
    @Ani_Origen   INT,
    @Sea_Origen   INT,
    @Ani_Destino  INT,
    @Sea_Destino  INT,
    @Usuario      INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @promovidos INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Alumnos activos en la sección-año de origen.
        DECLARE @alumnos TABLE (Alu_Id INT PRIMARY KEY);
        INSERT INTO @alumnos (Alu_Id)
        SELECT Alu_Id
        FROM   [app].[tbMatriculaAnio]
        WHERE  Ani_Id = @Ani_Origen
            AND Sea_Id = @Sea_Origen
            AND Mta_Estado = 1
            AND Mta_EsEliminado = 0;

        SET @promovidos = (SELECT COUNT(*) FROM @alumnos);

        -- 1) Marca el origen como Promovido.
        UPDATE  mt
        SET     mt.Mta_Estado         = 2,              -- Promovido
                mt.Mta_UsuarioModifica = @Usuario,
                mt.Mta_FechaModifica  = GETDATE()
        FROM    [app].[tbMatriculaAnio] mt
        INNER JOIN @alumnos al ON al.Alu_Id = mt.Alu_Id
        WHERE   mt.Ani_Id = @Ani_Origen
            AND mt.Sea_Id = @Sea_Origen
            AND mt.Mta_Estado = 1
            AND mt.Mta_EsEliminado = 0;

        -- 2) Inserta la matrícula Activa en destino (solo quienes no tienen fila en @Ani_Destino).
        INSERT INTO [app].[tbMatriculaAnio]
            (Alu_Id, Ani_Id, Sea_Id, Mta_Estado, Mta_EsEliminado, Mta_UsuarioRegistra, Mta_FechaRegistra)
        SELECT  al.Alu_Id, @Ani_Destino, @Sea_Destino, 1, 0, @Usuario, GETDATE()
        FROM    @alumnos al
        WHERE   NOT EXISTS (
                    SELECT 1 FROM [app].[tbMatriculaAnio] d
                    WHERE d.Alu_Id = al.Alu_Id AND d.Ani_Id = @Ani_Destino
                );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @msg NVARCHAR(2048) = ERROR_MESSAGE();
        RAISERROR(@msg, 16, 1);
        RETURN;
    END CATCH

    SELECT @promovidos AS Promovidos;
END
GO
