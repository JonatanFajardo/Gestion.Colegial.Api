/* =============================================================================
   065 · Escala de notas + umbrales del cuadro de honor

   - La escala traduce el promedio numérico (0-100, SACE Honduras) a un concepto en
     palabra/letra para el boletín: ej. 90-100 = "Excelente" (A). Cada fila es un rango
     (desde-hasta, ambos inclusive), con si APRUEBA o no y un orden de presentación.
   - Como las notas del sistema son numéricas y el concepto se deriva del rango al mostrar
     el boletín, editar la escala re-mapea en caliente; los documentos ya EMITIDOS quedan
     congelados (script 064), así que no se alteran.
   - Umbrales del cuadro de honor (una sola fila de configuración): promedio mínimo para
     entrar al Cuadro de Honor y al Cuadro de Honor Superior (como HR/HHR de RosarioSIS,
     pero sobre promedio 0-100 en vez de GPA).
   - FN_EscalaConcepto(@Promedio): función reutilizable que devuelve el concepto de un
     promedio según la escala vigente (la usarán boletín y cuadro de honor).
   - Permisos: "Escala de notas" (admin, director) para ver y configurar.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ---------------------------------------------------------------------------
   Tabla: filas de la escala (concepto por rango de promedio)
   --------------------------------------------------------------------------- */
IF OBJECT_ID('app.tbEscalaNotas') IS NULL
BEGIN
    CREATE TABLE app.tbEscalaNotas
    (
        Esc_Id              int           IDENTITY(1,1) NOT NULL,
        Esc_Concepto        nvarchar(40)  NOT NULL,
        Esc_Abreviatura     nvarchar(5)   NULL,
        Esc_NotaDesde       decimal(5,2)  NOT NULL,
        Esc_NotaHasta       decimal(5,2)  NOT NULL,
        Esc_Aprueba         bit           NOT NULL CONSTRAINT DF_tbEscalaNotas_Aprueba DEFAULT (1),
        Esc_Orden           int           NOT NULL CONSTRAINT DF_tbEscalaNotas_Orden DEFAULT (0),
        Esc_EsEliminado     bit           NOT NULL CONSTRAINT DF_tbEscalaNotas_EsEliminado DEFAULT (0),
        Esc_UsuarioRegistra int           NOT NULL,
        Esc_FechaRegistra   datetime      NOT NULL CONSTRAINT DF_tbEscalaNotas_FechaRegistra DEFAULT (GETDATE()),
        Esc_UsuarioModifica int           NULL,
        Esc_FechaModifica   datetime      NULL,
        CONSTRAINT PK_tbEscalaNotas PRIMARY KEY CLUSTERED (Esc_Id),
        CONSTRAINT CK_tbEscalaNotas_Rango CHECK (Esc_NotaDesde >= 0 AND Esc_NotaHasta <= 100 AND Esc_NotaDesde <= Esc_NotaHasta)
    );
END
GO

/* ---------------------------------------------------------------------------
   Tabla: configuración del cuadro de honor (una sola fila)
   --------------------------------------------------------------------------- */
IF OBJECT_ID('app.tbCuadroHonorConfig') IS NULL
BEGIN
    CREATE TABLE app.tbCuadroHonorConfig
    (
        Chc_Id                   int           NOT NULL,
        Chc_UmbralHonor          decimal(5,2)  NOT NULL,
        Chc_UmbralHonorSuperior  decimal(5,2)  NOT NULL,
        Chc_UsuarioModifica      int           NULL,
        Chc_FechaModifica        datetime      NULL,
        CONSTRAINT PK_tbCuadroHonorConfig PRIMARY KEY CLUSTERED (Chc_Id),
        CONSTRAINT CK_tbCuadroHonorConfig_Fila CHECK (Chc_Id = 1),
        CONSTRAINT CK_tbCuadroHonorConfig_Umbrales CHECK (Chc_UmbralHonor >= 0 AND Chc_UmbralHonorSuperior <= 100 AND Chc_UmbralHonor <= Chc_UmbralHonorSuperior)
    );
END
GO

