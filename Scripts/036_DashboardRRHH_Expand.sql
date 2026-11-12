-- 036_DashboardRRHH_Expand.sql
-- Expande PR_DashboardRRHH_Resumen a 12 result sets
-- Tablas usadas: tbEmpleados, tbPersonas, tbCargos, tbTitulos,
--                tbDepartamentoEmpleados, tbVacaciones, tbAsistenciaEmpleados

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
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    DECLARE @Hace14 DATE = DATEADD(DAY, -13, @Hoy);

    -- ── RS1: KPIs Generales ──────────────────────────────────────────────
    SELECT
        (SELECT COUNT(*)
         FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
         WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0) AS TotalEmpleadosActivos,

        (SELECT COUNT(*)
         FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
         WHERE p.Per_EsActivo = 0 AND p.Per_EsEliminado = 0) AS TotalEmpleadosInactivos,

        (SELECT COUNT(*)
         FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
         WHERE MONTH(p.Per_FechaNacimiento) = @Mes AND p.Per_EsEliminado = 0) AS CumpleanosMes,

        (SELECT COUNT(*)
         FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
         WHERE MONTH(p.Per_FechaNacimiento) = MONTH(@Hoy)
           AND DAY(p.Per_FechaNacimiento) = DAY(@Hoy)
           AND p.Per_EsEliminado = 0) AS CumpleanosHoy,

        (SELECT COUNT(*) FROM [app].[tbVacaciones]
         WHERE Vac_Tipo = 'V' AND Vac_Estado = 'P' AND Vac_EsEliminado = 0) AS VacacionesPendientes,

        (SELECT COUNT(*) FROM [app].[tbVacaciones]
         WHERE Vac_Tipo = 'P' AND Vac_Estado = 'P' AND Vac_EsEliminado = 0) AS PermisosPendientes,

        (SELECT COUNT(*) FROM [app].[tbVacaciones]
         WHERE Vac_Tipo = 'I' AND Vac_Estado = 'P' AND Vac_EsEliminado = 0) AS IncapacidadesPendientes,

        (SELECT COUNT(*)
         FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
         WHERE YEAR(p.Per_FechaRegistra) = @Anio AND p.Per_EsEliminado = 0) AS NuevosEmpleadosAnio,

        (SELECT COUNT(*) FROM [app].[tbAsistenciaEmpleados]
         WHERE AsiEmp_Fecha = @Hoy AND AsiEmp_Tipo = 'Presente' AND AsiEmp_EsEliminado = 0) AS PresentesHoy,

        (SELECT COUNT(*) FROM [app].[tbAsistenciaEmpleados]
         WHERE AsiEmp_Fecha = @Hoy AND AsiEmp_Tipo = 'Ausente' AND AsiEmp_EsEliminado = 0) AS AusentesHoy,

        (SELECT COUNT(*) FROM [app].[tbAsistenciaEmpleados]
         WHERE AsiEmp_Fecha = @Hoy AND AsiEmp_Tipo = 'Tardanza' AND AsiEmp_EsEliminado = 0) AS TardanzasHoy,

        (SELECT COUNT(*) FROM [app].[tbCargos] WHERE Car_EsEliminado = 0) AS TotalCargos,

        (SELECT COUNT(*) FROM [app].[tbDepartamentoEmpleados]) AS TotalDepartamentos;

    -- ── RS2: Empleados por Departamento (donut) ──────────────────────────
    SELECT
        d.Dep_Id,
        d.Nombre AS Departamento,
        COUNT(e.Emp_Id) AS TotalEmpleados
    FROM [app].[tbDepartamentoEmpleados] d
    LEFT JOIN [app].[tbEmpleados] e ON e.Dep_Id = d.Dep_Id
    LEFT JOIN [app].[tbPersonas]  p ON e.Per_Id = p.Per_Id AND p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0
    GROUP BY d.Dep_Id, d.Nombre
    ORDER BY TotalEmpleados DESC;

    -- ── RS3: Empleados por Cargo (barras horizontales) ───────────────────
    SELECT
        c.Car_Id,
        c.Car_Descripcion AS Cargo,
        COUNT(e.Emp_Id) AS TotalEmpleados
    FROM [app].[tbCargos] c
    LEFT JOIN [app].[tbEmpleados] e ON e.Car_Id = c.Car_Id
    LEFT JOIN [app].[tbPersonas]  p ON e.Per_Id = p.Per_Id AND p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0
    WHERE c.Car_EsEliminado = 0
    GROUP BY c.Car_Id, c.Car_Descripcion
    ORDER BY TotalEmpleados DESC;

    -- ── RS4: Asistencia últimos 14 días (line chart) ─────────────────────
    ;WITH Fechas AS (
        SELECT TOP 14
            DATEADD(DAY, -1 * (ROW_NUMBER() OVER (ORDER BY (SELECT 1)) - 1), @Hoy) AS Fecha
        FROM sys.columns
    )
    SELECT
        f.Fecha,
        ISNULL((SELECT COUNT(*) FROM [app].[tbAsistenciaEmpleados]
                WHERE AsiEmp_Fecha = f.Fecha AND AsiEmp_Tipo = 'Presente' AND AsiEmp_EsEliminado = 0), 0) AS Presentes,
        ISNULL((SELECT COUNT(*) FROM [app].[tbAsistenciaEmpleados]
                WHERE AsiEmp_Fecha = f.Fecha AND AsiEmp_Tipo = 'Ausente' AND AsiEmp_EsEliminado = 0), 0) AS Ausentes,
        ISNULL((SELECT COUNT(*) FROM [app].[tbAsistenciaEmpleados]
                WHERE AsiEmp_Fecha = f.Fecha AND AsiEmp_Tipo = 'Tardanza' AND AsiEmp_EsEliminado = 0), 0) AS Tardanzas,
        ISNULL((SELECT COUNT(*) FROM [app].[tbAsistenciaEmpleados]
                WHERE AsiEmp_Fecha = f.Fecha AND AsiEmp_Tipo = 'Permiso' AND AsiEmp_EsEliminado = 0), 0) AS Permisos
    FROM Fechas f
    ORDER BY f.Fecha;

    -- ── RS5: Solicitudes por tipo y estado (donut) ───────────────────────
    SELECT
        CASE Vac_Tipo WHEN 'V' THEN 'Vacaciones' WHEN 'P' THEN 'Permiso' WHEN 'I' THEN 'Incapacidad' ELSE 'Otro' END AS Tipo,
        CASE Vac_Estado WHEN 'P' THEN 'Pendiente' WHEN 'A' THEN 'Aprobada' WHEN 'R' THEN 'Rechazada' ELSE 'Otro' END AS Estado,
        COUNT(*) AS Total
    FROM [app].[tbVacaciones]
    WHERE Vac_EsEliminado = 0
    GROUP BY Vac_Tipo, Vac_Estado
    ORDER BY Vac_Tipo, Vac_Estado;

    -- ── RS6: Nuevos empleados por mes (últimos 6 meses, bar chart) ───────
    ;WITH Meses AS (
        SELECT TOP 6
            DATEADD(MONTH, -1 * (ROW_NUMBER() OVER (ORDER BY (SELECT 1)) - 1),
                    DATEFROMPARTS(@Anio, @Mes, 1)) AS Fecha
        FROM sys.columns
    )
    SELECT
        MONTH(m.Fecha) AS Mes,
        YEAR(m.Fecha)  AS Anio,
        (SELECT COUNT(*)
         FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
         WHERE YEAR(p.Per_FechaRegistra) = YEAR(m.Fecha)
           AND MONTH(p.Per_FechaRegistra) = MONTH(m.Fecha)
           AND p.Per_EsEliminado = 0) AS NuevosEmpleados
    FROM Meses m
    ORDER BY YEAR(m.Fecha), MONTH(m.Fecha);

    -- ── RS7: Distribución por género (pie chart) ─────────────────────────
    SELECT
        CASE p.Per_Sexo WHEN 'M' THEN 'Masculino' WHEN 'F' THEN 'Femenino' ELSE 'No especificado' END AS Genero,
        COUNT(*) AS Total
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
    WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0
    GROUP BY p.Per_Sexo
    ORDER BY Total DESC;

    -- ── RS8: Distribución por rango de edad (bar chart) ──────────────────
    SELECT
        CASE
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) < 25 THEN '< 25 años'
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 25 AND 34 THEN '25–34 años'
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 35 AND 44 THEN '35–44 años'
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 45 AND 54 THEN '45–54 años'
            ELSE '55+ años'
        END AS RangoEdad,
        COUNT(*) AS Total,
        CASE
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) < 25 THEN 1
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 25 AND 34 THEN 2
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 35 AND 44 THEN 3
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 45 AND 54 THEN 4
            ELSE 5
        END AS Orden
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
    WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0
    GROUP BY
        CASE
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) < 25 THEN '< 25 años'
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 25 AND 34 THEN '25–34 años'
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 35 AND 44 THEN '35–44 años'
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 45 AND 54 THEN '45–54 años'
            ELSE '55+ años'
        END,
        CASE
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) < 25 THEN 1
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 25 AND 34 THEN 2
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 35 AND 44 THEN 3
            WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 45 AND 54 THEN 4
            ELSE 5
        END
    ORDER BY Orden;

    -- ── RS9: Cumpleaños del mes (lista con foto y cargo) ─────────────────
    SELECT
        LTRIM(RTRIM(CONCAT(p.Per_PrimerNombre, ' ',
              ISNULL(p.Per_SegundoNombre + ' ', ''),
              p.Per_ApellidoPaterno))) AS NombreCompleto,
        p.Per_FechaNacimiento,
        DAY(p.Per_FechaNacimiento)  AS Dia,
        DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) AS Edad,
        p.Per_Imagen,
        c.Car_Descripcion AS Cargo,
        d.Nombre          AS Departamento
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas]             p ON e.Per_Id = p.Per_Id
    LEFT  JOIN [app].[tbCargos]              c ON e.Car_Id = c.Car_Id
    LEFT  JOIN [app].[tbDepartamentoEmpleados] d ON e.Dep_Id = d.Dep_Id
    WHERE MONTH(p.Per_FechaNacimiento) = @Mes AND p.Per_EsEliminado = 0
    ORDER BY DAY(p.Per_FechaNacimiento);

    -- ── RS10: Solicitudes pendientes (tabla detalle) ──────────────────────
    SELECT
        v.Vac_Id,
        CASE v.Vac_Tipo WHEN 'V' THEN 'Vacaciones' WHEN 'P' THEN 'Permiso' WHEN 'I' THEN 'Incapacidad' ELSE 'Otro' END AS Tipo,
        v.Vac_FechaInicio,
        v.Vac_FechaFin,
        v.Vac_DiasTotal,
        v.Vac_Motivo,
        LTRIM(RTRIM(CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno))) AS NombreEmpleado,
        c.Car_Descripcion AS Cargo,
        d.Nombre          AS Departamento
    FROM [app].[tbVacaciones] v
    INNER JOIN [app].[tbEmpleados]             e ON v.Emp_Id = e.Emp_Id
    INNER JOIN [app].[tbPersonas]              p ON e.Per_Id = p.Per_Id
    LEFT  JOIN [app].[tbCargos]               c ON e.Car_Id = c.Car_Id
    LEFT  JOIN [app].[tbDepartamentoEmpleados] d ON e.Dep_Id = d.Dep_Id
    WHERE v.Vac_Estado = 'P' AND v.Vac_EsEliminado = 0
    ORDER BY v.Vac_FechaInicio;

    -- ── RS11: Top 10 empleados por antigüedad ────────────────────────────
    SELECT TOP 10
        LTRIM(RTRIM(CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno))) AS NombreEmpleado,
        p.Per_FechaRegistra AS FechaIngreso,
        DATEDIFF(YEAR, p.Per_FechaRegistra, @Hoy) AS AnosServicio,
        c.Car_Descripcion AS Cargo,
        d.Nombre          AS Departamento,
        p.Per_Imagen
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas]              p ON e.Per_Id = p.Per_Id
    LEFT  JOIN [app].[tbCargos]               c ON e.Car_Id = c.Car_Id
    LEFT  JOIN [app].[tbDepartamentoEmpleados] d ON e.Dep_Id = d.Dep_Id
    WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0
    ORDER BY p.Per_FechaRegistra ASC;

    -- ── RS12: Alertas RRHH ───────────────────────────────────────────────
    SELECT TOP 10 Mensaje, Tipo, Urgencia, Orden FROM (

        -- Solicitudes pendientes acumuladas (alta)
        SELECT
            CAST((SELECT COUNT(*) FROM [app].[tbVacaciones]
                  WHERE Vac_Estado = 'P' AND Vac_EsEliminado = 0) AS VARCHAR)
            + ' solicitudes pendientes de aprobación' AS Mensaje,
            'solicitudes' AS Tipo, 'alta' AS Urgencia, 1 AS Orden
        WHERE EXISTS (SELECT 1 FROM [app].[tbVacaciones] WHERE Vac_Estado = 'P' AND Vac_EsEliminado = 0)

        UNION ALL

        -- Cumpleaños hoy (media)
        SELECT
            LTRIM(RTRIM(CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno)))
            + ' cumple años hoy' AS Mensaje,
            'cumpleanos' AS Tipo, 'media' AS Urgencia, 2 AS Orden
        FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
        WHERE MONTH(p.Per_FechaNacimiento) = MONTH(@Hoy)
          AND DAY(p.Per_FechaNacimiento) = DAY(@Hoy)
          AND p.Per_EsEliminado = 0

        UNION ALL

        -- Empleados sin correo o teléfono (baja)
        SELECT TOP 3
            LTRIM(RTRIM(CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno)))
            + ' no tiene datos de contacto completos' AS Mensaje,
            'contacto' AS Tipo, 'baja' AS Urgencia, 3 AS Orden
        FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
        WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0
          AND (p.Per_CorreoElectronico IS NULL OR LTRIM(RTRIM(p.Per_CorreoElectronico)) = ''
            OR p.Per_Telefono IS NULL OR LTRIM(RTRIM(p.Per_Telefono)) = '')
        ORDER BY p.Per_ApellidoPaterno

    ) alertas
    ORDER BY Orden, Mensaje;

END
GO

PRINT 'PR_DashboardRRHH_Resumen actualizado a 12 result sets.';
