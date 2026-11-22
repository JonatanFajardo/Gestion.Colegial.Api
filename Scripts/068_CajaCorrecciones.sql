/* =============================================================================
   068 · Caja: correcciones de cuentas (anular pagos, perdonar cargos, saldo a favor)

   - tbPagos: columnas de anulación. Un pago anulado NO se borra: queda en los listados
     con Pag_EsAnulado = 1 y deja de contar como ingreso en reportes y dashboards.
   - finanza.tbSaldoFavorMovimientos: entradas (+) y salidas (-) de dinero a favor del
     alumno. Saldo = SUM(Sfm_Monto).
   - finanza.tbCorrecciones: registro legible de cada corrección (quién, cuándo, por qué).
   - Listados de pagos por fecha / rango / alumno (no existían: la API respondía vacío).
   - Resumen financiero: totalPagado = suma de pagos no anulados del alumno.
   - Listado de cuentas por cobrar con ubicación del alumno y desglose de montos.
   - Registrar pago aplicándolo a cargos; el excedente va a saldo a favor.
   - Pantalla "Corregir cuentas" para director (1002) y contador (1006).
   Idempotente: se puede correr varias veces.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ---------- 1. Columnas de anulación en tbPagos ---------- */
IF COL_LENGTH('finanza.tbPagos', 'Pag_EsAnulado') IS NULL
    ALTER TABLE finanza.tbPagos ADD Pag_EsAnulado bit NOT NULL
        CONSTRAINT DF_tbPagos_Pag_EsAnulado DEFAULT (0);
GO
IF COL_LENGTH('finanza.tbPagos', 'Pag_MotivoAnulacion') IS NULL
    ALTER TABLE finanza.tbPagos ADD Pag_MotivoAnulacion nvarchar(500) NULL;
IF COL_LENGTH('finanza.tbPagos', 'Pag_DestinoAnulacion') IS NULL
    ALTER TABLE finanza.tbPagos ADD Pag_DestinoAnulacion varchar(20) NULL;
IF COL_LENGTH('finanza.tbPagos', 'Pag_FechaAnulacion') IS NULL
    ALTER TABLE finanza.tbPagos ADD Pag_FechaAnulacion datetime2(0) NULL;
IF COL_LENGTH('finanza.tbPagos', 'Pag_UsuarioAnula') IS NULL
    ALTER TABLE finanza.tbPagos ADD Pag_UsuarioAnula int NULL;
GO

/* ---------- 2. Saldo a favor ---------- */
IF OBJECT_ID('finanza.tbSaldoFavorMovimientos', 'U') IS NULL
BEGIN
    CREATE TABLE finanza.tbSaldoFavorMovimientos (
        Sfm_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbSaldoFavorMovimientos PRIMARY KEY,
        Alu_Id              int            NOT NULL,
        Sfm_Origen          varchar(20)    NOT NULL,   -- Excedente | Anulacion | Devolucion | Aplicacion
        Sfm_Monto           decimal(18,2)  NOT NULL,   -- + entra, - sale
        Pag_Id              int            NULL,
        Cco_Id              int            NULL,
        Sfm_Metodo          varchar(20)    NULL,       -- devoluciones: Efectivo | Transferencia | Cheque
        Sfm_Motivo          nvarchar(500)  NULL,
        Sfm_UsuarioRegistra int            NOT NULL,
        Sfm_FechaRegistra   datetime2(0)   NOT NULL CONSTRAINT DF_tbSaldoFavorMovimientos_Fecha DEFAULT (GETDATE()),
        CONSTRAINT CK_tbSaldoFavorMovimientos_Origen CHECK (Sfm_Origen IN ('Excedente','Anulacion','Devolucion','Aplicacion')),
        CONSTRAINT CK_tbSaldoFavorMovimientos_Monto CHECK (Sfm_Monto <> 0)
    );
    CREATE INDEX IX_tbSaldoFavorMovimientos_Alu ON finanza.tbSaldoFavorMovimientos (Alu_Id);
END
GO

/* ---------- 3. Registro de correcciones ---------- */
IF OBJECT_ID('finanza.tbCorrecciones', 'U') IS NULL
BEGIN
    CREATE TABLE finanza.tbCorrecciones (
        Cor_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbCorrecciones PRIMARY KEY,
        Alu_Id              int            NOT NULL,
        Cor_Tipo            nvarchar(30)   NOT NULL,   -- Pago anulado | Cargo perdonado | Devolución | Saldo aplicado | Saldo a favor
        Cor_Detalle         nvarchar(400)  NULL,
        Cor_Motivo          nvarchar(500)  NULL,
        Cor_Monto           decimal(18,2)  NOT NULL,
        Pag_Id              int            NULL,
        Cco_Id              int            NULL,
        Cor_UsuarioRegistra int            NOT NULL,
        Cor_FechaRegistra   datetime2(0)   NOT NULL CONSTRAINT DF_tbCorrecciones_Fecha DEFAULT (GETDATE())
    );
    CREATE INDEX IX_tbCorrecciones_Alu ON finanza.tbCorrecciones (Alu_Id, Cor_FechaRegistra DESC);
END
GO

