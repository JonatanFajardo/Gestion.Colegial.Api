-- =============================================
-- SCRIPT: Eliminar TarMen_AnioVigencia y simplificar el sistema
-- Fecha: 2025-01-18
-- =============================================

USE [GestionColegial_V20_R2]
GO

-- =============================================
-- PASO 1: Eliminar constraint y campo TarMen_AnioVigencia
-- =============================================

-- Eliminar constraint único antiguo si existe
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_TarifaMensualidad_CursoModalidadAnio' AND object_id = OBJECT_ID('finanza.tbTarifasMensualidades'))
BEGIN
    ALTER TABLE finanza.tbTarifasMensualidades DROP CONSTRAINT UX_TarifaMensualidad_CursoModalidadAnio
    PRINT 'Constraint UX_TarifaMensualidad_CursoModalidadAnio eliminado'
END
ELSE
    PRINT 'Constraint UX_TarifaMensualidad_CursoModalidadAnio no existe'
GO

-- Eliminar columna TarMen_AnioVigencia si existe
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('finanza.tbTarifasMensualidades') AND name = 'TarMen_AnioVigencia')
BEGIN
    ALTER TABLE finanza.tbTarifasMensualidades DROP COLUMN TarMen_AnioVigencia
    PRINT 'Campo TarMen_AnioVigencia eliminado'
END
ELSE
    PRINT 'Campo TarMen_AnioVigencia no existe'
GO

-- Crear nuevo constraint único (solo Curso-Modalidad)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_TarifaMensualidad_CursoModalidad' AND object_id = OBJECT_ID('finanza.tbTarifasMensualidades'))
BEGIN
    ALTER TABLE finanza.tbTarifasMensualidades
    ADD CONSTRAINT UX_TarifaMensualidad_CursoModalidad UNIQUE (Cun_Id, Mda_Id)
    PRINT 'Constraint UX_TarifaMensualidad_CursoModalidad creado'
END
ELSE
    PRINT 'Constraint UX_TarifaMensualidad_CursoModalidad ya existe'
GO

-- =============================================
-- PASO 2: Actualizar procedimiento PR_GenerarMensualidad
-- =============================================

