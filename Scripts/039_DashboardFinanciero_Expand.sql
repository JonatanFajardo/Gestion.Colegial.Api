-- 039_DashboardFinanciero_Expand.sql
-- Expande PR_DashboardFinanciero_Resumen a 10 result sets
-- Tablas: finanza.tbPagos, tbPagosDetalle, tbCuentasCobrar, tbFormasPago,
--         tbConceptosPago, tbEstadosPago, app.tbAlumnos, tbPersonas, tbCursos

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_DashboardFinanciero_Resumen]') AND type = 'P')
    DROP PROCEDURE [app].[PR_DashboardFinanciero_Resumen];
GO
CREATE PROCEDURE [app].[PR_DashboardFinanciero_Resumen]
    @Anio INT = NULL,
    @Mes  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());
    IF @Mes  IS NULL SET @Mes  = MONTH(GETDATE());

    DECLARE @Hoy           DATE = CAST(GETDATE() AS DATE);
    DECLARE @PrimerDiaMes  DATE = DATEFROMPARTS(@Anio, @Mes, 1);
    DECLARE @UltimoDiaMes  DATE = EOMONTH(@PrimerDiaMes);
    DECLARE @Hace12MesIni  DATE = DATEADD(MONTH, -11, DATEFROMPARTS(@Anio, @Mes, 1));
    DECLARE @ProximoSemana DATE = DATEADD(DAY, 7, @Hoy);

    -- ── RS1: KPIs Financieros ────────────────────────────────────────────
    DECLARE @TotalFacturadoMes  DECIMAL(18,2) = ISNULL((SELECT SUM(Cco_MontoTotal)
                                                        FROM finanza.tbCuentasCobrar
                                                        WHERE Cco_EsEliminado = 0
                                                          AND Cco_Anio = @Anio AND Cco_Mes = @Mes), 0);
    DECLARE @TotalCobradoMes    DECIMAL(18,2) = ISNULL((SELECT SUM(Pag_MontoTotal)
                                                        FROM finanza.tbPagos
                                                        WHERE Pag_EsEliminado = 0
                                                          AND YEAR(Pag_FechaPago) = @Anio
                                                          AND MONTH(Pag_FechaPago) = @Mes), 0);
    DECLARE @TotalPendiente     DECIMAL(18,2) = ISNULL((SELECT SUM(Cco_MontoPendiente)
                                                        FROM finanza.tbCuentasCobrar
                                                        WHERE Cco_EsEliminado = 0
                                                          AND Cco_MontoPendiente > 0), 0);
    DECLARE @TotalMora          DECIMAL(18,2) = ISNULL((SELECT SUM(Cco_MontoMora)
                                                        FROM finanza.tbCuentasCobrar
                                                        WHERE Cco_EsEliminado = 0
                                                          AND Cco_MontoMora > 0), 0);
    DECLARE @CantidadPagosMes   INT = ISNULL((SELECT COUNT(*) FROM finanza.tbPagos
                                              WHERE Pag_EsEliminado = 0
                                                AND YEAR(Pag_FechaPago) = @Anio
                                                AND MONTH(Pag_FechaPago) = @Mes), 0);
    DECLARE @AlumnosConPagos    INT = ISNULL((SELECT COUNT(DISTINCT Alu_Id) FROM finanza.tbPagos
                                              WHERE Pag_EsEliminado = 0
                                                AND YEAR(Pag_FechaPago) = @Anio
                                                AND MONTH(Pag_FechaPago) = @Mes), 0);
    DECLARE @AlumnosMorosos     INT = ISNULL((SELECT COUNT(DISTINCT Alu_Id) FROM finanza.tbCuentasCobrar
                                              WHERE Cco_EsEliminado = 0
                                                AND Cco_FechaVencimiento < @Hoy
                                                AND Cco_MontoPendiente > 0), 0);
    DECLARE @CuentasActivas     INT = ISNULL((SELECT COUNT(*) FROM finanza.tbCuentasCobrar
                                              WHERE Cco_EsEliminado = 0
                                                AND Cco_MontoPendiente > 0), 0);

    SELECT
        @TotalFacturadoMes AS TotalFacturadoMes,
        @TotalCobradoMes   AS TotalCobradoMes,
        @TotalPendiente    AS TotalPendiente,
        @TotalMora         AS TotalMora,
        CASE WHEN @TotalFacturadoMes > 0
             THEN CAST((@TotalCobradoMes * 100.0 / @TotalFacturadoMes) AS DECIMAL(10,2))
             ELSE 0 END AS PorcentajeCobranza,
        @CantidadPagosMes  AS CantidadPagosMes,
        CASE WHEN @CantidadPagosMes > 0
             THEN CAST(@TotalCobradoMes / @CantidadPagosMes AS DECIMAL(18,2))
             ELSE 0 END AS TicketPromedioMes,
        @AlumnosConPagos   AS AlumnosConPagos,
        @AlumnosMorosos    AS AlumnosMorosos,
        @CuentasActivas    AS CuentasActivas;

    -- ── RS2: Ingresos Mensuales (últimos 12 meses) ───────────────────────
    ;WITH Meses AS (
        SELECT TOP 12
            DATEADD(MONTH, -1 * (ROW_NUMBER() OVER (ORDER BY (SELECT 1)) - 1),
                    DATEFROMPARTS(@Anio, @Mes, 1)) AS Fecha
        FROM sys.columns
    )
    SELECT
        MONTH(m.Fecha) AS Mes,
        YEAR(m.Fecha)  AS Anio,
        UPPER(LEFT(DATENAME(MONTH, m.Fecha), 3)) + ' ' + RIGHT(CAST(YEAR(m.Fecha) AS VARCHAR), 2) AS EtiquetaMes,
        ISNULL((SELECT SUM(Cco_MontoTotal) FROM finanza.tbCuentasCobrar
                WHERE Cco_EsEliminado = 0
                  AND Cco_Anio = YEAR(m.Fecha) AND Cco_Mes = MONTH(m.Fecha)), 0) AS Facturado,
        ISNULL((SELECT SUM(Pag_MontoTotal) FROM finanza.tbPagos
                WHERE Pag_EsEliminado = 0
                  AND YEAR(Pag_FechaPago) = YEAR(m.Fecha)
                  AND MONTH(Pag_FechaPago) = MONTH(m.Fecha)), 0) AS Cobrado,
        ISNULL((SELECT SUM(Cco_MontoPendiente) FROM finanza.tbCuentasCobrar
                WHERE Cco_EsEliminado = 0
                  AND Cco_Anio = YEAR(m.Fecha) AND Cco_Mes = MONTH(m.Fecha)), 0) AS Pendiente
    FROM Meses m
    ORDER BY YEAR(m.Fecha), MONTH(m.Fecha);

    -- ── RS3: Cobros por Forma de Pago (mes actual) ───────────────────────
    SELECT
        f.Fpa_Descripcion,
        ISNULL(SUM(p.Pag_MontoTotal), 0) AS Total,
        COUNT(p.Pag_Id) AS Cantidad
    FROM finanza.tbFormasPago f
    LEFT JOIN finanza.tbPagos p ON p.Fpa_Id = f.Fpa_Id
        AND p.Pag_EsEliminado = 0
        AND YEAR(p.Pag_FechaPago) = @Anio
        AND MONTH(p.Pag_FechaPago) = @Mes
    WHERE f.Fpa_EsEliminado = 0 AND f.Fpa_EsActivo = 1
    GROUP BY f.Fpa_Descripcion
    HAVING COUNT(p.Pag_Id) > 0
    ORDER BY Total DESC;

    -- ── RS4: Morosidad por Concepto ──────────────────────────────────────
    SELECT
        cp.Cpa_Descripcion,
        COUNT(c.Cco_Id) AS CuentasMorosas,
        ISNULL(SUM(c.Cco_MontoPendiente), 0) AS MontoMoroso
    FROM finanza.tbConceptosPago cp
    INNER JOIN finanza.tbCuentasCobrar c ON c.Cpa_Id = cp.Cpa_Id
    WHERE c.Cco_EsEliminado = 0
      AND c.Cco_FechaVencimiento < @Hoy
      AND c.Cco_MontoPendiente > 0
    GROUP BY cp.Cpa_Descripcion
    ORDER BY MontoMoroso DESC;

    -- ── RS5: Top 10 Alumnos Morosos ──────────────────────────────────────
    SELECT TOP 10
        a.Alu_Id,
        LTRIM(RTRIM(CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno))) AS NombreAlumno,
        ISNULL(cu.Cur_Nombre, '—') AS Curso,
        SUM(c.Cco_MontoPendiente) AS MontoMoroso,
        COUNT(c.Cco_Id) AS CuentasVencidas,
        DATEDIFF(DAY, MIN(c.Cco_FechaVencimiento), @Hoy) AS DiasVencido,
        p.Per_Imagen
    FROM finanza.tbCuentasCobrar c
    INNER JOIN app.tbAlumnos  a  ON a.Alu_Id = c.Alu_Id
    INNER JOIN app.tbPersonas p  ON p.Per_Id = a.Per_Id
    LEFT  JOIN app.tbCursos   cu ON cu.Cur_Id = a.Cur_Id
    WHERE c.Cco_EsEliminado = 0
      AND c.Cco_FechaVencimiento < @Hoy
      AND c.Cco_MontoPendiente > 0
    GROUP BY a.Alu_Id, p.Per_PrimerNombre, p.Per_ApellidoPaterno, cu.Cur_Nombre, p.Per_Imagen
    ORDER BY MontoMoroso DESC;

    -- ── RS6: Cobros por Día (mes seleccionado) ───────────────────────────
    ;WITH Dias AS (
        SELECT @PrimerDiaMes AS Fecha
        UNION ALL
        SELECT DATEADD(DAY, 1, Fecha) FROM Dias WHERE Fecha < @UltimoDiaMes
    )
    SELECT
        DAY(d.Fecha) AS Dia,
        d.Fecha,
        ISNULL((SELECT SUM(Pag_MontoTotal) FROM finanza.tbPagos
                WHERE Pag_EsEliminado = 0
                  AND CAST(Pag_FechaPago AS DATE) = d.Fecha), 0) AS Total,
        ISNULL((SELECT COUNT(*) FROM finanza.tbPagos
                WHERE Pag_EsEliminado = 0
                  AND CAST(Pag_FechaPago AS DATE) = d.Fecha), 0) AS Cantidad
    FROM Dias d
    ORDER BY d.Fecha
    OPTION (MAXRECURSION 35);

    -- ── RS7: Estado de Cartera (Cobrado / Pendiente / Mora) ──────────────
    DECLARE @Cobrado DECIMAL(18,2) = ISNULL((SELECT SUM(Cco_MontoTotal - Cco_MontoPendiente)
                                              FROM finanza.tbCuentasCobrar
                                              WHERE Cco_EsEliminado = 0), 0);
    DECLARE @Pendiente DECIMAL(18,2) = ISNULL((SELECT SUM(Cco_MontoPendiente - ISNULL(Cco_MontoMora,0))
                                                FROM finanza.tbCuentasCobrar
                                                WHERE Cco_EsEliminado = 0
                                                  AND Cco_FechaVencimiento >= @Hoy
                                                  AND Cco_MontoPendiente > 0), 0);
    DECLARE @MoraTotal DECIMAL(18,2) = ISNULL((SELECT SUM(Cco_MontoPendiente)
                                                FROM finanza.tbCuentasCobrar
                                                WHERE Cco_EsEliminado = 0
                                                  AND Cco_FechaVencimiento < @Hoy
                                                  AND Cco_MontoPendiente > 0), 0);
    DECLARE @TotalCartera DECIMAL(18,2) = @Cobrado + @Pendiente + @MoraTotal;

    SELECT Estado, Total, Porcentaje, Orden FROM (
        SELECT N'Cobrado'   AS Estado, @Cobrado   AS Total,
               CASE WHEN @TotalCartera > 0 THEN CAST(@Cobrado*100.0/@TotalCartera AS DECIMAL(10,2)) ELSE 0 END AS Porcentaje, 1 AS Orden
        UNION ALL
        SELECT N'Pendiente', @Pendiente,
               CASE WHEN @TotalCartera > 0 THEN CAST(@Pendiente*100.0/@TotalCartera AS DECIMAL(10,2)) ELSE 0 END, 2
        UNION ALL
        SELECT N'Mora', @MoraTotal,
               CASE WHEN @TotalCartera > 0 THEN CAST(@MoraTotal*100.0/@TotalCartera AS DECIMAL(10,2)) ELSE 0 END, 3
    ) x
    ORDER BY Orden;

    -- ── RS8: Cuentas por Vencer (próximos 7 días, top 15) ────────────────
    SELECT TOP 15
        c.Cco_Id,
        LTRIM(RTRIM(CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno))) AS NombreAlumno,
        cp.Cpa_Descripcion,
        c.Cco_FechaVencimiento,
        c.Cco_MontoPendiente,
        DATEDIFF(DAY, @Hoy, c.Cco_FechaVencimiento) AS DiasParaVencer
    FROM finanza.tbCuentasCobrar c
    INNER JOIN app.tbAlumnos        a  ON a.Alu_Id  = c.Alu_Id
    INNER JOIN app.tbPersonas       p  ON p.Per_Id  = a.Per_Id
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = c.Cpa_Id
    WHERE c.Cco_EsEliminado = 0
      AND c.Cco_MontoPendiente > 0
      AND c.Cco_FechaVencimiento BETWEEN @Hoy AND @ProximoSemana
    ORDER BY c.Cco_FechaVencimiento ASC, c.Cco_MontoPendiente DESC;

    -- ── RS9: Cobros por Concepto (top 10 del mes) ────────────────────────
    SELECT TOP 10
        cp.Cpa_Descripcion,
        ISNULL(SUM(pd.Pde_MontoAplicado), 0) AS Total,
        COUNT(DISTINCT pd.Pag_Id) AS Cantidad
    FROM finanza.tbConceptosPago cp
    INNER JOIN finanza.tbCuentasCobrar cc ON cc.Cpa_Id = cp.Cpa_Id
    INNER JOIN finanza.tbPagosDetalle  pd ON pd.Cco_Id = cc.Cco_Id AND pd.Pde_EsEliminado = 0
    INNER JOIN finanza.tbPagos          p  ON p.Pag_Id  = pd.Pag_Id AND p.Pag_EsEliminado  = 0
    WHERE YEAR(p.Pag_FechaPago) = @Anio
      AND MONTH(p.Pag_FechaPago) = @Mes
    GROUP BY cp.Cpa_Descripcion
    ORDER BY Total DESC;

    -- ── RS10: Alertas Dinámicas ──────────────────────────────────────────
    SELECT TOP 10 Mensaje, Tipo, Urgencia, Orden FROM (

        -- Mora total alta
        SELECT
            N'Cartera en mora: Q ' + FORMAT(@MoraTotal, 'N2') AS Mensaje,
            N'mora' AS Tipo, N'alta' AS Urgencia, 1 AS Orden
        WHERE @MoraTotal > 0

        UNION ALL

        -- % cobranza bajo
        SELECT
            N'Cobranza del mes: ' + FORMAT(
                CASE WHEN @TotalFacturadoMes > 0
                     THEN (@TotalCobradoMes * 100.0 / @TotalFacturadoMes) ELSE 0 END, 'N1') + N'%' AS Mensaje,
            N'cobranza' AS Tipo,
            CASE WHEN @TotalFacturadoMes > 0 AND (@TotalCobradoMes * 100.0 / @TotalFacturadoMes) < 50 THEN N'alta'
                 WHEN @TotalFacturadoMes > 0 AND (@TotalCobradoMes * 100.0 / @TotalFacturadoMes) < 75 THEN N'media'
                 ELSE N'baja' END AS Urgencia,
            2 AS Orden
        WHERE @TotalFacturadoMes > 0

        UNION ALL

        -- Alumnos morosos
        SELECT
            CAST(@AlumnosMorosos AS VARCHAR) + N' alumnos con cuentas vencidas' AS Mensaje,
            N'morosos' AS Tipo, N'alta' AS Urgencia, 3 AS Orden
        WHERE @AlumnosMorosos > 0

        UNION ALL

        -- Cuentas por vencer en 7 días
        SELECT
            CAST(COUNT(*) AS VARCHAR) + N' cuentas vencen en los próximos 7 días' AS Mensaje,
            N'vencer' AS Tipo, N'media' AS Urgencia, 4 AS Orden
        FROM finanza.tbCuentasCobrar
        WHERE Cco_EsEliminado = 0 AND Cco_MontoPendiente > 0
          AND Cco_FechaVencimiento BETWEEN @Hoy AND @ProximoSemana
        HAVING COUNT(*) > 0

        UNION ALL

        -- Pago grande del día
        SELECT TOP 1
            N'Mayor cobro del mes: Q ' + FORMAT(Pag_MontoTotal, 'N2') AS Mensaje,
            N'pago' AS Tipo, N'baja' AS Urgencia, 5 AS Orden
        FROM finanza.tbPagos
        WHERE Pag_EsEliminado = 0
          AND YEAR(Pag_FechaPago) = @Anio AND MONTH(Pag_FechaPago) = @Mes
        ORDER BY Pag_MontoTotal DESC

    ) a
    ORDER BY Orden, Mensaje;