/* ---------------------------------------------------------------------------
   Siembra inicial (editable en pantalla): escala conceptual típica de Honduras
   --------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM app.tbEscalaNotas)
BEGIN
    INSERT INTO app.tbEscalaNotas (Esc_Concepto, Esc_Abreviatura, Esc_NotaDesde, Esc_NotaHasta, Esc_Aprueba, Esc_Orden, Esc_UsuarioRegistra)
    VALUES
        (N'Excelente',       N'A', 90, 100, 1, 1, 1),
        (N'Muy Bueno',       N'B', 80,  89, 1, 2, 1),
        (N'Bueno',           N'C', 70,  79, 1, 3, 1),
        (N'Necesita Mejorar',N'D', 60,  69, 0, 4, 1),
        (N'Deficiente',      N'F',  0,  59, 0, 5, 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM app.tbCuadroHonorConfig)
    INSERT INTO app.tbCuadroHonorConfig (Chc_Id, Chc_UmbralHonor, Chc_UmbralHonorSuperior) VALUES (1, 90, 95);
GO

/* ---------------------------------------------------------------------------
   Función: concepto de un promedio según la escala vigente
   --------------------------------------------------------------------------- */
CREATE OR ALTER FUNCTION app.FN_EscalaConcepto (@Promedio decimal(5,2))
RETURNS nvarchar(40)
AS
BEGIN
    DECLARE @Concepto nvarchar(40);
    IF @Promedio IS NULL RETURN NULL;
    SELECT TOP 1 @Concepto = Esc_Concepto
    FROM app.tbEscalaNotas
    WHERE Esc_EsEliminado = 0 AND @Promedio >= Esc_NotaDesde AND @Promedio <= Esc_NotaHasta
    ORDER BY Esc_NotaDesde DESC;
    RETURN @Concepto;
END
GO

