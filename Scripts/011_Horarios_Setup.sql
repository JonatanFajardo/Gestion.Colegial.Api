-- =====================================================================
-- Script 011: Horarios — Tabla y Stored Procedures
-- Descripción: Crea tabla tbHorarios (consolidada) y sus SPs CRUD
-- Nota: Corrige bug en PR_tbHorarios_List (referenciaba tbHorario sin 's')
--       y añade columna Hor_EsEliminado ausente en el CREATE original.
-- =====================================================================

USE [DB_GestionColegial]
GO

-- =====================================================================
-- TABLA: tbHorarios
-- =====================================================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[tbHorarios]') AND type = 'U')
BEGIN
    CREATE TABLE [app].[tbHorarios]
    (
        [Hor_Id]              INT IDENTITY(1,1) NOT NULL,
        CONSTRAINT [PK_tbHorarios] PRIMARY KEY CLUSTERED ([Hor_Id] ASC),
        [Cur_Id]              INT NOT NULL,
        [Cun_Id]              INT NOT NULL,
        [Mat_Id]              INT NOT NULL,
        [Emp_Id]              INT NOT NULL,
        [Sec_Id]              INT NOT NULL,
        [Aul_Id]              INT NOT NULL,
        [Dia_Id]              INT NOT NULL,
        [Hor_HoraInicio]      INT NOT NULL,
        [Hor_HoraFinaliza]    INT NOT NULL,
        [Sem_Id]              INT NOT NULL,
        [Mda_Id]              INT NULL,
        [Hor_Año]             INT NOT NULL,
        [Hor_EsEliminado]     BIT NOT NULL DEFAULT 0,
        [Hor_UsuarioRegistra] INT NOT NULL,
        [Hor_FechaRegistra]   DATETIME NOT NULL DEFAULT GETDATE(),
        [Hor_UsuarioModifica] INT NULL,
        [Hor_FechaModifica]   DATETIME NULL
    );

    -- FKs
    ALTER TABLE [app].[tbHorarios] WITH CHECK ADD CONSTRAINT [FK_tbHorarios_tbCursos]        FOREIGN KEY([Cur_Id]) REFERENCES [app].[tbCursos]       ([Cur_Id]);
    ALTER TABLE [app].[tbHorarios] WITH CHECK ADD CONSTRAINT [FK_tbHorarios_tbCursosNiveles]  FOREIGN KEY([Cun_Id]) REFERENCES [app].[tbCursosNiveles] ([Cun_Id]);
    ALTER TABLE [app].[tbHorarios] WITH CHECK ADD CONSTRAINT [FK_tbHorarios_tbMaterias]       FOREIGN KEY([Mat_Id]) REFERENCES [app].[tbMaterias]      ([Mat_Id]);
    ALTER TABLE [app].[tbHorarios] WITH CHECK ADD CONSTRAINT [FK_tbHorarios_tbEmpleados]      FOREIGN KEY([Emp_Id]) REFERENCES [app].[tbEmpleados]     ([Emp_Id]);
    ALTER TABLE [app].[tbHorarios] WITH CHECK ADD CONSTRAINT [FK_tbHorarios_tbSecciones]      FOREIGN KEY([Sec_Id]) REFERENCES [app].[tbSecciones]     ([Sec_Id]);
    ALTER TABLE [app].[tbHorarios] WITH CHECK ADD CONSTRAINT [FK_tbHorarios_tbAulas]          FOREIGN KEY([Aul_Id]) REFERENCES [app].[tbAulas]         ([Aul_Id]);
    ALTER TABLE [app].[tbHorarios] WITH CHECK ADD CONSTRAINT [FK_tbHorarios_tbDias]           FOREIGN KEY([Dia_Id]) REFERENCES [app].[tbDias]          ([Dia_Id]);
    ALTER TABLE [app].[tbHorarios] WITH CHECK ADD CONSTRAINT [FK_tbHorarios_tbHoras_Inicio]   FOREIGN KEY([Hor_HoraInicio])   REFERENCES [app].[tbHoras] ([Hor_Id]);
    ALTER TABLE [app].[tbHorarios] WITH CHECK ADD CONSTRAINT [FK_tbHorarios_tbHoras_Finaliza] FOREIGN KEY([Hor_HoraFinaliza]) REFERENCES [app].[tbHoras] ([Hor_Id]);
    ALTER TABLE [app].[tbHorarios] WITH CHECK ADD CONSTRAINT [FK_tbHorarios_tbSemestres]      FOREIGN KEY([Sem_Id]) REFERENCES [app].[tbSemestres]     ([Sem_Id]);
    ALTER TABLE [app].[tbHorarios] WITH CHECK ADD CONSTRAINT [FK_tbHorarios_tbModalidades]    FOREIGN KEY([Mda_Id]) REFERENCES [app].[tbModalidades]   ([Mda_Id]);

    ALTER TABLE [app].[tbHorarios] ADD CONSTRAINT [CHK_tbHorarios_Horas] CHECK ([Hor_HoraFinaliza] > [Hor_HoraInicio]);
    ALTER TABLE [app].[tbHorarios] ADD CONSTRAINT [CHK_tbHorarios_Año]   CHECK ([Hor_Año] >= 2020 AND [Hor_Año] <= 2100);

    PRINT 'Tabla tbHorarios creada.';
