-- =============================================
-- SISTEMA SIMPLIFICADO DE MENSUALIDADES
-- Fecha: 2025-01-18
-- Descripción: Script completo para generar mensualidades automáticamente
-- =============================================

 

-- =============================================
-- PASO 1: CREAR TABLA DE TARIFAS MENSUALIDADES
---- =============================================

--IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbTarifasMensualidades' AND schema_id = SCHEMA_ID('finanza'))
--BEGIN
--    CREATE TABLE finanza.tbTarifasMensualidades
--    (
--        TarMen_Id INT PRIMARY KEY IDENTITY(1,1),
--        Cun_Id INT NOT NULL,                    -- CursoNivel (FK a app.tbCursosNiveles)
--        Mda_Id INT NOT NULL,                    -- Modalidad (FK a app.tbModalidades)
--        TarMen_Monto DECIMAL(18,2) NOT NULL,    -- Monto mensual
--        TarMen_AnioVigencia SMALLINT NOT NULL,  -- Año de vigencia (2025, 2026, etc.)
--        TarMen_EsActivo BIT NOT NULL DEFAULT 1,
--        TarMen_EsEliminado BIT NOT NULL DEFAULT 0,
--        TarMen_UsuarioRegistra INT NOT NULL,
--        TarMen_FechaRegistra DATETIME2(0) NOT NULL DEFAULT GETDATE(),
--        TarMen_UsuarioModifica INT NULL,
--        TarMen_FechaModifica DATETIME2(0) NULL,

--        -- Índice único para evitar duplicados
--        CONSTRAINT UX_TarifaMensualidad_CursoModalidadAnio
--            UNIQUE (Cun_Id, Mda_Id, TarMen_AnioVigencia)
--    )

--    PRINT 'Tabla finanza.tbTarifasMensualidades creada exitosamente'
--END
--ELSE
--    PRINT 'Tabla finanza.tbTarifasMensualidades ya existe'
--GO

-- =============================================
-- PASO 2: AGREGAR CAMPOS A tbCuentasCobrar
-- =============================================

-- Agregar campo Mes
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('finanza.tbCuentasCobrar') AND name = 'Cco_Mes')
BEGIN
    ALTER TABLE finanza.tbCuentasCobrar
    ADD Cco_Mes TINYINT NULL  -- 1-12 (Enero-Diciembre)

    PRINT 'Campo Cco_Mes agregado a tbCuentasCobrar'
END
ELSE
    PRINT 'Campo Cco_Mes ya existe en tbCuentasCobrar'
GO

-- Agregar campo Año
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('finanza.tbCuentasCobrar') AND name = 'Cco_Anio')
BEGIN
    ALTER TABLE finanza.tbCuentasCobrar
    ADD Cco_Anio SMALLINT NULL  -- 2025, 2026, etc.

    PRINT 'Campo Cco_Anio agregado a tbCuentasCobrar'
END
ELSE
    PRINT 'Campo Cco_Anio ya existe en tbCuentasCobrar'
GO

-- Crear índice único para evitar duplicados (misma mensualidad 2 veces)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_CuentaCobrar_AlumnoMesAnio' AND object_id = OBJECT_ID('finanza.tbCuentasCobrar'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_CuentaCobrar_AlumnoMesAnio
    ON finanza.tbCuentasCobrar(Alu_Id, Cco_Mes, Cco_Anio, Cpa_Id)
    WHERE Cco_EsEliminado = 0

    PRINT 'Índice UX_CuentaCobrar_AlumnoMesAnio creado exitosamente'
END
ELSE
    PRINT 'Índice UX_CuentaCobrar_AlumnoMesAnio ya existe'
GO

-- =============================================
-- PASO 3: PROCEDIMIENTO PRINCIPAL - GENERAR MENSUALIDAD
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
            AND TM.TarMen_AnioVigencia = @Anio
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
            AND TM.TarMen_AnioVigencia = @Anio
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

PRINT 'Procedimiento finanza.PR_GenerarMensualidad creado/actualizado'
GO

