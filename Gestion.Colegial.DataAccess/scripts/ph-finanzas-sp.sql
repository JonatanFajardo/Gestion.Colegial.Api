USE [DB_GestionColegial]
GO
/****** Object:  StoredProcedure [finanza].[PR_tbConceptosPago_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbConceptosPago_Delete]
    @Cpa_Id int,
    @Cpa_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbConceptosPago
    SET Cpa_EsEliminado = 1,
        Cpa_UsuarioModifica = @Cpa_UsuarioModifica,
        Cpa_FechaModifica = sysdatetime()
    WHERE Cpa_Id = @Cpa_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbConceptosPago_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbConceptosPago_Detail]
    @Cpa_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT cp.Cpa_Id,
           cp.Cpa_Descripcion,
           cp.Cpa_EsRecurrente,
           cp.Cpa_EsObligatorio,
           cp.Cpa_EsActivo,
           COUNT(t.Tar_Id) AS CantTarifas,
           -- Campos de auditoría
           cp.Cpa_EsEliminado,
           cp.Cpa_UsuarioRegistra,
           usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
           cp.Cpa_FechaRegistra,
           cp.Cpa_UsuarioModifica,
           usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
           cp.Cpa_FechaModifica
    FROM finanza.tbConceptosPago cp
    LEFT JOIN finanza.tbTarifas t ON t.Cpa_Id = cp.Cpa_Id AND t.Tar_EsEliminado = 0
    -- JOINs para auditoría
    LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
        ON cp.Cpa_UsuarioRegistra = usuarioRegistra.Usu_Id
    LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
        ON cp.Cpa_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE cp.Cpa_Id = @Cpa_Id AND cp.Cpa_EsEliminado = 0
    GROUP BY cp.Cpa_Id, cp.Cpa_Descripcion, cp.Cpa_EsRecurrente, cp.Cpa_EsObligatorio, cp.Cpa_EsActivo,
             cp.Cpa_EsEliminado, cp.Cpa_UsuarioRegistra, usuarioRegistra.Usu_Name, cp.Cpa_FechaRegistra,
             cp.Cpa_UsuarioModifica, usuarioModificacion.Usu_Name, cp.Cpa_FechaModifica;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbConceptosPago_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbConceptosPago_Insert]
    @Cpa_Descripcion nvarchar(120),
    @Cpa_EsRecurrente  bit,
    @Cpa_EsObligatorio bit,
    @Cpa_EsActivo      bit,
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo,
                                     Cpa_UsuarioRegistra)
    VALUES (@Cpa_Descripcion, @Cpa_EsRecurrente, @Cpa_EsObligatorio, @Cpa_EsActivo, @Per_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbConceptosPago_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbConceptosPago_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY Cpa_Descripcion) AS [# Fila],
           Cpa_Id, Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo
    FROM finanza.tbConceptosPago
    WHERE Cpa_EsEliminado = 0
    ORDER BY Cpa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbCuentasCobrar_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbCuentasCobrar_Delete]
    @Cco_Id int,
    @Cco_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbCuentasCobrar
    SET Cco_EsEliminado = 1,
        Cco_UsuarioModifica = @Cco_UsuarioModifica,
        Cco_FechaModifica = sysdatetime()
    WHERE Cco_Id = @Cco_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbCuentasCobrar_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbCuentasCobrar_Detail]
    @Cco_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT cco.Cco_Id,
           cco.Alu_Id,
           cco.Cpa_Id,
           cco.Tar_Id,
           cco.Cco_MontoOriginal,
           cco.Cco_MontoDescuento,
           cco.Cco_MontoMora,
           cco.Cco_MontoTotal,
           cco.Cco_MontoPendiente,
           cco.Cco_FechaEmision,
           cco.Cco_FechaVencimiento,
           cco.Epa_Id,
           cco.Cco_Observaciones,
           cp.Cpa_Descripcion,
           epa.Epa_Descripcion,
           ISNULL(SUM(pd.Pde_MontoAplicado),0) AS TotalPagado,
           -- Campos de auditoría
           cco.Cco_EsEliminado,
           cco.Cco_UsuarioRegistra,
           usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
           cco.Cco_FechaRegistra,
           cco.Cco_UsuarioModifica,
           usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
           cco.Cco_FechaModifica
    FROM finanza.tbCuentasCobrar cco
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = cco.Cpa_Id
    INNER JOIN finanza.tbEstadosPago epa ON epa.Epa_Id = cco.Epa_Id
    LEFT  JOIN finanza.tbPagosDetalle pd ON pd.Cco_Id = cco.Cco_Id AND pd.Pde_EsEliminado = 0
    -- JOINs para auditoría
    LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
        ON cco.Cco_UsuarioRegistra = usuarioRegistra.Usu_Id
    LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
        ON cco.Cco_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE cco.Cco_Id = @Cco_Id
    GROUP BY cco.Cco_Id, cco.Alu_Id, cco.Cpa_Id, cco.Tar_Id, cco.Cco_MontoOriginal, cco.Cco_MontoDescuento,
             cco.Cco_MontoMora, cco.Cco_MontoTotal, cco.Cco_MontoPendiente, cco.Cco_FechaEmision, cco.Cco_FechaVencimiento,
             cco.Epa_Id, cco.Cco_Observaciones, cp.Cpa_Descripcion, epa.Epa_Descripcion,
             cco.Cco_EsEliminado, cco.Cco_UsuarioRegistra, usuarioRegistra.Usu_Name, cco.Cco_FechaRegistra,
             cco.Cco_UsuarioModifica, usuarioModificacion.Usu_Name, cco.Cco_FechaModifica;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbCuentasCobrar_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbCuentasCobrar_Find]
    @Cco_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM finanza.tbCuentasCobrar WHERE Cco_Id = @Cco_Id AND Cco_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbCuentasCobrar_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbCuentasCobrar_Insert]
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
        Epa_Id, Cco_Observaciones, Cco_UsuarioRegistra)
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
ALTER PROCEDURE [finanza].[PR_tbCuentasCobrar_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY cco.Cco_Id DESC) AS [# Fila],
           cco.Cco_Id, cco.Alu_Id, cco.Cpa_Id, cco.Tar_Id,
           cco.Cco_MontoOriginal, cco.Cco_MontoDescuento, cco.Cco_MontoMora,
           cco.Cco_MontoTotal, cco.Cco_MontoPendiente,
           cco.Cco_FechaEmision, cco.Cco_FechaVencimiento, cco.Epa_Id,
           cp.Cpa_Descripcion, epa.Epa_Descripcion
    FROM finanza.tbCuentasCobrar cco
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = cco.Cpa_Id
    INNER JOIN finanza.tbEstadosPago epa ON epa.Epa_Id = cco.Epa_Id
    WHERE cco.Cco_EsEliminado = 0
    ORDER BY cco.Cco_Id DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentos_Delete]
    @Des_Id int,
    @Des_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbDescuentos
    SET Des_EsEliminado = 1,
        Des_UsuarioModifica = @Des_UsuarioModifica,
        Des_FechaModifica = SYSDATETIME()
    WHERE Des_Id = @Des_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentos_Detail]
    @Des_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.Des_Id,
           d.Des_Descripcion,
           d.Des_TipoDescuento,
           d.Des_Valor,
           d.Des_EsActivo,
           COUNT(da.Dap_Id) AS CantidadAplicaciones,
           -- Campos de auditoría
           d.Des_EsEliminado,
           d.Des_UsuarioRegistra,
           usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
           d.Des_FechaRegistra,
           d.Des_UsuarioModifica,
           usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
           d.Des_FechaModifica
    FROM finanza.tbDescuentos d
    LEFT JOIN finanza.tbDescuentosAplicados da ON da.Des_Id = d.Des_Id AND da.Dap_EsEliminado = 0
    -- JOINs para auditoría
    LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
        ON d.Des_UsuarioRegistra = usuarioRegistra.Usu_Id
    LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
        ON d.Des_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE d.Des_Id = @Des_Id AND d.Des_EsEliminado = 0
    GROUP BY d.Des_Id, d.Des_Descripcion, d.Des_TipoDescuento, d.Des_Valor, d.Des_EsActivo,
             d.Des_EsEliminado, d.Des_UsuarioRegistra, usuarioRegistra.Usu_Name, d.Des_FechaRegistra,
             d.Des_UsuarioModifica, usuarioModificacion.Usu_Name, d.Des_FechaModifica;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Dropdown]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentos_Dropdown]
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
    WHERE Des_EsEliminado = 0 AND Des_EsActivo = 1
    ORDER BY Des_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Exist]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentos_Exist]
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
          AND Des_EsEliminado = 0
          AND (@Des_Id IS NULL OR Des_Id <> @Des_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe un descuento con esta descripci�n.';
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
ALTER PROCEDURE [finanza].[PR_tbDescuentos_Find]
    @Des_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbDescuentos
    WHERE Des_Id = @Des_Id AND Des_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentos_Insert]
    @Des_Descripcion nvarchar(120),
    @Des_TipoDescuento char(1),
    @Des_Valor decimal(18,2),
    @Des_EsActivo bit,
    @Des_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Des_UsuarioRegistra)
    VALUES (@Des_Descripcion, @Des_TipoDescuento, @Des_Valor, @Des_EsActivo, @Des_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentos_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY Des_Descripcion) AS [# Fila],
           Des_Id, Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo
    FROM finanza.tbDescuentos
    WHERE Des_EsEliminado = 0
    ORDER BY Des_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentos_Update]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentos_Update]
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
        Des_UsuarioModifica = @Des_UsuarioModifica,
        Des_FechaModifica = SYSDATETIME()
    WHERE Des_Id = @Des_Id;

    SELECT @Des_Id AS UpdatedId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentosAplicados_Delete]
    @Dap_Id int,
    @Dap_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbDescuentosAplicados
    SET Dap_EsEliminado = 1,
        Dap_UsuarioModifica = @Dap_UsuarioModifica,
        Dap_FechaModifica = SYSDATETIME()
    WHERE Dap_Id = @Dap_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentosAplicados_Detail]
    @Dap_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT da.Dap_Id,
           da.Cco_Id,
           da.Des_Id,
           da.Dap_MontoAplicado,
           da.Dap_Justificacion,
           d.Des_Descripcion,
           d.Des_TipoDescuento,
           d.Des_Valor,
           cc.Cco_MontoOriginal,
           cc.Cco_MontoTotal,
           -- Campos de auditoría
           da.Dap_EsEliminado,
           da.Dap_UsuarioRegistra,
           usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
           da.Dap_FechaRegistra,
           da.Dap_UsuarioModifica,
           usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
           da.Dap_FechaModifica
    FROM finanza.tbDescuentosAplicados da
    INNER JOIN finanza.tbDescuentos d ON d.Des_Id = da.Des_Id
    INNER JOIN finanza.tbCuentasCobrar cc ON cc.Cco_Id = da.Cco_Id
    -- JOINs para auditoría
    LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
        ON da.Dap_UsuarioRegistra = usuarioRegistra.Usu_Id
    LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
        ON da.Dap_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE da.Dap_Id = @Dap_Id AND da.Dap_EsEliminado = 0;
END
GO 
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentosAplicados_Find]
    @Dap_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbDescuentosAplicados
    WHERE Dap_Id = @Dap_Id AND Dap_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentosAplicados_Insert]
    @Cco_Id int,
    @Des_Id int,
    @Dap_MontoAplicado decimal(18,2),
    @Dap_Justificacion nvarchar(300),
    @Dap_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbDescuentosAplicados (Cco_Id, Des_Id, Dap_MontoAplicado, Dap_Justificacion, Dap_UsuarioRegistra)
    VALUES (@Cco_Id, @Des_Id, @Dap_MontoAplicado, @Dap_Justificacion, @Dap_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentosAplicados_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY da.Dap_FechaRegistra DESC) AS [# Fila],
           da.Dap_Id, da.Cco_Id, da.Des_Id, da.Dap_MontoAplicado, da.Dap_Justificacion,
           d.Des_Descripcion, d.Des_TipoDescuento, d.Des_Valor
    FROM finanza.tbDescuentosAplicados da
    INNER JOIN finanza.tbDescuentos d ON d.Des_Id = da.Des_Id
    WHERE da.Dap_EsEliminado = 0
    ORDER BY da.Dap_FechaRegistra DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbDescuentosAplicados_ListByCuenta]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbDescuentosAplicados_ListByCuenta]
    @Cco_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY da.Dap_FechaRegistra DESC) AS [# Fila],
           da.Dap_Id, da.Cco_Id, da.Des_Id, da.Dap_MontoAplicado, da.Dap_Justificacion,
           da.Dap_EsEliminado, da.Dap_UsuarioRegistra, da.Dap_FechaRegistra, da.Dap_UsuarioModifica, da.Dap_FechaModifica,
           d.Des_Descripcion, d.Des_TipoDescuento, d.Des_Valor
    FROM finanza.tbDescuentosAplicados da
    INNER JOIN finanza.tbDescuentos d ON d.Des_Id = da.Des_Id
    WHERE da.Cco_Id = @Cco_Id AND da.Dap_EsEliminado = 0
    ORDER BY da.Dap_FechaRegistra DESC;
END
GO 
/****** Object:  StoredProcedure [finanza].[PR_tbEstadosPago_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbEstadosPago_Detail]
    @Epa_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ep.Epa_Id,
           ep.Epa_Descripcion,
           ep.Epa_EsActivo,
           COUNT(cc.Cco_Id) AS CantidadCuentas,
           -- Campos de auditoría
           ep.Epa_EsEliminado,
           ep.Epa_UsuarioRegistra,
           usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
           ep.Epa_FechaRegistra,
           ep.Epa_UsuarioModifica,
           usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
           ep.Epa_FechaModifica
    FROM finanza.tbEstadosPago ep
    LEFT JOIN finanza.tbCuentasCobrar cc ON cc.Epa_Id = ep.Epa_Id AND cc.Cco_EsEliminado = 0
    -- JOINs para auditoría
    LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
        ON ep.Epa_UsuarioRegistra = usuarioRegistra.Usu_Id
    LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
        ON ep.Epa_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE ep.Epa_Id = @Epa_Id AND ep.Epa_EsEliminado = 0
    GROUP BY ep.Epa_Id, ep.Epa_Descripcion, ep.Epa_EsActivo,
             ep.Epa_EsEliminado, ep.Epa_UsuarioRegistra, usuarioRegistra.Usu_Name, ep.Epa_FechaRegistra,
             ep.Epa_UsuarioModifica, usuarioModificacion.Usu_Name, ep.Epa_FechaModifica;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbEstadosPago_Exist]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbEstadosPago_Exist]
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
          AND Epa_EsEliminado = 0
          AND (@Epa_Id IS NULL OR Epa_Id <> @Epa_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe un estado de pago con esta descripci�n.';
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
ALTER PROCEDURE [finanza].[PR_tbEstadosPago_Find]
    @Epa_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbEstadosPago
    WHERE Epa_Id = @Epa_Id AND Epa_EsEliminado = 0;
END
GO 
/****** Object:  StoredProcedure [finanza].[PR_tbEstadosPago_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbEstadosPago_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY Epa_Descripcion) AS [# Fila],
           Epa_Id, Epa_Descripcion
    FROM finanza.tbEstadosPago
    WHERE Epa_EsEliminado = 0
    ORDER BY Epa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbEstadosPago_Update]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbFormasPago_Delete]
    @Fpa_Id int,
    @Fpa_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbFormasPago
    SET Fpa_EsEliminado = 1,
        Fpa_UsuarioModifica = @Fpa_UsuarioModifica,
        Fpa_FechaModifica = SYSDATETIME()
    WHERE Fpa_Id = @Fpa_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbFormasPago_Detail]
    @Fpa_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT fp.Fpa_Id,
           fp.Fpa_Descripcion,
           fp.Fpa_EsActivo,
           COUNT(p.Pag_Id) AS CantidadPagos,
           -- Campos de auditoría
           fp.Fpa_EsEliminado,
           fp.Fpa_UsuarioRegistra,
           usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
           fp.Fpa_FechaRegistra,
           fp.Fpa_UsuarioModifica,
           usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
           fp.Fpa_FechaModifica
    FROM finanza.tbFormasPago fp
    LEFT JOIN finanza.tbPagos p ON p.Fpa_Id = fp.Fpa_Id AND p.Pag_EsEliminado = 0
    -- JOINs para auditoría
    LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
        ON fp.Fpa_UsuarioRegistra = usuarioRegistra.Usu_Id
    LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
        ON fp.Fpa_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE fp.Fpa_Id = @Fpa_Id AND fp.Fpa_EsEliminado = 0
    GROUP BY fp.Fpa_Id, fp.Fpa_Descripcion, fp.Fpa_EsActivo,
             fp.Fpa_EsEliminado, fp.Fpa_UsuarioRegistra, usuarioRegistra.Usu_Name, fp.Fpa_FechaRegistra,
             fp.Fpa_UsuarioModifica, usuarioModificacion.Usu_Name, fp.Fpa_FechaModifica;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_Exist]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbFormasPago_Exist]
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
          AND Fpa_EsEliminado = 0
          AND (@Fpa_Id IS NULL OR Fpa_Id <> @Fpa_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe una forma de pago con esta descripci�n.';
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
ALTER PROCEDURE [finanza].[PR_tbFormasPago_Find]
    @Fpa_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbFormasPago
    WHERE Fpa_Id = @Fpa_Id AND Fpa_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbFormasPago_Insert]
    @Fpa_Descripcion nvarchar(80),
    @Fpa_EsActivo bit,
    @Fpa_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbFormasPago (Fpa_Descripcion, Fpa_EsActivo, Fpa_UsuarioRegistra)
    VALUES (@Fpa_Descripcion, @Fpa_EsActivo, @Fpa_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbFormasPago_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY Fpa_Descripcion) AS [# Fila],
           Fpa_Id, Fpa_Descripcion, Fpa_EsActivo
    FROM finanza.tbFormasPago
    WHERE Fpa_EsEliminado = 0
    ORDER BY Fpa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbFormasPago_Update]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbFormasPago_Update]
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
        Fpa_UsuarioModifica = @Fpa_UsuarioModifica,
        Fpa_FechaModifica = SYSDATETIME()
    WHERE Fpa_Id = @Fpa_Id;

    SELECT @Fpa_Id AS UpdatedId;
END
GO 
/****** Object:  StoredProcedure [finanza].[PR_tbMoratorias_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbMoratorias_Detail]
    @Mor_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.Mor_Id,
           m.Cco_Id,
           m.Mor_DiasAtraso,
           m.Mor_Porcentaje,
           m.Mor_MontoMora,
           m.Mor_FechaCalculo,
           cc.Cco_MontoOriginal,
           cc.Cco_MontoTotal,
           cc.Cco_FechaVencimiento,
           -- Campos de auditoría
           m.Mor_EsEliminado,
           m.Mor_UsuarioRegistra,
           usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
           m.Mor_FechaRegistra,
           m.Mor_UsuarioModifica,
           usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
           m.Mor_FechaModifica
    FROM finanza.tbMoratorias m
    INNER JOIN finanza.tbCuentasCobrar cc ON cc.Cco_Id = m.Cco_Id
    -- JOINs para auditoría
    LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
        ON m.Mor_UsuarioRegistra = usuarioRegistra.Usu_Id
    LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
        ON m.Mor_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE m.Mor_Id = @Mor_Id AND m.Mor_EsEliminado = 0;
END
GO 
/****** Object:  StoredProcedure [finanza].[PR_tbMoratorias_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbMoratorias_Find]
    @Mor_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbMoratorias
    WHERE Mor_Id = @Mor_Id AND Mor_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbMoratorias_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbMoratorias_Insert]
    @Cco_Id int,
    @Mor_DiasAtraso int,
    @Mor_Porcentaje decimal(9,4),
    @Mor_MontoMora decimal(18,2),
    @Mor_FechaCalculo date,
    @Mor_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbMoratorias (Cco_Id, Mor_DiasAtraso, Mor_Porcentaje, Mor_MontoMora, Mor_FechaCalculo, Mor_UsuarioRegistra)
    VALUES (@Cco_Id, @Mor_DiasAtraso, @Mor_Porcentaje, @Mor_MontoMora, @Mor_FechaCalculo, @Mor_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbMoratorias_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbMoratorias_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY m.Mor_FechaCalculo DESC) AS [# Fila],
           m.Mor_Id, m.Cco_Id, m.Mor_DiasAtraso, m.Mor_Porcentaje, m.Mor_MontoMora, m.Mor_FechaCalculo,
           cco.Cco_MontoOriginal, cco.Cco_FechaVencimiento
    FROM finanza.tbMoratorias m
    INNER JOIN finanza.tbCuentasCobrar cco ON cco.Cco_Id = m.Cco_Id
    WHERE m.Mor_EsEliminado = 0
    ORDER BY m.Mor_FechaCalculo DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagos_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbPagos_Detail]
    @Pag_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Pag_Id,
           p.Alu_Id,
           p.Enc_Id,
           p.Fpa_Id,
           p.Pag_MontoTotal,
           p.Pag_FechaPago,
           p.Pag_NumeroReferencia,
           p.Pag_Observaciones,
           p.Usu_Id,
           fp.Fpa_Descripcion,
           (SELECT ISNULL(SUM(pd.Pde_MontoAplicado),0) FROM finanza.tbPagosDetalle pd WHERE pd.Pag_Id = p.Pag_Id AND pd.Pde_EsEliminado = 0) AS TotalDistribuido,
           -- Campos de auditoría
           p.Pag_EsEliminado,
           p.Pag_UsuarioRegistra,
           usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
           p.Pag_FechaRegistra,
           p.Pag_UsuarioModifica,
           usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
           p.Pag_FechaModifica
    FROM finanza.tbPagos p
    INNER JOIN finanza.tbFormasPago fp ON fp.Fpa_Id = p.Fpa_Id
    -- JOINs para auditoría
    LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
        ON p.Pag_UsuarioRegistra = usuarioRegistra.Usu_Id
    LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
        ON p.Pag_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE p.Pag_Id = @Pag_Id AND p.Pag_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagos_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbPagos_Find]
    @Pag_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM finanza.tbPagos WHERE Pag_Id = @Pag_Id AND Pag_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagos_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbPagos_Insert]
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
    INSERT INTO finanza.tbPagos (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_UsuarioRegistra)
    VALUES (@Alu_Id, @Enc_Id, @Fpa_Id, @Pag_MontoTotal, @Pag_FechaPago, @Pag_NumeroReferencia, @Pag_Observaciones, @Usu_Id, @Per_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagos_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbPagos_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ROW_NUMBER() OVER (ORDER BY p.Pag_FechaPago DESC, p.Pag_Id DESC) AS [# Fila],
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
            WHERE r.Pag_Id = p.Pag_Id AND r.Rec_EsEliminado = 0
            ORDER BY r.Rec_FechaEmision DESC, r.Rec_Id DESC
        ) r1
    WHERE p.Pag_EsEliminado = 0
    ORDER BY p.Pag_FechaPago DESC, p.Pag_Id DESC;
END
GO 
/****** Object:  StoredProcedure [finanza].[PR_tbPagosDetalle_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbPagosDetalle_Insert]
    @Pag_Id int,
    @Cco_Id int,
    @Pde_MontoAplicado decimal(18,2),
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbPagosDetalle (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_UsuarioRegistra)
    VALUES (@Pag_Id, @Cco_Id, @Pde_MontoAplicado, @Per_UsuarioRegistra);
    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbPagosDetalle_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbPagosDetalle_List]
    @Pag_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY pd.Pde_Id DESC) AS [# Fila],
           pd.Pde_Id, pd.Pag_Id, pd.Cco_Id, pd.Pde_MontoAplicado,
           pd.Pde_EsEliminado, pd.Pde_UsuarioRegistra, pd.Pde_FechaRegistra, pd.Pde_UsuarioModifica, pd.Pde_FechaModifica
    FROM finanza.tbPagosDetalle pd
    WHERE pd.Pde_EsEliminado = 0
      AND (@Pag_Id IS NULL OR pd.Pag_Id = @Pag_Id)
    ORDER BY pd.Pde_Id DESC;
END
GO 
/****** Object:  StoredProcedure [finanza].[PR_tbRecibos_Find]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbRecibos_Find]
    @Rec_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM finanza.tbRecibos WHERE Rec_Id = @Rec_Id AND Rec_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbRecibos_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbRecibos_Insert]
    @Pag_Id int,
    @Rec_NumeroRecibo nvarchar(40),
    @Rec_RutaArchivo nvarchar(260) = NULL,
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbRecibos (Pag_Id, Rec_NumeroRecibo, Rec_RutaArchivo, Rec_UsuarioRegistra)
    VALUES (@Pag_Id, @Rec_NumeroRecibo, @Rec_RutaArchivo, @Per_UsuarioRegistra);
    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbRecibos_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbRecibos_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY Rec_FechaEmision DESC, Rec_Id DESC) AS [# Fila],
           Rec_Id, Pag_Id, Rec_NumeroRecibo, Rec_FechaEmision, Rec_RutaArchivo,
           Rec_EsEliminado, Rec_UsuarioRegistra, Rec_FechaRegistra, Rec_UsuarioModifica, Rec_FechaModifica
    FROM finanza.tbRecibos
    WHERE Rec_EsEliminado = 0
    ORDER BY Rec_FechaEmision DESC, Rec_Id DESC;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Delete]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbTarifas_Delete]
    @Tar_Id int,
    @Tar_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbTarifas
    SET Tar_EsEliminado = 1,
        Tar_UsuarioModifica = @Tar_UsuarioModifica,
        Tar_FechaModifica = SYSDATETIME()
    WHERE Tar_Id = @Tar_Id;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Detail]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbTarifas_Detail]
    @Tar_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.Tar_Id,
           t.Cpa_Id,
           t.Niv_Id,
           t.Cun_Id,
           t.Tar_Monto,
           t.Tar_AnioVigencia,
           t.Tar_EsActivo,
           cp.Cpa_Descripcion AS Concepto,
           -- Campos de auditoría
           t.Tar_EsEliminado,
           t.Tar_UsuarioRegistra,
           usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra,
           t.Tar_FechaRegistra,
           t.Tar_UsuarioModifica,
           usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica,
           t.Tar_FechaModifica
    FROM finanza.tbTarifas t
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = t.Cpa_Id
    -- JOINs para auditoría
    LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
        ON t.Tar_UsuarioRegistra = usuarioRegistra.Usu_Id
    LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
        ON t.Tar_UsuarioModifica = usuarioModificacion.Usu_Id
    WHERE t.Tar_Id = @Tar_Id AND t.Tar_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Dropdown]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbTarifas_Dropdown]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.Tar_Id,
           CONCAT(cp.Cpa_Descripcion, ' - ', t.Tar_AnioVigencia, ' - L.', t.Tar_Monto) AS Texto
    FROM finanza.tbTarifas t
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = t.Cpa_Id
    WHERE t.Tar_EsEliminado = 0
    ORDER BY t.Tar_AnioVigencia DESC, cp.Cpa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Exist]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbTarifas_Exist]
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
          AND Tar_EsEliminado = 0
          AND (@Tar_Id IS NULL OR Tar_Id <> @Tar_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe una tarifa para este concepto y a�o.';
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
ALTER PROCEDURE [finanza].[PR_tbTarifas_Find]
    @Tar_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbTarifas
    WHERE Tar_Id = @Tar_Id AND Tar_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_GetByConceptoAndNivel]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbTarifas_GetByConceptoAndNivel]
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
      AND Tar_EsEliminado = 0;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Insert]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbTarifas_Insert]
    @Cpa_Id int,
    @Niv_Id int = NULL,
    @Cun_Id int = NULL,
    @Tar_Monto decimal(18,2),
    @Tar_AnioVigencia smallint,
    @Tar_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbTarifas (Cpa_Id, Niv_Id, Cun_Id, Tar_Monto, Tar_AnioVigencia, Tar_UsuarioRegistra)
    VALUES (@Cpa_Id, @Niv_Id, @Cun_Id, @Tar_Monto, @Tar_AnioVigencia, @Tar_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_List]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbTarifas_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER (ORDER BY t.Tar_AnioVigencia DESC, cp.Cpa_Descripcion) AS [# Fila],
           t.Tar_Id, t.Cpa_Id, t.Niv_Id, t.Cun_Id, t.Tar_Monto, t.Tar_AnioVigencia,
           cp.Cpa_Descripcion AS Concepto
    FROM finanza.tbTarifas t
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = t.Cpa_Id
    WHERE t.Tar_EsEliminado = 0
    ORDER BY t.Tar_AnioVigencia DESC, cp.Cpa_Descripcion;
END
GO
/****** Object:  StoredProcedure [finanza].[PR_tbTarifas_Update]    Script Date: 12/11/2025 22:25:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [finanza].[PR_tbTarifas_Update]
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
        Tar_UsuarioModifica = @Tar_UsuarioModifica,
        Tar_FechaModifica = SYSDATETIME()
    WHERE Tar_Id = @Tar_Id;

    SELECT @Tar_Id AS UpdatedId;
END
GO