CREATE OR ALTER PROCEDURE finanza.PR_GenerarMensualidad
    @Mes TINYINT,              -- 1-12
    @Anio SMALLINT,            -- 2025
    @Usu_Id INT,               -- Usuario que ejecuta
    @ConceptoMensualidadId INT = NULL  -- ID del concepto "Mensualidad" (si es NULL, se busca automáticamente)
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables
    DECLARE @FechaEmision DATE = GETDATE()
    DECLARE @FechaVencimiento DATE = DATEADD(DAY, 10, @FechaEmision)
    DECLARE @EstadoPendienteId INT = 1  -- ID del estado "Pendiente"
    DECLARE @TotalGenerados INT = 0
    DECLARE @MontoTotal DECIMAL(18,2) = 0
    DECLARE @NombreMes NVARCHAR(20)

    -- Validaciones
    IF @Mes < 1 OR @Mes > 12
    BEGIN
        RAISERROR('El mes debe estar entre 1 y 12', 16, 1)
        RETURN
    END

    IF @Anio < 2020 OR @Anio > 2100
    BEGIN
        RAISERROR('El año debe estar entre 2020 y 2100', 16, 1)
        RETURN
    END

    -- Obtener concepto de mensualidad si no se especificó
    IF @ConceptoMensualidadId IS NULL
    BEGIN
        SELECT TOP 1 @ConceptoMensualidadId = Cpa_Id
        FROM finanza.tbConceptosPago
        WHERE Cpa_Descripcion LIKE '%Mensualidad%'
          AND Cpa_EsEliminado = 0

        IF @ConceptoMensualidadId IS NULL
        BEGIN
            RAISERROR('No se encontró un concepto de pago tipo "Mensualidad"', 16, 1)
            RETURN
        END
    END

    -- Obtener nombre del mes
    SET @NombreMes = CASE @Mes
        WHEN 1 THEN 'Enero' WHEN 2 THEN 'Febrero' WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril' WHEN 5 THEN 'Mayo' WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre' WHEN 11 THEN 'Noviembre' WHEN 12 THEN 'Diciembre'
    END

    BEGIN TRY
        BEGIN TRANSACTION

        -- Insertar cuentas por cobrar para todos los alumnos activos
        INSERT INTO finanza.tbCuentasCobrar (
            Alu_Id,
            Cpa_Id,
            Tar_Id,
            Cco_MontoOriginal,
            Cco_MontoDescuento,
            Cco_MontoMora,
            Cco_MontoTotal,
            Cco_MontoPendiente,
            Cco_FechaEmision,
            Cco_FechaVencimiento,
            Epa_Id,
            Cco_Mes,
            Cco_Anio,
            Cco_Observaciones,
            Cco_EsEliminado,
            Cco_UsuarioRegistra,
            Cco_FechaRegistra
        )
        SELECT
            A.Alu_Id,
            @ConceptoMensualidadId,
            TM.TarMen_Id,
            TM.TarMen_Monto,                -- Monto original
            0,                               -- Sin descuento inicial
            0,                               -- Sin mora inicial
            TM.TarMen_Monto,                 -- Monto total
            TM.TarMen_Monto,                 -- Monto pendiente
            @FechaEmision,
            @FechaVencimiento,
            @EstadoPendienteId,
            @Mes,
            @Anio,
            'Mensualidad ' + @NombreMes + ' ' + CAST(@Anio AS NVARCHAR(4)),
            0,
            @Usu_Id,
            GETDATE()
        FROM app.tbAlumnos A
        INNER JOIN app.tbPersonas P ON A.Per_Id = P.Per_Id
        INNER JOIN finanza.tbTarifasMensualidades TM
            ON TM.Cun_Id = A.Cun_Id
            AND TM.Mda_Id = A.Mda_Id
            AND TM.TarMen_EsActivo = 1
            AND TM.TarMen_EsEliminado = 0
        WHERE P.Per_EsEliminado = 0
          AND A.Est_Id = 1  -- Estado Activo
          -- Evitar duplicados: no generar si ya existe
          AND NOT EXISTS (
              SELECT 1
              FROM finanza.tbCuentasCobrar CC
              WHERE CC.Alu_Id = A.Alu_Id
                AND CC.Cpa_Id = @ConceptoMensualidadId
                AND CC.Cco_Mes = @Mes
                AND CC.Cco_Anio = @Anio
                AND CC.Cco_EsEliminado = 0
          )

        -- Obtener totales
        SET @TotalGenerados = @@ROWCOUNT

        SELECT @MontoTotal = SUM(TM.TarMen_Monto)
        FROM app.tbAlumnos A
        INNER JOIN app.tbPersonas P ON A.Per_Id = P.Per_Id
        INNER JOIN finanza.tbTarifasMensualidades TM
            ON TM.Cun_Id = A.Cun_Id
            AND TM.Mda_Id = A.Mda_Id
            AND TM.TarMen_EsActivo = 1
        INNER JOIN finanza.tbCuentasCobrar CC
            ON CC.Alu_Id = A.Alu_Id
            AND CC.Cco_Mes = @Mes
            AND CC.Cco_Anio = @Anio
            AND CC.Cco_EsEliminado = 0
        WHERE P.Per_EsEliminado = 0
          AND A.Est_Id = 1

        COMMIT TRANSACTION

        -- Retornar resumen
        SELECT
            @TotalGenerados AS TotalGenerados,
            ISNULL(@MontoTotal, 0) AS MontoTotal,
            @Mes AS Mes,
            @NombreMes AS NombreMes,
            @Anio AS Anio,
            'Mensualidades generadas exitosamente' AS Mensaje

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

PRINT 'Procedimiento finanza.PR_GenerarMensualidad actualizado (sin TarMen_AnioVigencia)'
GO

-- =============================================
-- FIN DEL SCRIPT
-- =============================================

PRINT ''
PRINT '========================================='
PRINT 'SCRIPT COMPLETADO EXITOSAMENTE'
PRINT '========================================='
PRINT ''
PRINT 'CAMBIOS REALIZADOS:'
PRINT '1. Campo TarMen_AnioVigencia eliminado de tbTarifasMensualidades'
PRINT '2. Constraint único actualizado (solo Cun_Id + Mda_Id)'
PRINT '3. Procedimiento PR_GenerarMensualidad actualizado'
PRINT ''
PRINT 'NOTA: Ahora las tarifas son permanentes por curso/modalidad'
PRINT 'Puedes ejecutar: EXEC finanza.PR_GenerarMensualidad @Mes=1, @Anio=2025, @Usu_Id=1'
PRINT ''
GO
