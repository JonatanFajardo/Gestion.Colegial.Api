-- =====================================================================
-- Script 034: Corrección SPs Fase 7
-- Problemas:
--   1. PR_Academico_ComparativoAnios y PR_KPIs_Academicos usan Est_Id=1
--      pero todos los alumnos 2026 tienen Est_Id=3 (Graduado).
--      Se elimina el filtro Est_Id — se cuenta por AnioCursado solamente.
-- Nota: PR_Academico_RendimientoPorSeccion no tiene este bug (SP funciona OK).
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- 1. PR_Academico_ComparativoAnios  (fix: quitar Est_Id=1)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_Academico_ComparativoAnios]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Academico_ComparativoAnios];
GO
CREATE PROCEDURE [app].[PR_Academico_ComparativoAnios]
    @AnioBase        INT,
    @AnioComparacion INT
AS
BEGIN
    SET NOCOUNT ON;

    WITH Base AS (
        SELECT
            c.Cur_Id,
            c.Cur_Nombre         AS Cur_Descripcion,
            COUNT(a.Alu_Id)      AS TotalAlumnos
        FROM [app].[tbAlumnos] a
        INNER JOIN [app].[tbCursos] c ON a.Cur_Id = c.Cur_Id
        WHERE a.AnioCursado = @AnioBase
        GROUP BY c.Cur_Id, c.Cur_Nombre
    ),
    Comp AS (
        SELECT
            c.Cur_Id,
            COUNT(a.Alu_Id)      AS TotalAlumnos
        FROM [app].[tbAlumnos] a
        INNER JOIN [app].[tbCursos] c ON a.Cur_Id = c.Cur_Id
        WHERE a.AnioCursado = @AnioComparacion
        GROUP BY c.Cur_Id, c.Cur_Nombre
    ),
    Todos AS (
        SELECT b2.Cur_Id, b2.Cur_Descripcion FROM Base b2
        UNION
        SELECT c3.Cur_Id, c3.Cur_Nombre AS Cur_Descripcion
        FROM Comp cp3
        INNER JOIN [app].[tbCursos] c3 ON cp3.Cur_Id = c3.Cur_Id
    )
    SELECT
        t.Cur_Descripcion,
        ISNULL(b.TotalAlumnos,  0)                                              AS TotalAnioBase,
        ISNULL(cp.TotalAlumnos, 0)                                              AS TotalAnioComparacion,
        ISNULL(cp.TotalAlumnos, 0) - ISNULL(b.TotalAlumnos, 0)                 AS Diferencia,
        CASE
            WHEN ISNULL(b.TotalAlumnos, 0) = 0 THEN NULL
            ELSE CAST(
                    (CAST(ISNULL(cp.TotalAlumnos, 0) AS FLOAT)
                     - CAST(ISNULL(b.TotalAlumnos,  0) AS FLOAT))
                    / CAST(b.TotalAlumnos AS FLOAT) * 100.0
                 AS DECIMAL(7,2))
        END                                                                     AS PorcentajeCambio
    FROM Todos t
    LEFT JOIN Base b  ON t.Cur_Id = b.Cur_Id
    LEFT JOIN Comp cp ON t.Cur_Id = cp.Cur_Id
    ORDER BY t.Cur_Descripcion;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- 2. PR_KPIs_Academicos  (fix: quitar Est_Id=1)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_KPIs_Academicos]') IS NOT NULL
    DROP PROCEDURE [app].[PR_KPIs_Academicos];
GO
CREATE PROCEDURE [app].[PR_KPIs_Academicos]
    @Anio INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalAlumnos INT;
    SELECT @TotalAlumnos = COUNT(*)
    FROM   [app].[tbAlumnos]
    WHERE  AnioCursado = @Anio;

    DECLARE @TotalDocentes INT;
    SELECT @TotalDocentes = COUNT(DISTINCT h.Emp_Id)
    FROM   [app].[tbHorarios] h
    WHERE  h.Hor_Año         = @Anio
      AND  h.Hor_EsEliminado = 0;

    DECLARE @PromedioGeneral DECIMAL(5,2);
    SELECT @PromedioGeneral = CAST(AVG(CAST(n.Not_Nota AS FLOAT)) AS DECIMAL(5,2))
    FROM   [app].[tbNotas] n
    WHERE  YEAR(n.Not_Año)   = @Anio
      AND  n.Not_EsEliminado = 0;

    DECLARE @PorcentajeAsistencia DECIMAL(5,2);
    SELECT @PorcentajeAsistencia =
        CASE
            WHEN COUNT(*) = 0 THEN NULL
            ELSE CAST(
                    SUM(CASE WHEN a.Asi_Estado IN ('P','T') THEN 1.0 ELSE 0.0 END)
                    / COUNT(*) * 100.0
                 AS DECIMAL(5,2))
        END
    FROM  [app].[tbAsistencia] a
    INNER JOIN [app].[tbHorarios] h ON a.Hor_Id = h.Hor_Id
    WHERE YEAR(a.Asi_Fecha)   = @Anio
      AND a.Asi_EsEliminado   = 0
      AND h.Hor_EsEliminado   = 0;

    SELECT
        @Anio                 AS Anio,
        @TotalAlumnos         AS TotalAlumnosActivos,
        @TotalDocentes        AS TotalDocentes,
        @PromedioGeneral      AS PromedioGeneralInstitucional,
        @PorcentajeAsistencia AS PorcentajeAsistencia;
END
GO

PRINT 'Script 034 completado: PR_KPIs_Academicos y PR_Academico_ComparativoAnios corregidos.';
GO
