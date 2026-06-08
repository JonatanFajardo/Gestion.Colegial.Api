-- =====================================================================
-- Procedure: PR_tbHorarios_Find
-- Descripción: Obtiene un horario/clase por su ID
-- Fecha: 2025-11-27
-- =====================================================================

USE [DB_GestionColegial]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarios_Find]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarios_Find]
GO

CREATE PROCEDURE [app].[PR_tbHorarios_Find]
    @Hor_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        h.Hor_Id,
        h.Cur_Id,
        c.Cur_Nombre,
        h.Cun_Id,
        cn.Cun_Descripcion,
        h.Mat_Id,
        m.Mat_Nombre,
        h.Emp_Id,
        CONCAT(e.Emp_PrimerNombre, ' ', ISNULL(e.Emp_SegundoNombre, ''), ' ', e.Emp_PrimerApellido, ' ', ISNULL(e.Emp_SegundoApellido, '')) AS Emp_NombreCompleto,
        h.Sec_Id,
        s.Sec_Descripcion,
        h.Aul_Id,
        a.Aul_Descripcion,
        h.Dia_Id,
        d.Dia_Descripcion,
        h.Hor_HoraInicio,
        hi.Hor_Hora AS Hor_HoraInicioDescripcion,
        h.Hor_HoraFinaliza,
        hf.Hor_Hora AS Hor_HoraFinalizaDescripcion,
        h.Sem_Id,
        sem.Sem_Descripcion,
        h.Mda_Id,
        mda.Mda_Descripcion,
        h.Hor_Año,
        h.Hor_EsEliminado,
        h.Hor_UsuarioRegistra,
        h.Hor_FechaRegistra,
        h.Hor_UsuarioModifica,
        h.Hor_FechaModifica
    FROM [app].[tbHorarios] h
    INNER JOIN [app].[tbCursos] c ON h.Cur_Id = c.Cur_Id
    INNER JOIN [app].[tbCursosNiveles] cn ON h.Cun_Id = cn.Cun_Id
    INNER JOIN [app].[tbMaterias] m ON h.Mat_Id = m.Mat_Id
    INNER JOIN [app].[tbEmpleados] e ON h.Emp_Id = e.Emp_Id
    INNER JOIN [app].[tbSecciones] s ON h.Sec_Id = s.Sec_Id
    INNER JOIN [app].[tbAulas] a ON h.Aul_Id = a.Aul_Id
    INNER JOIN [app].[tbDias] d ON h.Dia_Id = d.Dia_Id
    INNER JOIN [app].[tbHoras] hi ON h.Hor_HoraInicio = hi.Hor_Id
    INNER JOIN [app].[tbHoras] hf ON h.Hor_HoraFinaliza = hf.Hor_Id
    INNER JOIN [app].[tbSemestres] sem ON h.Sem_Id = sem.Sem_Id
    LEFT JOIN [app].[tbModalidades] mda ON h.Mda_Id = mda.Mda_Id
    WHERE h.Hor_Id = @Hor_Id
      AND h.Hor_EsEliminado = 0;
END
GO
