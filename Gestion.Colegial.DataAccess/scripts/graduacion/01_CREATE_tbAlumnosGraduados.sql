-- =============================================================
-- 01_CREATE_tbAlumnosGraduados.sql
-- Snapshot plano del alumno al momento de la graduacion.
-- NO recibe FKs entrantes. NO mantiene FKs hacia tablas vivas.
-- Schema real del proyecto: app (no academico).
-- =============================================================
USE DB_GestionColegial;
GO

IF OBJECT_ID('app.tbAlumnosGraduados', 'U') IS NOT NULL
    DROP TABLE app.tbAlumnosGraduados;
GO

CREATE TABLE app.tbAlumnosGraduados
(
    AluGrad_Id              INT IDENTITY(1,1) NOT NULL,

    -- Datos personales (snapshot, copiados desde tbPersonas)
    AluGrad_Identidad           NVARCHAR(20)    NOT NULL,
    AluGrad_NombreCompleto      NVARCHAR(200)   NOT NULL,
    AluGrad_FechaNacimiento     DATE            NULL,
    AluGrad_Sexo                CHAR(1)         NULL,
    AluGrad_Correo              NVARCHAR(150)   NULL,
    AluGrad_Telefono            NVARCHAR(20)    NULL,

    -- Datos academicos (snapshot)
    AluGrad_NivelEducativo      NVARCHAR(100)   NULL,
    AluGrad_TituloObtenido      NVARCHAR(150)   NULL,
    AluGrad_AnioIngreso         INT             NULL,
    AluGrad_AnioGraduacion      INT             NOT NULL,

    -- Datos financieros consolidados
    AluGrad_TotalPagado         DECIMAL(18,2)   NOT NULL CONSTRAINT DF_AluGrad_TotalPagado DEFAULT(0),

    -- Encargados serializados (no se replican como tabla)
    AluGrad_EncargadosJson      NVARCHAR(MAX)   NULL,

    -- Referencia informativa al Alu_Id original (NO FK)
    AluGrad_AluIdOriginal       INT             NULL,

    -- Auditoria del archivado
    AluGrad_FechaArchivo        DATETIME        NOT NULL CONSTRAINT DF_AluGrad_FechaArchivo DEFAULT(GETDATE()),
    AluGrad_UsuarioArchivo      INT             NOT NULL,

    CONSTRAINT PK_tbAlumnosGraduados PRIMARY KEY CLUSTERED (AluGrad_Id)
);
GO

-- Identidad debe ser unica en el archivo de graduados
CREATE UNIQUE NONCLUSTERED INDEX UX_tbAlumnosGraduados_Identidad
    ON app.tbAlumnosGraduados (AluGrad_Identidad);
GO

-- Indice de busqueda por anio de graduacion
CREATE NONCLUSTERED INDEX IX_tbAlumnosGraduados_AnioGraduacion
    ON app.tbAlumnosGraduados (AluGrad_AnioGraduacion);
GO
