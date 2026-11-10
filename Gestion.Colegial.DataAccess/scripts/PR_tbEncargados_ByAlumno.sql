-- =============================================================================
-- SP: dbo.PR_tbEncargados_ByAlumno
-- Descripción: Retorna los encargados vinculados a un alumno con datos de
--              persona, parentesco e indicador de encargado principal.
-- Parámetros:  @Alu_Id — identificador del alumno
-- Uso desde:   Ficha del Alumno / tab Familia
-- =============================================================================

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_tbEncargados_ByAlumno]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[PR_tbEncargados_ByAlumno];
GO

CREATE PROCEDURE [dbo].[PR_tbEncargados_ByAlumno]
    @Alu_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        E.Enc_Id,
        EA.Par_Id,
        P.Par_Descripcion,
        Pe.Per_Id,
        Pe.Per_PrimerNombre,
        Pe.Per_SegundoNombre,
        Pe.Per_ApellidoPaterno,
        Pe.Per_ApellidoMaterno,
        Pe.Per_Telefono,
        Pe.Per_CorreoElectronico,
        Pe.Per_Direccion,
        E.Enc_Ocupacion,
        CAST(CASE WHEN ROW_NUMBER() OVER (ORDER BY E.Enc_Id) = 1 THEN 1 ELSE 0 END AS BIT) AS EncargadoPrincipal
    FROM app.tbEncargados E
    INNER JOIN app.tbEncargados_tbAlumnos EA ON E.Enc_Id = EA.Enc_Id
    INNER JOIN app.tbPersonas Pe ON E.Per_Id = Pe.Per_Id
    LEFT JOIN app.tbParentescos P ON EA.Par_Id = P.Par_Id
    WHERE EA.Alu_Id = @Alu_Id
    ORDER BY E.Enc_Id;
END;
GO
