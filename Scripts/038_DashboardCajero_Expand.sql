-- 038_DashboardCajero_Expand.sql
-- Expande PR_DashboardCajero_Hoy a 10 result sets
-- Tablas usadas: finanza.tbPagos, finanza.tbPagosDetalle, finanza.tbCuentasCobrar,
--                finanza.tbFormasPago, finanza.tbConceptosPago, finanza.tbArqueosCaja,
--                app.tbAlumnos, app.tbPersonas

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_DashboardCajero_Hoy]') AND type = 'P')
    DROP PROCEDURE [app].[PR_DashboardCajero_Hoy];
GO
CREATE PROCEDURE [app].[PR_DashboardCajero_Hoy]
    @Usu_Id INT,
    @Fecha  DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Fecha IS NULL SET @Fecha = CAST(GETDATE() AS DATE);
    DECLARE @Hace7 DATE = DATEADD(DAY, -6, @Fecha);

    -- ── RS1: KPIs Hoy ─────────────────────────────────────────────────────
    DECLARE @TotalCobrado DECIMAL(18,2) = (SELECT ISNULL(SUM(Pag_MontoTotal),0)
                                            FROM finanza.tbPagos
                                            WHERE Usu_Id = @Usu_Id
                                              AND CAST(Pag_FechaPago AS DATE) = @Fecha
                                              AND Pag_EsEliminado = 0);
    DECLARE @CantCobros INT = (SELECT COUNT(*)
                                FROM finanza.tbPagos
                                WHERE Usu_Id = @Usu_Id
                                  AND CAST(Pag_FechaPago AS DATE) = @Fecha
                                  AND Pag_EsEliminado = 0);

    SELECT
        @TotalCobrado AS TotalCobradoHoy,
        @CantCobros   AS CantidadCobros,
        CASE WHEN @CantCobros > 0 THEN @TotalCobrado / @CantCobros ELSE 0 END AS TicketPromedio,
        ISNULL((SELECT MAX(Pag_MontoTotal) FROM finanza.tbPagos
                WHERE Usu_Id = @Usu_Id
                  AND CAST(Pag_FechaPago AS DATE) = @Fecha
                  AND Pag_EsEliminado = 0), 0) AS MayorPago,
        (SELECT COUNT(DISTINCT Alu_Id) FROM finanza.tbPagos
         WHERE Usu_Id = @Usu_Id
           AND CAST(Pag_FechaPago AS DATE) = @Fecha
           AND Pag_EsEliminado = 0) AS AlumnosAtendidos,
        (SELECT COUNT(*) FROM finanza.tbCuentasCobrar
         WHERE Cco_MontoPendiente > 0
           AND Cco_EsEliminado = 0
           AND Cco_FechaVencimiento <= @Fecha) AS CuentasPendientesHoy,
        ISNULL((SELECT SUM(Cco_MontoPendiente) FROM finanza.tbCuentasCobrar
                WHERE Cco_MontoPendiente > 0
                  AND Cco_EsEliminado = 0
                  AND Cco_FechaVencimiento <= @Fecha), 0) AS MontoPendienteHoy,
        ISNULL((SELECT SUM(Cco_MontoMora) FROM finanza.tbCuentasCobrar
                WHERE Cco_MontoPendiente > 0
                  AND Cco_EsEliminado = 0
                  AND Cco_FechaVencimiento < @Fecha), 0) AS MontoMoraHoy;

    -- ── RS2: PagosPorHora (24 rows) ──────────────────────────────────────
    ;WITH Horas AS (
        SELECT 0 AS Hora UNION ALL SELECT Hora + 1 FROM Horas WHERE Hora < 23
    )
    SELECT
        h.Hora,
        ISNULL(COUNT(p.Pag_Id), 0) AS Cantidad,
        ISNULL(SUM(p.Pag_MontoTotal), 0) AS MontoTotal
    FROM Horas h
    LEFT JOIN finanza.tbPagos p
        ON DATEPART(HOUR, p.Pag_FechaPago) = h.Hora
       AND CAST(p.Pag_FechaPago AS DATE) = @Fecha
       AND p.Usu_Id = @Usu_Id
       AND p.Pag_EsEliminado = 0
    GROUP BY h.Hora
    ORDER BY h.Hora
    OPTION (MAXRECURSION 30);

    -- ── RS3: CobrosPorFormaPago ──────────────────────────────────────────
    SELECT
        fp.Fpa_Descripcion,
        ISNULL(SUM(p.Pag_MontoTotal), 0) AS Total,
        COUNT(p.Pag_Id) AS Cantidad
    FROM finanza.tbFormasPago fp
    LEFT JOIN finanza.tbPagos p
        ON p.Fpa_Id = fp.Fpa_Id
       AND p.Usu_Id = @Usu_Id
       AND CAST(p.Pag_FechaPago AS DATE) = @Fecha
       AND p.Pag_EsEliminado = 0
    WHERE fp.Fpa_EsEliminado = 0
    GROUP BY fp.Fpa_Id, fp.Fpa_Descripcion
    HAVING COUNT(p.Pag_Id) > 0
    ORDER BY Total DESC;

    -- ── RS4: CobrosPorConcepto (via tbPagosDetalle → tbCuentasCobrar) ────
    SELECT
        cp.Cpa_Descripcion,
        ISNULL(SUM(pd.Pde_MontoAplicado), 0) AS Total,
        COUNT(DISTINCT p.Pag_Id) AS Cantidad
    FROM finanza.tbConceptosPago cp
    INNER JOIN finanza.tbCuentasCobrar cc ON cc.Cpa_Id = cp.Cpa_Id AND cc.Cco_EsEliminado = 0
    INNER JOIN finanza.tbPagosDetalle pd ON pd.Cco_Id = cc.Cco_Id AND pd.Pde_EsEliminado = 0
    INNER JOIN finanza.tbPagos p ON p.Pag_Id = pd.Pag_Id
        AND p.Usu_Id = @Usu_Id
        AND CAST(p.Pag_FechaPago AS DATE) = @Fecha
        AND p.Pag_EsEliminado = 0
    WHERE cp.Cpa_EsEliminado = 0
    GROUP BY cp.Cpa_Id, cp.Cpa_Descripcion
    ORDER BY Total DESC;

    -- ── RS5: TimelinePagos (top 15 últimos del día) ─────────────────────
    SELECT TOP 15
        p.Pag_Id,
        p.Pag_FechaPago,
        p.Pag_MontoTotal,
        p.Pag_NumeroReferencia,
        fp.Fpa_Descripcion,
        RTRIM(LTRIM(
            ISNULL(per.Per_PrimerNombre,'') + ' ' +
            ISNULL(per.Per_ApellidoPaterno,'') + ' ' +
            ISNULL(per.Per_ApellidoMaterno,'')
        )) AS NombreAlumno
    FROM finanza.tbPagos p
    INNER JOIN finanza.tbFormasPago fp ON fp.Fpa_Id = p.Fpa_Id
    LEFT JOIN app.tbAlumnos a ON a.Alu_Id = p.Alu_Id
    LEFT JOIN app.tbPersonas per ON per.Per_Id = a.Per_Id
    WHERE p.Usu_Id = @Usu_Id
      AND CAST(p.Pag_FechaPago AS DATE) = @Fecha
      AND p.Pag_EsEliminado = 0
    ORDER BY p.Pag_FechaPago DESC;

    -- ── RS6: TopAlumnosDelDia (top 5 por monto) ──────────────────────────
    SELECT TOP 5
        a.Alu_Id,
        RTRIM(LTRIM(
            ISNULL(per.Per_PrimerNombre,'') + ' ' +
            ISNULL(per.Per_ApellidoPaterno,'') + ' ' +
            ISNULL(per.Per_ApellidoMaterno,'')
        )) AS NombreAlumno,
        COUNT(p.Pag_Id) AS CantidadPagos,
        SUM(p.Pag_MontoTotal) AS MontoTotal,
        per.Per_Imagen
    FROM finanza.tbPagos p
    INNER JOIN app.tbAlumnos a ON a.Alu_Id = p.Alu_Id
    LEFT JOIN app.tbPersonas per ON per.Per_Id = a.Per_Id
    WHERE p.Usu_Id = @Usu_Id
      AND CAST(p.Pag_FechaPago AS DATE) = @Fecha
      AND p.Pag_EsEliminado = 0
    GROUP BY a.Alu_Id, per.Per_PrimerNombre, per.Per_ApellidoPaterno, per.Per_ApellidoMaterno, per.Per_Imagen
    ORDER BY MontoTotal DESC;

    -- ── RS7: CuentasVencidas (top 10 más vencidas) ───────────────────────
    SELECT TOP 10
        cc.Cco_Id,
        RTRIM(LTRIM(
            ISNULL(per.Per_PrimerNombre,'') + ' ' +
            ISNULL(per.Per_ApellidoPaterno,'') + ' ' +
            ISNULL(per.Per_ApellidoMaterno,'')
        )) AS NombreAlumno,
        cp.Cpa_Descripcion,
        cc.Cco_FechaVencimiento,
        cc.Cco_MontoPendiente,
        DATEDIFF(DAY, cc.Cco_FechaVencimiento, @Fecha) AS DiasVencido
    FROM finanza.tbCuentasCobrar cc
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = cc.Cpa_Id
    INNER JOIN app.tbAlumnos a ON a.Alu_Id = cc.Alu_Id
    LEFT JOIN app.tbPersonas per ON per.Per_Id = a.Per_Id
    WHERE cc.Cco_MontoPendiente > 0
      AND cc.Cco_EsEliminado = 0
      AND cc.Cco_FechaVencimiento < @Fecha
    ORDER BY cc.Cco_FechaVencimiento ASC;

    -- ── RS8: UltimoArqueo del cajero ─────────────────────────────────────
    SELECT TOP 1
        Arq_Id,
        Arq_Fecha,
        Arq_TotalGeneral,
        Arq_Observaciones
    FROM finanza.tbArqueosCaja
    WHERE Usu_Id = @Usu_Id
      AND Arq_EsEliminado = 0
    ORDER BY Arq_Fecha DESC, Arq_Id DESC;

    -- ── RS9: ResumenSemanal (últimos 7 días) ─────────────────────────────
    ;WITH Dias AS (
        SELECT @Hace7 AS Fecha
        UNION ALL
        SELECT DATEADD(DAY, 1, Fecha) FROM Dias WHERE Fecha < @Fecha
    )
    SELECT
        d.Fecha,
        ISNULL(SUM(p.Pag_MontoTotal), 0) AS MontoTotal,
        ISNULL(COUNT(p.Pag_Id), 0) AS CantidadCobros
    FROM Dias d
    LEFT JOIN finanza.tbPagos p
        ON CAST(p.Pag_FechaPago AS DATE) = d.Fecha
       AND p.Usu_Id = @Usu_Id
       AND p.Pag_EsEliminado = 0
    GROUP BY d.Fecha
    ORDER BY d.Fecha
    OPTION (MAXRECURSION 30);

    -- ── RS10: Alertas dinámicas ──────────────────────────────────────────
    DECLARE @Alertas TABLE (Mensaje NVARCHAR(300), Tipo NVARCHAR(40), Urgencia NVARCHAR(10), Orden INT);

    DECLARE @CuentasVencidasCnt INT = (SELECT COUNT(*) FROM finanza.tbCuentasCobrar
                                        WHERE Cco_MontoPendiente > 0
                                          AND Cco_EsEliminado = 0
                                          AND Cco_FechaVencimiento < @Fecha);
    IF @CuentasVencidasCnt > 0
        INSERT INTO @Alertas VALUES (
            N'Existen ' + CAST(@CuentasVencidasCnt AS NVARCHAR) + N' cuentas vencidas pendientes de cobro.',
            N'vencidas',
            CASE WHEN @CuentasVencidasCnt > 20 THEN N'alta' WHEN @CuentasVencidasCnt > 5 THEN N'media' ELSE N'baja' END,
            1);

    DECLARE @MontoMora DECIMAL(18,2) = ISNULL((SELECT SUM(Cco_MontoMora) FROM finanza.tbCuentasCobrar
                                                WHERE Cco_MontoPendiente > 0
                                                  AND Cco_EsEliminado = 0
                                                  AND Cco_FechaVencimiento < @Fecha), 0);
    IF @MontoMora > 0
        INSERT INTO @Alertas VALUES (
            N'Mora acumulada: Q' + FORMAT(@MontoMora, 'N2'),
            N'mora',
            CASE WHEN @MontoMora > 5000 THEN N'alta' WHEN @MontoMora > 1000 THEN N'media' ELSE N'baja' END,
            2);

    IF NOT EXISTS (SELECT 1 FROM finanza.tbArqueosCaja
                    WHERE Usu_Id = @Usu_Id
                      AND Arq_Fecha = @Fecha
                      AND Arq_EsEliminado = 0)
       AND @CantCobros > 0
        INSERT INTO @Alertas VALUES (
            N'No se ha registrado arqueo de caja del día.',
            N'arqueo',
            N'media',
            3);

    IF @CantCobros = 0
        INSERT INTO @Alertas VALUES (
            N'No se han registrado cobros para la fecha seleccionada.',
            N'sin_cobros',
            N'baja',
            4);

    IF @TotalCobrado > 0
        INSERT INTO @Alertas VALUES (
            N'Cobros del día: Q' + FORMAT(@TotalCobrado, 'N2') + N' (' + CAST(@CantCobros AS NVARCHAR) + N' transacciones).',
            N'cobros_ok',
            N'baja',
            5);

    SELECT Mensaje, Tipo, Urgencia, Orden FROM @Alertas ORDER BY Orden;
