/* =============================================================================
   081 · Centro de reportes  (espejo de Skuul: ReportDesk + ReportRegistry + ReportRun)

   - Un solo lugar para pedir cualquier reporte con sus filtros, verlo y bajarlo en Excel o PDF.
     El catálogo de reportes vive en el ADM (cada reporte dice qué pantalla de origen se necesita
     para verlo y ejecutarlo). Casi todos reutilizan los procedimientos que ya existían; aquí solo
     se agregan los que faltaban:
       app.PR_CentroReportes_ListaClase           lista de clase por sección (año lectivo)
       app.PR_CentroReportes_SaldosAlumno         saldo de cada alumno del año (cargado, pagado, vencido)
       app.PR_CentroReportes_IngresosConcepto     dinero cobrado en un rango por concepto y forma de pago
       app.PR_CentroReportes_AsistenciaPersonal   resumen de asistencia del personal por empleado
   - app.tbReportesGenerados: cada reporte que genera una persona (como ReportRun de Skuul),
     con sus parámetros, estado (listo | fallo), filas y error. Sirve para "Recientes": repetir
     un reporte con un clic. Se guardan los últimos 200 de cada usuario.
   - Permiso: "Centro de reportes" (admin, director, secretaria, recursos humanos, cajero, contador).
     Cada reporte además exige la pantalla de origen; eso se valida en el ADM.
   - Prefijo: Rge_. Errores 50081-50089.
   Idempotente: se puede correr varias veces.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ─────────────────────────────── Tabla ─────────────────────────────── */