END
ELSE
BEGIN
    -- Agregar Hor_EsEliminado si la tabla ya existia sin esa columna
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('[app].[tbHorarios]') AND name = 'Hor_EsEliminado')
    BEGIN
        ALTER TABLE [app].[tbHorarios] ADD [Hor_EsEliminado] BIT NOT NULL DEFAULT 0;
        PRINT 'Columna Hor_EsEliminado agregada a tbHorarios.';
    END
END
GO

-- =====================================================================
-- SP: PR_tbHorarios_List
-- =====================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarios_List]') AND type IN (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarios_List]
GO
CREATE PROCEDURE [app].[PR_tbHorarios_List]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        h.Hor_Id,
        h.Cur_Id,        c.Cur_Nombre,
        h.Cun_Id,        cn.Cun_Descripcion,
        h.Mat_Id,        m.Mat_Nombre,
        h.Emp_Id,
        CONCAT(p.Per_PrimerNombre, ' ', ISNULL(p.Per_SegundoNombre, ''), ' ',
               p.Per_ApellidoPaterno, ' ', ISNULL(p.Per_ApellidoMaterno, '')) AS Emp_NombreCompleto,
        h.Sec_Id,        s.Sec_Descripcion,
        h.Aul_Id,        a.Aul_Descripcion,
        h.Dia_Id,        d.Dia_Descripcion,
        h.Hor_HoraInicio,     hi.Hor_Hora AS Hor_HoraInicioDescripcion,
        h.Hor_HoraFinaliza,   hf.Hor_Hora AS Hor_HoraFinalizaDescripcion,
        h.Sem_Id,        sem.Sem_Descripcion,
        h.Mda_Id,        mda.Mda_Descripcion,
        h.Hor_Año,
        h.Hor_EsEliminado,
        h.Hor_UsuarioRegistra,
        h.Hor_FechaRegistra,
        h.Hor_UsuarioModifica,
        h.Hor_FechaModifica
    FROM   [app].[tbHorarios] h
    INNER JOIN [app].[tbCursos]       c   ON h.Cur_Id          = c.Cur_Id
    INNER JOIN [app].[tbCursosNiveles] cn ON h.Cun_Id          = cn.Cun_Id
    INNER JOIN [app].[tbMaterias]     m   ON h.Mat_Id          = m.Mat_Id
    INNER JOIN [app].[tbEmpleados]    emp ON h.Emp_Id          = emp.Emp_Id
    INNER JOIN [app].[tbPersonas]     p   ON emp.Per_Id        = p.Per_Id
    INNER JOIN [app].[tbSecciones]    s   ON h.Sec_Id          = s.Sec_Id
    INNER JOIN [app].[tbAulas]        a   ON h.Aul_Id          = a.Aul_Id
    INNER JOIN [app].[tbDias]         d   ON h.Dia_Id          = d.Dia_Id
    INNER JOIN [app].[tbHoras]        hi  ON h.Hor_HoraInicio  = hi.Hor_Id
    INNER JOIN [app].[tbHoras]        hf  ON h.Hor_HoraFinaliza= hf.Hor_Id
    INNER JOIN [app].[tbSemestres]    sem ON h.Sem_Id          = sem.Sem_Id
    LEFT  JOIN [app].[tbModalidades]  mda ON h.Mda_Id          = mda.Mda_Id
    WHERE  h.Hor_EsEliminado = 0
    ORDER BY h.Hor_Año DESC, sem.Sem_Descripcion, s.Sec_Descripcion, d.Dia_Id, hi.Hor_Hora;
