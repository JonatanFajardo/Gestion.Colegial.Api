-- =============================================
-- Script: SPs para Fase 1 (Infraestructura compartida)
-- Pantallas: Mi perfil, Notificaciones, Buscador global
-- Base de datos: DB_GestionColegial
-- Requisitos: Scripts 001-009 ejecutados antes
-- =============================================

USE DB_GestionColegial;
GO

-- ============================================================
-- PERFIL DE USUARIO
-- Retorna datos del usuario + persona + rol para "Mi Perfil"
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Seguridad].[UDP_tbUsuarios_Perfil]') AND type = 'P')
    DROP PROCEDURE [Seguridad].[UDP_tbUsuarios_Perfil];
GO
CREATE PROCEDURE [Seguridad].[UDP_tbUsuarios_Perfil]
    @Usu_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.Usu_Id,
        u.Usu_Name,
        u.Usu_EsActivo,
        r.Rol_Id,
        r.Rol_Descripcion,
        p.Per_Id,
        CONCAT(p.Per_PrimerNombre, ' ', ISNULL(p.Per_SegundoNombre, ''), ' ', p.Per_ApellidoPaterno, ' ', ISNULL(p.Per_ApellidoMaterno, '')) AS NombreCompleto,
        p.Per_Imagen,
        p.Per_Identidad,
        p.Per_Telefono,
        p.Per_Direccion
    FROM [Seguridad].[tbUsuarios] u
    INNER JOIN [Seguridad].[tbRoles] r ON u.Rol_Id = r.Rol_Id
    LEFT JOIN  [app].[tbEmpleados] e  ON u.Emp_Id = e.Emp_Id
    LEFT JOIN  [app].[tbPersonas]  p  ON e.Per_Id  = p.Per_Id
    WHERE u.Usu_Id = @Usu_Id AND u.Usu_EsEliminado = 0;
END
GO


-- ============================================================
-- BUSCADOR GLOBAL
-- Busca alumnos y empleados por nombre o identidad
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_BuscadorGlobal]') AND type = 'P')
    DROP PROCEDURE [app].[PR_BuscadorGlobal];
GO
CREATE PROCEDURE [app].[PR_BuscadorGlobal]
    @Busqueda VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @q VARCHAR(102) = '%' + LTRIM(RTRIM(@Busqueda)) + '%';

    -- Alumnos
    SELECT
        'Alumno'                                                                AS Tipo,
        a.Alu_Id                                                                AS Id,
        CONCAT(p.Per_PrimerNombre, ' ', ISNULL(p.Per_SegundoNombre,''), ' ', p.Per_ApellidoPaterno) AS Nombre,
        p.Per_Identidad                                                         AS Identificador,
        p.Per_Imagen                                                            AS Imagen,
        c.Cur_Nombre                                                            AS Detalle
    FROM [app].[tbAlumnos] a
    INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
    INNER JOIN [app].[tbCursos]   c ON a.Cur_Id = c.Cur_Id
    WHERE p.Per_EsEliminado = 0
      AND (p.Per_PrimerNombre LIKE @q OR p.Per_ApellidoPaterno LIKE @q OR p.Per_Identidad LIKE @q
           OR CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno) LIKE @q)

    UNION ALL

    -- Empleados
    SELECT
        'Empleado'                                                               AS Tipo,
        e.Emp_Id                                                                 AS Id,
        CONCAT(p.Per_PrimerNombre, ' ', ISNULL(p.Per_SegundoNombre,''), ' ', p.Per_ApellidoPaterno) AS Nombre,
        p.Per_Identidad                                                          AS Identificador,
        p.Per_Imagen                                                             AS Imagen,
        ca.Car_Descripcion                                                       AS Detalle
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas] p  ON e.Per_Id  = p.Per_Id
    LEFT JOIN  [app].[tbCargos]   ca ON e.Car_Id  = ca.Car_Id
    WHERE p.Per_EsEliminado = 0 AND p.Per_EsActivo = 1
      AND (p.Per_PrimerNombre LIKE @q OR p.Per_ApellidoPaterno LIKE @q OR p.Per_Identidad LIKE @q
           OR CONCAT(p.Per_PrimerNombre, ' ', p.Per_ApellidoPaterno) LIKE @q)

    ORDER BY Nombre;
END
GO

PRINT 'Script 010 ejecutado exitosamente - SPs Fase 1 creados.';
GO
