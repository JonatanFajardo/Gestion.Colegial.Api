-- 042_SP_Seed_NotasAlumnos.sql
-- SP para sembrar notas masivas en app.tbNotas con distribucion realista.
-- Fuente de materias: app.tbHorarios del año indicado (curso-seccion-materia realmente impartidas).
-- Atribucion de Not_UsuarioRegistra: usuario del docente de tbHorarios si existe, si no fallback.
-- ~18% de alumnos con bajo rendimiento (notas < 70), el resto entre 70 y 100.
-- La columna [Not_Año] se referencia siempre con corchetes (contiene enie).

USE DB_GestionColegial;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'PR_Seed_NotasAlumnos' AND SCHEMA_NAME(schema_id) = 'app')
    DROP PROCEDURE app.PR_Seed_NotasAlumnos;
GO

CREATE PROCEDURE app.PR_Seed_NotasAlumnos
    @Anio              INT,
    @PorcentajeBajo    INT = 18,
    @UmbralBajo        INT = 70,
    @LimpiarPrevias    BIT = 0,
    @UsuarioFallback   INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Fecha date = DATEFROMPARTS(@Anio, 6, 15);
    DECLARE @Ahora datetime = GETDATE();

    IF NOT EXISTS (SELECT 1 FROM app.tbHorarios WHERE [Hor_Año] = @Anio AND Hor_EsEliminado = 0)
    BEGIN
        RAISERROR('No hay horarios registrados para el año %d; no se puede sembrar notas.', 16, 1, @Anio);
        RETURN;
    END

    IF (@LimpiarPrevias = 1)
    BEGIN
        DELETE FROM app.tbNotas
        WHERE YEAR([Not_Año]) = @Anio;
    END

    -- Un registro por (Cur_Id, Sec_Id, Mat_Id) tomado de horarios reales del año.
    -- Aul_Id y Emp_Id se colapsan al MIN por combinacion (representante estable).
    ;WITH MateriasPorSeccion AS (
        SELECT
            h.Cur_Id,
            h.Sec_Id,
            h.Mat_Id,
            MIN(h.Aul_Id) AS Aul_Id,
            MIN(h.Emp_Id) AS Emp_Id
          FROM app.tbHorarios h
         WHERE [Hor_Año] = @Anio
           AND h.Hor_EsEliminado = 0
         GROUP BY h.Cur_Id, h.Sec_Id, h.Mat_Id
    ),
    -- Alumnos cruzados con las materias impartidas a su curso-seccion.
    AlumnoNotas AS (
        SELECT
            a.Alu_Id,
            mps.Aul_Id,
            a.Sec_Id,
            mps.Mat_Id,
            mps.Emp_Id,
            -- Flag determinista de bajo rendimiento (~@PorcentajeBajo%)
            CASE WHEN ((a.Alu_Id * 7 + 13) % 100) < @PorcentajeBajo
                 THEN 1 ELSE 0 END AS EsBajo
          FROM app.tbAlumnos a
          JOIN MateriasPorSeccion mps
            ON mps.Cur_Id = a.Cur_Id
           AND mps.Sec_Id = a.Sec_Id
    )
    INSERT INTO app.tbNotas
        (Alu_Id, Aul_Id, Sec_Id, Not_Nota, Mat_Id, Sem_Id, Pac_Id,
         [Not_Año], Not_EsActivo, Not_EsEliminado,
         Not_UsuarioRegistra, Not_FechaRegistra,
         Not_UsuarioModifica, Not_FechaModifica)
    SELECT
        an.Alu_Id,
        an.Aul_Id,
        an.Sec_Id,
        CASE
            WHEN an.EsBajo = 1
                THEN 50 + (ABS(CHECKSUM(NEWID())) % (@UmbralBajo - 50))
            ELSE
                -- Nota entre 70 y 100 con sesgo a 75-90 (promedio de dos tiradas)
                70 + ((ABS(CHECKSUM(NEWID())) % 31 + ABS(CHECKSUM(NEWID())) % 31) / 2)
        END AS Not_Nota,
        an.Mat_Id,
        s.Sem_Id,
        p.Pac_Id,
        @Fecha,
        1,    -- Not_EsActivo
        0,    -- Not_EsEliminado
        ISNULL(u.Usu_Id, @UsuarioFallback) AS Not_UsuarioRegistra,
        @Ahora,
        NULL,
        NULL
      FROM AlumnoNotas an
     CROSS JOIN app.tbSemestres s
     CROSS JOIN app.tbParciales p
      JOIN app.tbMaterias m
        ON m.Mat_Id = an.Mat_Id
     OUTER APPLY (
         SELECT TOP 1 Usu_Id
           FROM seguridad.tbUsuarios
          WHERE Emp_Id = an.Emp_Id
            AND Usu_EsActivo = 1
            AND Usu_EsEliminado = 0
          ORDER BY Usu_Id
     ) u
     WHERE m.Mat_EsActivo = 1 AND m.Mat_EsEliminado = 0
       AND s.Sem_EsActivo = 1 AND s.Sem_EsEliminado = 0
       AND p.Pac_EsEliminado = 0;

    -- Resumen
    SELECT
        'Notas sembradas' AS Mensaje,
        COUNT(*)                                                       AS Total,
        SUM(CASE WHEN Not_Nota <  @UmbralBajo THEN 1 ELSE 0 END)       AS Bajas,
        SUM(CASE WHEN Not_Nota >= @UmbralBajo THEN 1 ELSE 0 END)       AS Buenas,
        COUNT(DISTINCT Not_UsuarioRegistra)                            AS DocentesDistintos
      FROM app.tbNotas
     WHERE YEAR([Not_Año]) = @Anio;
END
GO
