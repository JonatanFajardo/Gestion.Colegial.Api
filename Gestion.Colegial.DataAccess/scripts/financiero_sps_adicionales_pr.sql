/* =============================================================
   CORRECCIÓN DE PROCEDIMIENTOS _Exist
   Se corrige el uso de la palabra reservada "Exists"
   ============================================================= */

-- PR_tbTarifas_Exist (CORREGIDO)
IF OBJECT_ID('finanza.PR_tbTarifas_Exist','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbTarifas_Exist;
GO
CREATE PROCEDURE finanza.PR_tbTarifas_Exist
    @Cpa_Id int,
    @Niv_Id int = NULL,
    @Cun_Id int = NULL,
    @Tar_AnioVigencia smallint,
    @Tar_Id int = NULL  -- Para excluir en Update
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Exists bit = 0;
    DECLARE @Message nvarchar(200) = '';

    IF EXISTS (
        SELECT 1 FROM finanza.tbTarifas
        WHERE Cpa_Id = @Cpa_Id
          AND (Niv_Id = @Niv_Id OR (Niv_Id IS NULL AND @Niv_Id IS NULL))
          AND (Cun_Id = @Cun_Id OR (Cun_Id IS NULL AND @Cun_Id IS NULL))
          AND Tar_AnioVigencia = @Tar_AnioVigencia
          AND Per_EsEliminado = 0
          AND (@Tar_Id IS NULL OR Tar_Id <> @Tar_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe una tarifa para este concepto y año.';
    END
    ELSE
    BEGIN
        SET @Message = 'La tarifa no existe.';
    END

    -- CORREGIDO: Usar corchetes para palabra reservada
    SELECT @Exists AS [Exists], @Message AS Message;
END
GO

-- PR_tbFormasPago_Exist (CORREGIDO)
IF OBJECT_ID('finanza.PR_tbFormasPago_Exist','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbFormasPago_Exist;
GO
CREATE PROCEDURE finanza.PR_tbFormasPago_Exist
    @Fpa_Descripcion nvarchar(80),
    @Fpa_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Exists bit = 0;
    DECLARE @Message nvarchar(200) = '';

    IF EXISTS (
        SELECT 1 FROM finanza.tbFormasPago
        WHERE Fpa_Descripcion = @Fpa_Descripcion
          AND Per_EsEliminado = 0
          AND (@Fpa_Id IS NULL OR Fpa_Id <> @Fpa_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe una forma de pago con esta descripción.';
    END
    ELSE
    BEGIN
        SET @Message = 'La forma de pago no existe.';
    END

    -- CORREGIDO: Usar corchetes para palabra reservada
    SELECT @Exists AS [Exists], @Message AS Message;
END
GO

-- PR_tbDescuentos_Exist (CORREGIDO)
IF OBJECT_ID('finanza.PR_tbDescuentos_Exist','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbDescuentos_Exist;
GO
CREATE PROCEDURE finanza.PR_tbDescuentos_Exist
    @Des_Descripcion nvarchar(120),
    @Des_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Exists bit = 0;
    DECLARE @Message nvarchar(200) = '';

    IF EXISTS (
        SELECT 1 FROM finanza.tbDescuentos
        WHERE Des_Descripcion = @Des_Descripcion
          AND Per_EsEliminado = 0
          AND (@Des_Id IS NULL OR Des_Id <> @Des_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe un descuento con esta descripción.';
    END
    ELSE
    BEGIN
        SET @Message = 'El descuento no existe.';
    END

    -- CORREGIDO: Usar corchetes para palabra reservada
    SELECT @Exists AS [Exists], @Message AS Message;
END
GO

-- PR_tbEstadosPago_Exist (CORREGIDO)
IF OBJECT_ID('finanza.PR_tbEstadosPago_Exist','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbEstadosPago_Exist;
GO
CREATE PROCEDURE finanza.PR_tbEstadosPago_Exist
    @Epa_Descripcion nvarchar(50),
    @Epa_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Exists bit = 0;
    DECLARE @Message nvarchar(200) = '';

    IF EXISTS (
        SELECT 1 FROM finanza.tbEstadosPago
        WHERE Epa_Descripcion = @Epa_Descripcion
          AND Per_EsEliminado = 0
          AND (@Epa_Id IS NULL OR Epa_Id <> @Epa_Id)
    )
    BEGIN
        SET @Exists = 1;
        SET @Message = 'Ya existe un estado de pago con esta descripción.';
    END
    ELSE
    BEGIN
        SET @Message = 'El estado de pago no existe.';
    END

    -- CORREGIDO: Usar corchetes para palabra reservada
    SELECT @Exists AS [Exists], @Message AS Message;
END
GO

/* =============================================================
   PRUEBAS DE VALIDACIÓN
   ============================================================= */

-- Prueba 1: Verificar que los procedimientos se crearon correctamente
PRINT '=== Verificando procedimientos corregidos ===';
GO

SELECT 
    OBJECT_NAME(object_id) AS NombreProcedimiento,
    create_date AS FechaCreacion,
    modify_date AS FechaModificacion
FROM sys.procedures
WHERE name IN (
    'PR_tbTarifas_Exist',
    'PR_tbFormasPago_Exist',
    'PR_tbDescuentos_Exist',
    'PR_tbEstadosPago_Exist'
)
ORDER BY name;
GO

-- Prueba 2: Ejecutar cada procedimiento para verificar sintaxis
PRINT '=== Probando ejecución de procedimientos ===';
GO

EXEC finanza.PR_tbTarifas_Exist 
    @Cpa_Id = 1, 
    @Tar_AnioVigencia = 2024;

EXEC finanza.PR_tbFormasPago_Exist 
    @Fpa_Descripcion = 'Efectivo';

EXEC finanza.PR_tbDescuentos_Exist 
    @Des_Descripcion = 'Descuento Prueba';

EXEC finanza.PR_tbEstadosPago_Exist 
    @Epa_Descripcion = 'Pendiente';
GO

PRINT '=== Corrección completada exitosamente ===';