-- =====================================================================
-- Script: ALTER TABLE tbHorarioProfesores - Agregar Campos Faltantes
-- Descripción: Agrega los campos necesarios para que la tabla sea
--              funcional en un entorno escolar real
-- Fecha: 2025-11-08
-- =====================================================================

USE [DB_GestionColegial]
GO

-- =====================================================================
-- PASO 1: Agregar nuevas columnas a la tabla
-- =====================================================================

-- 1. Agregar Mat_Id (Materia) - CRÍTICO
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioProfesores]')
               AND name = 'Mat_Id')
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ADD [Mat_Id] INT NULL;
    PRINT 'Campo Mat_Id agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo Mat_Id ya existe.';
END
GO

-- 2. Agregar Emp_Id (Empleado/Profesor) - CRÍTICO
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioProfesores]')
               AND name = 'Emp_Id')
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ADD [Emp_Id] INT NULL;
    PRINT 'Campo Emp_Id agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo Emp_Id ya existe.';
END
GO

-- 3. Agregar Sec_Id (Sección) - CRÍTICO
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioProfesores]')
               AND name = 'Sec_Id')
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ADD [Sec_Id] INT NULL;
    PRINT 'Campo Sec_Id agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo Sec_Id ya existe.';
END
GO

-- 4. Agregar Aul_Id (Aula) - MUY IMPORTANTE
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioProfesores]')
               AND name = 'Aul_Id')
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ADD [Aul_Id] INT NULL;
    PRINT 'Campo Aul_Id agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo Aul_Id ya existe.';
END
GO

-- 5. Agregar Sem_Id (Semestre) - IMPORTANTE
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioProfesores]')
               AND name = 'Sem_Id')
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ADD [Sem_Id] INT NULL;
    PRINT 'Campo Sem_Id agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo Sem_Id ya existe.';
END
GO

-- 6. Agregar Mda_Id (Modalidad) - RECOMENDADO
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioProfesores]')
               AND name = 'Mda_Id')
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ADD [Mda_Id] INT NULL;
    PRINT 'Campo Mda_Id agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo Mda_Id ya existe.';
END
GO

-- 7. Agregar HoPr_Año (Año Académico) - CRÍTICO
IF NOT EXISTS (SELECT * FROM sys.columns
               WHERE object_id = OBJECT_ID(N'[app].[tbHorarioProfesores]')
               AND name = 'HoPr_Año')
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ADD [HoPr_Año] INT NULL;
    PRINT 'Campo HoPr_Año agregado correctamente.';
END
ELSE
BEGIN
    PRINT 'Campo HoPr_Año ya existe.';
END
GO

-- =====================================================================
-- PASO 2: Actualizar valores NULL con datos por defecto
--         (Solo si hay datos existentes)
-- =====================================================================

-- Actualizar año académico con el año actual si está NULL
UPDATE [app].[tbHorarioProfesores]
SET [HoPr_Año] = YEAR(GETDATE())
WHERE [HoPr_Año] IS NULL;
GO

-- =====================================================================
-- PASO 3: Convertir columnas críticas a NOT NULL
--         (Solo después de llenar los datos)
-- =====================================================================

-- Hacer Mat_Id NOT NULL (si todos los registros tienen valor)
IF NOT EXISTS (SELECT * FROM [app].[tbHorarioProfesores] WHERE [Mat_Id] IS NULL)
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ALTER COLUMN [Mat_Id] INT NOT NULL;
    PRINT 'Campo Mat_Id convertido a NOT NULL.';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: Mat_Id tiene valores NULL. Debe llenar los datos antes de hacer NOT NULL.';
END
GO

-- Hacer Emp_Id NOT NULL (si todos los registros tienen valor)
IF NOT EXISTS (SELECT * FROM [app].[tbHorarioProfesores] WHERE [Emp_Id] IS NULL)
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ALTER COLUMN [Emp_Id] INT NOT NULL;
    PRINT 'Campo Emp_Id convertido a NOT NULL.';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: Emp_Id tiene valores NULL. Debe llenar los datos antes de hacer NOT NULL.';
END
GO

-- Hacer Sec_Id NOT NULL (si todos los registros tienen valor)
IF NOT EXISTS (SELECT * FROM [app].[tbHorarioProfesores] WHERE [Sec_Id] IS NULL)
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ALTER COLUMN [Sec_Id] INT NOT NULL;
    PRINT 'Campo Sec_Id convertido a NOT NULL.';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: Sec_Id tiene valores NULL. Debe llenar los datos antes de hacer NOT NULL.';
END
GO