-- =============================================
-- PASO 4: PROCEDIMIENTO - GENERAR RANGO DE MENSUALIDADES
-- =============================================

CREATE OR ALTER PROCEDURE finanza.PR_GenerarMensualidadesRango
    @MesInicio TINYINT,
    @MesFin TINYINT,
    @Anio SMALLINT,
    @Usu_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @MesInicio < 1 OR @MesInicio > 12 OR @MesFin < 1 OR @MesFin > 12
    BEGIN
        RAISERROR('Los meses deben estar entre 1 y 12', 16, 1)
        RETURN
    END

    IF @MesInicio > @MesFin
    BEGIN
        RAISERROR('El mes inicial no puede ser mayor que el mes final', 16, 1)
        RETURN
    END

    DECLARE @MesActual TINYINT = @MesInicio
    DECLARE @TotalGeneradosTotal INT = 0
    DECLARE @MontoTotalTotal DECIMAL(18,2) = 0

    -- Tabla temporal para almacenar resultados
    CREATE TABLE #ResultadosMeses (
        Mes TINYINT,
        NombreMes NVARCHAR(20),
        TotalGenerados INT,
        MontoTotal DECIMAL(18,2)
    )

    BEGIN TRY
        WHILE @MesActual <= @MesFin
        BEGIN
            DECLARE @NombreMes NVARCHAR(20)
            DECLARE @TotalGen INT = 0
            DECLARE @MontoGen DECIMAL(18,2) = 0

            -- Ejecutar procedimiento para cada mes
            DECLARE @ResultadoTemp TABLE (
                TotalGenerados INT,
                MontoTotal DECIMAL(18,2),
                Mes TINYINT,
                NombreMes NVARCHAR(20),
                Anio SMALLINT,
                Mensaje NVARCHAR(200)
            )

            INSERT INTO @ResultadoTemp
            EXEC finanza.PR_GenerarMensualidad
                @Mes = @MesActual,
                @Anio = @Anio,
                @Usu_Id = @Usu_Id

            -- Obtener resultados
            SELECT
                @TotalGen = TotalGenerados,
                @MontoGen = MontoTotal,
                @NombreMes = NombreMes
            FROM @ResultadoTemp

            -- Acumular totales
            SET @TotalGeneradosTotal = @TotalGeneradosTotal + @TotalGen
            SET @MontoTotalTotal = @MontoTotalTotal + @MontoGen

            -- Guardar en tabla temporal
            INSERT INTO #ResultadosMeses VALUES (@MesActual, @NombreMes, @TotalGen, @MontoGen)

            -- Limpiar tabla temporal
            DELETE FROM @ResultadoTemp

            SET @MesActual = @MesActual + 1
        END

        -- Retornar resumen total
        SELECT
            @TotalGeneradosTotal AS TotalCuentasGeneradas,
            @MontoTotalTotal AS MontoTotalGenerado,
            @MesInicio AS MesInicio,
            @MesFin AS MesFin,
            @Anio AS Anio,
            'Mensualidades generadas exitosamente para el rango especificado' AS Mensaje

        -- Retornar detalle por mes
        SELECT * FROM #ResultadosMeses ORDER BY Mes

        -- Limpiar tabla temporal
        DROP TABLE #ResultadosMeses

    END TRY
    BEGIN CATCH
        -- Limpiar en caso de error
        IF OBJECT_ID('tempdb..#ResultadosMeses') IS NOT NULL
            DROP TABLE #ResultadosMeses

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

PRINT 'Procedimiento finanza.PR_GenerarMensualidadesRango creado/actualizado'
GO

-- =============================================
-- PASO 5: PROCEDIMIENTO - LISTAR MESES PENDIENTES POR ALUMNO
-- =============================================

