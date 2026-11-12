-- =====================================================================
-- Script 019: SPs Fase 6 — Financiero (pagos del día, pendientes, historial)
-- Crea/reemplaza:
--   finanza.PR_Finanza_PagosDelDia            — pagos de hoy o @Fecha
--   finanza.PR_Finanza_PendientesCobrar        — cuentas con saldo > 0
--   finanza.PR_Finanza_HistorialTransacciones  — historial paginado
-- Convención: idempotente (DROP IF EXISTS + CREATE)
-- Estructura real tbPagos:     Pag_FechaPago [datetime2], Alu_Id, Fpa_Id, Pag_MontoTotal, Usu_Id
-- Estructura real tbCuentasCobrar: Cco_MontoPendiente, Cco_FechaVencimiento, Cco_Mes, Cco_Anio
-- Estructura real tbPagosDetalle:  Pag_Id, Cco_Id, Pde_MontoAplicado
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- finanza.PR_Finanza_PagosDelDia
-- Devuelve todos los pagos registrados en la fecha indicada (o hoy).
-- Incluye: alumno, forma de pago, usuario cajero, conceptos cobrados.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[finanza].[PR_Finanza_PagosDelDia]') IS NOT NULL
    DROP PROCEDURE [finanza].[PR_Finanza_PagosDelDia];
GO
CREATE PROCEDURE [finanza].[PR_Finanza_PagosDelDia]
    @Fecha  DATE = NULL,    -- NULL = hoy
    @Usu_Id INT  = NULL     -- NULL = todos los cajeros
AS
BEGIN
    SET NOCOUNT ON;
    IF @Fecha IS NULL SET @Fecha = CAST(GETDATE() AS DATE);

    -- RS1: Resumen del día
    SELECT
        @Fecha                                          AS Fecha,
        COUNT(p.Pag_Id)                                 AS TotalPagos,
        ISNULL(SUM(p.Pag_MontoTotal), 0)                AS MontoTotal,
        ISNULL(SUM(CASE WHEN fp.Fpa_Descripcion LIKE '%efectivo%'     THEN p.Pag_MontoTotal ELSE 0 END), 0) AS TotalEfectivo,
        ISNULL(SUM(CASE WHEN fp.Fpa_Descripcion LIKE '%transferencia%' THEN p.Pag_MontoTotal ELSE 0 END), 0) AS TotalTransferencia,
        ISNULL(SUM(CASE WHEN fp.Fpa_Descripcion LIKE '%tarjeta%'       THEN p.Pag_MontoTotal ELSE 0 END), 0) AS TotalTarjeta
    FROM [finanza].[tbPagos] p
    LEFT JOIN [finanza].[tbFormasPago] fp ON p.Fpa_Id = fp.Fpa_Id
    WHERE CAST(p.Pag_FechaPago AS DATE) = @Fecha
      AND p.Pag_EsEliminado = 0
      AND (@Usu_Id IS NULL OR p.Usu_Id = @Usu_Id);

    -- RS2: Detalle de cada pago
    SELECT
        p.Pag_Id,
        p.Pag_FechaPago,
        p.Pag_MontoTotal,
        p.Pag_NumeroReferencia,
        p.Pag_Observaciones,
        -- Alumno
        a.Alu_Id,
        LTRIM(RTRIM(CONCAT(
            per.Per_PrimerNombre, ' ',
            ISNULL(per.Per_SegundoNombre + ' ', ''),
            per.Per_ApellidoPaterno, ' ',
            ISNULL(per.Per_ApellidoMaterno, '')
        )))                         AS Alu_NombreCompleto,
        per.Per_Identidad           AS Alu_Identidad,
        c.Cur_Nombre,
        -- Forma de pago
        fp.Fpa_Id,
        fp.Fpa_Descripcion,
        -- Cajero
        p.Usu_Id,
        u.Usu_Name                  AS CajeroNombre,
        -- Conceptos cobrados (concatenados)
        STUFF((
            SELECT ', ' + cp.Cpa_Descripcion
            FROM [finanza].[tbPagosDetalle]    pd2
            INNER JOIN [finanza].[tbCuentasCobrar] cc2 ON pd2.Cco_Id = cc2.Cco_Id
            INNER JOIN [finanza].[tbConceptosPago] cp  ON cc2.Cpa_Id = cp.Cpa_Id
            WHERE pd2.Pag_Id = p.Pag_Id AND pd2.Pde_EsEliminado = 0
            FOR XML PATH(''), TYPE
        ).value('.','NVARCHAR(MAX)'), 1, 2, '') AS ConceptosCobrados
    FROM [finanza].[tbPagos] p
    INNER JOIN [app].[tbAlumnos]           a   ON p.Alu_Id  = a.Alu_Id
    INNER JOIN [app].[tbPersonas]          per ON a.Per_Id  = per.Per_Id
    INNER JOIN [app].[tbCursos]            c   ON a.Cur_Id  = c.Cur_Id
    INNER JOIN [finanza].[tbFormasPago]    fp  ON p.Fpa_Id  = fp.Fpa_Id
    INNER JOIN [seguridad].[tbUsuarios]    u   ON p.Usu_Id  = u.Usu_Id
    WHERE CAST(p.Pag_FechaPago AS DATE) = @Fecha
      AND p.Pag_EsEliminado = 0
      AND (@Usu_Id IS NULL OR p.Usu_Id = @Usu_Id)
    ORDER BY p.Pag_FechaPago DESC;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- finanza.PR_Finanza_PendientesCobrar
