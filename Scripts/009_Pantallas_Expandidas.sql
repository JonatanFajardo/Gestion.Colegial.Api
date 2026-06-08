-- =============================================
-- Script: Pantallas expandidas por rol (complemento de 008)
-- Base de datos: DB_GestionColegial
-- Requisitos: Scripts 001-008 ejecutados antes
-- =============================================

USE DB_GestionColegial;
GO

SET NOCOUNT ON;

-- =============================================
-- 1. Insertar pantallas nuevas (idempotente)
-- =============================================

-- GRUPO: Seguridad (solo admin)
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Backup & restore')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Backup & restore', 'Seguridad');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Logs de errores')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Logs de errores', 'Seguridad');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Importador / Exportador masivo')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Importador / Exportador masivo', 'Seguridad');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Matriz visual Rol x Pantallas')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Matriz visual Rol x Pantallas', 'Seguridad');
GO

-- GRUPO: General (compartidas)
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Centro de anuncios')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Centro de anuncios', 'General');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Mensajes a encargados')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Mensajes a encargados', 'General');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Configuracion de tema')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Configuracion de tema', 'General');
GO

-- GRUPO: Academico
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Mapa de ocupacion de aulas')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Mapa de ocupacion de aulas', 'Academico');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Plan de clases')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Plan de clases', 'Academico');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Tareas y entregas')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Tareas y entregas', 'Academico');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Mis alumnos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Mis alumnos', 'Academico');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Mapa de aulas')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Mapa de aulas', 'Academico');
GO

-- GRUPO: Recursos Humanos
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Cumplimiento de documentos empleado')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Cumplimiento de documentos empleado', 'Recursos Humanos');
GO

-- GRUPO: Financiero
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Pendientes por cobrar hoy')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Pendientes por cobrar hoy', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Historial de transacciones')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Historial de transacciones', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Conciliacion rapida')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Conciliacion rapida', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Estado de resultados mensual')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Estado de resultados mensual', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Asignador masivo de descuentos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Asignador masivo de descuentos', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Generador de recibos masivos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Generador de recibos masivos', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Analisis ingresos vs egresos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Analisis ingresos vs egresos', 'Financiero');
GO

-- GRUPO: Reportes
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Piramide de matricula')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Piramide de matricula', 'Reportes');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Reportes financieros descargables')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Reportes financieros descargables', 'Reportes');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'KPIs academicos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('KPIs academicos', 'Reportes');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'KPIs financieros')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('KPIs financieros', 'Reportes');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Reportes pre-generados')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Reportes pre-generados', 'Reportes');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Visor de graficos consolidados')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Visor de graficos consolidados', 'Reportes');
GO

PRINT 'Pantallas expandidas insertadas.';
GO


-- =============================================
-- 2. Asignacion a roles
-- =============================================

-- -------------------------------------------------------
-- ROL 1: admin → todas las pantallas nuevas
-- -------------------------------------------------------
INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT 1, p.Pan_Id
FROM Seguridad.tbPantallas p
WHERE p.Pan_EsEliminado = 0
  AND NOT EXISTS (
      SELECT 1 FROM Seguridad.tbRolesPantallas rp
      WHERE rp.Rol_Id = 1 AND rp.Pan_Id = p.Pan_Id
  );
GO

-- -------------------------------------------------------
-- ROL 2: director → reportes, KPIs, anuncios, mapas, financiero
-- -------------------------------------------------------
DECLARE @RolId INT;
SELECT @RolId = Rol_Id FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'director' AND Rol_EsEliminado = 0;
IF @RolId IS NOT NULL
BEGIN
    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, p.Pan_Id
    FROM Seguridad.tbPantallas p
    WHERE p.Pan_EsEliminado = 0
      AND p.Pan_Descripcion IN (
          'Centro de anuncios', 'Configuracion de tema',
          'Mapa de ocupacion de aulas', 'Piramide de matricula',
          'KPIs academicos', 'KPIs financieros',
          'Reportes pre-generados', 'Visor de graficos consolidados',
          'Reportes financieros descargables',
          'Estado de resultados mensual', 'Analisis ingresos vs egresos'
      )
      AND NOT EXISTS (
          SELECT 1 FROM Seguridad.tbRolesPantallas rp
          WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id
      );