IF OBJECT_ID(N'app.tbReportesGenerados', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbReportesGenerados
    (
        Rge_Id          int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbReportesGenerados PRIMARY KEY,
        Usu_Id          int               NOT NULL,
        Rge_Clave       nvarchar(60)      NOT NULL,
        Rge_Titulo      nvarchar(150)     NOT NULL,
        Rge_Parametros  nvarchar(2000)    NOT NULL CONSTRAINT DF_tbReportesGenerados_Parametros DEFAULT (N'{}'),
        Rge_Resumen     nvarchar(500)     NULL,
        Rge_Estado      varchar(10)       NOT NULL,
        Rge_Filas       int               NULL,
        Rge_Error       nvarchar(400)     NULL,
        Rge_Fecha       datetime2(0)      NOT NULL CONSTRAINT DF_tbReportesGenerados_Fecha DEFAULT (SYSDATETIME()),
        CONSTRAINT CK_tbReportesGenerados_Estado CHECK (Rge_Estado IN ('listo', 'fallo')),
        CONSTRAINT FK_tbReportesGenerados_Usuario FOREIGN KEY (Usu_Id) REFERENCES seguridad.tbUsuarios (Usu_Id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_tbReportesGenerados_Usuario'
                                            AND object_id = OBJECT_ID(N'app.tbReportesGenerados'))
    CREATE INDEX IX_tbReportesGenerados_Usuario ON app.tbReportesGenerados (Usu_Id, Rge_Id DESC);
GO

/* ─────────────────────────────── Recientes ─────────────────────────────── */
-- Registra una ejecución y deja solo las últimas 200 del usuario.
CREATE OR ALTER PROCEDURE app.PR_tbReportesGenerados_Registrar
    @Usu_Id         int,
    @Rge_Clave      nvarchar(60),
    @Rge_Titulo     nvarchar(150),
    @Rge_Parametros nvarchar(2000),
    @Rge_Resumen    nvarchar(500) = NULL,
    @Rge_Estado     varchar(10),
    @Rge_Filas      int = NULL,
    @Rge_Error      nvarchar(400) = NULL,
    @Rge_Fecha      datetime2(0) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM seguridad.tbUsuarios WHERE Usu_Id = @Usu_Id)
        THROW 50081, N'El usuario no existe.', 1;
    IF @Rge_Estado NOT IN ('listo', 'fallo')
        THROW 50082, N'El estado del reporte no es válido.', 1;
    IF NULLIF(LTRIM(RTRIM(@Rge_Clave)), N'') IS NULL OR NULLIF(LTRIM(RTRIM(@Rge_Titulo)), N'') IS NULL
        THROW 50083, N'Falta el reporte.', 1;

    BEGIN TRAN;
        INSERT INTO app.tbReportesGenerados
            (Usu_Id, Rge_Clave, Rge_Titulo, Rge_Parametros, Rge_Resumen, Rge_Estado, Rge_Filas, Rge_Error, Rge_Fecha)
        VALUES
            (@Usu_Id, LTRIM(RTRIM(@Rge_Clave)), LTRIM(RTRIM(@Rge_Titulo)), COALESCE(NULLIF(@Rge_Parametros, N''), N'{}'),
             @Rge_Resumen, @Rge_Estado, @Rge_Filas, LEFT(@Rge_Error, 400), COALESCE(@Rge_Fecha, SYSDATETIME()));

        DECLARE @Rge_Id int = CAST(SCOPE_IDENTITY() AS int);

        DELETE FROM app.tbReportesGenerados
        WHERE Usu_Id = @Usu_Id
          AND Rge_Id NOT IN (SELECT TOP (200) Rge_Id FROM app.tbReportesGenerados
                             WHERE Usu_Id = @Usu_Id ORDER BY Rge_Id DESC);
    COMMIT;

    SELECT @Rge_Id AS Rge_Id;
END
GO

-- Últimos reportes distintos (mismo reporte con los mismos parámetros = una sola fila).
CREATE OR ALTER PROCEDURE app.PR_tbReportesGenerados_Recientes
    @Usu_Id int,
    @Top    int = 30
AS
BEGIN
    SET NOCOUNT ON;
    IF @Top IS NULL OR @Top < 1 SET @Top = 30;
    IF @Top > 100 SET @Top = 100;

    WITH r AS (
        SELECT g.Rge_Id, g.Rge_Clave, g.Rge_Titulo, g.Rge_Parametros, g.Rge_Resumen, g.Rge_Estado,
               g.Rge_Filas, g.Rge_Error, g.Rge_Fecha,
               ROW_NUMBER() OVER (PARTITION BY g.Rge_Clave, g.Rge_Parametros ORDER BY g.Rge_Id DESC) AS Orden,
               COUNT(*)     OVER (PARTITION BY g.Rge_Clave, g.Rge_Parametros)                      AS Veces
        FROM app.tbReportesGenerados g
        WHERE g.Usu_Id = @Usu_Id
    )
    SELECT TOP (@Top) Rge_Id, Rge_Clave, Rge_Titulo, Rge_Parametros, Rge_Resumen, Rge_Estado,
                      Rge_Filas, Rge_Error, Rge_Fecha, Veces
    FROM r
    WHERE Orden = 1
    ORDER BY Rge_Id DESC;
END
GO

/* ─────────────────────────────── Lista de clase ─────────────────────────────── */
-- Alumnos matriculados en el año por sección. Filtros en cascada: nivel → grado → sección.
CREATE OR ALTER PROCEDURE app.PR_CentroReportes_ListaClase
    @Ani_Id      int,
    @Niv_Id      int  = NULL,
    @Cun_Id      int  = NULL,
    @Sea_Id      int  = NULL,
    @SoloActivos bit  = 1,
    @Hoy         date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Hoy = COALESCE(@Hoy, CAST(GETDATE() AS date));

    SELECT
        ne.Niv_Descripcion AS Nivel,
        cn.Cun_Descripcion AS Grado,
        COALESCE(NULLIF(LTRIM(RTRIM(sa.Sea_Nombre)), N''), CONCAT_WS(N' ', cn.Cun_Descripcion, s.Sec_Descripcion)) AS Seccion,
        CAST(ROW_NUMBER() OVER (PARTITION BY sa.Sea_Id
                                ORDER BY p.Per_ApellidoPaterno, p.Per_ApellidoMaterno, p.Per_PrimerNombre, p.Per_SegundoNombre) AS int) AS Numero,
        a.Alu_Id,
        LTRIM(RTRIM(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N''))))
            + N', ' +
        LTRIM(RTRIM(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), N'')))) AS Alumno,
        p.Per_Identidad       AS Identidad,
        p.Per_Sexo            AS Sexo,
        p.Per_FechaNacimiento AS FechaNacimiento,
        CASE WHEN p.Per_FechaNacimiento IS NULL THEN NULL
             ELSE DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy)
                  - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy), p.Per_FechaNacimiento) > @Hoy THEN 1 ELSE 0 END
        END                   AS Edad,
        p.Per_Telefono        AS Telefono,
        CASE m.Mta_Estado WHEN 1 THEN N'Activa' WHEN 2 THEN N'Promovido' WHEN 3 THEN N'Repite'
                          WHEN 4 THEN N'Retirado' WHEN 5 THEN N'Graduado' ELSE N'—' END AS EstadoMatricula
    FROM app.tbMatriculaAnio m
    JOIN app.tbSeccionesAnio sa          ON sa.Sea_Id = m.Sea_Id AND sa.Sea_EsEliminado = 0
    JOIN app.tbAlumnos a                 ON a.Alu_Id  = m.Alu_Id
    JOIN app.tbPersonas p                ON p.Per_Id  = a.Per_Id
    LEFT JOIN app.tbNivelesEducativos ne ON ne.Niv_Id = sa.Niv_Id
    LEFT JOIN app.tbCursosNiveles cn     ON cn.Cun_Id = sa.Cun_Id
    LEFT JOIN app.tbSecciones s          ON s.Sec_Id  = sa.Sec_Id
    WHERE m.Ani_Id = @Ani_Id
      AND m.Mta_EsEliminado = 0
      AND (@SoloActivos = 0 OR m.Mta_Estado = 1)
      AND (@Niv_Id IS NULL OR sa.Niv_Id = @Niv_Id)
      AND (@Cun_Id IS NULL OR sa.Cun_Id = @Cun_Id)
      AND (@Sea_Id IS NULL OR sa.Sea_Id = @Sea_Id)
    ORDER BY sa.Niv_Id, cn.Cun_Orden, sa.Cun_Id, Seccion, Numero;
