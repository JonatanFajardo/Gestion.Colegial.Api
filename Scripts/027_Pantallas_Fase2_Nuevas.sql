-- Script 027: Registrar pantallas faltantes y corregir nombres con acentos

-- =============================================
-- CORRECCIONES DE NOMBRES (acentos faltantes en script 020)
-- =============================================
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Pirámide de Matrícula'
WHERE Pan_Descripcion = 'Piramide de Matricula';
GO
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Cumpleaños Empleados'
WHERE Pan_Descripcion = 'Cumpleanos Empleados';
GO
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Pagos del Día'
WHERE Pan_Descripcion = 'Pagos del Dia';
GO
UPDATE [Seguridad].[tbPantallas] SET Pan_Descripcion = 'Boletín de calificaciones'
WHERE Pan_Descripcion = 'Boletin de Calificaciones';
GO

-- =============================================
-- NUEVAS PANTALLAS
-- =============================================
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Análisis Ingresos vs Egresos')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Análisis Ingresos vs Egresos', 1, 0, 'Financiero');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Centro de anuncios')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Centro de anuncios', 1, 0, 'Academico');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Comparativo de Años')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Comparativo de Años', 1, 0, 'Financiero');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Conciliación Rápida')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Conciliación Rápida', 1, 0, 'Financiero');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Configuración del Sistema')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Configuración del Sistema', 1, 0, 'Seguridad');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Cumplimiento de Documentos')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Cumplimiento de Documentos', 1, 0, 'Recursos Humanos');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Estado de Resultados')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Estado de Resultados', 1, 0, 'Financiero');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Flujo de Caja')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Flujo de Caja', 1, 0, 'Financiero');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Importador / Exportador')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Importador / Exportador', 1, 0, 'Seguridad');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'KPIs Académicos')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('KPIs Académicos', 1, 0, 'Academico');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'KPIs Financieros')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('KPIs Financieros', 1, 0, 'Financiero');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Logs de Errores')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Logs de Errores', 1, 0, 'Seguridad');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Matriz Rol Pantallas')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Matriz Rol Pantallas', 1, 0, 'Seguridad');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Mensajes a Encargados')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Mensajes a Encargados', 1, 0, 'Alumnos');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Organigrama')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Organigrama', 1, 0, 'Recursos Humanos');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Rendimiento por Sección')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Rendimiento por Sección', 1, 0, 'Academico');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Reportes pre-generados')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Reportes pre-generados', 1, 0, 'Reportes');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Sesiones Activas')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Sesiones Activas', 1, 0, 'Seguridad');
GO
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Descripcion = 'Visor de Gráficos')
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo) VALUES ('Visor de Gráficos', 1, 0, 'Reportes');
GO

-- =============================================
-- ASIGNAR TODAS AL ROL administrador
-- =============================================
DECLARE @RolId INT;
SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'administrador';
IF @RolId IS NOT NULL
BEGIN
    INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id)
    SELECT @RolId, Pan_Id FROM [Seguridad].[tbPantallas]
    WHERE Pan_Descripcion IN (
        'Análisis Ingresos vs Egresos', 'Centro de anuncios', 'Comparativo de Años',
        'Conciliación Rápida', 'Configuración del Sistema', 'Cumplimiento de Documentos',
        'Estado de Resultados', 'Flujo de Caja', 'Importador / Exportador',
        'KPIs Académicos', 'KPIs Financieros', 'Logs de Errores',
        'Matriz Rol Pantallas', 'Mensajes a Encargados', 'Organigrama',
        'Rendimiento por Sección', 'Reportes pre-generados', 'Sesiones Activas',
        'Visor de Gráficos',
        -- Also re-assign the renamed ones (name changed so old assignment still works by Pan_Id)
        'Pirámide de Matrícula', 'Cumpleaños Empleados', 'Pagos del Día',
        'Boletín de calificaciones'
    )
    AND NOT EXISTS (
        SELECT 1 FROM [Seguridad].[tbRolesPantallas] rp
        WHERE rp.Rol_Id = @RolId AND rp.Pan_Id = [Seguridad].[tbPantallas].Pan_Id
    );
END
GO
