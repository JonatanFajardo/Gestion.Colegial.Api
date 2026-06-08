-- =====================================================================
-- Script 032: Seed data para Organigrama
-- Corrige nombres de cargos, agrega departamentos reales y redistribuye
-- los 52 empleados de prueba entre los departamentos.
-- Idempotente: seguro de re-ejecutar.
-- =====================================================================

USE [DB_GestionColegial];
GO

-- ──────────────────────────────────────────────────────────────────────
-- 1. Corregir nombres de cargos existentes
-- ──────────────────────────────────────────────────────────────────────
UPDATE [app].[tbCargos] SET Car_Descripcion = 'Dirección y Coordinación' WHERE Car_Id = 1;
UPDATE [app].[tbCargos] SET Car_Descripcion = 'Administración'           WHERE Car_Id = 2;
UPDATE [app].[tbCargos] SET Car_Descripcion = 'Docencia'                 WHERE Car_Id = 3;
UPDATE [app].[tbCargos] SET Car_Descripcion = 'Servicios Generales'      WHERE Car_Id = 4;
GO

-- ──────────────────────────────────────────────────────────────────────
-- 2. Agregar cargos adicionales (si no existen por descripción)
-- ──────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM [app].[tbCargos] WHERE Car_Descripcion = 'Recursos Humanos')
    INSERT INTO [app].[tbCargos] (Car_Descripcion, Car_EsEliminado, Car_UsuarioRegistra, Car_FechaRegistra)
    VALUES ('Recursos Humanos', 0, 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM [app].[tbCargos] WHERE Car_Descripcion = 'Informática')
    INSERT INTO [app].[tbCargos] (Car_Descripcion, Car_EsEliminado, Car_UsuarioRegistra, Car_FechaRegistra)
    VALUES ('Informática', 0, 1, GETDATE());
GO

-- ──────────────────────────────────────────────────────────────────────
-- 3. Departamentos: renombrar el existente y agregar los demás
-- ──────────────────────────────────────────────────────────────────────
UPDATE [app].[tbDepartamentoEmpleados]
SET Nombre = 'Dirección General'
WHERE Dep_Id = 1;

IF NOT EXISTS (SELECT 1 FROM [app].[tbDepartamentoEmpleados] WHERE Nombre = 'Administración y Finanzas')
    INSERT INTO [app].[tbDepartamentoEmpleados] (Nombre) VALUES ('Administración y Finanzas');

IF NOT EXISTS (SELECT 1 FROM [app].[tbDepartamentoEmpleados] WHERE Nombre = 'Área Docente')
    INSERT INTO [app].[tbDepartamentoEmpleados] (Nombre) VALUES ('Área Docente');

IF NOT EXISTS (SELECT 1 FROM [app].[tbDepartamentoEmpleados] WHERE Nombre = 'Servicios Generales')
    INSERT INTO [app].[tbDepartamentoEmpleados] (Nombre) VALUES ('Servicios Generales');

IF NOT EXISTS (SELECT 1 FROM [app].[tbDepartamentoEmpleados] WHERE Nombre = 'Recursos Humanos')
    INSERT INTO [app].[tbDepartamentoEmpleados] (Nombre) VALUES ('Recursos Humanos');

IF NOT EXISTS (SELECT 1 FROM [app].[tbDepartamentoEmpleados] WHERE Nombre = 'Informática y Tecnología')
    INSERT INTO [app].[tbDepartamentoEmpleados] (Nombre) VALUES ('Informática y Tecnología');
GO

-- ──────────────────────────────────────────────────────────────────────
-- 4. Redistribuir empleados a los departamentos según su cargo
--    Car_Id 1 (Dirección)        → Dep "Dirección General"
--    Car_Id 2 (Administración)   → Dep "Administración y Finanzas"
--    Car_Id 3 (Docencia)         → Dep "Área Docente"
--    Car_Id 4 (Servicios Gen.)   → Dep "Servicios Generales"
-- ──────────────────────────────────────────────────────────────────────
UPDATE [app].[tbEmpleados]
SET Dep_Id = d.Dep_Id
FROM [app].[tbEmpleados] e
INNER JOIN [app].[tbDepartamentoEmpleados] d ON d.Nombre = 'Dirección General'
WHERE e.Car_Id = 1;

UPDATE [app].[tbEmpleados]
SET Dep_Id = d.Dep_Id
FROM [app].[tbEmpleados] e
INNER JOIN [app].[tbDepartamentoEmpleados] d ON d.Nombre = 'Administración y Finanzas'
WHERE e.Car_Id = 2;

UPDATE [app].[tbEmpleados]
SET Dep_Id = d.Dep_Id
FROM [app].[tbEmpleados] e
INNER JOIN [app].[tbDepartamentoEmpleados] d ON d.Nombre = 'Área Docente'
WHERE e.Car_Id = 3;

UPDATE [app].[tbEmpleados]
SET Dep_Id = d.Dep_Id
FROM [app].[tbEmpleados] e
INNER JOIN [app].[tbDepartamentoEmpleados] d ON d.Nombre = 'Servicios Generales'
WHERE e.Car_Id = 4;
GO

-- ──────────────────────────────────────────────────────────────────────
-- 5. Asignar algunos empleados a los departamentos adicionales
--    (RRHH e Informática) tomando los últimos de cada grupo grande
-- ──────────────────────────────────────────────────────────────────────

-- Mover los 3 últimos de Dirección General → Recursos Humanos
UPDATE [app].[tbEmpleados]
SET Dep_Id = (SELECT Dep_Id FROM [app].[tbDepartamentoEmpleados] WHERE Nombre = 'Recursos Humanos')
WHERE Emp_Id IN (
    SELECT TOP 3 Emp_Id
    FROM [app].[tbEmpleados]
    WHERE Car_Id = 1
    ORDER BY Emp_Id DESC
);

-- Mover los 3 últimos de Administración → Informática y Tecnología
UPDATE [app].[tbEmpleados]
SET Dep_Id = (SELECT Dep_Id FROM [app].[tbDepartamentoEmpleados] WHERE Nombre = 'Informática y Tecnología')
WHERE Emp_Id IN (
    SELECT TOP 3 Emp_Id
    FROM [app].[tbEmpleados]
    WHERE Car_Id = 2
    ORDER BY Emp_Id DESC
);
GO

-- ──────────────────────────────────────────────────────────────────────
-- Verificación final
-- ──────────────────────────────────────────────────────────────────────
SELECT d.Nombre AS Departamento, COUNT(e.Emp_Id) AS Empleados
FROM [app].[tbDepartamentoEmpleados] d
LEFT JOIN [app].[tbEmpleados] e ON d.Dep_Id = e.Dep_Id
GROUP BY d.Dep_Id, d.Nombre
ORDER BY d.Dep_Id;

SELECT c.Car_Descripcion AS Cargo, COUNT(e.Emp_Id) AS Empleados
FROM [app].[tbCargos] c
LEFT JOIN [app].[tbEmpleados] e ON c.Car_Id = e.Car_Id
GROUP BY c.Car_Id, c.Car_Descripcion
ORDER BY c.Car_Id;
