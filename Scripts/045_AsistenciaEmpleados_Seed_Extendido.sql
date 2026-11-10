-- =====================================================================
-- 045_AsistenciaEmpleados_Seed_Extendido.sql
--   Completa data de asistencia para TODOS los empleados activos
--   con distribución realista, para el rango 2026-01-01 → hoy - 1.
--
--   Distribución (por (Emp_Id, Fecha) usando CHECKSUM % 100):
--       0..91   → Presente   (92%)
--       92..95  → Ausente    ( 4%)
--       96..98  → Tardanza   ( 3%)
--       99      → Permiso    ( 1%)
--
--   • Omite fines de semana.
--   • Idempotente: NOT EXISTS por (Emp_Id, Fecha).
--   • Reproducible: CHECKSUM(Emp_Id, Fecha) es determinístico.
-- =====================================================================

USE [DB_GestionColegial];
GO

SET NOCOUNT ON;
GO

DECLARE @Hoy        DATE = CAST(GETDATE() AS DATE);
DECLARE @PrimerDia  DATE = '2026-01-01';
DECLARE @UltimoDia  DATE = DATEADD(DAY, -1, @Hoy);   -- hasta ayer

DECLARE @Fecha      DATE = @PrimerDia;
DECLARE @Insertados INT  = 0;

SET DATEFIRST 7;   -- 1=Dom, 7=Sáb

WHILE @Fecha <= @UltimoDia
BEGIN
    IF DATEPART(WEEKDAY, @Fecha) NOT IN (1, 7)
    BEGIN
        INSERT INTO [app].[tbAsistenciaEmpleados]
            (Emp_Id, AsiEmp_Fecha, AsiEmp_Tipo, AsiEmp_EsEliminado, AsiEmp_UsuarioRegistra)
        SELECT
            e.Emp_Id,
            @Fecha,
            CASE
                WHEN ABS(CHECKSUM(e.Emp_Id, @Fecha)) % 100 < 92 THEN 'Presente'
                WHEN ABS(CHECKSUM(e.Emp_Id, @Fecha)) % 100 < 96 THEN 'Ausente'
                WHEN ABS(CHECKSUM(e.Emp_Id, @Fecha)) % 100 < 99 THEN 'Tardanza'
                ELSE 'Permiso'
            END,
            0,
            1
        FROM [app].[tbEmpleados] e
        INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
        WHERE p.Per_EsActivo    = 1
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

-- ─────────────────────────────────────────────────────────────────
-- Verificación
-- ─────────────────────────────────────────────────────────────────
SELECT
    COUNT(*)                AS TotalRegistros,
    MIN(AsiEmp_Fecha)       AS MinFecha,
    MAX(AsiEmp_Fecha)       AS MaxFecha,
    COUNT(DISTINCT Emp_Id)  AS EmpleadosConData
FROM [app].[tbAsistenciaEmpleados]
WHERE AsiEmp_EsEliminado = 0;

SELECT
    AsiEmp_Tipo,
    COUNT(*)                                     AS Total,
    CAST(COUNT(*) * 100.0 /
         SUM(COUNT(*)) OVER () AS DECIMAL(5,2))  AS Porcentaje
FROM [app].[tbAsistenciaEmpleados]
WHERE AsiEmp_EsEliminado = 0
GROUP BY AsiEmp_Tipo
ORDER BY Total DESC;
GO
