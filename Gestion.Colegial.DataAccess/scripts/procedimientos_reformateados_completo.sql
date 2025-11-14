USE [DB_GestionColegial];
GO

/* ============================================================================
   SCRIPT DE PROCEDIMIENTOS REFORMATEADOS

   Este script contiene todos los procedimientos almacenados reformateados
   según las reglas especificadas:

   - LIST: Sin IDs, sin auditoría, solo descripciones
   - FIND: Con IDs y descripciones, sin auditoría
   - DETAIL: Con IDs, descripciones y auditoría completa

   Aplicar LEFT JOIN (no FULL JOIN) para usuarios de auditoría
   Nombres descriptivos en alias AS
   WHERE con != 1 en lugar de = 0
   ============================================================================ */

/* ============================================================================
   PR_tbDescuentos
   ============================================================================ */

-- ============================================================================
-- PR_tbDescuentos_List
-- Tipo: LIST - Sin IDs, sin auditoría, solo descripciones
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbDescuentos_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY des.Des_Descripcion
        ) AS [Fila],
        des.Des_Descripcion,
        des.Des_TipoDescuento,
        des.Des_Valor,
        des.Des_EsActivo
    FROM
        finanza.tbDescuentos des
    WHERE
        des.Per_EsEliminado != 1
    ORDER BY
        des.Des_Descripcion;
END
GO

-- ============================================================================
-- PR_tbDescuentos_Find
-- Tipo: FIND - Con IDs y descripciones, sin auditoría
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbDescuentos_Find]
    @Des_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        des.Des_Id,
        des.Des_Descripcion,
        des.Des_TipoDescuento,
        des.Des_Valor,
        des.Des_EsActivo
    FROM
        finanza.tbDescuentos des
    WHERE
        des.Des_Id = @Des_Id
        AND des.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbDescuentos_Detail
-- Tipo: DETAIL - Con IDs, descripciones y auditoría completa
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbDescuentos_Detail]
    @Des_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        des.Des_Id,
        des.Des_Descripcion,
        des.Des_TipoDescuento,
        des.Des_Valor,
        des.Des_EsActivo,
        -- Campos de auditoría
        des.Per_EsEliminado,
        des.Per_UsuarioRegistra,
        usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
        des.Per_FechaRegistra,
        des.Per_UsuarioModifica,
        usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
        des.Per_FechaModifica
    FROM
        finanza.tbDescuentos des
        -- JOINs para auditoría
        LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
            ON des.Per_UsuarioRegistra = usuarioRegistra.Usu_Id
        LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
            ON des.Per_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE
        des.Des_Id = @Des_Id
        AND des.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbDescuentos_Dropdown
-- Tipo: Dropdown - Solo ID y texto para dropdowns
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbDescuentos_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        des.Des_Id,
        des.Des_Descripcion AS Texto
    FROM
        finanza.tbDescuentos des
    WHERE
        des.Per_EsEliminado != 1
        AND des.Des_EsActivo = 1
    ORDER BY
        des.Des_Descripcion;
END
GO

