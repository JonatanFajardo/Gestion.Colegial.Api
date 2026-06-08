-- =====================================================================
-- Script 021: SPs Fase 5 — RRHH restantes
-- Crea/reemplaza:
--   [TABLA]  app.tbAnuncios              — si no existe (idempotente)
--   app.PR_Empleados_CumplimientoDocumentos — documentos entregados/pendientes por empleado
--   app.PR_CentroAnuncios_List           — lista anuncios/comunicados activos
--   app.PR_CentroAnuncios_Insert         — insertar nuevo anuncio
--   app.PR_CentroAnuncios_Delete         — eliminar lógico de anuncio
-- Convención: idempotente (DROP IF EXISTS + CREATE). Terminar con GO.
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- Verificar existencia previa de los SPs
-- SELECT SCHEMA_NAME(schema_id)+'.'+name FROM sys.objects
-- WHERE type='P' AND name IN ('PR_Empleados_CumplimientoDocumentos',
--   'PR_CentroAnuncios_List','PR_CentroAnuncios_Insert','PR_CentroAnuncios_Delete')
-- ──────────────────────────────────────────────────────────────────────

-- ──────────────────────────────────────────────────────────────────────
-- Tabla: app.tbAnuncios
-- Repositorio de comunicados/anuncios institucionales.
-- ──────────────────────────────────────────────────────────────────────
IF NOT EXISTS (
    SELECT * FROM sys.tables
    WHERE name = 'tbAnuncios'
      AND schema_id = SCHEMA_ID('app')
)
BEGIN
    CREATE TABLE [app].[tbAnuncios] (
        [Anu_Id]               INT           IDENTITY(1,1) NOT NULL,
        [Anu_Titulo]           NVARCHAR(200) NOT NULL,
        [Anu_Contenido]        NVARCHAR(MAX) NOT NULL,
        [Anu_FechaPublicacion] DATE          NOT NULL CONSTRAINT [DF_Anu_FechaPublicacion] DEFAULT (CAST(GETDATE() AS DATE)),
        [Anu_FechaExpiracion]  DATE          NULL,
        [Anu_Activo]           BIT           NOT NULL CONSTRAINT [DF_Anu_Activo]           DEFAULT (1),
        [Anu_EsEliminado]      BIT           NOT NULL CONSTRAINT [DF_Anu_EsEliminado]      DEFAULT (0),
        [Anu_UsuarioRegistra]  INT           NOT NULL,
        [Anu_FechaRegistra]    DATETIME      NOT NULL CONSTRAINT [DF_Anu_FechaRegistra]    DEFAULT (GETDATE()),
        [Anu_UsuarioModifica]  INT           NULL,
        [Anu_FechaModifica]    DATETIME      NULL,
        CONSTRAINT [PK_tbAnuncios] PRIMARY KEY CLUSTERED ([Anu_Id] ASC)
    );
    PRINT 'Tabla app.tbAnuncios creada.';
END
ELSE
    PRINT 'app.tbAnuncios ya existe.';
GO

-- ──────────────────────────────────────────────────────────────────────
-- app.PR_Empleados_CumplimientoDocumentos
-- Por empleado, lista qué documentos tiene entregados y cuáles faltan.
-- Usa una lista fija de documentos requeridos (hardcoded) ya que no
-- existe tabla de documentos de empleados equivalente a tbDocumentosAlumno.
-- Retorna: Emp_Id, NombreCompleto, Documento, EsEntregado (0/1), FechaEntrega
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_Empleados_CumplimientoDocumentos]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Empleados_CumplimientoDocumentos];
GO
CREATE PROCEDURE [app].[PR_Empleados_CumplimientoDocumentos]
    @Emp_Id INT = NULL     -- NULL = todos los empleados activos
AS
BEGIN
    SET NOCOUNT ON;

    -- Lista fija de documentos requeridos para empleados
    DECLARE @DocsRequeridos TABLE (Documento VARCHAR(100), EsObligatorio BIT);
    INSERT INTO @DocsRequeridos (Documento, EsObligatorio) VALUES
        ('DPI / Cédula de identidad',          1),
        ('Título o diploma académico',          1),
        ('Contrato de trabajo firmado',         1),
        ('Antecedentes penales y policiales',   1),
        ('Hoja de vida actualizada (CV)',        1),
        ('Foto tamaño cédula',                  1),
        ('Número de IGSS / Seguridad social',   1),
        ('Constancia de colegiatura (si aplica)',0),
        ('Referencia bancaria / cuenta de pago',0);

    -- Tabla temporal para resultado
    -- Nota: no existe tbDocumentosEmpleado, por lo que EsEntregado siempre
    --       vendrá como NULL hasta que se cree esa tabla.
    --       Si en el futuro se agrega app.tbDocumentosEmpleado(Emp_Id, Documento, EsEntregado, FechaEntrega),
    --       reemplazar el LEFT JOIN correspondiente.
    SELECT
        e.Emp_Id,
        e.Emp_Codigo,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre, ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        )))                         AS NombreCompleto,
        p.Per_Identidad,
        dr.Documento,
        dr.EsObligatorio,
        -- Cuando exista tbDocumentosEmpleado, quitar el CAST NULL y activar el JOIN
        CAST(NULL AS BIT)           AS EsEntregado,
        CAST(NULL AS DATE)          AS FechaEntrega,
        CAST(NULL AS VARCHAR(200))  AS Observacion
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
    CROSS JOIN @DocsRequeridos dr
    WHERE p.Per_EsEliminado = 0
      AND (@Emp_Id IS NULL OR e.Emp_Id = @Emp_Id)
    ORDER BY
        p.Per_ApellidoPaterno,
        p.Per_PrimerNombre,
        dr.EsObligatorio DESC,
        dr.Documento;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- app.PR_CentroAnuncios_List
