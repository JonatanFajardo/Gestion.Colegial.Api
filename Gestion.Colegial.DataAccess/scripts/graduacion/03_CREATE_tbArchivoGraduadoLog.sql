-- =============================================================
-- 03_CREATE_tbArchivoGraduadoLog.sql
-- Auditoria del proceso de archivado de graduados.
-- Registra cada DELETE/MIGRACION realizada por el flujo.
-- =============================================================
USE DB_GestionColegial;
GO

IF OBJECT_ID('app.tbArchivoGraduadoLog', 'U') IS NOT NULL
    DROP TABLE app.tbArchivoGraduadoLog;
GO

CREATE TABLE app.tbArchivoGraduadoLog
(
    LogArc_Id               BIGINT IDENTITY(1,1) NOT NULL,

    LogArc_AluGrad_Id           INT             NULL,  -- FK informativa al snapshot
    LogArc_AluIdOriginal        INT             NOT NULL,
    LogArc_TablaAfectada        NVARCHAR(150)   NOT NULL,
    LogArc_Accion               NVARCHAR(30)    NOT NULL,  -- DELETE | MIGRATE | AGGREGATE | SKIP
    LogArc_RegistrosAfectados   INT             NOT NULL CONSTRAINT DF_LogArc_RegistrosAfectados DEFAULT(0),
    LogArc_Detalle              NVARCHAR(MAX)   NULL,      -- JSON opcional con resumen / errores

    LogArc_FechaEvento          DATETIME        NOT NULL CONSTRAINT DF_LogArc_FechaEvento DEFAULT(GETDATE()),
    LogArc_UsuarioId            INT             NOT NULL,

    CONSTRAINT PK_tbArchivoGraduadoLog PRIMARY KEY CLUSTERED (LogArc_Id),
    CONSTRAINT FK_tbArchivoGraduadoLog_tbAlumnosGraduados
        FOREIGN KEY (LogArc_AluGrad_Id)
        REFERENCES app.tbAlumnosGraduados (AluGrad_Id)
);
GO

CREATE NONCLUSTERED INDEX IX_tbArchivoGraduadoLog_AluIdOriginal
    ON app.tbArchivoGraduadoLog (LogArc_AluIdOriginal);
GO

CREATE NONCLUSTERED INDEX IX_tbArchivoGraduadoLog_Fecha
    ON app.tbArchivoGraduadoLog (LogArc_FechaEvento);
GO
