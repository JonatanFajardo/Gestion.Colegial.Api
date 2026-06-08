-- =====================================================================
-- Script 012: Notas — Stored Procedures
-- Corrige PR_tbNotas_Insert (faltaba Alu_Id/Sec_Id) y
-- agrega PR_Notas_CuadernoParcial para el cuaderno de notas.
-- =====================================================================

USE [DB_GestionColegial]
GO

-- =====================================================================
-- SP: PR_tbNotas_Insert  (corregido — incluye Alu_Id y Sec_Id)
-- =====================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbNotas_Insert]') AND type IN (N'P',N'PC'))
    DROP PROCEDURE [app].[PR_tbNotas_Insert]
GO
CREATE PROCEDURE [app].[PR_tbNotas_Insert]
    @Alu_Id              INT,
    @Sec_Id              INT,
    @Mat_Id              INT,
    @Sem_Id              INT,
    @Par_Id              INT,
    @Not_Nota            DECIMAL(5,2),
    @Not_Año             DATE,
    @Not_UsuarioRegistra INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO [app].[tbNotas]
            ([Alu_Id],[Sec_Id],[Mat_Id],[Sem_Id],[Pac_Id],
             [Not_Nota],[Not_Año],[Not_EsActivo],[Not_EsEliminado],
             [Not_UsuarioRegistra],[Not_FechaRegistra])
        VALUES
            (@Alu_Id,@Sec_Id,@Mat_Id,@Sem_Id,@Par_Id,
             @Not_Nota,@Not_Año,1,0,
             @Not_UsuarioRegistra,GETDATE());
        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS Not_Id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS Not_Id;
    END CATCH
END
GO

-- =====================================================================
-- SP: PR_tbNotas_Update
-- =====================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbNotas_Update]') AND type IN (N'P',N'PC'))
    DROP PROCEDURE [app].[PR_tbNotas_Update]
GO
CREATE PROCEDURE [app].[PR_tbNotas_Update]
    @Not_Id              INT,
    @Not_Nota            DECIMAL(5,2),
    @Not_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [app].[tbNotas]
        SET [Not_Nota]            = @Not_Nota,
            [Not_UsuarioModifica] = @Not_UsuarioModifica,
            [Not_FechaModifica]   = GETDATE()
        WHERE [Not_Id] = @Not_Id AND [Not_EsEliminado] = 0;
        COMMIT TRANSACTION;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS CodeResult;
    END CATCH
END
GO

-- =====================================================================
-- SP: PR_Notas_CuadernoParcial
-- Devuelve todos los alumnos de la sección con su nota (o NULL si no tiene)
-- para un parcial / materia / semestre / año dados.
-- =====================================================================
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
        p.Per_FechaNacimiento,
        n.Not_Id,
        n.Not_Nota,
        n.Not_FechaRegistra,
        n.Not_FechaModifica
    FROM   [app].[tbAlumnos]   a
    INNER JOIN [app].[tbPersonas] p   ON a.Per_Id   = p.Per_Id
    -- Relación alumno → sección vía matrícula vigente
    INNER JOIN [app].[tbMatriculas] m ON a.Alu_Id = m.Alu_Id
                                      AND m.Sec_Id = @Sec_Id
                                      AND YEAR(m.Mat_Fecha) = @Anio
                                      AND m.Mat_EsEliminado = 0
    LEFT JOIN [app].[tbNotas] n ON n.Alu_Id = a.Alu_Id
                                AND n.Sec_Id = @Sec_Id
                                AND n.Mat_Id = @Mat_Id
                                AND n.Pac_Id = @Par_Id
                                AND n.Sem_Id = @Sem_Id
                                AND YEAR(n.Not_Año) = @Anio
                                AND n.Not_EsEliminado = 0
    WHERE  a.Alu_EsEliminado = 0
    ORDER BY p.Per_ApellidoPaterno, p.Per_PrimerNombre;
END
GO

-- =====================================================================
-- SP: PR_Notas_BoletinAlumno
-- Todas las notas de un alumno en un año/semestre (para el boletín).
-- =====================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_Notas_BoletinAlumno]') AND type IN (N'P',N'PC'))
    DROP PROCEDURE [app].[PR_Notas_BoletinAlumno]
GO
CREATE PROCEDURE [app].[PR_Notas_BoletinAlumno]
    @Alu_Id  INT,
    @Sem_Id  INT,
    @Anio    INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        n.Not_Id,
        n.Mat_Id,
        m.Mat_Nombre,
        n.Pac_Id,
        pr.Pac_Descripcion,
        n.Not_Nota,
        n.Sem_Id,
        sem.Sem_Descripcion,
        n.Not_Año
    FROM   [app].[tbNotas]    n
    INNER JOIN [app].[tbMaterias]  m   ON n.Mat_Id  = m.Mat_Id
    INNER JOIN [app].[tbParciales] pr  ON n.Pac_Id  = pr.Pac_Id
    INNER JOIN [app].[tbSemestres] sem ON n.Sem_Id  = sem.Sem_Id
    WHERE  n.Alu_Id         = @Alu_Id
      AND  n.Sem_Id         = @Sem_Id
      AND  YEAR(n.Not_Año)  = @Anio
      AND  n.Not_EsEliminado = 0
    ORDER BY m.Mat_Nombre, pr.Pac_Descripcion;
END
GO

PRINT 'Script 012 completado: SPs de Notas listos.';
GO
