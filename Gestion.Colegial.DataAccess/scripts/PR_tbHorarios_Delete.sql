-- =====================================================================
-- Procedure: PR_tbHorarios_Delete
-- Descripción: Elimina (soft delete) un horario/clase
-- Fecha: 2025-11-27
-- =====================================================================

USE [DB_GestionColegial]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarios_Delete]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarios_Delete]
GO

CREATE PROCEDURE [app].[PR_tbHorarios_Delete]
    @Hor_Id INT,
    @Hor_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Soft delete: marcar como eliminado
        UPDATE [app].[tbHorarios]
        SET [Hor_EsEliminado] = 1,
            [Hor_UsuarioModifica] = @Hor_UsuarioModifica,
            [Hor_FechaModifica] = GETDATE()
        WHERE [Hor_Id] = @Hor_Id
          AND [Hor_EsEliminado] = 0;

        COMMIT TRANSACTION;

        SELECT 1 AS CodeResult; -- Éxito
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 0 AS CodeResult; -- Error
    END CATCH
END
GO
