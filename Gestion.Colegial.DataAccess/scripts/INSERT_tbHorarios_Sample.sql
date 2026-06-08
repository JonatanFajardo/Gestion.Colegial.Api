-- =====================================================================
-- Script: INSERT Sample Data - tbHorarios
-- Descripción: Inserta registros de ejemplo en tbHorarios
-- Fecha: 2025-11-27
-- =====================================================================

USE [DB_GestionColegial]
GO

-- =====================================================================
-- INSERTAR REGISTRO DE EJEMPLO
-- =====================================================================
-- Asegúrate de que los IDs de las tablas relacionadas existan antes de ejecutar

DECLARE @Cur_Id INT = 1              -- ID del Curso
DECLARE @Cun_Id INT = 1              -- ID del Curso Nivel
DECLARE @Mat_Id INT = 1              -- ID de la Materia
DECLARE @Emp_Id INT = 1              -- ID del Empleado/Profesor
DECLARE @Sec_Id INT = 1              -- ID de la Sección
DECLARE @Aul_Id INT = 1              -- ID del Aula
DECLARE @Dia_Id INT = 1              -- ID del Día (1=Lunes)
DECLARE @Hor_HoraInicio INT = 1      -- ID de Hora Inicio
DECLARE @Hor_HoraFinaliza INT = 2    -- ID de Hora Finaliza
DECLARE @Sem_Id INT = 1              -- ID del Semestre
DECLARE @Mda_Id INT = NULL           -- ID de Modalidad (NULL = no especificado)
DECLARE @Hor_Año INT = 2025          -- Año académico
DECLARE @Hor_UsuarioRegistra INT = 1 -- ID del Usuario que registra

-- Verificar que no exista un registro duplicado
IF NOT EXISTS (
    SELECT 1
    FROM [app].[tbHorarios]
    WHERE [Cur_Id] = @Cur_Id
      AND [Cun_Id] = @Cun_Id
      AND [Mat_Id] = @Mat_Id
      AND [Emp_Id] = @Emp_Id
      AND [Sec_Id] = @Sec_Id
      AND [Dia_Id] = @Dia_Id
      AND [Hor_HoraInicio] = @Hor_HoraInicio
      AND [Sem_Id] = @Sem_Id
      AND [Hor_Año] = @Hor_Año
      AND [Hor_EsEliminado] = 0
)
BEGIN
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
        0,                              -- Hor_EsEliminado = 0 (activo)
        @Hor_UsuarioRegistra,
        GETDATE()
    );

    PRINT 'Registro insertado exitosamente en tbHorarios';
    PRINT 'ID generado: ' + CAST(SCOPE_IDENTITY() AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT 'Ya existe un registro similar en tbHorarios. No se insertó duplicado.';
END
GO

-- =====================================================================
-- EJEMPLO DE MÚLTIPLES REGISTROS
-- =====================================================================
-- Descomenta las siguientes líneas para insertar múltiples horarios

/*
-- Lunes - Matemáticas I - 7:00 AM a 8:00 AM
INSERT INTO [app].[tbHorarios]
    ([Cur_Id], [Cun_Id], [Mat_Id], [Emp_Id], [Sec_Id], [Aul_Id], [Dia_Id], [Hor_HoraInicio], [Hor_HoraFinaliza], [Sem_Id], [Mda_Id], [Hor_Año], [Hor_EsEliminado], [Hor_UsuarioRegistra], [Hor_FechaRegistra])
VALUES
    (1, 1, 1, 1, 1, 1, 1, 1, 2, 1, NULL, 2025, 0, 1, GETDATE());

-- Martes - Español II - 8:00 AM a 9:00 AM
INSERT INTO [app].[tbHorarios]
    ([Cur_Id], [Cun_Id], [Mat_Id], [Emp_Id], [Sec_Id], [Aul_Id], [Dia_Id], [Hor_HoraInicio], [Hor_HoraFinaliza], [Sem_Id], [Mda_Id], [Hor_Año], [Hor_EsEliminado], [Hor_UsuarioRegistra], [Hor_FechaRegistra])
VALUES
    (2, 2, 2, 2, 1, 2, 2, 2, 3, 1, NULL, 2025, 0, 1, GETDATE());

-- Miércoles - Ciencias III - 9:00 AM a 10:00 AM
INSERT INTO [app].[tbHorarios]
    ([Cur_Id], [Cun_Id], [Mat_Id], [Emp_Id], [Sec_Id], [Aul_Id], [Dia_Id], [Hor_HoraInicio], [Hor_HoraFinaliza], [Sem_Id], [Mda_Id], [Hor_Año], [Hor_EsEliminado], [Hor_UsuarioRegistra], [Hor_FechaRegistra])
VALUES
    (3, 3, 3, 3, 2, 3, 3, 3, 4, 1, NULL, 2025, 0, 1, GETDATE());

PRINT 'Múltiples registros insertados exitosamente';
*/
GO
