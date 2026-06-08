-- =====================================================================
-- Procedure: PR_tbHorarioAlumnos_Insert
-- Descripción: Inserta un nuevo horario de alumno
-- Fecha: 2025-11-27
-- =====================================================================

USE [DB_GestionColegial]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarioAlumnos_Insert]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarioAlumnos_Insert]
GO

CREATE PROCEDURE [app].[PR_tbHorarioAlumnos_Insert]
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
    @HoAl_UsuarioRegistra INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [app].[tbHorarioAlumnos] (
            [Cur_Id],
            [Cun_Id],
            [Mat_Id],
            [HoAl_HoraInicio],
            [HoAl_HoraFinaliza],
            [Dia_Id],
            [Sec_Id],
            [Aul_Id],
            [Emp_Id],
            [Sem_Id],
            [Mda_Id],
            [HoAl_Año],
            [HoAl_UsuarioRegistra],
            [HoAl_FechaRegistra]
        )
        VALUES (
            @Cur_Id,
            @Cun_Id,
            @Mat_Id,
            @HoAl_HoraInicio,
            @HoAl_HoraFinaliza,
            @Dia_Id,
            @Sec_Id,
            @Aul_Id,
            @Emp_Id,
            @Sem_Id,
            @Mda_Id,
            @HoAl_Año,
            @HoAl_UsuarioRegistra,
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
