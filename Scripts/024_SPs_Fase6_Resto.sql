-- =====================================================================
-- Script 024: SPs Fase 6 Resto — Flujo de Caja, Estado de Resultados,
--             Análisis de Ingresos, Organigrama
-- Crea/reemplaza (idempotente):
--   finanza.PR_Finanza_FlujoCaja
--   finanza.PR_Finanza_EstadoResultados
--   finanza.PR_Finanza_AnalisisIngresos
--   app.PR_Organigrama_GetTree
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- finanza.PR_Finanza_FlujoCaja
-- Flujo de caja mensual del año indicado.
-- Retorna una fila por mes: Mes, NombreMes, TotalIngresos (suma pagos),
--   TotalPendiente (cuentas por cobrar pendientes), SaldoNeto.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[finanza].[PR_Finanza_FlujoCaja]') IS NOT NULL
    DROP PROCEDURE [finanza].[PR_Finanza_FlujoCaja];
GO
CREATE PROCEDURE [finanza].[PR_Finanza_FlujoCaja]
    @Anio INT
AS
BEGIN
    SET NOCOUNT ON;

    WITH Meses AS (
        SELECT 1 AS Mes, N'Enero'      AS NombreMes UNION ALL
        SELECT 2,        N'Febrero'              UNION ALL
        SELECT 3,        N'Marzo'                UNION ALL
        SELECT 4,        N'Abril'                UNION ALL
        SELECT 5,        N'Mayo'                 UNION ALL
        SELECT 6,        N'Junio'                UNION ALL
        SELECT 7,        N'Julio'                UNION ALL
        SELECT 8,        N'Agosto'               UNION ALL
        SELECT 9,        N'Septiembre'           UNION ALL
        SELECT 10,       N'Octubre'              UNION ALL
        SELECT 11,       N'Noviembre'            UNION ALL
        SELECT 12,       N'Diciembre'
    ),
    Ingresos AS (
        SELECT
            MONTH(p.Pag_FechaPago)          AS Mes,
            ISNULL(SUM(p.Pag_MontoTotal), 0) AS TotalIngresos
        FROM [finanza].[tbPagos] p
        WHERE YEAR(p.Pag_FechaPago) = @Anio
          AND p.Pag_EsEliminado = 0
        GROUP BY MONTH(p.Pag_FechaPago)
    ),
    Pendientes AS (
        SELECT
            c.Cco_Mes                               AS Mes,
            ISNULL(SUM(c.Cco_MontoPendiente), 0)    AS TotalPendiente
        FROM [finanza].[tbCuentasCobrar] c
        WHERE c.Cco_Anio = @Anio
          AND c.Cco_EsEliminado = 0
          AND c.Cco_MontoPendiente > 0
        GROUP BY c.Cco_Mes
    )
    SELECT
        m.Mes,
        m.NombreMes,
        ISNULL(i.TotalIngresos,  0)                           AS TotalIngresos,
        ISNULL(p.TotalPendiente, 0)                           AS TotalPendiente,
        ISNULL(i.TotalIngresos,  0) - ISNULL(p.TotalPendiente, 0) AS SaldoNeto
    FROM Meses m
    LEFT JOIN Ingresos  i ON m.Mes = i.Mes
    LEFT JOIN Pendientes p ON m.Mes = p.Mes
    ORDER BY m.Mes;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- finanza.PR_Finanza_EstadoResultados
-- Estado de resultados mensual (@Anio, @Mes).
-- Retorna filas: Concepto, Monto
--   "Total Cobrado", "Total Descuentos Aplicados", "Ingresos Netos",
--   "Cuentas Pendientes", "Total Morosos"
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[finanza].[PR_Finanza_EstadoResultados]') IS NOT NULL
    DROP PROCEDURE [finanza].[PR_Finanza_EstadoResultados];
