-- Permite llamar al dropdown sin Niv_Id para obtener todos los cursos
ALTER PROCEDURE [dbo].[PR_tbCursosNiveles_By_tbNivelesEducativos_Dropdown]
    @Niv_Id INT = NULL
AS
BEGIN
    SELECT  Cun_Id,
            Cun_Descripcion
    FROM    [app].[tbCursosNiveles]
    WHERE   (@Niv_Id IS NULL OR Niv_Id = @Niv_Id)
    ORDER BY Cun_Descripcion
END
GO
