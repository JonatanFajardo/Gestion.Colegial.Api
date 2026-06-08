-- =============================================
-- Script: Stored Procedures funcionales
--         Dashboards, búsquedas, reportes y operativos
-- Base de datos: DB_GestionColegial
-- Requisitos: Scripts 001-006 ejecutados antes
-- =============================================

USE DB_GestionColegial;
GO

-- ============================================================
-- DASHBOARDS (8 SPs)
-- ============================================================

-- -------------------------------------------------------
-- PR_DashboardAdmin_Resumen
-- -------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_DashboardAdmin_Resumen]') AND type = 'P')
    DROP PROCEDURE [app].[PR_DashboardAdmin_Resumen];
GO
CREATE PROCEDURE [app].[PR_DashboardAdmin_Resumen]
AS
BEGIN
    SET NOCOUNT ON;

    -- KPIs del sistema
    SELECT
        (SELECT COUNT(*) FROM [Seguridad].[tbUsuarios]  WHERE Usu_EsActivo = 1 AND Usu_EsEliminado = 0)         AS TotalUsuariosActivos,
        (SELECT COUNT(*) FROM [Seguridad].[tbRoles]     WHERE Rol_EsEliminado = 0)                               AS TotalRoles,
        (SELECT COUNT(*) FROM [Seguridad].[tbPantallas] WHERE Pan_Estado = 1 AND Pan_EsEliminado = 0)             AS TotalPantallas,
        (SELECT COUNT(*) FROM [Seguridad].[tbBitacora]  WHERE CAST(Bit_Fecha AS DATE) = CAST(GETDATE() AS DATE)) AS AccionesHoy;

    -- Ultimas 15 acciones en bitacora
    SELECT TOP 15
        b.Bit_Id, u.Usu_Name, b.Bit_Accion,
        b.Bit_Tabla, b.Bit_Descripcion, b.Bit_Ip, b.Bit_Fecha
    FROM [Seguridad].[tbBitacora] b
    INNER JOIN [Seguridad].[tbUsuarios] u ON b.Usu_Id = u.Usu_Id
    ORDER BY b.Bit_Fecha DESC;

    -- Usuarios agrupados por rol
    SELECT r.Rol_Descripcion, COUNT(u.Usu_Id) AS Total
    FROM [Seguridad].[tbRoles] r
    LEFT JOIN [Seguridad].[tbUsuarios] u ON r.Rol_Id = u.Rol_Id AND u.Usu_EsEliminado = 0
    WHERE r.Rol_EsEliminado = 0
    GROUP BY r.Rol_Id, r.Rol_Descripcion
    ORDER BY Total DESC;
END
GO

-- -------------------------------------------------------
-- PR_DashboardDirector_KPIs
-- -------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_DashboardDirector_KPIs]') AND type = 'P')
    DROP PROCEDURE [app].[PR_DashboardDirector_KPIs];
GO
CREATE PROCEDURE [app].[PR_DashboardDirector_KPIs]
    @Anio INT = NULL,
    @Mes  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());
    IF @Mes  IS NULL SET @Mes  = MONTH(GETDATE());

    -- KPIs globales
    SELECT
        (SELECT COUNT(*) FROM [app].[tbAlumnos] WHERE AnioCursado = @Anio)                                                                                                  AS TotalAlumnos,
        (SELECT COUNT(*) FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0)              AS TotalEmpleados,
        (SELECT ISNULL(SUM(Pag_MontoTotal), 0) FROM [finanza].[tbPagos] WHERE YEAR(Pag_FechaPago) = @Anio AND MONTH(Pag_FechaPago) = @Mes AND Pag_EsEliminado = 0)          AS TotalCobradoMes,
        (SELECT ISNULL(SUM(Cco_MontoPendiente), 0) FROM [finanza].[tbCuentasCobrar] WHERE Cco_Anio = @Anio AND Cco_EsEliminado = 0 AND Cco_MontoPendiente > 0)              AS TotalDeudaPendiente,
        (SELECT COUNT(*) FROM [finanza].[tbCuentasCobrar] WHERE Cco_FechaVencimiento < GETDATE() AND Cco_MontoPendiente > 0 AND Cco_Anio = @Anio AND Cco_EsEliminado = 0)  AS CuentasVencidas;

    -- Matricula por curso
    SELECT c.Cur_Nombre, COUNT(a.Alu_Id) AS TotalAlumnos
    FROM [app].[tbCursos] c
    LEFT JOIN [app].[tbAlumnos] a ON c.Cur_Id = a.Cur_Id AND a.AnioCursado = @Anio
    WHERE c.Cur_EsEliminado = 0
    GROUP BY c.Cur_Id, c.Cur_Nombre
    ORDER BY TotalAlumnos DESC;

    -- Cobros por mes (últimos 6 meses)
    SELECT MONTH(Pag_FechaPago) AS Mes, YEAR(Pag_FechaPago) AS Anio,
           ISNULL(SUM(Pag_MontoTotal), 0) AS TotalCobrado
    FROM [finanza].[tbPagos]
    WHERE Pag_FechaPago >= DATEADD(MONTH, -5, DATEFROMPARTS(@Anio, @Mes, 1))
      AND Pag_EsEliminado = 0
    GROUP BY YEAR(Pag_FechaPago), MONTH(Pag_FechaPago)
    ORDER BY Anio, Mes;
END
GO

-- -------------------------------------------------------
-- PR_DashboardDocente_Hoy
-- -------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_DashboardDocente_Hoy]') AND type = 'P')
    DROP PROCEDURE [app].[PR_DashboardDocente_Hoy];