/* ---------- 4. Listados de pagos (mismo formato en todos) ---------- */
CREATE OR ALTER VIEW finanza.VW_PagosListado
AS
    SELECT
        p.Pag_Id,
        p.Alu_Id,
        p.Pag_FechaPago,
        p.Pag_MontoTotal,
        p.Pag_NumeroReferencia,
        p.Pag_Observaciones,
        fp.Fpa_Descripcion AS FormaPago,
        Alumno = LTRIM(RTRIM(CONCAT(pa.Per_PrimerNombre, ' ', ISNULL(pa.Per_SegundoNombre,''), ' ',
                                    pa.Per_ApellidoPaterno, ' ', ISNULL(pa.Per_ApellidoMaterno,'')))),
        Encargado = CASE WHEN p.Enc_Id IS NULL THEN NULL ELSE
                    LTRIM(RTRIM(CONCAT(pe.Per_PrimerNombre, ' ', ISNULL(pe.Per_SegundoNombre,''), ' ',
                                       pe.Per_ApellidoPaterno, ' ', ISNULL(pe.Per_ApellidoMaterno,'')))) END,
        Usuario = u.Usu_Name,
        r1.Rec_NumeroRecibo,
        r1.Rec_FechaEmision,
        p.Pag_EsAnulado,
        p.Pag_MotivoAnulacion
    FROM finanza.tbPagos p
        INNER JOIN finanza.tbFormasPago fp ON fp.Fpa_Id = p.Fpa_Id
        LEFT JOIN app.tbAlumnos a ON a.Alu_Id = p.Alu_Id
        LEFT JOIN app.tbPersonas pa ON pa.Per_Id = a.Per_Id
        LEFT JOIN app.tbEncargados e ON e.Enc_Id = p.Enc_Id
        LEFT JOIN app.tbPersonas pe ON pe.Per_Id = e.Per_Id
        LEFT JOIN seguridad.tbUsuarios u ON u.Usu_Id = p.Usu_Id
        OUTER APPLY (
            SELECT TOP (1) r.Rec_NumeroRecibo, r.Rec_FechaEmision
            FROM finanza.tbRecibos r
            WHERE r.Pag_Id = p.Pag_Id AND r.Rec_EsEliminado = 0
            ORDER BY r.Rec_FechaEmision DESC, r.Rec_Id DESC
        ) r1
    WHERE p.Pag_EsEliminado = 0;
GO

CREATE OR ALTER PROCEDURE finanza.PR_tbPagos_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY v.Pag_FechaPago DESC, v.Pag_Id DESC) AS Fila, v.*
    FROM finanza.VW_PagosListado v
    ORDER BY v.Pag_FechaPago DESC, v.Pag_Id DESC;
END
GO

CREATE OR ALTER PROCEDURE finanza.PR_tbPagos_ListByFecha
    @Fecha datetime
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Desde date = CAST(@Fecha AS date);
    SELECT ROW_NUMBER() OVER (ORDER BY v.Pag_FechaPago DESC, v.Pag_Id DESC) AS Fila, v.*
    FROM finanza.VW_PagosListado v
    WHERE v.Pag_FechaPago >= @Desde AND v.Pag_FechaPago < DATEADD(DAY, 1, @Desde)
    ORDER BY v.Pag_FechaPago DESC, v.Pag_Id DESC;
END
GO

-- El rango incluye el día final completo (hasta las 23:59:59).
CREATE OR ALTER PROCEDURE finanza.PR_tbPagos_ListByRangoFechas
    @FechaInicio datetime,
    @FechaFin    datetime
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Desde date = CAST(@FechaInicio AS date), @Hasta date = CAST(@FechaFin AS date);
    SELECT ROW_NUMBER() OVER (ORDER BY v.Pag_FechaPago DESC, v.Pag_Id DESC) AS Fila, v.*
    FROM finanza.VW_PagosListado v
    WHERE v.Pag_FechaPago >= @Desde AND v.Pag_FechaPago < DATEADD(DAY, 1, @Hasta)
    ORDER BY v.Pag_FechaPago DESC, v.Pag_Id DESC;
END
GO

CREATE OR ALTER PROCEDURE finanza.PR_tbPagos_ListByAlumno
    @Alu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY v.Pag_FechaPago DESC, v.Pag_Id DESC) AS Fila, v.*
    FROM finanza.VW_PagosListado v
    WHERE v.Alu_Id = @Alu_Id
    ORDER BY v.Pag_FechaPago DESC, v.Pag_Id DESC;
END
GO

CREATE OR ALTER PROCEDURE finanza.PR_ObtenerHistoricoPagos
    @Alu_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.Pag_Id,
        p.Pag_FechaPago,
        p.Pag_MontoTotal,
        fp.Fpa_Descripcion,
        p.Pag_NumeroReferencia,
        ISNULL(r1.Rec_NumeroRecibo, p.Pag_NumeroReferencia) AS numeroRecibo,
        CONCAT(per.Per_PrimerNombre, ' ', per.Per_ApellidoPaterno) AS Alumno,
        p.Pag_Observaciones,
        p.Pag_EsAnulado,
        p.Pag_MotivoAnulacion
    FROM finanza.tbPagos p
    INNER JOIN finanza.tbFormasPago fp ON p.Fpa_Id = fp.Fpa_Id
    INNER JOIN app.tbAlumnos alu ON p.Alu_Id = alu.Alu_Id
    LEFT JOIN app.tbPersonas per ON alu.Per_Id = per.Per_Id
    OUTER APPLY (
        SELECT TOP (1) r.Rec_NumeroRecibo FROM finanza.tbRecibos r
        WHERE r.Pag_Id = p.Pag_Id AND r.Rec_EsEliminado = 0
        ORDER BY r.Rec_FechaEmision DESC, r.Rec_Id DESC
    ) r1
    WHERE p.Alu_Id = @Alu_Id
        AND p.Pag_EsEliminado = 0
    ORDER BY p.Pag_FechaPago DESC;
