-- =====================================================================
-- 044_AsistenciaEmpleados_RangoFechas_Y_Seed.sql
--   1) Extiende app.PR_Empleados_Asistencia_List con @FechaDesde/@FechaHasta
--      (mantiene @Fecha para compatibilidad). Sin filtros: mes anterior + actual.
--   2) Seed: rellena asistencia faltante para los dos meses (mes anterior + actual)
--      para todos los empleados activos. Idempotente (no duplica).
-- =====================================================================

USE [DB_GestionColegial];
GO

SET NOCOUNT ON;
GO

-- ──────────────────────────────────────────────────────────────────────
-- 1) PR_Empleados_Asistencia_List — nuevos parámetros de rango
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_Empleados_Asistencia_List]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Empleados_Asistencia_List];
GO

CREATE PROCEDURE [app].[PR_Empleados_Asistencia_List]
    @Emp_Id      INT  = NULL,
    @Fecha       DATE = NULL,   -- filtro de un solo día (compat)
    @FechaDesde  DATE = NULL,
    @FechaHasta  DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

    -- Rango efectivo:
    --   • Si viene @Fecha → ese día puntual (compat con UI antigua)
    --   • Si vienen @FechaDesde / @FechaHasta → ese rango
    --   • Si no viene nada → primer día del mes anterior hasta hoy
    DECLARE @D DATE, @H DATE;

    IF @Fecha IS NOT NULL
    BEGIN
        SET @D = @Fecha;
        SET @H = @Fecha;
    END
    ELSE
    BEGIN
        SET @D = ISNULL(@FechaDesde, DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, @Hoy)),
                                                  MONTH(DATEADD(MONTH, -1, @Hoy)),
                                                  1));
        SET @H = ISNULL(@FechaHasta, @Hoy);
    END

    SELECT
        ae.AsiEmp_Id,
        ae.Emp_Id,
        e.Emp_Codigo,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre, ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        )))                         AS NombreEmpleado,
        p.Per_Imagen,
        ae.AsiEmp_Fecha,
        ae.AsiEmp_Tipo,
        ae.AsiEmp_Observacion,
        ae.AsiEmp_FechaRegistra
    FROM [app].[tbAsistenciaEmpleados] ae
    INNER JOIN [app].[tbEmpleados] e ON ae.Emp_Id = e.Emp_Id
    INNER JOIN [app].[tbPersonas]  p ON e.Per_Id  = p.Per_Id
    WHERE ae.AsiEmp_EsEliminado = 0
      AND (@Emp_Id IS NULL OR ae.Emp_Id = @Emp_Id)
      AND ae.AsiEmp_Fecha BETWEEN @D AND @H
    ORDER BY ae.AsiEmp_Fecha DESC, p.Per_ApellidoPaterno;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- 2) Seed: mes anterior + mes actual para todos los empleados activos
--    Reparto por empleado (mod 10):
--        0–6 → Presente (70%)
--        7   → Tardanza
--        8   → Ausente
--        9   → Permiso
--    Se omiten sábados y domingos (DATEPART weekday con DATEFIRST=7: 1=Dom, 7=Sáb).
--    Idempotente: NOT EXISTS evita duplicados (clave única Emp_Id+Fecha).
-- ──────────────────────────────────────────────────────────────────────
DECLARE @Hoy        DATE = CAST(GETDATE() AS DATE);
DECLARE @PrimerDia  DATE = DATEFROMPARTS(
                              YEAR (DATEADD(MONTH, -1, @Hoy)),
                              MONTH(DATEADD(MONTH, -1, @Hoy)),
                              1);
DECLARE @UltimoDia  DATE = @Hoy;

DECLARE @Fecha DATE = @PrimerDia;
DECLARE @Insertados INT = 0;

SET DATEFIRST 7;

WHILE @Fecha <= @UltimoDia
BEGIN
    -- 1=Dom, 7=Sáb → omitir fines de semana
    IF DATEPART(WEEKDAY, @Fecha) NOT IN (1, 7)
    BEGIN
        INSERT INTO [app].[tbAsistenciaEmpleados]
            (Emp_Id, AsiEmp_Fecha, AsiEmp_Tipo, AsiEmp_EsEliminado, AsiEmp_UsuarioRegistra)
        SELECT
            e.Emp_Id,
            @Fecha,
            CASE (e.Emp_Id % 10)
                WHEN 7 THEN 'Tardanza'
                WHEN 8 THEN 'Ausente'
                WHEN 9 THEN 'Permiso'
                ELSE 'Presente'
            END,
            0,
            1
        FROM [app].[tbEmpleados] e
        INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
        WHERE p.Per_EsActivo = 1
          AND p.Per_EsEliminado = 0
          AND NOT EXISTS (
              SELECT 1
              FROM [app].[tbAsistenciaEmpleados] a2
              WHERE a2.Emp_Id       = e.Emp_Id
                AND a2.AsiEmp_Fecha = @Fecha
          );

        SET @Insertados = @Insertados + @@ROWCOUNT;
    END

    SET @Fecha = DATEADD(DAY, 1, @Fecha);
END

PRINT CONCAT('Seed Asistencia ', CONVERT(VARCHAR(10), @PrimerDia, 23),
             ' → ',              CONVERT(VARCHAR(10), @UltimoDia, 23),
             ' | Filas insertadas: ', @Insertados);
GO

-- Verificación
SELECT
    COUNT(*)              AS TotalRegistros,
    MIN(AsiEmp_Fecha)     AS MinFecha,
    MAX(AsiEmp_Fecha)     AS MaxFecha,
    COUNT(DISTINCT Emp_Id) AS Empleados
FROM [app].[tbAsistenciaEmpleados]
WHERE AsiEmp_EsEliminado = 0;
GO
