-- Script 028: Alinear Pan_Descripcion con los atributos [SessionManager] de los controllers ADM
-- Problema: Los nombres en tbPantallas no coinciden con los usados en [SessionManager("X")]
-- Impacto: Sin esta corrección, los controllers redirigen a "Sin Acceso" aunque el usuario tenga el rol

-- 1. Dashboard Administrador
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Dashboard Administrador'
WHERE Pan_Descripcion = 'Dashboard Admin'
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Dashboard Administrador');
GO

-- 2. Dashboard Secretaría (con tilde en la i)
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Dashboard Secretaría'
WHERE Pan_Descripcion = 'Dashboard Secretaria'
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Dashboard Secretaría');
GO

-- 3. Dashboard Consultas (con s)
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Dashboard Consultas'
WHERE Pan_Descripcion = 'Dashboard Consulta'
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Dashboard Consultas');
GO

-- 4. Pase de lista
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Pase de lista'
WHERE Pan_Descripcion = 'Asistencia de alumnos'
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Pase de lista');
GO

-- 5. Estado de cuenta alumno
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Estado de cuenta alumno'
WHERE Pan_Descripcion = 'Estado de cuenta del alumno'
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Estado de cuenta alumno');
GO

-- 6. Control de vacaciones
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Control de vacaciones'
WHERE Pan_Descripcion = 'Control de vacaciones y permisos'
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Control de vacaciones');
GO

-- 7. Documentos alumno
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Documentos alumno'
WHERE Pan_Descripcion = 'Documentos pendientes de entrega'
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Documentos alumno');
GO

-- 8. Top Alumnos con Deuda
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Top Alumnos con Deuda'
WHERE Pan_Descripcion = 'Top deudores'
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Top Alumnos con Deuda');
GO

-- 9. Morosidad por Nivel
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Morosidad por Nivel'
WHERE Pan_Descripcion = 'Reporte de morosidad'
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Morosidad por Nivel');
GO

-- 10. Ficha 360 alumno
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Ficha 360 alumno'
WHERE Pan_Descripcion = 'Ficha del alumno'
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Ficha 360 alumno');
GO

-- 11. Ficha 360 empleado
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Ficha 360 empleado'
WHERE Pan_Descripcion = 'Ficha del empleado'
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Ficha 360 empleado');
GO

-- 12. Busqueda de Alumnos (puede no existir)
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Búsqueda de Alumnos')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
    VALUES ('Búsqueda de Alumnos', 1, 0, 'Reportes');
GO

-- Asignar Busqueda de Alumnos al rol admin (Rol_Id = 1)
INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id)
SELECT 1, Pan_Id FROM [Seguridad].[tbPantallas]
WHERE Pan_Descripcion = 'Búsqueda de Alumnos'
  AND NOT EXISTS (
      SELECT 1 FROM [Seguridad].[tbRolesPantallas] rp
      WHERE rp.Rol_Id = 1 AND rp.Pan_Id = [Seguridad].[tbPantallas].Pan_Id
  );
GO

PRINT 'Script 028 completado: nombres de pantallas alineados con SessionManager.';
GO