CREATE OR ALTER PROCEDURE finanza.PR_MesesPendientesPorAlumno
    @Alu_Id INT,
    @Anio SMALLINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Anio IS NULL
        SET @Anio = YEAR(GETDATE())

    -- Generar todos los meses del año
    ;WITH Meses AS (
        SELECT 1 AS Mes, 'Enero' AS NombreMes
        UNION ALL SELECT 2, 'Febrero'
        UNION ALL SELECT 3, 'Marzo'
        UNION ALL SELECT 4, 'Abril'
        UNION ALL SELECT 5, 'Mayo'
        UNION ALL SELECT 6, 'Junio'
        UNION ALL SELECT 7, 'Julio'
        UNION ALL SELECT 8, 'Agosto'
        UNION ALL SELECT 9, 'Septiembre'
        UNION ALL SELECT 10, 'Octubre'
        UNION ALL SELECT 11, 'Noviembre'
        UNION ALL SELECT 12, 'Diciembre'
    )
    SELECT
        M.Mes,
        M.NombreMes,
        @Anio AS Anio,
        CASE
            WHEN CC.Cco_Id IS NULL THEN 'No Generado'
            WHEN CC.Cco_MontoPendiente = 0 THEN 'Pagado'
            WHEN CC.Cco_MontoPendiente > 0 AND CC.Cco_MontoPendiente < CC.Cco_MontoTotal THEN 'Pago Parcial'
            ELSE 'Pendiente'
        END AS Estado,
        ISNULL(CC.Cco_MontoTotal, 0) AS MontoTotal,
        ISNULL(CC.Cco_MontoPendiente, 0) AS MontoPendiente,
        ISNULL(CC.Cco_MontoTotal - CC.Cco_MontoPendiente, 0) AS MontoPagado,
        CC.Cco_FechaVencimiento,
        CASE
            WHEN CC.Cco_FechaVencimiento < GETDATE() AND CC.Cco_MontoPendiente > 0
            THEN 'Vencido'
            WHEN CC.Cco_Id IS NULL
            THEN 'N/A'
            ELSE 'Al día'
        END AS EstadoVencimiento,
        CASE
            WHEN CC.Cco_FechaVencimiento < GETDATE() AND CC.Cco_MontoPendiente > 0
            THEN DATEDIFF(DAY, CC.Cco_FechaVencimiento, GETDATE())
            ELSE 0
        END AS DiasVencido
    FROM Meses M
    LEFT JOIN finanza.tbCuentasCobrar CC
        ON CC.Alu_Id = @Alu_Id
        AND CC.Cco_Mes = M.Mes
        AND CC.Cco_Anio = @Anio
        AND CC.Cco_EsEliminado = 0
    ORDER BY M.Mes
END
GO

PRINT 'Procedimiento finanza.PR_MesesPendientesPorAlumno creado/actualizado'
GO