END
GO

PRINT 'PR_DashboardFinanciero_Resumen actualizado a 10 result sets.';

-- ──────────────────────────────────────────────────────────────────────
-- SEED DATA: poblar finanzas para demos del dashboard (Mayo 2026)
-- ──────────────────────────────────────────────────────────────────────

-- Backfill Cco_Anio / Cco_Mes desde Cco_FechaEmision en cuentas existentes
UPDATE finanza.tbCuentasCobrar
SET Cco_Anio = YEAR(Cco_FechaEmision), Cco_Mes = MONTH(Cco_FechaEmision)
WHERE Cco_Anio IS NULL OR Cco_Mes IS NULL;

DECLARE @CpaMens   INT = (SELECT TOP 1 Cpa_Id FROM finanza.tbConceptosPago WHERE Cpa_Descripcion LIKE N'Mensualidad%');
DECLARE @CpaTrans  INT = (SELECT TOP 1 Cpa_Id FROM finanza.tbConceptosPago WHERE Cpa_Descripcion LIKE N'Transporte%');
DECLARE @CpaMatr   INT = (SELECT TOP 1 Cpa_Id FROM finanza.tbConceptosPago WHERE Cpa_Descripcion LIKE N'Matr_cula%');
DECLARE @EpaPend   INT = (SELECT TOP 1 Epa_Id FROM finanza.tbEstadosPago   WHERE Epa_Descripcion = N'Pendiente');
DECLARE @Fpa1 INT = (SELECT TOP 1 Fpa_Id FROM finanza.tbFormasPago WHERE Fpa_Descripcion LIKE N'Efectivo%');
DECLARE @Fpa2 INT = (SELECT TOP 1 Fpa_Id FROM finanza.tbFormasPago WHERE Fpa_Descripcion LIKE N'Transfer%');
DECLARE @Fpa3 INT = (SELECT TOP 1 Fpa_Id FROM finanza.tbFormasPago WHERE Fpa_Descripcion LIKE N'Tarjeta%');
DECLARE @Fpa4 INT = (SELECT TOP 1 Fpa_Id FROM finanza.tbFormasPago WHERE Fpa_Descripcion LIKE N'Cheque%');

