-- =============================================
-- Script: Roles iniciales del sistema + asignacion de pantallas
-- Base de datos: DB_GestionColegial
-- Esquema: Seguridad
-- Requisitos: Ejecutar antes los scripts 001, 003 y 004
-- Idempotente: solo inserta el rol si no existe
-- =============================================

USE DB_GestionColegial;
GO

SET NOCOUNT ON;

DECLARE @RolId INT;

-- =============================================
-- 2. Director
--    Acceso total excepto al grupo Seguridad
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'director')
BEGIN
    INSERT INTO Seguridad.tbRoles (Rol_Descripcion, Rol_Estado, Rol_EsEliminado, Rol_UsuarioRegistra, Rol_FechaRegistra)
    VALUES ('director', 1, 0, 1, GETDATE());
    SET @RolId = SCOPE_IDENTITY();

    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, Pan_Id
    FROM Seguridad.tbPantallas
    WHERE Pan_EsEliminado = 0
      AND ISNULL(Pan_Grupo, 'General') <> 'Seguridad';
END
GO

-- =============================================
-- 3. Docente
--    Solo lectura academica + notas
-- =============================================
DECLARE @RolId INT;
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'docente')
BEGIN
    INSERT INTO Seguridad.tbRoles (Rol_Descripcion, Rol_Estado, Rol_EsEliminado, Rol_UsuarioRegistra, Rol_FechaRegistra)
    VALUES ('docente', 1, 0, 1, GETDATE());
    SET @RolId = SCOPE_IDENTITY();

    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, Pan_Id
    FROM Seguridad.tbPantallas
    WHERE Pan_EsEliminado = 0
      AND Pan_Descripcion IN (
          'Home',
          'Listado de cursos',
          'Listado de materias',
          'Listado de alumnos',
          'Listado de horarios',
          'Listado de horas',
          'Listado de dias',
          'Listado de aulas',
          'Listado de secciones',
          'Listado de parciales',
          'Listado de notas'
      );
END
GO

-- =============================================
-- 4. Secretaria
--    Matricula de alumnos/encargados + consultas academicas
-- =============================================
DECLARE @RolId INT;
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'secretaria')
BEGIN
    INSERT INTO Seguridad.tbRoles (Rol_Descripcion, Rol_Estado, Rol_EsEliminado, Rol_UsuarioRegistra, Rol_FechaRegistra)
    VALUES ('secretaria', 1, 0, 1, GETDATE());
    SET @RolId = SCOPE_IDENTITY();

    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, Pan_Id
    FROM Seguridad.tbPantallas
    WHERE Pan_EsEliminado = 0
      AND Pan_Descripcion IN (
          'Home',
          -- Alumnos (CRUD)
          'Listado de alumnos', 'Crear alumnos', 'Editar alumnos', 'Eliminar alumnos',
          'Listado de encargados', 'Crear encargados', 'Editar encargados', 'Eliminar encargados',
          'Listado de parentescos', 'Crear parentescos', 'Editar parentescos',
          'Listado de personas',
          -- Consultas academicas
          'Listado de cursos', 'Listado de cursos niveles', 'Listado de materias', 'Listado de duraciones',
          'Listado de secciones', 'Listado de semestres', 'Listado de modalidades', 'Listado de niveles educativos',
          'Listado de horarios', 'Listado de horas', 'Listado de dias', 'Listado de aulas',
          'Listado de titulos', 'Listado de estados'
      );
END
GO

