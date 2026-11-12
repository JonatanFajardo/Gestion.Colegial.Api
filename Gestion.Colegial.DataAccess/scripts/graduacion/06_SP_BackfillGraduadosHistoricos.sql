/* =============================================================================
   SP: app.spBackfillGraduadosHistoricos
   Proyecto: Archivado de Graduados
   Rama API: feature/graduacion-alumnos
   ----------------------------------------------------------------------------
   Propósito:
     Procesar en lote alumnos que ya están marcados como Graduados (Est_Id = 3)
     y que aún viven en app.tbAlumnos. Aplica app.spGraduarAlumno por
     cada uno, registrando éxito/fallo en app.tbArchivoGraduadoLog.

   Parámetros:
     @Anio    int  = NULL   -> Filtra por año del último boletín (YEAR(Not_Año)).
                              Si NULL, no filtra por año.
     @TopN    int  = 50     -> Tamaño máximo del lote por ejecución.
     @DryRun  bit  = 1      -> Si 1, sólo lista candidatos; no ejecuta nada.

   ASSUMPTIONS:
     -- ASSUMPTION: Est_Id = 3 corresponde a 'Graduado' (validado en DB).
     -- ASSUMPTION: La regla de @Anio se aplica sobre MAX(YEAR(Not_Año)) por
                    alumno (último año en que tuvo notas registradas).

   TODO:
     -- TODO: Si el negocio define un campo explícito de "año de graduación"
              en tbAlumnos, reemplazar el cálculo basado en tbNotas.
   ============================================================================= */

IF OBJECT_ID('app.spBackfillGraduadosHistoricos', 'P') IS NOT NULL
    DROP PROCEDURE app.spBackfillGraduadosHistoricos;
GO

CREATE PROCEDURE app.spBackfillGraduadosHistoricos
    @Anio       INT  = NULL,
    @TopN       INT  = 50,
    @DryRun     BIT  = 1,
    @UsuarioId  INT  = 0   -- usuario "sistema" por defecto
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Procesados INT = 0;
    DECLARE @Exitos     INT = 0;
    DECLARE @Fallos     INT = 0;

    -- Candidatos: alumnos marcados como Graduado en app.tbAlumnos.
    DECLARE @Candidatos TABLE
    (
        Alu_Id     INT PRIMARY KEY,
        UltimoAnio INT NULL
    );

    INSERT INTO @Candidatos (Alu_Id, UltimoAnio)
    SELECT TOP (@TopN)
           a.Alu_Id,
           ua.UltimoAnio
    FROM   app.tbAlumnos a
    OUTER APPLY (
        SELECT MAX(YEAR(n.Not_Año)) AS UltimoAnio
        FROM   app.tbNotas n
        WHERE  n.Alu_Id = a.Alu_Id AND n.Not_EsEliminado = 0
    ) ua
    WHERE  a.Est_Id = 3 -- Graduado
      AND  (@Anio IS NULL OR ua.UltimoAnio = @Anio)
    ORDER BY a.Alu_Id;

    -----------------------------------------------------------------
    -- DRY RUN: sólo lista
    -----------------------------------------------------------------
    IF @DryRun = 1
    BEGIN
        SELECT  c.Alu_Id,
                c.UltimoAnio,
                LTRIM(RTRIM(
                    ISNULL(p.Per_PrimerNombre,'')   + ' ' +
                    ISNULL(p.Per_ApellidoPaterno,'')+ ' ' +
                    ISNULL(p.Per_ApellidoMaterno,'')
                ))                       AS NombreCompleto,
                'DryRun - no ejecutado'  AS Accion
        FROM    @Candidatos c
        INNER JOIN app.tbAlumnos a ON a.Alu_Id = c.Alu_Id
        INNER JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id;

        RETURN;
    END

    -----------------------------------------------------------------
    -- EJECUCIÓN REAL
    -----------------------------------------------------------------
    DECLARE @Alu_Id INT;
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT Alu_Id FROM @Candidatos ORDER BY Alu_Id;

    OPEN cur;
    FETCH NEXT FROM cur INTO @Alu_Id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Procesados = @Procesados + 1;

        BEGIN TRY
            EXEC app.spGraduarAlumno
                 @Alu_Id    = @Alu_Id,
                 @UsuarioId = @UsuarioId;
            SET @Exitos = @Exitos + 1;
        END TRY
        BEGIN CATCH
            SET @Fallos = @Fallos + 1;

            -- spGraduarAlumno ya intenta loguear; igual reforzamos contexto.
            BEGIN TRY
                INSERT INTO app.tbArchivoGraduadoLog
                    (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
                     LogArc_Accion, LogArc_RegistrosAfectados, LogArc_Detalle, LogArc_UsuarioId)
                VALUES
                    (NULL, @Alu_Id, '(backfill)', 'SKIP', 0,
                     CONCAT(N'BACKFILL_ERROR: ', ERROR_MESSAGE()), @UsuarioId);
            END TRY BEGIN CATCH END CATCH
        END CATCH

        FETCH NEXT FROM cur INTO @Alu_Id;
    END

    CLOSE cur;
    DEALLOCATE cur;

    SELECT @Procesados AS Procesados,
           @Exitos     AS Exitos,
           @Fallos     AS Fallos;
END;
GO
