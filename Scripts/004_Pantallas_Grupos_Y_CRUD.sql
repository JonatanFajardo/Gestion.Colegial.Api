-- =============================================
-- Script: Agregar agrupacion a pantallas + pantallas CRUD
-- Base de datos: DB_GestionColegial
-- Esquema: Seguridad
-- =============================================

USE DB_GestionColegial;
GO

-- =============================================
-- 1. Agregar columna Pan_Grupo a tbPantallas
-- =============================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Seguridad.tbPantallas') AND name = 'Pan_Grupo')
BEGIN
    ALTER TABLE Seguridad.tbPantallas ADD Pan_Grupo NVARCHAR(50) NULL;
END
GO

-- =============================================
-- 2. Asignar grupos a pantallas existentes
-- =============================================
UPDATE Seguridad.tbPantallas SET Pan_Grupo = 'General'          WHERE Pan_Descripcion = 'Home';
UPDATE Seguridad.tbPantallas SET Pan_Grupo = 'Cursos'           WHERE Pan_Descripcion IN ('Listado de cursos', 'Listado de cursos niveles', 'Listado de duraciones', 'Listado de materias');
UPDATE Seguridad.tbPantallas SET Pan_Grupo = 'Alumnos'          WHERE Pan_Descripcion IN ('Listado de alumnos', 'Listado de encargados', 'Listado de parentescos');
UPDATE Seguridad.tbPantallas SET Pan_Grupo = 'Recursos Humanos' WHERE Pan_Descripcion IN ('Listado de empleados', 'Listado de cargos');
UPDATE Seguridad.tbPantallas SET Pan_Grupo = 'Horarios'         WHERE Pan_Descripcion IN ('Listado de horarios', 'Listado de horas', 'Listado de dias', 'Listado de aulas');
UPDATE Seguridad.tbPantallas SET Pan_Grupo = 'Institucion'      WHERE Pan_Descripcion IN ('Listado de modalidades', 'Listado de niveles educativos', 'Listado de parciales', 'Listado de secciones', 'Listado de semestres', 'Listado de titulos', 'Listado de estados');
UPDATE Seguridad.tbPantallas SET Pan_Grupo = 'Financiero'       WHERE Pan_Descripcion IN ('Listado de pagos', 'Listado de cuentas por cobrar', 'Listado de conceptos de pago', 'Listado de formas de pago', 'Listado de descuentos', 'Listado de estados de pago', 'Listado de tarifas', 'Reportes financieros', 'Guia financiera');
UPDATE Seguridad.tbPantallas SET Pan_Grupo = 'Seguridad'        WHERE Pan_Descripcion IN ('Listado de usuarios', 'Listado de roles');
UPDATE Seguridad.tbPantallas SET Pan_Grupo = 'Academico'        WHERE Pan_Descripcion IN ('Listado de notas', 'Listado de personas');

-- Cualquier pantalla sin grupo asignar a General
UPDATE Seguridad.tbPantallas SET Pan_Grupo = 'General' WHERE Pan_Grupo IS NULL AND Pan_EsEliminado = 0;
GO

-- =============================================
-- 3. Insertar pantallas CRUD para los modulos principales
--    Solo si no existen ya
-- =============================================

-- Macro para insertar pantalla si no existe
-- Cursos
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear cursos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear cursos', 'Cursos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar cursos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar cursos', 'Cursos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar cursos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar cursos', 'Cursos');

-- Cursos Niveles
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear cursos niveles')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear cursos niveles', 'Cursos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar cursos niveles')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar cursos niveles', 'Cursos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar cursos niveles')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar cursos niveles', 'Cursos');

-- Materias
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear materias')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear materias', 'Cursos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar materias')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar materias', 'Cursos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar materias')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar materias', 'Cursos');

-- Duraciones
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear duraciones')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear duraciones', 'Cursos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar duraciones')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar duraciones', 'Cursos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar duraciones')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar duraciones', 'Cursos');

