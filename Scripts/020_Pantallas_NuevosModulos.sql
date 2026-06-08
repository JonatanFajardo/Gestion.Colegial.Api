-- Script 020: Pantallas nuevos módulos

IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Buscador Global')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Buscador Global', 1, 0, 'General');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Notificaciones')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Notificaciones', 1, 0, 'General');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Mi Perfil')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Mi Perfil', 1, 0, 'General');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Cuaderno de Notas')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Cuaderno de Notas', 1, 0, 'Academico');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Boletin de Calificaciones')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Boletin de Calificaciones', 1, 0, 'Academico');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Directorio de Alumnos')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Directorio de Alumnos', 1, 0, 'Alumnos');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Piramide de Matricula')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Piramide de Matricula', 1, 0, 'Alumnos');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Cumpleanos Empleados')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Cumpleanos Empleados', 1, 0, 'Recursos Humanos');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Asistencia Empleados')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Asistencia Empleados', 1, 0, 'Recursos Humanos');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Pagos del Dia')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Pagos del Dia', 1, 0, 'Financiero');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Pendientes por Cobrar')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Pendientes por Cobrar', 1, 0, 'Financiero');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Historial de Transacciones')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Historial de Transacciones', 1, 0, 'Financiero');
GO

DECLARE @RolId INT;
SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'administrador';
IF @RolId IS NOT NULL
BEGIN
    INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id)
    SELECT @RolId, Pan_Id FROM [Seguridad].[tbPantallas]
    WHERE Pan_Descripcion IN (
        'Buscador Global','Notificaciones','Mi Perfil',
        'Cuaderno de Notas','Boletin de Calificaciones',
        'Directorio de Alumnos','Piramide de Matricula',
        'Cumpleanos Empleados','Asistencia Empleados',
        'Pagos del Dia','Pendientes por Cobrar','Historial de Transacciones'
    )
    AND NOT EXISTS (
        SELECT 1 FROM [Seguridad].[tbRolesPantallas] rp
        WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = [Seguridad].[tbPantallas].Pan_Id
    );
END
GO
