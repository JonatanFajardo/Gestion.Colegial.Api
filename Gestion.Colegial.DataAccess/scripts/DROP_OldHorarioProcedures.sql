-- =====================================================================
-- Script: DROP Procedimientos Antiguos de HorarioAlumnos
-- Descripción: Elimina los procedimientos almacenados antiguos que fueron
--              reemplazados por los nuevos procedimientos de tbHorarios
-- Fecha: 2025-11-27
-- =====================================================================

USE [DB_GestionColegial]
GO

PRINT '=====================================================================';
PRINT 'Eliminando procedimientos antiguos de tbHorarioAlumnos...';
PRINT '=====================================================================';

-- Eliminar PR_tbHorarioAlumnos_Insert
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarioAlumnos_Insert]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [app].[PR_tbHorarioAlumnos_Insert];
    PRINT '✓ PR_tbHorarioAlumnos_Insert eliminado';
END
ELSE
BEGIN
    PRINT '- PR_tbHorarioAlumnos_Insert no existe';
END
GO

-- Eliminar PR_tbHorarioAlumnos_Update
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarioAlumnos_Update]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [app].[PR_tbHorarioAlumnos_Update];
    PRINT '✓ PR_tbHorarioAlumnos_Update eliminado';
END
ELSE
BEGIN
    PRINT '- PR_tbHorarioAlumnos_Update no existe';
END
GO

-- Eliminar PR_tbHorarioAlumnos_List
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarioAlumnos_List]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [app].[PR_tbHorarioAlumnos_List];
    PRINT '✓ PR_tbHorarioAlumnos_List eliminado';
END
ELSE
BEGIN
    PRINT '- PR_tbHorarioAlumnos_List no existe';
END
GO

-- Eliminar PR_tbHorarioAlumnos_Find
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarioAlumnos_Find]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [app].[PR_tbHorarioAlumnos_Find];
    PRINT '✓ PR_tbHorarioAlumnos_Find eliminado';
END
ELSE
BEGIN
    PRINT '- PR_tbHorarioAlumnos_Find no existe';
END
GO

-- Eliminar PR_tbHorarioAlumnos_Delete
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarioAlumnos_Delete]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [app].[PR_tbHorarioAlumnos_Delete];
    PRINT '✓ PR_tbHorarioAlumnos_Delete eliminado';
END
ELSE
BEGIN
    PRINT '- PR_tbHorarioAlumnos_Delete no existe';
END
GO

PRINT '';
PRINT '=====================================================================';
PRINT 'Procedimientos antiguos eliminados exitosamente.';
PRINT 'Ahora debes usar los nuevos procedimientos PR_tbHorarios_*';
PRINT '=====================================================================';
GO
