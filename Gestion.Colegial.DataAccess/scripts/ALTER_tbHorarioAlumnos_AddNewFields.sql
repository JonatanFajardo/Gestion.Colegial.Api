-- =====================================================================
-- Script: ALTER TABLE tbHorarioAlumnos - Agregar Campos Faltantes
-- Descripción: Agrega los campos necesarios para que la tabla sea
--              funcional en un entorno escolar real
-- Fecha: 2025-11-08
-- =====================================================================

USE [DB_GestionColegial]
GO

-- =====================================================================
-- PASO 1: Agregar nuevas columnas a la tabla
-- =====================================================================

-- 1. Agregar Sec_Id (Sección) - CRÍTICO
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioAlumnos]')
               AND name = 'Sec_Id')
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos]
    ADD [Sec_Id] INT NULL;
    PRINT 'Campo Sec_Id agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo Sec_Id ya existe.';
END
GO

-- 2. Agregar Aul_Id (Aula) - MUY IMPORTANTE
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioAlumnos]')
               AND name = 'Aul_Id')
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos]
    ADD [Aul_Id] INT NULL;
    PRINT 'Campo Aul_Id agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo Aul_Id ya existe.';
END
GO

-- 3. Agregar Emp_Id (Empleado/Profesor) - IMPORTANTE
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioAlumnos]')
               AND name = 'Emp_Id')
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos]
    ADD [Emp_Id] INT NULL;
    PRINT 'Campo Emp_Id agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo Emp_Id ya existe.';
END
GO

-- 4. Agregar Sem_Id (Semestre) - IMPORTANTE
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioAlumnos]')
               AND name = 'Sem_Id')
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos]
    ADD [Sem_Id] INT NULL;
    PRINT 'Campo Sem_Id agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo Sem_Id ya existe.';
END
GO

-- 5. Agregar Mda_Id (Modalidad) - RECOMENDADO
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioAlumnos]')
               AND name = 'Mda_Id')
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos]
    ADD [Mda_Id] INT NULL;
    PRINT 'Campo Mda_Id agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo Mda_Id ya existe.';
END
GO

-- 6. Agregar HoAl_Año (Año Académico) - CRÍTICO
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioAlumnos]')
               AND name = 'HoAl_Año')
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos]
    ADD [HoAl_Año] INT NULL;
    PRINT 'Campo HoAl_Año agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo HoAl_Año ya existe.';
END
GO

-- =====================================================================
-- PASO 2: Actualizar valores NULL con datos por defecto
--         (Solo si hay datos existentes)
-- =====================================================================

-- Actualizar año académico con el año actual si está NULL
UPDATE [app].[tbHorarioAlumnos]
SET [HoAl_Año] = YEAR(GETDATE())
WHERE [HoAl_Año] IS NULL;
GO

-- =====================================================================
-- PASO 3: Convertir columnas críticas a NOT NULL
--         (Solo después de llenar los datos)
-- =====================================================================

-- Hacer Sec_Id NOT NULL (si todos los registros tienen valor)
IF NOT EXISTS (SELECT * FROM [app].[tbHorarioAlumnos] WHERE [Sec_Id] IS NULL)
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos]
    ALTER COLUMN [Sec_Id] INT NOT NULL;
    PRINT 'Campo Sec_Id convertido a NOT NULL.';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: Sec_Id tiene valores NULL. Debe llenar los datos antes de hacer NOT NULL.';
END
GO

-- Hacer Aul_Id NOT NULL (si todos los registros tienen valor)
IF NOT EXISTS (SELECT * FROM [app].[tbHorarioAlumnos] WHERE [Aul_Id] IS NULL)
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos]
    ALTER COLUMN [Aul_Id] INT NOT NULL;
    PRINT 'Campo Aul_Id convertido a NOT NULL.';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: Aul_Id tiene valores NULL. Debe llenar los datos antes de hacer NOT NULL.';
END
GO

