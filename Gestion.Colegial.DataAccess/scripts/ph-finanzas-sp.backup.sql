USE [DB_GestionColegial]
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
   PROCEDIMIENTOS ALMACENADOS
   ============================================================================ */

/****** Object:  StoredProcedure [finanza].[PR_tbConceptosPago_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbConceptosPago_Delete]
    @Cpa_Id int,
    @Per_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbConceptosPago
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Per_UsuarioModifica,
        Per_FechaModifica = sysdatetime()
    WHERE Cpa_Id = @Cpa_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbConceptosPago_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbConceptosPago_Detail]
    @Cpa_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT cp.*, COUNT(t.Tar_Id) AS CantTarifas
    FROM finanza.tbConceptosPago cp
    LEFT JOIN finanza.tbTarifas t ON t.Cpa_Id = cp.Cpa_Id AND t.Per_EsEliminado = 0
    WHERE cp.Cpa_Id = @Cpa_Id AND cp.Per_EsEliminado = 0
    GROUP BY cp.Cpa_Id, cp.Cpa_Descripcion, cp.Cpa_EsRecurrente, cp.Cpa_EsObligatorio, cp.Cpa_EsActivo,
             cp.Per_EsEliminado, cp.Per_UsuarioRegistra, cp.Per_FechaRegistra, cp.Per_UsuarioModifica, cp.Per_FechaModifica;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbConceptosPago_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbConceptosPago_Find]
    @Cpa_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbConceptosPago
    WHERE Cpa_Id = @Cpa_Id AND Per_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbConceptosPago_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbConceptosPago_Insert]
    @Cpa_Descripcion   nvarchar(120),
    @Cpa_EsRecurrente  bit,
    @Cpa_EsObligatorio bit,
    @Cpa_EsActivo      bit,
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo,
                                     Per_UsuarioRegistra)
    VALUES (@Cpa_Descripcion, @Cpa_EsRecurrente, @Cpa_EsObligatorio, @Cpa_EsActivo, @Per_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbConceptosPago_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbConceptosPago_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Cpa_Id, Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo,
           Per_EsEliminado, Per_UsuarioRegistra, Per_FechaRegistra, Per_UsuarioModifica, Per_FechaModifica
    FROM finanza.tbConceptosPago
    WHERE Per_EsEliminado = 0
    ORDER BY Cpa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbCuentasCobrar_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbCuentasCobrar_Delete]
    @Cco_Id int,
    @Per_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbCuentasCobrar
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Per_UsuarioModifica,
        Per_FechaModifica = sysdatetime()
    WHERE Cco_Id = @Cco_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbCuentasCobrar_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbCuentasCobrar_Detail]
    @Cco_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT cco.*, cp.Cpa_Descripcion, epa.Epa_Descripcion,
           ISNULL(SUM(pd.Pde_MontoAplicado),0) AS TotalPagado
    FROM finanza.tbCuentasCobrar cco
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = cco.Cpa_Id
    INNER JOIN finanza.tbEstadosPago epa ON epa.Epa_Id = cco.Epa_Id
    LEFT  JOIN finanza.tbPagosDetalle pd ON pd.Cco_Id = cco.Cco_Id AND pd.Per_EsEliminado = 0
    WHERE cco.Cco_Id = @Cco_Id
    GROUP BY cco.Cco_Id, cco.Alu_Id, cco.Cpa_Id, cco.Tar_Id, cco.Cco_MontoOriginal, cco.Cco_MontoDescuento,
             cco.Cco_MontoMora, cco.Cco_MontoTotal, cco.Cco_MontoPendiente, cco.Cco_FechaEmision, cco.Cco_FechaVencimiento,
             cco.Epa_Id, cco.Cco_Observaciones, cco.Per_EsEliminado, cco.Per_UsuarioRegistra, cco.Per_FechaRegistra,
             cco.Per_UsuarioModifica, cco.Per_FechaModifica, cp.Cpa_Descripcion, epa.Epa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbCuentasCobrar_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbCuentasCobrar_Find]
    @Cco_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM finanza.tbCuentasCobrar WHERE Cco_Id = @Cco_Id AND Per_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbCuentasCobrar_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbCuentasCobrar_Insert]
    @Alu_Id int,
    @Cpa_Id int,
    @Tar_Id int = NULL,
    @Cco_MontoOriginal decimal(18,2),
    @Cco_MontoDescuento decimal(18,2) = 0,
    @Cco_MontoMora decimal(18,2) = 0,
    @Cco_MontoTotal decimal(18,2),
    @Cco_MontoPendiente decimal(18,2),
    @Cco_FechaEmision date,
    @Cco_FechaVencimiento date,
    @Epa_Id int,
    @Cco_Observaciones nvarchar(300) = NULL,
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbCuentasCobrar (
        Alu_Id, Cpa_Id, Tar_Id, Cco_MontoOriginal, Cco_MontoDescuento, Cco_MontoMora,
        Cco_MontoTotal, Cco_MontoPendiente, Cco_FechaEmision, Cco_FechaVencimiento,
        Epa_Id, Cco_Observaciones, Per_UsuarioRegistra)
    VALUES (
        @Alu_Id, @Cpa_Id, @Tar_Id, @Cco_MontoOriginal, @Cco_MontoDescuento, @Cco_MontoMora,
        @Cco_MontoTotal, @Cco_MontoPendiente, @Cco_FechaEmision, @Cco_FechaVencimiento,
        @Epa_Id, @Cco_Observaciones, @Per_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbCuentasCobrar_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbCuentasCobrar_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT cco.Cco_Id, cco.Alu_Id, cco.Cpa_Id, cco.Tar_Id,
           cco.Cco_MontoOriginal, cco.Cco_MontoDescuento, cco.Cco_MontoMora,
           cco.Cco_MontoTotal, cco.Cco_MontoPendiente,
           cco.Cco_FechaEmision, cco.Cco_FechaVencimiento, cco.Epa_Id,
           cp.Cpa_Descripcion, epa.Epa_Descripcion,
           cco.Per_EsEliminado, cco.Per_UsuarioRegistra, cco.Per_FechaRegistra,
           cco.Per_UsuarioModifica, cco.Per_FechaModifica
    FROM finanza.tbCuentasCobrar cco
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = cco.Cpa_Id
    INNER JOIN finanza.tbEstadosPago epa ON epa.Epa_Id = cco.Epa_Id
    WHERE cco.Per_EsEliminado = 0
    ORDER BY cco.Cco_FechaVencimiento DESC, cco.Cco_Id DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentos_Delete]
    @Des_Id int,
    @Des_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbDescuentos
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Des_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE Des_Id = @Des_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentos_Detail]
    @Des_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.*, COUNT(da.Dap_Id) AS CantidadAplicaciones
    FROM finanza.tbDescuentos d
    LEFT JOIN finanza.tbDescuentosAplicados da ON da.Des_Id = d.Des_Id AND da.Per_EsEliminado = 0
    WHERE d.Des_Id = @Des_Id AND d.Per_EsEliminado = 0
    GROUP BY d.Des_Id, d.Des_Descripcion, d.Des_TipoDescuento, d.Des_Valor, d.Des_EsActivo,
             d.Per_EsEliminado, d.Per_UsuarioRegistra, d.Per_FechaRegistra,
             d.Per_UsuarioModifica, d.Per_FechaModifica;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Dropdown]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentos_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Des_Id,
           CONCAT(Des_Descripcion, ' (',
                  CASE Des_TipoDescuento
                      WHEN 'P' THEN CAST(Des_Valor AS nvarchar) + '%'
                      ELSE 'L.' + CAST(Des_Valor AS nvarchar)
                  END, ')') AS Texto
    FROM finanza.tbDescuentos
    WHERE Per_EsEliminado = 0 AND Des_EsActivo = 1
    ORDER BY Des_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Exist]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentos_Exist]
    @Des_Descripcion nvarchar(120),
    @Des_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Exists bit = 0;
    DECLARE @Message nvarchar(200) = '';

    IF EXISTS (
        SELECT 1 FROM finanza.tbDescuentos
        WHERE Des_Descripcion = @Des_Descripcion
          AND Per_EsEliminado = 0
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

    -- CORREGIDO: Usar corchetes para palabra reservada
    SELECT @Exists AS [Exists], @Message AS Message;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentos_Find]
    @Des_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbDescuentos
    WHERE Des_Id = @Des_Id AND Per_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentos_Insert]
    @Des_Descripcion nvarchar(120),
    @Des_TipoDescuento char(1),
    @Des_Valor decimal(18,2),
    @Des_EsActivo bit,
    @Des_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Per_UsuarioRegistra)
    VALUES (@Des_Descripcion, @Des_TipoDescuento, @Des_Valor, @Des_EsActivo, @Des_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentos_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Des_Id, Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo,
           Per_EsEliminado, Per_UsuarioRegistra, Per_FechaRegistra,
           Per_UsuarioModifica, Per_FechaModifica
    FROM finanza.tbDescuentos
    WHERE Per_EsEliminado = 0
    ORDER BY Des_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Update]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentos_Update]
    @Des_Id int,
    @Des_Descripcion nvarchar(120),
    @Des_TipoDescuento char(1),
    @Des_Valor decimal(18,2),
    @Des_EsActivo bit,
    @Des_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbDescuentos
    SET Des_Descripcion = @Des_Descripcion,
        Des_TipoDescuento = @Des_TipoDescuento,
        Des_Valor = @Des_Valor,
        Des_EsActivo = @Des_EsActivo,
        Per_UsuarioModifica = @Des_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE Des_Id = @Des_Id;

    SELECT @Des_Id AS UpdatedId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentosAplicados_Delete]
    @Dap_Id int,
    @Dap_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbDescuentosAplicados
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Dap_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE Dap_Id = @Dap_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentosAplicados_Detail]
    @Dap_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT da.*, d.Des_Descripcion, d.Des_TipoDescuento, d.Des_Valor,
           cc.Cco_MontoOriginal, cc.Cco_MontoTotal
    FROM finanza.tbDescuentosAplicados da
    INNER JOIN finanza.tbDescuentos d ON d.Des_Id = da.Des_Id
    INNER JOIN finanza.tbCuentasCobrar cc ON cc.Cco_Id = da.Cco_Id
    WHERE da.Dap_Id = @Dap_Id AND da.Per_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_Dropdown]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentosAplicados_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT da.Dap_Id,
           CONCAT('Desc. #', da.Dap_Id, ' - ', d.Des_Descripcion, ' - L.', da.Dap_MontoAplicado) AS Texto
    FROM finanza.tbDescuentosAplicados da
    INNER JOIN finanza.tbDescuentos d ON d.Des_Id = da.Des_Id
    WHERE da.Per_EsEliminado = 0
    ORDER BY da.Per_FechaRegistra DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentosAplicados_Find]
    @Dap_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbDescuentosAplicados
    WHERE Dap_Id = @Dap_Id AND Per_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentosAplicados_Insert]
    @Cco_Id int,
    @Des_Id int,
    @Dap_MontoAplicado decimal(18,2),
    @Dap_Justificacion nvarchar(300),
    @Dap_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbDescuentosAplicados (Cco_Id, Des_Id, Dap_MontoAplicado, Dap_Justificacion, Per_UsuarioRegistra)
    VALUES (@Cco_Id, @Des_Id, @Dap_MontoAplicado, @Dap_Justificacion, @Dap_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentosAplicados_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT da.Dap_Id, da.Cco_Id, da.Des_Id, da.Dap_MontoAplicado, da.Dap_Justificacion,
           da.Per_EsEliminado, da.Per_UsuarioRegistra, da.Per_FechaRegistra,
           da.Per_UsuarioModifica, da.Per_FechaModifica,
           d.Des_Descripcion, d.Des_TipoDescuento, d.Des_Valor
    FROM finanza.tbDescuentosAplicados da
    INNER JOIN finanza.tbDescuentos d ON d.Des_Id = da.Des_Id
    WHERE da.Per_EsEliminado = 0
    ORDER BY da.Per_FechaRegistra DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_ListByCuenta]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentosAplicados_ListByCuenta]
    @Cco_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT da.*, d.Des_Descripcion, d.Des_TipoDescuento, d.Des_Valor
    FROM finanza.tbDescuentosAplicados da
    INNER JOIN finanza.tbDescuentos d ON d.Des_Id = da.Des_Id
    WHERE da.Cco_Id = @Cco_Id AND da.Per_EsEliminado = 0
    ORDER BY da.Per_FechaRegistra DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_Update]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbDescuentosAplicados_Update]
    @Dap_Id int,
    @Cco_Id int,
    @Des_Id int,
    @Dap_MontoAplicado decimal(18,2),
    @Dap_Justificacion nvarchar(300),
    @Dap_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbDescuentosAplicados
    SET Cco_Id = @Cco_Id,
        Des_Id = @Des_Id,
        Dap_MontoAplicado = @Dap_MontoAplicado,
        Dap_Justificacion = @Dap_Justificacion,
        Per_UsuarioModifica = @Dap_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE Dap_Id = @Dap_Id;

    SELECT @Dap_Id AS UpdatedId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbEstadosPago_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbEstadosPago_Delete]
    @Epa_Id int,
    @Epa_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbEstadosPago
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Epa_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE Epa_Id = @Epa_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbEstadosPago_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbEstadosPago_Detail]
    @Epa_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ep.*, COUNT(cc.Cco_Id) AS CantidadCuentas
    FROM finanza.tbEstadosPago ep
    LEFT JOIN finanza.tbCuentasCobrar cc ON cc.Epa_Id = ep.Epa_Id AND cc.Per_EsEliminado = 0
    WHERE ep.Epa_Id = @Epa_Id AND ep.Per_EsEliminado = 0
    GROUP BY ep.Epa_Id, ep.Epa_Descripcion,
             ep.Per_EsEliminado, ep.Per_UsuarioRegistra, ep.Per_FechaRegistra,
             ep.Per_UsuarioModifica, ep.Per_FechaModifica;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbEstadosPago_Dropdown]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbEstadosPago_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Epa_Id, Epa_Descripcion AS Texto
    FROM finanza.tbEstadosPago
    WHERE Per_EsEliminado = 0
    ORDER BY Epa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbEstadosPago_Exist]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbEstadosPago_Exist]
    @Epa_Descripcion nvarchar(50),
    @Epa_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Exists bit = 0;
    DECLARE @Message nvarchar(200) = '';

    IF EXISTS (
        SELECT 1 FROM finanza.tbEstadosPago
        WHERE Epa_Descripcion = @Epa_Descripcion
          AND Per_EsEliminado = 0
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

    -- CORREGIDO: Usar corchetes para palabra reservada
    SELECT @Exists AS [Exists], @Message AS Message;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbEstadosPago_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbEstadosPago_Find]
    @Epa_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbEstadosPago
    WHERE Epa_Id = @Epa_Id AND Per_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbEstadosPago_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbEstadosPago_Insert]
    @Epa_Descripcion nvarchar(50),
    @Epa_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbEstadosPago (Epa_Descripcion, Per_UsuarioRegistra)
    VALUES (@Epa_Descripcion, @Epa_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbEstadosPago_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbEstadosPago_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Epa_Id, Epa_Descripcion,
           Per_EsEliminado, Per_UsuarioRegistra, Per_FechaRegistra,
           Per_UsuarioModifica, Per_FechaModifica
    FROM finanza.tbEstadosPago
    WHERE Per_EsEliminado = 0
    ORDER BY Epa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbEstadosPago_Update]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbEstadosPago_Update]
    @Epa_Id int,
    @Epa_Descripcion nvarchar(50),
    @Epa_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbEstadosPago
    SET Epa_Descripcion = @Epa_Descripcion,
        Per_UsuarioModifica = @Epa_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE Epa_Id = @Epa_Id;

    SELECT @Epa_Id AS UpdatedId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbFormasPago_Delete]
    @Fpa_Id int,
    @Fpa_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbFormasPago
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Fpa_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE Fpa_Id = @Fpa_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- PR_tbFormasPago_Detail
-- Tipo: DETAIL - Con IDs, descripciones y auditoría completa
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbFormasPago_Detail]
    @Fpa_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        fp.Fpa_Id,
        fp.Fpa_Descripcion,
        fp.Fpa_EsActivo,
        -- Campos de auditoría
        fp.Per_EsEliminado,
        fp.Per_UsuarioRegistra,
        usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
        fp.Per_FechaRegistra,
        fp.Per_UsuarioModifica,
        usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
        fp.Per_FechaModifica
    FROM
        finanza.tbFormasPago fp
        -- JOINs para auditoría
        LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
            ON fp.Per_UsuarioRegistra = usuarioRegistra.Usu_Id
        LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
            ON fp.Per_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE
        fp.Fpa_Id = @Fpa_Id
        AND fp.Per_EsEliminado != 1;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_Dropdown]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbFormasPago_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Fpa_Id, Fpa_Descripcion AS Texto
    FROM finanza.tbFormasPago
    WHERE Per_EsEliminado = 0 AND Fpa_EsActivo = 1
    ORDER BY Fpa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_Exist]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbFormasPago_Exist]
    @Fpa_Descripcion nvarchar(80),
    @Fpa_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Exists bit = 0;
    DECLARE @Message nvarchar(200) = '';

    IF EXISTS (
        SELECT 1 FROM finanza.tbFormasPago
        WHERE Fpa_Descripcion = @Fpa_Descripcion
          AND Per_EsEliminado = 0
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

    -- CORREGIDO: Usar corchetes para palabra reservada
    SELECT @Exists AS [Exists], @Message AS Message;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- PR_tbFormasPago_Find
-- Tipo: FIND - Con IDs y descripciones, sin auditoría
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbFormasPago_Find]
    @Fpa_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        fp.Fpa_Id,
        fp.Fpa_Descripcion,
        fp.Fpa_EsActivo
    FROM
        finanza.tbFormasPago fp
    WHERE
        fp.Fpa_Id = @Fpa_Id
        AND fp.Per_EsEliminado != 1;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbFormasPago_Insert]
    @Fpa_Descripcion nvarchar(80),
    @Fpa_EsActivo bit,
    @Fpa_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbFormasPago (Fpa_Descripcion, Fpa_EsActivo, Per_UsuarioRegistra)
    VALUES (@Fpa_Descripcion, @Fpa_EsActivo, @Fpa_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- PR_tbFormasPago_List
-- Tipo: LIST - Sin IDs, sin auditoría, solo descripciones
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_tbFormasPago_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        fp.Fpa_Descripcion,
        fp.Fpa_EsActivo
    FROM
        finanza.tbFormasPago fp
    WHERE
        fp.Per_EsEliminado != 1
    ORDER BY
        fp.Fpa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_Update]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbFormasPago_Update]
    @Fpa_Id int,
    @Fpa_Descripcion nvarchar(80),
    @Fpa_EsActivo bit,
    @Fpa_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbFormasPago
    SET Fpa_Descripcion = @Fpa_Descripcion,
        Fpa_EsActivo = @Fpa_EsActivo,
        Per_UsuarioModifica = @Fpa_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE Fpa_Id = @Fpa_Id;

    SELECT @Fpa_Id AS UpdatedId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbMoratorias_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbMoratorias_Delete]
    @Mor_Id int,
    @Mor_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbMoratorias
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Mor_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE Mor_Id = @Mor_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbMoratorias_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbMoratorias_Detail]
    @Mor_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.*, cc.Cco_MontoOriginal, cc.Cco_MontoTotal, cc.Cco_FechaVencimiento
    FROM finanza.tbMoratorias m
    INNER JOIN finanza.tbCuentasCobrar cc ON cc.Cco_Id = m.Cco_Id
    WHERE m.Mor_Id = @Mor_Id AND m.Per_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbMoratorias_Dropdown]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbMoratorias_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.Mor_Id,
           CONCAT('Mora #', m.Mor_Id, ' - ', m.Mor_DiasAtraso, ' días - L.', m.Mor_MontoMora) AS Texto
    FROM finanza.tbMoratorias m
    WHERE m.Per_EsEliminado = 0
    ORDER BY m.Mor_FechaCalculo DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbMoratorias_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbMoratorias_Find]
    @Mor_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbMoratorias
    WHERE Mor_Id = @Mor_Id AND Per_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbMoratorias_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbMoratorias_Insert]
    @Cco_Id int,
    @Mor_DiasAtraso int,
    @Mor_Porcentaje decimal(9,4),
    @Mor_MontoMora decimal(18,2),
    @Mor_FechaCalculo date,
    @Mor_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbMoratorias (Cco_Id, Mor_DiasAtraso, Mor_Porcentaje, Mor_MontoMora, Mor_FechaCalculo, Per_UsuarioRegistra)
    VALUES (@Cco_Id, @Mor_DiasAtraso, @Mor_Porcentaje, @Mor_MontoMora, @Mor_FechaCalculo, @Mor_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbMoratorias_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbMoratorias_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.Mor_Id, m.Cco_Id, m.Mor_DiasAtraso, m.Mor_Porcentaje, m.Mor_MontoMora, m.Mor_FechaCalculo,
           m.Per_EsEliminado, m.Per_UsuarioRegistra, m.Per_FechaRegistra,
           m.Per_UsuarioModifica, m.Per_FechaModifica
    FROM finanza.tbMoratorias m
    WHERE m.Per_EsEliminado = 0
    ORDER BY m.Mor_FechaCalculo DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbMoratorias_ListByCuenta]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbMoratorias_ListByCuenta]
    @Cco_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbMoratorias
    WHERE Cco_Id = @Cco_Id AND Per_EsEliminado = 0
    ORDER BY Mor_FechaCalculo DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbMoratorias_Update]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbMoratorias_Update]
    @Mor_Id int,
    @Cco_Id int,
    @Mor_DiasAtraso int,
    @Mor_Porcentaje decimal(9,4),
    @Mor_MontoMora decimal(18,2),
    @Mor_FechaCalculo date,
    @Mor_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbMoratorias
    SET Cco_Id = @Cco_Id,
        Mor_DiasAtraso = @Mor_DiasAtraso,
        Mor_Porcentaje = @Mor_Porcentaje,
        Mor_MontoMora = @Mor_MontoMora,
        Mor_FechaCalculo = @Mor_FechaCalculo,
        Per_UsuarioModifica = @Mor_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE Mor_Id = @Mor_Id;

    SELECT @Mor_Id AS UpdatedId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagos_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbPagos_Delete]
    @Pag_Id int,
    @Per_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbPagos
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Per_UsuarioModifica,
        Per_FechaModifica = sysdatetime()
    WHERE Pag_Id = @Pag_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagos_Detail]    Script Date: 12/11/2025 22:25:46 ******/