-- ============================================================================
-- PR_tbDescuentos_Exist
-- Tipo: Exist - Verificar existencia
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbDescuentos_Exist]
    @Des_Descripcion nvarchar(120),
    @Des_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Exists bit = 0;
    DECLARE @Message nvarchar(200) = '';

    IF EXISTS (
        SELECT 1
        FROM finanza.tbDescuentos
        WHERE Des_Descripcion = @Des_Descripcion
          AND Per_EsEliminado != 1
          AND (@Des_Id IS NULL OR Des_Id <> @Des_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe un descuento con esta descripción.';
    END
    ELSE
    BEGIN
        SET @Message = 'El descuento no existe.';
    END

    SELECT @Exists AS [Exists], @Message AS Message;
END
GO

/* ============================================================================
   PR_tbDescuentosAplicados
   ============================================================================ */

-- ============================================================================
-- PR_tbDescuentosAplicados_List
-- Tipo: LIST - Sin IDs, sin auditoría, solo descripciones
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbDescuentosAplicados_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY da.Dap_Fecha DESC, da.Dap_Id DESC
        ) AS [Fila],
        da.Dap_MontoAplicado,
        da.Dap_Fecha,
        -- Descripciones de relaciones
        des.Des_Descripcion AS DescripcionDescuento,
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno
    FROM
        finanza.tbDescuentosAplicados da
        INNER JOIN finanza.tbDescuentos des ON da.Des_Id = des.Des_Id
        INNER JOIN finanza.tbCuentasCobrar cco ON da.Cco_Id = cco.Cco_Id
        INNER JOIN app.tbAlumnos a ON cco.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
    WHERE
        da.Per_EsEliminado != 1
    ORDER BY
        da.Dap_Fecha DESC,
        da.Dap_Id DESC;
END
GO

-- ============================================================================
-- PR_tbDescuentosAplicados_Find
-- Tipo: FIND - Con IDs y descripciones, sin auditoría
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbDescuentosAplicados_Find]
    @Dap_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        da.Dap_Id,
        da.Cco_Id,
        da.Des_Id,
        da.Dap_MontoAplicado,
        da.Dap_Fecha,
        -- Descripciones de relaciones
        des.Des_Descripcion AS DescripcionDescuento,
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno
    FROM
        finanza.tbDescuentosAplicados da
        INNER JOIN finanza.tbDescuentos des ON da.Des_Id = des.Des_Id
        INNER JOIN finanza.tbCuentasCobrar cco ON da.Cco_Id = cco.Cco_Id
        INNER JOIN app.tbAlumnos a ON cco.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
    WHERE
        da.Dap_Id = @Dap_Id
        AND da.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbDescuentosAplicados_Detail
-- Tipo: DETAIL - Con IDs, descripciones y auditoría completa
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbDescuentosAplicados_Detail]
    @Dap_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        da.Dap_Id,
        da.Cco_Id,
        da.Des_Id,
        da.Dap_MontoAplicado,
        da.Dap_Fecha,
        -- Descripciones de relaciones
        des.Des_Descripcion AS DescripcionDescuento,
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno,
        -- Campos de auditoría
        da.Per_EsEliminado,
        da.Per_UsuarioRegistra,
        usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
        da.Per_FechaRegistra,
        da.Per_UsuarioModifica,
        usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
        da.Per_FechaModifica
    FROM
        finanza.tbDescuentosAplicados da
        INNER JOIN finanza.tbDescuentos des ON da.Des_Id = des.Des_Id
        INNER JOIN finanza.tbCuentasCobrar cco ON da.Cco_Id = cco.Cco_Id
        INNER JOIN app.tbAlumnos a ON cco.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
        -- JOINs para auditoría
        LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
            ON da.Per_UsuarioRegistra = usuarioRegistra.Usu_Id
        LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
            ON da.Per_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE
        da.Dap_Id = @Dap_Id
        AND da.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbDescuentosAplicados_Dropdown
-- Tipo: Dropdown - Solo ID y texto para dropdowns
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbDescuentosAplicados_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        da.Dap_Id,
        CONCAT(des.Des_Descripcion, ' - ', FORMAT(da.Dap_MontoAplicado, 'C2')) AS Texto
    FROM
        finanza.tbDescuentosAplicados da
        INNER JOIN finanza.tbDescuentos des ON da.Des_Id = des.Des_Id
    WHERE
        da.Per_EsEliminado != 1
    ORDER BY
        da.Dap_Fecha DESC;
END
GO

-- ============================================================================
-- PR_tbDescuentosAplicados_ListByCuenta
-- Tipo: List especializado - Por cuenta a cobrar
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbDescuentosAplicados_ListByCuenta]
    @Cco_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        da.Dap_MontoAplicado,
        da.Dap_Fecha,
        -- Descripciones de relaciones
        des.Des_Descripcion AS DescripcionDescuento
    FROM
        finanza.tbDescuentosAplicados da
        INNER JOIN finanza.tbDescuentos des ON da.Des_Id = des.Des_Id
    WHERE
        da.Cco_Id = @Cco_Id
        AND da.Per_EsEliminado != 1
    ORDER BY
        da.Dap_Fecha DESC;