-- Cuentas por cobrar con saldo pendiente > 0.
-- Filtros opcionales: año, mes, y si están vencidas.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[finanza].[PR_Finanza_PendientesCobrar]') IS NOT NULL
    DROP PROCEDURE [finanza].[PR_Finanza_PendientesCobrar];
GO
CREATE PROCEDURE [finanza].[PR_Finanza_PendientesCobrar]
    @Anio          INT  = NULL,
    @Mes           INT  = NULL,     -- NULL = todos los meses
    @SoloVencidas  BIT  = 0,        -- 1 = solo con vencimiento pasado
    @Alu_Id        INT  = NULL      -- NULL = todos los alumnos
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

    -- RS1: Resumen de pendientes
    SELECT
        COUNT(cc.Cco_Id)                               AS TotalCuentas,
        ISNULL(SUM(cc.Cco_MontoPendiente), 0)          AS MontoPendienteTotal,
        ISNULL(SUM(cc.Cco_MontoMora), 0)               AS MoraTotal,
        COUNT(DISTINCT cc.Alu_Id)                       AS TotalAlumnosDeudores,
        COUNT(CASE WHEN cc.Cco_FechaVencimiento < @Hoy THEN 1 END) AS CuentasVencidas
    FROM [finanza].[tbCuentasCobrar] cc
    WHERE cc.Cco_MontoPendiente > 0
      AND cc.Cco_EsEliminado    = 0
      AND cc.Cco_Anio           = @Anio
      AND (@Mes         IS NULL OR cc.Cco_Mes   = @Mes)
      AND (@Alu_Id      IS NULL OR cc.Alu_Id    = @Alu_Id)
      AND (@SoloVencidas = 0    OR cc.Cco_FechaVencimiento < @Hoy);

    -- RS2: Detalle de cuentas pendientes
    SELECT
        cc.Cco_Id,
        cc.Cco_Mes,
        cc.Cco_Anio,
        cc.Cco_MontoOriginal,
        cc.Cco_MontoDescuento,
        cc.Cco_MontoMora,
        cc.Cco_MontoTotal,
        cc.Cco_MontoPendiente,
        cc.Cco_FechaEmision,
        cc.Cco_FechaVencimiento,
        DATEDIFF(DAY, cc.Cco_FechaVencimiento, @Hoy) AS DiasVencida,
        CASE WHEN cc.Cco_FechaVencimiento < @Hoy THEN 1 ELSE 0 END AS EsVencida,
        cc.Cco_Observaciones,
        -- Concepto
        cp.Cpa_Id,
        cp.Cpa_Descripcion,
        -- Estado
        ep.Epa_Id,
        ep.Epa_Descripcion,
        -- Alumno
        a.Alu_Id,
        LTRIM(RTRIM(CONCAT(
            per.Per_PrimerNombre, ' ',
            ISNULL(per.Per_SegundoNombre + ' ', ''),
            per.Per_ApellidoPaterno, ' ',
            ISNULL(per.Per_ApellidoMaterno, '')
        )))                         AS Alu_NombreCompleto,
        per.Per_Identidad           AS Alu_Identidad,
        per.Per_Telefono            AS Alu_Telefono,
        c.Cur_Nombre,
        s.Sec_Descripcion
    FROM [finanza].[tbCuentasCobrar] cc
    INNER JOIN [finanza].[tbConceptosPago]  cp  ON cc.Cpa_Id  = cp.Cpa_Id
    INNER JOIN [finanza].[tbEstadosPago]    ep  ON cc.Epa_Id  = ep.Epa_Id
    INNER JOIN [app].[tbAlumnos]            a   ON cc.Alu_Id  = a.Alu_Id
    INNER JOIN [app].[tbPersonas]           per ON a.Per_Id   = per.Per_Id
    INNER JOIN [app].[tbCursos]             c   ON a.Cur_Id   = c.Cur_Id
    LEFT  JOIN [app].[tbSecciones]          s   ON a.Sec_Id   = s.Sec_Id
    WHERE cc.Cco_MontoPendiente > 0
      AND cc.Cco_EsEliminado    = 0
      AND cc.Cco_Anio           = @Anio
      AND (@Mes         IS NULL OR cc.Cco_Mes   = @Mes)
      AND (@Alu_Id      IS NULL OR cc.Alu_Id    = @Alu_Id)
      AND (@SoloVencidas = 0    OR cc.Cco_FechaVencimiento < @Hoy)
    ORDER BY cc.Cco_FechaVencimiento ASC, per.Per_ApellidoPaterno;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- finanza.PR_Finanza_HistorialTransacciones
