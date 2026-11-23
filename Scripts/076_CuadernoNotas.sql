/* =============================================================================
   076 - Cuaderno de notas: captura de notas por horario (app.tbHorarios) y parcial
   - Los procedimientos de notas leían app.tbHorario (singular, legado). Ahora usan app.tbHorarios.
   - app.PR_Cuaderno_Horarios : horarios (materia + sección + semestre) del año activo que puede
       capturar el usuario. Un docente ve solo los suyos; los demás roles ven todos.
   - app.PR_tbNotas_List      : alumnos activos de la sección con su nota del parcial. Mismos
       parámetros + @Usu_Id; devuelve además Sec_Id, Mat_Id, Sem_Id y el año.
   - app.PR_tbNotas_Insert    : crea o actualiza la nota (misma firma). Valida 0-100, que el alumno sea
       de esa sección y que el docente sea el dueño del horario.
   - app.PR_tbNotas_Update    : misma firma; valida 0-100 y dueño. Conserva el bloqueo por parcial cerrado (075).
   - Errores 50071-50074 (se muestran tal cual al usuario). Idempotente.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Empleado del usuario si su rol es Docente (-1 si no tiene empleado); NULL si no es docente o si
-- @Usu_Id es NULL (sin restricción). Un usuario que no existe (0, vacío) se trata como sin acceso (-1).
CREATE OR ALTER FUNCTION app.FN_Cuaderno_EmpDocente (@Usu_Id int)
RETURNS int
AS
BEGIN
    IF @Usu_Id IS NULL RETURN NULL;
    RETURN ISNULL((SELECT TOP 1 CASE WHEN LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) = 'docente' THEN ISNULL(u.Emp_Id, -1) END
                   FROM seguridad.tbUsuarios u
                   JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
                   WHERE u.Usu_Id = @Usu_Id),
                  CASE WHEN EXISTS (SELECT 1 FROM seguridad.tbUsuarios WHERE Usu_Id = @Usu_Id) THEN NULL ELSE -1 END);
END
GO

CREATE OR ALTER PROCEDURE app.PR_Cuaderno_Horarios
    @Usu_Id int,
    @Anio   int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL
        SELECT @Anio = TRY_CAST(Con_Valor AS int) FROM app.tbConfiguracion WHERE Con_Clave = 'anio_lectivo_actual';
    DECLARE @Emp int = app.FN_Cuaderno_EmpDocente(@Usu_Id);

    SELECT MIN(h.Hor_Id) AS Hor_Id, h.Mat_Id, m.Mat_Nombre, h.Sec_Id, s.Sec_Descripcion,
           h.Cur_Id, c.Cur_Nombre, h.Cun_Id, cn.Cun_Descripcion, h.Sem_Id, sm.Sem_Descripcion,
           h.Hor_Año AS Anio,
           (SELECT COUNT(*) FROM app.tbAlumnos a
             WHERE a.Sec_Id = h.Sec_Id AND a.Cur_Id = h.Cur_Id AND a.Cun_Id = h.Cun_Id
               AND a.AnioCursado = h.Hor_Año AND a.Est_Id = 1) AS Alumnos
    FROM app.tbHorarios h
    JOIN app.tbMaterias m        ON m.Mat_Id = h.Mat_Id
    JOIN app.tbSecciones s       ON s.Sec_Id = h.Sec_Id
    JOIN app.tbCursos c          ON c.Cur_Id = h.Cur_Id
    JOIN app.tbCursosNiveles cn  ON cn.Cun_Id = h.Cun_Id
    JOIN app.tbSemestres sm      ON sm.Sem_Id = h.Sem_Id
    WHERE h.Hor_EsEliminado = 0 AND h.Hor_Año = @Anio
      AND (@Emp IS NULL OR h.Emp_Id = @Emp)
    GROUP BY h.Mat_Id, m.Mat_Nombre, h.Sec_Id, s.Sec_Descripcion, h.Cur_Id, c.Cur_Nombre,
             h.Cun_Id, cn.Cun_Descripcion, h.Sem_Id, sm.Sem_Descripcion, h.Hor_Año
    ORDER BY h.Sem_Id, cn.Cun_Descripcion, s.Sec_Descripcion, m.Mat_Nombre;
END
GO

-- Lista de alumnos activos de la sección del horario, con su nota del parcial (NULL si no tiene).
CREATE OR ALTER PROCEDURE [app].[PR_tbNotas_List]
    @Hor_Id  INT,
    @Par_Id  INT,          -- Pac_Id del parcial
    @Usu_Id  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Sec_Id INT, @Mat_Id INT, @Sem_Id INT, @Anio INT, @Cur_Id INT, @Cun_Id INT, @EmpH INT;
    SELECT @Sec_Id = Sec_Id, @Mat_Id = Mat_Id, @Sem_Id = Sem_Id, @Anio = Hor_Año,
           @Cur_Id = Cur_Id, @Cun_Id = Cun_Id, @EmpH = Emp_Id
    FROM app.tbHorarios WHERE Hor_Id = @Hor_Id AND Hor_EsEliminado = 0;

    IF @Sec_Id IS NULL
        THROW 50071, N'El horario seleccionado no existe.', 1;
    DECLARE @Emp INT = app.FN_Cuaderno_EmpDocente(@Usu_Id);
    IF @Usu_Id IS NOT NULL AND @Emp IS NOT NULL AND @Emp <> @EmpH
        THROW 50072, N'Ese horario no está asignado a su usuario.', 1;

    SELECT a.Alu_Id,
           LTRIM(RTRIM(CONCAT(p.Per_PrimerNombre, ' ', ISNULL(p.Per_SegundoNombre + ' ', ''),
                              p.Per_ApellidoPaterno, ' ', ISNULL(p.Per_ApellidoMaterno, '')))) AS Alu_NombreCompleto,
           n.Not_Id, n.Not_Nota, n.Not_FechaRegistra, n.Not_FechaModifica,
           CASE WHEN n.Not_Id IS NOT NULL THEN 1 ELSE 0 END AS TieneNota,
           @Sec_Id AS Sec_Id, @Mat_Id AS Mat_Id, @Sem_Id AS Sem_Id, @Anio AS Anio
    FROM app.tbAlumnos a
    JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id
    LEFT JOIN app.tbNotas n
           ON n.Alu_Id = a.Alu_Id AND n.Sec_Id = @Sec_Id AND n.Mat_Id = @Mat_Id
          AND n.Pac_Id = @Par_Id AND n.Sem_Id = @Sem_Id AND YEAR(n.Not_Año) = @Anio
          AND n.Not_EsEliminado = 0
    WHERE a.Sec_Id = @Sec_Id AND a.Cur_Id = @Cur_Id AND a.Cun_Id = @Cun_Id
      AND a.AnioCursado = @Anio AND a.Est_Id = 1 AND p.Per_EsEliminado = 0
    ORDER BY p.Per_ApellidoPaterno, p.Per_PrimerNombre;
END
GO

CREATE OR ALTER PROCEDURE [app].[PR_tbNotas_Insert]
    @Alu_Id              INT,
    @Hor_Id              INT,
    @Par_Id              INT,           -- Pac_Id del parcial
    @Not_Calificacion    INT,           -- Not_Nota es INT en la tabla
    @UsuarioRegistra     INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Sec_Id INT, @Mat_Id INT, @Sem_Id INT, @Anio INT, @Aul_Id INT, @Cur_Id INT, @Cun_Id INT, @EmpH INT;
    SELECT @Sec_Id = Sec_Id, @Mat_Id = Mat_Id, @Sem_Id = Sem_Id, @Anio = Hor_Año, @Aul_Id = Aul_Id,
           @Cur_Id = Cur_Id, @Cun_Id = Cun_Id, @EmpH = Emp_Id
    FROM app.tbHorarios WHERE Hor_Id = @Hor_Id AND Hor_EsEliminado = 0;

    IF @Sec_Id IS NULL
    BEGIN
        SELECT 0 AS CodeResult, 0 AS Not_Id, 'Horario no encontrado' AS Mensaje;
        RETURN;
    END
    IF @Not_Calificacion IS NULL OR @Not_Calificacion < 0 OR @Not_Calificacion > 100
        THROW 50074, N'La nota debe ser un número entero entre 0 y 100.', 1;
    DECLARE @Emp INT = app.FN_Cuaderno_EmpDocente(@UsuarioRegistra);
    IF @Emp IS NOT NULL AND @Emp <> @EmpH
        THROW 50072, N'Ese horario no está asignado a su usuario.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbAlumnos a
                   WHERE a.Alu_Id = @Alu_Id AND a.Sec_Id = @Sec_Id AND a.Cur_Id = @Cur_Id
                     AND a.Cun_Id = @Cun_Id AND a.AnioCursado = @Anio AND a.Est_Id = 1)
        THROW 50073, N'El alumno no es un alumno activo de esa sección.', 1;

    DECLARE @FechaAnio DATE = DATEFROMPARTS(@Anio, 1, 1);
    DECLARE @ExistingId INT = NULL;

    SELECT @ExistingId = Not_Id
    FROM [app].[tbNotas]
    WHERE Alu_Id = @Alu_Id AND Sec_Id = @Sec_Id AND Mat_Id = @Mat_Id AND Pac_Id = @Par_Id
      AND Sem_Id = @Sem_Id AND YEAR(Not_Año) = @Anio AND Not_EsEliminado = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 075: parcial cerrado = no se registran ni cambian notas (THROW 50070), dentro de la transacción
        EXEC app.PR_CierresParcial_ValidarAbierto @Anio, @Sem_Id, @Par_Id;

        IF @ExistingId IS NOT NULL
        BEGIN
            UPDATE [app].[tbNotas]
            SET Not_Nota = @Not_Calificacion, Not_UsuarioModifica = @UsuarioRegistra, Not_FechaModifica = GETDATE()
            WHERE Not_Id = @ExistingId;

            COMMIT TRANSACTION;
            SELECT 1 AS CodeResult, @ExistingId AS Not_Id, 'Nota actualizada' AS Mensaje;
        END
        ELSE
        BEGIN
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
        IF ERROR_NUMBER() = 50070 THROW;
        SELECT 0 AS CodeResult, 0 AS Not_Id, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [app].[PR_tbNotas_Update]
    @Not_Id              INT,
    @Not_Calificacion    INT,           -- Not_Nota es INT
    @UsuarioModifica     INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Not_Calificacion IS NULL OR @Not_Calificacion < 0 OR @Not_Calificacion > 100
        THROW 50074, N'La nota debe ser un número entero entre 0 y 100.', 1;
    DECLARE @Emp INT = app.FN_Cuaderno_EmpDocente(@UsuarioModifica);
    IF @Emp IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM app.tbNotas n
            JOIN app.tbHorarios h ON h.Mat_Id = n.Mat_Id AND h.Sec_Id = n.Sec_Id AND h.Sem_Id = n.Sem_Id
                                 AND h.Hor_Año = YEAR(n.Not_Año) AND h.Hor_EsEliminado = 0 AND h.Emp_Id = @Emp
            WHERE n.Not_Id = @Not_Id)
        THROW 50072, N'Esa nota no es de una materia asignada a su usuario.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        -- 075: parcial cerrado = no se registran ni cambian notas (THROW 50070), dentro de la transacción
        EXEC app.PR_CierresParcial_ValidarNota @Not_Id;
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
        IF ERROR_NUMBER() = 50070 THROW;
        SELECT 0 AS CodeResult;
    END CATCH
END
GO

PRINT '076 Cuaderno de notas OK';
GO
