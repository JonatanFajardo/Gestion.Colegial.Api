-- =====================================================================
-- Procedure: PR_tbHorarios_Update
-- Descripción: Actualiza un horario/clase existente
-- Fecha: 2025-11-27
-- =====================================================================

USE [DB_GestionColegial]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarios_Update]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarios_Update]
GO

CREATE PROCEDURE [app].[PR_tbHorarios_Update]
    @Hor_Id INT,
    @Cur_Id INT,
    @Cun_Id INT,
    @Mat_Id INT,
    @Emp_Id INT,
    @Sec_Id INT,
    @Aul_Id INT,
    @Dia_Id INT,
    @Hor_HoraInicio INT,
    @Hor_HoraFinaliza INT,
    @Sem_Id INT,
    @Mda_Id INT = NULL,
    @Hor_Año INT,
    @Hor_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [app].[tbHorarios]
        SET [Cur_Id] = @Cur_Id,
            [Cun_Id] = @Cun_Id,
            [Mat_Id] = @Mat_Id,
            [Emp_Id] = @Emp_Id,
            [Sec_Id] = @Sec_Id,
            [Aul_Id] = @Aul_Id,
            [Dia_Id] = @Dia_Id,
            [Hor_HoraInicio] = @Hor_HoraInicio,
            [Hor_HoraFinaliza] = @Hor_HoraFinaliza,
            [Sem_Id] = @Sem_Id,
            [Mda_Id] = @Mda_Id,
            [Hor_Año] = @Hor_Año,
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
