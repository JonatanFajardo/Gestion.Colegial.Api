-- Script 028: Limpieza de duplicados
-- 1. Elimina SPs en schema dbo que deben estar solo en schema app
-- 2. Elimina pantallas duplicadas generadas por script 027 (2xxx/3xxx) cuando ya existia equivalente en 1xxx

USE [DB_GestionColegial]
GO

-- ============================================================
-- PARTE 1: Drop SPs duplicados en schema dbo
-- ============================================================
IF EXISTS (SELECT 1 FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'PR_tbNotas_Insert' AND type = 'P')
    DROP PROCEDURE [dbo].[PR_tbNotas_Insert];
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE schema_id = SCHEMA_ID('dbo') AND name = 'PR_tbNotas_Update' AND type = 'P')
    DROP PROCEDURE [dbo].[PR_tbNotas_Update];
GO

-- ============================================================
-- PARTE 2: Eliminar asignaciones de roles de pantallas duplicadas
-- ============================================================
DELETE FROM [Seguridad].[tbRolesPantallas]
WHERE Pan_Id IN (
    2068,  -- 'Boletin de calificaciones'   => dup de 1081
    2071,  -- 'Asistencia Empleados'         => dup de 1094
    2072,  -- 'Pagos del Dia'                => dup de 1100
    2073,  -- 'Pendientes por Cobrar'        => dup de 1127
    3068,  -- 'Analisis Ingresos vs Egresos' => dup de 1133
    3069,  -- 'Comparativo de Anos'          => dup de 1107
    3070,  -- 'Conciliacion Rapida'          => dup de 1129
    3071,  -- 'Configuracion del Sistema'    => dup de 1113
    3072,  -- 'Cumplimiento de Documentos'   => dup de 1126
    3073,  -- 'Estado de Resultados'         => dup de 1130
    3074,  -- 'Flujo de Caja'                => dup de 1104
    3075,  -- 'Importador / Exportador'      => dup de 1116
    3076,  -- 'KPIs Academicos'              => dup de 1136
    3077,  -- 'Matriz Rol Pantallas'         => dup de 1117
    3078,  -- 'Rendimiento por Seccion'      => dup de 1109
    3079   -- 'Visor de Graficos'            => dup de 1139
);
GO

-- ============================================================
-- PARTE 3: Eliminar las pantallas duplicadas
-- ============================================================
DELETE FROM [Seguridad].[tbPantallas]
WHERE Pan_Id IN (
    2068, 2071, 2072, 2073,
    3068, 3069, 3070, 3071, 3072, 3073, 3074, 3075, 3076, 3077, 3078, 3079
);
GO

PRINT 'Script 028 completado: duplicados eliminados.';
GO
