USE [DB_GestionColegial]
GO

-- ══════════════════════════════════════════
--  PLAN DE CLASES
-- ══════════════════════════════════════════

IF OBJECT_ID('[app].[PR_tbPlanClases_List]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbPlanClases_List]
GO
CREATE PROCEDURE [app].[PR_tbPlanClases_List]
    @Hor_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Pla_Id, p.Hor_Id, p.Pla_Semana, p.Pla_Tema,
           p.Pla_Objetivos, p.Pla_Recursos, p.Pla_Estado, p.Pla_FechaRegistra,
           m.Mat_Nombre, s.Sec_Descripcion
    FROM   [app].[tbPlanClases] p
    INNER JOIN [app].[tbHorarios]  h ON p.Hor_Id = h.Hor_Id
    INNER JOIN [app].[tbMaterias]  m ON h.Mat_Id = m.Mat_Id
    INNER JOIN [app].[tbSecciones] s ON h.Sec_Id = s.Sec_Id
    WHERE  p.Pla_EsEliminado = 0 AND p.Hor_Id = @Hor_Id
    ORDER BY p.Pla_Semana;
END
GO

IF OBJECT_ID('[app].[PR_tbPlanClases_Find]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbPlanClases_Find]
GO
CREATE PROCEDURE [app].[PR_tbPlanClases_Find]
    @Pla_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Pla_Id, p.Hor_Id, p.Pla_Semana, p.Pla_Tema,
           p.Pla_Objetivos, p.Pla_Recursos, p.Pla_Estado
    FROM   [app].[tbPlanClases] p
    WHERE  p.Pla_Id = @Pla_Id AND p.Pla_EsEliminado = 0;
END
GO

IF OBJECT_ID('[app].[PR_tbPlanClases_Insert]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbPlanClases_Insert]
GO
CREATE PROCEDURE [app].[PR_tbPlanClases_Insert]
    @Hor_Id              INT,
    @Pla_Semana          SMALLINT,
    @Pla_Tema            NVARCHAR(200),
    @Pla_Objetivos       NVARCHAR(MAX)  = NULL,
    @Pla_Recursos        NVARCHAR(300)  = NULL,
    @Pla_UsuarioRegistra INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO [app].[tbPlanClases]
            (Hor_Id, Pla_Semana, Pla_Tema, Pla_Objetivos, Pla_Recursos, Pla_UsuarioRegistra, Pla_FechaRegistra)
        VALUES
            (@Hor_Id, @Pla_Semana, @Pla_Tema, @Pla_Objetivos, @Pla_Recursos, @Pla_UsuarioRegistra, GETDATE());
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH
        SELECT 0 AS CodeResult;
    END CATCH
END
GO

IF OBJECT_ID('[app].[PR_tbPlanClases_Update]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbPlanClases_Update]
GO
CREATE PROCEDURE [app].[PR_tbPlanClases_Update]
    @Pla_Id              INT,
    @Pla_Semana          SMALLINT,
    @Pla_Tema            NVARCHAR(200),
    @Pla_Objetivos       NVARCHAR(MAX)  = NULL,
    @Pla_Recursos        NVARCHAR(300)  = NULL,
    @Pla_Estado          NVARCHAR(20),
    @Pla_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE [app].[tbPlanClases]
        SET    Pla_Semana          = @Pla_Semana,
               Pla_Tema            = @Pla_Tema,
               Pla_Objetivos       = @Pla_Objetivos,
               Pla_Recursos        = @Pla_Recursos,
               Pla_Estado          = @Pla_Estado,
               Pla_UsuarioModifica = @Pla_UsuarioModifica,
               Pla_FechaModifica   = GETDATE()
        WHERE  Pla_Id = @Pla_Id;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH
        SELECT 0 AS CodeResult;
    END CATCH
END
GO

IF OBJECT_ID('[app].[PR_tbPlanClases_Delete]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbPlanClases_Delete]
GO
CREATE PROCEDURE [app].[PR_tbPlanClases_Delete]
    @Pla_Id              INT,
    @Pla_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE [app].[tbPlanClases]
        SET    Pla_EsEliminado     = 1,
               Pla_UsuarioModifica = @Pla_UsuarioModifica,
               Pla_FechaModifica   = GETDATE()
        WHERE  Pla_Id = @Pla_Id;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH
        SELECT 0 AS CodeResult;
    END CATCH
END
GO

-- ══════════════════════════════════════════
--  TAREAS Y ENTREGAS
-- ══════════════════════════════════════════

IF OBJECT_ID('[app].[PR_tbTareas_List]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbTareas_List]
GO
CREATE PROCEDURE [app].[PR_tbTareas_List]
    @Hor_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.Tar_Id, t.Hor_Id, t.Tar_Titulo, t.Tar_Descripcion,
           t.Tar_FechaEntrega, t.Tar_Punteo, t.Tar_Estado, t.Tar_FechaRegistra,
           m.Mat_Nombre, s.Sec_Descripcion
    FROM   [app].[tbTareas] t
    INNER JOIN [app].[tbHorarios]  h ON t.Hor_Id = h.Hor_Id
    INNER JOIN [app].[tbMaterias]  m ON h.Mat_Id = m.Mat_Id
    INNER JOIN [app].[tbSecciones] s ON h.Sec_Id = s.Sec_Id
    WHERE  t.Tar_EsEliminado = 0 AND t.Hor_Id = @Hor_Id
    ORDER BY t.Tar_FechaEntrega;
END
GO

IF OBJECT_ID('[app].[PR_tbTareas_Find]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbTareas_Find]
GO
CREATE PROCEDURE [app].[PR_tbTareas_Find]
    @Tar_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.Tar_Id, t.Hor_Id, t.Tar_Titulo, t.Tar_Descripcion,
           t.Tar_FechaEntrega, t.Tar_Punteo, t.Tar_Estado
    FROM   [app].[tbTareas] t
    WHERE  t.Tar_Id = @Tar_Id AND t.Tar_EsEliminado = 0;
END
GO

IF OBJECT_ID('[app].[PR_tbTareas_Insert]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbTareas_Insert]
GO
CREATE PROCEDURE [app].[PR_tbTareas_Insert]
    @Hor_Id              INT,
    @Tar_Titulo          NVARCHAR(200),
    @Tar_Descripcion     NVARCHAR(MAX)  = NULL,
    @Tar_FechaEntrega    DATE,
    @Tar_Punteo          DECIMAL(5,2)   = 100,
    @Tar_UsuarioRegistra INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO [app].[tbTareas]
            (Hor_Id, Tar_Titulo, Tar_Descripcion, Tar_FechaEntrega, Tar_Punteo, Tar_UsuarioRegistra, Tar_FechaRegistra)
        VALUES
            (@Hor_Id, @Tar_Titulo, @Tar_Descripcion, @Tar_FechaEntrega, @Tar_Punteo, @Tar_UsuarioRegistra, GETDATE());
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH
        SELECT 0 AS CodeResult;
    END CATCH
END
GO

IF OBJECT_ID('[app].[PR_tbTareas_Update]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbTareas_Update]
GO
CREATE PROCEDURE [app].[PR_tbTareas_Update]
    @Tar_Id              INT,
    @Tar_Titulo          NVARCHAR(200),
    @Tar_Descripcion     NVARCHAR(MAX)  = NULL,
    @Tar_FechaEntrega    DATE,
    @Tar_Punteo          DECIMAL(5,2),
    @Tar_Estado          NVARCHAR(20),
    @Tar_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE [app].[tbTareas]
        SET    Tar_Titulo          = @Tar_Titulo,
               Tar_Descripcion     = @Tar_Descripcion,
               Tar_FechaEntrega    = @Tar_FechaEntrega,
               Tar_Punteo          = @Tar_Punteo,
               Tar_Estado          = @Tar_Estado,
               Tar_UsuarioModifica = @Tar_UsuarioModifica,
               Tar_FechaModifica   = GETDATE()
        WHERE  Tar_Id = @Tar_Id;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH
        SELECT 0 AS CodeResult;
    END CATCH
END
GO

IF OBJECT_ID('[app].[PR_tbTareas_Delete]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbTareas_Delete]
GO
CREATE PROCEDURE [app].[PR_tbTareas_Delete]
    @Tar_Id              INT,
    @Tar_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE [app].[tbTareas]
        SET    Tar_EsEliminado     = 1,
               Tar_UsuarioModifica = @Tar_UsuarioModifica,
               Tar_FechaModifica   = GETDATE()
        WHERE  Tar_Id = @Tar_Id;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH
        SELECT 0 AS CodeResult;
    END CATCH
END
GO

-- ══════════════════════════════════════════
--  MIS ALUMNOS (DOCENTE)
-- ══════════════════════════════════════════

IF OBJECT_ID('[app].[PR_Docente_MisAlumnos]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Docente_MisAlumnos]
GO
CREATE PROCEDURE [app].[PR_Docente_MisAlumnos]
    @Hor_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Sec_Id INT;
    SELECT @Sec_Id = Sec_Id
    FROM   [app].[tbHorarios]
    WHERE  Hor_Id = @Hor_Id AND Hor_EsEliminado = 0;

    SELECT
        a.Alu_Id,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre, ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        ))) AS NombreCompleto,
        p.Per_Imagen,
        s.Sec_Descripcion
    FROM   [app].[tbAlumnos]   a
    INNER JOIN [app].[tbPersonas]  p ON a.Per_Id = p.Per_Id
    INNER JOIN [app].[tbSecciones] s ON a.Sec_Id = s.Sec_Id
    WHERE  a.Sec_Id = @Sec_Id
    ORDER BY p.Per_ApellidoPaterno, p.Per_PrimerNombre;
END
GO

-- ══════════════════════════════════════════
--  MAPA DE OCUPACIÓN DE AULAS
-- ══════════════════════════════════════════

IF OBJECT_ID('[app].[PR_Aulas_MapaOcupacion]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Aulas_MapaOcupacion]
GO
CREATE PROCEDURE [app].[PR_Aulas_MapaOcupacion]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.Aul_Id,
        a.Aul_Descripcion,
        COUNT(h.Hor_Id)                                                AS Horarios_Total,
        SUM(CASE WHEN h.Hor_Año = YEAR(GETDATE()) THEN 1 ELSE 0 END)  AS HorariosActuales
    FROM   [app].[tbAulas] a
    LEFT JOIN [app].[tbHorarios] h
           ON a.Aul_Id = h.Aul_Id AND h.Hor_EsEliminado = 0
    GROUP BY a.Aul_Id, a.Aul_Descripcion
    ORDER BY HorariosActuales DESC, a.Aul_Descripcion;
END
GO
