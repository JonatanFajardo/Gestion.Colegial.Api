/* =============================================================================
   093 · Constancias con las notas finales del cierre del año   (requiere los scripts 064 y 090)

   app.PR_tbDocumentosEmitidos_Calcular (misma firma y mismos códigos que en el script 064) agrega al
   contenido congelado del documento:
     - finales   : nota final de cada materia (con la recuperación ya aplicada) y su resultado, de los
                   años en que la decisión del alumno se confirmó en el Cierre del año;
     - resultados: promedio del año y decisión (promovido / repite / se gradúa) con la marca de fin
                   de nivel.
   Solo boletín de todos los parciales, expediente y constancia de estudio (esta última, solo el
   resultado del año). El boletín de un solo parcial no cambia. Con notas finales, el promedio del
   documento usa la nota final de cada materia; sin ellas se calcula igual que antes.
   Los documentos ya emitidos no cambian (son inmutables); las revisiones nuevas traen estos datos.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE app.PR_tbDocumentosEmitidos_Calcular
    @Doc_Tipo   varchar(12),
    @Alu_Id     int,
    @Ani_Id     int = NULL,
    @Pac_Id     int = NULL,
    @Codigo     int            OUTPUT,
    @Contenido  nvarchar(max)  OUTPUT,
    @Promedio   decimal(5,2)   OUTPUT,
    @Revision   int            OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @Codigo = 0, @Contenido = NULL, @Promedio = NULL, @Revision = NULL;
    SET @Doc_Tipo = UPPER(LTRIM(RTRIM(@Doc_Tipo)));

    -- El expediente abarca todos los años: no lleva año.
    IF @Doc_Tipo = 'EXPEDIENTE' SET @Ani_Id = NULL;

    IF @Doc_Tipo IS NULL OR @Doc_Tipo NOT IN ('ESTUDIO', 'BOLETIN', 'EXPEDIENTE')
       OR NOT EXISTS (SELECT 1 FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id)
       OR (@Doc_Tipo IN ('ESTUDIO', 'BOLETIN') AND @Ani_Id IS NULL)
       OR (@Ani_Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id AND Ani_EsEliminado = 0))
       OR (@Pac_Id IS NOT NULL AND @Doc_Tipo <> 'BOLETIN')
       OR (@Pac_Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM app.tbParciales WHERE Pac_Id = @Pac_Id AND Pac_EsEliminado = 0))
    BEGIN
        SET @Codigo = -3;
        RETURN;
    END

    -- Matrícula del año (ESTUDIO exige que no esté retirado).
    DECLARE @Sea_Id int, @Matriculado bit = 0;
    IF @Ani_Id IS NOT NULL
        SELECT TOP (1) @Sea_Id = m.Sea_Id, @Matriculado = 1
        FROM app.tbMatriculaAnio m
        WHERE m.Alu_Id = @Alu_Id AND m.Ani_Id = @Ani_Id AND m.Mta_EsEliminado = 0
          AND (@Doc_Tipo <> 'ESTUDIO' OR m.Mta_Estado <> 4);

    IF @Doc_Tipo IN ('ESTUDIO', 'BOLETIN') AND @Matriculado = 0
    BEGIN
        SET @Codigo = -2;
        RETURN;
    END

    DECLARE @Anio int = (SELECT Ani_Anio FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id);
    DECLARE @Parcial nvarchar(100) = (SELECT Pac_Descripcion FROM app.tbParciales WHERE Pac_Id = @Pac_Id);

    -- Notas incluidas.
    DECLARE @Notas TABLE (Anio int, Grado nvarchar(200), Seccion nvarchar(200), Materia nvarchar(200),
                          Mat_Id int, Sem_Id int, Semestre nvarchar(100), Pac_Id int, Parcial nvarchar(100), Nota int);
    IF @Doc_Tipo IN ('BOLETIN', 'EXPEDIENTE')
        INSERT INTO @Notas
        SELECT YEAR(n.Not_Año), TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM cn.Cun_Descripcion),
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM COALESCE(s1.Sec_Descripcion, s2.Sec_Descripcion)),
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM ma.Mat_Nombre), n.Mat_Id, n.Sem_Id, se.Sem_Descripcion, n.Pac_Id, pa.Pac_Descripcion, n.Not_Nota
        FROM app.tbNotas n
        LEFT JOIN app.tbMaterias ma        ON ma.Mat_Id = n.Mat_Id
        LEFT JOIN app.tbParciales pa       ON pa.Pac_Id = n.Pac_Id
        LEFT JOIN app.tbSemestres se       ON se.Sem_Id = n.Sem_Id
        LEFT JOIN app.tbAnioLectivo an     ON an.Ani_Anio = YEAR(n.Not_Año) AND an.Ani_EsEliminado = 0
        LEFT JOIN app.tbMatriculaAnio m    ON m.Alu_Id = n.Alu_Id AND m.Ani_Id = an.Ani_Id AND m.Mta_EsEliminado = 0
        LEFT JOIN app.tbSeccionesAnio sa   ON sa.Sea_Id = m.Sea_Id
        LEFT JOIN app.tbCursosNiveles cn   ON cn.Cun_Id = sa.Cun_Id
        LEFT JOIN app.tbSecciones s1       ON s1.Sec_Id = sa.Sec_Id
        LEFT JOIN app.tbSecciones s2       ON s2.Sec_Id = n.Sec_Id
        WHERE n.Alu_Id = @Alu_Id
          AND n.Not_EsEliminado = 0 AND n.Not_EsActivo = 1
          AND (@Anio IS NULL OR YEAR(n.Not_Año) = @Anio)
          AND (@Pac_Id IS NULL OR n.Pac_Id = @Pac_Id);

    IF @Doc_Tipo IN ('BOLETIN', 'EXPEDIENTE') AND NOT EXISTS (SELECT 1 FROM @Notas)
    BEGIN
        SET @Codigo = -1;
        RETURN;
    END

    -- Notas finales y resultado del año del cierre (script 090): solo de los años en que la decisión
    -- del alumno ya se confirmó (esos resultados quedan congelados). No aplica al boletín de un parcial.
    DECLARE @Finales TABLE (Anio int, Materia nvarchar(200), NotaFinal decimal(5,2), Resultado varchar(20),
                            NotaRecuperacion decimal(5,2), AproboRecuperacion bit);
    DECLARE @Resultados TABLE (Anio int, Promedio decimal(5,2), Decision varchar(12), TerminaNivel bit, Nivel nvarchar(200));
    IF @Pac_Id IS NULL
    BEGIN
        INSERT INTO @Resultados
        SELECT an.Ani_Anio, pr.Pra_Promedio, ISNULL(pr.Pra_Decision, pr.Pra_Propuesta), pr.Pra_TerminaNivel,
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM ne.Niv_Descripcion)
        FROM app.tbPromocionesAnio pr
        JOIN app.tbAnioLectivo an            ON an.Ani_Id = pr.Ani_Id AND an.Ani_EsEliminado = 0
        LEFT JOIN app.tbNivelesEducativos ne ON ne.Niv_Id = pr.Niv_Id
        WHERE pr.Alu_Id = @Alu_Id AND pr.Pra_Confirmada = 1 AND pr.Pra_EsEliminado = 0
          AND (@Ani_Id IS NULL OR pr.Ani_Id = @Ani_Id);

        IF @Doc_Tipo IN ('BOLETIN', 'EXPEDIENTE')
            INSERT INTO @Finales
            SELECT an.Ani_Anio, TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM COALESCE(ma.Mat_Nombre, r.Rea_Materia)), r.Rea_NotaFinal, r.Rea_Resultado,
                   r.Rea_NotaRecuperacion, r.Rea_AproboRecuperacion
            FROM app.tbResultadosAnio r
            JOIN app.tbAnioLectivo an     ON an.Ani_Id = r.Ani_Id
            JOIN app.tbPromocionesAnio pr ON pr.Ani_Id = r.Ani_Id AND pr.Alu_Id = r.Alu_Id
                                         AND pr.Pra_Confirmada = 1 AND pr.Pra_EsEliminado = 0
            LEFT JOIN app.tbMaterias ma   ON ma.Mat_Id = r.Mat_Id
            WHERE r.Alu_Id = @Alu_Id AND r.Rea_EsEliminado = 0
              AND (@Ani_Id IS NULL OR r.Ani_Id = @Ani_Id);
    END

    IF @Doc_Tipo <> 'ESTUDIO' AND NOT EXISTS (SELECT 1 FROM @Finales)
        SET @Promedio = (SELECT CAST(ROUND(AVG(CAST(Nota AS decimal(9,4))), 2) AS decimal(5,2)) FROM @Notas);
    ELSE IF @Doc_Tipo <> 'ESTUDIO'
        -- Con notas finales: promedio de las materias, con la nota final donde la hay (incluye la
        -- recuperación) y el promedio de sus notas donde no (años sin cierre confirmado).
        SET @Promedio = (
            SELECT CAST(ROUND(AVG(COALESCE(f.NotaFinal, x.Prom)), 2) AS decimal(5,2))
            FROM (SELECT Anio, Materia, AVG(CAST(Nota AS decimal(9,4))) AS Prom FROM @Notas GROUP BY Anio, Materia) x
            FULL JOIN @Finales f ON f.Anio = x.Anio AND f.Materia = x.Materia);

    -- Ubicación: la del año pedido; sin año (expediente), la actual del alumno.
    DECLARE @Alumno nvarchar(max) = (
        SELECT al.Alu_Id,
               CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), N''),
                         NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N'')) AS Nombre,
               p.Per_Identidad      AS Identidad,
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM ne.Niv_Descripcion) AS Nivel,
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM cn.Cun_Descripcion) AS Grado,
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM cu.Cur_Nombre) AS Curso,
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM s.Sec_Descripcion) AS Seccion,
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM md.Mda_Descripcion) AS Modalidad
        FROM app.tbAlumnos al
        JOIN app.tbPersonas p              ON p.Per_Id = al.Per_Id
        LEFT JOIN app.tbSeccionesAnio sa   ON sa.Sea_Id = @Sea_Id
        LEFT JOIN app.tbNivelesEducativos ne ON ne.Niv_Id = CASE WHEN @Ani_Id IS NULL THEN al.Niv_Id ELSE sa.Niv_Id END
        LEFT JOIN app.tbCursosNiveles cn   ON cn.Cun_Id = CASE WHEN @Ani_Id IS NULL THEN al.Cun_Id ELSE sa.Cun_Id END
        LEFT JOIN app.tbSecciones s        ON s.Sec_Id  = CASE WHEN @Ani_Id IS NULL THEN al.Sec_Id ELSE sa.Sec_Id END
        LEFT JOIN app.tbModalidades md     ON md.Mda_Id = CASE WHEN @Ani_Id IS NULL THEN al.Mda_Id ELSE sa.Mda_Id END
        LEFT JOIN app.tbCursos cu          ON cu.Cur_Id = al.Cur_Id   -- la sección del año no guarda la carrera
        WHERE al.Alu_Id = @Alu_Id
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES);

    DECLARE @ListaNotas nvarchar(max) = (
        SELECT Anio, Grado, Seccion, Materia, Pac_Id, Parcial, Nota, Sem_Id, Semestre
        FROM @Notas
        ORDER BY Anio, Materia, Pac_Id, Sem_Id
        FOR JSON PATH, INCLUDE_NULL_VALUES);

    DECLARE @ListaFinales nvarchar(max) = (
        SELECT Anio, Materia, NotaFinal, Resultado, NotaRecuperacion, AproboRecuperacion
        FROM @Finales
        ORDER BY Anio, Materia
        FOR JSON PATH, INCLUDE_NULL_VALUES);

    DECLARE @ListaResultados nvarchar(max) = (
        SELECT Anio, Promedio, Decision, TerminaNivel, Nivel
        FROM @Resultados
        ORDER BY Anio
        FOR JSON PATH, INCLUDE_NULL_VALUES);

    SET @Contenido = (
        SELECT JSON_QUERY(@Alumno) AS alumno,
               @Anio AS anio,
               @Parcial AS parcial,
               JSON_QUERY(ISNULL(@ListaNotas, N'[]')) AS notas,
               JSON_QUERY(ISNULL(@ListaFinales, N'[]')) AS finales,
               JSON_QUERY(ISNULL(@ListaResultados, N'[]')) AS resultados
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES);

    SET @Revision = 1 + ISNULL((
        SELECT MAX(d.Doc_Revision) FROM app.tbDocumentosEmitidos d
        WHERE d.Alu_Id = @Alu_Id AND d.Doc_Tipo = @Doc_Tipo
          AND ISNULL(d.Ani_Id, 0) = ISNULL(@Ani_Id, 0)
          AND ISNULL(d.Pac_Id, 0) = ISNULL(@Pac_Id, 0)), 0);
END
GO
