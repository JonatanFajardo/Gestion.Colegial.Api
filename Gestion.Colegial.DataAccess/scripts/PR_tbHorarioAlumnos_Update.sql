-- =====================================================================
-- Procedure: PR_tbHorarioAlumnos_Update
-- Descripción: Actualiza un horario de alumno existente
-- Fecha: 2025-11-27
-- =====================================================================

USE [DB_GestionColegial]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarioAlumnos_Update]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarioAlumnos_Update]
GO

CREATE PROCEDURE [app].[PR_tbHorarioAlumnos_Update]
    @HoAl_Id INT,
    @Cur_Id INT,
    @Cun_Id INT,
    @Mat_Id INT,
    @HoAl_HoraInicio INT,
    @HoAl_HoraFinaliza INT,
    @Dia_Id INT,
    @Sec_Id INT,
    @Aul_Id INT,
    @Emp_Id INT,
    @Sem_Id INT,
    @Mda_Id INT = NULL,
    @HoAl_Año INT,
    @HoAl_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [app].[tbHorarioAlumnos]
        SET [Cur_Id] = @Cur_Id,
            [Cun_Id] = @Cun_Id,
            [Mat_Id] = @Mat_Id,
            [HoAl_HoraInicio] = @HoAl_HoraInicio,
            [HoAl_HoraFinaliza] = @HoAl_HoraFinaliza,
            [Dia_Id] = @Dia_Id,
            [Sec_Id] = @Sec_Id,
            [Aul_Id] = @Aul_Id,
            [Emp_Id] = @Emp_Id,
            [Sem_Id] = @Sem_Id,
            [Mda_Id] = @Mda_Id,
            [HoAl_Año] = @HoAl_Año,
            [HoAl_UsuarioModifica] = @HoAl_UsuarioModifica,
            [HoAl_FechaModifica] = GETDATE()
        WHERE [HoAl_Id] = @HoAl_Id;

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