END
GO

-- -------------------------------------------------------
-- ROL 3: docente → clases, tareas, alumnos, mensajes
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
          'Plan de clases', 'Tareas y entregas',
          'Mis alumnos', 'Mensajes a encargados',
          'Configuracion de tema'
      )
      AND NOT EXISTS (
          SELECT 1 FROM Seguridad.tbRolesPantallas rp
          WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id
      );
END
GO

-- -------------------------------------------------------
-- ROL 4: secretaria → mapa de aulas, anuncios, mensajes
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
          'Mapa de aulas', 'Centro de anuncios',
          'Mensajes a encargados', 'Configuracion de tema'
      )
      AND NOT EXISTS (
          SELECT 1 FROM Seguridad.tbRolesPantallas rp
          WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id
      );
END
GO

-- -------------------------------------------------------
-- ROL 5: recursos humanos → documentos empleado
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
          'Cumplimiento de documentos empleado',
          'Configuracion de tema'
      )
      AND NOT EXISTS (
          SELECT 1 FROM Seguridad.tbRolesPantallas rp
          WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id
      );
END
GO

-- -------------------------------------------------------
-- ROL 6: cajero → pendientes, historial, conciliacion
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
          'Pendientes por cobrar hoy', 'Historial de transacciones',
          'Conciliacion rapida', 'Configuracion de tema'
      )
      AND NOT EXISTS (
          SELECT 1 FROM Seguridad.tbRolesPantallas rp
          WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id
      );
END
GO

-- -------------------------------------------------------
-- ROL 7: contador → financiero completo + KPIs + reportes
-- -------------------------------------------------------
DECLARE @RolId INT;
SELECT @RolId = Rol_Id FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'contador' AND Rol_EsEliminado = 0;
IF @RolId IS NOT NULL
BEGIN
    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, p.Pan_Id
    FROM Seguridad.tbPantallas p
    WHERE p.Pan_EsEliminado = 0
      AND p.Pan_Descripcion IN (
          'Estado de resultados mensual',
          'Asignador masivo de descuentos',
          'Generador de recibos masivos',
          'Reportes financieros descargables',
          'Analisis ingresos vs egresos',
          'KPIs financieros', 'Visor de graficos consolidados',
          'Configuracion de tema'
      )
      AND NOT EXISTS (
          SELECT 1 FROM Seguridad.tbRolesPantallas rp
          WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id
      );
END
GO

-- -------------------------------------------------------
-- ROL 8: consulta → KPIs y reportes (solo lectura)
-- -------------------------------------------------------
DECLARE @RolId INT;
SELECT @RolId = Rol_Id FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'consulta' AND Rol_EsEliminado = 0;
IF @RolId IS NOT NULL
BEGIN
    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, p.Pan_Id
    FROM Seguridad.tbPantallas p
    WHERE p.Pan_EsEliminado = 0
      AND p.Pan_Descripcion IN (
          'KPIs academicos', 'KPIs financieros',
          'Reportes pre-generados', 'Visor de graficos consolidados',
          'Configuracion de tema'
      )
      AND NOT EXISTS (
          SELECT 1 FROM Seguridad.tbRolesPantallas rp
          WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = p.Pan_Id
      );
END
GO


-- =============================================
-- 3. Verificacion final
-- =============================================
SELECT Pan_Grupo, COUNT(*) AS Total
FROM Seguridad.tbPantallas
WHERE Pan_EsEliminado = 0
GROUP BY Pan_Grupo
ORDER BY Pan_Grupo;

SELECT r.Rol_Descripcion, COUNT(rp.Pan_Id) AS TotalPantallas
FROM Seguridad.tbRoles r
LEFT JOIN Seguridad.tbRolesPantallas rp ON r.Rol_Id = rp.Rol_Id
WHERE r.Rol_EsEliminado = 0
GROUP BY r.Rol_Id, r.Rol_Descripcion
ORDER BY r.Rol_Id;
GO

PRINT 'Script 009 ejecutado exitosamente - pantallas expandidas creadas y asignadas.';
GO