END
GO

/* ---------- 5. Resumen financiero del alumno ---------- */
-- totalPagado = pagos NO anulados del alumno (antes sumaba cuentas en estado Pagado y daba 0).
-- Deuda y pendiente usan lo que realmente falta (Cco_MontoPendiente), no el total del cargo.
CREATE OR ALTER PROCEDURE finanza.PR_ObtenerResumenFinanciero
    @Alu_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ISNULL((SELECT SUM(cc.Cco_MontoPendiente)
                FROM finanza.tbCuentasCobrar cc
                INNER JOIN finanza.tbEstadosPago ep ON ep.Epa_Id = cc.Epa_Id
                WHERE cc.Alu_Id = @Alu_Id AND cc.Cco_EsEliminado = 0
                  AND ep.Epa_Descripcion IN ('Pendiente','Vencido')), 0) AS totalDeuda,
        ISNULL((SELECT SUM(p.Pag_MontoTotal)
                FROM finanza.tbPagos p
                WHERE p.Alu_Id = @Alu_Id AND p.Pag_EsEliminado = 0 AND p.Pag_EsAnulado = 0), 0) AS totalPagado,
        ISNULL((SELECT SUM(cc.Cco_MontoPendiente)
                FROM finanza.tbCuentasCobrar cc
                INNER JOIN finanza.tbEstadosPago ep ON ep.Epa_Id = cc.Epa_Id
                WHERE cc.Alu_Id = @Alu_Id AND cc.Cco_EsEliminado = 0
                  AND ep.Epa_Descripcion = 'Pendiente'), 0) AS totalPendiente,
        ISNULL((SELECT SUM(cc.Cco_MontoMora)
                FROM finanza.tbCuentasCobrar cc
                WHERE cc.Alu_Id = @Alu_Id AND cc.Cco_EsEliminado = 0), 0) AS totalMora;
END
GO

/* ---------- 6. Listado de cuentas por cobrar (incluye pagadas) ---------- */
CREATE OR ALTER PROCEDURE finanza.PR_tbCuentasCobrar_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ROW_NUMBER() OVER (ORDER BY cco.Cco_Id DESC) AS Fila,
        cco.Cco_Id,
        cp.Cpa_Descripcion AS Concepto,
        LTRIM(RTRIM(CONCAT(pa.Per_PrimerNombre, ' ', ISNULL(pa.Per_SegundoNombre, ''), ' ',
                           pa.Per_ApellidoPaterno, ' ', ISNULL(pa.Per_ApellidoMaterno, '')))) AS Alumno,
        cco.Cco_MontoPendiente AS Pendiente,
        CAST(cco.Cco_FechaVencimiento AS datetime) AS FechaVence,
        epa.Epa_Descripcion AS EstadoPago,
        cco.Alu_Id,
        pa.Per_Identidad AS Identidad,
        niv.Niv_Descripcion AS Nivel,
        cun.Cun_Descripcion AS Grado,
        sec.Sec_Descripcion AS Seccion,
        cco.Cco_MontoOriginal AS MontoOriginal,
        cco.Cco_MontoDescuento AS MontoDescuento,
        cco.Cco_MontoMora AS MontoMora,
        cco.Cco_MontoTotal AS MontoTotal,
        CAST(cco.Cco_Mes AS int) AS Mes,
        CAST(cco.Cco_Anio AS int) AS Anio
    FROM finanza.tbCuentasCobrar cco
        INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = cco.Cpa_Id
        INNER JOIN finanza.tbEstadosPago epa ON epa.Epa_Id = cco.Epa_Id
        INNER JOIN app.tbAlumnos a ON a.Alu_Id = cco.Alu_Id
        INNER JOIN app.tbPersonas pa ON pa.Per_Id = a.Per_Id
        LEFT JOIN app.tbNivelesEducativos niv ON niv.Niv_Id = a.Niv_Id
        LEFT JOIN app.tbCursosNiveles cun ON cun.Cun_Id = a.Cun_Id
        LEFT JOIN app.tbSecciones sec ON sec.Sec_Id = a.Sec_Id
    WHERE cco.Cco_EsEliminado = 0
    ORDER BY cco.Cco_Id DESC;
END
GO

/* ---------- 7. Saldo a favor: consulta ---------- */
CREATE OR ALTER FUNCTION finanza.FN_SaldoFavor (@Alu_Id int)
RETURNS decimal(18,2)
AS
BEGIN
    RETURN ISNULL((SELECT SUM(Sfm_Monto) FROM finanza.tbSaldoFavorMovimientos WHERE Alu_Id = @Alu_Id), 0);
END
GO

CREATE OR ALTER PROCEDURE finanza.PR_SaldoFavor_Obtener
    @Alu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @Alu_Id AS AlumnoId, finanza.FN_SaldoFavor(@Alu_Id) AS Saldo;
END
GO

