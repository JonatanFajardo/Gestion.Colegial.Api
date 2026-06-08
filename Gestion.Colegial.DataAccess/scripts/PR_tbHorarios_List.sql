-- =====================================================================
-- Procedure: PR_tbHorarios_List
-- Descripción: Lista todos los horarios/clases con información relacionada
-- Fecha: 2025-11-27
-- =====================================================================

USE [DB_GestionColegial]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarios_List]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarios_List]
GO

CREATE PROCEDURE [app].[PR_tbHorarios_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        tbhorarios.Hor_Id,
        tbhorarios.Cur_Id,
        tbcursos.Cur_Nombre,
        tbhorarios.Cun_Id,
        tbcursosniveles.Cun_Descripcion,
        tbhorarios.Mat_Id,
        tbmaterias.Mat_Nombre,
        tbhorarios.Emp_Id,
        CONCAT(tbpersonas.Per_PrimerNombre, ' ', ISNULL(tbpersonas.Per_SegundoNombre, ''), ' ', tbpersonas.Per_ApellidoPaterno, ' ', ISNULL(tbpersonas.Per_ApellidoMaterno, '')) AS Emp_NombreCompleto,
        tbhorarios.Sec_Id,
        tbsecciones.Sec_Descripcion,
        tbhorarios.Aul_Id,
        tbaulas.Aul_Descripcion,
        tbhorarios.Dia_Id,
        tbdias.Dia_Descripcion,
        tbhorarios.Hor_HoraInicio,
        tbhorasinicio.Hor_Hora AS Hor_HoraInicioDescripcion,
        tbhorarios.Hor_HoraFinaliza,
        tbhorasfinaliza.Hor_Hora AS Hor_HoraFinalizaDescripcion,
        tbhorarios.Sem_Id,
        tbsemestres.Sem_Descripcion,
        tbhorarios.Mda_Id,
        tbmodalidades.Mda_Descripcion,
        tbhorarios.Hor_Año,
        tbhorarios.Hor_EsEliminado,
        tbhorarios.Hor_UsuarioRegistra,
        tbhorarios.Hor_FechaRegistra,
        tbhorarios.Hor_UsuarioModifica,
        tbhorarios.Hor_FechaModifica
    FROM [app].[tbHorario] tbhorarios
    INNER JOIN [app].[tbCursos] tbcursos ON tbhorarios.Cur_Id = tbcursos.Cur_Id
    INNER JOIN [app].[tbCursosNiveles] tbcursosniveles ON tbhorarios.Cun_Id = tbcursosniveles.Cun_Id
    INNER JOIN [app].[tbMaterias] tbmaterias ON tbhorarios.Mat_Id = tbmaterias.Mat_Id
    INNER JOIN [app].[tbEmpleados] tbempleados ON tbhorarios.Emp_Id = tbempleados.Emp_Id
    INNER JOIN [app].[tbPersonas] tbpersonas ON tbempleados.Per_Id = tbpersonas.Per_Id
    INNER JOIN [app].[tbSecciones] tbsecciones ON tbhorarios.Sec_Id = tbsecciones.Sec_Id
    INNER JOIN [app].[tbAulas] tbaulas ON tbhorarios.Aul_Id = tbaulas.Aul_Id
    INNER JOIN [app].[tbDias] tbdias ON tbhorarios.Dia_Id = tbdias.Dia_Id
    INNER JOIN [app].[tbHoras] tbhorasinicio ON tbhorarios.Hor_HoraInicio = tbhorasinicio.Hor_Id
    INNER JOIN [app].[tbHoras] tbhorasfinaliza ON tbhorarios.Hor_HoraFinaliza = tbhorasfinaliza.Hor_Id
    INNER JOIN [app].[tbSemestres] tbsemestres ON tbhorarios.Sem_Id = tbsemestres.Sem_Id
    LEFT JOIN [app].[tbModalidades] tbmodalidades ON tbhorarios.Mda_Id = tbmodalidades.Mda_Id
    WHERE tbhorarios.Hor_EsEliminado = 0
    ORDER BY tbhorarios.Hor_Año DESC, tbsemestres.Sem_Descripcion, tbsecciones.Sec_Descripcion, tbdias.Dia_Id, tbhorasinicio.Hor_Hora;
END
GO
