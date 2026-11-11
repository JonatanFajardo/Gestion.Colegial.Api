-- =====================================================================
-- Script 052: Año Lectivo como ENTIDAD (hueco #1 — capa multi-año)
-- Contexto: hoy el año es solo un valor suelto en app.tbConfiguracion
--           (clave 'anio_lectivo_actual'='2026'). Este script lo eleva a
--           entidad real con ciclo de vida, y agrega la clave
--           'anio_lectivo_activo_id' que apunta al Ani_Id activo.
-- Crea:
--   app.tbAnioLectivo                 — la entidad.
--   seed del año 2026 (Abierto) desde el valor de configuración.
--   clave config 'anio_lectivo_activo_id'.
--   app.PR_tbAnioLectivo_List         — lista años (+ estado desc + EsActual).
--   app.PR_tbAnioLectivo_Find         — un año por Ani_Id.
--   app.PR_tbAnioLectivo_Insert       — alta, devuelve NewId.
--   app.PR_tbAnioLectivo_Update       — modifica.
--   app.PR_tbAnioLectivo_Delete       — baja lógica (Ani_EsEliminado=1).
--   app.PR_tbAnioLectivo_SetActivo    — marca el año de trabajo (config).
--   app.PR_tbAnioLectivo_Activo       — devuelve el año activo.
-- Ciclo de vida (Ani_Estado): 1 Borrador · 2 Programado · 3 Abierto ·
--                             4 Cerrando · 5 Cerrado · 6 Archivado.
-- Convención: idempotente (IF EXISTS + DROP/CREATE). Baja lógica, nunca físico.
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- Tabla app.tbAnioLectivo
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[tbAnioLectivo]') IS NULL
BEGIN
    CREATE TABLE [app].[tbAnioLectivo]
    (
        [Ani_Id]             INT            IDENTITY(1,1) NOT NULL,
        [Ani_Anio]           INT            NOT NULL,
        [Ani_Nombre]         VARCHAR(20)    NOT NULL,
        [Ani_FechaInicio]    DATE           NULL,
        [Ani_FechaFin]       DATE           NULL,
        [Ani_Estado]         TINYINT        NOT NULL CONSTRAINT DF_tbAnioLectivo_Estado      DEFAULT (1),
        [Ani_EsActivo]       BIT            NOT NULL CONSTRAINT DF_tbAnioLectivo_EsActivo    DEFAULT (1),
        [Ani_EsEliminado]    BIT            NOT NULL CONSTRAINT DF_tbAnioLectivo_EsEliminado DEFAULT (0),
        [Ani_UsuarioRegistra] INT           NULL,
        [Ani_FechaRegistra]  DATETIME       NOT NULL CONSTRAINT DF_tbAnioLectivo_FechaReg    DEFAULT (GETDATE()),
        [Ani_UsuarioModifica] INT           NULL,
        [Ani_FechaModifica]  DATETIME       NULL,
        CONSTRAINT [PK_tbAnioLectivo] PRIMARY KEY CLUSTERED ([Ani_Id] ASC),
        CONSTRAINT [UQ_tbAnioLectivo_Anio] UNIQUE ([Ani_Anio])
    );
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- Seed: el año en curso (toma el valor de 'anio_lectivo_actual' o 2026)
-- ──────────────────────────────────────────────────────────────────────
DECLARE @anioActual INT = TRY_CONVERT(INT, (
    SELECT TOP 1 Con_Valor FROM [app].[tbConfiguracion] WHERE Con_Clave = 'anio_lectivo_actual'
));
SET @anioActual = ISNULL(@anioActual, 2026);

IF NOT EXISTS (SELECT 1 FROM [app].[tbAnioLectivo] WHERE Ani_Anio = @anioActual)
BEGIN
    INSERT INTO [app].[tbAnioLectivo]
        (Ani_Anio, Ani_Nombre, Ani_FechaInicio, Ani_FechaFin, Ani_Estado, Ani_EsActivo, Ani_EsEliminado, Ani_UsuarioRegistra)
    VALUES
        (@anioActual, CAST(@anioActual AS VARCHAR(10)),
         DATEFROMPARTS(@anioActual, 1, 1), DATEFROMPARTS(@anioActual, 12, 31),
         3 /*Abierto*/, 1, 0, 1);
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- Clave de configuración: año de trabajo activo (apunta al Ani_Id)
-- ──────────────────────────────────────────────────────────────────────
DECLARE @aniId INT = (
    SELECT TOP 1 Ani_Id FROM [app].[tbAnioLectivo]
    WHERE Ani_EsEliminado = 0
    ORDER BY Ani_Anio DESC
);

IF NOT EXISTS (SELECT 1 FROM [app].[tbConfiguracion] WHERE Con_Clave = 'anio_lectivo_activo_id')
BEGIN
    INSERT INTO [app].[tbConfiguracion] (Con_Clave, Con_Valor, Con_Descripcion, Con_Grupo, Con_Tipo)
    VALUES ('anio_lectivo_activo_id', CAST(@aniId AS VARCHAR(10)),
            'Id del año lectivo de trabajo activo', 'Académico', 'numero');
END
ELSE
BEGIN
    UPDATE [app].[tbConfiguracion] SET Con_Valor = CAST(@aniId AS VARCHAR(10))
    WHERE Con_Clave = 'anio_lectivo_activo_id';
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbAnioLectivo_List
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbAnioLectivo_List]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbAnioLectivo_List]
GO
CREATE PROCEDURE [app].[PR_tbAnioLectivo_List]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @activoId INT = TRY_CONVERT(INT, (
        SELECT TOP 1 Con_Valor FROM [app].[tbConfiguracion] WHERE Con_Clave = 'anio_lectivo_activo_id'
    ));

    SELECT
        a.Ani_Id,
        a.Ani_Anio,
        a.Ani_Nombre,
        a.Ani_FechaInicio,
        a.Ani_FechaFin,
        a.Ani_Estado,
        CASE a.Ani_Estado
            WHEN 1 THEN 'Borrador'
            WHEN 2 THEN 'Programado'
            WHEN 3 THEN 'Abierto'
            WHEN 4 THEN 'Cerrando'
            WHEN 5 THEN 'Cerrado'
            WHEN 6 THEN 'Archivado'
            ELSE 'Desconocido'
        END                                         AS Ani_EstadoDescripcion,
        a.Ani_EsActivo,
        CAST(CASE WHEN a.Ani_Id = @activoId THEN 1 ELSE 0 END AS BIT) AS Ani_EsActual
    FROM    [app].[tbAnioLectivo] a
    WHERE   a.Ani_EsEliminado = 0
    ORDER BY a.Ani_Anio DESC;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbAnioLectivo_Find
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbAnioLectivo_Find]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbAnioLectivo_Find]
GO
CREATE PROCEDURE [app].[PR_tbAnioLectivo_Find]
    @Ani_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Ani_Id,
        Ani_Anio,
        Ani_Nombre,
        Ani_FechaInicio,
        Ani_FechaFin,
        Ani_Estado,
        Ani_EsActivo
    FROM    [app].[tbAnioLectivo]
    WHERE   Ani_Id = @Ani_Id
        AND Ani_EsEliminado = 0;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbAnioLectivo_Insert
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbAnioLectivo_Insert]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbAnioLectivo_Insert]
GO
CREATE PROCEDURE [app].[PR_tbAnioLectivo_Insert]
    @Ani_Anio             INT,
    @Ani_Nombre           VARCHAR(20),
    @Ani_FechaInicio      DATE = NULL,
    @Ani_FechaFin         DATE = NULL,
    @Ani_Estado           TINYINT = 1,
    @Ani_UsuarioRegistra  INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [app].[tbAnioLectivo]
        (Ani_Anio, Ani_Nombre, Ani_FechaInicio, Ani_FechaFin, Ani_Estado,
         Ani_EsActivo, Ani_EsEliminado, Ani_UsuarioRegistra, Ani_FechaRegistra)
    VALUES
        (@Ani_Anio, @Ani_Nombre, @Ani_FechaInicio, @Ani_FechaFin, @Ani_Estado,
         1, 0, @Ani_UsuarioRegistra, GETDATE());

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbAnioLectivo_Update
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbAnioLectivo_Update]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbAnioLectivo_Update]
GO
CREATE PROCEDURE [app].[PR_tbAnioLectivo_Update]
    @Ani_Id               INT,
    @Ani_Anio             INT,
    @Ani_Nombre           VARCHAR(20),
    @Ani_FechaInicio      DATE = NULL,
    @Ani_FechaFin         DATE = NULL,
    @Ani_Estado           TINYINT,
    @Ani_UsuarioModifica  INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE  [app].[tbAnioLectivo]
    SET     Ani_Anio             = @Ani_Anio,
            Ani_Nombre           = @Ani_Nombre,
            Ani_FechaInicio      = @Ani_FechaInicio,
            Ani_FechaFin         = @Ani_FechaFin,
            Ani_Estado           = @Ani_Estado,
            Ani_UsuarioModifica  = @Ani_UsuarioModifica,
            Ani_FechaModifica    = GETDATE()
    WHERE   Ani_Id = @Ani_Id;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbAnioLectivo_Delete  (baja lógica)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbAnioLectivo_Delete]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbAnioLectivo_Delete]