-- Historial paginado de pagos con filtros opcionales.
-- @Pagina empieza en 1; @RegistrosPorPagina default 50.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[finanza].[PR_Finanza_HistorialTransacciones]') IS NOT NULL
    DROP PROCEDURE [finanza].[PR_Finanza_HistorialTransacciones];
GO
CREATE PROCEDURE [finanza].[PR_Finanza_HistorialTransacciones]
    @Alu_Id           INT  = NULL,
    @FechaDesde       DATE = NULL,
    @FechaHasta       DATE = NULL,
    @Pagina           INT  = 1,
    @RegistrosPorPagina INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    -- Defaults de rango de fechas: último mes si no se especifica
    IF @FechaDesde IS NULL SET @FechaDesde = DATEADD(MONTH, -1, CAST(GETDATE() AS DATE));
    IF @FechaHasta IS NULL SET @FechaHasta = CAST(GETDATE() AS DATE);
    IF @Pagina < 1 SET @Pagina = 1;
    IF @RegistrosPorPagina < 1 OR @RegistrosPorPagina > 500 SET @RegistrosPorPagina = 50;

    DECLARE @Offset INT = (@Pagina - 1) * @RegistrosPorPagina;

    -- RS1: Total de registros para paginación cliente
    SELECT COUNT(*) AS TotalRegistros,
           @Pagina                 AS PaginaActual,
           @RegistrosPorPagina     AS RegistrosPorPagina,
           CEILING(COUNT(*) * 1.0 / @RegistrosPorPagina) AS TotalPaginas
    FROM [finanza].[tbPagos] p
    WHERE p.Pag_EsEliminado = 0
      AND CAST(p.Pag_FechaPago AS DATE) BETWEEN @FechaDesde AND @FechaHasta
      AND (@Alu_Id IS NULL OR p.Alu_Id = @Alu_Id);

    -- RS2: Página de transacciones
    SELECT
        p.Pag_Id,
        p.Pag_FechaPago,
        p.Pag_MontoTotal,
        p.Pag_NumeroReferencia,
        p.Pag_Observaciones,
        -- Alumno
        a.Alu_Id,
        LTRIM(RTRIM(CONCAT(
            per.Per_PrimerNombre, ' ',
            ISNULL(per.Per_SegundoNombre + ' ', ''),
            per.Per_ApellidoPaterno, ' ',
            ISNULL(per.Per_ApellidoMaterno, '')
        )))                         AS Alu_NombreCompleto,
        per.Per_Identidad           AS Alu_Identidad,
        c.Cur_Nombre,
        -- Forma de pago
        fp.Fpa_Id,
        fp.Fpa_Descripcion,
        -- Cajero
        p.Usu_Id,
        u.Usu_Name                  AS CajeroNombre,
        -- Total de conceptos en el pago
        (SELECT COUNT(*) FROM [finanza].[tbPagosDetalle] pd2
         WHERE pd2.Pag_Id = p.Pag_Id AND pd2.Pde_EsEliminado = 0) AS CantidadConceptos
    FROM [finanza].[tbPagos] p
    INNER JOIN [app].[tbAlumnos]           a   ON p.Alu_Id  = a.Alu_Id
    INNER JOIN [app].[tbPersonas]          per ON a.Per_Id  = per.Per_Id
    INNER JOIN [app].[tbCursos]            c   ON a.Cur_Id  = c.Cur_Id
    INNER JOIN [finanza].[tbFormasPago]    fp  ON p.Fpa_Id  = fp.Fpa_Id
    INNER JOIN [seguridad].[tbUsuarios]    u   ON p.Usu_Id  = u.Usu_Id
    WHERE p.Pag_EsEliminado = 0
      AND CAST(p.Pag_FechaPago AS DATE) BETWEEN @FechaDesde AND @FechaHasta
      AND (@Alu_Id IS NULL OR p.Alu_Id = @Alu_Id)
    ORDER BY p.Pag_FechaPago DESC
    OFFSET @Offset ROWS
    FETCH NEXT @RegistrosPorPagina ROWS ONLY;

    -- RS3: Detalle de los conceptos por pago (del mismo filtro para que el cliente los una)
    SELECT
        pd.Pag_Id,
        pd.Cco_Id,
        pd.Pde_MontoAplicado,
        cp.Cpa_Descripcion,
        cc.Cco_Mes,
        cc.Cco_Anio
    FROM [finanza].[tbPagosDetalle]    pd
    INNER JOIN [finanza].[tbPagos]         p   ON pd.Pag_Id = p.Pag_Id
    INNER JOIN [finanza].[tbCuentasCobrar] cc  ON pd.Cco_Id = cc.Cco_Id
    INNER JOIN [finanza].[tbConceptosPago] cp  ON cc.Cpa_Id = cp.Cpa_Id
    WHERE pd.Pde_EsEliminado = 0
      AND p.Pag_EsEliminado  = 0
      AND CAST(p.Pag_FechaPago AS DATE) BETWEEN @FechaDesde AND @FechaHasta
      AND (@Alu_Id IS NULL OR p.Alu_Id = @Alu_Id)
    ORDER BY pd.Pag_Id DESC;
END
GO

PRINT 'Script 019 completado: SPs Fase 6 (Financiero - PagosDelDia + PendientesCobrar + HistorialTransacciones) creados exitosamente.';
GO
