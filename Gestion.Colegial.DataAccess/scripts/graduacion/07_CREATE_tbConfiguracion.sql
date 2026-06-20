-- =========================================================================
-- 07_CREATE_tbConfiguracion.sql
-- =========================================================================
-- Tabla clave/valor de configuracion global. Persiste parametros editables
-- por administradores que afectan el comportamiento del sistema.
--
-- Uso actual:
--   - 'nota_minima_aprobacion' (DECIMAL 0-100, default 70):
--     Umbral usado por app.vCandidatosGraduacion y app.spGraduarAlumno
--     para evaluar si las notas finales del alumno son aprobatorias.
--
-- Diseñado idempotente: ejecutable multiples veces sin error.
-- =========================================================================

IF OBJECT_ID('app.tbConfiguracion', 'U') IS NULL
BEGIN
    CREATE TABLE app.tbConfiguracion
    (
        Con_Clave           VARCHAR(100)  NOT NULL,
        Con_Valor           NVARCHAR(500) NOT NULL,
        Con_Descripcion     NVARCHAR(300) NULL,
        Con_FechaModifica   DATETIME      NULL,
        Con_UsuarioModifica INT           NULL,
        CONSTRAINT PK_tbConfiguracion PRIMARY KEY (Con_Clave)
    );
END
GO

-- Seed de la nota minima de aprobacion (idempotente)
IF NOT EXISTS (SELECT 1 FROM app.tbConfiguracion WHERE Con_Clave = 'nota_minima_aprobacion')
BEGIN
    INSERT INTO app.tbConfiguracion (Con_Clave, Con_Valor, Con_Descripcion)
    VALUES (
        'nota_minima_aprobacion',
        N'70',
        N'Nota minima requerida para aprobar una materia (0-100). Usado por la graduacion de alumnos.'
    );
END
GO
