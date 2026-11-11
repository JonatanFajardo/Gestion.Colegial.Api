-- =====================================================================
-- Script 051: Módulo Matrículas
-- Contexto: app.tbMatriculas ya existe (836 filas migradas, año 2026).
--           Este script solo crea los Stored Procedures CRUD.
-- Crea:
--   app.PR_tbMatriculas_List    — lista matrículas de un año lectivo
--                                  con nombre de alumno, grado, sección
--                                  y estado (JOINs a tbAlumnos/tbPersonas/
--                                  tbCursosNiveles/tbSecciones/tbEstados).
--   app.PR_tbMatriculas_Find    — obtiene una matrícula por Matri_Id.
--   app.PR_tbMatriculas_Insert  — registra una matrícula, devuelve NewId.
--   app.PR_tbMatriculas_Update  — modifica una matrícula existente.
--   app.PR_tbMatriculas_Delete  — baja lógica (Matri_EsEliminado = 1).
-- Convención: idempotente (DROP IF EXISTS + CREATE).
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbMatriculas_List
-- Lista las matrículas de un año lectivo. Usa LEFT JOIN hacia
-- tbCursosNiveles/tbSecciones/tbEstados porque Cun_Id/Sec_Id/Est_Id son
-- opcionales en tbMatriculas (alumno matriculado sin grado/sección/estado
-- asignado todavía).
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbMatriculas_List]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbMatriculas_List]
GO
CREATE PROCEDURE [app].[PR_tbMatriculas_List]
    @Anio INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.Matri_Id,
        m.Alu_Id,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre, ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        )))                     AS Alu_Nombre,
        m.Matri_Anio,
        m.Cun_Id,
        cn.Cun_Descripcion,
        m.Sec_Id,
        s.Sec_Descripcion,
        m.Est_Id,
        e.Est_Descripcion,
        m.Matri_FechaInicio,
        m.Matri_FechaFin
    FROM        [app].[tbMatriculas]    m
    INNER JOIN  [app].[tbAlumnos]       a  ON m.Alu_Id = a.Alu_Id
    INNER JOIN  [app].[tbPersonas]      p  ON a.Per_Id = p.Per_Id
    LEFT JOIN   [app].[tbCursosNiveles] cn ON m.Cun_Id = cn.Cun_Id
    LEFT JOIN   [app].[tbSecciones]     s  ON m.Sec_Id = s.Sec_Id
    LEFT JOIN   [app].[tbEstados]       e  ON m.Est_Id = e.Est_Id
    WHERE       m.Matri_Anio = @Anio
            AND m.Matri_EsEliminado = 0
    ORDER BY    p.Per_ApellidoPaterno, p.Per_PrimerNombre;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbMatriculas_Find
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbMatriculas_Find]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbMatriculas_Find]
GO
CREATE PROCEDURE [app].[PR_tbMatriculas_Find]
    @Matri_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Matri_Id,
        Alu_Id,
        Matri_Anio,
        Cun_Id,
        Sec_Id,
        Matri_FechaInicio,
        Matri_FechaFin,
        Est_Id,
        Matri_EsActivo
    FROM    [app].[tbMatriculas]
    WHERE   Matri_Id = @Matri_Id
        AND Matri_EsEliminado = 0;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbMatriculas_Insert
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbMatriculas_Insert]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbMatriculas_Insert]
GO
CREATE PROCEDURE [app].[PR_tbMatriculas_Insert]
    @Alu_Id                INT,
    @Matri_Anio             INT,
    @Cun_Id                 INT = NULL,
    @Sec_Id                 INT = NULL,
    @Matri_FechaInicio      DATE,
    @Matri_FechaFin         DATE = NULL,
    @Est_Id                 INT = NULL,
    @Matri_UsuarioRegistra  INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [app].[tbMatriculas]
        (Alu_Id, Matri_Anio, Cun_Id, Sec_Id, Matri_FechaInicio, Matri_FechaFin, Est_Id,
         Matri_EsActivo, Matri_EsEliminado, Matri_UsuarioRegistra, Matri_FechaRegistra)
    VALUES
        (@Alu_Id, @Matri_Anio, @Cun_Id, @Sec_Id, @Matri_FechaInicio, @Matri_FechaFin, @Est_Id,
         1, 0, @Matri_UsuarioRegistra, GETDATE());

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbMatriculas_Update
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbMatriculas_Update]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbMatriculas_Update]
GO
CREATE PROCEDURE [app].[PR_tbMatriculas_Update]
    @Matri_Id               INT,
    @Alu_Id                 INT,
    @Matri_Anio             INT,
    @Cun_Id                 INT = NULL,
    @Sec_Id                 INT = NULL,
    @Matri_FechaInicio      DATE,
    @Matri_FechaFin         DATE = NULL,
    @Est_Id                 INT = NULL,
    @Matri_UsuarioModifica  INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE  [app].[tbMatriculas]
    SET     Alu_Id                = @Alu_Id,
            Matri_Anio            = @Matri_Anio,
            Cun_Id                = @Cun_Id,
            Sec_Id                = @Sec_Id,
            Matri_FechaInicio     = @Matri_FechaInicio,
            Matri_FechaFin        = @Matri_FechaFin,
            Est_Id                = @Est_Id,
            Matri_UsuarioModifica = @Matri_UsuarioModifica,
            Matri_FechaModifica   = GETDATE()
    WHERE   Matri_Id = @Matri_Id;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbMatriculas_Delete
-- Baja lógica — NUNCA borrar físico.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbMatriculas_Delete]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbMatriculas_Delete]
GO
CREATE PROCEDURE [app].[PR_tbMatriculas_Delete]
    @Matri_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE  [app].[tbMatriculas]
    SET     Matri_EsEliminado = 1
    WHERE   Matri_Id = @Matri_Id;
END
GO