END
GO

/* ─────────────────────────────── Saldos por alumno ─────────────────────────────── */
-- Cargos vivos del alumno (sin eliminados ni cancelados): cargado, pagado, saldo y vencido a la fecha.
CREATE OR ALTER PROCEDURE app.PR_CentroReportes_SaldosAlumno
    @Ani_Id       int,
    @Niv_Id       int  = NULL,
    @Cun_Id       int  = NULL,
    @Sea_Id       int  = NULL,
    @SoloConSaldo bit  = 1,
    @Hoy          date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Hoy = COALESCE(@Hoy, CAST(GETDATE() AS date));

    WITH alumnos AS (
        SELECT m.Alu_Id, sa.Sea_Id, sa.Niv_Id, sa.Cun_Id,
               ne.Niv_Descripcion AS Nivel, cn.Cun_Descripcion AS Grado, cn.Cun_Orden,
               COALESCE(NULLIF(LTRIM(RTRIM(sa.Sea_Nombre)), N''), CONCAT_WS(N' ', cn.Cun_Descripcion, s.Sec_Descripcion)) AS Seccion
        FROM app.tbMatriculaAnio m
        JOIN app.tbSeccionesAnio sa          ON sa.Sea_Id = m.Sea_Id AND sa.Sea_EsEliminado = 0
        LEFT JOIN app.tbNivelesEducativos ne ON ne.Niv_Id = sa.Niv_Id
        LEFT JOIN app.tbCursosNiveles cn     ON cn.Cun_Id = sa.Cun_Id
        LEFT JOIN app.tbSecciones s          ON s.Sec_Id  = sa.Sec_Id
        WHERE m.Ani_Id = @Ani_Id
          AND m.Mta_EsEliminado = 0
          AND (@Niv_Id IS NULL OR sa.Niv_Id = @Niv_Id)
          AND (@Cun_Id IS NULL OR sa.Cun_Id = @Cun_Id)
          AND (@Sea_Id IS NULL OR sa.Sea_Id = @Sea_Id)
    ),
    cargos AS (
        SELECT c.Alu_Id,
               SUM(c.Cco_MontoTotal)     AS Cargado,
               SUM(c.Cco_MontoPendiente) AS Saldo,
               SUM(CASE WHEN c.Cco_MontoPendiente > 0 AND c.Cco_FechaVencimiento < @Hoy THEN c.Cco_MontoPendiente ELSE 0 END) AS Vencido,
               SUM(CASE WHEN c.Cco_MontoPendiente > 0 AND c.Cco_FechaVencimiento < @Hoy THEN 1 ELSE 0 END)                    AS CargosVencidos
        FROM finanza.tbCuentasCobrar c
        WHERE c.Cco_EsEliminado = 0
          AND c.Epa_Id <> 4                                   -- 4 = Cancelado
          AND c.Alu_Id IN (SELECT Alu_Id FROM alumnos)
        GROUP BY c.Alu_Id
    ),
    pagos AS (
        SELECT pg.Alu_Id, MAX(pg.Pag_FechaPago) AS UltimoPago
        FROM finanza.tbPagos pg
        WHERE pg.Pag_EsEliminado = 0
          AND ISNULL(pg.Pag_EsAnulado, 0) = 0
          AND pg.Alu_Id IN (SELECT Alu_Id FROM alumnos)
        GROUP BY pg.Alu_Id
    )
    SELECT
        al.Nivel, al.Grado, al.Seccion,
        al.Alu_Id,
        LTRIM(RTRIM(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N''))))
            + N', ' +
        LTRIM(RTRIM(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), N'')))) AS Alumno,
        p.Per_Identidad                                         AS Identidad,
        p.Per_Telefono                                          AS Telefono,
        CAST(ISNULL(cg.Cargado, 0) AS decimal(12,2))            AS Cargado,
        CAST(ISNULL(cg.Cargado, 0) - ISNULL(cg.Saldo, 0) AS decimal(12,2)) AS Pagado,
        CAST(ISNULL(cg.Saldo, 0) AS decimal(12,2))              AS Saldo,
        CAST(ISNULL(cg.Vencido, 0) AS decimal(12,2))            AS Vencido,
        ISNULL(cg.CargosVencidos, 0)                            AS CargosVencidos,
        pa.UltimoPago
    FROM alumnos al
    JOIN app.tbAlumnos a  ON a.Alu_Id = al.Alu_Id
    JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id
    LEFT JOIN cargos cg   ON cg.Alu_Id = al.Alu_Id
    LEFT JOIN pagos pa    ON pa.Alu_Id = al.Alu_Id
    WHERE (@SoloConSaldo = 0 OR ISNULL(cg.Saldo, 0) > 0)
    ORDER BY al.Niv_Id, al.Cun_Orden, al.Cun_Id, al.Seccion, Alumno;
