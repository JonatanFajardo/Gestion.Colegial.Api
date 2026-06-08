-- =====================================================================
-- Procedure: PR_tbHorarioAlumnos_Find
-- Descripción: Obtiene un horario de alumno por su ID
-- Fecha: 2025-11-27
-- =====================================================================

USE [DB_GestionColegial]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarioAlumnos_Find]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarioAlumnos_Find]
GO

CREATE PROCEDURE [app].[PR_tbHorarioAlumnos_Find]
    @HoAl_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ha.HoAl_Id,
        ha.Cur_Id,
        c.Cur_Nombre,
        ha.Cun_Id,
        cn.Cun_Descripcion,
        ha.Mat_Id,
        m.Mat_Nombre,
        ha.HoAl_HoraInicio,
        hi.Hor_Hora AS HoAl_HoraInicioDescripcion,
        ha.HoAl_HoraFinaliza,
        hf.Hor_Hora AS HoAl_HoraFinalizaDescripcion,
        ha.Dia_Id,
        d.Dia_Descripcion,
        ha.Sec_Id,
        s.Sec_Descripcion,
        ha.Aul_Id,
        a.Aul_Descripcion,
        ha.Emp_Id,
        CONCAT(e.Emp_PrimerNombre, ' ', ISNULL(e.Emp_SegundoNombre, ''), ' ', e.Emp_PrimerApellido, ' ', ISNULL(e.Emp_SegundoApellido, '')) AS Emp_NombreCompleto,
        ha.Sem_Id,
        sem.Sem_Descripcion,
        ha.Mda_Id,
        mda.Mda_Descripcion,
        ha.HoAl_Año,
        ha.HoAl_UsuarioRegistra,
        ha.HoAl_FechaRegistra,
        ha.HoAl_UsuarioModifica,
        ha.HoAl_FechaModifica
    FROM [app].[tbHorarioAlumnos] ha
    INNER JOIN [app].[tbCursos] c ON ha.Cur_Id = c.Cur_Id
    INNER JOIN [app].[tbCursosNiveles] cn ON ha.Cun_Id = cn.Cun_Id
    INNER JOIN [app].[tbMaterias] m ON ha.Mat_Id = m.Mat_Id
    INNER JOIN [app].[tbHoras] hi ON ha.HoAl_HoraInicio = hi.Hor_Id
    INNER JOIN [app].[tbHoras] hf ON ha.HoAl_HoraFinaliza = hf.Hor_Id
    INNER JOIN [app].[tbDias] d ON ha.Dia_Id = d.Dia_Id
    INNER JOIN [app].[tbSecciones] s ON ha.Sec_Id = s.Sec_Id
    INNER JOIN [app].[tbAulas] a ON ha.Aul_Id = a.Aul_Id
    INNER JOIN [app].[tbEmpleados] e ON ha.Emp_Id = e.Emp_Id
    INNER JOIN [app].[tbSemestres] sem ON ha.Sem_Id = sem.Sem_Id
    LEFT JOIN [app].[tbModalidades] mda ON ha.Mda_Id = mda.Mda_Id
    WHERE ha.HoAl_Id = @HoAl_Id;
END
GO
