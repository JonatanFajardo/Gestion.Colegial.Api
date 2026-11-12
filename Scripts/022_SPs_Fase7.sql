-- =====================================================================
-- Script 022: SPs Fase 7 — Reportes académicos y KPIs ejecutivos
-- Crea/reemplaza:
--   app.PR_Academico_ComparativoAnios    — matrícula comparada entre dos años
--   app.PR_Academico_RendimientoPorSeccion — promedio de notas por sección
--   app.PR_KPIs_Academicos               — resumen académico ejecutivo
--   finanza.PR_KPIs_Financieros          — resumen financiero ejecutivo
-- Convención: idempotente (DROP IF EXISTS + CREATE). Terminar con GO.
-- Notas de estructura:
--   tbAlumnos: Alu_Id, Per_Id, Cur_Id, Sec_Id, Cun_Id, Niv_Id, AnioCursado, Alu_EsEliminado
--   tbNotas:   Alu_Id, Sec_Id, Mat_Id, Sem_Id, Pac_Id, Not_Nota (decimal), Not_Año (date), Not_EsEliminado
--   tbHorarios: Hor_Id, Cur_Id, Sec_Id, Mat_Id, Emp_Id, Hor_Año, Hor_EsEliminado
--   tbAsistencia: Hor_Id, Alu_Id, Asi_Fecha (date), Asi_Estado CHAR(1) P/A/T/J, Asi_EsEliminado
--   finanza.tbPagos: Pag_Id, Alu_Id, Pag_FechaPago, Pag_MontoTotal, Pag_EsEliminado
--   finanza.tbCuentasCobrar: Cco_Id, Alu_Id, Cco_MontoPendiente, Cco_Mes, Cco_Anio, Cco_EsEliminado
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- Verificar existencia previa de los SPs
-- SELECT SCHEMA_NAME(schema_id)+'.'+name FROM sys.objects
-- WHERE type='P' AND name IN ('PR_Academico_ComparativoAnios',
--   'PR_Academico_RendimientoPorSeccion','PR_KPIs_Academicos','PR_KPIs_Financieros')
-- ──────────────────────────────────────────────────────────────────────

-- ──────────────────────────────────────────────────────────────────────
-- app.PR_Academico_ComparativoAnios
-- Compara la matrícula de alumnos activos entre dos años lectivos,
-- agrupada por curso (grado). Permite identificar crecimiento o caída.
-- Parámetros:
--   @AnioBase        INT — año de referencia (año anterior)
--   @AnioComparacion INT — año a comparar (año actual)
-- Retorna:
--   Cur_Descripcion, TotalAnioBase, TotalAnioComparacion,
--   Diferencia, PorcentajeCambio
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

    -- Conteo por curso para cada año
    WITH Base AS (
        SELECT
            c.Cur_Id,
            c.Cur_Nombre         AS Cur_Descripcion,
            COUNT(a.Alu_Id)      AS TotalAlumnos
        FROM [app].[tbAlumnos] a
        INNER JOIN [app].[tbCursos] c ON a.Cur_Id = c.Cur_Id
        WHERE a.AnioCursado    = @AnioBase
          AND a.Est_Id          = 1    -- Est_Id=1 = Activo
        GROUP BY c.Cur_Id, c.Cur_Nombre
    ),
    Comp AS (
        SELECT
            c.Cur_Id,
            COUNT(a.Alu_Id)      AS TotalAlumnos
        FROM [app].[tbAlumnos] a
        INNER JOIN [app].[tbCursos] c ON a.Cur_Id = c.Cur_Id
        WHERE a.AnioCursado    = @AnioComparacion
          AND a.Est_Id          = 1    -- Est_Id=1 = Activo
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
        ISNULL(b.TotalAlumnos, 0)                                           AS TotalAnioBase,
        ISNULL(cp.TotalAlumnos, 0)                                          AS TotalAnioComparacion,
        ISNULL(cp.TotalAlumnos, 0) - ISNULL(b.TotalAlumnos, 0)             AS Diferencia,
        CASE
            WHEN ISNULL(b.TotalAlumnos, 0) = 0 THEN NULL
            ELSE CAST(
                    (CAST(ISNULL(cp.TotalAlumnos, 0) AS FLOAT)
                     - CAST(ISNULL(b.TotalAlumnos, 0) AS FLOAT))
                    / CAST(b.TotalAlumnos AS FLOAT) * 100.0
                 AS DECIMAL(7,2))
        END                                                                 AS PorcentajeCambio
    FROM Todos t
    LEFT JOIN Base b  ON t.Cur_Id = b.Cur_Id
    LEFT JOIN Comp cp ON t.Cur_Id = cp.Cur_Id
    ORDER BY t.Cur_Descripcion;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- app.PR_Academico_RendimientoPorSeccion
-- Promedio de notas por sección y curso en un año lectivo dado.
-- Parámetros:
--   @Anio   INT       — año lectivo
--   @Par_Id INT NULL  — Pac_Id del parcial; NULL = todos los parciales
-- Retorna:
--   Sec_Descripcion, Cur_Descripcion, PromedioGeneral, TotalAlumnos
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_Academico_RendimientoPorSeccion]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Academico_RendimientoPorSeccion];
GO
CREATE PROCEDURE [app].[PR_Academico_RendimientoPorSeccion]
    @Anio   INT,
    @Par_Id INT = NULL   -- NULL = todos los parciales del año