USE [DB_GestionColegial];
GO
CREATE PROCEDURE [finanza].[PR_tbPagos_Detail]
    @Pag_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.Pag_Id,
        p.Alu_Id,
        AlumnoNombre = LTRIM(RTRIM(CONCAT(pa.Per_PrimerNombre, ' ', ISNULL(pa.Per_SegundoNombre, ''), ' ', pa.Per_ApellidoPaterno, ' ', ISNULL(pa.Per_ApellidoMaterno, '')))),
        p.Enc_Id,
        EncargadoNombre = CASE
                              WHEN p.Enc_Id IS NULL THEN NULL
                              ELSE LTRIM(RTRIM(CONCAT(pe.Per_PrimerNombre, ' ', ISNULL(pe.Per_SegundoNombre, ''), ' ', pe.Per_ApellidoPaterno, ' ', ISNULL(pe.Per_ApellidoMaterno, ''))))
                          END,
        p.Fpa_Id,
        FormaPago = fp.Fpa_Descripcion,
        p.Pag_MontoTotal,
        p.Pag_FechaPago,
        p.Pag_NumeroReferencia,
        p.Pag_Observaciones,
        p.Usu_Id,
        UsuarioNombre = u.Usu_Name,
        ReciboNumero = r1.Rec_NumeroRecibo,
        ReciboFecha = r1.Rec_FechaEmision,
        TotalDistribuido = distribucion.TotalDistribuido,
        p.Per_EsEliminado,
        p.Per_UsuarioRegistra,
        p.Per_FechaRegistra,
        p.Per_UsuarioModifica,
        p.Per_FechaModifica,
        usuarioRegistra.Usu_Name AS UsuarioRegistraNombre,
        usuarioModificacion.Usu_Name AS UsuarioModificaNombre
    FROM finanza.tbPagos AS p
    INNER JOIN finanza.tbFormasPago AS fp
        ON fp.Fpa_Id = p.Fpa_Id
    LEFT JOIN app.tbAlumnos AS a
        ON a.Alu_Id = p.Alu_Id
    LEFT JOIN app.tbPersonas AS pa
        ON pa.Per_Id = a.Per_Id
    LEFT JOIN app.tbEncargados AS e
        ON e.Enc_Id = p.Enc_Id
    LEFT JOIN app.tbPersonas AS pe
        ON pe.Per_Id = e.Per_Id
    LEFT JOIN seguridad.tbUsuarios AS u
        ON u.Usu_Id = p.Usu_Id
    OUTER APPLY (
        SELECT ISNULL(SUM(pd.Pde_MontoAplicado), 0) AS TotalDistribuido
        FROM finanza.tbPagosDetalle AS pd
        WHERE pd.Pag_Id = p.Pag_Id
          AND pd.Per_EsEliminado != 1
    ) AS distribucion
    OUTER APPLY (
        SELECT TOP (1)
            r.Rec_NumeroRecibo,
            r.Rec_FechaEmision
        FROM finanza.tbRecibos AS r
        WHERE r.Pag_Id = p.Pag_Id
          AND r.Per_EsEliminado != 1
        ORDER BY r.Rec_FechaEmision DESC, r.Rec_Id DESC
    ) AS r1
    INNER JOIN [seguridad].[tbUsuarios] AS usuarioRegistra
        ON p.Per_UsuarioRegistra = usuarioRegistra.Usu_Id
    FULL JOIN [seguridad].[tbUsuarios] AS usuarioModificacion
        ON p.Per_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE p.Pag_Id = @Pag_Id
      AND p.Per_EsEliminado != 1;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagos_Find]    Script Date: 12/11/2025 22:25:46 ******/