/* ---------- 8. Registrar pago aplicándolo a cargos ---------- */
-- @Cargos: Ids de tbCuentasCobrar separados por coma. Sin cargos, solo se registra el pago
-- (comportamiento anterior). Con cargos, el pago cubre esos cargos del más viejo al más nuevo
-- y lo que sobra entra al saldo a favor del alumno.
CREATE OR ALTER PROCEDURE finanza.PR_tbPagos_Registrar
    @Alu_Id               int,
    @Enc_Id               int = NULL,
    @Fpa_Id               int,
    @Pag_MontoTotal       decimal(18,2),
    @Pag_FechaPago        datetime2(0) = NULL,
    @Pag_NumeroReferencia nvarchar(60) = NULL,
    @Pag_Observaciones    nvarchar(300) = NULL,
    @Usu_Id               int = NULL,
    @Cargos               nvarchar(max) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Usu_Id = ISNULL(NULLIF(@Usu_Id, 0), 1);
    SET @Pag_FechaPago = ISNULL(@Pag_FechaPago, GETDATE());

    IF NOT EXISTS (SELECT 1 FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id)
        THROW 50060, N'El alumno no existe.', 1;
    IF @Pag_MontoTotal IS NULL OR @Pag_MontoTotal <= 0
        THROW 50061, N'El monto del pago debe ser mayor que cero.', 1;
    IF NOT EXISTS (SELECT 1 FROM finanza.tbFormasPago WHERE Fpa_Id = @Fpa_Id AND Fpa_EsEliminado = 0)
        THROW 50062, N'Elija una forma de pago válida.', 1;

    DECLARE @Lista TABLE (Cco_Id int PRIMARY KEY);
    IF @Cargos IS NOT NULL AND LTRIM(RTRIM(@Cargos)) <> ''
        INSERT INTO @Lista (Cco_Id)
        SELECT DISTINCT TRY_CAST(value AS int) FROM STRING_SPLIT(@Cargos, ',')
        WHERE TRY_CAST(value AS int) IS NOT NULL;

    IF EXISTS (SELECT 1 FROM @Lista l
               LEFT JOIN finanza.tbCuentasCobrar c ON c.Cco_Id = l.Cco_Id AND c.Alu_Id = @Alu_Id AND c.Cco_EsEliminado = 0
               WHERE c.Cco_Id IS NULL)
        THROW 50063, N'Uno de los cargos elegidos no pertenece al alumno.', 1;

    DECLARE @Pag_Id int, @Restante decimal(18,2) = @Pag_MontoTotal, @Aplicado decimal(18,2) = 0;

    BEGIN TRAN;

    INSERT INTO finanza.tbPagos (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia,
                                 Pag_Observaciones, Usu_Id, Pag_UsuarioRegistra)
    VALUES (@Alu_Id, @Enc_Id, @Fpa_Id, @Pag_MontoTotal, @Pag_FechaPago, @Pag_NumeroReferencia,
            @Pag_Observaciones, @Usu_Id, @Usu_Id);
    SET @Pag_Id = SCOPE_IDENTITY();

    IF EXISTS (SELECT 1 FROM @Lista)
    BEGIN
        DECLARE @Cco int, @Pend decimal(18,2), @Monto decimal(18,2);
        DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
            SELECT c.Cco_Id, c.Cco_MontoPendiente
            FROM finanza.tbCuentasCobrar c JOIN @Lista l ON l.Cco_Id = c.Cco_Id
            WHERE c.Cco_MontoPendiente > 0
            ORDER BY c.Cco_FechaVencimiento, c.Cco_Id;
        OPEN cur;
        FETCH NEXT FROM cur INTO @Cco, @Pend;
        WHILE @@FETCH_STATUS = 0 AND @Restante > 0
        BEGIN
            SET @Monto = CASE WHEN @Pend < @Restante THEN @Pend ELSE @Restante END;

            INSERT INTO finanza.tbPagosDetalle (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_UsuarioRegistra)
            VALUES (@Pag_Id, @Cco, @Monto, @Usu_Id);

            UPDATE finanza.tbCuentasCobrar
               SET Cco_MontoPendiente = Cco_MontoPendiente - @Monto,
                   Epa_Id = CASE WHEN Cco_MontoPendiente - @Monto <= 0 THEN 2
                                 WHEN Cco_FechaVencimiento < CAST(GETDATE() AS date) THEN 3 ELSE 1 END,
                   Cco_UsuarioModifica = @Usu_Id, Cco_FechaModifica = GETDATE()
             WHERE Cco_Id = @Cco;

            SET @Restante -= @Monto;
            SET @Aplicado += @Monto;
            FETCH NEXT FROM cur INTO @Cco, @Pend;
        END
        CLOSE cur; DEALLOCATE cur;

        IF @Restante > 0
        BEGIN
            INSERT INTO finanza.tbSaldoFavorMovimientos (Alu_Id, Sfm_Origen, Sfm_Monto, Pag_Id, Sfm_Motivo, Sfm_UsuarioRegistra)
            VALUES (@Alu_Id, 'Excedente', @Restante, @Pag_Id, N'Excedente del pago', @Usu_Id);

            INSERT INTO finanza.tbCorrecciones (Alu_Id, Cor_Tipo, Cor_Detalle, Cor_Motivo, Cor_Monto, Pag_Id, Cor_UsuarioRegistra)
            VALUES (@Alu_Id, N'Saldo a favor',
                    CONCAT(N'Excedente del pago #', @Pag_Id, N' (pagó ', FORMAT(@Pag_MontoTotal, 'N2'),
                           N', cubrió ', FORMAT(@Aplicado, 'N2'), N')'),
                    N'El pago superó lo pendiente de los cargos elegidos', @Restante, @Pag_Id, @Usu_Id);
        END
    END

    COMMIT;

    SELECT CAST(@Pag_Id AS decimal(18,0)) AS NewId,
           CASE WHEN EXISTS (SELECT 1 FROM @Lista) THEN @Aplicado ELSE CAST(0 AS decimal(18,2)) END AS MontoAplicado,
           CASE WHEN EXISTS (SELECT 1 FROM @Lista) THEN @Restante ELSE CAST(0 AS decimal(18,2)) END AS Excedente,
           finanza.FN_SaldoFavor(@Alu_Id) AS SaldoFavor;
