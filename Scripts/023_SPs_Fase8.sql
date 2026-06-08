-- =====================================================================
-- Script 023: SPs Fase 8 — Seguridad / Admin
-- Crea/reemplaza:
--   [TABLA]  Seguridad.tbSesiones          — si no existe (idempotente)
--   Seguridad.PR_SesionesActivas_List      — lista sesiones activas con usuario
--   Seguridad.PR_MatrizRolPantallas_Get    — matriz completa Rol × Pantalla (1/0)
-- Convención: idempotente (DROP IF EXISTS + CREATE). Terminar con GO.
-- Estructura Seguridad existente:
--   Seguridad.tbRoles:         Rol_Id, Rol_Descripcion, Rol_Estado, Rol_EsEliminado
--   Seguridad.tbPantallas:     Pan_Id, Pan_Descripcion, Pan_Grupo, Pan_Estado, Pan_EsEliminado
--   Seguridad.tbRolesPantallas: RolPan_Id, Rol_Id, Pan_Id
--   Seguridad.tbUsuarios:      Usu_Id, Usu_Name, Rol_Id, Emp_Id, Usu_EsEliminado
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- Verificar existencia previa de los SPs
-- SELECT SCHEMA_NAME(schema_id)+'.'+name FROM sys.objects
-- WHERE type='P' AND name IN ('PR_SesionesActivas_List','PR_MatrizRolPantallas_Get')
-- ──────────────────────────────────────────────────────────────────────

-- ──────────────────────────────────────────────────────────────────────
-- Tabla: Seguridad.tbSesiones
-- Registro de sesiones de usuarios (tokens de acceso).
-- Permite auditar y forzar cierre de sesiones desde administración.
-- ──────────────────────────────────────────────────────────────────────
IF NOT EXISTS (
    SELECT * FROM sys.tables
    WHERE name = 'tbSesiones'
      AND schema_id = SCHEMA_ID('Seguridad')
)
BEGIN
    CREATE TABLE [Seguridad].[tbSesiones] (
        [Ses_Id]              INT            IDENTITY(1,1) NOT NULL,
        [Usu_Id]              INT            NOT NULL,
        [Ses_Token]           NVARCHAR(500)  NOT NULL,
        [Ses_FechaInicio]     DATETIME       NOT NULL CONSTRAINT [DF_Ses_FechaInicio]    DEFAULT (GETDATE()),
        [Ses_UltimaActividad] DATETIME       NOT NULL CONSTRAINT [DF_Ses_UltActiv]       DEFAULT (GETDATE()),
        [Ses_IP]              VARCHAR(50)    NULL,
        [Ses_UserAgent]       NVARCHAR(300)  NULL,
        [Ses_EsActiva]        BIT            NOT NULL CONSTRAINT [DF_Ses_EsActiva]       DEFAULT (1),
        [Ses_FechaCierre]     DATETIME       NULL,
        CONSTRAINT [PK_tbSesiones] PRIMARY KEY CLUSTERED ([Ses_Id] ASC),
        CONSTRAINT [FK_Sesiones_Usuarios]
            FOREIGN KEY ([Usu_Id]) REFERENCES [Seguridad].[tbUsuarios] ([Usu_Id])
    );
    -- Índice para búsqueda rápida por token
    CREATE NONCLUSTERED INDEX [IX_Sesiones_Token]
        ON [Seguridad].[tbSesiones] ([Ses_Token]);
    -- Índice para listar sesiones activas por usuario
    CREATE NONCLUSTERED INDEX [IX_Sesiones_Usu_Activa]
        ON [Seguridad].[tbSesiones] ([Usu_Id], [Ses_EsActiva]);
    PRINT 'Tabla Seguridad.tbSesiones creada.';
END
ELSE
    PRINT 'Seguridad.tbSesiones ya existe.';
GO

