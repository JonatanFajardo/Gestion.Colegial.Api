/* =============================================================================
   066 · Cuadro de honor   (requiere el 065: FN_EscalaConcepto + tbCuadroHonorConfig)

   - Ranking de los mejores alumnos de un año por promedio, en DOS niveles según los
     umbrales configurados (script 065): Cuadro de Honor Superior (promedio >= umbral
     superior) y Cuadro de Honor (>= umbral y por debajo del superior).
   - El promedio es el AVG de todas las notas activas del año (igual criterio que el SP
     043 de promedios). Filtros opcionales por nivel y por sección (la ubicación del
     alumno: tbAlumnos.Niv_Id / Sec_Id).
   - Devuelve también el concepto (app.FN_EscalaConcepto) y la ubicación para mostrar y
     agrupar. Solo trae a quienes llegan al umbral de honor, ordenados por promedio desc.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE app.PR_CuadroHonor
    @Anio   int,
    @Niv_Id int = NULL,
    @Sec_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());

    DECLARE @UmbralHonor decimal(5,2), @UmbralSuperior decimal(5,2);
    SELECT @UmbralHonor = Chc_UmbralHonor, @UmbralSuperior = Chc_UmbralHonorSuperior
    FROM app.tbCuadroHonorConfig WHERE Chc_Id = 1;
    IF @UmbralHonor   IS NULL SET @UmbralHonor   = 90;
    IF @UmbralSuperior IS NULL SET @UmbralSuperior = 95;

    ;WITH Prom AS (
        SELECT n.Alu_Id,
               CAST(AVG(CAST(n.Not_Nota AS decimal(5,2))) AS decimal(5,2)) AS Promedio
        FROM app.tbNotas n
        WHERE YEAR(n.[Not_Año]) = @Anio
          AND n.Not_EsActivo    = 1
          AND n.Not_EsEliminado = 0
        GROUP BY n.Alu_Id
    )
    SELECT
        a.Alu_Id,
        LTRIM(RTRIM(CONCAT_WS(' ',
            NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)),  ''),
            NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), ''),
            NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), ''),
            NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), '')))) AS Alu_NombreCompleto,
        pr.Promedio,
        app.FN_EscalaConcepto(pr.Promedio) AS Concepto,
        LTRIM(RTRIM(niv.Niv_Descripcion)) AS Nivel,
        LTRIM(RTRIM(REPLACE(REPLACE(cur.Cur_Nombre, CHAR(13), ''), CHAR(10), ''))) AS Curso,
        LTRIM(RTRIM(sec.Sec_Descripcion)) AS Seccion,
        CASE WHEN pr.Promedio >= @UmbralSuperior THEN 'S' ELSE 'H' END AS NivelHonor
    FROM Prom pr
    INNER JOIN app.tbAlumnos  a   ON a.Alu_Id = pr.Alu_Id
    INNER JOIN app.tbPersonas p   ON p.Per_Id = a.Per_Id
    LEFT  JOIN app.tbNivelesEducativos niv ON niv.Niv_Id = a.Niv_Id
    LEFT  JOIN app.tbCursos   cur ON cur.Cur_Id = a.Cur_Id
    LEFT  JOIN app.tbSecciones sec ON sec.Sec_Id = a.Sec_Id
    WHERE pr.Promedio >= @UmbralHonor
      AND (@Niv_Id IS NULL OR a.Niv_Id = @Niv_Id)
      AND (@Sec_Id IS NULL OR a.Sec_Id = @Sec_Id)
    ORDER BY pr.Promedio DESC, Alu_NombreCompleto;
END
GO

/* ---------------------------------------------------------------------------
   Permiso
   --------------------------------------------------------------------------- */
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES
    (N'Cuadro de honor', N'|1|1002|');

INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
SELECT x.Nombre, 1, 0, 'Academico'
FROM @Pantallas x
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas p WHERE p.Pan_Descripcion = x.Nombre);

INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN @Pantallas x ON x.Nombre = p.Pan_Descripcion
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0
                        AND x.Roles LIKE N'%|' + CONVERT(nvarchar(10), r.Rol_Id) + N'|%'
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas y WHERE y.Rol_Id = r.Rol_Id AND y.Pan_Id = p.Pan_Id);
GO