END
GO

/* ============================================================================
   PR_tbEstadosPago
   ============================================================================ */

-- ============================================================================
-- PR_tbEstadosPago_Find
-- Tipo: FIND - Con IDs y descripciones, sin auditoría
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbEstadosPago_Find]
    @Epa_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ep.Epa_Id,
        ep.Epa_Descripcion
    FROM
        finanza.tbEstadosPago ep
    WHERE
        ep.Epa_Id = @Epa_Id
        AND ep.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbEstadosPago_Detail
-- Tipo: DETAIL - Con IDs, descripciones y auditoría completa
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbEstadosPago_Detail]
    @Epa_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ep.Epa_Id,
        ep.Epa_Descripcion,
        -- Campos de auditoría
        ep.Per_EsEliminado,
        ep.Per_UsuarioRegistra,
        usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
        ep.Per_FechaRegistra,
        ep.Per_UsuarioModifica,
        usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
        ep.Per_FechaModifica
    FROM
        finanza.tbEstadosPago ep
        -- JOINs para auditoría
        LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
            ON ep.Per_UsuarioRegistra = usuarioRegistra.Usu_Id
        LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
            ON ep.Per_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE
        ep.Epa_Id = @Epa_Id
        AND ep.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbEstadosPago_Dropdown
-- Tipo: Dropdown - Solo ID y texto para dropdowns
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbEstadosPago_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ep.Epa_Id,
        ep.Epa_Descripcion AS Texto
    FROM
        finanza.tbEstadosPago ep
    WHERE
        ep.Per_EsEliminado != 1
    ORDER BY
        ep.Epa_Descripcion;
END
GO

