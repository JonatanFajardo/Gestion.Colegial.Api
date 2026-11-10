-- =====================================================================
-- Script 046: Entregas de Tarea (por alumno)
-- Contexto: app.tbTareas solo administra la tarea (metadata). No existe
--           forma de registrar quién entregó ni calificar la entrega.
-- Crea:
--   app.tbEntregasTarea            — tabla de entregas por alumno
--   app.PR_tbEntregasTarea_List    — lista alumnos de la sección de la
--                                    tarea marcando quién entregó
--   app.PR_tbEntregasTarea_Upsert  — registra/marca la entrega de un alumno
--   app.PR_tbEntregasTarea_Update  — califica una entrega existente
-- Convención: idempotente (IF NOT EXISTS / DROP IF EXISTS + CREATE)
-- NO APLICAR SIN REVISIÓN — solo referencia para revisión manual.
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- tbEntregasTarea
-- ──────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbEntregasTarea' AND schema_id = SCHEMA_ID('app'))
BEGIN
    CREATE TABLE [app].[tbEntregasTarea] (
        [Ent_Id]              INT IDENTITY(1,1)  NOT NULL,
        [Tar_Id]              INT                NOT NULL,
        [Alu_Id]              INT                NOT NULL,
        [Ent_Entregado]       BIT                NOT NULL CONSTRAINT [DF_tbEntregasTarea_Entregado] DEFAULT (0),
        [Ent_FechaEntrega]    DATETIME           NULL,
        [Ent_Nota]            DECIMAL(5,2)       NULL,
        [Ent_Observacion]     NVARCHAR(500)      NULL,
        [Ent_EsEliminado]     BIT                NOT NULL CONSTRAINT [DF_tbEntregasTarea_EsEliminado] DEFAULT (0),
        [Ent_UsuarioRegistra] INT                NOT NULL,
        [Ent_FechaRegistra]   DATETIME           NOT NULL CONSTRAINT [DF_tbEntregasTarea_FechaRegistra] DEFAULT (GETDATE()),
        [Ent_UsuarioModifica] INT                NULL,
        [Ent_FechaModifica]   DATETIME           NULL,
        CONSTRAINT [PK_tbEntregasTarea] PRIMARY KEY CLUSTERED ([Ent_Id] ASC),
        CONSTRAINT [FK_tbEntregasTarea_Tar_Id] FOREIGN KEY ([Tar_Id]) REFERENCES [app].[tbTareas]([Tar_Id]),
        CONSTRAINT [FK_tbEntregasTarea_Alu_Id] FOREIGN KEY ([Alu_Id]) REFERENCES [app].[tbAlumnos]([Alu_Id])
    );

    -- Un alumno solo puede tener una entrega activa por tarea.
    CREATE UNIQUE INDEX [UX_tbEntregasTarea_Tar_Alu_Activo]
        ON [app].[tbEntregasTarea] ([Tar_Id], [Alu_Id])
        WHERE [Ent_EsEliminado] = 0;

    PRINT 'tbEntregasTarea creada.';
END
ELSE
    PRINT 'tbEntregasTarea ya existe.';
GO

-- ══════════════════════════════════════════
-- SPs
-- ══════════════════════════════════════════

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbEntregasTarea_List
-- Lista todos los alumnos de la sección de la tarea (resuelta vía
-- Tar_Id -> Hor_Id -> Sec_Id/Hor_Año) marcando si entregaron y su nota.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbEntregasTarea_List]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbEntregasTarea_List]
GO
CREATE PROCEDURE [app].[PR_tbEntregasTarea_List]
    @Tar_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Sec_Id INT, @Anio INT;
    SELECT
        @Sec_Id = h.Sec_Id,
        @Anio   = h.Hor_Año
    FROM [app].[tbTareas]   t
    INNER JOIN [app].[tbHorarios] h ON t.Hor_Id = h.Hor_Id
    WHERE t.Tar_Id = @Tar_Id AND t.Tar_EsEliminado = 0;

    SELECT
        a.Alu_Id,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre, ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        )))                     AS Alu_NombreCompleto,
        p.Per_Imagen,
        e.Ent_Id,
        e.Ent_Entregado,
        e.Ent_FechaEntrega,
        e.Ent_Nota,
        e.Ent_Observacion,
        CASE WHEN e.Ent_Entregado = 1 THEN 1 ELSE 0 END AS TieneEntrega,
        CASE WHEN e.Ent_Nota IS NOT NULL THEN 1 ELSE 0 END AS TieneNota
    FROM [app].[tbAlumnos] a
    INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
    LEFT JOIN [app].[tbEntregasTarea] e
        ON  e.Alu_Id          = a.Alu_Id
        AND e.Tar_Id          = @Tar_Id
        AND e.Ent_EsEliminado = 0
    WHERE a.Sec_Id          = @Sec_Id
      AND a.AnioCursado     = @Anio
      AND p.Per_EsEliminado = 0
    ORDER BY p.Per_ApellidoPaterno, p.Per_PrimerNombre;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbEntregasTarea_Upsert