GO
CREATE PROCEDURE [app].[PR_DashboardDocente_Hoy]
    @Emp_Id INT,
    @Dia_Id INT,
    @Anio   INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());

    -- Clases del dia con indicador de asistencia registrada
    SELECT
        h.Hor_Id,
        m.Mat_Nombre,
        a.Aul_Descripcion,
        s.Sec_Descripcion,
        c.Cur_Nombre,
        cn.Cun_Descripcion,
        hi.Hor_Hora AS HoraInicio,
        hf.Hor_Hora AS HoraFin,
        (SELECT COUNT(*) FROM [app].[tbAsistencia] ast
         WHERE ast.Hor_Id = h.Hor_Id
           AND ast.Asi_Fecha = CAST(GETDATE() AS DATE)
           AND ast.Asi_EsEliminado = 0) AS AsistenciaRegistrada
    FROM [app].[tbHorario] h
    INNER JOIN [app].[tbMaterias]      m  ON h.Mat_Id = m.Mat_Id
    INNER JOIN [app].[tbAulas]         a  ON h.Aul_Id = a.Aul_Id
    INNER JOIN [app].[tbSecciones]     s  ON h.Sec_Id = s.Sec_Id
    INNER JOIN [app].[tbCursos]        c  ON h.Cur_Id = c.Cur_Id
    INNER JOIN [app].[tbCursosNiveles] cn ON h.Cun_Id = cn.Cun_Id
    INNER JOIN [app].[tbHoras]         hi ON h.Hor_HoraInicio   = hi.Hor_Id
    INNER JOIN [app].[tbHoras]         hf ON h.Hor_HoraFinaliza = hf.Hor_Id
    WHERE h.Emp_Id = @Emp_Id
      AND h.Dia_Id = @Dia_Id
      AND h.Hor_Año = @Anio
      AND h.Hor_EsEliminado = 0
    ORDER BY hi.Hor_Hora;

    -- KPIs del docente
    SELECT
        (SELECT COUNT(DISTINCT alm.Alu_Id)
         FROM [app].[tbHorario] h2
         INNER JOIN [app].[tbAlumnos] alm ON h2.Cur_Id = alm.Cur_Id AND h2.Sec_Id = alm.Sec_Id
         WHERE h2.Emp_Id = @Emp_Id AND h2.Hor_Año = @Anio AND h2.Hor_EsEliminado = 0) AS TotalAlumnos,
        (SELECT COUNT(DISTINCT h3.Mat_Id)
         FROM [app].[tbHorario] h3
         WHERE h3.Emp_Id = @Emp_Id AND h3.Hor_Año = @Anio AND h3.Hor_EsEliminado = 0) AS TotalMaterias;
END
GO

-- -------------------------------------------------------
-- PR_DashboardSecretaria_Resumen
-- -------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_DashboardSecretaria_Resumen]') AND type = 'P')
    DROP PROCEDURE [app].[PR_DashboardSecretaria_Resumen];
GO
CREATE PROCEDURE [app].[PR_DashboardSecretaria_Resumen]
    @Anio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());

    -- KPIs de matricula
    SELECT
        (SELECT COUNT(*) FROM [app].[tbAlumnos] WHERE AnioCursado = @Anio)                                                                                                                                       AS TotalMatriculados,
        (SELECT COUNT(*) FROM [app].[tbAlumnos] al INNER JOIN [app].[tbPersonas] p ON al.Per_Id = p.Per_Id WHERE al.AnioCursado = @Anio AND YEAR(p.Per_FechaRegistra) = @Anio AND MONTH(p.Per_FechaRegistra) = MONTH(GETDATE())) AS NuevasMesActual,
        (SELECT COUNT(*) FROM [app].[tbDocumentosAlumno] WHERE Doa_EsEntregado = 0 AND Doa_EsEliminado = 0) AS DocumentosPendientes,
        (SELECT COUNT(*) FROM [app].[tbPersonas] WHERE Per_Imagen IS NULL AND Per_EsEliminado = 0)           AS AlumnosSinFoto;

    -- Matricula por seccion y curso
    SELECT c.Cur_Nombre, s.Sec_Descripcion, COUNT(a.Alu_Id) AS TotalAlumnos
    FROM [app].[tbSecciones] s
    CROSS JOIN [app].[tbCursos] c
    LEFT JOIN [app].[tbAlumnos] a ON s.Sec_Id = a.Sec_Id AND c.Cur_Id = a.Cur_Id AND a.AnioCursado = @Anio
    WHERE s.Sec_EsEliminado = 0 AND c.Cur_EsEliminado = 0
    GROUP BY c.Cur_Id, c.Cur_Nombre, s.Sec_Id, s.Sec_Descripcion
    HAVING COUNT(a.Alu_Id) > 0
    ORDER BY c.Cur_Nombre, s.Sec_Descripcion;
END
GO

-- -------------------------------------------------------
-- PR_DashboardRRHH_Resumen
-- -------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_DashboardRRHH_Resumen]') AND type = 'P')
    DROP PROCEDURE [app].[PR_DashboardRRHH_Resumen];
GO
CREATE PROCEDURE [app].[PR_DashboardRRHH_Resumen]
    @Anio INT = NULL,
    @Mes  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());
    IF @Mes  IS NULL SET @Mes  = MONTH(GETDATE());

    -- KPIs RRHH
    SELECT
        (SELECT COUNT(*) FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0)              AS TotalEmpleadosActivos,
        (SELECT COUNT(*) FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id WHERE MONTH(p.Per_FechaNacimiento) = @Mes AND p.Per_EsEliminado = 0) AS CumpleanosMes,
        (SELECT COUNT(*) FROM [app].[tbVacaciones] WHERE Vac_Estado = 'P' AND Vac_EsEliminado = 0)                                                                           AS PermisosPendientes,
        (SELECT COUNT(*) FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id WHERE YEAR(p.Per_FechaRegistra) = @Anio AND p.Per_EsEliminado = 0) AS NuevosEmpleadosAnio;

    -- Cumpleaños del mes
    SELECT
        CONCAT(p.Per_PrimerNombre, ' ', ISNULL(p.Per_SegundoNombre, ''), ' ', p.Per_ApellidoPaterno) AS NombreCompleto,
        p.Per_FechaNacimiento,
        DAY(p.Per_FechaNacimiento) AS Dia,
        p.Per_Imagen
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
    WHERE MONTH(p.Per_FechaNacimiento) = @Mes AND p.Per_EsEliminado = 0
    ORDER BY DAY(p.Per_FechaNacimiento);

    -- Permisos/vacaciones pendientes de aprobar
    SELECT v.Vac_Id, v.Vac_Tipo, v.Vac_FechaInicio, v.Vac_FechaFin, v.Vac_DiasTotal, v.Vac_Motivo,
           CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno) AS NombreEmpleado
    FROM [app].[tbVacaciones] v
    INNER JOIN [app].[tbEmpleados] e ON v.Emp_Id = e.Emp_Id
    INNER JOIN [app].[tbPersonas]  p ON e.Per_Id = p.Per_Id
    WHERE v.Vac_Estado = 'P' AND v.Vac_EsEliminado = 0
    ORDER BY v.Vac_FechaInicio;
END
GO

