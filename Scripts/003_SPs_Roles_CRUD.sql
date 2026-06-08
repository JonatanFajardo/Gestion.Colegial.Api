-- =============================================
-- Script: SPs CRUD para tbRoles + asignacion de pantallas
-- Base de datos: DB_GestionColegial
-- Esquema: Seguridad
-- =============================================

USE DB_GestionColegial;
GO

-- =============================================
-- 1. Listar roles
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbRoles_List' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbRoles_List;
GO

CREATE PROCEDURE Seguridad.UDP_tbRoles_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.Rol_Id,
           r.Rol_Descripcion,
           r.Rol_Estado,
           (SELECT COUNT(*) FROM Seguridad.tbRolesPantallas rp WHERE rp.Rol_Id = r.Rol_Id) AS CantidadPantallas
    FROM Seguridad.tbRoles r
    WHERE r.Rol_EsEliminado = 0
    ORDER BY r.Rol_Descripcion;
END
GO

-- =============================================
-- 2. Buscar rol por ID
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbRoles_Find' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbRoles_Find;
GO

CREATE PROCEDURE Seguridad.UDP_tbRoles_Find
    @Rol_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Rol_Id, Rol_Descripcion, Rol_Estado
    FROM Seguridad.tbRoles
    WHERE Rol_Id = @Rol_Id AND Rol_EsEliminado = 0;
END
GO

-- =============================================
-- 3. Detalle de rol
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbRoles_Detail' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbRoles_Detail;
GO

CREATE PROCEDURE Seguridad.UDP_tbRoles_Detail
    @Rol_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.Rol_Id,
           r.Rol_Descripcion,
           r.Rol_Estado,
           r.Rol_FechaRegistra,
           r.Rol_FechaModifica,
           (SELECT COUNT(*) FROM Seguridad.tbRolesPantallas rp WHERE rp.Rol_Id = r.Rol_Id) AS CantidadPantallas
    FROM Seguridad.tbRoles r
    WHERE r.Rol_Id = @Rol_Id AND r.Rol_EsEliminado = 0;
END
GO

-- =============================================
-- 4. Insertar rol (retorna el nuevo Rol_Id)
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbRoles_Insert' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbRoles_Insert;
GO

CREATE PROCEDURE Seguridad.UDP_tbRoles_Insert
    @Rol_Descripcion NVARCHAR(50),
    @Rol_UsuarioRegistra INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Seguridad.tbRoles (Rol_Descripcion, Rol_Estado, Rol_EsEliminado, Rol_UsuarioRegistra, Rol_FechaRegistra)
    VALUES (@Rol_Descripcion, 1, 0, @Rol_UsuarioRegistra, GETDATE());

    SELECT SCOPE_IDENTITY() AS Rol_Id;
END
GO

-- =============================================
-- 5. Actualizar rol
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbRoles_Update' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbRoles_Update;
GO

CREATE PROCEDURE Seguridad.UDP_tbRoles_Update
    @Rol_Id INT,
    @Rol_Descripcion NVARCHAR(50),
    @Rol_Estado BIT,
    @Rol_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Seguridad.tbRoles
    SET Rol_Descripcion = @Rol_Descripcion,
        Rol_Estado = @Rol_Estado,
        Rol_UsuarioModifica = @Rol_UsuarioModifica,
        Rol_FechaModifica = GETDATE()
    WHERE Rol_Id = @Rol_Id;
END
GO

-- =============================================
-- 6. Eliminar rol (soft delete)
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbRoles_Delete' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbRoles_Delete;
GO

CREATE PROCEDURE Seguridad.UDP_tbRoles_Delete
    @Rol_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Seguridad.tbRoles
    SET Rol_EsEliminado = 1,
        Rol_Estado = 0,
        Rol_FechaModifica = GETDATE()
    WHERE Rol_Id = @Rol_Id;

    -- Tambien eliminar asignaciones de pantallas
    DELETE FROM Seguridad.tbRolesPantallas WHERE Rol_Id = @Rol_Id;
END
GO

-- =============================================
-- 7. Verificar existencia de rol
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbRoles_Exist' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbRoles_Exist;
GO

CREATE PROCEDURE Seguridad.UDP_tbRoles_Exist
    @Rol_Descripcion NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Rol_Id, Rol_Descripcion
    FROM Seguridad.tbRoles
    WHERE Rol_Descripcion = @Rol_Descripcion AND Rol_EsEliminado = 0;
END
GO

-- =============================================
-- 8. Listar TODAS las pantallas (para checkboxes)
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbPantallas_List' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbPantallas_List;
GO

CREATE PROCEDURE Seguridad.UDP_tbPantallas_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Pan_Id, Pan_Descripcion
    FROM Seguridad.tbPantallas
    WHERE Pan_Estado = 1 AND Pan_EsEliminado = 0
    ORDER BY Pan_Descripcion;
END
GO

-- =============================================
-- 9. Obtener IDs de pantallas asignadas a un rol
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbRolesPantallas_IdsByRol' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbRolesPantallas_IdsByRol;
GO

CREATE PROCEDURE Seguridad.UDP_tbRolesPantallas_IdsByRol
    @Rol_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Pan_Id
    FROM Seguridad.tbRolesPantallas
    WHERE Rol_Id = @Rol_Id;
END
GO

-- =============================================
-- 10. Eliminar TODAS las pantallas de un rol
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbRolesPantallas_DeleteByRol' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbRolesPantallas_DeleteByRol;
GO

CREATE PROCEDURE Seguridad.UDP_tbRolesPantallas_DeleteByRol
    @Rol_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Seguridad.tbRolesPantallas WHERE Rol_Id = @Rol_Id;
END
GO

-- =============================================
-- 11. Insertar UNA pantalla a un rol
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbRolesPantallas_InsertSingle' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbRolesPantallas_InsertSingle;
GO

CREATE PROCEDURE Seguridad.UDP_tbRolesPantallas_InsertSingle
    @Rol_Id INT,
    @Pan_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Seguridad.tbRolesPantallas WHERE Rol_Id = @Rol_Id AND Pan_Id = @Pan_Id)
    BEGIN
        INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id) VALUES (@Rol_Id, @Pan_Id);
    END
END
GO

-- =============================================
-- 12. Agregar pantalla "Listado de roles" si no existe
-- =============================================
IF NOT EXISTS (SELECT 1 FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Listado de roles')
BEGIN
    INSERT INTO Seguridad.tbPantallas (Pan_Descripcion) VALUES ('Listado de roles');

    -- Asignar al admin
    INSERT INTO Seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
    SELECT 1, Pan_Id FROM Seguridad.tbPantallas WHERE Pan_Descripcion = 'Listado de roles';
END
GO

PRINT 'SPs de Roles CRUD creados exitosamente.';
GO