GO
CREATE PROCEDURE [app].[PR_tbAnioLectivo_Delete]
    @Ani_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE  [app].[tbAnioLectivo]
    SET     Ani_EsEliminado = 1
    WHERE   Ani_Id = @Ani_Id;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbAnioLectivo_SetActivo  (marca el año de trabajo en config)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbAnioLectivo_SetActivo]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbAnioLectivo_SetActivo]
GO
CREATE PROCEDURE [app].[PR_tbAnioLectivo_SetActivo]
    @Ani_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [app].[tbAnioLectivo] WHERE Ani_Id = @Ani_Id AND Ani_EsEliminado = 0)
    BEGIN
        RAISERROR('El año lectivo no existe o está eliminado.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [app].[tbConfiguracion] WHERE Con_Clave = 'anio_lectivo_activo_id')
        UPDATE [app].[tbConfiguracion] SET Con_Valor = CAST(@Ani_Id AS VARCHAR(10)), FechaModifica = GETDATE()
        WHERE Con_Clave = 'anio_lectivo_activo_id';
    ELSE
        INSERT INTO [app].[tbConfiguracion] (Con_Clave, Con_Valor, Con_Descripcion, Con_Grupo, Con_Tipo)
        VALUES ('anio_lectivo_activo_id', CAST(@Ani_Id AS VARCHAR(10)), 'Id del año lectivo de trabajo activo', 'Académico', 'numero');

    -- Sincroniza también la clave legacy para compatibilidad.
    UPDATE [app].[tbConfiguracion]
    SET    Con_Valor = CAST((SELECT Ani_Anio FROM [app].[tbAnioLectivo] WHERE Ani_Id = @Ani_Id) AS VARCHAR(10)),
           FechaModifica = GETDATE()
    WHERE  Con_Clave = 'anio_lectivo_actual';

    SELECT @Ani_Id AS Ani_Id;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbAnioLectivo_Activo  (devuelve el año de trabajo activo)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbAnioLectivo_Activo]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbAnioLectivo_Activo]
