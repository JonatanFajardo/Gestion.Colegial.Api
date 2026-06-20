-- =============================================================
-- 02_CREATE_tbBoletinesGraduados.sql
-- Boletin consolidado por materia/anio del alumno graduado.
-- Una sola FK entrante permitida: hacia tbAlumnosGraduados.
-- =============================================================
USE DB_GestionColegial;
GO

IF OBJECT_ID('app.tbBoletinesGraduados', 'U') IS NOT NULL
    DROP TABLE app.tbBoletinesGraduados;
GO

CREATE TABLE app.tbBoletinesGraduados
(
    BolGrad_Id              INT IDENTITY(1,1) NOT NULL,
    AluGrad_Id              INT             NOT NULL,

    -- Snapshot academico de la fila de boletin
    BolGrad_Anio                INT             NOT NULL,
    BolGrad_NivelEducativo      NVARCHAR(100)   NULL,
    BolGrad_Grado               NVARCHAR(100)   NULL,
    BolGrad_Seccion             NVARCHAR(50)    NULL,
    BolGrad_Materia             NVARCHAR(150)   NOT NULL,

    -- Notas por parcial (snapshot textual / numerico)
    BolGrad_NotaParcial1        DECIMAL(5,2)    NULL,
    BolGrad_NotaParcial2        DECIMAL(5,2)    NULL,
    BolGrad_NotaParcial3        DECIMAL(5,2)    NULL,
    BolGrad_NotaParcial4        DECIMAL(5,2)    NULL,
    BolGrad_NotaFinal           DECIMAL(5,2)    NULL,
    BolGrad_Observaciones       NVARCHAR(500)   NULL,

    BolGrad_FechaArchivo        DATETIME        NOT NULL CONSTRAINT DF_BolGrad_FechaArchivo DEFAULT(GETDATE()),

    CONSTRAINT PK_tbBoletinesGraduados PRIMARY KEY CLUSTERED (BolGrad_Id),
    CONSTRAINT FK_tbBoletinesGraduados_tbAlumnosGraduados
        FOREIGN KEY (AluGrad_Id)
        REFERENCES app.tbAlumnosGraduados (AluGrad_Id)
);
GO

CREATE NONCLUSTERED INDEX IX_tbBoletinesGraduados_AluGrad
    ON app.tbBoletinesGraduados (AluGrad_Id, BolGrad_Anio);
GO