END
GO

/* ---------- 9. Anular pago ---------- */
CREATE OR ALTER PROCEDURE finanza.PR_tbPagos_Anular
    @Pag_Id  int,
    @Motivo  nvarchar(500),
    @Destino varchar(20),
    @Usu_Id  int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Usu_Id = ISNULL(NULLIF(@Usu_Id, 0), 1);
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');

    DECLARE @Alu_Id int, @Monto decimal(18,2), @Anulado bit, @Fecha datetime2(0);
    SELECT @Alu_Id = Alu_Id, @Monto = Pag_MontoTotal, @Anulado = Pag_EsAnulado, @Fecha = Pag_FechaPago
    FROM finanza.tbPagos WHERE Pag_Id = @Pag_Id AND Pag_EsEliminado = 0;

    IF @Alu_Id IS NULL      THROW 50064, N'El pago no existe.', 1;
    IF @Anulado = 1         THROW 50065, N'El pago ya está anulado.', 1;
    IF @Motivo IS NULL      THROW 50066, N'Escriba el motivo de la anulación.', 1;
    IF @Destino NOT IN ('Devuelto','SaldoFavor')
        THROW 50067, N'Indique qué pasa con el dinero: devuelto o saldo a favor.', 1;

    BEGIN TRAN;

    DECLARE @Excedente decimal(18,2) =
        ISNULL((SELECT SUM(Sfm_Monto) FROM finanza.tbSaldoFavorMovimientos
                WHERE Pag_Id = @Pag_Id AND Sfm_Origen = 'Excedente'), 0);
    IF @Destino = 'Devuelto' AND @Excedente > 0
       AND ISNULL((SELECT SUM(Sfm_Monto) FROM finanza.tbSaldoFavorMovimientos WITH (UPDLOCK, HOLDLOCK)
                   WHERE Alu_Id = @Alu_Id), 0) < @Excedente
        THROW 50068, N'El excedente de este pago ya se usó del saldo a favor; anúlelo enviando el dinero a saldo a favor.', 1;

    -- Lo que el pago cubría vuelve a quedar pendiente (sin pasar del total del cargo).
    DECLARE @Afectadas TABLE (Cco_Id int PRIMARY KEY, Monto decimal(18,2));
    INSERT INTO @Afectadas (Cco_Id, Monto)
    SELECT d.Cco_Id, SUM(d.Pde_MontoAplicado)
    FROM finanza.tbPagosDetalle d
    WHERE d.Pag_Id = @Pag_Id AND d.Pde_EsEliminado = 0
    GROUP BY d.Cco_Id;

    UPDATE c
       SET Cco_MontoPendiente = x.NuevoPendiente,
           Epa_Id = CASE WHEN c.Epa_Id = 4 THEN 4
                         WHEN x.NuevoPendiente <= 0 THEN 2
                         WHEN c.Cco_FechaVencimiento < CAST(GETDATE() AS date) THEN 3 ELSE 1 END,
           Cco_UsuarioModifica = @Usu_Id, Cco_FechaModifica = GETDATE()
    FROM finanza.tbCuentasCobrar c
    JOIN @Afectadas a ON a.Cco_Id = c.Cco_Id
    CROSS APPLY (SELECT NuevoPendiente = CASE WHEN c.Cco_MontoPendiente + a.Monto > c.Cco_MontoTotal
                                              THEN c.Cco_MontoTotal ELSE c.Cco_MontoPendiente + a.Monto END) x;

    INSERT INTO finanza.tbCuentasCobrarHistorial (Cco_Id, Cgh_Accion, Cgh_Detalle, Cgh_Fecha, Cgh_Usuario)
    SELECT a.Cco_Id, N'Reabierto', CONCAT(N'Pago #', @Pag_Id, N' anulado: vuelve a pendiente ', FORMAT(a.Monto, 'N2')), GETDATE(), @Usu_Id
    FROM @Afectadas a;

    UPDATE finanza.tbPagos
       SET Pag_EsAnulado = 1, Pag_MotivoAnulacion = @Motivo, Pag_DestinoAnulacion = @Destino,
           Pag_FechaAnulacion = GETDATE(), Pag_UsuarioAnula = @Usu_Id,
           Pag_UsuarioModifica = @Usu_Id, Pag_FechaModifica = GETDATE()
     WHERE Pag_Id = @Pag_Id;

    INSERT INTO finanza.tbPagosHistorial (Pag_Id, Pgh_Accion, Pgh_Detalle, Pgh_Fecha, Pgh_Usuario)
    VALUES (@Pag_Id, N'Anulado', CONCAT(N'Destino: ', @Destino, N'. Motivo: ', @Motivo), GETDATE(), @Usu_Id);

    -- Lo que el pago dejó como excedente ya estaba en el saldo a favor: si se devuelve, sale de ahí.
    IF @Excedente > 0 AND @Destino = 'Devuelto'
        INSERT INTO finanza.tbSaldoFavorMovimientos (Alu_Id, Sfm_Origen, Sfm_Monto, Pag_Id, Sfm_Motivo, Sfm_UsuarioRegistra)
        VALUES (@Alu_Id, 'Anulacion', -@Excedente, @Pag_Id, N'Pago anulado y devuelto: sale el excedente', @Usu_Id);

    -- Saldo a favor: entra lo que el pago cubría (el excedente ya estaba dentro).
    IF @Destino = 'SaldoFavor' AND @Monto - @Excedente > 0
        INSERT INTO finanza.tbSaldoFavorMovimientos (Alu_Id, Sfm_Origen, Sfm_Monto, Pag_Id, Sfm_Motivo, Sfm_UsuarioRegistra)
        VALUES (@Alu_Id, 'Anulacion', @Monto - @Excedente, @Pag_Id, @Motivo, @Usu_Id);

    INSERT INTO finanza.tbCorrecciones (Alu_Id, Cor_Tipo, Cor_Detalle, Cor_Motivo, Cor_Monto, Pag_Id, Cor_UsuarioRegistra)
    VALUES (@Alu_Id, N'Pago anulado',
            CONCAT(N'Pago #', @Pag_Id, N' del ', FORMAT(@Fecha, 'dd/MM/yyyy'), N'; ',
                   CASE WHEN @Destino = 'Devuelto' THEN N'dinero devuelto' ELSE N'pasa a saldo a favor' END,
                   N'; ', (SELECT COUNT(*) FROM @Afectadas), N' cargo(s) vuelven a pendiente'),
            @Motivo, @Monto, @Pag_Id, @Usu_Id);

    COMMIT;

    SELECT @Pag_Id AS PagoId, @Monto AS Monto, @Destino AS Destino,
           (SELECT COUNT(*) FROM @Afectadas) AS CargosReabiertos,
           finanza.FN_SaldoFavor(@Alu_Id) AS SaldoFavor;