-- Lista anuncios/comunicados activos (no expirados y no eliminados).
-- Parámetro @SoloActivos BIT: 1=solo vigentes, 0=todos (incluso expirados)
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_CentroAnuncios_List]') IS NOT NULL
    DROP PROCEDURE [app].[PR_CentroAnuncios_List];
GO
CREATE PROCEDURE [app].[PR_CentroAnuncios_List]
    @SoloActivos BIT = 1   -- 1 = solo vigentes; 0 = todos (excepto eliminados)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

    SELECT
        a.Anu_Id,
        a.Anu_Titulo,
        a.Anu_Contenido,
        a.Anu_FechaPublicacion,
        a.Anu_FechaExpiracion,
        a.Anu_Activo,
        -- Vigente: activo y no expirado (o sin fecha de expiración)
        CASE
            WHEN a.Anu_Activo = 1
             AND (a.Anu_FechaExpiracion IS NULL OR a.Anu_FechaExpiracion >= @Hoy)
            THEN 1 ELSE 0
        END                         AS EsVigente,
        a.Anu_FechaRegistra,
        -- Usuario que publicó
        u.Usu_Name                  AS PublicadoPor
    FROM [app].[tbAnuncios] a
    LEFT JOIN [Seguridad].[tbUsuarios] u ON a.Anu_UsuarioRegistra = u.Usu_Id
    WHERE a.Anu_EsEliminado = 0
      AND (
            @SoloActivos = 0
            OR (
                a.Anu_Activo = 1
                AND (a.Anu_FechaExpiracion IS NULL OR a.Anu_FechaExpiracion >= @Hoy)
               )
          )
    ORDER BY a.Anu_FechaPublicacion DESC;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- app.PR_CentroAnuncios_Insert
-- Inserta un nuevo anuncio/comunicado.
-- Retorna Anu_Id del nuevo registro.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_CentroAnuncios_Insert]') IS NOT NULL
    DROP PROCEDURE [app].[PR_CentroAnuncios_Insert];
GO
CREATE PROCEDURE [app].[PR_CentroAnuncios_Insert]
    @Anu_Titulo           NVARCHAR(200),
    @Anu_Contenido        NVARCHAR(MAX),
    @Anu_FechaPublicacion DATE         = NULL,   -- NULL = hoy
    @Anu_FechaExpiracion  DATE         = NULL,
    @Anu_UsuarioRegistra  INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Anu_FechaPublicacion IS NULL
            SET @Anu_FechaPublicacion = CAST(GETDATE() AS DATE);

        INSERT INTO [app].[tbAnuncios]
            ([Anu_Titulo], [Anu_Contenido], [Anu_FechaPublicacion],
             [Anu_FechaExpiracion], [Anu_Activo], [Anu_EsEliminado],
             [Anu_UsuarioRegistra], [Anu_FechaRegistra])
        VALUES
            (@Anu_Titulo, @Anu_Contenido, @Anu_FechaPublicacion,
             @Anu_FechaExpiracion, 1, 0,
             @Anu_UsuarioRegistra, GETDATE());

        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS Anu_Id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS Anu_Id;
        THROW;
    END CATCH
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- app.PR_CentroAnuncios_Delete
-- Eliminación lógica de un anuncio (Anu_EsEliminado = 1).
-- Retorna: 1 = eliminado, 0 = no encontrado.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_CentroAnuncios_Delete]') IS NOT NULL
    DROP PROCEDURE [app].[PR_CentroAnuncios_Delete];
GO
CREATE PROCEDURE [app].[PR_CentroAnuncios_Delete]
    @Anu_Id              INT,
    @Anu_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [app].[tbAnuncios]
    SET    [Anu_EsEliminado]    = 1,
           [Anu_Activo]         = 0,
           [Anu_UsuarioModifica]= @Anu_UsuarioModifica,
           [Anu_FechaModifica]  = GETDATE()
    WHERE  [Anu_Id] = @Anu_Id
      AND  [Anu_EsEliminado] = 0;

    SELECT @@ROWCOUNT AS Afectados;
END
GO