END
GO

-- =====================================================================
-- SP: PR_tbHorarios_Find
-- =====================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarios_Find]') AND type IN (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarios_Find]
GO
CREATE PROCEDURE [app].[PR_tbHorarios_Find]
    @Hor_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        h.Hor_Id,
        h.Cur_Id,        c.Cur_Nombre,
        h.Cun_Id,        cn.Cun_Descripcion,
        h.Mat_Id,        m.Mat_Nombre,
        h.Emp_Id,
        CONCAT(p.Per_PrimerNombre, ' ', ISNULL(p.Per_SegundoNombre, ''), ' ',
               p.Per_ApellidoPaterno, ' ', ISNULL(p.Per_ApellidoMaterno, '')) AS Emp_NombreCompleto,
        h.Sec_Id,        s.Sec_Descripcion,
        h.Aul_Id,        a.Aul_Descripcion,
        h.Dia_Id,        d.Dia_Descripcion,
        h.Hor_HoraInicio,     hi.Hor_Hora AS Hor_HoraInicioDescripcion,
        h.Hor_HoraFinaliza,   hf.Hor_Hora AS Hor_HoraFinalizaDescripcion,
        h.Sem_Id,        sem.Sem_Descripcion,
        h.Mda_Id,        mda.Mda_Descripcion,
        h.Hor_Año,
        h.Hor_EsEliminado,
        h.Hor_UsuarioRegistra,
        h.Hor_FechaRegistra,
        h.Hor_UsuarioModifica,
        h.Hor_FechaModifica
    FROM   [app].[tbHorarios] h
    INNER JOIN [app].[tbCursos]       c   ON h.Cur_Id          = c.Cur_Id
    INNER JOIN [app].[tbCursosNiveles] cn ON h.Cun_Id          = cn.Cun_Id
    INNER JOIN [app].[tbMaterias]     m   ON h.Mat_Id          = m.Mat_Id
    INNER JOIN [app].[tbEmpleados]    emp ON h.Emp_Id          = emp.Emp_Id
    INNER JOIN [app].[tbPersonas]     p   ON emp.Per_Id        = p.Per_Id
    INNER JOIN [app].[tbSecciones]    s   ON h.Sec_Id          = s.Sec_Id
    INNER JOIN [app].[tbAulas]        a   ON h.Aul_Id          = a.Aul_Id
    INNER JOIN [app].[tbDias]         d   ON h.Dia_Id          = d.Dia_Id
    INNER JOIN [app].[tbHoras]        hi  ON h.Hor_HoraInicio  = hi.Hor_Id
    INNER JOIN [app].[tbHoras]        hf  ON h.Hor_HoraFinaliza= hf.Hor_Id
    INNER JOIN [app].[tbSemestres]    sem ON h.Sem_Id          = sem.Sem_Id
    LEFT  JOIN [app].[tbModalidades]  mda ON h.Mda_Id          = mda.Mda_Id
    WHERE  h.Hor_Id = @Hor_Id
      AND  h.Hor_EsEliminado = 0;