END
GO

/* ─────────────────────────────── Ingresos por concepto ─────────────────────────────── */
-- Dinero cobrado en el rango (pagos no anulados) por concepto y forma de pago. Lo que un pago
-- no aplicó a ningún cargo (anticipo o saldo a favor) sale como "Sin aplicar a un cargo" y,
-- si aplicó más de lo que entró, se reparte lo que entró: así la suma cuadra con la caja.
CREATE OR ALTER PROCEDURE app.PR_CentroReportes_IngresosConcepto
    @Desde  date,
    @Hasta  date,
    @Cpa_Id int = NULL,
    @Fpa_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Desde IS NULL OR @Hasta IS NULL
        THROW 50084, N'Falta el rango de fechas.', 1;
    IF @Desde > @Hasta
        THROW 50085, N'La fecha «Desde» tiene que ser anterior o igual a la fecha «Hasta».', 1;

    WITH pagos AS (
        SELECT pg.Pag_Id, pg.Alu_Id, pg.Fpa_Id, pg.Pag_MontoTotal
        FROM finanza.tbPagos pg
        WHERE pg.Pag_EsEliminado = 0
          AND ISNULL(pg.Pag_EsAnulado, 0) = 0
          AND pg.Pag_FechaPago >= @Desde
          AND pg.Pag_FechaPago <  DATEADD(DAY, 1, @Hasta)
          AND (@Fpa_Id IS NULL OR pg.Fpa_Id = @Fpa_Id)
    ),
    detalle AS (
        SELECT pg.Pag_Id, pg.Alu_Id, pg.Fpa_Id, pg.Pag_MontoTotal, c.Cpa_Id, d.Pde_MontoAplicado,
               SUM(d.Pde_MontoAplicado) OVER (PARTITION BY pg.Pag_Id) AS AplicadoPago
        FROM pagos pg
        JOIN finanza.tbPagosDetalle d   ON d.Pag_Id = pg.Pag_Id AND d.Pde_EsEliminado = 0
        JOIN finanza.tbCuentasCobrar c  ON c.Cco_Id = d.Cco_Id
    ),
    -- Si un pago aplicó más de lo que entró (usó saldo a favor), se reparte solo lo que entró.
    aplicado AS (
        SELECT Pag_Id, Alu_Id, Fpa_Id, Cpa_Id,
               CAST(CASE WHEN AplicadoPago > Pag_MontoTotal AND AplicadoPago > 0
                         THEN CAST(Pde_MontoAplicado AS decimal(18,6)) * Pag_MontoTotal / AplicadoPago
                         ELSE Pde_MontoAplicado END AS decimal(18,6)) AS Monto
        FROM detalle
    ),
    sinAplicar AS (
        SELECT pg.Pag_Id, pg.Alu_Id, pg.Fpa_Id, CAST(NULL AS int) AS Cpa_Id,
               pg.Pag_MontoTotal - ISNULL((SELECT SUM(a.Monto) FROM aplicado a WHERE a.Pag_Id = pg.Pag_Id), 0) AS Monto
        FROM pagos pg
    ),
    todo AS (
        SELECT Pag_Id, Alu_Id, Fpa_Id, Cpa_Id, Monto FROM aplicado
        UNION ALL
        SELECT Pag_Id, Alu_Id, Fpa_Id, Cpa_Id, Monto FROM sinAplicar WHERE Monto > 0 AND @Cpa_Id IS NULL
    )
    SELECT
        COALESCE(cp.Cpa_Descripcion, N'Sin aplicar a un cargo') AS Concepto,
        COALESCE(fp.Fpa_Descripcion, N'—')                      AS FormaPago,
        COUNT(DISTINCT t.Pag_Id)                                AS Pagos,
        COUNT(DISTINCT t.Alu_Id)                                AS Alumnos,
        CAST(SUM(t.Monto) AS decimal(12,2))                     AS Monto
    FROM todo t
    LEFT JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = t.Cpa_Id
    LEFT JOIN finanza.tbFormasPago fp    ON fp.Fpa_Id = t.Fpa_Id
    WHERE (@Cpa_Id IS NULL OR t.Cpa_Id = @Cpa_Id)
    GROUP BY cp.Cpa_Descripcion, fp.Fpa_Descripcion
    ORDER BY Monto DESC, Concepto, FormaPago;
