-- =====================================================================
-- Procedure: PR_tbHorarioAlumnos_List
-- Descripción: Lista todos los horarios de alumnos con información relacionada
-- Fecha: 2025-11-27
-- =====================================================================

USE [DB_GestionColegial]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarioAlumnos_List]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarioAlumnos_List]
GO

CREATE PROCEDURE [app].[PR_tbHorarioAlumnos_List]
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
        CONCAT(pe.Per_PrimerNombre, ' ', ISNULL(pe.Per_SegundoNombre, ''), ' ', pe.Per_ApellidoPaterno, ' ', ISNULL(pe.Per_ApellidoMaterno, '')) AS Emp_NombreCompleto,
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
    INNER JOIN [app].[tbPersonas] pe ON e.Per_Id = pe.Per_Id
    INNER JOIN [app].[tbSemestres] sem ON ha.Sem_Id = sem.Sem_Id
    LEFT JOIN [app].[tbModalidades] mda ON ha.Mda_Id = mda.Mda_Id
    ORDER BY ha.HoAl_Año DESC, sem.Sem_Descripcion, s.Sec_Descripcion, d.Dia_Id, hi.Hor_Hora;
END
GO