-- -------------------------------------------------------
-- PR_DashboardCajero_Hoy
-- -------------------------------------------------------
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

    -- KPIs caja del dia del cajero
    SELECT
        ISNULL(SUM(Pag_MontoTotal), 0) AS TotalCobradoHoy,
        COUNT(*) AS CantidadCobros
    FROM [finanza].[tbPagos]
    WHERE Usu_Id = @Usu_Id
      AND CAST(Pag_FechaPago AS DATE) = @Fecha
      AND Pag_EsEliminado = 0;

    -- Total cuentas pendientes del dia (vencidas o vencen hoy)
    SELECT COUNT(*) AS CuentasPendientesHoy,
           ISNULL(SUM(Cco_MontoPendiente), 0) AS MontoPendienteHoy
    FROM [finanza].[tbCuentasCobrar]
    WHERE CAST(Cco_FechaVencimiento AS DATE) <= @Fecha
      AND Cco_MontoPendiente > 0
      AND Cco_EsEliminado = 0;

    -- Ultimo arqueo del cajero
    SELECT TOP 1 Arq_Id, Arq_Fecha, Arq_TotalGeneral, Arq_Observaciones
    FROM [finanza].[tbArqueosCaja]
    WHERE Usu_Id = @Usu_Id AND Arq_EsEliminado = 0
    ORDER BY Arq_Fecha DESC, Arq_FechaRegistra DESC;

    -- Timeline de pagos del dia
    SELECT p.Pag_Id, p.Pag_MontoTotal, p.Pag_FechaPago, p.Pag_NumeroReferencia,
           fp.Fpa_Descripcion,
           CONCAT(per.Per_PrimerNombre, ' ', per.Per_ApellidoPaterno) AS NombreAlumno
    FROM [finanza].[tbPagos] p
    INNER JOIN [finanza].[tbFormasPago] fp ON p.Fpa_Id = fp.Fpa_Id
    INNER JOIN [app].[tbAlumnos]        al ON p.Alu_Id = al.Alu_Id
    INNER JOIN [app].[tbPersonas]       per ON al.Per_Id = per.Per_Id
    WHERE p.Usu_Id = @Usu_Id
      AND CAST(p.Pag_FechaPago AS DATE) = @Fecha
      AND p.Pag_EsEliminado = 0
    ORDER BY p.Pag_FechaPago DESC;
END
GO

-- -------------------------------------------------------
-- PR_DashboardFinanciero_Resumen
-- -------------------------------------------------------
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

    -- KPIs financieros del mes
    SELECT
        ISNULL((SELECT SUM(Cco_MontoTotal)    FROM [finanza].[tbCuentasCobrar] WHERE Cco_Anio = @Anio AND Cco_Mes = @Mes AND Cco_EsEliminado = 0), 0) AS TotalFacturadoMes,
        ISNULL((SELECT SUM(Pag_MontoTotal)    FROM [finanza].[tbPagos]         WHERE YEAR(Pag_FechaPago) = @Anio AND MONTH(Pag_FechaPago) = @Mes AND Pag_EsEliminado = 0), 0) AS TotalCobradoMes,
        ISNULL((SELECT SUM(Cco_MontoPendiente) FROM [finanza].[tbCuentasCobrar] WHERE Cco_Anio = @Anio AND Cco_EsEliminado = 0 AND Cco_MontoPendiente > 0), 0) AS TotalPendiente,
        ISNULL((SELECT SUM(Cco_MontoMora)     FROM [finanza].[tbCuentasCobrar] WHERE Cco_Anio = @Anio AND Cco_EsEliminado = 0 AND Cco_MontoMora > 0), 0) AS TotalMora;

    -- Cobros por forma de pago del mes
    SELECT fp.Fpa_Descripcion, ISNULL(SUM(p.Pag_MontoTotal), 0) AS Total, COUNT(p.Pag_Id) AS Cantidad
    FROM [finanza].[tbFormasPago] fp
    LEFT JOIN [finanza].[tbPagos] p ON fp.Fpa_Id = p.Fpa_Id
        AND YEAR(p.Pag_FechaPago) = @Anio AND MONTH(p.Pag_FechaPago) = @Mes AND p.Pag_EsEliminado = 0
    WHERE fp.Fpa_EsActivo = 1
    GROUP BY fp.Fpa_Id, fp.Fpa_Descripcion
    ORDER BY Total DESC;

    -- Morosidad por concepto
    SELECT cp.Cpa_Descripcion, COUNT(cc.Cco_Id) AS CuentasMorosas, ISNULL(SUM(cc.Cco_MontoPendiente), 0) AS MontoMoroso
    FROM [finanza].[tbConceptosPago] cp
    LEFT JOIN [finanza].[tbCuentasCobrar] cc ON cp.Cpa_Id = cc.Cpa_Id
        AND cc.Cco_FechaVencimiento < GETDATE() AND cc.Cco_MontoPendiente > 0 AND cc.Cco_EsEliminado = 0
    WHERE cp.Cpa_EsActivo = 1
    GROUP BY cp.Cpa_Id, cp.Cpa_Descripcion
    ORDER BY MontoMoroso DESC;
END
GO

-- -------------------------------------------------------
-- PR_DashboardConsulta_KPIs (solo lectura, sin datos sensibles)
-- -------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_DashboardConsulta_KPIs]') AND type = 'P')
    DROP PROCEDURE [app].[PR_DashboardConsulta_KPIs];
GO
CREATE PROCEDURE [app].[PR_DashboardConsulta_KPIs]
    @Anio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());

    -- Resumen ejecutivo sin montos sensibles
    SELECT
        (SELECT COUNT(*) FROM [app].[tbAlumnos]   WHERE AnioCursado = @Anio) AS TotalAlumnos,
        (SELECT COUNT(*) FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0) AS TotalEmpleados,
        (SELECT COUNT(*) FROM [app].[tbHorario]   WHERE Hor_Año = @Anio AND Hor_EsEliminado = 0) AS TotalClases,
        (SELECT CAST(COUNT(CASE WHEN Cco_MontoPendiente = 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) FROM [finanza].[tbCuentasCobrar] WHERE Cco_Anio = @Anio AND Cco_EsEliminado = 0) AS PorcentajeCobrado;

    -- Matricula por curso para grafico
    SELECT c.Cur_Nombre, COUNT(a.Alu_Id) AS TotalAlumnos
    FROM [app].[tbCursos] c
    LEFT JOIN [app].[tbAlumnos] a ON c.Cur_Id = a.Cur_Id AND a.AnioCursado = @Anio
    WHERE c.Cur_EsEliminado = 0
    GROUP BY c.Cur_Id, c.Cur_Nombre
    ORDER BY TotalAlumnos DESC;
END
GO


-- ============================================================
-- ASISTENCIA (4 SPs)
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbAsistencia_List]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbAsistencia_List];
GO
CREATE PROCEDURE [app].[PR_tbAsistencia_List]
    @Hor_Id INT,
    @Fecha  DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        asi.Asi_Id, asi.Alu_Id, asi.Asi_Estado, asi.Asi_Observacion, asi.Asi_Fecha,
        CONCAT(p.Per_PrimerNombre, ' ', ISNULL(p.Per_SegundoNombre,''), ' ', p.Per_ApellidoPaterno) AS NombreAlumno,
        p.Per_Imagen
    FROM [app].[tbAsistencia] asi
    INNER JOIN [app].[tbAlumnos]  al ON asi.Alu_Id = al.Alu_Id
    INNER JOIN [app].[tbPersonas] p  ON al.Per_Id  = p.Per_Id
    WHERE asi.Hor_Id = @Hor_Id AND asi.Asi_Fecha = @Fecha AND asi.Asi_EsEliminado = 0
    ORDER BY NombreAlumno;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbAsistencia_Insert]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbAsistencia_Insert];
