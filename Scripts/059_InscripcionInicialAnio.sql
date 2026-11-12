-- =====================================================================
-- 059_InscripcionInicialAnio.sql
-- Inscripción inicial del año lectivo (cierra el hueco #1 de la capa multi-año).
--
-- Los alumnos hoy existen solo en app.tbAlumnos con su ubicación
-- (Niv_Id, Cun_Id, Mda_Id, Sec_Id). Estos procedimientos los inscriben en el
-- año (app.tbMatriculaAnio) dentro de su sección del año (app.tbSeccionesAnio).
--
--   app.PR_tbMatriculaAnio_ResumenInscripcion    — grupos de ubicación del año vs
--                                                   secciones del año e inscritos.
--   app.PR_tbSeccionesAnio_CrearDesdeUbicacion   — crea las secciones del año que faltan.
--   app.PR_tbMatriculaAnio_InscribirDesdeUbicacion — inscribe en lote (o un alumno),
--                                                   opcionalmente crea secciones y
--                                                   pasa de Graduado a Activo.
--
-- "Alumno del año" = tbAlumnos.AnioCursado = tbAnioLectivo.Ani_Anio.
-- Si @Ani_Id es NULL se usa el año activo (tbConfiguracion 'anio_lectivo_activo_id').
-- Estados usados: tbEstados 1 = Activo, 3 = Graduado · Mta_Estado 1 = Activa ·
-- Sea_Estado 2 = Planificada, 3 = Activa (si el año está Abierto = 3).
-- Convención: idempotente (DROP/CREATE); nunca borra; se puede ejecutar varias veces.
-- Los procedimientos se crean con QUOTED_IDENTIFIER ON: tbSeccionesAnio tiene un índice
-- filtrado y una columna calculada, y sin esa opción sus INSERT fallan (sqlcmd la trae OFF).
-- =====================================================================
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ─────────────────────────────────────────────────
-- PR_tbMatriculaAnio_ResumenInscripcion
--   Una fila por grupo de ubicación (nivel + grado + modalidad + sección) de los
--   alumnos del año, con su sección del año (si existe) y cuántos están inscritos.
-- ─────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbMatriculaAnio_ResumenInscripcion]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbMatriculaAnio_ResumenInscripcion]
GO
CREATE PROCEDURE [app].[PR_tbMatriculaAnio_ResumenInscripcion]
    @Ani_Id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Ani_Id IS NULL
        SET @Ani_Id = TRY_CONVERT(INT, (SELECT TOP 1 Con_Valor FROM [app].[tbConfiguracion] WHERE Con_Clave = 'anio_lectivo_activo_id'));

    DECLARE @anio INT = (SELECT Ani_Anio FROM [app].[tbAnioLectivo] WHERE Ani_Id = @Ani_Id);

    ;WITH alu AS (
        SELECT  a.Alu_Id, a.Niv_Id, a.Cun_Id, a.Mda_Id, a.Sec_Id,
                CASE WHEN EXISTS (SELECT 1 FROM [app].[tbMatriculaAnio] m
                                  WHERE m.Alu_Id = a.Alu_Id AND m.Ani_Id = @Ani_Id AND m.Mta_EsEliminado = 0)
                     THEN 1 ELSE 0 END AS Inscrito
        FROM    [app].[tbAlumnos] a
        WHERE   a.AnioCursado = @anio
    ), grupos AS (
        SELECT  Niv_Id, Cun_Id, Mda_Id, Sec_Id,
                COUNT(*)      AS Alumnos,
                SUM(Inscrito) AS Inscritos
        FROM    alu
        GROUP BY Niv_Id, Cun_Id, Mda_Id, Sec_Id
    )
    SELECT  @Ani_Id                         AS Ani_Id,
            g.Niv_Id, g.Cun_Id, g.Mda_Id, g.Sec_Id,
            n.Niv_Descripcion,
            c.Cun_Descripcion,
            md.Mda_Descripcion,
            s.Sec_Descripcion,
            g.Alumnos,
            g.Inscritos,
            g.Alumnos - g.Inscritos         AS Pendientes,
            sa.Sea_Id,
            sa.Sea_Nombre
    FROM    grupos g
    LEFT JOIN [app].[tbNivelesEducativos] n  ON n.Niv_Id  = g.Niv_Id
    LEFT JOIN [app].[tbCursosNiveles]     c  ON c.Cun_Id  = g.Cun_Id
    LEFT JOIN [app].[tbModalidades]       md ON md.Mda_Id = g.Mda_Id
    LEFT JOIN [app].[tbSecciones]         s  ON s.Sec_Id  = g.Sec_Id
    LEFT JOIN [app].[tbSeccionesAnio]     sa ON sa.Ani_Id = @Ani_Id AND sa.Sea_EsEliminado = 0
                                            AND sa.Niv_Id = g.Niv_Id AND sa.Cun_Id = g.Cun_Id
                                            AND sa.Sec_Id = g.Sec_Id AND sa.Sea_MdaKey = ISNULL(g.Mda_Id, 0)
    ORDER BY g.Niv_Id, c.Cun_Orden, c.Cun_Descripcion, s.Sec_Descripcion, md.Mda_Descripcion;