-- Alumnos
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear alumnos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear alumnos', 'Alumnos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar alumnos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar alumnos', 'Alumnos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar alumnos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar alumnos', 'Alumnos');

-- Encargados
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear encargados')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear encargados', 'Alumnos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar encargados')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar encargados', 'Alumnos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar encargados')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar encargados', 'Alumnos');

-- Parentescos
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear parentescos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear parentescos', 'Alumnos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar parentescos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar parentescos', 'Alumnos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar parentescos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar parentescos', 'Alumnos');

-- Empleados
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear empleados')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear empleados', 'Recursos Humanos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar empleados')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar empleados', 'Recursos Humanos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar empleados')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar empleados', 'Recursos Humanos');

-- Cargos
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear cargos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear cargos', 'Recursos Humanos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar cargos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar cargos', 'Recursos Humanos');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar cargos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar cargos', 'Recursos Humanos');

-- Horarios
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear horarios')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear horarios', 'Horarios');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar horarios')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar horarios', 'Horarios');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar horarios')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar horarios', 'Horarios');

-- Modalidades
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear modalidades')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear modalidades', 'Institucion');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar modalidades')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar modalidades', 'Institucion');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar modalidades')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar modalidades', 'Institucion');

-- Niveles Educativos
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear niveles educativos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear niveles educativos', 'Institucion');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar niveles educativos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar niveles educativos', 'Institucion');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar niveles educativos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar niveles educativos', 'Institucion');

-- Secciones
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear secciones')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear secciones', 'Institucion');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar secciones')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar secciones', 'Institucion');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar secciones')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar secciones', 'Institucion');

-- Semestres
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear semestres')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear semestres', 'Institucion');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar semestres')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar semestres', 'Institucion');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar semestres')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar semestres', 'Institucion');

-- Pagos
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear pagos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear pagos', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar pagos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar pagos', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar pagos')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar pagos', 'Financiero');

-- Cuentas por Cobrar
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear cuentas por cobrar')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear cuentas por cobrar', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar cuentas por cobrar')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar cuentas por cobrar', 'Financiero');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar cuentas por cobrar')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar cuentas por cobrar', 'Financiero');

-- Usuarios
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear usuarios')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear usuarios', 'Seguridad');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar usuarios')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar usuarios', 'Seguridad');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar usuarios')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar usuarios', 'Seguridad');

-- Roles
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Crear roles')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Crear roles', 'Seguridad');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Editar roles')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Editar roles', 'Seguridad');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Eliminar roles')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Eliminar roles', 'Seguridad');
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Asignar pantallas')
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion, Pan_Grupo) VALUES ('Asignar pantallas', 'Seguridad');
GO

-- =============================================
-- 4. Asignar TODAS las nuevas pantallas al Admin (Rol_Id = 1)
-- =============================================
INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT 1, p.Pan_Id
FROM Seguridad.tbPantallas p
WHERE p.Pan_EsEliminado = 0
  AND NOT EXISTS (
    SELECT 1 FROM Seguridad.tbRolesPantallas rp
    WHERE rp.Rol_Id = 1 AND rp.Pan_Id = p.Pan_Id
  );
GO

-- =============================================
-- 5. Modificar SP UDP_tbPantallas_List para incluir Pan_Grupo
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbPantallas_List' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbPantallas_List;
GO

CREATE PROCEDURE Seguridad.UDP_tbPantallas_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Pan_Id, Pan_Descripcion, ISNULL(Pan_Grupo, 'General') AS Pan_Grupo
    FROM Seguridad.tbPantallas
    WHERE Pan_Estado = 1 AND Pan_EsEliminado = 0
    ORDER BY Pan_Grupo, Pan_Descripcion;
END
GO

PRINT 'Script 004 ejecutado exitosamente - Pantallas agrupadas y CRUD creadas.';
GO