GO
CREATE PROCEDURE [app].[PR_tbAsistencia_Insert]
    @Hor_Id              INT,
    @Alu_Id              INT,
    @Asi_Fecha           DATE,
    @Asi_Estado          CHAR(1),
    @Asi_Observacion     VARCHAR(200) = NULL,
    @Asi_UsuarioRegistra INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM [app].[tbAsistencia] WHERE Hor_Id = @Hor_Id AND Alu_Id = @Alu_Id AND Asi_Fecha = @Asi_Fecha AND Asi_EsEliminado = 0)
    BEGIN
        UPDATE [app].[tbAsistencia]
        SET Asi_Estado = @Asi_Estado, Asi_Observacion = @Asi_Observacion,
            Asi_UsuarioModifica = @Asi_UsuarioRegistra, Asi_FechaModifica = GETDATE()
        WHERE Hor_Id = @Hor_Id AND Alu_Id = @Alu_Id AND Asi_Fecha = @Asi_Fecha;
    END
    ELSE
    BEGIN
        INSERT INTO [app].[tbAsistencia] (Hor_Id, Alu_Id, Asi_Fecha, Asi_Estado, Asi_Observacion, Asi_UsuarioRegistra)
        VALUES (@Hor_Id, @Alu_Id, @Asi_Fecha, @Asi_Estado, @Asi_Observacion, @Asi_UsuarioRegistra);
    END
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbAsistencia_Update]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbAsistencia_Update];
GO
CREATE PROCEDURE [app].[PR_tbAsistencia_Update]
    @Asi_Id              INT,
    @Asi_Estado          CHAR(1),
    @Asi_Observacion     VARCHAR(200) = NULL,
    @Asi_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [app].[tbAsistencia]
    SET Asi_Estado = @Asi_Estado, Asi_Observacion = @Asi_Observacion,
        Asi_UsuarioModifica = @Asi_UsuarioModifica, Asi_FechaModifica = GETDATE()
    WHERE Asi_Id = @Asi_Id AND Asi_EsEliminado = 0;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbAsistencia_ByAlumno]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbAsistencia_ByAlumno];
GO
CREATE PROCEDURE [app].[PR_tbAsistencia_ByAlumno]
    @Alu_Id INT,
    @Anio   INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());
    SELECT
        asi.Asi_Id, asi.Asi_Fecha, asi.Asi_Estado, asi.Asi_Observacion,
        m.Mat_Nombre, d.Dia_Descripcion, hi.Hor_Hora AS HoraInicio
    FROM [app].[tbAsistencia] asi
    INNER JOIN [app].[tbHorario]  h  ON asi.Hor_Id = h.Hor_Id
    INNER JOIN [app].[tbMaterias] m  ON h.Mat_Id   = m.Mat_Id
    INNER JOIN [app].[tbDias]     d  ON h.Dia_Id   = d.Dia_Id
    INNER JOIN [app].[tbHoras]    hi ON h.Hor_HoraInicio = hi.Hor_Id
    WHERE asi.Alu_Id = @Alu_Id AND YEAR(asi.Asi_Fecha) = @Anio AND asi.Asi_EsEliminado = 0
    ORDER BY asi.Asi_Fecha DESC, hi.Hor_Hora;
END
GO


-- ============================================================
-- DOCUMENTOS ALUMNO (3 SPs)
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbDocumentosAlumno_List]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbDocumentosAlumno_List];
GO
CREATE PROCEDURE [app].[PR_tbDocumentosAlumno_List]
    @Alu_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        doa.Doa_Id, doa.Doa_EsEntregado, doa.Doa_FechaEntrega, doa.Doa_Observacion,
        td.TDoc_Id, td.TDoc_Descripcion, td.TDoc_EsObligatorio
    FROM [app].[tbTiposDocumento] td
    LEFT JOIN [app].[tbDocumentosAlumno] doa ON td.TDoc_Id = doa.TDoc_Id AND doa.Alu_Id = @Alu_Id AND doa.Doa_EsEliminado = 0
    WHERE td.TDoc_EsActivo = 1 AND td.TDoc_EsEliminado = 0
    ORDER BY td.TDoc_EsObligatorio DESC, td.TDoc_Descripcion;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbDocumentosAlumno_Update]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbDocumentosAlumno_Update];
GO
CREATE PROCEDURE [app].[PR_tbDocumentosAlumno_Update]
    @Alu_Id              INT,
    @TDoc_Id             INT,
    @Doa_EsEntregado     BIT,
    @Doa_FechaEntrega    DATE = NULL,
    @Doa_Observacion     VARCHAR(200) = NULL,
    @Doa_UsuarioRegistra INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM [app].[tbDocumentosAlumno] WHERE Alu_Id = @Alu_Id AND TDoc_Id = @TDoc_Id AND Doa_EsEliminado = 0)
    BEGIN
        UPDATE [app].[tbDocumentosAlumno]
        SET Doa_EsEntregado = @Doa_EsEntregado, Doa_FechaEntrega = @Doa_FechaEntrega,
            Doa_Observacion = @Doa_Observacion, Doa_UsuarioModifica = @Doa_UsuarioRegistra, Doa_FechaModifica = GETDATE()
        WHERE Alu_Id = @Alu_Id AND TDoc_Id = @TDoc_Id;
    END
    ELSE
    BEGIN
        INSERT INTO [app].[tbDocumentosAlumno] (Alu_Id, TDoc_Id, Doa_EsEntregado, Doa_FechaEntrega, Doa_Observacion, Doa_UsuarioRegistra)
        VALUES (@Alu_Id, @TDoc_Id, @Doa_EsEntregado, @Doa_FechaEntrega, @Doa_Observacion, @Doa_UsuarioRegistra);
    END
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbDocumentosAlumno_PendientesList]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbDocumentosAlumno_PendientesList];
GO
CREATE PROCEDURE [app].[PR_tbDocumentosAlumno_PendientesList]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        al.Alu_Id,
        CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno) AS NombreAlumno,
        c.Cur_Nombre,
        COUNT(CASE WHEN doa.Doa_EsEntregado = 0 OR doa.Doa_Id IS NULL THEN 1 END) AS DocumentosPendientes
    FROM [app].[tbAlumnos] al
    INNER JOIN [app].[tbPersonas] p  ON al.Per_Id = p.Per_Id
    INNER JOIN [app].[tbCursos]   c  ON al.Cur_Id = c.Cur_Id
    CROSS JOIN [app].[tbTiposDocumento] td
    LEFT JOIN  [app].[tbDocumentosAlumno] doa ON al.Alu_Id = doa.Alu_Id AND td.TDoc_Id = doa.TDoc_Id AND doa.Doa_EsEliminado = 0
    WHERE td.TDoc_EsActivo = 1 AND td.TDoc_EsEliminado = 0
      AND (doa.Doa_EsEntregado = 0 OR doa.Doa_Id IS NULL)
    GROUP BY al.Alu_Id, p.Per_PrimerNombre, p.Per_ApellidoPaterno, c.Cur_Nombre
    ORDER BY DocumentosPendientes DESC, NombreAlumno;