GO
CREATE PROCEDURE [finanza].[PR_Finanza_EstadoResultados]
    @Anio INT,
    @Mes  INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalCobrado      DECIMAL(18,2);
    DECLARE @TotalDescuentos   DECIMAL(18,2);
    DECLARE @IngresosNetos     DECIMAL(18,2);
    DECLARE @CuentasPendientes DECIMAL(18,2);
    DECLARE @TotalMorosos      DECIMAL(18,2);

    -- Total cobrado (pagos en el mes)
    SELECT @TotalCobrado = ISNULL(SUM(p.Pag_MontoTotal), 0)
    FROM [finanza].[tbPagos] p
    WHERE YEAR(p.Pag_FechaPago) = @Anio
      AND MONTH(p.Pag_FechaPago) = @Mes
      AND p.Pag_EsEliminado = 0;

    -- Total descuentos aplicados (en cuentas del mes)
    SELECT @TotalDescuentos = ISNULL(SUM(da.Dap_MontoAplicado), 0)
    FROM [finanza].[tbDescuentosAplicados] da
    INNER JOIN [finanza].[tbCuentasCobrar] c ON da.Cco_Id = c.Cco_Id
    WHERE c.Cco_Anio = @Anio
      AND c.Cco_Mes  = @Mes
      AND c.Cco_EsEliminado  = 0
      AND da.Dap_EsEliminado = 0;

    -- Ingresos netos = cobrado - descuentos
    SET @IngresosNetos = @TotalCobrado - @TotalDescuentos;

    -- Cuentas pendientes del mes
    SELECT @CuentasPendientes = ISNULL(SUM(c.Cco_MontoPendiente), 0)
    FROM [finanza].[tbCuentasCobrar] c
    WHERE c.Cco_Anio = @Anio
      AND c.Cco_Mes  = @Mes
      AND c.Cco_EsEliminado = 0
      AND c.Cco_MontoPendiente > 0;

    -- Total morosos (cuentas vencidas con saldo, en el mes)
    SELECT @TotalMorosos = ISNULL(SUM(c.Cco_MontoPendiente), 0)
    FROM [finanza].[tbCuentasCobrar] c
    WHERE c.Cco_Anio = @Anio
      AND c.Cco_Mes  = @Mes
      AND c.Cco_EsEliminado = 0
      AND c.Cco_MontoPendiente > 0
      AND c.Cco_FechaVencimiento < GETDATE();

    SELECT 'Total Cobrado'              AS Concepto, @TotalCobrado      AS Monto UNION ALL
    SELECT 'Total Descuentos Aplicados',              @TotalDescuentos            UNION ALL
    SELECT 'Ingresos Netos',                          @IngresosNetos              UNION ALL
    SELECT 'Cuentas Pendientes',                      @CuentasPendientes          UNION ALL
    SELECT 'Total Morosos',                           @TotalMorosos;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- finanza.PR_Finanza_AnalisisIngresos
-- Análisis de ingresos vs pendientes por concepto de pago, en el año.
-- Retorna: ConceptoPago, TotalCobrado, TotalPendiente, PorcentajeCobrado
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[finanza].[PR_Finanza_AnalisisIngresos]') IS NOT NULL
    DROP PROCEDURE [finanza].[PR_Finanza_AnalisisIngresos];
GO
CREATE PROCEDURE [finanza].[PR_Finanza_AnalisisIngresos]
    @Anio INT
AS
BEGIN
    SET NOCOUNT ON;

    WITH CuentasPorConcepto AS (
        SELECT
            cp.Cpa_Descripcion                                   AS ConceptoPago,
            ISNULL(SUM(c.Cco_MontoOriginal - c.Cco_MontoPendiente), 0) AS TotalCobrado,
            ISNULL(SUM(c.Cco_MontoPendiente), 0)                 AS TotalPendiente
        FROM [finanza].[tbCuentasCobrar] c
        INNER JOIN [finanza].[tbConceptosPago] cp ON c.Cpa_Id = cp.Cpa_Id
        WHERE c.Cco_Anio = @Anio
          AND c.Cco_EsEliminado = 0
          AND cp.Cpa_EsEliminado = 0
        GROUP BY cp.Cpa_Descripcion
    )
    SELECT
        ConceptoPago,
        TotalCobrado,
        TotalPendiente,
        CASE
            WHEN (TotalCobrado + TotalPendiente) = 0 THEN 0
            ELSE CAST(TotalCobrado * 100.0 / (TotalCobrado + TotalPendiente) AS DECIMAL(5,2))
        END AS PorcentajeCobrado
    FROM CuentasPorConcepto
    ORDER BY TotalCobrado DESC;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- app.PR_Organigrama_GetTree
-- Retorna empleados con su estructura jerárquica.
-- Emp_Id, Emp_NombreCompleto, Emp_Cargo, Emp_IdSupervisor, NombreSupervisor
-- Nota: app.tbEmpleados no tiene campo de supervisor en la estructura
--       actual; se retorna NULL para mantener la firma y permitir
--       extensión futura cuando se agregue la FK.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_Organigrama_GetTree]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Organigrama_GetTree];
GO
CREATE PROCEDURE [app].[PR_Organigrama_GetTree]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.Emp_Id,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre,    ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        )))                             AS Emp_NombreCompleto,
        c.Car_Descripcion               AS Emp_Cargo,
        e.Dep_Id                        AS Emp_IdDepartamento,
        d.Nombre                        AS NombreDepartamento,
        NULL                            AS Emp_IdSupervisor,
        NULL                            AS NombreSupervisor
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas]              p ON e.Per_Id = p.Per_Id
    LEFT  JOIN [app].[tbCargos]                c ON e.Car_Id = c.Car_Id
    LEFT  JOIN [app].[tbDepartamentoEmpleados] d ON e.Dep_Id = d.Dep_Id
    WHERE p.Per_EsEliminado = 0
    ORDER BY c.Car_Descripcion, Emp_NombreCompleto;
END
GO