-- Hacer Aul_Id NOT NULL (si todos los registros tienen valor)
IF NOT EXISTS (SELECT * FROM [app].[tbHorarioProfesores] WHERE [Aul_Id] IS NULL)
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ALTER COLUMN [Aul_Id] INT NOT NULL;
    PRINT 'Campo Aul_Id convertido a NOT NULL.';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: Aul_Id tiene valores NULL. Debe llenar los datos antes de hacer NOT NULL.';
END
GO

-- Hacer Sem_Id NOT NULL (si todos los registros tienen valor)
IF NOT EXISTS (SELECT * FROM [app].[tbHorarioProfesores] WHERE [Sem_Id] IS NULL)
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ALTER COLUMN [Sem_Id] INT NOT NULL;
    PRINT 'Campo Sem_Id convertido a NOT NULL.';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: Sem_Id tiene valores NULL. Debe llenar los datos antes de hacer NOT NULL.';
END
GO

-- Hacer HoPr_Año NOT NULL (ya debería tener valores después del UPDATE anterior)
IF NOT EXISTS (SELECT * FROM [app].[tbHorarioProfesores] WHERE [HoPr_Año] IS NULL)
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores]
    ALTER COLUMN [HoPr_Año] INT NOT NULL;
    PRINT 'Campo HoPr_Año convertido a NOT NULL.';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: HoPr_Año tiene valores NULL. Debe llenar los datos antes de hacer NOT NULL.';
END
GO

-- =====================================================================
-- PASO 4: Agregar Foreign Keys (Relaciones)
-- =====================================================================

-- FK: Mat_Id -> tbMaterias
IF NOT EXISTS (SELECT * FROM sys.foreign_keys
               WHERE object_id = OBJECT_ID(N'[app].[FK_tbHorarioProfesores_tbMaterias_Mat_Id]'))
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores] WITH CHECK
    ADD CONSTRAINT [FK_tbHorarioProfesores_tbMaterias_Mat_Id]
    FOREIGN KEY([Mat_Id])
    REFERENCES [app].[tbMaterias] ([Mat_Id]);

    ALTER TABLE [app].[tbHorarioProfesores]
    CHECK CONSTRAINT [FK_tbHorarioProfesores_tbMaterias_Mat_Id];

    PRINT 'Foreign Key FK_tbHorarioProfesores_tbMaterias_Mat_Id creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tbHorarioProfesores_tbMaterias_Mat_Id ya existe.';
END
GO

-- FK: Emp_Id -> tbEmpleados
IF NOT EXISTS (SELECT * FROM sys.foreign_keys
               WHERE object_id = OBJECT_ID(N'[app].[FK_tbHorarioProfesores_tbEmpleados_Emp_Id]'))
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores] WITH CHECK
    ADD CONSTRAINT [FK_tbHorarioProfesores_tbEmpleados_Emp_Id]
    FOREIGN KEY([Emp_Id])
    REFERENCES [app].[tbEmpleados] ([Emp_Id]);

    ALTER TABLE [app].[tbHorarioProfesores]
    CHECK CONSTRAINT [FK_tbHorarioProfesores_tbEmpleados_Emp_Id];

    PRINT 'Foreign Key FK_tbHorarioProfesores_tbEmpleados_Emp_Id creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tbHorarioProfesores_tbEmpleados_Emp_Id ya existe.';
END
GO

-- FK: Sec_Id -> tbSecciones
IF NOT EXISTS (SELECT * FROM sys.foreign_keys
               WHERE object_id = OBJECT_ID(N'[app].[FK_tbHorarioProfesores_tbSecciones_Sec_Id]'))
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores] WITH CHECK
    ADD CONSTRAINT [FK_tbHorarioProfesores_tbSecciones_Sec_Id]
    FOREIGN KEY([Sec_Id])
    REFERENCES [app].[tbSecciones] ([Sec_Id]);

    ALTER TABLE [app].[tbHorarioProfesores]
    CHECK CONSTRAINT [FK_tbHorarioProfesores_tbSecciones_Sec_Id];

    PRINT 'Foreign Key FK_tbHorarioProfesores_tbSecciones_Sec_Id creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tbHorarioProfesores_tbSecciones_Sec_Id ya existe.';
END
GO

-- FK: Aul_Id -> tbAulas
IF NOT EXISTS (SELECT * FROM sys.foreign_keys
               WHERE object_id = OBJECT_ID(N'[app].[FK_tbHorarioProfesores_tbAulas_Aul_Id]'))
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores] WITH CHECK
    ADD CONSTRAINT [FK_tbHorarioProfesores_tbAulas_Aul_Id]
    FOREIGN KEY([Aul_Id])
    REFERENCES [app].[tbAulas] ([Aul_Id]);

    ALTER TABLE [app].[tbHorarioProfesores]
    CHECK CONSTRAINT [FK_tbHorarioProfesores_tbAulas_Aul_Id];

    PRINT 'Foreign Key FK_tbHorarioProfesores_tbAulas_Aul_Id creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tbHorarioProfesores_tbAulas_Aul_Id ya existe.';