GO
CREATE PROCEDURE [app].[PR_tbAnioLectivo_Activo]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @activoId INT = TRY_CONVERT(INT, (
        SELECT TOP 1 Con_Valor FROM [app].[tbConfiguracion] WHERE Con_Clave = 'anio_lectivo_activo_id'
    ));

    SELECT TOP 1
        Ani_Id, Ani_Anio, Ani_Nombre, Ani_FechaInicio, Ani_FechaFin, Ani_Estado, Ani_EsActivo
    FROM    [app].[tbAnioLectivo]
    WHERE   Ani_EsEliminado = 0
        AND (@activoId IS NULL OR Ani_Id = @activoId)
    ORDER BY CASE WHEN Ani_Id = @activoId THEN 0 ELSE 1 END, Ani_Anio DESC;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_tbAnioLectivo_Exist  (valida año duplicado; @value = el año como texto)
-- Devuelve la fila coincidente para que el UI compare Ids ([Remote]).
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_tbAnioLectivo_Exist]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbAnioLectivo_Exist]
GO
CREATE PROCEDURE [app].[PR_tbAnioLectivo_Exist]
    @value VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        Ani_Id, Ani_Anio, Ani_Nombre, Ani_FechaInicio, Ani_FechaFin, Ani_Estado, Ani_EsActivo
    FROM    [app].[tbAnioLectivo]
    WHERE   Ani_EsEliminado = 0
        AND Ani_Anio = TRY_CONVERT(INT, @value);
END
GO
