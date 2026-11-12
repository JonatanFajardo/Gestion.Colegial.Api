-- 043_PR_PromediosPorAlumno.sql
-- SP para calcular el promedio anual por alumno a partir de app.tbNotas
-- y marcar como "bajo rendimiento" a quienes esten por debajo del umbral.
-- Usado por el endpoint API: GET /api/v1/PromediosAlumnos/ListAsync
-- La columna [Not_Año] se referencia con corchetes (contiene enie).

USE DB_GestionColegial;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'PR_Academico_PromediosPorAlumno' AND SCHEMA_NAME(schema_id) = 'app')
    DROP PROCEDURE app.PR_Academico_PromediosPorAlumno;
GO

CREATE PROCEDURE app.PR_Academico_PromediosPorAlumno
    @Anio        INT,
    @UmbralBajo  INT = 70
AS
BEGIN
    SET NOCOUNT ON;

    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());
    IF @UmbralBajo IS NULL SET @UmbralBajo = 70;

    SELECT
        a.Alu_Id,
        LTRIM(RTRIM(
            CONCAT_WS(' ',
                NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)),  ''),
                NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), ''),
                NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), ''),
                NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), '')
            )
        )) AS Alu_NombreCompleto,
        CAST(AVG(CAST(n.Not_Nota AS DECIMAL(5,2))) AS DECIMAL(5,2)) AS Promedio,
        CASE
            WHEN AVG(CAST(n.Not_Nota AS DECIMAL(5,2))) < @UmbralBajo
                THEN CAST(1 AS BIT)
            ELSE CAST(0 AS BIT)
        END AS EsBajo
    FROM app.tbAlumnos  a
    INNER JOIN app.tbPersonas p ON a.Per_Id = p.Per_Id
    INNER JOIN app.tbNotas    n ON n.Alu_Id = a.Alu_Id
    WHERE YEAR(n.[Not_Año]) = @Anio
      AND n.Not_EsActivo    = 1
      AND n.Not_EsEliminado = 0
    GROUP BY a.Alu_Id,
             p.Per_PrimerNombre,
             p.Per_SegundoNombre,
             p.Per_ApellidoPaterno,
             p.Per_ApellidoMaterno;
END
GO

PRINT 'Script 043 ejecutado: SP app.PR_Academico_PromediosPorAlumno creado/actualizado.';
GO
