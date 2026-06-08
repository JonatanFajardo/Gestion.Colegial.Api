-- 037_DashboardRRHH_SeedData.sql
-- Seed data para tbVacaciones y tbAsistenciaEmpleados
-- Solo inserta si las tablas están vacías.

SET NOCOUNT ON;

-- ── Vacaciones / Permisos / Incapacidades ────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM [app].[tbVacaciones])
BEGIN
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

    -- 1  Emp 3  – Vacaciones pendientes (próximas)
    INSERT INTO [app].[tbVacaciones] (Emp_Id, Vac_Tipo, Vac_FechaInicio, Vac_FechaFin, Vac_Estado, Vac_Motivo, Vac_EsEliminado, Vac_UsuarioRegistra)
    VALUES (3, 'V', DATEADD(DAY,  5, @Hoy), DATEADD(DAY, 19, @Hoy), 'P', N'Vacaciones anuales', 0, 1);

    -- 2  Emp 5  – Permiso pendiente
    INSERT INTO [app].[tbVacaciones] (Emp_Id, Vac_Tipo, Vac_FechaInicio, Vac_FechaFin, Vac_Estado, Vac_Motivo, Vac_EsEliminado, Vac_UsuarioRegistra)
    VALUES (5, 'P', DATEADD(DAY,  2, @Hoy), DATEADD(DAY,  3, @Hoy), 'P', N'Cita médica familiar', 0, 1);

    -- 3  Emp 7  – Incapacidad pendiente
    INSERT INTO [app].[tbVacaciones] (Emp_Id, Vac_Tipo, Vac_FechaInicio, Vac_FechaFin, Vac_Estado, Vac_Motivo, Vac_EsEliminado, Vac_UsuarioRegistra)
    VALUES (7, 'I', DATEADD(DAY, -3, @Hoy), DATEADD(DAY,  2, @Hoy), 'P', N'Incapacidad por gripe', 0, 1);

    -- 4  Emp 10 – Vacaciones aprobadas (historial)
    INSERT INTO [app].[tbVacaciones] (Emp_Id, Vac_Tipo, Vac_FechaInicio, Vac_FechaFin, Vac_Estado, Vac_Motivo, Vac_EsEliminado, Vac_UsuarioRegistra)
    VALUES (10, 'V', DATEADD(MONTH, -2, @Hoy), DATEADD(DAY, -45, @Hoy), 'A', N'Vacaciones aprobadas', 0, 1);

    -- 5  Emp 12 – Permiso aprobado
    INSERT INTO [app].[tbVacaciones] (Emp_Id, Vac_Tipo, Vac_FechaInicio, Vac_FechaFin, Vac_Estado, Vac_Motivo, Vac_EsEliminado, Vac_UsuarioRegistra)
    VALUES (12, 'P', DATEADD(MONTH, -1, @Hoy), DATEADD(DAY, -28, @Hoy), 'A', N'Permiso personal', 0, 1);

    -- 6  Emp 15 – Vacaciones rechazadas
    INSERT INTO [app].[tbVacaciones] (Emp_Id, Vac_Tipo, Vac_FechaInicio, Vac_FechaFin, Vac_Estado, Vac_Motivo, Vac_EsEliminado, Vac_UsuarioRegistra)
    VALUES (15, 'V', DATEADD(DAY, 30, @Hoy), DATEADD(DAY, 44, @Hoy), 'R', N'Vacaciones rechazadas por temporada', 0, 1);

    -- 7  Emp 20 – Incapacidad aprobada
    INSERT INTO [app].[tbVacaciones] (Emp_Id, Vac_Tipo, Vac_FechaInicio, Vac_FechaFin, Vac_Estado, Vac_Motivo, Vac_EsEliminado, Vac_UsuarioRegistra)
    VALUES (20, 'I', DATEADD(DAY, -10, @Hoy), DATEADD(DAY, -5, @Hoy), 'A', N'Incapacidad cirugía menor', 0, 1);

    -- 8  Emp 8  – Permiso pendiente
    INSERT INTO [app].[tbVacaciones] (Emp_Id, Vac_Tipo, Vac_FechaInicio, Vac_FechaFin, Vac_Estado, Vac_Motivo, Vac_EsEliminado, Vac_UsuarioRegistra)
    VALUES (8, 'P', DATEADD(DAY, 1, @Hoy), DATEADD(DAY, 1, @Hoy), 'P', N'Trámite personal', 0, 1);

    PRINT 'Seed tbVacaciones: 8 registros insertados.';
END
ELSE
    PRINT 'tbVacaciones ya tiene datos. Seed omitido.';
GO

-- ── Asistencia Empleados (últimos 14 días) ───────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM [app].[tbAsistenciaEmpleados])
BEGIN
    DECLARE @d INT = 0;
    DECLARE @Fecha DATE;

    -- Generamos asistencia para los últimos 14 días para todos los empleados activos
    WHILE @d < 14
    BEGIN
        SET @Fecha = DATEADD(DAY, -@d, CAST(GETDATE() AS DATE));

        -- Solo días de semana (Lunes a Viernes)
        IF DATEPART(WEEKDAY, @Fecha) NOT IN (1, 7)  -- 1=Domingo, 7=Sábado (en SQL Server con DATEFIRST=7)
        BEGIN
            -- Empleados 1-40 marcan Presente
            INSERT INTO [app].[tbAsistenciaEmpleados]
                (Emp_Id, AsiEmp_Fecha, AsiEmp_Tipo, AsiEmp_EsEliminado, AsiEmp_UsuarioRegistra)
            SELECT e.Emp_Id, @Fecha, 'Presente', 0, 1
            FROM [app].[tbEmpleados] e
            INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
            WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0
              AND e.Emp_Id BETWEEN 1 AND 40
              AND NOT EXISTS (SELECT 1 FROM [app].[tbAsistenciaEmpleados] a2
                              WHERE a2.Emp_Id = e.Emp_Id AND a2.AsiEmp_Fecha = @Fecha);

            -- Empleados 41-45 marcan Tardanza
            INSERT INTO [app].[tbAsistenciaEmpleados]
                (Emp_Id, AsiEmp_Fecha, AsiEmp_Tipo, AsiEmp_EsEliminado, AsiEmp_UsuarioRegistra)
            SELECT e.Emp_Id, @Fecha, 'Tardanza', 0, 1
            FROM [app].[tbEmpleados] e
            INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
            WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0
              AND e.Emp_Id BETWEEN 41 AND 45
              AND NOT EXISTS (SELECT 1 FROM [app].[tbAsistenciaEmpleados] a2
                              WHERE a2.Emp_Id = e.Emp_Id AND a2.AsiEmp_Fecha = @Fecha);

            -- Empleados 46-50 marcan Ausente
            INSERT INTO [app].[tbAsistenciaEmpleados]
                (Emp_Id, AsiEmp_Fecha, AsiEmp_Tipo, AsiEmp_EsEliminado, AsiEmp_UsuarioRegistra)
            SELECT e.Emp_Id, @Fecha, 'Ausente', 0, 1
            FROM [app].[tbEmpleados] e
            INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
            WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0
              AND e.Emp_Id BETWEEN 46 AND 50
              AND NOT EXISTS (SELECT 1 FROM [app].[tbAsistenciaEmpleados] a2
                              WHERE a2.Emp_Id = e.Emp_Id AND a2.AsiEmp_Fecha = @Fecha);
        END

        SET @d = @d + 1;
    END

    PRINT 'Seed tbAsistenciaEmpleados: asistencia de 14 días insertada.';
END
ELSE
    PRINT 'tbAsistenciaEmpleados ya tiene datos. Seed omitido.';
GO