END
GO

/* ─────────────────────────────── Asistencia del personal ─────────────────────────────── */
-- Resumen por empleado en el rango: días con registro por tipo y % de asistencia
-- (presente + tardanza sobre presente + tardanza + ausente; los permisos no cuentan en contra).
CREATE OR ALTER PROCEDURE app.PR_CentroReportes_AsistenciaPersonal
    @Desde date,
    @Hasta date
AS
BEGIN
    SET NOCOUNT ON;
    IF @Desde IS NULL OR @Hasta IS NULL
        THROW 50086, N'Falta el rango de fechas.', 1;
    IF @Desde > @Hasta
        THROW 50087, N'La fecha «Desde» tiene que ser anterior o igual a la fecha «Hasta».', 1;

    WITH r AS (
        SELECT ae.Emp_Id,
               SUM(CASE WHEN ae.AsiEmp_Tipo = N'Presente' THEN 1 ELSE 0 END) AS Presente,
               SUM(CASE WHEN ae.AsiEmp_Tipo = N'Tardanza' THEN 1 ELSE 0 END) AS Tardanza,
               SUM(CASE WHEN ae.AsiEmp_Tipo = N'Ausente'  THEN 1 ELSE 0 END) AS Ausente,
               SUM(CASE WHEN ae.AsiEmp_Tipo = N'Permiso'  THEN 1 ELSE 0 END) AS Permiso,
               COUNT(*)                                                     AS Registros,
               MAX(CASE WHEN ae.AsiEmp_Tipo = N'Ausente' THEN ae.AsiEmp_Fecha END) AS UltimaAusencia
        FROM app.tbAsistenciaEmpleados ae
        WHERE ae.AsiEmp_EsEliminado = 0
          AND ae.AsiEmp_Fecha >= @Desde
          AND ae.AsiEmp_Fecha <  DATEADD(DAY, 1, @Hasta)
        GROUP BY ae.Emp_Id
    )
    SELECT
        e.Emp_Id,
        e.Emp_Codigo                                                          AS Codigo,
        LTRIM(RTRIM(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), N''),
                                    NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N'')))) AS Empleado,
        ca.Car_Descripcion                                                    AS Cargo,
        r.Registros, r.Presente, r.Tardanza, r.Ausente, r.Permiso,
        CAST(CASE WHEN r.Presente + r.Tardanza + r.Ausente = 0 THEN NULL
                  ELSE 100.0 * (r.Presente + r.Tardanza) / (r.Presente + r.Tardanza + r.Ausente) END AS decimal(5,2)) AS PorcAsistencia,
        r.UltimaAusencia
    FROM r
    JOIN app.tbEmpleados e    ON e.Emp_Id = r.Emp_Id
    JOIN app.tbPersonas p     ON p.Per_Id = e.Per_Id
    LEFT JOIN app.tbCargos ca ON ca.Car_Id = e.Car_Id
    ORDER BY CASE WHEN r.Presente + r.Tardanza + r.Ausente = 0 THEN 1 ELSE 0 END, PorcAsistencia, r.Ausente DESC, Empleado;
END
GO

/* ─────────────────────────────── Permisos ─────────────────────────────── */
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES
    (N'Centro de reportes', N'|admin|director|secretaria|recursos humanos|cajero|contador|');

INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
SELECT x.Nombre, 1, 0, 'Reportes'
FROM @Pantallas x
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas p WHERE p.Pan_Descripcion = x.Nombre);

INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN @Pantallas x ON x.Nombre = p.Pan_Descripcion
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0
                        AND x.Roles LIKE N'%|' + LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) + N'|%'
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas y WHERE y.Rol_Id = r.Rol_Id AND y.Pan_Id = p.Pan_Id);
GO