-- ============================================================================
-- PR_tbEstadosPago_Exist
-- Tipo: Exist - Verificar existencia
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbEstadosPago_Exist]
    @Epa_Descripcion nvarchar(50),
    @Epa_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Exists bit = 0;
    DECLARE @Message nvarchar(200) = '';

    IF EXISTS (
        SELECT 1
        FROM finanza.tbEstadosPago
        WHERE Epa_Descripcion = @Epa_Descripcion
          AND Per_EsEliminado != 1
          AND (@Epa_Id IS NULL OR Epa_Id <> @Epa_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe un estado de pago con esta descripción.';
    END
    ELSE
    BEGIN
        SET @Message = 'El estado de pago no existe.';
    END

    SELECT @Exists AS [Exists], @Message AS Message;
END
GO

/* ============================================================================
   PR_tbFormasPago
   ============================================================================ */

-- ============================================================================
-- PR_tbFormasPago_Dropdown
-- Tipo: Dropdown - Solo ID y texto para dropdowns
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbFormasPago_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        fp.Fpa_Id,
        fp.Fpa_Descripcion AS Texto
    FROM
        finanza.tbFormasPago fp
    WHERE
        fp.Per_EsEliminado != 1
        AND fp.Fpa_EsActivo = 1
    ORDER BY
        fp.Fpa_Descripcion;
END
GO

-- ============================================================================
-- PR_tbFormasPago_Exist
-- Tipo: Exist - Verificar existencia
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbFormasPago_Exist]
    @Fpa_Descripcion nvarchar(80),
    @Fpa_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Exists bit = 0;
    DECLARE @Message nvarchar(200) = '';

    IF EXISTS (
        SELECT 1
        FROM finanza.tbFormasPago
        WHERE Fpa_Descripcion = @Fpa_Descripcion
          AND Per_EsEliminado != 1
          AND (@Fpa_Id IS NULL OR Fpa_Id <> @Fpa_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe una forma de pago con esta descripción.';
    END
    ELSE
    BEGIN
        SET @Message = 'La forma de pago no existe.';
    END

    SELECT @Exists AS [Exists], @Message AS Message;
END
GO

/* ============================================================================
   PR_tbMoratorias
   ============================================================================ */

-- ============================================================================
-- PR_tbMoratorias_List
-- Tipo: LIST - Sin IDs, sin auditoría, solo descripciones
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbMoratorias_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY m.Mor_FechaAplicacion DESC, m.Mor_Id DESC
        ) AS [Fila],
        m.Mor_MontoMora,
        m.Mor_FechaAplicacion,
        m.Mor_Observaciones,
        -- Descripciones de relaciones
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno
    FROM
        finanza.tbMoratorias m
        INNER JOIN finanza.tbCuentasCobrar cco ON m.Cco_Id = cco.Cco_Id
        INNER JOIN app.tbAlumnos a ON cco.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
    WHERE
        m.Per_EsEliminado != 1
    ORDER BY
        m.Mor_FechaAplicacion DESC,
        m.Mor_Id DESC;
END
GO

-- ============================================================================
-- PR_tbMoratorias_Find
-- Tipo: FIND - Con IDs y descripciones, sin auditoría
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbMoratorias_Find]
    @Mor_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.Mor_Id,
        m.Cco_Id,
        m.Mor_MontoMora,
        m.Mor_FechaAplicacion,
        m.Mor_Observaciones,
        -- Descripciones de relaciones
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno
    FROM
        finanza.tbMoratorias m
        INNER JOIN finanza.tbCuentasCobrar cco ON m.Cco_Id = cco.Cco_Id
        INNER JOIN app.tbAlumnos a ON cco.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
    WHERE
        m.Mor_Id = @Mor_Id
        AND m.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbMoratorias_Detail
-- Tipo: DETAIL - Con IDs, descripciones y auditoría completa
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbMoratorias_Detail]
    @Mor_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.Mor_Id,
        m.Cco_Id,
        m.Mor_MontoMora,
        m.Mor_FechaAplicacion,
        m.Mor_Observaciones,
        -- Descripciones de relaciones
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno,
        -- Campos de auditoría
        m.Per_EsEliminado,
        m.Per_UsuarioRegistra,
        usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
        m.Per_FechaRegistra,
        m.Per_UsuarioModifica,
        usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
        m.Per_FechaModifica
    FROM
        finanza.tbMoratorias m
        INNER JOIN finanza.tbCuentasCobrar cco ON m.Cco_Id = cco.Cco_Id
        INNER JOIN app.tbAlumnos a ON cco.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
        -- JOINs para auditoría
        LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
            ON m.Per_UsuarioRegistra = usuarioRegistra.Usu_Id
        LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
            ON m.Per_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE
        m.Mor_Id = @Mor_Id
        AND m.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbMoratorias_Dropdown
-- Tipo: Dropdown - Solo ID y texto para dropdowns
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbMoratorias_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.Mor_Id,
        CONCAT(FORMAT(m.Mor_MontoMora, 'C2'), ' - ', FORMAT(m.Mor_FechaAplicacion, 'dd/MM/yyyy')) AS Texto
    FROM
        finanza.tbMoratorias m
    WHERE
        m.Per_EsEliminado != 1
    ORDER BY
        m.Mor_FechaAplicacion DESC;
END
GO

-- ============================================================================
-- PR_tbMoratorias_ListByCuenta
-- Tipo: List especializado - Por cuenta a cobrar
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbMoratorias_ListByCuenta]
    @Cco_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.Mor_MontoMora,
        m.Mor_FechaAplicacion,
        m.Mor_Observaciones
    FROM
        finanza.tbMoratorias m
    WHERE
        m.Cco_Id = @Cco_Id
        AND m.Per_EsEliminado != 1
    ORDER BY
        m.Mor_FechaAplicacion DESC;
END
GO

/* ============================================================================
   PR_tbPagos
   ============================================================================ */

