USE [DB_GestionColegial]
GO

DECLARE @PanId INT;

-- Plan de Clases
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Plan de clases')
BEGIN
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion) VALUES ('Plan de clases');
    SET @PanId = SCOPE_IDENTITY();

    DECLARE @RolId INT;
    SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'director';
    IF @RolId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
        INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
END
GO
DECLARE @PanId INT, @RolId INT;
SELECT @PanId = Pan_Id FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Plan de clases';
SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'docente';
IF @RolId IS NOT NULL AND @PanId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
    INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
GO

-- Tareas y entregas
DECLARE @PanId INT;
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Tareas y entregas')
BEGIN
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion) VALUES ('Tareas y entregas');
    SET @PanId = SCOPE_IDENTITY();
    DECLARE @RolId INT;
    SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'docente';
    IF @RolId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
        INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
END
GO
DECLARE @PanId INT, @RolId INT;
SELECT @PanId = Pan_Id FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Tareas y entregas';
SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'director';
IF @RolId IS NOT NULL AND @PanId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
    INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
GO

-- Mis alumnos
DECLARE @PanId INT;
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Mis alumnos')
BEGIN
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion) VALUES ('Mis alumnos');
    SET @PanId = SCOPE_IDENTITY();
    DECLARE @RolId INT;
    SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'docente';
    IF @RolId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
        INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
END
GO
DECLARE @PanId INT, @RolId INT;
SELECT @PanId = Pan_Id FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Mis alumnos';
SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'director';
IF @RolId IS NOT NULL AND @PanId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
    INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
GO

-- Mapa de aulas
DECLARE @PanId INT;
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Mapa de aulas')
BEGIN
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion) VALUES ('Mapa de aulas');
    SET @PanId = SCOPE_IDENTITY();
    DECLARE @RolId INT;
    SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'director';
    IF @RolId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
        INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
END
GO
DECLARE @PanId INT, @RolId INT;
SELECT @PanId = Pan_Id FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Mapa de aulas';
SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'secretaria';
IF @RolId IS NOT NULL AND @PanId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
    INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
GO
