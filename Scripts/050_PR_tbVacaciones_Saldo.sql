-- ============================================================
-- 050_PR_tbVacaciones_Saldo
-- Saldo de vacaciones por empleado.
-- Antigüedad basada en Per_FechaRegistra (misma fuente que
-- PR_Empleados_Antiguedad). Escala de días según el Código del
-- Trabajo de Honduras, Art. 346:
--   1 año   -> 10 días
--   2 años  -> 12 días
--   3 años  -> 15 días
--   4+ años -> 20 días
-- Días tomados = solicitudes de tipo Vacaciones ('V') APROBADAS ('A')
-- del año en curso. Los pendientes ('P') se informan aparte.
-- ============================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbVacaciones_Saldo]') AND type = 'P')
    DROP PROCEDURE [app].[PR_tbVacaciones_Saldo];
GO
CREATE PROCEDURE [app].[PR_tbVacaciones_Saldo]
    @Emp_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FechaIngreso DATE;
    SELECT @FechaIngreso = p.Per_FechaRegistra
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
    WHERE e.Emp_Id = @Emp_Id;

    -- Años completos de servicio
    DECLARE @Anos INT = 0;
    IF @FechaIngreso IS NOT NULL
    BEGIN
        SET @Anos = DATEDIFF(YEAR, @FechaIngreso, GETDATE())
                  - CASE WHEN (MONTH(@FechaIngreso) > MONTH(GETDATE()))
                           OR (MONTH(@FechaIngreso) = MONTH(GETDATE()) AND DAY(@FechaIngreso) > DAY(GETDATE()))
                         THEN 1 ELSE 0 END;
        IF @Anos < 0 SET @Anos = 0;
    END

    DECLARE @DiasDerecho INT =
        CASE
            WHEN @Anos < 1 THEN 0
            WHEN @Anos = 1 THEN 10
            WHEN @Anos = 2 THEN 12
            WHEN @Anos = 3 THEN 15
            ELSE 20
        END;

    DECLARE @Anio INT = YEAR(GETDATE());

    DECLARE @DiasTomados INT =
        ISNULL((SELECT SUM(Vac_DiasTotal) FROM [app].[tbVacaciones]
                WHERE Emp_Id = @Emp_Id AND Vac_Tipo = 'V' AND Vac_Estado = 'A'
                  AND Vac_EsEliminado = 0 AND YEAR(Vac_FechaInicio) = @Anio), 0);

    DECLARE @DiasPendientes INT =
        ISNULL((SELECT SUM(Vac_DiasTotal) FROM [app].[tbVacaciones]
                WHERE Emp_Id = @Emp_Id AND Vac_Tipo = 'V' AND Vac_Estado = 'P'
                  AND Vac_EsEliminado = 0 AND YEAR(Vac_FechaInicio) = @Anio), 0);

    SELECT
        @Emp_Id                              AS Emp_Id,
        @Anos                                AS Anos,
        @DiasDerecho                         AS DiasDerecho,
        @DiasTomados                         AS DiasTomados,
        @DiasPendientes                      AS DiasPendientes,
        (@DiasDerecho - @DiasTomados)        AS DiasDisponibles;
END
GO
