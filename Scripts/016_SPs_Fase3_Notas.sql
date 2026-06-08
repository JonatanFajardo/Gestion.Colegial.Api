-- =====================================================================
-- Script 016: SPs Fase 3 — Notas y Boletín
-- Crea/reemplaza:
--   app.PR_tbNotas_List         — lista notas por horario y parcial
--   app.PR_tbNotas_Insert       — insertar/actualizar nota (usando tbHorario)
--   app.PR_tbNotas_Update       — actualizar nota existente
--   app.PR_Boletin_Generate     — boletín completo del alumno por año
-- Convención: idempotente (DROP IF EXISTS + CREATE)
-- Nota: tbNotas usa Not_Año (date), Pac_Id (parcial), Not_Nota (int)
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbNotas_List
-- Lista todas las notas de una sección/materia/parcial/año
-- Parámetros: @Hor_Id (identifica Sec_Id+Mat_Id+Sem_Id), @Par_Id (Pac_Id)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbNotas_List]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbNotas_List];
GO
CREATE PROCEDURE [app].[PR_tbNotas_List]
    @Hor_Id INT,
    @Par_Id INT          -- Pac_Id del parcial
AS
BEGIN
    SET NOCOUNT ON;

    -- Resolver Sec_Id, Mat_Id, Sem_Id desde el horario
    DECLARE @Sec_Id INT, @Mat_Id INT, @Sem_Id INT, @Anio INT;
    SELECT
        @Sec_Id = h.Sec_Id,
        @Mat_Id = h.Mat_Id,
        @Sem_Id = h.Sem_Id,
        @Anio   = h.Hor_Año
    FROM [app].[tbHorario] h
    WHERE h.Hor_Id = @Hor_Id AND h.Hor_EsEliminado = 0;

    -- Todos los alumnos de la sección con su nota (NULL si no tiene)
    SELECT
        a.Alu_Id,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre, ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        )))                 AS Alu_NombreCompleto,
        p.Per_Imagen,
        n.Not_Id,
        n.Not_Nota,
        n.Not_FechaRegistra,
        n.Not_FechaModifica,
        CASE WHEN n.Not_Id IS NOT NULL THEN 1 ELSE 0 END AS TieneNota
    FROM [app].[tbAlumnos] a
    INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
    LEFT JOIN [app].[tbNotas] n
        ON  n.Alu_Id          = a.Alu_Id
        AND n.Sec_Id          = @Sec_Id
        AND n.Mat_Id          = @Mat_Id
        AND n.Pac_Id          = @Par_Id
        AND n.Sem_Id          = @Sem_Id
        AND YEAR(n.Not_Año)   = @Anio
        AND n.Not_EsEliminado = 0
    WHERE a.Sec_Id         = @Sec_Id
      AND a.AnioCursado    = @Anio
      AND p.Per_EsEliminado = 0
    ORDER BY p.Per_ApellidoPaterno, p.Per_PrimerNombre;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbNotas_Insert  (versión corregida con @Hor_Id y convención firma)
-- Inserta o actualiza nota de alumno derivando Sec_Id/Mat_Id/Sem_Id
-- desde el horario. Si ya existe la nota la actualiza (UPSERT).
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbNotas_Insert]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbNotas_Insert];
GO
CREATE PROCEDURE [app].[PR_tbNotas_Insert]
    @Alu_Id              INT,
    @Hor_Id              INT,
    @Par_Id              INT,           -- Pac_Id del parcial
    @Not_Calificacion    INT,           -- Not_Nota es INT en la tabla
    @UsuarioRegistra     INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Resolver datos del horario
    DECLARE @Sec_Id INT, @Mat_Id INT, @Sem_Id INT, @Anio INT, @Aul_Id INT;
    SELECT
        @Sec_Id = Sec_Id,
        @Mat_Id = Mat_Id,
        @Sem_Id = Sem_Id,
        @Anio   = Hor_Año,
        @Aul_Id = Aul_Id
    FROM [app].[tbHorario]
    WHERE Hor_Id = @Hor_Id AND Hor_EsEliminado = 0;

    IF @Sec_Id IS NULL
    BEGIN
        SELECT 0 AS CodeResult, 0 AS Not_Id, 'Horario no encontrado' AS Mensaje;
        RETURN;
    END

    DECLARE @FechaAnio DATE = DATEFROMPARTS(@Anio, 1, 1);
    DECLARE @ExistingId INT = NULL;

    SELECT @ExistingId = Not_Id
    FROM [app].[tbNotas]
    WHERE Alu_Id          = @Alu_Id
      AND Sec_Id          = @Sec_Id
      AND Mat_Id          = @Mat_Id
      AND Pac_Id          = @Par_Id
      AND Sem_Id          = @Sem_Id
      AND YEAR(Not_Año)   = @Anio
      AND Not_EsEliminado = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @ExistingId IS NOT NULL
        BEGIN
            -- Actualizar nota existente
            UPDATE [app].[tbNotas]
            SET Not_Nota            = @Not_Calificacion,
                Not_UsuarioModifica = @UsuarioRegistra,
                Not_FechaModifica   = GETDATE()
            WHERE Not_Id = @ExistingId;

            COMMIT TRANSACTION;
            SELECT 1 AS CodeResult, @ExistingId AS Not_Id, 'Nota actualizada' AS Mensaje;
        END
        ELSE
        BEGIN
            -- Insertar nueva nota
            INSERT INTO [app].[tbNotas]
                (Alu_Id, Aul_Id, Sec_Id, Mat_Id, Sem_Id, Pac_Id,
                 Not_Nota, Not_Año, Not_EsActivo, Not_EsEliminado,
                 Not_UsuarioRegistra, Not_FechaRegistra)
            VALUES
                (@Alu_Id, @Aul_Id, @Sec_Id, @Mat_Id, @Sem_Id, @Par_Id,
                 @Not_Calificacion, @FechaAnio, 1, 0,
                 @UsuarioRegistra, GETDATE());

            DECLARE @NewId INT = SCOPE_IDENTITY();
            COMMIT TRANSACTION;
            SELECT 1 AS CodeResult, @NewId AS Not_Id, 'Nota insertada' AS Mensaje;
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS CodeResult, 0 AS Not_Id, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbNotas_Update  (reemplaza version anterior)
-- Actualiza únicamente la calificación de una nota por Not_Id
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbNotas_Update]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbNotas_Update];
GO
CREATE PROCEDURE [app].[PR_tbNotas_Update]
    @Not_Id              INT,
    @Not_Calificacion    INT,           -- Not_Nota es INT
    @UsuarioModifica     INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [app].[tbNotas]
        SET Not_Nota            = @Not_Calificacion,
            Not_UsuarioModifica = @UsuarioModifica,
            Not_FechaModifica   = GETDATE()
        WHERE Not_Id = @Not_Id AND Not_EsEliminado = 0;

        COMMIT TRANSACTION;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS CodeResult;
    END CATCH
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_Boletin_Generate
-- Boletín completo de un alumno en un año:
--   ResultSet 1: datos del alumno (persona + curso + sección)
--   ResultSet 2: notas por materia y parcial
--   ResultSet 3: resumen promedio por materia
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_Boletin_Generate]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Boletin_Generate];
GO
CREATE PROCEDURE [app].[PR_Boletin_Generate]
    @Alu_Id INT,
    @Anio   INT