END
GO

/* ---------- 10. Perdonar cargo (exoneración / beca / ajuste) ---------- */
-- Se registra como descuento del cargo: baja el total y el pendiente por el mismo monto.
CREATE OR ALTER PROCEDURE finanza.PR_tbCuentasCobrar_Perdonar
    @Cco_Id int,
    @Monto  decimal(18,2),
    @Tipo   nvarchar(20),
    @Motivo nvarchar(500),
    @Usu_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Usu_Id = ISNULL(NULLIF(@Usu_Id, 0), 1);
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');

    DECLARE @Alu_Id int, @Pend decimal(18,2), @Epa int, @Concepto nvarchar(200);
    SELECT @Alu_Id = c.Alu_Id, @Pend = c.Cco_MontoPendiente, @Epa = c.Epa_Id,
           @Concepto = CONCAT(cp.Cpa_Descripcion,
                              CASE WHEN c.Cco_Mes IS NOT NULL THEN CONCAT(N' ', c.Cco_Mes, N'/', c.Cco_Anio) ELSE N'' END)
    FROM finanza.tbCuentasCobrar c
    JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = c.Cpa_Id
    WHERE c.Cco_Id = @Cco_Id AND c.Cco_EsEliminado = 0;

    IF @Alu_Id IS NULL   THROW 50070, N'El cargo no existe.', 1;
    IF @Epa = 4          THROW 50071, N'El cargo está cancelado.', 1;
    IF @Pend <= 0        THROW 50072, N'El cargo no tiene saldo pendiente.', 1;
    IF @Tipo NOT IN (N'Exoneración', N'Beca', N'Ajuste')
        THROW 50073, N'Elija el tipo: exoneración, beca o ajuste.', 1;
    IF @Motivo IS NULL   THROW 50074, N'Escriba el motivo.', 1;
    IF @Monto IS NULL OR @Monto <= 0
        THROW 50075, N'El monto a perdonar debe ser mayor que cero.', 1;
    IF @Monto > @Pend
        THROW 50076, N'El monto a perdonar no puede ser mayor que lo pendiente del cargo.', 1;

    BEGIN TRAN;

    UPDATE finanza.tbCuentasCobrar
       SET Cco_MontoDescuento = Cco_MontoDescuento + @Monto,
           Cco_MontoTotal     = Cco_MontoTotal - @Monto,
           Cco_MontoPendiente = Cco_MontoPendiente - @Monto,
           Epa_Id = CASE WHEN Cco_MontoPendiente - @Monto <= 0 THEN 2
                         WHEN Cco_FechaVencimiento < CAST(GETDATE() AS date) THEN 3 ELSE 1 END,
           Cco_UsuarioModifica = @Usu_Id, Cco_FechaModifica = GETDATE()
     WHERE Cco_Id = @Cco_Id;

    INSERT INTO finanza.tbCuentasCobrarHistorial (Cco_Id, Cgh_Accion, Cgh_Detalle, Cgh_Fecha, Cgh_Usuario)
    VALUES (@Cco_Id, N'Perdonado', CONCAT(@Tipo, N' de ', FORMAT(@Monto, 'N2'), N'. Motivo: ', @Motivo), GETDATE(), @Usu_Id);

    INSERT INTO finanza.tbCorrecciones (Alu_Id, Cor_Tipo, Cor_Detalle, Cor_Motivo, Cor_Monto, Cco_Id, Cor_UsuarioRegistra)
    VALUES (@Alu_Id, N'Cargo perdonado', CONCAT(@Tipo, N' sobre ', @Concepto, N' (cargo #', @Cco_Id, N')'),
            @Motivo, @Monto, @Cco_Id, @Usu_Id);

    COMMIT;

    SELECT c.Cco_Id AS CuentaCobrarId, c.Cco_MontoPendiente AS Pendiente, c.Cco_MontoTotal AS MontoTotal,
           e.Epa_Descripcion AS EstadoPago
    FROM finanza.tbCuentasCobrar c JOIN finanza.tbEstadosPago e ON e.Epa_Id = c.Epa_Id
    WHERE c.Cco_Id = @Cco_Id;