END
GO


-- ============================================================
-- VACACIONES (4 SPs)
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbVacaciones_Insert]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbVacaciones_Insert];
GO
CREATE PROCEDURE [app].[PR_tbVacaciones_Insert]
    @Emp_Id              INT,
    @Vac_Tipo            CHAR(1),
    @Vac_FechaInicio     DATE,
    @Vac_FechaFin        DATE,
    @Vac_Motivo          VARCHAR(300) = NULL,
    @Vac_UsuarioRegistra INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [app].[tbVacaciones] (Emp_Id, Vac_Tipo, Vac_FechaInicio, Vac_FechaFin, Vac_Estado, Vac_Motivo, Vac_UsuarioRegistra)
    VALUES (@Emp_Id, @Vac_Tipo, @Vac_FechaInicio, @Vac_FechaFin, 'P', @Vac_Motivo, @Vac_UsuarioRegistra);
    SELECT SCOPE_IDENTITY() AS Vac_Id;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbVacaciones_List]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbVacaciones_List];
GO
CREATE PROCEDURE [app].[PR_tbVacaciones_List]
    @Emp_Id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        v.Vac_Id, v.Vac_Tipo, v.Vac_FechaInicio, v.Vac_FechaFin, v.Vac_DiasTotal,
        v.Vac_Estado, v.Vac_Motivo, v.Vac_FechaRegistra,
        CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno) AS NombreEmpleado,
        e.Emp_Codigo
    FROM [app].[tbVacaciones] v
    INNER JOIN [app].[tbEmpleados] e ON v.Emp_Id = e.Emp_Id
    INNER JOIN [app].[tbPersonas]  p ON e.Per_Id = p.Per_Id
    WHERE v.Vac_EsEliminado = 0 AND (@Emp_Id IS NULL OR v.Emp_Id = @Emp_Id)
    ORDER BY v.Vac_FechaRegistra DESC;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbVacaciones_Update]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbVacaciones_Update];
GO
CREATE PROCEDURE [app].[PR_tbVacaciones_Update]
    @Vac_Id              INT,
    @Vac_Estado          CHAR(1),
    @Vac_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [app].[tbVacaciones]
    SET Vac_Estado = @Vac_Estado, Vac_UsuarioModifica = @Vac_UsuarioModifica, Vac_FechaModifica = GETDATE()
    WHERE Vac_Id = @Vac_Id AND Vac_EsEliminado = 0;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbVacaciones_Delete]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbVacaciones_Delete];
GO
CREATE PROCEDURE [app].[PR_tbVacaciones_Delete]
    @Vac_Id              INT,
    @Vac_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [app].[tbVacaciones]
    SET Vac_EsEliminado = 1, Vac_UsuarioModifica = @Vac_UsuarioModifica, Vac_FechaModifica = GETDATE()
    WHERE Vac_Id = @Vac_Id;
END
GO


-- ============================================================
-- NOTIFICACIONES (3 SPs)
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbNotificaciones_Insert]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbNotificaciones_Insert];
GO
CREATE PROCEDURE [app].[PR_tbNotificaciones_Insert]
    @Usu_Id              INT,
    @Not_Titulo          VARCHAR(100),
    @Not_Mensaje         VARCHAR(500),
    @Not_Tipo            CHAR(1) = 'I',
    @Not_UrlDestino      VARCHAR(200) = NULL,
    @Not_UsuarioRegistra INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [app].[tbNotificaciones] (Usu_Id, Not_Titulo, Not_Mensaje, Not_Tipo, Not_UrlDestino, Not_UsuarioRegistra)
    VALUES (@Usu_Id, @Not_Titulo, @Not_Mensaje, @Not_Tipo, @Not_UrlDestino, @Not_UsuarioRegistra);
    SELECT SCOPE_IDENTITY() AS Not_Id;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbNotificaciones_ListByUsuario]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbNotificaciones_ListByUsuario];
GO
CREATE PROCEDURE [app].[PR_tbNotificaciones_ListByUsuario]
    @Usu_Id      INT,
    @SoloNoLeidas BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 50
        Not_Id, Not_Titulo, Not_Mensaje, Not_Tipo, Not_EsLeida, Not_UrlDestino, Not_FechaEnvio
    FROM [app].[tbNotificaciones]
    WHERE Usu_Id = @Usu_Id AND Not_EsEliminado = 0
      AND (@SoloNoLeidas = 0 OR Not_EsLeida = 0)
    ORDER BY Not_FechaEnvio DESC;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbNotificaciones_MarcarLeida]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbNotificaciones_MarcarLeida];
GO
CREATE PROCEDURE [app].[PR_tbNotificaciones_MarcarLeida]
    @Not_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [app].[tbNotificaciones]
    SET Not_EsLeida = 1, Not_FechaLectura = GETDATE()
    WHERE Not_Id = @Not_Id;
END
GO


-- ============================================================
-- ARQUEO DE CAJA (3 SPs)
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finanza].[PR_tbArqueosCaja_Insert]') AND type = 'P')
    DROP PROCEDURE [finanza].[PR_tbArqueosCaja_Insert];
GO
CREATE PROCEDURE [finanza].[PR_tbArqueosCaja_Insert]
    @Usu_Id                INT,
    @Arq_Fecha             DATE,
    @Arq_TotalEfectivo     DECIMAL(10,2),
    @Arq_TotalTransferencia DECIMAL(10,2),
    @Arq_TotalTarjeta      DECIMAL(10,2),
    @Arq_Observaciones     VARCHAR(300) = NULL,
    @Arq_UsuarioRegistra   INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [finanza].[tbArqueosCaja] (Usu_Id, Arq_Fecha, Arq_TotalEfectivo, Arq_TotalTransferencia, Arq_TotalTarjeta, Arq_Observaciones, Arq_UsuarioRegistra)
    VALUES (@Usu_Id, @Arq_Fecha, @Arq_TotalEfectivo, @Arq_TotalTransferencia, @Arq_TotalTarjeta, @Arq_Observaciones, @Arq_UsuarioRegistra);
    SELECT SCOPE_IDENTITY() AS Arq_Id;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finanza].[PR_tbArqueosCaja_Find]') AND type = 'P')
    DROP PROCEDURE [finanza].[PR_tbArqueosCaja_Find];
