-- 042_SP_Seed_NotasAlumnos.sql
-- SP para sembrar notas masivas en app.tbNotas con distribucion realista
-- ~18% de alumnos con bajo rendimiento (notas < 70), el resto entre 70 y 100.
-- Aul_Id distribuido entre los 9 valores reales (1,3,5,7,9,11,13,15,17), Sec_Id siempre = 1.
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
    @SoloUnaMateria    BIT = 0,
    @LimpiarPrevias    BIT = 0,
    @UsuarioRegistra   INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Fecha date = DATEFROMPARTS(@Anio, 6, 15);
    DECLARE @Ahora datetime = GETDATE();
    DECLARE @TotalAulas int = (SELECT COUNT(*) FROM app.tbCursos_tbSecciones);

    IF (@TotalAulas IS NULL OR @TotalAulas = 0)
    BEGIN
        RAISERROR('No hay filas en app.tbCursos_tbSecciones; no se puede asignar Aul_Id.', 16, 1);
        RETURN;
    END

    -- Limpieza opcional de notas previas del mismo anio
    IF (@LimpiarPrevias = 1)
    BEGIN
        DELETE FROM app.tbNotas
        WHERE YEAR([Not_Año]) = @Anio;
    END

    -- Mapa de Aul_Id reales (los 9 disponibles en tbCursos_tbSecciones)
    -- Indices 0..(@TotalAulas-1) para round-robin determinista por alumno.
    ;WITH AulasMap AS (
        SELECT Aul_Id, Sec_Id,
               ROW_NUMBER() OVER (ORDER BY Aul_Id) - 1 AS Idx
          FROM app.tbCursos_tbSecciones
    ),
    AlumnosRanked AS (
        SELECT a.Alu_Id,
               ROW_NUMBER() OVER (ORDER BY a.Alu_Id) - 1 AS RN
          FROM app.tbAlumnos a
    ),
    AlumnosConAula AS (
        SELECT ar.Alu_Id,
               ar.RN,
               am.Aul_Id,
               am.Sec_Id,
               -- Flag determinista de bajo rendimiento (~@PorcentajeBajo%)
               CASE WHEN ((ar.Alu_Id * 7 + 13) % 100) < @PorcentajeBajo
                    THEN 1 ELSE 0 END AS EsBajo
          FROM AlumnosRanked ar
          JOIN AulasMap am
            ON am.Idx = (ar.RN % @TotalAulas)
    )
    INSERT INTO app.tbNotas
        (Alu_Id, Aul_Id, Sec_Id, Not_Nota, Mat_Id, Sem_Id, Pac_Id,
         [Not_Año], Not_EsActivo, Not_EsEliminado,
         Not_UsuarioRegistra, Not_FechaRegistra,
         Not_UsuarioModifica, Not_FechaModifica)
    SELECT
        ac.Alu_Id,
        ac.Aul_Id,
        ac.Sec_Id,
        CASE
            WHEN ac.EsBajo = 1
                THEN 50 + (ABS(CHECKSUM(NEWID())) % (@UmbralBajo - 50))
            ELSE
                -- Nota entre 70 y 100 con sesgo a 75-90 (promedio de dos tiradas)
                70 + ((ABS(CHECKSUM(NEWID())) % 31 + ABS(CHECKSUM(NEWID())) % 31) / 2)
        END AS Not_Nota,
        m.Mat_Id,
        s.Sem_Id,
        p.Pac_Id,
        @Fecha,
        1,    -- Not_EsActivo
        0,    -- Not_EsEliminado
        @UsuarioRegistra,
        @Ahora,
        NULL,
        NULL
      FROM AlumnosConAula ac
     CROSS JOIN app.tbMaterias  m
     CROSS JOIN app.tbSemestres s
     CROSS JOIN app.tbParciales p
     WHERE m.Mat_EsActivo = 1 AND m.Mat_EsEliminado = 0
       AND s.Sem_EsActivo = 1 AND s.Sem_EsEliminado = 0
       AND p.Pac_EsEliminado = 0
       AND (@SoloUnaMateria = 0 OR m.Mat_Id = 1);

    -- Resumen
    SELECT
        'Notas sembradas' AS Mensaje,
        COUNT(*)                                                       AS Total,
        SUM(CASE WHEN Not_Nota <  @UmbralBajo THEN 1 ELSE 0 END)       AS Bajas,
        SUM(CASE WHEN Not_Nota >= @UmbralBajo THEN 1 ELSE 0 END)       AS Buenas
      FROM app.tbNotas
     WHERE YEAR([Not_Año]) = @Anio;
END
GO
