-- =============================================
-- Script: Pantallas funcionales (no-CRUD) e insercion en roles
-- Base de datos: DB_GestionColegial
-- Requisitos: Scripts 001-007 ejecutados antes
-- =============================================

USE DB_GestionColegial;
GO

SET NOCOUNT ON;

-- =============================================
-- 1. Agregar pantallas nuevas (idempotente)
-- =============================================

-- GRUPO: Dashboard
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Dashboard Admin')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Dashboard Admin', 'Dashboard');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Dashboard Director')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Dashboard Director', 'Dashboard');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Dashboard Docente')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Dashboard Docente', 'Dashboard');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Dashboard Secretaria')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Dashboard Secretaria', 'Dashboard');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Dashboard Recursos Humanos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Dashboard Recursos Humanos', 'Dashboard');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Dashboard Caja')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Dashboard Caja', 'Dashboard');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Dashboard Financiero')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Dashboard Financiero', 'Dashboard');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Dashboard Consulta')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Dashboard Consulta', 'Dashboard');
GO

-- GRUPO: General
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Mi perfil')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Mi perfil', 'General');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Notificaciones')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Notificaciones', 'General');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Buscador global')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Buscador global', 'General');
GO

-- GRUPO: Academico
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Asistencia de alumnos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Asistencia de alumnos', 'Academico');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Cuaderno de notas')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Cuaderno de notas', 'Academico');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Boletín de calificaciones')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Boletín de calificaciones', 'Academico');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Horario semanal')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Horario semanal', 'Academico');
GO

-- GRUPO: Alumnos
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Ficha del alumno')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Ficha del alumno', 'Alumnos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Matrícula nueva')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Matrícula nueva', 'Alumnos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Re-matrícula')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Re-matrícula', 'Alumnos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Generador de carnets')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Generador de carnets', 'Alumnos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Generador de constancias')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Generador de constancias', 'Alumnos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Directorio de encargados')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Directorio de encargados', 'Alumnos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Documentos pendientes de entrega')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Documentos pendientes de entrega', 'Alumnos');
GO

-- GRUPO: Recursos Humanos
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Ficha del empleado')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Ficha del empleado', 'Recursos Humanos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Organigrama')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Organigrama', 'Recursos Humanos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Cumpleaños del mes')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Cumpleaños del mes', 'Recursos Humanos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Control de vacaciones y permisos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Control de vacaciones y permisos', 'Recursos Humanos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Asistencia de empleados')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Asistencia de empleados', 'Recursos Humanos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Reporte de antigüedad')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Reporte de antigüedad', 'Recursos Humanos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Constancias laborales')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Constancias laborales', 'Recursos Humanos');
GO

-- GRUPO: Financiero
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Estado de cuenta del alumno')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Estado de cuenta del alumno', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Punto de cobro')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Punto de cobro', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Arqueo de caja')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Arqueo de caja', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Pagos del día')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Pagos del día', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Reporte de morosidad')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Reporte de morosidad', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Top deudores')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Top deudores', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Aging de cuentas por cobrar')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Aging de cuentas por cobrar', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Flujo de caja proyectado')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Flujo de caja proyectado', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Comprobante de pago')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Comprobante de pago', 'Financiero');
GO

-- GRUPO: Reportes
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Indicadores académicos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Indicadores académicos', 'Reportes');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Comparativo de años lectivos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Comparativo de años lectivos', 'Reportes');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Alumnos en riesgo académico')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Alumnos en riesgo académico', 'Reportes');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Rendimiento por sección')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Rendimiento por sección', 'Reportes');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Alumnos en riesgo financiero')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Alumnos en riesgo financiero', 'Reportes');
GO

-- GRUPO: Seguridad
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Bitácora de actividad')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Bitácora de actividad', 'Seguridad');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Sesiones activas')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Sesiones activas', 'Seguridad');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Configuración del sistema')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Configuración del sistema', 'Seguridad');
GO