GO
CREATE PROCEDURE [finanza].[PR_tbArqueosCaja_Find]
    @Arq_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT a.Arq_Id, a.Arq_Fecha, a.Arq_TotalEfectivo, a.Arq_TotalTransferencia, a.Arq_TotalTarjeta,
           a.Arq_TotalGeneral, a.Arq_Observaciones, a.Arq_FechaRegistra, u.Usu_Name
    FROM [finanza].[tbArqueosCaja] a
    INNER JOIN [Seguridad].[tbUsuarios] u ON a.Usu_Id = u.Usu_Id
    WHERE a.Arq_Id = @Arq_Id AND a.Arq_EsEliminado = 0;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finanza].[PR_tbArqueosCaja_LastByUsuario]') AND type = 'P')
    DROP PROCEDURE [finanza].[PR_tbArqueosCaja_LastByUsuario];
GO
CREATE PROCEDURE [finanza].[PR_tbArqueosCaja_LastByUsuario]
    @Usu_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 10
        a.Arq_Id, a.Arq_Fecha, a.Arq_TotalEfectivo, a.Arq_TotalTransferencia,
        a.Arq_TotalTarjeta, a.Arq_TotalGeneral, a.Arq_Observaciones
    FROM [finanza].[tbArqueosCaja] a
    WHERE a.Usu_Id = @Usu_Id AND a.Arq_EsEliminado = 0
    ORDER BY a.Arq_Fecha DESC, a.Arq_FechaRegistra DESC;
END
GO


-- ============================================================
-- BITACORA (2 SPs)
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Seguridad].[UDP_tbBitacora_Insert]') AND type = 'P')
    DROP PROCEDURE [Seguridad].[UDP_tbBitacora_Insert];
GO
CREATE PROCEDURE [Seguridad].[UDP_tbBitacora_Insert]
    @Usu_Id         INT,
    @Bit_Accion     VARCHAR(50),
    @Bit_Tabla      VARCHAR(100) = NULL,
    @Bit_RegistroId INT          = NULL,
    @Bit_Descripcion VARCHAR(500) = NULL,
    @Bit_Ip         VARCHAR(45)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [Seguridad].[tbBitacora] (Usu_Id, Bit_Accion, Bit_Tabla, Bit_RegistroId, Bit_Descripcion, Bit_Ip)
    VALUES (@Usu_Id, @Bit_Accion, @Bit_Tabla, @Bit_RegistroId, @Bit_Descripcion, @Bit_Ip);
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Seguridad].[UDP_tbBitacora_List]') AND type = 'P')
    DROP PROCEDURE [Seguridad].[UDP_tbBitacora_List];
GO
CREATE PROCEDURE [Seguridad].[UDP_tbBitacora_List]
    @Usu_Id   INT = NULL,
    @Bit_Tabla VARCHAR(100) = NULL,
    @Top      INT = 100
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Top)
        b.Bit_Id, b.Bit_Accion, b.Bit_Tabla, b.Bit_RegistroId,
        b.Bit_Descripcion, b.Bit_Ip, b.Bit_Fecha, u.Usu_Name
    FROM [Seguridad].[tbBitacora] b
    INNER JOIN [Seguridad].[tbUsuarios] u ON b.Usu_Id = u.Usu_Id
    WHERE (@Usu_Id   IS NULL OR b.Usu_Id    = @Usu_Id)
      AND (@Bit_Tabla IS NULL OR b.Bit_Tabla = @Bit_Tabla)
    ORDER BY b.Bit_Fecha DESC;
END
GO


-- ============================================================
-- BUSQUEDA GLOBAL / FICHAS (4 SPs)
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_Alumnos_BusquedaGlobal]') AND type = 'P')
    DROP PROCEDURE [app].[PR_Alumnos_BusquedaGlobal];
GO
CREATE PROCEDURE [app].[PR_Alumnos_BusquedaGlobal]
    @Termino VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 20
        al.Alu_Id,
        CONCAT(p.Per_PrimerNombre, ' ', ISNULL(p.Per_SegundoNombre,''), ' ', p.Per_ApellidoPaterno, ' ', ISNULL(p.Per_ApellidoMaterno,'')) AS NombreCompleto,
        p.Per_Identidad, p.Per_Telefono, p.Per_Imagen,
        c.Cur_Nombre, s.Sec_Descripcion, al.AnioCursado
    FROM [app].[tbAlumnos] al
    INNER JOIN [app].[tbPersonas]  p ON al.Per_Id = p.Per_Id
    INNER JOIN [app].[tbCursos]    c ON al.Cur_Id = c.Cur_Id
    LEFT JOIN  [app].[tbSecciones] s ON al.Sec_Id = s.Sec_Id
    WHERE p.Per_EsEliminado = 0
      AND (
          p.Per_PrimerNombre    LIKE '%' + @Termino + '%' OR
          p.Per_ApellidoPaterno LIKE '%' + @Termino + '%' OR
          p.Per_Identidad       LIKE '%' + @Termino + '%' OR
          p.Per_Telefono        LIKE '%' + @Termino + '%'
      )
    ORDER BY p.Per_ApellidoPaterno, p.Per_PrimerNombre;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_Alumnos_Ficha360]') AND type = 'P')
    DROP PROCEDURE [app].[PR_Alumnos_Ficha360];
