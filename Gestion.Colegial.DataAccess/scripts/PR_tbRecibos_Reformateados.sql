USE [DB_GestionColegial];
GO

/* ============================================================================
   FUNCIONES REUTILIZABLES
   ============================================================================ */

-- Función para formatear nombres completos
IF OBJECT_ID('dbo.fn_FormatearNombreCompleto', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_FormatearNombreCompleto;
GO

CREATE FUNCTION dbo.fn_FormatearNombreCompleto (
    @PrimerNombre NVARCHAR(100),
    @SegundoNombre NVARCHAR(100),
    @ApellidoPaterno NVARCHAR(100),
    @ApellidoMaterno NVARCHAR(100)
)
RETURNS NVARCHAR(300)
AS
BEGIN
    DECLARE @NombreCompleto NVARCHAR(300);

    SET @NombreCompleto = LTRIM(RTRIM(
        CONCAT(
            @PrimerNombre,
            ' ',
            ISNULL(@SegundoNombre, ''),
            ' ',
            @ApellidoPaterno,
            ' ',
            ISNULL(@ApellidoMaterno, '')
        )
    ));

    RETURN @NombreCompleto;
END;
GO

/* ============================================================================
   PROCEDIMIENTOS ALMACENADOS - tbRecibos
   ============================================================================ */

-- ============================================================================
-- PR_tbRecibos_List
-- Descripción: Lista todos los recibos con información descriptiva
-- Tipo: LIST - Sin IDs de relaciones, sin auditoría, solo descripciones
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbRecibos_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.Rec_NumeroRecibo,
        r.Rec_FechaEmision,
        r.Rec_RutaArchivo,
        -- Descripción del Alumno del Pago asociado
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno
    FROM
        finanza.tbRecibos r
        INNER JOIN finanza.tbPagos p ON r.Pag_Id = p.Pag_Id
        INNER JOIN app.tbAlumnos a ON p.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
    WHERE
        r.Per_EsEliminado != 1
    ORDER BY
        r.Rec_FechaEmision DESC,
        r.Rec_Id DESC;
END
GO

-- ============================================================================
-- PR_tbRecibos_Find
-- Descripción: Busca un recibo específico por ID con IDs y descripciones
-- Tipo: FIND - Con IDs de relaciones y descripciones, sin auditoría
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbRecibos_Find]
    @Rec_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        -- Campos principales del Recibo
        r.Rec_Id,
        r.Pag_Id,
        r.Rec_NumeroRecibo,
        r.Rec_FechaEmision,
        r.Rec_RutaArchivo,
        -- Descripción del Alumno del Pago asociado
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno
    FROM
        finanza.tbRecibos r
        INNER JOIN finanza.tbPagos p ON r.Pag_Id = p.Pag_Id
        INNER JOIN app.tbAlumnos a ON p.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
    WHERE
        r.Rec_Id = @Rec_Id
        AND r.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbRecibos_Detail
-- Descripción: Obtiene el detalle completo de un recibo incluyendo auditoría
-- Tipo: DETAIL - Con IDs, descripciones y campos de auditoría
-- ============================================================================
IF OBJECT_ID('[finanza].[PR_tbRecibos_Detail]', 'P') IS NOT NULL
    DROP PROCEDURE [finanza].[PR_tbRecibos_Detail];
GO

CREATE PROCEDURE [finanza].[PR_tbRecibos_Detail]
    @Rec_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        -- Campos principales del Recibo
        r.Rec_Id,
        r.Pag_Id,
        r.Rec_NumeroRecibo,
        r.Rec_FechaEmision,
        r.Rec_RutaArchivo,
        -- Descripción del Alumno del Pago asociado
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno,
        -- Campos de Auditoría
        r.Per_EsEliminado,
        r.Per_UsuarioRegistra,
        usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
        r.Per_FechaRegistra,
        r.Per_UsuarioModifica,
        usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
        r.Per_FechaModifica
    FROM
        finanza.tbRecibos r
        INNER JOIN finanza.tbPagos p ON r.Pag_Id = p.Pag_Id
        INNER JOIN app.tbAlumnos a ON p.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
        -- JOINs para auditoría
        LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
            ON r.Per_UsuarioRegistra = usuarioRegistra.Usu_Id
        LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
            ON r.Per_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE
        r.Rec_Id = @Rec_Id
        AND r.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbRecibos_Insert
-- Descripción: Inserta un nuevo recibo
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbRecibos_Insert]
    @Pag_Id int,
    @Rec_NumeroRecibo nvarchar(40),
    @Rec_RutaArchivo nvarchar(260) = NULL,
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO finanza.tbRecibos (
        Pag_Id,
        Rec_NumeroRecibo,
        Rec_RutaArchivo,
        Per_UsuarioRegistra
    )
    VALUES (
        @Pag_Id,
        @Rec_NumeroRecibo,
        @Rec_RutaArchivo,
        @Per_UsuarioRegistra
    );

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO

-- ============================================================================
-- PR_tbRecibos_Update
-- Descripción: Actualiza un recibo existente
-- ============================================================================
IF OBJECT_ID('[finanza].[PR_tbRecibos_Update]', 'P') IS NOT NULL
    DROP PROCEDURE [finanza].[PR_tbRecibos_Update];
GO

CREATE PROCEDURE [finanza].[PR_tbRecibos_Update]
    @Rec_Id int,
    @Pag_Id int,
    @Rec_NumeroRecibo nvarchar(40),
    @Rec_RutaArchivo nvarchar(260) = NULL,
    @Per_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE finanza.tbRecibos
    SET
        Pag_Id = @Pag_Id,
        Rec_NumeroRecibo = @Rec_NumeroRecibo,
        Rec_RutaArchivo = @Rec_RutaArchivo,
        Per_UsuarioModifica = @Per_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE
        Rec_Id = @Rec_Id;
END
GO

-- ============================================================================
-- PR_tbRecibos_Delete
-- Descripción: Eliminación lógica de un recibo
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbRecibos_Delete]
    @Rec_Id int,
    @Per_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE finanza.tbRecibos
    SET
        Per_EsEliminado = 1,
        Per_UsuarioModifica = @Per_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE
        Rec_Id = @Rec_Id;
END
GO

PRINT 'Procedimientos de tbRecibos reformateados exitosamente.';
GO