END
GO

-- ─────────────────────────────────────────────────
-- PR_tbSeccionesAnio_CrearDesdeUbicacion
--   Crea, para el año, una sección por cada grupo de ubicación de sus alumnos que
--   todavía no la tenga. Nombre: "<grado> <sección> · <modalidad>". Sin profe guía
--   (se asigna después en el wizard). @Alu_Id limita al grupo de un alumno.
--   Devuelve el mismo formato que InscribirDesdeUbicacion (solo SeccionesCreadas).
-- ─────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbSeccionesAnio_CrearDesdeUbicacion]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbSeccionesAnio_CrearDesdeUbicacion]
GO
CREATE PROCEDURE [app].[PR_tbSeccionesAnio_CrearDesdeUbicacion]
    @Ani_Id      INT = NULL,
    @Alu_Id      INT = NULL,
    @Usuario     INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Ani_Id IS NULL
        SET @Ani_Id = TRY_CONVERT(INT, (SELECT TOP 1 Con_Valor FROM [app].[tbConfiguracion] WHERE Con_Clave = 'anio_lectivo_activo_id'));

    DECLARE @anio INT, @estadoAnio TINYINT;
    SELECT @anio = Ani_Anio, @estadoAnio = Ani_Estado FROM [app].[tbAnioLectivo] WHERE Ani_Id = @Ani_Id;

    INSERT INTO [app].[tbSeccionesAnio]
        (Ani_Id, Niv_Id, Cun_Id, Sec_Id, Mda_Id, Emp_Id, Sea_Nombre, Sea_Cupo,
         Sea_Estado, Sea_EsEliminado, Sea_UsuarioRegistra, Sea_FechaRegistra)
    SELECT  @Ani_Id, g.Niv_Id, g.Cun_Id, g.Sec_Id, g.Mda_Id, NULL,
            LEFT(CONCAT(c.Cun_Descripcion, ' ', s.Sec_Descripcion,
                        CASE WHEN md.Mda_Descripcion IS NOT NULL THEN ' · ' + md.Mda_Descripcion ELSE '' END), 60),
            NULL,
            CASE WHEN @estadoAnio = 3 THEN 3 ELSE 2 END,   -- año Abierto → sección Activa; si no, Planificada
            0, @Usuario, GETDATE()
    FROM (
        SELECT DISTINCT a.Niv_Id, a.Cun_Id, a.Mda_Id, a.Sec_Id
        FROM   [app].[tbAlumnos] a
        WHERE  (@Alu_Id IS NULL AND a.AnioCursado = @anio) OR a.Alu_Id = @Alu_Id
    ) g
    LEFT JOIN [app].[tbCursosNiveles] c  ON c.Cun_Id  = g.Cun_Id
    LEFT JOIN [app].[tbModalidades]   md ON md.Mda_Id = g.Mda_Id
    LEFT JOIN [app].[tbSecciones]     s  ON s.Sec_Id  = g.Sec_Id
    WHERE  @anio IS NOT NULL
      AND  g.Niv_Id IS NOT NULL AND g.Cun_Id IS NOT NULL AND g.Sec_Id IS NOT NULL
      AND  NOT EXISTS (SELECT 1 FROM [app].[tbSeccionesAnio] sa
                       WHERE sa.Ani_Id = @Ani_Id AND sa.Sea_EsEliminado = 0
                         AND sa.Niv_Id = g.Niv_Id AND sa.Cun_Id = g.Cun_Id
                         AND sa.Sec_Id = g.Sec_Id AND sa.Sea_MdaKey = ISNULL(g.Mda_Id, 0));

    SELECT  @@ROWCOUNT AS SeccionesCreadas,
            0 AS Inscritos, 0 AS Reactivados, 0 AS YaInscritos, 0 AS SinSeccion, 0 AS Activados;