END
GO

-- FK: Sem_Id -> tbSemestres
IF NOT EXISTS (SELECT * FROM sys.foreign_keys
               WHERE object_id = OBJECT_ID(N'[app].[FK_tbHorarioProfesores_tbSemestres_Sem_Id]'))
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores] WITH CHECK
    ADD CONSTRAINT [FK_tbHorarioProfesores_tbSemestres_Sem_Id]
    FOREIGN KEY([Sem_Id])
    REFERENCES [app].[tbSemestres] ([Sem_Id]);

    ALTER TABLE [app].[tbHorarioProfesores]
    CHECK CONSTRAINT [FK_tbHorarioProfesores_tbSemestres_Sem_Id];

    PRINT 'Foreign Key FK_tbHorarioProfesores_tbSemestres_Sem_Id creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tbHorarioProfesores_tbSemestres_Sem_Id ya existe.';
END
GO

-- FK: Mda_Id -> tbModalidades (opcional)
IF NOT EXISTS (SELECT * FROM sys.foreign_keys
               WHERE object_id = OBJECT_ID(N'[app].[FK_tbHorarioProfesores_tbModalidades_Mda_Id]'))
BEGIN
    ALTER TABLE [app].[tbHorarioProfesores] WITH CHECK
    ADD CONSTRAINT [FK_tbHorarioProfesores_tbModalidades_Mda_Id]
    FOREIGN KEY([Mda_Id])
    REFERENCES [app].[tbModalidades] ([Mda_Id]);

    ALTER TABLE [app].[tbHorarioProfesores]
    CHECK CONSTRAINT [FK_tbHorarioProfesores_tbModalidades_Mda_Id];

    PRINT 'Foreign Key FK_tbHorarioProfesores_tbModalidades_Mda_Id creada correctamente.';
END
ELSE
BEGIN
    PRINT 'Foreign Key FK_tbHorarioProfesores_tbModalidades_Mda_Id ya existe.';
END
GO

-- =====================================================================
-- PASO 5: Crear índices para mejorar rendimiento
-- =====================================================================

-- Índice compuesto para consultas comunes de profesores
IF NOT EXISTS (SELECT * FROM sys.indexes
               WHERE name = 'IX_tbHorarioProfesores_Año_Sem_Emp_Dia'
               AND object_id = OBJECT_ID(N'[app].[tbHorarioProfesores]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_tbHorarioProfesores_Año_Sem_Emp_Dia]
    ON [app].[tbHorarioProfesores]
    (
        [HoPr_Año] ASC,
        [Sem_Id] ASC,
        [Emp_Id] ASC,
        [Dia_Id] ASC
    );
    PRINT 'Índice IX_tbHorarioProfesores_Año_Sem_Emp_Dia creado correctamente.';
END
ELSE
BEGIN
    PRINT 'Índice IX_tbHorarioProfesores_Año_Sem_Emp_Dia ya existe.';
END
GO

-- =====================================================================
-- RESUMEN DE CAMBIOS APLICADOS
-- =====================================================================

PRINT '';
PRINT '=====================================================================';
PRINT 'RESUMEN DE CAMBIOS APLICADOS A tbHorarioProfesores';
PRINT '=====================================================================';
PRINT 'Nuevos campos agregados:';
PRINT '  - Mat_Id (Materia) - CRÍTICO';
PRINT '  - Emp_Id (Empleado/Profesor) - CRÍTICO';
PRINT '  - Sec_Id (Sección) - CRÍTICO';
PRINT '  - Aul_Id (Aula) - MUY IMPORTANTE';
PRINT '  - Sem_Id (Semestre) - IMPORTANTE';
PRINT '  - Mda_Id (Modalidad) - RECOMENDADO';
PRINT '  - HoPr_Año (Año Académico) - CRÍTICO';
PRINT '';
PRINT 'Foreign Keys creadas: 6';
PRINT 'Índices creados: 1';
PRINT '';
PRINT 'IMPORTANTE: Recuerde:';
PRINT '  1. Crear los Stored Procedures para esta tabla';
PRINT '  2. Crear los DTOs en C# para reflejar los nuevos campos';
PRINT '  3. Crear el Repository y Service';
PRINT '  4. Actualizar la entidad tbHorarioProfesores.cs';
PRINT '  5. Crear el Controller';
PRINT '=====================================================================';
GO