-- ============================================================================
-- PR_tbPagos_List
-- Tipo: LIST - Sin IDs, sin auditoría, solo descripciones
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbPagos_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY p.Pag_FechaPago DESC, p.Pag_Id DESC
        ) AS [Fila],
        p.Pag_MontoTotal,
        p.Pag_FechaPago,
        p.Pag_NumeroReferencia,
        p.Pag_Observaciones,
        -- Descripciones de relaciones
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno,
        fp.Fpa_Descripcion AS DescripcionFormaPago,
        dbo.fn_FormatearNombreCompleto(
            perEnc.Per_PrimerNombre,
            perEnc.Per_SegundoNombre,
            perEnc.Per_ApellidoPaterno,
            perEnc.Per_ApellidoMaterno
        ) AS NombreCompletoEncargado,
        usuPago.Usu_Name AS NombreUsuarioRegistraPago
    FROM
        finanza.tbPagos p
        INNER JOIN finanza.tbFormasPago fp ON p.Fpa_Id = fp.Fpa_Id
        INNER JOIN app.tbAlumnos a ON p.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
        LEFT JOIN app.tbEncargados enc ON p.Enc_Id = enc.Enc_Id
        LEFT JOIN app.tbPersonas perEnc ON enc.Per_Id = perEnc.Per_Id
        INNER JOIN seguridad.tbUsuarios usuPago ON p.Usu_Id = usuPago.Usu_Id
    WHERE
        p.Per_EsEliminado != 1
    ORDER BY
        p.Pag_FechaPago DESC,
        p.Pag_Id DESC;
END
GO

-- ============================================================================
-- PR_tbPagos_Find
-- Tipo: FIND - Con IDs y descripciones, sin auditoría
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbPagos_Find]
    @Pag_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.Pag_Id,
        p.Alu_Id,
        p.Enc_Id,
        p.Fpa_Id,
        p.Usu_Id,
        p.Pag_MontoTotal,
        p.Pag_FechaPago,
        p.Pag_NumeroReferencia,
        p.Pag_Observaciones,
        -- Descripciones de relaciones
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno,
        fp.Fpa_Descripcion AS DescripcionFormaPago,
        dbo.fn_FormatearNombreCompleto(
            perEnc.Per_PrimerNombre,
            perEnc.Per_SegundoNombre,
            perEnc.Per_ApellidoPaterno,
            perEnc.Per_ApellidoMaterno
        ) AS NombreCompletoEncargado,
        usuPago.Usu_Name AS NombreUsuarioRegistraPago
    FROM
        finanza.tbPagos p
        INNER JOIN finanza.tbFormasPago fp ON p.Fpa_Id = fp.Fpa_Id
        INNER JOIN app.tbAlumnos a ON p.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
        LEFT JOIN app.tbEncargados enc ON p.Enc_Id = enc.Enc_Id
        LEFT JOIN app.tbPersonas perEnc ON enc.Per_Id = perEnc.Per_Id
        INNER JOIN seguridad.tbUsuarios usuPago ON p.Usu_Id = usuPago.Usu_Id
    WHERE
        p.Pag_Id = @Pag_Id
        AND p.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbPagos_Detail
-- Tipo: DETAIL - Con IDs, descripciones y auditoría completa
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbPagos_Detail]
    @Pag_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.Pag_Id,
        p.Alu_Id,
        p.Enc_Id,
        p.Fpa_Id,
        p.Usu_Id,
        p.Pag_MontoTotal,
        p.Pag_FechaPago,
        p.Pag_NumeroReferencia,
        p.Pag_Observaciones,
        -- Descripciones de relaciones
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno,
        fp.Fpa_Descripcion AS DescripcionFormaPago,
        dbo.fn_FormatearNombreCompleto(
            perEnc.Per_PrimerNombre,
            perEnc.Per_SegundoNombre,
            perEnc.Per_ApellidoPaterno,
            perEnc.Per_ApellidoMaterno
        ) AS NombreCompletoEncargado,
        usuPago.Usu_Name AS NombreUsuarioRegistraPago,
        -- Campos de auditoría
        p.Per_EsEliminado,
        p.Per_UsuarioRegistra,
        usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
        p.Per_FechaRegistra,
        p.Per_UsuarioModifica,
        usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
        p.Per_FechaModifica
    FROM
        finanza.tbPagos p
        INNER JOIN finanza.tbFormasPago fp ON p.Fpa_Id = fp.Fpa_Id
        INNER JOIN app.tbAlumnos a ON p.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
        LEFT JOIN app.tbEncargados enc ON p.Enc_Id = enc.Enc_Id
        LEFT JOIN app.tbPersonas perEnc ON enc.Per_Id = perEnc.Per_Id
        INNER JOIN seguridad.tbUsuarios usuPago ON p.Usu_Id = usuPago.Usu_Id
        -- JOINs para auditoría
        LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
            ON p.Per_UsuarioRegistra = usuarioRegistra.Usu_Id
        LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
            ON p.Per_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE
        p.Pag_Id = @Pag_Id
        AND p.Per_EsEliminado != 1;
