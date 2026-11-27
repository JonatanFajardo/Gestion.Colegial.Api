/* =============================================================================
   094 · Centro de reportes: comparativo de cobros entre dos años y proyección de cobros
   (requiere el script 081)

   Reemplazan a «Comparativa anual» y «Proyección de cobros» de Reportes financieros, que nunca
   funcionaron (su servicio de la API estaba comentado y sus procedimientos no existían).

   app.PR_CentroReportes_ComparativoCobros (@AnioBase, @AnioComparado)
     Una fila por mes: lo cobrado en cada año (pagos no anulados, por fecha de pago), la diferencia y
     la variación en % (vacía si el año base no cobró nada ese mes).

   app.PR_CentroReportes_ProyeccionCobros (@Anio, @MesDesde)
     Lo que falta por cobrar del año, mes a mes desde @MesDesde:
       - primera fila «Atrasado»: saldo de los cargos que vencieron antes de ese mes;
       - por mes: saldo de los cargos que vencen ese mes (de cualquier concepto) y la estimación de
         las mensualidades que todavía no se han generado: alumnos activos con tarifa de su grado y
         modalidad (finanza.tbTarifasMensualidades), igual que finanza.PR_GenerarMensualidad, solo en
         los meses dentro de las fechas del año lectivo (si el año existe en app.tbAnioLectivo).
   Permiso en la API: «Reportes financieros» (admin, contador, consulta).
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Nombre del mes en español con mayúscula inicial ("Enero"…).
CREATE OR ALTER FUNCTION app.FN_NombreMes (@Mes int)
RETURNS nvarchar(20)
AS
BEGIN
    RETURN CASE @Mes WHEN 1 THEN N'Enero' WHEN 2 THEN N'Febrero' WHEN 3 THEN N'Marzo' WHEN 4 THEN N'Abril'
                     WHEN 5 THEN N'Mayo' WHEN 6 THEN N'Junio' WHEN 7 THEN N'Julio' WHEN 8 THEN N'Agosto'
                     WHEN 9 THEN N'Septiembre' WHEN 10 THEN N'Octubre' WHEN 11 THEN N'Noviembre'
                     WHEN 12 THEN N'Diciembre' END;
END
GO

CREATE OR ALTER PROCEDURE app.PR_CentroReportes_ComparativoCobros
    @AnioBase      int,
    @AnioComparado int
AS
BEGIN
    SET NOCOUNT ON;
    IF @AnioBase IS NULL OR @AnioComparado IS NULL
       OR @AnioBase NOT BETWEEN 2000 AND 2100 OR @AnioComparado NOT BETWEEN 2000 AND 2100
        THROW 50086, N'Elija los dos años que quiere comparar.', 1;

    WITH meses AS (
        SELECT v.Mes FROM (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) v (Mes)
    ),
    cobrado AS (
        SELECT YEAR(pg.Pag_FechaPago) AS Anio, MONTH(pg.Pag_FechaPago) AS Mes, SUM(pg.Pag_MontoTotal) AS Monto
        FROM finanza.tbPagos pg
        WHERE pg.Pag_EsEliminado = 0 AND ISNULL(pg.Pag_EsAnulado, 0) = 0
          AND pg.Pag_FechaPago >= DATEFROMPARTS(IIF(@AnioBase < @AnioComparado, @AnioBase, @AnioComparado), 1, 1)
          AND pg.Pag_FechaPago <  DATEFROMPARTS(IIF(@AnioBase > @AnioComparado, @AnioBase, @AnioComparado) + 1, 1, 1)
        GROUP BY YEAR(pg.Pag_FechaPago), MONTH(pg.Pag_FechaPago)
    )
    SELECT m.Mes,
           app.FN_NombreMes(m.Mes) AS NombreMes,
           CAST(ISNULL(cb.Monto, 0) AS decimal(18,2)) AS CobradoBase,
           CAST(ISNULL(cc.Monto, 0) AS decimal(18,2)) AS CobradoComparado,
           CAST(ISNULL(cc.Monto, 0) - ISNULL(cb.Monto, 0) AS decimal(18,2)) AS Diferencia,
           CAST(CASE WHEN ISNULL(cb.Monto, 0) = 0 THEN NULL
                     ELSE (ISNULL(cc.Monto, 0) - cb.Monto) * 100.0 / cb.Monto END AS decimal(9,1)) AS Variacion
    FROM meses m
    LEFT JOIN cobrado cb ON cb.Anio = @AnioBase      AND cb.Mes = m.Mes
    LEFT JOIN cobrado cc ON cc.Anio = @AnioComparado AND cc.Mes = m.Mes
    ORDER BY m.Mes;
END
GO

CREATE OR ALTER PROCEDURE app.PR_CentroReportes_ProyeccionCobros
    @Anio     int,
    @MesDesde int = 1
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL OR @Anio NOT BETWEEN 2000 AND 2100
        THROW 50086, N'Elija el año.', 1;
    SET @MesDesde = ISNULL(@MesDesde, 1);
    IF @MesDesde NOT BETWEEN 1 AND 12
        THROW 50086, N'El mes tiene que estar entre 1 y 12.', 1;

    DECLARE @Inicio date = DATEFROMPARTS(@Anio, @MesDesde, 1);
    DECLARE @FinAnio date = DATEFROMPARTS(@Anio + 1, 1, 1);

    -- Meses del año lectivo (si existe): fuera de ellos no se generan mensualidades.
    DECLARE @LectivoDesde date, @LectivoHasta date;
    SELECT TOP (1) @LectivoDesde = Ani_FechaInicio, @LectivoHasta = Ani_FechaFin
    FROM app.tbAnioLectivo
    WHERE Ani_Anio = @Anio AND Ani_EsEliminado = 0
    ORDER BY Ani_Id;

    DECLARE @Mensualidad int = (SELECT TOP (1) Cpa_Id FROM finanza.tbConceptosPago
                                WHERE Cpa_Descripcion LIKE N'%Mensualidad%' AND Cpa_EsEliminado = 0
                                ORDER BY Cpa_Id);

    -- Alumnos a los que se les generaría la mensualidad y su tarifa (igual que PR_GenerarMensualidad).
    DECLARE @Tarifas TABLE (Alu_Id int PRIMARY KEY, Monto decimal(18,2));
    IF @Mensualidad IS NOT NULL
        INSERT INTO @Tarifas (Alu_Id, Monto)
        SELECT a.Alu_Id, MAX(tm.TarMen_Monto)
        FROM app.tbAlumnos a
        JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id AND p.Per_EsEliminado = 0
        JOIN finanza.tbTarifasMensualidades tm ON tm.Cun_Id = a.Cun_Id AND tm.Mda_Id = a.Mda_Id
                                              AND tm.TarMen_EsActivo = 1 AND tm.TarMen_EsEliminado = 0
        WHERE a.Est_Id = 1 AND ISNULL(a.AnioCursado, 0) <= @Anio
        GROUP BY a.Alu_Id;

    WITH meses AS (
        SELECT v.Mes FROM (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) v (Mes)
        WHERE v.Mes >= @MesDesde
    ),
    pendiente AS (
        SELECT MONTH(c.Cco_FechaVencimiento) AS Mes, SUM(c.Cco_MontoPendiente) AS Monto
        FROM finanza.tbCuentasCobrar c
        WHERE c.Cco_EsEliminado = 0 AND c.Cco_MontoPendiente > 0
          AND c.Cco_FechaVencimiento >= @Inicio AND c.Cco_FechaVencimiento < @FinAnio
        GROUP BY MONTH(c.Cco_FechaVencimiento)
    ),
    porGenerar AS (
        SELECT m.Mes, SUM(t.Monto) AS Monto
        FROM meses m
        CROSS JOIN @Tarifas t
        WHERE (@LectivoDesde IS NULL OR DATEFROMPARTS(@Anio, m.Mes, 1) >= DATEFROMPARTS(YEAR(@LectivoDesde), MONTH(@LectivoDesde), 1))
          AND (@LectivoHasta IS NULL OR DATEFROMPARTS(@Anio, m.Mes, 1) <= @LectivoHasta)
          AND NOT EXISTS (SELECT 1 FROM finanza.tbCuentasCobrar c
                          WHERE c.Alu_Id = t.Alu_Id AND c.Cpa_Id = @Mensualidad
                            AND c.Cco_Mes = m.Mes AND c.Cco_Anio = @Anio AND c.Cco_EsEliminado = 0)
        GROUP BY m.Mes
    ),
    filas AS (
        -- Lo atrasado: cargos con saldo que vencieron antes del primer mes pedido.
        SELECT 0 AS Mes, CAST(N'Atrasado' AS nvarchar(20)) AS NombreMes,
               ISNULL(SUM(c.Cco_MontoPendiente), 0) AS Pendiente, CAST(0 AS decimal(18,2)) AS EstimadoPorGenerar
        FROM finanza.tbCuentasCobrar c
        WHERE c.Cco_EsEliminado = 0 AND c.Cco_MontoPendiente > 0 AND c.Cco_FechaVencimiento < @Inicio
        UNION ALL
        SELECT m.Mes, app.FN_NombreMes(m.Mes), ISNULL(pe.Monto, 0), ISNULL(pg.Monto, 0)
        FROM meses m
        LEFT JOIN pendiente  pe ON pe.Mes = m.Mes
        LEFT JOIN porGenerar pg ON pg.Mes = m.Mes
    )
    SELECT Mes, NombreMes,
           CAST(Pendiente AS decimal(18,2)) AS Pendiente,
           CAST(EstimadoPorGenerar AS decimal(18,2)) AS EstimadoPorGenerar,
           CAST(Pendiente + EstimadoPorGenerar AS decimal(18,2)) AS TotalEsperado
    FROM filas
    ORDER BY Mes;
END
GO
