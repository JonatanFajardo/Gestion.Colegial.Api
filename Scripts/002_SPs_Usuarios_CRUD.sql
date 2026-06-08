-- =============================================
-- Script: SPs CRUD para tbUsuarios
-- Base de datos: DB_GestionColegial
-- Esquema: Seguridad
-- =============================================

USE DB_GestionColegial;
GO

-- =============================================
-- 1. SP: Listar usuarios
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbUsuarios_List' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbUsuarios_List;
GO

CREATE PROCEDURE Seguridad.UDP_tbUsuarios_List
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.Usu_Id,
           u.Usu_Name,
           r.Rol_Descripcion,
           u.Rol_Id,
           u.Emp_Id,
           u.Usu_EsActivo
    FROM Seguridad.tbUsuarios u
    INNER JOIN Seguridad.tbRoles r ON u.Rol_Id = r.Rol_Id
    WHERE u.Usu_EsEliminado = 0
    ORDER BY u.Usu_Name;
END
GO

-- =============================================
-- 2. SP: Buscar usuario por ID (para editar)
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbUsuarios_Find' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbUsuarios_Find;
GO

CREATE PROCEDURE Seguridad.UDP_tbUsuarios_Find
    @Usu_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.Usu_Id,
           u.Usu_Name,
           u.Rol_Id,
           u.Emp_Id,
           u.Usu_EsActivo
    FROM Seguridad.tbUsuarios u
    WHERE u.Usu_Id = @Usu_Id
      AND u.Usu_EsEliminado = 0;
END
GO

-- =============================================
-- 3. SP: Detalle de usuario
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbUsuarios_Detail' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbUsuarios_Detail;
GO

CREATE PROCEDURE Seguridad.UDP_tbUsuarios_Detail
    @Usu_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.Usu_Id,
           u.Usu_Name,
           r.Rol_Descripcion,
           u.Usu_EsActivo,
           u.Usu_FechaCreacion,
           u.Usu_fechaModificacion
    FROM Seguridad.tbUsuarios u
    INNER JOIN Seguridad.tbRoles r ON u.Rol_Id = r.Rol_Id
    WHERE u.Usu_Id = @Usu_Id
      AND u.Usu_EsEliminado = 0;
END
GO

-- =============================================
-- 4. SP: Insertar usuario
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbUsuarios_Insert' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbUsuarios_Insert;
GO

CREATE PROCEDURE Seguridad.UDP_tbUsuarios_Insert
    @Usu_Name      NVARCHAR(50),
    @Usu_Contrasena VARCHAR(255),
    @Rol_Id         INT,
    @Emp_Id         INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Seguridad.tbUsuarios (Usu_Name, [Usu_Contraseña], Rol_Id, Emp_Id, Usu_EsActivo, Usu_EsEliminado, Usu_FechaCreacion)
    VALUES (@Usu_Name, @Usu_Contrasena, @Rol_Id, @Emp_Id, 1, 0, GETDATE());
END
GO

-- =============================================
-- 5. SP: Actualizar usuario
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbUsuarios_Update' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbUsuarios_Update;
GO

CREATE PROCEDURE Seguridad.UDP_tbUsuarios_Update
    @Usu_Id         INT,
    @Usu_Name       NVARCHAR(50),
    @Rol_Id         INT,
    @Emp_Id         INT,
    @Usu_EsActivo   BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Seguridad.tbUsuarios
    SET Usu_Name = @Usu_Name,
        Rol_Id = @Rol_Id,
        Emp_Id = @Emp_Id,
        Usu_EsActivo = @Usu_EsActivo,
        Usu_fechaModificacion = GETDATE()
    WHERE Usu_Id = @Usu_Id;
END
GO

-- =============================================
-- 6. SP: Eliminar usuario (soft delete)
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbUsuarios_Delete' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbUsuarios_Delete;
GO

CREATE PROCEDURE Seguridad.UDP_tbUsuarios_Delete
    @Usu_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Seguridad.tbUsuarios
    SET Usu_EsEliminado = 1,
        Usu_EsActivo = 0,
        Usu_fechaModificacion = GETDATE()
    WHERE Usu_Id = @Usu_Id;
END
GO

-- =============================================
-- 7. SP: Verificar existencia (duplicado de username)
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbUsuarios_Exist' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbUsuarios_Exist;
GO

CREATE PROCEDURE Seguridad.UDP_tbUsuarios_Exist
    @Usu_Name NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Usu_Id, Usu_Name
    FROM Seguridad.tbUsuarios
    WHERE Usu_Name = @Usu_Name
      AND Usu_EsEliminado = 0;
END
GO

-- =============================================
-- 8. SP: Dropdown de roles
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'UDP_tbRoles_Dropdown' AND schema_id = SCHEMA_ID('Seguridad'))
    DROP PROCEDURE Seguridad.UDP_tbRoles_Dropdown;
GO

CREATE PROCEDURE Seguridad.UDP_tbRoles_Dropdown
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Rol_Id, Rol_Descripcion
    FROM Seguridad.tbRoles
    WHERE Rol_Estado = 1
      AND Rol_EsEliminado = 0
    ORDER BY Rol_Descripcion;
END
GO

PRINT 'SPs de Usuarios CRUD creados exitosamente.';
GO
