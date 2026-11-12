USE [DB_GestionColegial]
GO

-- ── tbPlanClases ─────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbPlanClases' AND schema_id = SCHEMA_ID('app'))
BEGIN
    CREATE TABLE [app].[tbPlanClases] (
        [Pla_Id]             INT IDENTITY(1,1)  NOT NULL,
        [Hor_Id]             INT                NOT NULL,
        [Pla_Semana]         SMALLINT           NOT NULL,
        [Pla_Tema]           NVARCHAR(200)      NOT NULL,
        [Pla_Objetivos]      NVARCHAR(MAX)      NULL,
        [Pla_Recursos]       NVARCHAR(300)      NULL,
        [Pla_Estado]         NVARCHAR(20)       NOT NULL CONSTRAINT [DF_tbPlanClases_Estado] DEFAULT ('Pendiente'),
        [Pla_EsEliminado]    BIT                NOT NULL CONSTRAINT [DF_tbPlanClases_EsEliminado] DEFAULT (0),
        [Pla_UsuarioRegistra] INT               NOT NULL,
        [Pla_FechaRegistra]  DATETIME           NOT NULL CONSTRAINT [DF_tbPlanClases_FechaRegistra] DEFAULT (GETDATE()),
        [Pla_UsuarioModifica] INT               NULL,
        [Pla_FechaModifica]  DATETIME           NULL,
        CONSTRAINT [PK_tbPlanClases] PRIMARY KEY CLUSTERED ([Pla_Id] ASC),
        CONSTRAINT [FK_tbPlanClases_Hor_Id] FOREIGN KEY ([Hor_Id]) REFERENCES [app].[tbHorarios]([Hor_Id])
    );
    PRINT 'tbPlanClases creada.';
END
ELSE
    PRINT 'tbPlanClases ya existe.';
GO

-- ── tbTareas ─────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbTareas' AND schema_id = SCHEMA_ID('app'))
BEGIN
    CREATE TABLE [app].[tbTareas] (
        [Tar_Id]             INT IDENTITY(1,1)  NOT NULL,
        [Hor_Id]             INT                NOT NULL,
        [Tar_Titulo]         NVARCHAR(200)      NOT NULL,
        [Tar_Descripcion]    NVARCHAR(MAX)      NULL,
        [Tar_FechaEntrega]   DATE               NOT NULL,
        [Tar_Punteo]         DECIMAL(5,2)       NOT NULL CONSTRAINT [DF_tbTareas_Punteo] DEFAULT (100),
        [Tar_Estado]         NVARCHAR(20)       NOT NULL CONSTRAINT [DF_tbTareas_Estado] DEFAULT ('Activa'),
        [Tar_EsEliminado]    BIT                NOT NULL CONSTRAINT [DF_tbTareas_EsEliminado] DEFAULT (0),
        [Tar_UsuarioRegistra] INT               NOT NULL,
        [Tar_FechaRegistra]  DATETIME           NOT NULL CONSTRAINT [DF_tbTareas_FechaRegistra] DEFAULT (GETDATE()),
        [Tar_UsuarioModifica] INT               NULL,
        [Tar_FechaModifica]  DATETIME           NULL,
        CONSTRAINT [PK_tbTareas] PRIMARY KEY CLUSTERED ([Tar_Id] ASC),
        CONSTRAINT [FK_tbTareas_Hor_Id] FOREIGN KEY ([Hor_Id]) REFERENCES [app].[tbHorarios]([Hor_Id])
    );
    PRINT 'tbTareas creada.';
END
ELSE
    PRINT 'tbTareas ya existe.';
GO