GO
CREATE PROCEDURE [app].[PR_Alumnos_Ficha360]
    @Alu_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Datos personales y academicos
    SELECT
        al.Alu_Id, al.AnioCursado, al.PromedioAnual,
        p.Per_PrimerNombre, p.Per_SegundoNombre, p.Per_ApellidoPaterno, p.Per_ApellidoMaterno,
        p.Per_Identidad, p.Per_FechaNacimiento, p.Per_Sexo,
        p.Per_Telefono, p.Per_CorreoElectronico, p.Per_Direccion, p.Per_Imagen,
        c.Cur_Nombre, cn.Cun_Descripcion, s.Sec_Descripcion
    FROM [app].[tbAlumnos] al
    INNER JOIN [app].[tbPersonas]      p  ON al.Per_Id  = p.Per_Id
    INNER JOIN [app].[tbCursos]        c  ON al.Cur_Id  = c.Cur_Id
    LEFT JOIN  [app].[tbCursosNiveles] cn ON al.Cun_Id  = cn.Cun_Id
    LEFT JOIN  [app].[tbSecciones]     s  ON al.Sec_Id  = s.Sec_Id
    WHERE al.Alu_Id = @Alu_Id;

    -- Cuentas por cobrar del alumno
    SELECT cc.Cco_Id, cc.Cco_Mes, cc.Cco_Anio, cc.Cco_MontoTotal,
           cc.Cco_MontoPendiente, cc.Cco_FechaVencimiento, ep.Epa_Descripcion, cp.Cpa_Descripcion
    FROM [finanza].[tbCuentasCobrar] cc
    INNER JOIN [finanza].[tbConceptosPago] cp ON cc.Cpa_Id = cp.Cpa_Id
    INNER JOIN [finanza].[tbEstadosPago]   ep ON cc.Epa_Id = ep.Epa_Id
    WHERE cc.Alu_Id = @Alu_Id AND cc.Cco_EsEliminado = 0
    ORDER BY cc.Cco_Anio DESC, cc.Cco_Mes DESC;

    -- Asistencia reciente
    SELECT TOP 30 asi.Asi_Fecha, asi.Asi_Estado, m.Mat_Nombre
    FROM [app].[tbAsistencia] asi
    INNER JOIN [app].[tbHorario]  h ON asi.Hor_Id = h.Hor_Id
    INNER JOIN [app].[tbMaterias] m ON h.Mat_Id   = m.Mat_Id
    WHERE asi.Alu_Id = @Alu_Id AND asi.Asi_EsEliminado = 0
    ORDER BY asi.Asi_Fecha DESC;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_Empleados_Ficha360]') AND type = 'P')
    DROP PROCEDURE [app].[PR_Empleados_Ficha360];
GO
CREATE PROCEDURE [app].[PR_Empleados_Ficha360]
    @Emp_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Datos personales y laborales
    SELECT
        e.Emp_Id, e.Emp_Codigo,
        p.Per_PrimerNombre, p.Per_SegundoNombre, p.Per_ApellidoPaterno, p.Per_ApellidoMaterno,
        p.Per_Identidad, p.Per_FechaNacimiento, p.Per_Sexo,
        p.Per_Telefono, p.Per_CorreoElectronico, p.Per_Direccion, p.Per_Imagen,
        p.Per_FechaRegistra AS FechaContratacion,
        DATEDIFF(YEAR, p.Per_FechaRegistra, GETDATE()) AS AnosAntigüedad
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
    WHERE e.Emp_Id = @Emp_Id;

    -- Clases asignadas
    SELECT h.Hor_Id, m.Mat_Nombre, s.Sec_Descripcion, c.Cur_Nombre, h.Hor_Año,
           d.Dia_Descripcion, hi.Hor_Hora AS HoraInicio, hf.Hor_Hora AS HoraFin
    FROM [app].[tbHorario] h
    INNER JOIN [app].[tbMaterias]  m  ON h.Mat_Id = m.Mat_Id
    INNER JOIN [app].[tbSecciones] s  ON h.Sec_Id = s.Sec_Id
    INNER JOIN [app].[tbCursos]    c  ON h.Cur_Id = c.Cur_Id
    INNER JOIN [app].[tbDias]      d  ON h.Dia_Id = d.Dia_Id
    INNER JOIN [app].[tbHoras]     hi ON h.Hor_HoraInicio   = hi.Hor_Id
    INNER JOIN [app].[tbHoras]     hf ON h.Hor_HoraFinaliza = hf.Hor_Id
    WHERE h.Emp_Id = @Emp_Id AND h.Hor_Año = YEAR(GETDATE()) AND h.Hor_EsEliminado = 0
    ORDER BY d.Dia_Id, hi.Hor_Hora;

    -- Historial de vacaciones
    SELECT Vac_Tipo, Vac_FechaInicio, Vac_FechaFin, Vac_DiasTotal, Vac_Estado, Vac_Motivo
    FROM [app].[tbVacaciones]
    WHERE Emp_Id = @Emp_Id AND Vac_EsEliminado = 0
    ORDER BY Vac_FechaInicio DESC;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_Empleados_Antiguedad]') AND type = 'P')
    DROP PROCEDURE [app].[PR_Empleados_Antiguedad];
GO
CREATE PROCEDURE [app].[PR_Empleados_Antiguedad]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        e.Emp_Id, e.Emp_Codigo,
        CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno) AS NombreCompleto,
        p.Per_FechaRegistra AS FechaIngreso,
        DATEDIFF(YEAR,  p.Per_FechaRegistra, GETDATE()) AS Años,
        DATEDIFF(MONTH, p.Per_FechaRegistra, GETDATE()) % 12 AS Meses,
        p.Per_Imagen
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
    WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0
    ORDER BY FechaIngreso ASC;
END
GO


-- ============================================================
-- REPORTES FINANCIEROS (4 SPs)
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finanza].[PR_Finanza_EstadoCuenta]') AND type = 'P')
    DROP PROCEDURE [finanza].[PR_Finanza_EstadoCuenta];
GO
CREATE PROCEDURE [finanza].[PR_Finanza_EstadoCuenta]
    @Alu_Id INT,
    @Anio   INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());

    SELECT
        cc.Cco_Id, cc.Cco_Mes, cc.Cco_Anio,
        cp.Cpa_Descripcion,
        cc.Cco_MontoOriginal, cc.Cco_MontoDescuento, cc.Cco_MontoMora,
        cc.Cco_MontoTotal,    cc.Cco_MontoPendiente,
        cc.Cco_FechaEmision,  cc.Cco_FechaVencimiento,
        ep.Epa_Descripcion    AS Estado,
        ISNULL((SELECT SUM(pd.Pde_MontoAplicado)
                FROM [finanza].[tbPagosDetalle] pd WHERE pd.Cco_Id = cc.Cco_Id), 0) AS MontoPagado
    FROM [finanza].[tbCuentasCobrar] cc
    INNER JOIN [finanza].[tbConceptosPago] cp ON cc.Cpa_Id = cp.Cpa_Id
    INNER JOIN [finanza].[tbEstadosPago]   ep ON cc.Epa_Id = ep.Epa_Id
    WHERE cc.Alu_Id = @Alu_Id AND cc.Cco_Anio = @Anio AND cc.Cco_EsEliminado = 0
    ORDER BY cc.Cco_Mes;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finanza].[PR_Finanza_AgingCuentas]') AND type = 'P')
    DROP PROCEDURE [finanza].[PR_Finanza_AgingCuentas];
