/* =============================================================================
   067 · Arreglo del boletín (Boletin/FindAsync)

   Problema: app.PR_Boletin_Generate devuelve TRES result sets (1 datos del alumno,
   2 notas, 3 promedios). El repositorio lee con DataTable.Load, que toma solo el
   PRIMER result set (los datos del alumno), por eso el boletín llegaba con
   Mat_Id=0 / Not_Nota=null y mostraba "Sin materia · —" para todos los alumnos.
   Además la clase de resultado espera columnas Par_Id / Par_Descripcion, pero el SP
   las nombraba Pac_Id / Pac_Descripcion.

   Solución: SP dedicado que devuelve las notas del alumno/año como ÚNICO result set,
   con los alias que espera PR_Boletin_GenerateResult (Pac_Id -> Par_Id). El repo pasa
   a llamar a este SP. No se toca PR_Boletin_Generate (por si lo usa algo más).
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE app.PR_Boletin_Notas
    @Alu_Id int,
    @Anio   int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.Alu_Id,
        LTRIM(RTRIM(CONCAT_WS(' ',
            NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)),  ''),
            NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), ''),
            NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), ''),
            NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), '')))) AS Alu_NombreCompleto,
        LTRIM(RTRIM(REPLACE(REPLACE(c.Cur_Nombre, CHAR(13), ''), CHAR(10), ''))) AS Cur_Nombre,
        s.Sec_Descripcion            AS Sec_Nombre,
        n.Mat_Id,
        m.Mat_Nombre,
        n.Pac_Id                     AS Par_Id,
        pac.Pac_Descripcion          AS Par_Descripcion,
        CAST(n.Not_Nota AS decimal(5,2)) AS Not_Nota,  -- la clase lo espera decimal?; Not_Nota es int
        YEAR(n.[Not_Año])            AS Anio
    FROM app.tbNotas n
    INNER JOIN app.tbMaterias  m   ON m.Mat_Id = n.Mat_Id
    INNER JOIN app.tbParciales pac ON pac.Pac_Id = n.Pac_Id
    INNER JOIN app.tbAlumnos   a   ON a.Alu_Id = n.Alu_Id
    INNER JOIN app.tbPersonas  p   ON p.Per_Id = a.Per_Id
    LEFT  JOIN app.tbCursos    c   ON c.Cur_Id = a.Cur_Id
    LEFT  JOIN app.tbSecciones s   ON s.Sec_Id = a.Sec_Id
    WHERE n.Alu_Id          = @Alu_Id
      AND YEAR(n.[Not_Año])  = @Anio
      AND n.Not_EsActivo     = 1
      AND n.Not_EsEliminado  = 0
    ORDER BY m.Mat_Nombre, n.Pac_Id;
END
GO