-- Registra/marca la entrega de un alumno para una tarea (UPSERT).
-- No toca la calificación (se hace vía PR_tbEntregasTarea_Update).
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbEntregasTarea_Upsert]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbEntregasTarea_Upsert]
GO
CREATE PROCEDURE [app].[PR_tbEntregasTarea_Upsert]
    @Tar_Id              INT,
    @Alu_Id              INT,
    @Ent_Entregado       BIT,
    @Ent_Observacion     NVARCHAR(500) = NULL,
    @UsuarioRegistra     INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExistingId INT = NULL;
    SELECT @ExistingId = Ent_Id
    FROM [app].[tbEntregasTarea]
    WHERE Tar_Id = @Tar_Id AND Alu_Id = @Alu_Id AND Ent_EsEliminado = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @ExistingId IS NOT NULL
        BEGIN
            UPDATE [app].[tbEntregasTarea]
            SET    Ent_Entregado       = @Ent_Entregado,
                   Ent_FechaEntrega    = CASE WHEN @Ent_Entregado = 1 THEN GETDATE() ELSE NULL END,
                   Ent_Observacion     = @Ent_Observacion,
                   Ent_UsuarioModifica = @UsuarioRegistra,
                   Ent_FechaModifica   = GETDATE()
            WHERE  Ent_Id = @ExistingId;

            COMMIT TRANSACTION;
            SELECT 1 AS CodeResult, @ExistingId AS Ent_Id, 'Entrega actualizada' AS Mensaje;
        END
        ELSE
        BEGIN
            INSERT INTO [app].[tbEntregasTarea]
                (Tar_Id, Alu_Id, Ent_Entregado, Ent_FechaEntrega, Ent_Observacion,
                 Ent_UsuarioRegistra, Ent_FechaRegistra)
            VALUES
                (@Tar_Id, @Alu_Id, @Ent_Entregado,
                 CASE WHEN @Ent_Entregado = 1 THEN GETDATE() ELSE NULL END,
                 @Ent_Observacion, @UsuarioRegistra, GETDATE());

            DECLARE @NewId INT = SCOPE_IDENTITY();
            COMMIT TRANSACTION;
            SELECT 1 AS CodeResult, @NewId AS Ent_Id, 'Entrega registrada' AS Mensaje;
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS CodeResult, 0 AS Ent_Id, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbEntregasTarea_Update
-- Califica una entrega existente (requiere Ent_Id, es decir que el
-- alumno ya tenga fila de entrega — usar primero el Upsert si no existe).
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbEntregasTarea_Update]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbEntregasTarea_Update]
GO
CREATE PROCEDURE [app].[PR_tbEntregasTarea_Update]
    @Ent_Id              INT,
    @Ent_Nota            DECIMAL(5,2),
    @Ent_Observacion     NVARCHAR(500) = NULL,
    @UsuarioModifica     INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [app].[tbEntregasTarea]
        SET    Ent_Nota            = @Ent_Nota,
               Ent_Observacion     = ISNULL(@Ent_Observacion, Ent_Observacion),
               Ent_UsuarioModifica = @UsuarioModifica,
               Ent_FechaModifica   = GETDATE()
        WHERE  Ent_Id = @Ent_Id AND Ent_EsEliminado = 0;

        COMMIT TRANSACTION;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS CodeResult;
    END CATCH
END
GO