GO
CREATE PROCEDURE [finanza].[PR_Finanza_AgingCuentas]
    @FechaCorte DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @FechaCorte IS NULL SET @FechaCorte = CAST(GETDATE() AS DATE);

    SELECT
        CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno) AS NombreAlumno,
        al.Alu_Id,
        ISNULL(SUM(CASE WHEN DATEDIFF(DAY, cc.Cco_FechaVencimiento, @FechaCorte) BETWEEN  1 AND  30 THEN cc.Cco_MontoPendiente ELSE 0 END), 0) AS Rango_1_30,
        ISNULL(SUM(CASE WHEN DATEDIFF(DAY, cc.Cco_FechaVencimiento, @FechaCorte) BETWEEN 31 AND  60 THEN cc.Cco_MontoPendiente ELSE 0 END), 0) AS Rango_31_60,
        ISNULL(SUM(CASE WHEN DATEDIFF(DAY, cc.Cco_FechaVencimiento, @FechaCorte) BETWEEN 61 AND  90 THEN cc.Cco_MontoPendiente ELSE 0 END), 0) AS Rango_61_90,
        ISNULL(SUM(CASE WHEN DATEDIFF(DAY, cc.Cco_FechaVencimiento, @FechaCorte) > 90             THEN cc.Cco_MontoPendiente ELSE 0 END), 0) AS Rango_Mas90,
        ISNULL(SUM(cc.Cco_MontoPendiente), 0) AS TotalDeuda
    FROM [finanza].[tbCuentasCobrar] cc
    INNER JOIN [app].[tbAlumnos]  al ON cc.Alu_Id = al.Alu_Id
    INNER JOIN [app].[tbPersonas] p  ON al.Per_Id = p.Per_Id
    WHERE cc.Cco_MontoPendiente > 0
      AND cc.Cco_FechaVencimiento < @FechaCorte
      AND cc.Cco_EsEliminado = 0
    GROUP BY al.Alu_Id, p.Per_PrimerNombre, p.Per_ApellidoPaterno
    ORDER BY TotalDeuda DESC;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finanza].[PR_Finanza_TopDeudores]') AND type = 'P')
    DROP PROCEDURE [finanza].[PR_Finanza_TopDeudores];
GO
CREATE PROCEDURE [finanza].[PR_Finanza_TopDeudores]
    @Top  INT = 10,
    @Anio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());

    SELECT TOP (@Top)
        al.Alu_Id,
        CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno) AS NombreAlumno,
        p.Per_Telefono,
        c.Cur_Nombre,
        ISNULL(SUM(cc.Cco_MontoPendiente), 0) AS TotalDeuda,
        COUNT(cc.Cco_Id) AS CuotasPendientes,
        MAX(cc.Cco_FechaVencimiento) AS UltimoVencimiento
    FROM [finanza].[tbCuentasCobrar] cc
    INNER JOIN [app].[tbAlumnos]  al ON cc.Alu_Id = al.Alu_Id
    INNER JOIN [app].[tbPersonas] p  ON al.Per_Id = p.Per_Id
    INNER JOIN [app].[tbCursos]   c  ON al.Cur_Id = c.Cur_Id
    WHERE cc.Cco_Anio = @Anio AND cc.Cco_MontoPendiente > 0 AND cc.Cco_EsEliminado = 0
    GROUP BY al.Alu_Id, p.Per_PrimerNombre, p.Per_ApellidoPaterno, p.Per_Telefono, c.Cur_Nombre
    ORDER BY TotalDeuda DESC;
END
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finanza].[PR_Finanza_Morosidad_PorNivel]') AND type = 'P')
    DROP PROCEDURE [finanza].[PR_Finanza_Morosidad_PorNivel];
GO
CREATE PROCEDURE [finanza].[PR_Finanza_Morosidad_PorNivel]
    @Anio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());

    SELECT
        c.Cur_Nombre,
        COUNT(DISTINCT al.Alu_Id)             AS TotalAlumnos,
        COUNT(DISTINCT CASE WHEN cc.Cco_MontoPendiente > 0 THEN al.Alu_Id END) AS AlumnosMorosos,
        ISNULL(SUM(cc.Cco_MontoPendiente), 0) AS MontoMoroso,
        CAST(
            COUNT(DISTINCT CASE WHEN cc.Cco_MontoPendiente > 0 THEN al.Alu_Id END) * 100.0
            / NULLIF(COUNT(DISTINCT al.Alu_Id), 0)
        AS DECIMAL(5,2)) AS PorcentajeMorosidad
    FROM [app].[tbCursos] c
    LEFT JOIN [app].[tbAlumnos] al ON c.Cur_Id = al.Cur_Id AND al.AnioCursado = @Anio
    LEFT JOIN [finanza].[tbCuentasCobrar] cc ON al.Alu_Id = cc.Alu_Id
        AND cc.Cco_Anio = @Anio AND cc.Cco_MontoPendiente > 0 AND cc.Cco_FechaVencimiento < GETDATE() AND cc.Cco_EsEliminado = 0
    WHERE c.Cur_EsEliminado = 0
    GROUP BY c.Cur_Id, c.Cur_Nombre
    ORDER BY PorcentajeMorosidad DESC;
END
GO


-- ============================================================
-- REPORTE ACADEMICO (1 SP)
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_Academico_AlumnosEnRiesgo]') AND type = 'P')
    DROP PROCEDURE [app].[PR_Academico_AlumnosEnRiesgo];
GO
CREATE PROCEDURE [app].[PR_Academico_AlumnosEnRiesgo]
    @PromedioMinimo DECIMAL(5,2) = 60.00,
    @Anio           INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());

    SELECT
        al.Alu_Id,
        CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno) AS NombreAlumno,
        p.Per_Telefono, p.Per_Imagen,
        c.Cur_Nombre, s.Sec_Descripcion,
        al.PromedioAnual,
        ISNULL((SELECT SUM(cc2.Cco_MontoPendiente) FROM [finanza].[tbCuentasCobrar] cc2
                WHERE cc2.Alu_Id = al.Alu_Id AND cc2.Cco_Anio = @Anio AND cc2.Cco_EsEliminado = 0), 0) AS DeudaPendiente
    FROM [app].[tbAlumnos] al
    INNER JOIN [app].[tbPersonas]  p ON al.Per_Id = p.Per_Id
    INNER JOIN [app].[tbCursos]    c ON al.Cur_Id = c.Cur_Id
    LEFT JOIN  [app].[tbSecciones] s ON al.Sec_Id = s.Sec_Id
    WHERE al.AnioCursado = @Anio AND al.PromedioAnual IS NOT NULL AND al.PromedioAnual < @PromedioMinimo
    ORDER BY al.PromedioAnual ASC;
END
GO

PRINT 'Script 007 ejecutado exitosamente - stored procedures funcionales creados.';
GO
