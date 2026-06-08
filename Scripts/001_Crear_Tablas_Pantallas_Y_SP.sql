-- =============================================
-- Script: Crear tablas de pantallas/permisos y SP
-- Base de datos: DB_GestionColegial
-- Esquema: Seguridad
-- =============================================

USE DB_GestionColegial;
GO

-- =============================================
-- 1. Tabla de Pantallas (catalogos de pantallas del sistema)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbPantallas' AND schema_id = SCHEMA_ID('Seguridad'))
BEGIN
    CREATE TABLE Seguridad.tbPantallas (
        Pan_Id          INT IDENTITY(1,1) PRIMARY KEY,
        Pan_Descripcion NVARCHAR(100) NOT NULL,
        Pan_Estado      BIT NOT NULL DEFAULT 1,
        Pan_EsEliminado BIT NOT NULL DEFAULT 0,
        Pan_UsuarioRegistra   INT NULL,
        Pan_FechaRegistra     DATETIME NOT NULL DEFAULT GETDATE(),
        Pan_UsuarioModifica   INT NULL,
        Pan_FechaModifica     DATETIME NULL
    );
END
GO

-- =============================================
-- 2. Tabla puente Roles-Pantallas
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbRolesPantallas' AND schema_id = SCHEMA_ID('Seguridad'))
BEGIN
    CREATE TABLE Seguridad.tbRolesPantallas (
        RolPan_Id   INT IDENTITY(1,1) PRIMARY KEY,
        Rol_Id      INT NOT NULL,
        Pan_Id      INT NOT NULL,
        CONSTRAINT FK_RolesPantallas_Roles     FOREIGN KEY (Rol_Id) REFERENCES Seguridad.tbRoles(Rol_Id),
        CONSTRAINT FK_RolesPantallas_Pantallas FOREIGN KEY (Pan_Id) REFERENCES Seguridad.tbPantallas(Pan_Id),
        CONSTRAINT UQ_RolesPantallas UNIQUE (Rol_Id, Pan_Id)
    );
END
GO

-- =============================================
-- 3. SP: Obtener pantallas por Rol_Id
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbRolesPantallas_ByRolId' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbRolesPantallas_ByRolId;
GO

CREATE PROCEDURE Seguridad.UDP_tbRolesPantallas_ByRolId
    @Rol_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT p.Pan_Descripcion
    FROM Seguridad.tbRolesPantallas rp
    INNER JOIN Seguridad.tbPantallas p ON rp.Pan_Id = p.Pan_Id
    WHERE rp.Rol_Id = @Rol_Id
      AND p.Pan_Estado = 1
      AND p.Pan_EsEliminado = 0
    ORDER BY p.Pan_Descripcion;
END
GO

-- =============================================
-- 4. Datos iniciales: Insertar todas las pantallas del sistema
-- =============================================
INSERT INTO Seguridad.tbPantallas (Pan_Descripcion) VALUES
('Home'),
('Listado de cursos'),
('Listado de cursos niveles'),
('Listado de duraciones'),
('Listado de materias'),
('Listado de alumnos'),
('Listado de encargados'),
('Listado de parentescos'),
('Listado de empleados'),
('Listado de cargos'),
('Listado de horarios'),
('Listado de horas'),
('Listado de dias'),
('Listado de aulas'),
('Listado de modalidades'),
('Listado de niveles educativos'),
('Listado de parciales'),
('Listado de secciones'),
('Listado de semestres'),
('Listado de titulos'),
('Listado de estados'),
('Listado de pagos'),
('Listado de cuentas por cobrar'),
('Listado de conceptos de pago'),
('Listado de formas de pago'),
('Listado de descuentos'),
('Listado de estados de pago'),
('Listado de tarifas'),
('Reportes financieros'),
('Guia financiera'),
('Listado de usuarios'),
('Listado de notas'),
('Listado de personas');
GO

-- =============================================
-- 5. Asignar TODAS las pantallas al rol con Rol_Id = 1 (Admin)
--    Ajustar el Rol_Id si el rol administrador tiene otro ID
-- =============================================
INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT 1, Pan_Id
FROM Seguridad.tbPantallas
WHERE Pan_EsEliminado = 0;
GO

PRINT 'Script ejecutado exitosamente.';
GO