END
GO

-- =====================================================================
-- SP: PR_tbHorarios_Insert
-- =====================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarios_Insert]') AND type IN (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarios_Insert]
GO
CREATE PROCEDURE [app].[PR_tbHorarios_Insert]
    @Cur_Id              INT,
    @Cun_Id              INT,
    @Mat_Id              INT,
    @Emp_Id              INT,
    @Sec_Id              INT,
    @Aul_Id              INT,
    @Dia_Id              INT,
    @Hor_HoraInicio      INT,
    @Hor_HoraFinaliza    INT,
    @Sem_Id              INT,
    @Mda_Id              INT = NULL,
    @Hor_Año             INT,
    @Hor_UsuarioRegistra INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO [app].[tbHorarios]
            ([Cur_Id],[Cun_Id],[Mat_Id],[Emp_Id],[Sec_Id],[Aul_Id],[Dia_Id],
             [Hor_HoraInicio],[Hor_HoraFinaliza],[Sem_Id],[Mda_Id],[Hor_Año],
             [Hor_EsEliminado],[Hor_UsuarioRegistra],[Hor_FechaRegistra])
        VALUES
            (@Cur_Id,@Cun_Id,@Mat_Id,@Emp_Id,@Sec_Id,@Aul_Id,@Dia_Id,
             @Hor_HoraInicio,@Hor_HoraFinaliza,@Sem_Id,@Mda_Id,@Hor_Año,
             0,@Hor_UsuarioRegistra,GETDATE());
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
-- SP: PR_tbHorarios_Update
-- =====================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarios_Update]') AND type IN (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarios_Update]
GO
CREATE PROCEDURE [app].[PR_tbHorarios_Update]
    @Hor_Id              INT,
    @Cur_Id              INT,
    @Cun_Id              INT,
    @Mat_Id              INT,
    @Emp_Id              INT,
    @Sec_Id              INT,
    @Aul_Id              INT,
    @Dia_Id              INT,
    @Hor_HoraInicio      INT,
    @Hor_HoraFinaliza    INT,
    @Sem_Id              INT,
    @Mda_Id              INT = NULL,
    @Hor_Año             INT,
    @Hor_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [app].[tbHorarios]
        SET [Cur_Id]              = @Cur_Id,
            [Cun_Id]              = @Cun_Id,
            [Mat_Id]              = @Mat_Id,
            [Emp_Id]              = @Emp_Id,
            [Sec_Id]              = @Sec_Id,
            [Aul_Id]              = @Aul_Id,
            [Dia_Id]              = @Dia_Id,
            [Hor_HoraInicio]      = @Hor_HoraInicio,
            [Hor_HoraFinaliza]    = @Hor_HoraFinaliza,
            [Sem_Id]              = @Sem_Id,
            [Mda_Id]              = @Mda_Id,
            [Hor_Año]             = @Hor_Año,
            [Hor_UsuarioModifica] = @Hor_UsuarioModifica,
            [Hor_FechaModifica]   = GETDATE()
        WHERE [Hor_Id] = @Hor_Id AND [Hor_EsEliminado] = 0;
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
-- SP: PR_tbHorarios_Delete  (soft delete)
-- =====================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_tbHorarios_Delete]') AND type IN (N'P', N'PC'))
    DROP PROCEDURE [app].[PR_tbHorarios_Delete]
GO
CREATE PROCEDURE [app].[PR_tbHorarios_Delete]
    @Hor_Id              INT,
    @Hor_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [app].[tbHorarios]
        SET [Hor_EsEliminado]     = 1,
            [Hor_UsuarioModifica] = @Hor_UsuarioModifica,
            [Hor_FechaModifica]   = GETDATE()
        WHERE [Hor_Id] = @Hor_Id AND [Hor_EsEliminado] = 0;
        COMMIT TRANSACTION;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS CodeResult;
    END CATCH
END
GO

PRINT 'Script 011 completado: tbHorarios y SPs listos.';
GO
