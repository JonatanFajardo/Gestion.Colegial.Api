-- =====================================================================
-- Script 025: ConfiguracionSistema — Tabla, Seed y Stored Procedures
-- =====================================================================

-- Tabla
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'tbConfiguracion' AND schema_id = SCHEMA_ID('app'))
BEGIN
    CREATE TABLE app.tbConfiguracion (
        Con_Id          INT IDENTITY(1,1) PRIMARY KEY,
        Con_Clave       NVARCHAR(100) NOT NULL,
        Con_Valor       NVARCHAR(500) NULL,
        Con_Descripcion NVARCHAR(200) NULL,
        Con_Grupo       NVARCHAR(100) NULL DEFAULT 'General',
        Con_Tipo        NVARCHAR(50)  NULL DEFAULT 'texto',
        FechaModifica   DATETIME      NULL,
        UsuarioModifica INT           NULL,
        CONSTRAINT UQ_tbConfiguracion_Clave UNIQUE (Con_Clave)
    );

    -- Seed inicial
    INSERT INTO app.tbConfiguracion (Con_Clave, Con_Valor, Con_Descripcion, Con_Grupo, Con_Tipo) VALUES
    ('institucion_nombre',     'Colegio San José',   'Nombre de la institución',           'Institución', 'texto'),
    ('institucion_telefono',   '+504 0000-0000',     'Teléfono principal',                  'Institución', 'texto'),
    ('institucion_email',      'info@colegio.hn',    'Correo electrónico',                  'Institución', 'texto'),
    ('institucion_direccion',  'Ciudad, País',       'Dirección',                           'Institución', 'texto'),
    ('anio_lectivo_actual',    CAST(YEAR(GETDATE()) AS NVARCHAR(10)), 'Año lectivo en curso', 'Académico', 'numero'),
    ('max_alumnos_aula',       '35',                 'Máximo de alumnos por aula',          'Académico',   'numero'),
    ('nota_minima_aprobacion', '60',                 'Nota mínima para aprobar',            'Académico',   'numero'),
    ('moneda_simbolo',         'L.',                 'Símbolo de la moneda',                'Financiero',  'texto'),
    ('recargo_mora_pct',       '5',                  'Porcentaje de mora mensual',          'Financiero',  'numero');
END
GO

-- SP List
CREATE OR ALTER PROCEDURE app.PR_Configuracion_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        Con_Id,
        Con_Clave,
        Con_Valor,
        Con_Descripcion,
        Con_Grupo,
        Con_Tipo
    FROM app.tbConfiguracion
    ORDER BY Con_Grupo, Con_Clave;
END
GO

-- SP Update
CREATE OR ALTER PROCEDURE app.PR_Configuracion_Update
    @Con_Id          INT,
    @Con_Valor       NVARCHAR(500),
    @UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE app.tbConfiguracion
    SET
        Con_Valor       = @Con_Valor,
        FechaModifica   = GETDATE(),
        UsuarioModifica = @UsuarioModifica
    WHERE Con_Id = @Con_Id;
END
GO