END
GO

-- ─────────────────────────────────────────────────
-- PR_tbMatriculaAnio_InscribirDesdeUbicacion
--   Inscribe en el año a los alumnos del año (o solo a @Alu_Id) en la sección del
--   año que coincide con su ubicación. Respeta UNIQUE (Alu_Id, Ani_Id): reactiva
--   filas dadas de baja y no duplica a los ya inscritos.
--   @CrearSecciones = 1 crea antes las secciones que falten.
--   @ActivarEstado  = 1 pasa a Activo (Est_Id 1) a los inscritos que figuren como
--   Graduado (Est_Id 3); no toca Suspendido.
-- ─────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbMatriculaAnio_InscribirDesdeUbicacion]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbMatriculaAnio_InscribirDesdeUbicacion]
GO
CREATE PROCEDURE [app].[PR_tbMatriculaAnio_InscribirDesdeUbicacion]
    @Ani_Id          INT = NULL,
    @Alu_Id          INT = NULL,
    @CrearSecciones  BIT = 1,
    @ActivarEstado   BIT = 1,
    @Usuario         INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Ani_Id IS NULL
        SET @Ani_Id = TRY_CONVERT(INT, (SELECT TOP 1 Con_Valor FROM [app].[tbConfiguracion] WHERE Con_Clave = 'anio_lectivo_activo_id'));

    DECLARE @anio INT, @estadoAnio TINYINT;
    SELECT @anio = Ani_Anio, @estadoAnio = Ani_Estado FROM [app].[tbAnioLectivo] WHERE Ani_Id = @Ani_Id;

    DECLARE @creadas INT = 0, @inscritos INT = 0, @reactivados INT = 0,
            @yaInscritos INT = 0, @sinSeccion INT = 0, @activados INT = 0;

    IF @anio IS NULL
    BEGIN
        SELECT 0 AS SeccionesCreadas, 0 AS Inscritos, 0 AS Reactivados, 0 AS YaInscritos, 0 AS SinSeccion, 0 AS Activados;
        RETURN;
    END

    CREATE TABLE #alu (Alu_Id INT PRIMARY KEY, Niv_Id INT, Cun_Id INT, Mda_Id INT NULL, Sec_Id INT);
    INSERT INTO #alu (Alu_Id, Niv_Id, Cun_Id, Mda_Id, Sec_Id)
    SELECT Alu_Id, Niv_Id, Cun_Id, Mda_Id, Sec_Id
    FROM   [app].[tbAlumnos]
    WHERE  (@Alu_Id IS NULL AND AnioCursado = @anio) OR Alu_Id = @Alu_Id;

    BEGIN TRANSACTION;

    -- 1) Secciones del año que falten
    IF @CrearSecciones = 1
    BEGIN
        INSERT INTO [app].[tbSeccionesAnio]
            (Ani_Id, Niv_Id, Cun_Id, Sec_Id, Mda_Id, Emp_Id, Sea_Nombre, Sea_Cupo,
             Sea_Estado, Sea_EsEliminado, Sea_UsuarioRegistra, Sea_FechaRegistra)
        SELECT  @Ani_Id, g.Niv_Id, g.Cun_Id, g.Sec_Id, g.Mda_Id, NULL,
                LEFT(CONCAT(c.Cun_Descripcion, ' ', s.Sec_Descripcion,
                            CASE WHEN md.Mda_Descripcion IS NOT NULL THEN ' · ' + md.Mda_Descripcion ELSE '' END), 60),
                NULL,
                CASE WHEN @estadoAnio = 3 THEN 3 ELSE 2 END,
                0, @Usuario, GETDATE()
        FROM (SELECT DISTINCT Niv_Id, Cun_Id, Mda_Id, Sec_Id FROM #alu) g
        LEFT JOIN [app].[tbCursosNiveles] c  ON c.Cun_Id  = g.Cun_Id
        LEFT JOIN [app].[tbModalidades]   md ON md.Mda_Id = g.Mda_Id
        LEFT JOIN [app].[tbSecciones]     s  ON s.Sec_Id  = g.Sec_Id
        WHERE  g.Niv_Id IS NOT NULL AND g.Cun_Id IS NOT NULL AND g.Sec_Id IS NOT NULL
          AND  NOT EXISTS (SELECT 1 FROM [app].[tbSeccionesAnio] sa
                           WHERE sa.Ani_Id = @Ani_Id AND sa.Sea_EsEliminado = 0
                             AND sa.Niv_Id = g.Niv_Id AND sa.Cun_Id = g.Cun_Id
                             AND sa.Sec_Id = g.Sec_Id AND sa.Sea_MdaKey = ISNULL(g.Mda_Id, 0));
        SET @creadas = @@ROWCOUNT;
    END

    -- 2) Sección del año y matrícula previa de cada alumno
    CREATE TABLE #asig (Alu_Id INT PRIMARY KEY, Sea_Id INT NULL, Mta_Id INT NULL, Viva BIT NULL);
    INSERT INTO #asig (Alu_Id, Sea_Id, Mta_Id, Viva)
    SELECT  a.Alu_Id, sa.Sea_Id, m.Mta_Id,
            CASE WHEN m.Mta_Id IS NULL THEN NULL WHEN m.Mta_EsEliminado = 0 THEN 1 ELSE 0 END
    FROM    #alu a
    OUTER APPLY (SELECT TOP 1 x.Sea_Id FROM [app].[tbSeccionesAnio] x
                 WHERE x.Ani_Id = @Ani_Id AND x.Sea_EsEliminado = 0
                   AND x.Niv_Id = a.Niv_Id AND x.Cun_Id = a.Cun_Id
                   AND x.Sec_Id = a.Sec_Id AND x.Sea_MdaKey = ISNULL(a.Mda_Id, 0)) sa
    OUTER APPLY (SELECT TOP 1 y.Mta_Id, y.Mta_EsEliminado FROM [app].[tbMatriculaAnio] y
                 WHERE y.Alu_Id = a.Alu_Id AND y.Ani_Id = @Ani_Id) m;

    SELECT @yaInscritos = COUNT(*) FROM #asig WHERE Viva = 1;
    SELECT @sinSeccion  = COUNT(*) FROM #asig WHERE ISNULL(Viva, 0) = 0 AND Sea_Id IS NULL;

    -- 3) Reactivar matrículas dadas de baja
    UPDATE  m
    SET     Sea_Id              = x.Sea_Id,
            Mta_Estado          = 1,
            Mta_EsEliminado     = 0,
            Mta_UsuarioModifica = @Usuario,
            Mta_FechaModifica   = GETDATE()
    FROM    [app].[tbMatriculaAnio] m
    JOIN    #asig x ON x.Mta_Id = m.Mta_Id
    WHERE   x.Viva = 0 AND x.Sea_Id IS NOT NULL;
    SET @reactivados = @@ROWCOUNT;

    -- 4) Inscribir a los que nunca estuvieron en el año
    INSERT INTO [app].[tbMatriculaAnio]
        (Alu_Id, Ani_Id, Sea_Id, Mta_Estado, Mta_EsEliminado, Mta_UsuarioRegistra, Mta_FechaRegistra)
    SELECT  x.Alu_Id, @Ani_Id, x.Sea_Id, 1, 0, @Usuario, GETDATE()
    FROM    #asig x
    WHERE   x.Mta_Id IS NULL AND x.Sea_Id IS NOT NULL;
    SET @inscritos = @@ROWCOUNT;

    -- 5) Quien está inscrito en el año no puede figurar como Graduado
    IF @ActivarEstado = 1
    BEGIN
        UPDATE  al
        SET     Est_Id = 1                                      -- Activo
        FROM    [app].[tbAlumnos] al
        JOIN    #alu a ON a.Alu_Id = al.Alu_Id
        WHERE   al.Est_Id = 3                                   -- Graduado
          AND   EXISTS (SELECT 1 FROM [app].[tbMatriculaAnio] m
                        WHERE m.Alu_Id = al.Alu_Id AND m.Ani_Id = @Ani_Id AND m.Mta_EsEliminado = 0);
        SET @activados = @@ROWCOUNT;
    END

    COMMIT TRANSACTION;

    SELECT  @creadas     AS SeccionesCreadas,
            @inscritos   AS Inscritos,
            @reactivados AS Reactivados,
            @yaInscritos AS YaInscritos,
            @sinSeccion  AS SinSeccion,
            @activados   AS Activados;
END
GO