-- ──────────────────────────────────────────────────────────────────────
-- Seguridad.PR_SesionesActivas_List
-- Devuelve las sesiones activas (Ses_EsActiva = 1) con nombre de usuario,
-- rol y tiempo de inactividad en minutos.
-- Parámetros:
--   @Usu_Id INT NULL — filtrar por usuario específico; NULL = todos
-- Retorna:
--   Ses_Id, Usu_Id, Usu_Name, NombreCompleto, Rol_Descripcion,
--   Ses_FechaInicio, Ses_UltimaActividad, MinutosInactivo, Ses_IP, Ses_UserAgent
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[Seguridad].[PR_SesionesActivas_List]') IS NOT NULL
    DROP PROCEDURE [Seguridad].[PR_SesionesActivas_List];
GO
CREATE PROCEDURE [Seguridad].[PR_SesionesActivas_List]
    @Usu_Id INT = NULL   -- NULL = todas las sesiones activas del sistema
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.Ses_Id,
        s.Usu_Id,
        u.Usu_Name,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre, ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        )))                                         AS NombreCompleto,
        r.Rol_Descripcion,
        s.Ses_FechaInicio,
        s.Ses_UltimaActividad,
        DATEDIFF(MINUTE, s.Ses_UltimaActividad, GETDATE()) AS MinutosInactivo,
        s.Ses_IP,
        s.Ses_UserAgent
    FROM [Seguridad].[tbSesiones] s
    INNER JOIN [Seguridad].[tbUsuarios] u ON s.Usu_Id = u.Usu_Id
    INNER JOIN [Seguridad].[tbRoles]    r ON u.Rol_Id  = r.Rol_Id
    -- Datos personales del usuario (vía empleado)
    LEFT  JOIN [app].[tbEmpleados]  e ON u.Emp_Id  = e.Emp_Id
    LEFT  JOIN [app].[tbPersonas]   p ON e.Per_Id  = p.Per_Id
    WHERE s.Ses_EsActiva      = 1
      AND u.Usu_EsEliminado   = 0
      AND (@Usu_Id IS NULL OR s.Usu_Id = @Usu_Id)
    ORDER BY s.Ses_UltimaActividad DESC;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- Seguridad.PR_MatrizRolPantallas_Get
-- Retorna la matriz completa Rol × Pantalla con indicador de acceso (1/0).
-- Útil para renderizar la vista de matriz visual en el panel de admin.
-- Parámetros:
--   @Rol_Id INT NULL — filtrar por un solo rol; NULL = todos los roles
-- Retorna:
--   Rol_Id, Rol_Descripcion, Pan_Id, Pan_Descripcion, Pan_Grupo, TieneAcceso
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[Seguridad].[PR_MatrizRolPantallas_Get]') IS NOT NULL
    DROP PROCEDURE [Seguridad].[PR_MatrizRolPantallas_Get];
GO
CREATE PROCEDURE [Seguridad].[PR_MatrizRolPantallas_Get]
    @Rol_Id INT = NULL   -- NULL = matriz completa de todos los roles
AS
BEGIN
    SET NOCOUNT ON;

    -- Producto cartesiano Roles × Pantallas activas, con LEFT JOIN a la tabla puente
    SELECT
        r.Rol_Id,
        r.Rol_Descripcion,
        p.Pan_Id,
        p.Pan_Descripcion,
        ISNULL(p.Pan_Grupo, 'General')  AS Pan_Grupo,
        CASE WHEN rp.RolPan_Id IS NOT NULL THEN CAST(1 AS BIT)
             ELSE CAST(0 AS BIT)
        END                             AS TieneAcceso
    FROM [Seguridad].[tbRoles] r
    CROSS JOIN [Seguridad].[tbPantallas] p
    LEFT JOIN  [Seguridad].[tbRolesPantallas] rp
        ON  rp.Rol_Id = r.Rol_Id
        AND rp.Pan_Id = p.Pan_Id
    WHERE r.Rol_EsEliminado  = 0
      AND r.Rol_Estado        = 1
      AND p.Pan_EsEliminado  = 0
      AND p.Pan_Estado        = 1
      AND (@Rol_Id IS NULL OR r.Rol_Id = @Rol_Id)
    ORDER BY
        r.Rol_Descripcion,
        ISNULL(p.Pan_Grupo, 'General'),
        p.Pan_Descripcion;
END
GO