-- =============================================
-- PASO 6: PROCEDIMIENTO - LISTAR CUENTAS POR COBRAR POR ALUMNO
-- =============================================
CREATE OR ALTER PROCEDURE finanza.PR_tbCuentasCobrar_ListByAlumno
    @Alu_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CC.Cco_Id AS CuentaCobrarId,
        CC.Alu_Id AS AlumnoId,
        CC.Cpa_Id AS ConceptoPagoId,
        CC.Tar_Id AS TarifaId,
        CC.Cco_MontoOriginal AS MontoOriginal,
        CC.Cco_MontoDescuento AS MontoDescuento,
        CC.Cco_MontoMora AS MontoMora,
        CC.Cco_MontoTotal AS MontoTotal,
        CC.Cco_MontoPendiente AS MontoPendiente,
        CC.Cco_FechaEmision AS FechaEmision,
        CC.Cco_FechaVencimiento AS FechaVencimiento,
        CC.Epa_Id AS EstadoPagoId,
        CC.Cco_Mes AS Mes,
        CC.Cco_Anio AS Anio,
        CC.Cco_Observaciones AS Observaciones,
        CP.Cpa_Descripcion AS ConceptoDescripcion,
        EP.Epa_Descripcion AS EstadoPagoDescripcion,
        CC.Cco_MontoTotal - CC.Cco_MontoPendiente AS TotalPagado,
        CC.Cco_EsEliminado AS EsEliminado,
        CC.Cco_UsuarioRegistra AS UsuarioRegistraId,

        -- Nombre usuario registra
        CONCAT(UPA.Per_PrimerNombre, ' ', UPA.Per_ApellidoPaterno) AS NombreCompletoUsuarioRegistra,

        CC.Cco_FechaRegistra AS FechaRegistro,
        CC.Cco_UsuarioModifica AS UsuarioModificaId,

        -- Nombre usuario modifica
        CASE WHEN CC.Cco_UsuarioModifica IS NOT NULL 
             THEN CONCAT(UMA.Per_PrimerNombre, ' ', UMA.Per_ApellidoPaterno)
             ELSE NULL
        END AS NombreCompletoUsuarioModifica,

        CC.Cco_FechaModifica AS FechaModifica
    FROM finanza.tbCuentasCobrar CC
    INNER JOIN finanza.tbConceptosPago CP ON CC.Cpa_Id = CP.Cpa_Id
    INNER JOIN finanza.tbEstadosPago EP ON CC.Epa_Id = EP.Epa_Id

    -- Usuario registra
    INNER JOIN seguridad.tbUsuarios U ON CC.Cco_UsuarioRegistra = U.Usu_Id
    INNER JOIN app.tbEmpleados UE ON U.Emp_Id = UE.Emp_Id
    INNER JOIN app.tbPersonas UPA ON UE.Per_Id = UPA.Per_Id

    -- Usuario modifica
    LEFT JOIN seguridad.tbUsuarios UM ON CC.Cco_UsuarioModifica = UM.Usu_Id
    LEFT JOIN app.tbEmpleados UEM ON UM.Emp_Id = UEM.Emp_Id
    LEFT JOIN app.tbPersonas UMA ON UEM.Per_Id = UMA.Per_Id

    WHERE CC.Alu_Id = @Alu_Id
      AND CC.Cco_EsEliminado = 0
      AND CC.Cco_MontoPendiente > 0
    ORDER BY CC.Cco_FechaVencimiento ASC, CC.Cco_Anio, CC.Cco_Mes
END
GO

GO

PRINT 'Procedimiento finanza.PR_tbCuentasCobrar_ListByAlumno creado/actualizado'
GO

-- =============================================
-- PASO 7: DATOS INICIALES - CONCEPTO MENSUALIDAD
-- =============================================

-- Verificar si existe el concepto "Mensualidad"
IF NOT EXISTS (SELECT 1 FROM finanza.tbConceptosPago WHERE Cpa_Descripcion = 'Mensualidad' AND Cpa_EsEliminado = 0)
BEGIN
    INSERT INTO finanza.tbConceptosPago (
        Cpa_Descripcion,
        Cpa_EsRecurrente,
        Cpa_EsObligatorio,
        Cpa_EsActivo,
        Cpa_EsEliminado,
        Cpa_UsuarioRegistra,
        Cpa_FechaRegistra
    )
    VALUES (
        'Mensualidad',
        1,  -- Es recurrente
        1,  -- Es obligatorio
        1,  -- Está activo
        0,  -- No eliminado
        1,  -- Usuario sistema
        GETDATE()
    )

    PRINT 'Concepto de pago "Mensualidad" creado'
END
ELSE
    PRINT 'Concepto de pago "Mensualidad" ya existe'
GO

-- =============================================
-- FIN DEL SCRIPT
-- =============================================

PRINT ''
PRINT '========================================='
PRINT 'SCRIPT COMPLETADO EXITOSAMENTE'
PRINT '========================================='
PRINT ''
PRINT 'PRÓXIMOS PASOS:'
PRINT '1. Configurar tarifas en finanza.tbTarifasMensualidades'
PRINT '2. Ejecutar finanza.PR_GenerarMensualidad para generar mensualidades'
PRINT '3. Usar finanza.PR_MesesPendientesPorAlumno para ver estado de pagos'
PRINT ''
GO