END
GO

/* ============================================================================
   PR_tbPagosDetalle
   ============================================================================ */

-- ============================================================================
-- PR_tbPagosDetalle_List
-- Tipo: LIST - Sin IDs, sin auditoría, solo descripciones
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbPagosDetalle_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY pd.Pde_Id DESC
        ) AS [Fila],
        pd.Pde_MontoAplicado,
        -- Descripciones de relaciones
        dbo.fn_FormatearNombreCompleto(
            per.Per_PrimerNombre,
            per.Per_SegundoNombre,
            per.Per_ApellidoPaterno,
            per.Per_ApellidoMaterno
        ) AS NombreCompletoAlumno,
        cp.Cpa_Descripcion AS DescripcionConceptoPago
    FROM
        finanza.tbPagosDetalle pd
        INNER JOIN finanza.tbPagos p ON pd.Pag_Id = p.Pag_Id
        INNER JOIN finanza.tbCuentasCobrar cco ON pd.Cco_Id = cco.Cco_Id
        INNER JOIN finanza.tbConceptosPago cp ON cco.Cpa_Id = cp.Cpa_Id
        INNER JOIN app.tbAlumnos a ON p.Alu_Id = a.Alu_Id
        INNER JOIN app.tbPersonas per ON a.Per_Id = per.Per_Id
    WHERE
        pd.Per_EsEliminado != 1
    ORDER BY
        pd.Pde_Id DESC;
END
GO

/* ============================================================================
   PR_tbTarifas
   ============================================================================ */

-- ============================================================================
-- PR_tbTarifas_List
-- Tipo: LIST - Sin IDs, sin auditoría, solo descripciones
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbTarifas_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY t.Tar_AnioVigencia DESC, t.Tar_Id DESC
        ) AS [Fila],
        t.Tar_Monto,
        t.Tar_AnioVigencia,
        t.Tar_EsActivo,
        -- Descripciones de relaciones
        cp.Cpa_Descripcion AS DescripcionConceptoPago
    FROM
        finanza.tbTarifas t
        INNER JOIN finanza.tbConceptosPago cp ON t.Cpa_Id = cp.Cpa_Id
    WHERE
        t.Per_EsEliminado != 1
    ORDER BY
        t.Tar_AnioVigencia DESC,
        t.Tar_Id DESC;
END
GO

-- ============================================================================
-- PR_tbTarifas_Find
-- Tipo: FIND - Con IDs y descripciones, sin auditoría
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbTarifas_Find]
    @Tar_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        t.Tar_Id,
        t.Cpa_Id,
        t.Niv_Id,
        t.Tar_Monto,
        t.Tar_AnioVigencia,
        t.Tar_EsActivo,
        -- Descripciones de relaciones
        cp.Cpa_Descripcion AS DescripcionConceptoPago
    FROM
        finanza.tbTarifas t
        INNER JOIN finanza.tbConceptosPago cp ON t.Cpa_Id = cp.Cpa_Id
    WHERE
        t.Tar_Id = @Tar_Id
        AND t.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbTarifas_Detail