-- Hacer Emp_Id NOT NULL (si todos los registros tienen valor)
IF NOT EXISTS (SELECT * FROM [app].[tbHorarioAlumnos] WHERE [Emp_Id] IS NULL)
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos]
    ALTER COLUMN [Emp_Id] INT NOT NULL;
    PRINT 'Campo Emp_Id convertido a NOT NULL.';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: Emp_Id tiene valores NULL. Debe llenar los datos antes de hacer NOT NULL.';
END
GO

-- Hacer Sem_Id NOT NULL (si todos los registros tienen valor)
IF NOT EXISTS (SELECT * FROM [app].[tbHorarioAlumnos] WHERE [Sem_Id] IS NULL)
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos]
    ALTER COLUMN [Sem_Id] INT NOT NULL;
    PRINT 'Campo Sem_Id convertido a NOT NULL.';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: Sem_Id tiene valores NULL. Debe llenar los datos antes de hacer NOT NULL.';
END
GO

-- Hacer HoAl_Año NOT NULL (ya debería tener valores después del UPDATE anterior)
IF NOT EXISTS (SELECT * FROM [app].[tbHorarioAlumnos] WHERE [HoAl_Año] IS NULL)
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos]
    ALTER COLUMN [HoAl_Año] INT NOT NULL;
    PRINT 'Campo HoAl_Año convertido a NOT NULL.';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: HoAl_Año tiene valores NULL. Debe llenar los datos antes de hacer NOT NULL.';
END
GO

-- =====================================================================
-- PASO 4: Agregar Foreign Keys (Relaciones)
-- =====================================================================

-- FK: Sec_Id -> tbSecciones
IF NOT EXISTS (SELECT * FROM sys.foreign_keys
               WHERE object_id = OBJECT_ID(N'[app].[FK_tbHorarioAlumnos_tbSecciones_Sec_Id]'))
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos] WITH CHECK
    ADD CONSTRAINT [FK_tbHorarioAlumnos_tbSecciones_Sec_Id]
    FOREIGN KEY([Sec_Id])
    REFERENCES [app].[tbSecciones] ([Sec_Id]);

    ALTER TABLE [app].[tbHorarioAlumnos]
    CHECK CONSTRAINT [FK_tbHorarioAlumnos_tbSecciones_Sec_Id];

    PRINT 'Foreign Key FK_tbHorarioAlumnos_tbSecciones_Sec_Id creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tbHorarioAlumnos_tbSecciones_Sec_Id ya existe.';
END
GO

-- FK: Aul_Id -> tbAulas
IF NOT EXISTS (SELECT * FROM sys.foreign_keys
               WHERE object_id = OBJECT_ID(N'[app].[FK_tbHorarioAlumnos_tbAulas_Aul_Id]'))
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos] WITH CHECK
    ADD CONSTRAINT [FK_tbHorarioAlumnos_tbAulas_Aul_Id]
    FOREIGN KEY([Aul_Id])
    REFERENCES [app].[tbAulas] ([Aul_Id]);

    ALTER TABLE [app].[tbHorarioAlumnos]
    CHECK CONSTRAINT [FK_tbHorarioAlumnos_tbAulas_Aul_Id];

    PRINT 'Foreign Key FK_tbHorarioAlumnos_tbAulas_Aul_Id creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tbHorarioAlumnos_tbAulas_Aul_Id ya existe.';
END
GO

-- FK: Emp_Id -> tbEmpleados
IF NOT EXISTS (SELECT * FROM sys.foreign_keys
               WHERE object_id = OBJECT_ID(N'[app].[FK_tbHorarioAlumnos_tbEmpleados_Emp_Id]'))
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos] WITH CHECK
    ADD CONSTRAINT [FK_tbHorarioAlumnos_tbEmpleados_Emp_Id]
    FOREIGN KEY([Emp_Id])
    REFERENCES [app].[tbEmpleados] ([Emp_Id]);

    ALTER TABLE [app].[tbHorarioAlumnos]
    CHECK CONSTRAINT [FK_tbHorarioAlumnos_tbEmpleados_Emp_Id];

    PRINT 'Foreign Key FK_tbHorarioAlumnos_tbEmpleados_Emp_Id creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tbHorarioAlumnos_tbEmpleados_Emp_Id ya existe.';
END
GO