PRINT 'Pantallas funcionales insertadas.';
GO


-- =============================================
-- 2. Asignar pantallas a roles
-- =============================================

DECLARE @RolId INT;

-- -------------------------------------------------------
-- ROL 1: admin → todas las pantallas nuevas
-- -------------------------------------------------------
INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT 1, p.Pan_Id
FROM Seguridad.tbPantallas p
WHERE p.Pan_EsEliminado = 0
  AND NOT EXISTS (SELECT 1 FROM Seguridad.tbRolesPantallas rp WHERE rp.Rol_Id = 1 AND rp.Pan_Id = p.Pan_Id);
GO

-- -------------------------------------------------------
-- ROL 2: director → todo excepto pantallas de Seguridad y Dashboard Admin
-- -------------------------------------------------------
DECLARE @RolId INT;
SELECT @RolId = Rol_Id FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'director' AND Rol_EsEliminado = 0;
IF @RolId IS NOT NULL
BEGIN
    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, p.Pan_Id
    FROM Seguridad.tbPantallas p
    WHERE p.Pan_EsEliminado = 0
      AND ISNULL(p.Pan_Grupo,'General') NOT IN ('Seguridad')
      AND p.Pan_Descripcion <> 'Dashboard Admin'
      AND NOT EXISTS (SELECT 1 FROM Seguridad.tbRolesPantallas rp WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id);
END
GO

-- -------------------------------------------------------
-- ROL 3: docente → dashboard propio + pantallas académicas
-- -------------------------------------------------------
DECLARE @RolId INT;
SELECT @RolId = Rol_Id FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'docente' AND Rol_EsEliminado = 0;
IF @RolId IS NOT NULL
BEGIN
    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, p.Pan_Id
    FROM Seguridad.tbPantallas p
    WHERE p.Pan_EsEliminado = 0
      AND p.Pan_Descripcion IN (
          'Dashboard Docente',
          'Mi perfil', 'Notificaciones',
          'Asistencia de alumnos', 'Cuaderno de notas', 'Boletín de calificaciones', 'Horario semanal',
          'Ficha del alumno', 'Buscador global'
      )
      AND NOT EXISTS (SELECT 1 FROM Seguridad.tbRolesPantallas rp WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id);
END
GO

-- -------------------------------------------------------
-- ROL 4: secretaria → dashboard + matricula + consultas
-- -------------------------------------------------------
DECLARE @RolId INT;
SELECT @RolId = Rol_Id FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'secretaria' AND Rol_EsEliminado = 0;
IF @RolId IS NOT NULL
BEGIN
    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, p.Pan_Id
    FROM Seguridad.tbPantallas p
    WHERE p.Pan_EsEliminado = 0
      AND p.Pan_Descripcion IN (
          'Dashboard Secretaria',
          'Mi perfil', 'Notificaciones', 'Buscador global',
          'Ficha del alumno', 'Matrícula nueva', 'Re-matrícula',
          'Generador de carnets', 'Generador de constancias',
          'Directorio de encargados', 'Documentos pendientes de entrega',
          'Estado de cuenta del alumno'
      )
      AND NOT EXISTS (SELECT 1 FROM Seguridad.tbRolesPantallas rp WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id);
END
GO

-- -------------------------------------------------------
-- ROL 5: recursos humanos → dashboard + ficha empleado + operativos
-- -------------------------------------------------------
DECLARE @RolId INT;
SELECT @RolId = Rol_Id FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'recursos humanos' AND Rol_EsEliminado = 0;
IF @RolId IS NOT NULL
BEGIN
    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, p.Pan_Id
    FROM Seguridad.tbPantallas p
    WHERE p.Pan_EsEliminado = 0
      AND p.Pan_Descripcion IN (
          'Dashboard Recursos Humanos',
          'Mi perfil', 'Notificaciones',
          'Ficha del empleado', 'Organigrama', 'Cumpleaños del mes',
          'Control de vacaciones y permisos', 'Asistencia de empleados',
          'Reporte de antigüedad', 'Constancias laborales'
      )
      AND NOT EXISTS (SELECT 1 FROM Seguridad.tbRolesPantallas rp WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id);
