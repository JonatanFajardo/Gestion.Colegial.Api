USE DB_GestionColegial;
GO

-- ============================================================
-- Script 026: Mensajes a Encargados
-- Tabla: app.tbMensajes
-- SPs: PR_Mensajes_List, PR_Mensajes_Find, PR_Mensajes_Insert, PR_Mensajes_Delete
-- ============================================================

-- Tabla de mensajes
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'tbMensajes' AND schema_id = SCHEMA_ID('app'))
BEGIN
    CREATE TABLE app.tbMensajes (
        Msg_Id          INT IDENTITY(1,1) PRIMARY KEY,
        Msg_Asunto      NVARCHAR(200)     NOT NULL,
        Msg_Contenido   NVARCHAR(MAX)     NOT NULL,
        Msg_FechaEnvio  DATETIME          NOT NULL DEFAULT GETDATE(),
        Msg_Estado      NVARCHAR(20)      NOT NULL DEFAULT 'Enviado', -- Enviado/Leido
        Alu_Id          INT               NOT NULL,
        Enc_Id          INT               NULL,  -- NULL = todos los encargados del alumno
        UsuarioEnvia    INT               NOT NULL,
        EsEliminado     BIT               NOT NULL DEFAULT 0
    );
    PRINT 'Tabla app.tbMensajes creada.';
END
ELSE PRINT 'app.tbMensajes ya existe.';
GO

-- SP: Listar mensajes
CREATE OR ALTER PROCEDURE app.PR_Mensajes_List
    @UsuarioId  INT = NULL,
    @Alu_Id     INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        m.Msg_Id,
        m.Msg_Asunto,
        LEFT(m.Msg_Contenido, 100)  AS Msg_Resumen,
        CONVERT(VARCHAR(20), m.Msg_FechaEnvio, 120) AS Msg_FechaEnvio,
        m.Msg_Estado,
        m.Alu_Id,
        m.UsuarioEnvia,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre, ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        )))                         AS Alu_NombreCompleto
    FROM app.tbMensajes m
    INNER JOIN app.tbAlumnos a  ON m.Alu_Id = a.Alu_Id
    INNER JOIN app.tbPersonas p ON a.Per_Id  = p.Per_Id
    WHERE m.EsEliminado = 0
      AND (@Alu_Id    IS NULL OR m.Alu_Id      = @Alu_Id)
      AND (@UsuarioId IS NULL OR m.UsuarioEnvia = @UsuarioId)
    ORDER BY m.Msg_FechaEnvio DESC;
END
GO

-- SP: Detalle de un mensaje
CREATE OR ALTER PROCEDURE app.PR_Mensajes_Find
    @Msg_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        m.Msg_Id,
        m.Msg_Asunto,
        m.Msg_Contenido,
        CONVERT(VARCHAR(20), m.Msg_FechaEnvio, 120) AS Msg_FechaEnvio,
        m.Msg_Estado,
        m.Alu_Id,
        m.UsuarioEnvia,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre, ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        )))                         AS Alu_NombreCompleto
    FROM app.tbMensajes m
    INNER JOIN app.tbAlumnos a  ON m.Alu_Id = a.Alu_Id
    INNER JOIN app.tbPersonas p ON a.Per_Id  = p.Per_Id
    WHERE m.Msg_Id = @Msg_Id AND m.EsEliminado = 0;
END
GO

-- SP: Insertar mensaje
CREATE OR ALTER PROCEDURE app.PR_Mensajes_Insert
    @Msg_Asunto     NVARCHAR(200),
    @Msg_Contenido  NVARCHAR(MAX),
    @Alu_Id         INT,
    @UsuarioEnvia   INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO app.tbMensajes (Msg_Asunto, Msg_Contenido, Alu_Id, UsuarioEnvia)
    VALUES (@Msg_Asunto, @Msg_Contenido, @Alu_Id, @UsuarioEnvia);
    SELECT SCOPE_IDENTITY() AS Msg_Id;
END
GO

-- SP: Eliminar mensaje (soft delete)
CREATE OR ALTER PROCEDURE app.PR_Mensajes_Delete
    @Msg_Id          INT,
    @UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE app.tbMensajes SET EsEliminado = 1 WHERE Msg_Id = @Msg_Id;
END
GO

PRINT 'Script 026 ejecutado correctamente.';
GO