-- FK: Sem_Id -> tbSemestres
IF NOT EXISTS (SELECT * FROM sys.foreign_keys
               WHERE object_id = OBJECT_ID(N'[app].[FK_tbHorarioAlumnos_tbSemestres_Sem_Id]'))
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos] WITH CHECK
    ADD CONSTRAINT [FK_tbHorarioAlumnos_tbSemestres_Sem_Id]
    FOREIGN KEY([Sem_Id])
    REFERENCES [app].[tbSemestres] ([Sem_Id]);

    ALTER TABLE [app].[tbHorarioAlumnos]
    CHECK CONSTRAINT [FK_tbHorarioAlumnos_tbSemestres_Sem_Id];

    PRINT 'Foreign Key FK_tbHorarioAlumnos_tbSemestres_Sem_Id creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tbHorarioAlumnos_tbSemestres_Sem_Id ya existe.';
END
GO

-- FK: Mda_Id -> tbModalidades (opcional)
IF NOT EXISTS (SELECT * FROM sys.foreign_keys
               WHERE object_id = OBJECT_ID(N'[app].[FK_tbHorarioAlumnos_tbModalidades_Mda_Id]'))
BEGIN
    ALTER TABLE [app].[tbHorarioAlumnos] WITH CHECK
    ADD CONSTRAINT [FK_tbHorarioAlumnos_tbModalidades_Mda_Id]
    FOREIGN KEY([Mda_Id])
    REFERENCES [app].[tbModalidades] ([Mda_Id]);

    ALTER TABLE [app].[tbHorarioAlumnos]
    CHECK CONSTRAINT [FK_tbHorarioAlumnos_tbModalidades_Mda_Id];

    PRINT 'Foreign Key FK_tbHorarioAlumnos_tbModalidades_Mda_Id creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tbHorarioAlumnos_tbModalidades_Mda_Id ya existe.';
END
GO

-- =====================================================================
-- PASO 5: Crear índices para mejorar rendimiento
-- =====================================================================

-- Índice compuesto para consultas comunes
IF NOT EXISTS (SELECT * FROM sys.indexes
               WHERE name = 'IX_tbHorarioAlumnos_Año_Sem_Sec_Dia'
               AND object_id = OBJECT_ID(N'[app].[tbHorarioAlumnos]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_tbHorarioAlumnos_Año_Sem_Sec_Dia]
    ON [app].[tbHorarioAlumnos]
    (
        [HoAl_Año] ASC,
        [Sem_Id] ASC,
        [Sec_Id] ASC,
        [Dia_Id] ASC
    );
    PRINT 'Índice IX_tbHorarioAlumnos_Año_Sem_Sec_Dia creado correctamente.';
END
ELSE
BEGIN
    PRINT 'Índice IX_tbHorarioAlumnos_Año_Sem_Sec_Dia ya existe.';
END
GO

-- =====================================================================
-- RESUMEN DE CAMBIOS APLICADOS
-- =====================================================================

PRINT '';
PRINT '=====================================================================';
PRINT 'RESUMEN DE CAMBIOS APLICADOS A tbHorarioAlumnos';
PRINT '=====================================================================';
PRINT 'Nuevos campos agregados:';
PRINT '  - Sec_Id (Sección) - CRÍTICO';
PRINT '  - Aul_Id (Aula) - MUY IMPORTANTE';
PRINT '  - Emp_Id (Empleado/Profesor) - IMPORTANTE';
PRINT '  - Sem_Id (Semestre) - IMPORTANTE';
PRINT '  - Mda_Id (Modalidad) - RECOMENDADO';
PRINT '  - HoAl_Año (Año Académico) - CRÍTICO';
PRINT '';
PRINT 'Foreign Keys creadas: 5';
PRINT 'Índices creados: 1';
PRINT '';
PRINT 'IMPORTANTE: Recuerde actualizar:';
PRINT '  1. Los DTOs en C# para reflejar los nuevos campos';
PRINT '  2. Los Stored Procedures (Insert, Update, List, Find, Detail)';
PRINT '  3. El Repository y Service para manejar los nuevos campos';
PRINT '  4. La entidad tbHorarioAlumnos.cs';
PRINT '=====================================================================';
GO