-- =============================================
-- 5. Recursos Humanos
--    CRUD de empleados y cargos
-- =============================================
DECLARE @RolId INT;
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'recursos humanos')
BEGIN
    INSERT INTO Seguridad.tbRoles (Rol_Descripcion, Rol_Estado, Rol_EsEliminado, Rol_UsuarioRegistra, Rol_FechaRegistra)
    VALUES ('recursos humanos', 1, 0, 1, GETDATE());
    SET @RolId = SCOPE_IDENTITY();

    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, Pan_Id
    FROM Seguridad.tbPantallas
    WHERE Pan_EsEliminado = 0
      AND Pan_Descripcion IN (
          'Home',
          'Listado de empleados', 'Crear empleados', 'Editar empleados', 'Eliminar empleados',
          'Listado de cargos',    'Crear cargos',    'Editar cargos',    'Eliminar cargos',
          'Listado de personas'
      );
END
GO

-- =============================================
-- 6. Cajero
--    Cobros del dia (sin eliminar pagos, sin descuentos/tarifas)
-- =============================================
DECLARE @RolId INT;
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'cajero')
BEGIN
    INSERT INTO Seguridad.tbRoles (Rol_Descripcion, Rol_Estado, Rol_EsEliminado, Rol_UsuarioRegistra, Rol_FechaRegistra)
    VALUES ('cajero', 1, 0, 1, GETDATE());
    SET @RolId = SCOPE_IDENTITY();

    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, Pan_Id
    FROM Seguridad.tbPantallas
    WHERE Pan_EsEliminado = 0
      AND Pan_Descripcion IN (
          'Home',
          'Listado de pagos', 'Crear pagos', 'Editar pagos',
          'Listado de cuentas por cobrar',
          'Listado de conceptos de pago',
          'Listado de formas de pago',
          'Listado de estados de pago',
          'Listado de alumnos',
          'Listado de personas'
      );
END
GO

-- =============================================
-- 7. Contador
--    Modulo Financiero completo + lectura de alumnos
-- =============================================
DECLARE @RolId INT;
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'contador')
BEGIN
    INSERT INTO Seguridad.tbRoles (Rol_Descripcion, Rol_Estado, Rol_EsEliminado, Rol_UsuarioRegistra, Rol_FechaRegistra)
    VALUES ('contador', 1, 0, 1, GETDATE());
    SET @RolId = SCOPE_IDENTITY();

    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, Pan_Id
    FROM Seguridad.tbPantallas
    WHERE Pan_EsEliminado = 0
      AND (
          ISNULL(Pan_Grupo, 'General') = 'Financiero'
          OR Pan_Descripcion IN ('Home', 'Listado de alumnos', 'Listado de personas')
      );
END
GO

-- =============================================
-- 8. Consulta (solo lectura, auditoria/junta directiva)
--    Todos los listados excepto los del grupo Seguridad
-- =============================================
DECLARE @RolId INT;
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbRoles WHERE Rol_Descripcion = 'consulta')
BEGIN
    INSERT INTO Seguridad.tbRoles (Rol_Descripcion, Rol_Estado, Rol_EsEliminado, Rol_UsuarioRegistra, Rol_FechaRegistra)
    VALUES ('consulta', 1, 0, 1, GETDATE());
    SET @RolId = SCOPE_IDENTITY();

    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT @RolId, Pan_Id
    FROM Seguridad.tbPantallas
    WHERE Pan_EsEliminado = 0
      AND ISNULL(Pan_Grupo, 'General') <> 'Seguridad'
      AND (
          Pan_Descripcion LIKE 'Listado de%'
          OR Pan_Descripcion IN ('Home', 'Reportes financieros', 'Guia financiera')
      );
END
GO

PRINT 'Script 005 ejecutado: roles iniciales creados y pantallas asignadas.';
GO

-- =============================================
-- Verificacion final (opcional)
-- =============================================
SELECT r.Rol_Id, r.Rol_Descripcion, COUNT(rp.Pan_Id) AS Cantidad_Pantallas
FROM Seguridad.tbRoles r
LEFT JOIN Seguridad.tbRolesPantallas rp ON r.Rol_Id = rp.Rol_Id
WHERE r.Rol_EsEliminado = 0
GROUP BY r.Rol_Id, r.Rol_Descripcion
ORDER BY r.Rol_Id;
GO