AS
BEGIN
    SET NOCOUNT ON;

    -- Unimos notas con horario para obtener Cur_Id (el horario conecta notas con cursos)
    -- tbNotas tiene Sec_Id directamente; para el curso usamos tbHorarios
    SELECT
        s.Sec_Descripcion,
        c.Cur_Nombre                        AS Cur_Descripcion,
        CAST(AVG(CAST(n.Not_Nota AS FLOAT)) AS DECIMAL(5,2)) AS PromedioGeneral,
        COUNT(DISTINCT n.Alu_Id)            AS TotalAlumnos
    FROM [app].[tbNotas] n
    INNER JOIN [app].[tbSecciones] s ON n.Sec_Id = s.Sec_Id
    -- Obtener Cur_Id desde tbHorarios usando Sec_Id + año
    INNER JOIN (
        SELECT DISTINCT h.Sec_Id, h.Cur_Id
        FROM [app].[tbHorarios] h
        WHERE h.Hor_Año = @Anio
          AND h.Hor_EsEliminado = 0
    ) hc ON n.Sec_Id = hc.Sec_Id
    INNER JOIN [app].[tbCursos] c ON hc.Cur_Id = c.Cur_Id
    WHERE YEAR(n.Not_Año)   = @Anio
      AND n.Not_EsEliminado = 0
      AND (@Par_Id IS NULL OR n.Pac_Id = @Par_Id)
    GROUP BY s.Sec_Descripcion, c.Cur_Nombre
    ORDER BY c.Cur_Nombre, s.Sec_Descripcion;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- app.PR_KPIs_Academicos
-- Resumen académico ejecutivo para el año indicado.
-- Parámetros:
--   @Anio INT — año lectivo
-- Retorna (fila única):
--   TotalAlumnosActivos, TotalDocentes,
--   PromedioGeneralInstitucional, PorcentajeAsistencia
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_KPIs_Academicos]') IS NOT NULL
    DROP PROCEDURE [app].[PR_KPIs_Academicos];
GO
CREATE PROCEDURE [app].[PR_KPIs_Academicos]
    @Anio INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Alumnos activos en el año
    DECLARE @TotalAlumnos INT;
    SELECT @TotalAlumnos = COUNT(*)
    FROM [app].[tbAlumnos]
    WHERE AnioCursado    = @Anio
      AND Est_Id         = 1;    -- Est_Id=1 = Activo

    -- Docentes que tienen horarios en el año (activos)
    DECLARE @TotalDocentes INT;
    SELECT @TotalDocentes = COUNT(DISTINCT h.Emp_Id)
    FROM [app].[tbHorarios] h
    WHERE h.Hor_Año       = @Anio
      AND h.Hor_EsEliminado = 0;

    -- Promedio general institucional (todas las notas del año)
    DECLARE @PromedioGeneral DECIMAL(5,2);
    SELECT @PromedioGeneral = CAST(AVG(CAST(n.Not_Nota AS FLOAT)) AS DECIMAL(5,2))
    FROM [app].[tbNotas] n
    WHERE YEAR(n.Not_Año)   = @Anio
      AND n.Not_EsEliminado = 0;

    -- Porcentaje de asistencia (P=Presente, T=Tardanza cuentan como asistidos)
    DECLARE @PorcentajeAsistencia DECIMAL(5,2);
    SELECT @PorcentajeAsistencia =
        CASE
            WHEN COUNT(*) = 0 THEN NULL
            ELSE CAST(
                    SUM(CASE WHEN a.Asi_Estado IN ('P','T') THEN 1.0 ELSE 0.0 END)
                    / COUNT(*) * 100.0
                 AS DECIMAL(5,2))
        END
    FROM [app].[tbAsistencia] a
    INNER JOIN [app].[tbHorarios] h ON a.Hor_Id = h.Hor_Id
    WHERE YEAR(a.Asi_Fecha)   = @Anio
      AND a.Asi_EsEliminado   = 0
      AND h.Hor_EsEliminado   = 0;

    SELECT
        @Anio                   AS Anio,
        @TotalAlumnos           AS TotalAlumnosActivos,
        @TotalDocentes          AS TotalDocentes,
        @PromedioGeneral        AS PromedioGeneralInstitucional,
        @PorcentajeAsistencia   AS PorcentajeAsistencia;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- finanza.PR_KPIs_Financieros