-- Tipo: DETAIL - Con IDs, descripciones y auditoría completa
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbTarifas_Detail]
    @Tar_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        t.Tar_Id,
        t.Cpa_Id,
        t.Niv_Id,
        t.Tar_Monto,
        t.Tar_AnioVigencia,
        t.Tar_EsActivo,
        -- Descripciones de relaciones
        cp.Cpa_Descripcion AS DescripcionConceptoPago,
        -- Campos de auditoría
        t.Per_EsEliminado,
        t.Per_UsuarioRegistra,
        usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
        t.Per_FechaRegistra,
        t.Per_UsuarioModifica,
        usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
        t.Per_FechaModifica
    FROM
        finanza.tbTarifas t
        INNER JOIN finanza.tbConceptosPago cp ON t.Cpa_Id = cp.Cpa_Id
        -- JOINs para auditoría
        LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
            ON t.Per_UsuarioRegistra = usuarioRegistra.Usu_Id
        LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
            ON t.Per_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE
        t.Tar_Id = @Tar_Id
        AND t.Per_EsEliminado != 1;
END
GO

-- ============================================================================
-- PR_tbTarifas_Dropdown
-- Tipo: Dropdown - Solo ID y texto para dropdowns
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbTarifas_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        t.Tar_Id,
        CONCAT(cp.Cpa_Descripcion, ' - ', FORMAT(t.Tar_Monto, 'C2'), ' (', t.Tar_AnioVigencia, ')') AS Texto
    FROM
        finanza.tbTarifas t
        INNER JOIN finanza.tbConceptosPago cp ON t.Cpa_Id = cp.Cpa_Id
    WHERE
        t.Per_EsEliminado != 1
        AND t.Tar_EsActivo = 1
    ORDER BY
        t.Tar_AnioVigencia DESC,
        cp.Cpa_Descripcion;
END
GO

-- ============================================================================
-- PR_tbTarifas_Exist
-- Tipo: Exist - Verificar existencia
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbTarifas_Exist]
    @Cpa_Id int,
    @Niv_Id int = NULL,
    @Tar_AnioVigencia int,
    @Tar_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Exists bit = 0;
    DECLARE @Message nvarchar(200) = '';

    IF EXISTS (
        SELECT 1
        FROM finanza.tbTarifas
        WHERE Cpa_Id = @Cpa_Id
          AND (@Niv_Id IS NULL OR Niv_Id = @Niv_Id)
          AND Tar_AnioVigencia = @Tar_AnioVigencia
          AND Per_EsEliminado != 1
          AND (@Tar_Id IS NULL OR Tar_Id <> @Tar_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe una tarifa para este concepto, nivel y año de vigencia.';
    END
    ELSE
    BEGIN
        SET @Message = 'La tarifa no existe.';
    END

    SELECT @Exists AS [Exists], @Message AS Message;
END
GO

-- ============================================================================
-- PR_tbTarifas_GetByConceptoAndNivel
-- Tipo: Búsqueda especializada - Por concepto y nivel
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbTarifas_GetByConceptoAndNivel]
    @Cpa_Id int,
    @Niv_Id int = NULL,
    @Tar_AnioVigencia int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AnioActual int = YEAR(GETDATE());
    IF @Tar_AnioVigencia IS NULL
        SET @Tar_AnioVigencia = @AnioActual;

    SELECT
        t.Tar_Id,
        t.Cpa_Id,
        t.Niv_Id,
        t.Tar_Monto,
        t.Tar_AnioVigencia,
        t.Tar_EsActivo,
        -- Descripciones de relaciones
        cp.Cpa_Descripcion AS DescripcionConceptoPago
    FROM
        finanza.tbTarifas t
        INNER JOIN finanza.tbConceptosPago cp ON t.Cpa_Id = cp.Cpa_Id
    WHERE
        t.Cpa_Id = @Cpa_Id
        AND (@Niv_Id IS NULL OR t.Niv_Id = @Niv_Id)
        AND t.Tar_AnioVigencia = @Tar_AnioVigencia
        AND t.Per_EsEliminado != 1
        AND t.Tar_EsActivo = 1
    ORDER BY
        t.Tar_Monto DESC;
END
GO

PRINT 'Procedimientos reformateados aplicados exitosamente.';
GO