AS
BEGIN
    SET NOCOUNT ON;

    -- RS1: Datos del alumno
    SELECT
        a.Alu_Id,
        a.AnioCursado,
        a.PromedioAnual,
        p.Per_PrimerNombre,
        p.Per_SegundoNombre,
        p.Per_ApellidoPaterno,
        p.Per_ApellidoMaterno,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre, ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        )))                         AS NombreCompleto,
        p.Per_Identidad,
        p.Per_FechaNacimiento,
        p.Per_Sexo,
        p.Per_Imagen,
        c.Cur_Nombre,
        cn.Cun_Descripcion,
        s.Sec_Descripcion,
        niv.Niv_Descripcion
    FROM [app].[tbAlumnos] a
    INNER JOIN [app].[tbPersonas]      p   ON a.Per_Id  = p.Per_Id
    INNER JOIN [app].[tbCursos]        c   ON a.Cur_Id  = c.Cur_Id
    LEFT  JOIN [app].[tbCursosNiveles] cn  ON a.Cun_Id  = cn.Cun_Id
    LEFT  JOIN [app].[tbSecciones]     s   ON a.Sec_Id  = s.Sec_Id
    LEFT  JOIN [app].[tbNivelesEducativos] niv ON a.Niv_Id = niv.Niv_Id
    WHERE a.Alu_Id = @Alu_Id;

    -- RS2: Notas detalle por materia, semestre y parcial
    SELECT
        n.Not_Id,
        n.Mat_Id,
        m.Mat_Nombre,
        n.Pac_Id,
        pac.Pac_Descripcion,
        n.Sem_Id,
        sem.Sem_Descripcion,
        n.Not_Nota,
        n.Not_Año,
        n.Not_FechaRegistra,
        n.Not_FechaModifica
    FROM [app].[tbNotas]    n
    INNER JOIN [app].[tbMaterias]   m   ON n.Mat_Id  = m.Mat_Id
    INNER JOIN [app].[tbParciales]  pac ON n.Pac_Id  = pac.Pac_Id
    INNER JOIN [app].[tbSemestres]  sem ON n.Sem_Id  = sem.Sem_Id
    WHERE n.Alu_Id          = @Alu_Id
      AND YEAR(n.Not_Año)   = @Anio
      AND n.Not_EsEliminado = 0
    ORDER BY sem.Sem_Id, m.Mat_Nombre, pac.Pac_Id;

    -- RS3: Promedio por materia
    SELECT
        n.Mat_Id,
        m.Mat_Nombre,
        n.Sem_Id,
        sem.Sem_Descripcion,
        AVG(CAST(n.Not_Nota AS DECIMAL(5,2)))  AS PromedioMateria,
        MIN(n.Not_Nota)                         AS NotaMinima,
        MAX(n.Not_Nota)                         AS NotaMaxima,
        COUNT(n.Not_Id)                         AS TotalParciales
    FROM [app].[tbNotas]   n
    INNER JOIN [app].[tbMaterias]  m   ON n.Mat_Id = m.Mat_Id
    INNER JOIN [app].[tbSemestres] sem ON n.Sem_Id = sem.Sem_Id
    WHERE n.Alu_Id          = @Alu_Id
      AND YEAR(n.Not_Año)   = @Anio
      AND n.Not_EsEliminado = 0
    GROUP BY n.Mat_Id, m.Mat_Nombre, n.Sem_Id, sem.Sem_Descripcion, sem.Sem_Id
    ORDER BY sem.Sem_Id, m.Mat_Nombre;
END
GO

PRINT 'Script 016 completado: SPs Fase 3 (Notas + Boletin) creados exitosamente.';
GO