-- Resumen financiero ejecutivo para el año (y mes opcional) indicados.
-- Parámetros:
--   @Anio INT       — año fiscal
--   @Mes  INT NULL  — mes (1-12); NULL = todo el año
-- Retorna (fila única):
--   TotalCobrado, TotalPendiente, TotalMorosos, PorcentajeRecuperacion
-- Estructura:
--   finanza.tbPagos: Pag_MontoTotal, Pag_FechaPago, Pag_EsEliminado
--   finanza.tbCuentasCobrar: Cco_MontoPendiente, Cco_Mes, Cco_Anio, Alu_Id, Cco_EsEliminado
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[finanza].[PR_KPIs_Financieros]') IS NOT NULL
    DROP PROCEDURE [finanza].[PR_KPIs_Financieros];
GO
CREATE PROCEDURE [finanza].[PR_KPIs_Financieros]
    @Anio INT,
    @Mes  INT = NULL   -- NULL = todo el año
AS
BEGIN
    SET NOCOUNT ON;

    -- Total cobrado: suma de pagos efectuados en el periodo
    DECLARE @TotalCobrado DECIMAL(14,2);
    SELECT @TotalCobrado = ISNULL(SUM(p.Pag_MontoTotal), 0)
    FROM [finanza].[tbPagos] p
    WHERE YEAR(p.Pag_FechaPago) = @Anio
      AND p.Pag_EsEliminado     = 0
      AND (@Mes IS NULL OR MONTH(p.Pag_FechaPago) = @Mes);

    -- Total pendiente: saldo por cobrar en cuentas del periodo
    DECLARE @TotalPendiente DECIMAL(14,2);
    SELECT @TotalPendiente = ISNULL(SUM(cc.Cco_MontoPendiente), 0)
    FROM [finanza].[tbCuentasCobrar] cc
    WHERE cc.Cco_Anio        = @Anio
      AND cc.Cco_EsEliminado = 0
      AND cc.Cco_MontoPendiente > 0
      AND (@Mes IS NULL OR cc.Cco_Mes = @Mes);

    -- Total morosos: alumnos distintos que tienen cuentas pendientes vencidas
    DECLARE @TotalMorosos INT;
    SELECT @TotalMorosos = COUNT(DISTINCT cc.Alu_Id)
    FROM [finanza].[tbCuentasCobrar] cc
    WHERE cc.Cco_Anio             = @Anio
      AND cc.Cco_EsEliminado      = 0
      AND cc.Cco_MontoPendiente   > 0
      -- Considera morosa la cuenta cuyo mes ya pasó respecto al mes actual
      AND (cc.Cco_Anio < YEAR(GETDATE())
           OR (cc.Cco_Anio = YEAR(GETDATE()) AND cc.Cco_Mes < MONTH(GETDATE())))
      AND (@Mes IS NULL OR cc.Cco_Mes <= @Mes);

    -- Porcentaje de recuperación: cobrado / (cobrado + pendiente) * 100
    DECLARE @PorcentajeRecuperacion DECIMAL(5,2);
    SET @PorcentajeRecuperacion =
        CASE
            WHEN (@TotalCobrado + @TotalPendiente) = 0 THEN NULL
            ELSE CAST(@TotalCobrado / (@TotalCobrado + @TotalPendiente) * 100.0 AS DECIMAL(5,2))
        END;

    SELECT
        @Anio                       AS Anio,
        @Mes                        AS Mes,
        @TotalCobrado               AS TotalCobrado,
        @TotalPendiente             AS TotalPendiente,
        @TotalMorosos               AS TotalMorosos,
        @PorcentajeRecuperacion     AS PorcentajeRecuperacion;
END
GO
