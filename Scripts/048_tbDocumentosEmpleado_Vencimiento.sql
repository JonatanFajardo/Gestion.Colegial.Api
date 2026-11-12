-- =====================================================================
-- Script 048: app.tbDocumentosEmpleado — creación + vencimiento (C7)
-- Motivo: RRHH no puede detectar documentos VENCIDOS ni por vencer
--         porque la tabla real de documentos de empleado nunca se creó
--         (PR_Empleados_CumplimientoDocumentos usaba una lista hardcoded
--         con EsEntregado siempre NULL — ver Script 021, líneas 82-100).
--
-- Crea/reemplaza:
--   [TABLA] app.tbDocumentosEmpleado          — si no existe (idempotente)
--   app.PR_Empleados_CumplimientoDocumentos   — ALTER: ahora hace LEFT JOIN
--                                                real + calcula EstadoVencimiento
--   app.PR_DocumentosEmpleado_MarcarEntregado — upsert (marcar entregado +
--                                                fecha de vencimiento)
--
-- Convención: idempotente (DROP IF EXISTS + CREATE). Terminar con GO.
-- NO EJECUTAR contra la DB — script para revisión. Aplica quien administra
-- la DB real ((localdb)\MSSQLLocalDB → DB_GestionColegial).
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- Tabla: app.tbDocumentosEmpleado
-- Checklist de documentos por empleado (análoga a tbDocumentosAlumno).
-- Documento queda como texto libre (sin catálogo, ver hallazgo #9 de
-- docs/database-schema.md) — fuera de alcance de este cambio.
-- Doc_FechaVencimiento es NULL para documentos que no vencen (ej. CV).
-- ──────────────────────────────────────────────────────────────────────
IF NOT EXISTS (
    SELECT * FROM sys.tables
    WHERE name = 'tbDocumentosEmpleado'
      AND schema_id = SCHEMA_ID('app')
)
BEGIN
    CREATE TABLE [app].[tbDocumentosEmpleado] (
        [DocEmp_Id]              INT          IDENTITY(1,1) NOT NULL,
        [Emp_Id]                 INT          NOT NULL,
        [Documento]              VARCHAR(100) NOT NULL,
        [EsEntregado]            BIT          NOT NULL CONSTRAINT [DF_DocEmp_EsEntregado] DEFAULT (0),
        [FechaEntrega]           DATE         NULL,
        [Doc_FechaVencimiento]   DATETIME     NULL,
        [Observacion]            VARCHAR(200) NULL,
        [DocEmp_EsEliminado]     BIT          NOT NULL CONSTRAINT [DF_DocEmp_EsEliminado]     DEFAULT (0),
        [DocEmp_UsuarioRegistra] INT          NOT NULL,
        [DocEmp_FechaRegistra]   DATETIME     NOT NULL CONSTRAINT [DF_DocEmp_FechaRegistra]   DEFAULT (GETDATE()),
        [DocEmp_UsuarioModifica] INT          NULL,
        [DocEmp_FechaModifica]   DATETIME     NULL,
        CONSTRAINT [PK_tbDocumentosEmpleado]  PRIMARY KEY CLUSTERED ([DocEmp_Id] ASC),
        CONSTRAINT [FK_DocEmpleado_Empleados] FOREIGN KEY ([Emp_Id]) REFERENCES [app].[tbEmpleados]([Emp_Id]),
        CONSTRAINT [UQ_DocEmpleado_EmpDocumento] UNIQUE ([Emp_Id], [Documento])
    );
    PRINT 'Tabla app.tbDocumentosEmpleado creada.';