-- Cuentas Mayo 2026 (si no existen ya)
IF NOT EXISTS (SELECT 1 FROM finanza.tbCuentasCobrar WHERE Cco_Anio = 2026 AND Cco_Mes = 5 AND Cco_Observaciones = N'Mensualidad Mayo 2026')
BEGIN
    INSERT INTO finanza.tbCuentasCobrar (Alu_Id, Cpa_Id, Tar_Id, Cco_MontoOriginal, Cco_MontoDescuento, Cco_MontoMora, Cco_MontoTotal, Cco_MontoPendiente, Cco_FechaEmision, Cco_FechaVencimiento, Epa_Id, Cco_Observaciones, Cco_EsEliminado, Cco_UsuarioRegistra, Cco_FechaRegistra, Cco_Anio, Cco_Mes)
    SELECT TOP 25 a.Alu_Id, @CpaMens, NULL, 850.00, 0, 0, 850.00, 850.00, '2026-05-01', '2026-05-15', @EpaPend, N'Mensualidad Mayo 2026', 0, 1, GETDATE(), 2026, 5
    FROM app.tbAlumnos a ORDER BY a.Alu_Id;
END

-- Pagos Mayo 2026
IF NOT EXISTS (SELECT 1 FROM finanza.tbPagos WHERE YEAR(Pag_FechaPago)=2026 AND MONTH(Pag_FechaPago)=5 AND Pag_Observaciones = N'Pago mensualidad Mayo 2026')
BEGIN
    ;WITH AluRecien AS (
        SELECT TOP 18 Alu_Id, ROW_NUMBER() OVER (ORDER BY Alu_Id) AS rn FROM app.tbAlumnos ORDER BY Alu_Id
    )
    INSERT INTO finanza.tbPagos (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
    SELECT
        Alu_Id, NULL,
        CASE WHEN rn % 4 = 0 THEN @Fpa1 WHEN rn % 4 = 1 THEN @Fpa2 WHEN rn % 4 = 2 THEN @Fpa3 ELSE @Fpa4 END,
        CAST(500 + (rn * 137) % 2000 AS DECIMAL(18,2)),
        DATEADD(DAY, rn % 27, '2026-05-01'),
        N'REF-MAY-' + CAST(1000 + rn AS NVARCHAR),
        N'Pago mensualidad Mayo 2026',
        1, 0, 1, GETDATE()
    FROM AluRecien;
END

-- Cuentas por vencer próxima semana
IF NOT EXISTS (SELECT 1 FROM finanza.tbCuentasCobrar WHERE Cco_Observaciones = N'Por vencer')
BEGIN
    ;WITH AluRecien AS (
        SELECT TOP 10 Alu_Id, ROW_NUMBER() OVER (ORDER BY Alu_Id DESC) AS rn FROM app.tbAlumnos ORDER BY Alu_Id DESC
    )
    INSERT INTO finanza.tbCuentasCobrar (Alu_Id, Cpa_Id, Tar_Id, Cco_MontoOriginal, Cco_MontoDescuento, Cco_MontoMora, Cco_MontoTotal, Cco_MontoPendiente, Cco_FechaEmision, Cco_FechaVencimiento, Epa_Id, Cco_Observaciones, Cco_EsEliminado, Cco_UsuarioRegistra, Cco_FechaRegistra, Cco_Anio, Cco_Mes)
    SELECT
        Alu_Id,
        CASE WHEN rn % 2 = 0 THEN ISNULL(@CpaTrans, @CpaMatr) ELSE ISNULL(@CpaMatr, @CpaMens) END,
        NULL,
        CAST(300 + rn*80 AS DECIMAL(18,2)), 0, 0,
        CAST(300 + rn*80 AS DECIMAL(18,2)),
        CAST(300 + rn*80 AS DECIMAL(18,2)),
        GETDATE(),
        DATEADD(DAY, rn, CAST(GETDATE() AS DATE)),
        @EpaPend, N'Por vencer', 0, 1, GETDATE(), 2026, 5
    FROM AluRecien;
END

-- Vincular pagos de Mayo a cuentas (PagosDetalle) para que CobrosPorConcepto tenga datos
INSERT INTO finanza.tbPagosDetalle (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra)
SELECT p.Pag_Id, c.Cco_Id, p.Pag_MontoTotal, 0, 1, GETDATE()
FROM finanza.tbPagos p
CROSS APPLY (
    SELECT TOP 1 Cco_Id FROM finanza.tbCuentasCobrar
    WHERE Alu_Id = p.Alu_Id AND Cco_Anio = 2026 AND Cco_Mes = 5 AND Cco_EsEliminado = 0
    ORDER BY Cco_Id
) c
WHERE YEAR(p.Pag_FechaPago) = 2026 AND MONTH(p.Pag_FechaPago) = 5
  AND p.Pag_EsEliminado = 0
  AND NOT EXISTS (SELECT 1 FROM finanza.tbPagosDetalle d WHERE d.Pag_Id = p.Pag_Id AND d.Pde_EsEliminado = 0);

PRINT 'Seed data finanzas insertado (May 2026).';
GO