END
GO

/* ---------- 11. Devolver saldo a favor ---------- */
CREATE OR ALTER PROCEDURE finanza.PR_SaldoFavor_Devolver
    @Alu_Id int,
    @Monto  decimal(18,2),
    @Metodo varchar(20),
    @Motivo nvarchar(500),
    @Usu_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Usu_Id = ISNULL(NULLIF(@Usu_Id, 0), 1);
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');

    IF NOT EXISTS (SELECT 1 FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id)
        THROW 50080, N'El alumno no existe.', 1;
    IF @Monto IS NULL OR @Monto <= 0
        THROW 50081, N'El monto a devolver debe ser mayor que cero.', 1;
    IF @Metodo NOT IN ('Efectivo','Transferencia','Cheque')
        THROW 50082, N'Elija cómo se devuelve: efectivo, transferencia o cheque.', 1;
    IF @Motivo IS NULL
        THROW 50083, N'Escriba el motivo de la devolución.', 1;

    BEGIN TRAN;
    DECLARE @Saldo decimal(18,2) =
        ISNULL((SELECT SUM(Sfm_Monto) FROM finanza.tbSaldoFavorMovimientos WITH (UPDLOCK, HOLDLOCK) WHERE Alu_Id = @Alu_Id), 0);
    IF @Monto > @Saldo
        THROW 50084, N'El monto a devolver supera el saldo a favor del alumno.', 1;

    INSERT INTO finanza.tbSaldoFavorMovimientos (Alu_Id, Sfm_Origen, Sfm_Monto, Sfm_Metodo, Sfm_Motivo, Sfm_UsuarioRegistra)
    VALUES (@Alu_Id, 'Devolucion', -@Monto, @Metodo, @Motivo, @Usu_Id);

    INSERT INTO finanza.tbCorrecciones (Alu_Id, Cor_Tipo, Cor_Detalle, Cor_Motivo, Cor_Monto, Cor_UsuarioRegistra)
    VALUES (@Alu_Id, N'Devolución', CONCAT(N'Saldo a favor devuelto por ', LOWER(@Metodo)), @Motivo, @Monto, @Usu_Id);
    COMMIT;

    SELECT @Alu_Id AS AlumnoId, finanza.FN_SaldoFavor(@Alu_Id) AS Saldo;
END
GO

/* ---------- 12. Aplicar saldo a favor a cargos pendientes ---------- */
CREATE OR ALTER PROCEDURE finanza.PR_SaldoFavor_Aplicar
    @Alu_Id int,
    @Monto  decimal(18,2),
    @Motivo nvarchar(500) = NULL,
    @Usu_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Usu_Id = ISNULL(NULLIF(@Usu_Id, 0), 1);
    SET @Motivo = ISNULL(NULLIF(LTRIM(RTRIM(@Motivo)), N''), N'Aplicación de saldo a favor');

    IF NOT EXISTS (SELECT 1 FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id)
        THROW 50085, N'El alumno no existe.', 1;
    IF @Monto IS NULL OR @Monto <= 0
        THROW 50086, N'El monto a aplicar debe ser mayor que cero.', 1;

    BEGIN TRAN;
    DECLARE @Saldo decimal(18,2) =
        ISNULL((SELECT SUM(Sfm_Monto) FROM finanza.tbSaldoFavorMovimientos WITH (UPDLOCK, HOLDLOCK) WHERE Alu_Id = @Alu_Id), 0);
    DECLARE @Deuda decimal(18,2) =
        ISNULL((SELECT SUM(Cco_MontoPendiente) FROM finanza.tbCuentasCobrar
                WHERE Alu_Id = @Alu_Id AND Cco_EsEliminado = 0 AND Epa_Id IN (1,3) AND Cco_MontoPendiente > 0), 0);
    IF @Monto > @Saldo
        THROW 50087, N'El monto supera el saldo a favor del alumno.', 1;
    IF @Monto > @Deuda
        THROW 50088, N'El monto supera lo que el alumno debe.', 1;

    DECLARE @Restante decimal(18,2) = @Monto, @Cco int, @Pend decimal(18,2), @Aplica decimal(18,2), @Cargos int = 0;
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT Cco_Id, Cco_MontoPendiente FROM finanza.tbCuentasCobrar
        WHERE Alu_Id = @Alu_Id AND Cco_EsEliminado = 0 AND Epa_Id IN (1,3) AND Cco_MontoPendiente > 0
        ORDER BY Cco_FechaVencimiento, Cco_Id;
    OPEN cur;
    FETCH NEXT FROM cur INTO @Cco, @Pend;
    WHILE @@FETCH_STATUS = 0 AND @Restante > 0
    BEGIN
        SET @Aplica = CASE WHEN @Pend < @Restante THEN @Pend ELSE @Restante END;

        UPDATE finanza.tbCuentasCobrar
           SET Cco_MontoPendiente = Cco_MontoPendiente - @Aplica,
               Epa_Id = CASE WHEN Cco_MontoPendiente - @Aplica <= 0 THEN 2
                             WHEN Cco_FechaVencimiento < CAST(GETDATE() AS date) THEN 3 ELSE 1 END,
               Cco_UsuarioModifica = @Usu_Id, Cco_FechaModifica = GETDATE()
         WHERE Cco_Id = @Cco;

        INSERT INTO finanza.tbSaldoFavorMovimientos (Alu_Id, Sfm_Origen, Sfm_Monto, Cco_Id, Sfm_Motivo, Sfm_UsuarioRegistra)
        VALUES (@Alu_Id, 'Aplicacion', -@Aplica, @Cco, @Motivo, @Usu_Id);

        INSERT INTO finanza.tbCuentasCobrarHistorial (Cco_Id, Cgh_Accion, Cgh_Detalle, Cgh_Fecha, Cgh_Usuario)
        VALUES (@Cco, N'Saldo aplicado', CONCAT(N'Se aplicó saldo a favor por ', FORMAT(@Aplica, 'N2')), GETDATE(), @Usu_Id);

        SET @Restante -= @Aplica;
        SET @Cargos += 1;
        FETCH NEXT FROM cur INTO @Cco, @Pend;
    END
    CLOSE cur; DEALLOCATE cur;

    INSERT INTO finanza.tbCorrecciones (Alu_Id, Cor_Tipo, Cor_Detalle, Cor_Motivo, Cor_Monto, Cor_UsuarioRegistra)
    VALUES (@Alu_Id, N'Saldo aplicado', CONCAT(N'Saldo a favor aplicado a ', @Cargos, N' cargo(s) pendiente(s)'),
            @Motivo, @Monto - @Restante, @Usu_Id);
    COMMIT;

    SELECT @Alu_Id AS AlumnoId, @Monto - @Restante AS MontoAplicado, @Cargos AS CargosAfectados,
           finanza.FN_SaldoFavor(@Alu_Id) AS Saldo;