END
ELSE
BEGIN
    -- Tabla ya existe (posible en un ambiente donde se creó fuera de este
    -- repo de scripts): sólo agregar la columna de vencimiento si falta.
    IF NOT EXISTS (
        SELECT * FROM sys.columns
        WHERE object_id = OBJECT_ID('[app].[tbDocumentosEmpleado]')
          AND name = 'Doc_FechaVencimiento'
    )
    BEGIN
        ALTER TABLE [app].[tbDocumentosEmpleado]
            ADD [Doc_FechaVencimiento] DATETIME NULL;
        PRINT 'Columna Doc_FechaVencimiento agregada a app.tbDocumentosEmpleado.';
    END
    ELSE
        PRINT 'app.tbDocumentosEmpleado ya existe con Doc_FechaVencimiento.';
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- app.PR_Empleados_CumplimientoDocumentos (ALTER)
-- Ahora hace LEFT JOIN real contra app.tbDocumentosEmpleado y calcula
-- EstadoVencimiento: 'vigente' | 'por-vencer' (<=30 días) | 'vencido' |
-- 'sin-vencimiento' (documento entregado sin fecha de vencimiento, ej.
-- CV) | 'pendiente' (no entregado aún).
-- Retorna: Emp_Id, Emp_Codigo, NombreCompleto, Per_Identidad, Documento,
--          EsObligatorio, EsEntregado, FechaEntrega, Doc_FechaVencimiento,
--          EstadoVencimiento, Observacion, DocEmp_Id
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_Empleados_CumplimientoDocumentos]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Empleados_CumplimientoDocumentos];
GO
CREATE PROCEDURE [app].[PR_Empleados_CumplimientoDocumentos]
    @Emp_Id INT = NULL     -- NULL = todos los empleados activos
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

    -- Lista fija de documentos requeridos para empleados.
    -- (Sigue hardcoded: no existe catálogo tipo tbTiposDocumento para
    --  empleados — hallazgo #9 de docs/database-schema.md, fuera de
    --  alcance de este cambio.)
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
        de.DocEmp_Id,
        ISNULL(de.EsEntregado, 0)   AS EsEntregado,
        de.FechaEntrega,
        de.Doc_FechaVencimiento,
        CASE
            WHEN de.EsEntregado IS NULL OR de.EsEntregado = 0
                THEN 'pendiente'
            WHEN de.Doc_FechaVencimiento IS NULL
                THEN 'sin-vencimiento'
            WHEN CAST(de.Doc_FechaVencimiento AS DATE) < @Hoy
                THEN 'vencido'
            WHEN CAST(de.Doc_FechaVencimiento AS DATE) <= DATEADD(DAY, 30, @Hoy)
                THEN 'por-vencer'
            ELSE 'vigente'
        END                         AS EstadoVencimiento,
        de.Observacion
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
    CROSS JOIN @DocsRequeridos dr
    LEFT JOIN [app].[tbDocumentosEmpleado] de
        ON de.Emp_Id = e.Emp_Id
       AND de.Documento = dr.Documento
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
-- app.PR_DocumentosEmpleado_MarcarEntregado
-- Upsert: marca (o desmarca) un documento de empleado como entregado,
-- con fecha de entrega, fecha de vencimiento y observación opcionales.
-- Mismo patrón que app.PR_tbDocumentosAlumno_Update (Script 007).
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_DocumentosEmpleado_MarcarEntregado]') IS NOT NULL
    DROP PROCEDURE [app].[PR_DocumentosEmpleado_MarcarEntregado];
GO
CREATE PROCEDURE [app].[PR_DocumentosEmpleado_MarcarEntregado]
    @Emp_Id                 INT,
    @Documento               VARCHAR(100),
    @EsEntregado             BIT,
    @FechaEntrega            DATE      = NULL,
    @Doc_FechaVencimiento    DATETIME  = NULL,
    @Observacion             VARCHAR(200) = NULL,
    @UsuarioRegistra         INT
AS
BEGIN
    SET NOCOUNT ON;
    -- NOTA: la tabla real es minimalista (sin columnas de auditoría/soft-delete),
    -- por eso este SP no toca DocEmp_UsuarioRegistra/Modifica ni DocEmp_EsEliminado.
    -- @UsuarioRegistra se conserva en la firma por compatibilidad con la capa API.
    IF EXISTS (
        SELECT 1 FROM [app].[tbDocumentosEmpleado]
        WHERE Emp_Id = @Emp_Id AND Documento = @Documento
    )
    BEGIN
        UPDATE [app].[tbDocumentosEmpleado]
        SET EsEntregado             = @EsEntregado,
            FechaEntrega             = @FechaEntrega,
            Doc_FechaVencimiento     = @Doc_FechaVencimiento,
            Observacion              = @Observacion
        WHERE Emp_Id = @Emp_Id AND Documento = @Documento;
    END
    ELSE
    BEGIN
        INSERT INTO [app].[tbDocumentosEmpleado]
            (Emp_Id, Documento, EsEntregado, FechaEntrega, Doc_FechaVencimiento, Observacion)
        VALUES
            (@Emp_Id, @Documento, @EsEntregado, @FechaEntrega, @Doc_FechaVencimiento, @Observacion);
    END
END
GO