END
GO

-- -------------------------------------------------------
-- ROL 6: cajero → dashboard + cobros + arqueo
-- -------------------------------------------------------
DECLARE @RolId INT;
SELECT @RolId = Rol_Id FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'cajero' AND Rol_EsEliminado = 0;
IF @RolId IS NOT NULL
BEGIN
    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, p.Pan_Id
    FROM Seguridad.tbPantallas p
    WHERE p.Pan_EsEliminado = 0
      AND p.Pan_Descripcion IN (
          'Dashboard Caja',
          'Mi perfil', 'Notificaciones', 'Buscador global',
          'Estado de cuenta del alumno', 'Punto de cobro',
          'Arqueo de caja', 'Pagos del día', 'Comprobante de pago'
      )
      AND NOT EXISTS (SELECT 1 FROM Seguridad.tbRolesPantallas rp WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id);
END
GO

-- -------------------------------------------------------
-- ROL 7: contador → dashboard financiero + reportes completos
-- -------------------------------------------------------
DECLARE @RolId INT;
SELECT @RolId = Rol_Id FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'contador' AND Rol_EsEliminado = 0;
IF @RolId IS NOT NULL
BEGIN
    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, p.Pan_Id
    FROM Seguridad.tbPantallas p
    WHERE p.Pan_EsEliminado = 0
      AND (
          ISNULL(p.Pan_Grupo, 'General') = 'Financiero' OR
          ISNULL(p.Pan_Grupo, 'General') = 'Reportes'  OR
          p.Pan_Descripcion IN (
              'Dashboard Financiero',
              'Mi perfil', 'Notificaciones',
              'Estado de cuenta del alumno', 'Ficha del alumno', 'Buscador global'
          )
      )
      AND NOT EXISTS (SELECT 1 FROM Seguridad.tbRolesPantallas rp WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id);
END
GO

-- -------------------------------------------------------
-- ROL 8: consulta → dashboard + reportes (solo lectura)
-- -------------------------------------------------------
DECLARE @RolId INT;
SELECT @RolId = Rol_Id FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'consulta' AND Rol_EsEliminado = 0;
IF @RolId IS NOT NULL
BEGIN
    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, p.Pan_Id
    FROM Seguridad.tbPantallas p
    WHERE p.Pan_EsEliminado = 0
      AND (
          ISNULL(p.Pan_Grupo, 'General') = 'Reportes' OR
          p.Pan_Descripcion IN (
              'Dashboard Consulta',
              'Mi perfil', 'Notificaciones'
          )
      )
      AND NOT EXISTS (SELECT 1 FROM Seguridad.tbRolesPantallas rp WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id);
END
GO


-- =============================================
-- 3. Verificacion: pantallas nuevas insertadas
-- =============================================
SELECT Pan_Grupo, COUNT(*) AS Total
FROM Seguridad.tbPantallas
WHERE Pan_EsEliminado = 0
GROUP BY Pan_Grupo
ORDER BY Pan_Grupo;

-- Pantallas por rol (resumen final)
SELECT r.Rol_Descripcion, COUNT(rp.Pan_Id) AS TotalPantallas
FROM Seguridad.tbRoles r
LEFT JOIN Seguridad.tbRolesPantallas rp ON r.Rol_Id = rp.Rol_Id
WHERE r.Rol_EsEliminado = 0
GROUP BY r.Rol_Id, r.Rol_Descripcion
ORDER BY r.Rol_Id;
GO

PRINT 'Script 008 ejecutado exitosamente - pantallas funcionales creadas y asignadas a roles.';
GO
