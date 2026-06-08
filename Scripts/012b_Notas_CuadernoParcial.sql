USE [DB_GestionColegial]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_Notas_CuadernoParcial]') AND type IN (N'P',N'PC'))
    DROP PROCEDURE [app].[PR_Notas_CuadernoParcial]
GO

CREATE PROCEDURE [app].[PR_Notas_CuadernoParcial]
    @Sec_Id  INT,
    @Mat_Id  INT,
    @Par_Id  INT,
    @Sem_Id  INT,
    @Anio    INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.Alu_Id,
        CONCAT(p.Per_PrimerNombre, ' ', ISNULL(p.Per_SegundoNombre,''), ' ',
               p.Per_ApellidoPaterno, ' ', ISNULL(p.Per_ApellidoMaterno,'')) AS Alu_NombreCompleto,
        n.Not_Id,
        n.Not_Nota,
        n.Not_FechaRegistra,
        n.Not_FechaModifica
    FROM   [app].[tbAlumnos]  a
    INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
    LEFT  JOIN [app].[tbNotas]    n ON n.Alu_Id = a.Alu_Id
                                   AND n.Sec_Id  = @Sec_Id
                                   AND n.Mat_Id  = @Mat_Id
                                   AND n.Pac_Id  = @Par_Id
                                   AND n.Sem_Id  = @Sem_Id
                                   AND YEAR(n.Not_Año) = @Anio
                                   AND n.Not_EsEliminado = 0
    WHERE  a.Sec_Id       = @Sec_Id
      AND  a.AnioCursado  = @Anio
    ORDER BY p.Per_ApellidoPaterno, p.Per_PrimerNombre;
END
GO

PRINT 'PR_Notas_CuadernoParcial creado OK';
GO