USE [DB_GestionColegial];
GO
CREATE PROCEDURE [finanza].[PR_tbPagos_Find]
    @Pag_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.Pag_Id,
        p.Alu_Id,
        AlumnoNombre = LTRIM(RTRIM(
            CONCAT(pa.Per_PrimerNombre, ' ', ISNULL(pa.Per_SegundoNombre, ''), ' 
                   pa.Per_ApellidoPaterno, ' ', ISNULL(pa.Per_ApellidoMaterno, ''))
        )),

        p.Enc_Id,
        EncargadoNombre = CASE
                              WHEN p.Enc_Id IS NULL THEN NULL
                              ELSE LTRIM(RTRIM(
                                  CONCAT(pe.Per_PrimerNombre, ' ', ISNULL(pe.Per_SegundoNombre, ''), ' 
                                         pe.Per_ApellidoPaterno, ' ', ISNULL(pe.Per_ApellidoMaterno, ''))
                              ))
                          END,

        p.Fpa_Id,
        fp.Fpa_Descripcion AS FormaPago,

        p.Pag_MontoTotal,
        p.Pag_FechaPago,
        p.Pag_NumeroReferencia,
        p.Pag_Observaciones,

        p.Usu_Id,
        u.Usu_Name AS UsuarioNombre,

        recibo.Rec_NumeroRecibo,
        recibo.Rec_FechaEmision,
        distribucion.TotalDistribuido
    FROM finanza.tbPagos AS p
        INNER JOIN finanza.tbFormasPago AS fp
            ON fp.Fpa_Id = p.Fpa_Id

        LEFT JOIN app.tbAlumnos AS a
            ON a.Alu_Id = p.Alu_Id
        LEFT JOIN app.tbPersonas AS pa
            ON pa.Per_Id = a.Per_Id

        LEFT JOIN app.tbEncargados AS e
            ON e.Enc_Id = p.Enc_Id
        LEFT JOIN app.tbPersonas AS pe
            ON pe.Per_Id = e.Per_Id

        LEFT JOIN seguridad.tbUsuarios AS u
            ON u.Usu_Id = p.Usu_Id

        OUTER APPLY (
            SELECT ISNULL(SUM(pd.Pde_MontoAplicado), 0) AS TotalDistribuido
            FROM finanza.tbPagosDetalle AS pd
            WHERE pd.Pag_Id = p.Pag_Id
              AND pd.Per_EsEliminado != 1
        ) AS distribucion

        OUTER APPLY (
            SELECT TOP (1)
                r.Rec_NumeroRecibo,
                r.Rec_FechaEmision
            FROM finanza.tbRecibos AS r
            WHERE r.Pag_Id = p.Pag_Id
              AND r.Per_EsEliminado != 1
            ORDER BY r.Rec_FechaEmision DESC, r.Rec_Id DESC
        ) AS recibo

    WHERE p.Pag_Id = @Pag_Id
      AND p.Per_EsEliminado != 1;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagos_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbPagos_Insert]
    @Alu_Id int,
    @Enc_Id int = NULL,
    @Fpa_Id int,
    @Pag_MontoTotal decimal(18,2),
    @Pag_FechaPago datetime2(0),
    @Pag_NumeroReferencia nvarchar(60) = NULL,
    @Pag_Observaciones nvarchar(300) = NULL,
    @Usu_Id int,
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbPagos (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Per_UsuarioRegistra)
    VALUES (@Alu_Id, @Enc_Id, @Fpa_Id, @Pag_MontoTotal, @Pag_FechaPago, @Pag_NumeroReferencia, @Pag_Observaciones, @Usu_Id, @Per_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagos_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbPagos_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.Pag_Id,
        p.Pag_FechaPago,
        p.Pag_MontoTotal,
        p.Pag_NumeroReferencia,
        p.Pag_Observaciones,

        -- Forma de pago
        fp.Fpa_Descripcion AS FormaPago,

        -- Alumno
        Alumno = LTRIM(RTRIM(
                    CONCAT(pa.Per_PrimerNombre, ' ',
                           ISNULL(pa.Per_SegundoNombre,''), ' ',
                           pa.Per_ApellidoPaterno, ' ',
                           ISNULL(pa.Per_ApellidoMaterno,'')))),

        -- Encargado
        Encargado = CASE WHEN p.Enc_Id IS NULL THEN NULL ELSE
                    LTRIM(RTRIM(
                    CONCAT(pe.Per_PrimerNombre, ' ',
                           ISNULL(pe.Per_SegundoNombre,''), ' ',
                           pe.Per_ApellidoPaterno, ' ',
                           ISNULL(pe.Per_ApellidoMaterno,'')))) END,

        -- Cajero (usuario)
        Usuario = u.Usu_Name,

        -- Recibo asociado
        r1.Rec_NumeroRecibo,
        r1.Rec_FechaEmision
    FROM finanza.tbPagos p
        INNER JOIN finanza.tbFormasPago fp ON fp.Fpa_Id = p.Fpa_Id
        LEFT JOIN app.tbAlumnos a ON a.Alu_Id = p.Alu_Id
        LEFT JOIN app.tbPersonas pa ON pa.Per_Id = a.Per_Id
        LEFT JOIN app.tbEncargados e ON e.Enc_Id = p.Enc_Id
        LEFT JOIN app.tbPersonas pe ON pe.Per_Id = e.Per_Id
        LEFT JOIN seguridad.tbUsuarios u ON u.Usu_Id = p.Usu_Id
        OUTER APPLY (
            SELECT TOP (1)
                r.Rec_NumeroRecibo,
                r.Rec_FechaEmision
            FROM finanza.tbRecibos r
            WHERE r.Pag_Id = p.Pag_Id AND r.Per_EsEliminado = 0
            ORDER BY r.Rec_FechaEmision DESC, r.Rec_Id DESC
        ) r1
    WHERE p.Per_EsEliminado = 0
    ORDER BY p.Pag_FechaPago DESC, p.Pag_Id DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagosDetalle_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbPagosDetalle_Delete]
    @Pde_Id int,
    @Per_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbPagosDetalle
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Per_UsuarioModifica,
        Per_FechaModifica = sysdatetime()
    WHERE Pde_Id = @Pde_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagosDetalle_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbPagosDetalle_Insert]
    @Pag_Id int,
    @Cco_Id int,
    @Pde_MontoAplicado decimal(18,2),
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbPagosDetalle (Pag_Id, Cco_Id, Pde_MontoAplicado, Per_UsuarioRegistra)
    VALUES (@Pag_Id, @Cco_Id, @Pde_MontoAplicado, @Per_UsuarioRegistra);
    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagosDetalle_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbPagosDetalle_List]
    @Pag_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pd.*
    FROM finanza.tbPagosDetalle pd
    WHERE pd.Per_EsEliminado = 0
      AND (@Pag_Id IS NULL OR pd.Pag_Id = @Pag_Id)
    ORDER BY pd.Pde_Id DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbRecibos_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  StoredProcedure [finanza].[PR_tbRecibos_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  StoredProcedure [finanza].[PR_tbRecibos_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- PR_tbRecibos_Detail
-- Descripción: Obtiene el detalle completo de un recibo incluyendo auditoría
-- Tipo: DETAIL - Con IDs, descripciones y campos de auditoría
-- ============================================================================
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
/****** Object:  StoredProcedure [finanza].[PR_tbRecibos_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbRecibos_Insert]
    @Pag_Id int,
    @Rec_NumeroRecibo nvarchar(40),
    @Rec_RutaArchivo nvarchar(260) = NULL,
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbRecibos (Pag_Id, Rec_NumeroRecibo, Rec_RutaArchivo, Per_UsuarioRegistra)
    VALUES (@Pag_Id, @Rec_NumeroRecibo, @Rec_RutaArchivo, @Per_UsuarioRegistra);
    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbRecibos_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbTarifas_Delete]
    @Tar_Id int,
    @Tar_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbTarifas
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Tar_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE Tar_Id = @Tar_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbTarifas_Detail]
    @Tar_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.*, cp.Cpa_Descripcion AS Concepto
    FROM finanza.tbTarifas t
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = t.Cpa_Id
    WHERE t.Tar_Id = @Tar_Id AND t.Per_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Dropdown]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbTarifas_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.Tar_Id,
           CONCAT(cp.Cpa_Descripcion, ' - ', t.Tar_AnioVigencia, ' - L.', t.Tar_Monto) AS Texto
    FROM finanza.tbTarifas t
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = t.Cpa_Id
    WHERE t.Per_EsEliminado = 0
    ORDER BY t.Tar_AnioVigencia DESC, cp.Cpa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Exist]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbTarifas_Exist]
    @Cpa_Id int,
    @Niv_Id int = NULL,
    @Cun_Id int = NULL,
    @Tar_AnioVigencia smallint,
    @Tar_Id int = NULL  -- Para excluir en Update
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Exists bit = 0;
    DECLARE @Message nvarchar(200) = '';

    IF EXISTS (
        SELECT 1 FROM finanza.tbTarifas
        WHERE Cpa_Id = @Cpa_Id
          AND (Niv_Id = @Niv_Id OR (Niv_Id IS NULL AND @Niv_Id IS NULL))
          AND (Cun_Id = @Cun_Id OR (Cun_Id IS NULL AND @Cun_Id IS NULL))
          AND Tar_AnioVigencia = @Tar_AnioVigencia
          AND Per_EsEliminado = 0
          AND (@Tar_Id IS NULL OR Tar_Id <> @Tar_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe una tarifa para este concepto y año.';
    END
    ELSE
    BEGIN
        SET @Message = 'La tarifa no existe.';
    END

    -- CORREGIDO: Usar corchetes para palabra reservada
    SELECT @Exists AS [Exists], @Message AS Message;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbTarifas_Find]
    @Tar_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbTarifas
    WHERE Tar_Id = @Tar_Id AND Per_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_GetByConceptoAndNivel]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbTarifas_GetByConceptoAndNivel]
    @Cpa_Id int,
    @Niv_Id int,
    @Tar_AnioVigencia smallint
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbTarifas
    WHERE Cpa_Id = @Cpa_Id
      AND Niv_Id = @Niv_Id
      AND Tar_AnioVigencia = @Tar_AnioVigencia
      AND Per_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbTarifas_Insert]
    @Cpa_Id int,
    @Niv_Id int = NULL,
    @Cun_Id int = NULL,
    @Tar_Monto decimal(18,2),
    @Tar_AnioVigencia smallint,
    @Tar_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbTarifas (Cpa_Id, Niv_Id, Cun_Id, Tar_Monto, Tar_AnioVigencia, Per_UsuarioRegistra)
    VALUES (@Cpa_Id, @Niv_Id, @Cun_Id, @Tar_Monto, @Tar_AnioVigencia, @Tar_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbTarifas_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.Tar_Id, t.Cpa_Id, t.Niv_Id, t.Cun_Id, t.Tar_Monto, t.Tar_AnioVigencia,
           t.Per_EsEliminado, t.Per_UsuarioRegistra, t.Per_FechaRegistra,
           t.Per_UsuarioModifica, t.Per_FechaModifica,
           cp.Cpa_Descripcion AS Concepto
    FROM finanza.tbTarifas t
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = t.Cpa_Id
    WHERE t.Per_EsEliminado = 0
    ORDER BY t.Tar_AnioVigencia DESC, cp.Cpa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Update]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [finanza].[PR_tbTarifas_Update]
    @Tar_Id int,
    @Cpa_Id int,
    @Niv_Id int = NULL,
    @Cun_Id int = NULL,
    @Tar_Monto decimal(18,2),
    @Tar_AnioVigencia smallint,
    @Tar_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbTarifas
    SET Cpa_Id = @Cpa_Id,
        Niv_Id = @Niv_Id,
        Cun_Id = @Cun_Id,
        Tar_Monto = @Tar_Monto,
        Tar_AnioVigencia = @Tar_AnioVigencia,
        Per_UsuarioModifica = @Tar_UsuarioModifica,
        Per_FechaModifica = SYSDATETIME()
    WHERE Tar_Id = @Tar_Id;

    SELECT @Tar_Id AS UpdatedId;
END
GO