/* ---------------------------------------------------------------------------
   Procedimientos: CRUD de la escala
   --------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE app.PR_tbEscalaNotas_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Esc_Id, Esc_Concepto, Esc_Abreviatura, Esc_NotaDesde, Esc_NotaHasta, Esc_Aprueba, Esc_Orden
    FROM app.tbEscalaNotas
    WHERE Esc_EsEliminado = 0
    ORDER BY Esc_Orden, Esc_NotaDesde DESC;
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbEscalaNotas_Find
    @Esc_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Esc_Id, Esc_Concepto, Esc_Abreviatura, Esc_NotaDesde, Esc_NotaHasta, Esc_Aprueba, Esc_Orden
    FROM app.tbEscalaNotas
    WHERE Esc_Id = @Esc_Id AND Esc_EsEliminado = 0;
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbEscalaNotas_Detail
    @Esc_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.Esc_Id, e.Esc_Concepto, e.Esc_Abreviatura, e.Esc_NotaDesde, e.Esc_NotaHasta, e.Esc_Aprueba, e.Esc_Orden,
           app.FN_NombreUsuario(e.Esc_UsuarioRegistra) AS Esc_RegistradoPor, e.Esc_FechaRegistra,
           app.FN_NombreUsuario(e.Esc_UsuarioModifica) AS Esc_ModificadoPor, e.Esc_FechaModifica
    FROM app.tbEscalaNotas e
    WHERE e.Esc_Id = @Esc_Id AND e.Esc_EsEliminado = 0;
END
GO

-- Choque de rangos: existe otra fila activa cuyo rango se solapa con el dado.
CREATE OR ALTER PROCEDURE app.PR_tbEscalaNotas_Exist
    @Esc_NotaDesde decimal(5,2),
    @Esc_NotaHasta decimal(5,2),
    @Esc_Id        int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 Esc_Id, Esc_Concepto, Esc_NotaDesde, Esc_NotaHasta
    FROM app.tbEscalaNotas
    WHERE Esc_EsEliminado = 0
      AND (@Esc_Id IS NULL OR Esc_Id <> @Esc_Id)
      AND @Esc_NotaDesde <= Esc_NotaHasta
      AND @Esc_NotaHasta >= Esc_NotaDesde
    ORDER BY Esc_NotaDesde;
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbEscalaNotas_Insert
    @Esc_Concepto        nvarchar(40),
    @Esc_Abreviatura     nvarchar(5),
    @Esc_NotaDesde       decimal(5,2),
    @Esc_NotaHasta       decimal(5,2),
    @Esc_Aprueba         bit,
    @Esc_Orden           int,
    @Esc_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO app.tbEscalaNotas (Esc_Concepto, Esc_Abreviatura, Esc_NotaDesde, Esc_NotaHasta, Esc_Aprueba, Esc_Orden, Esc_UsuarioRegistra)
    VALUES (@Esc_Concepto, NULLIF(LTRIM(RTRIM(@Esc_Abreviatura)), ''), @Esc_NotaDesde, @Esc_NotaHasta, @Esc_Aprueba, @Esc_Orden, @Esc_UsuarioRegistra);
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbEscalaNotas_Update
    @Esc_Id              int,
    @Esc_Concepto        nvarchar(40),
    @Esc_Abreviatura     nvarchar(5),
    @Esc_NotaDesde       decimal(5,2),
    @Esc_NotaHasta       decimal(5,2),
    @Esc_Aprueba         bit,
    @Esc_Orden           int,
    @Esc_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE app.tbEscalaNotas
    SET Esc_Concepto    = @Esc_Concepto,
        Esc_Abreviatura = NULLIF(LTRIM(RTRIM(@Esc_Abreviatura)), ''),
        Esc_NotaDesde   = @Esc_NotaDesde,
        Esc_NotaHasta   = @Esc_NotaHasta,
        Esc_Aprueba     = @Esc_Aprueba,
        Esc_Orden       = @Esc_Orden,
        Esc_UsuarioModifica = @Esc_UsuarioModifica,
        Esc_FechaModifica   = GETDATE()
    WHERE Esc_Id = @Esc_Id AND Esc_EsEliminado = 0;
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbEscalaNotas_Delete
    @Esc_Id int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE app.tbEscalaNotas
    SET Esc_EsEliminado = 1, Esc_FechaModifica = GETDATE()
    WHERE Esc_Id = @Esc_Id AND Esc_EsEliminado = 0;
END
GO

/* ---------------------------------------------------------------------------
   Procedimientos: configuración del cuadro de honor
   --------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE app.PR_tbCuadroHonorConfig_Get
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Chc_Id, Chc_UmbralHonor, Chc_UmbralHonorSuperior
    FROM app.tbCuadroHonorConfig
    WHERE Chc_Id = 1;
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbCuadroHonorConfig_Set
    @Chc_UmbralHonor         decimal(5,2),
    @Chc_UmbralHonorSuperior decimal(5,2),
    @Chc_UsuarioModifica     int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE app.tbCuadroHonorConfig
    SET Chc_UmbralHonor         = @Chc_UmbralHonor,
        Chc_UmbralHonorSuperior = @Chc_UmbralHonorSuperior,
        Chc_UsuarioModifica     = @Chc_UsuarioModifica,
        Chc_FechaModifica       = GETDATE()
    WHERE Chc_Id = 1;

    IF @@ROWCOUNT = 0
        INSERT INTO app.tbCuadroHonorConfig (Chc_Id, Chc_UmbralHonor, Chc_UmbralHonorSuperior, Chc_UsuarioModifica, Chc_FechaModifica)
        VALUES (1, @Chc_UmbralHonor, @Chc_UmbralHonorSuperior, @Chc_UsuarioModifica, GETDATE());
END
GO

/* ---------------------------------------------------------------------------
   Permisos
   --------------------------------------------------------------------------- */
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES
    (N'Escala de notas', N'|1|1002|');

INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
SELECT x.Nombre, 1, 0, 'Academico'
FROM @Pantallas x
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas p WHERE p.Pan_Descripcion = x.Nombre);

INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN @Pantallas x ON x.Nombre = p.Pan_Descripcion
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0
                        AND x.Roles LIKE N'%|' + CONVERT(nvarchar(10), r.Rol_Id) + N'|%'
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas y WHERE y.Rol_Id = r.Rol_Id AND y.Pan_Id = p.Pan_Id);
GO
