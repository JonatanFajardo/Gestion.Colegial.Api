-- =====================================================================
-- Procedure: PR_tbHorarios_Insert
-- Descripción: Inserta un nuevo horario/clase
-- Fecha: 2025-11-27
-- =====================================================================

USE [DB_GestionColegial]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarios_Insert]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarios_Insert]
GO

CREATE PROCEDURE [app].[PR_tbHorarios_Insert]
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
    @Hor_UsuarioRegistra INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [app].[tbHorarios] (
            [Cur_Id],
            [Cun_Id],
            [Mat_Id],
            [Emp_Id],
            [Sec_Id],
            [Aul_Id],
            [Dia_Id],
            [Hor_HoraInicio],
            [Hor_HoraFinaliza],
            [Sem_Id],
            [Mda_Id],
            [Hor_Año],
            [Hor_EsEliminado],
            [Hor_UsuarioRegistra],
            [Hor_FechaRegistra]
        )
        VALUES (
            @Cur_Id,
            @Cun_Id,
            @Mat_Id,
            @Emp_Id,
            @Sec_Id,
            @Aul_Id,
            @Dia_Id,
            @Hor_HoraInicio,
            @Hor_HoraFinaliza,
            @Sem_Id,
            @Mda_Id,
            @Hor_Año,
            0,  -- Hor_EsEliminado = false
            @Hor_UsuarioRegistra,
            GETDATE()
        );

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