END
GO

/* ---------- 13. Historial de correcciones del alumno ---------- */
CREATE OR ALTER PROCEDURE finanza.PR_Correcciones_ListByAlumno
    @Alu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.Cor_FechaRegistra AS Fecha, c.Cor_Tipo AS Tipo, c.Cor_Detalle AS Detalle, c.Cor_Motivo AS Motivo,
           u.Usu_Name AS Usuario, c.Cor_Monto AS Monto
    FROM finanza.tbCorrecciones c
    LEFT JOIN seguridad.tbUsuarios u ON u.Usu_Id = c.Cor_UsuarioRegistra
    WHERE c.Alu_Id = @Alu_Id
    ORDER BY c.Cor_FechaRegistra DESC, c.Cor_Id DESC;
END
GO

/* ---------- 14. Reportes y dashboards: un pago anulado no cuenta como ingreso ----------
   Se agrega "AND Pag_EsAnulado = 0" junto a cada filtro "Pag_EsEliminado = 0" de los
   procedimientos que suman cobros. Solo toca los que aún no lo tienen. */
DECLARE @Procs TABLE (Nombre sysname);
INSERT INTO @Procs VALUES
    ('app.PR_DashboardCajero_Hoy'), ('app.PR_DashboardDirector_KPIs'), ('app.PR_DashboardFinanciero_Resumen'),
    ('dbo.PR_HistorialTransacciones_List'), ('dbo.PR_PagosDelDia_List'),
    ('finanza.PR_Finanza_EstadoResultados'), ('finanza.PR_Finanza_FlujoCaja'),
    ('finanza.PR_Finanza_HistorialTransacciones'), ('finanza.PR_Finanza_PagosDelDia'),
    ('finanza.PR_KPIs_Financieros'), ('finanza.PR_tbFormasPago_Detail');

DECLARE @Nombre sysname, @Def nvarchar(max), @Pos int;
DECLARE procs CURSOR LOCAL FAST_FORWARD FOR SELECT Nombre FROM @Procs;
OPEN procs;
FETCH NEXT FROM procs INTO @Nombre;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Def = OBJECT_DEFINITION(OBJECT_ID(@Nombre));
    IF @Def IS NOT NULL AND @Def NOT LIKE N'%Pag_EsAnulado%'
    BEGIN
        WHILE CHARINDEX(N'Pag_EsEliminado  ', @Def) > 0
            SET @Def = REPLACE(@Def, N'Pag_EsEliminado  ', N'Pag_EsEliminado ');
        SET @Def = REPLACE(@Def, N'Pag_EsEliminado=0',   N'Pag_EsEliminado = 0');
        SET @Def = REPLACE(@Def, N'Pag_EsEliminado= 0',  N'Pag_EsEliminado = 0');
        SET @Def = REPLACE(@Def, N'Pag_EsEliminado =0',  N'Pag_EsEliminado = 0');
        SET @Def = REPLACE(@Def, N'Pag_EsEliminado = 0', N'Pag_EsEliminado = 0 AND Pag_EsAnulado = 0');
        SET @Pos = CHARINDEX(N'CREATE', @Def);
        SET @Def = STUFF(@Def, @Pos, 6, N'ALTER');
        EXEC sys.sp_executesql @Def;
    END
    FETCH NEXT FROM procs INTO @Nombre;
END
CLOSE procs; DEALLOCATE procs;
GO

/* ---------- 15. Permiso: pantalla "Corregir cuentas" ---------- */
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(100));
INSERT INTO @Pantallas VALUES (N'Corregir cuentas', N'|1|1002|1006|');

INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
SELECT x.Nombre, 1, 0, 'Financiero'
FROM @Pantallas x
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas p WHERE p.Pan_Descripcion = x.Nombre);

INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN @Pantallas x ON x.Nombre = p.Pan_Descripcion
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0
                        AND x.Roles LIKE N'%|' + CONVERT(nvarchar(10), r.Rol_Id) + N'|%'
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas y WHERE y.Rol_Id = r.Rol_Id AND y.Pan_Id = p.Pan_Id);
GO