END
GO

-- ───────────────────────────────────────────────────────────────────────
-- SEED DATA: pagos del día (2026-05-28) + último arqueo (2026-05-27)
-- Idempotente: limpia antes de insertar
-- ───────────────────────────────────────────────────────────────────────
DELETE pd FROM finanza.tbPagosDetalle pd
 INNER JOIN finanza.tbPagos p ON p.Pag_Id = pd.Pag_Id
 WHERE p.Usu_Id=1 AND CAST(p.Pag_FechaPago AS DATE)='2026-05-28';
DELETE FROM finanza.tbPagos WHERE Usu_Id=1 AND CAST(Pag_FechaPago AS DATE)='2026-05-28';
DELETE FROM finanza.tbArqueosCaja WHERE Usu_Id=1 AND Arq_Fecha='2026-05-27';
GO

DECLARE @F DATETIME2; DECLARE @PagId INT;
SET @F = '2026-05-28T08:15:00';
INSERT INTO finanza.tbPagos (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
VALUES (25, 0, 1, 500.00, @F, N'REF-2026-100', N'Cobro matrícula', 1, 0, 1, @F);
SET @PagId = SCOPE_IDENTITY();
INSERT INTO finanza.tbPagosDetalle (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra) VALUES (@PagId, 3, 500.00, 0, 1, @F);

SET @F = '2026-05-28T09:30:00';
INSERT INTO finanza.tbPagos (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
VALUES (68, 0, 2, 800.00, @F, N'REF-2026-101', N'Mensualidad mayo', 1, 0, 1, @F);
SET @PagId = SCOPE_IDENTITY();
INSERT INTO finanza.tbPagosDetalle (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra) VALUES (@PagId, 4, 800.00, 0, 1, @F);

SET @F = '2026-05-28T10:45:00';
INSERT INTO finanza.tbPagos (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
VALUES (69, 0, 3, 840.00, @F, N'REF-2026-102', N'Pago transferencia BAC', 1, 0, 1, @F);
SET @PagId = SCOPE_IDENTITY();
INSERT INTO finanza.tbPagosDetalle (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra) VALUES (@PagId, 5, 840.00, 0, 1, @F);

SET @F = '2026-05-28T11:20:00';
INSERT INTO finanza.tbPagos (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
VALUES (1, 0, 1, 800.00, @F, N'REF-2026-103', N'Cobro mensualidad', 1, 0, 1, @F);
SET @PagId = SCOPE_IDENTITY();
INSERT INTO finanza.tbPagosDetalle (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra) VALUES (@PagId, 1, 800.00, 0, 1, @F);

SET @F = '2026-05-28T13:50:00';
INSERT INTO finanza.tbPagos (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
VALUES (1, 0, 1, 300.00, @F, N'REF-2026-104', N'Materiales', 1, 0, 1, @F);
SET @PagId = SCOPE_IDENTITY();
INSERT INTO finanza.tbPagosDetalle (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra) VALUES (@PagId, 2, 300.00, 0, 1, @F);

SET @F = '2026-05-28T15:10:00';
INSERT INTO finanza.tbPagos (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
VALUES (314, 0, 2, 450.00, @F, N'REF-2026-105', N'Matrícula nueva', 1, 0, 1, @F);
SET @PagId = SCOPE_IDENTITY();
INSERT INTO finanza.tbPagosDetalle (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra) VALUES (@PagId, 7, 450.00, 0, 1, @F);

INSERT INTO finanza.tbArqueosCaja (Usu_Id, Arq_Fecha, Arq_TotalEfectivo, Arq_TotalTransferencia, Arq_TotalTarjeta, Arq_Observaciones, Arq_EsEliminado, Arq_UsuarioRegistra, Arq_FechaRegistra)
VALUES (1, '2026-05-27', 1500.00, 800.00, 700.00, N'Cierre de jornada sin novedades.', 0, 1, '2026-05-27T17:30:00');
GO
