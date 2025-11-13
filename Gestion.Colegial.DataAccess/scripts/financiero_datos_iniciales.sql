/* =============================================================
   MÓDULO FINANCIERO – DATOS INICIALES
   Inserta los registros básicos necesarios para el funcionamiento
   del módulo financiero
   ============================================================= */

SET NOCOUNT ON;
GO

PRINT '=== INSERTANDO DATOS INICIALES DEL MÓDULO FINANCIERO ===';
GO

/* =============================================================
   1) tbEstadosPago - Estados de las cuentas por cobrar
   ============================================================= */
PRINT 'Insertando Estados de Pago...';

IF NOT EXISTS (SELECT 1 FROM dbo.tbEstadosPago WHERE Epa_Descripcion = 'Pendiente')
BEGIN
    INSERT INTO dbo.tbEstadosPago (Epa_Descripcion, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Pendiente', 1, SYSDATETIME());
    PRINT '  - Estado: Pendiente';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbEstadosPago WHERE Epa_Descripcion = 'Pagado')
BEGIN
    INSERT INTO dbo.tbEstadosPago (Epa_Descripcion, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Pagado', 1, SYSDATETIME());
    PRINT '  - Estado: Pagado';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbEstadosPago WHERE Epa_Descripcion = 'Vencido')
BEGIN
    INSERT INTO dbo.tbEstadosPago (Epa_Descripcion, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Vencido', 1, SYSDATETIME());
    PRINT '  - Estado: Vencido';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbEstadosPago WHERE Epa_Descripcion = 'Parcialmente Pagado')
BEGIN
    INSERT INTO dbo.tbEstadosPago (Epa_Descripcion, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Parcialmente Pagado', 1, SYSDATETIME());
    PRINT '  - Estado: Parcialmente Pagado';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbEstadosPago WHERE Epa_Descripcion = 'Cancelado')
BEGIN
    INSERT INTO dbo.tbEstadosPago (Epa_Descripcion, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Cancelado', 1, SYSDATETIME());
    PRINT '  - Estado: Cancelado';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbEstadosPago WHERE Epa_Descripcion = 'En Mora')
BEGIN
    INSERT INTO dbo.tbEstadosPago (Epa_Descripcion, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('En Mora', 1, SYSDATETIME());
    PRINT '  - Estado: En Mora';
END

PRINT 'Estados de Pago insertados correctamente.';
PRINT '';
GO

/* =============================================================
   2) tbFormasPago - Formas de pago disponibles
   ============================================================= */
PRINT 'Insertando Formas de Pago...';

IF NOT EXISTS (SELECT 1 FROM dbo.tbFormasPago WHERE Fpa_Descripcion = 'Efectivo')
BEGIN
    INSERT INTO dbo.tbFormasPago (Fpa_Descripcion, Fpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Efectivo', 1, 1, SYSDATETIME());
    PRINT '  - Forma de Pago: Efectivo';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbFormasPago WHERE Fpa_Descripcion = 'Tarjeta de Crédito')
BEGIN
    INSERT INTO dbo.tbFormasPago (Fpa_Descripcion, Fpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Tarjeta de Crédito', 1, 1, SYSDATETIME());
    PRINT '  - Forma de Pago: Tarjeta de Crédito';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbFormasPago WHERE Fpa_Descripcion = 'Tarjeta de Débito')
BEGIN
    INSERT INTO dbo.tbFormasPago (Fpa_Descripcion, Fpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Tarjeta de Débito', 1, 1, SYSDATETIME());
    PRINT '  - Forma de Pago: Tarjeta de Débito';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbFormasPago WHERE Fpa_Descripcion = 'Transferencia Bancaria')
BEGIN
    INSERT INTO dbo.tbFormasPago (Fpa_Descripcion, Fpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Transferencia Bancaria', 1, 1, SYSDATETIME());
    PRINT '  - Forma de Pago: Transferencia Bancaria';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbFormasPago WHERE Fpa_Descripcion = 'Cheque')
BEGIN
    INSERT INTO dbo.tbFormasPago (Fpa_Descripcion, Fpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Cheque', 1, 1, SYSDATETIME());
    PRINT '  - Forma de Pago: Cheque';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbFormasPago WHERE Fpa_Descripcion = 'Depósito Bancario')
BEGIN
    INSERT INTO dbo.tbFormasPago (Fpa_Descripcion, Fpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Depósito Bancario', 1, 1, SYSDATETIME());
    PRINT '  - Forma de Pago: Depósito Bancario';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbFormasPago WHERE Fpa_Descripcion = 'Sinpe Móvil')
BEGIN
    INSERT INTO dbo.tbFormasPago (Fpa_Descripcion, Fpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Sinpe Móvil', 1, 1, SYSDATETIME());
    PRINT '  - Forma de Pago: Sinpe Móvil';
END

PRINT 'Formas de Pago insertadas correctamente.';
PRINT '';
GO

/* =============================================================
   3) tbConceptosPago - Conceptos de pago del colegio
   ============================================================= */
PRINT 'Insertando Conceptos de Pago...';

IF NOT EXISTS (SELECT 1 FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Matrícula')
BEGIN
    INSERT INTO dbo.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Matrícula', 0, 1, 1, 1, SYSDATETIME());
    PRINT '  - Concepto: Matrícula (No recurrente, Obligatorio)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Mensualidad')
BEGIN
    INSERT INTO dbo.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Mensualidad', 1, 1, 1, 1, SYSDATETIME());
    PRINT '  - Concepto: Mensualidad (Recurrente, Obligatorio)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Uniformes')
BEGIN
    INSERT INTO dbo.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Uniformes', 0, 0, 1, 1, SYSDATETIME());
    PRINT '  - Concepto: Uniformes (No recurrente, No obligatorio)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Libros y Materiales')
BEGIN
    INSERT INTO dbo.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Libros y Materiales', 0, 1, 1, 1, SYSDATETIME());
    PRINT '  - Concepto: Libros y Materiales (No recurrente, Obligatorio)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Transporte Escolar')
BEGIN
    INSERT INTO dbo.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Transporte Escolar', 1, 0, 1, 1, SYSDATETIME());
    PRINT '  - Concepto: Transporte Escolar (Recurrente, No obligatorio)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Alimentación')
BEGIN
    INSERT INTO dbo.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Alimentación', 1, 0, 1, 1, SYSDATETIME());
    PRINT '  - Concepto: Alimentación (Recurrente, No obligatorio)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Actividades Extracurriculares')
BEGIN
    INSERT INTO dbo.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Actividades Extracurriculares', 0, 0, 1, 1, SYSDATETIME());
    PRINT '  - Concepto: Actividades Extracurriculares (No recurrente, No obligatorio)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Seguro Estudiantil')
BEGIN
    INSERT INTO dbo.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Seguro Estudiantil', 0, 1, 1, 1, SYSDATETIME());
    PRINT '  - Concepto: Seguro Estudiantil (No recurrente, Obligatorio)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Reposición de Carnet')
BEGIN
    INSERT INTO dbo.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Reposición de Carnet', 0, 0, 1, 1, SYSDATETIME());
    PRINT '  - Concepto: Reposición de Carnet (No recurrente, No obligatorio)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Gira Educativa')
BEGIN
    INSERT INTO dbo.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Gira Educativa', 0, 0, 1, 1, SYSDATETIME());
    PRINT '  - Concepto: Gira Educativa (No recurrente, No obligatorio)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Graduación')
BEGIN
    INSERT INTO dbo.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Graduación', 0, 0, 1, 1, SYSDATETIME());
    PRINT '  - Concepto: Graduación (No recurrente, No obligatorio)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Multa por Retraso')
BEGIN
    INSERT INTO dbo.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Multa por Retraso', 0, 0, 1, 1, SYSDATETIME());
    PRINT '  - Concepto: Multa por Retraso (No recurrente, No obligatorio)';
END

PRINT 'Conceptos de Pago insertados correctamente.';
PRINT '';
GO

/* =============================================================
   4) tbDescuentos - Tipos de descuentos disponibles
   ============================================================= */
PRINT 'Insertando Descuentos...';

IF NOT EXISTS (SELECT 1 FROM dbo.tbDescuentos WHERE Des_Descripcion = 'Descuento por Pronto Pago')
BEGIN
    INSERT INTO dbo.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Descuento por Pronto Pago', 'P', 5.00, 1, 1, SYSDATETIME());
    PRINT '  - Descuento: Por Pronto Pago (5% - Porcentaje)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbDescuentos WHERE Des_Descripcion = 'Descuento por Hermanos (2do hijo)')
BEGIN
    INSERT INTO dbo.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Descuento por Hermanos (2do hijo)', 'P', 10.00, 1, 1, SYSDATETIME());
    PRINT '  - Descuento: Por Hermanos 2do hijo (10% - Porcentaje)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbDescuentos WHERE Des_Descripcion = 'Descuento por Hermanos (3er hijo o más)')
BEGIN
    INSERT INTO dbo.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Descuento por Hermanos (3er hijo o más)', 'P', 15.00, 1, 1, SYSDATETIME());
    PRINT '  - Descuento: Por Hermanos 3er hijo o más (15% - Porcentaje)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbDescuentos WHERE Des_Descripcion = 'Beca Académica (25%)')
BEGIN
    INSERT INTO dbo.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Beca Académica (25%)', 'P', 25.00, 1, 1, SYSDATETIME());
    PRINT '  - Descuento: Beca Académica 25% (25% - Porcentaje)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbDescuentos WHERE Des_Descripcion = 'Beca Académica (50%)')
BEGIN
    INSERT INTO dbo.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Beca Académica (50%)', 'P', 50.00, 1, 1, SYSDATETIME());
    PRINT '  - Descuento: Beca Académica 50% (50% - Porcentaje)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbDescuentos WHERE Des_Descripcion = 'Beca Académica (75%)')
BEGIN
    INSERT INTO dbo.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Beca Académica (75%)', 'P', 75.00, 1, 1, SYSDATETIME());
    PRINT '  - Descuento: Beca Académica 75% (75% - Porcentaje)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbDescuentos WHERE Des_Descripcion = 'Beca Total (100%)')
BEGIN
    INSERT INTO dbo.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Beca Total (100%)', 'P', 100.00, 1, 1, SYSDATETIME());
    PRINT '  - Descuento: Beca Total (100% - Porcentaje)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbDescuentos WHERE Des_Descripcion = 'Beca Deportiva')
BEGIN
    INSERT INTO dbo.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Beca Deportiva', 'P', 30.00, 1, 1, SYSDATETIME());
    PRINT '  - Descuento: Beca Deportiva (30% - Porcentaje)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbDescuentos WHERE Des_Descripcion = 'Beca por Situación Socioeconómica')
BEGIN
    INSERT INTO dbo.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Beca por Situación Socioeconómica', 'P', 40.00, 1, 1, SYSDATETIME());
    PRINT '  - Descuento: Beca Socioeconómica (40% - Porcentaje)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbDescuentos WHERE Des_Descripcion = 'Descuento por Empleado del Colegio')
BEGIN
    INSERT INTO dbo.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Descuento por Empleado del Colegio', 'P', 20.00, 1, 1, SYSDATETIME());
    PRINT '  - Descuento: Por Empleado del Colegio (20% - Porcentaje)';
END

IF NOT EXISTS (SELECT 1 FROM dbo.tbDescuentos WHERE Des_Descripcion = 'Descuento Especial')
BEGIN
    INSERT INTO dbo.tbDescuentos (Des_Descripcion, Des_TipoDescuento, Des_Valor, Des_EsActivo, Per_UsuarioRegistra, Per_FechaRegistra)
    VALUES ('Descuento Especial', 'M', 5000.00, 1, 1, SYSDATETIME());
    PRINT '  - Descuento: Especial (₡5,000.00 - Monto Fijo)';
END

PRINT 'Descuentos insertados correctamente.';
PRINT '';
GO

/* =============================================================
   5) tbTarifas - Tarifas de ejemplo por concepto y año
   NOTA: Estas son tarifas de ejemplo para el año 2025.
         Ajustar según los niveles educativos reales del colegio.
   ============================================================= */
PRINT 'Insertando Tarifas de Ejemplo (Año 2025)...';

DECLARE @CpaMatricula int, @CpaMensualidad int, @CpaUniformes int,
        @CpaLibros int, @CpaTransporte int, @CpaAlimentacion int,
        @CpaExtracurriculares int, @CpaSeguro int, @CpaCarnet int;

-- Obtener IDs de conceptos
SELECT @CpaMatricula = Cpa_Id FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Matrícula';
SELECT @CpaMensualidad = Cpa_Id FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Mensualidad';
SELECT @CpaUniformes = Cpa_Id FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Uniformes';
SELECT @CpaLibros = Cpa_Id FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Libros y Materiales';
SELECT @CpaTransporte = Cpa_Id FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Transporte Escolar';
SELECT @CpaAlimentacion = Cpa_Id FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Alimentación';
SELECT @CpaExtracurriculares = Cpa_Id FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Actividades Extracurriculares';
SELECT @CpaSeguro = Cpa_Id FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Seguro Estudiantil';
SELECT @CpaCarnet = Cpa_Id FROM dbo.tbConceptosPago WHERE Cpa_Descripcion = 'Reposición de Carnet';

-- Tarifas para Matrícula (sin nivel específico - general)
IF NOT EXISTS (SELECT 1 FROM dbo.tbTarifas WHERE Cpa_Id = @CpaMatricula AND Tar_AnioVigencia = 2025 AND Niv_Id IS NULL AND Cun_Id IS NULL)
BEGIN
    INSERT INTO dbo.tbTarifas (Cpa_Id, Niv_Id, Cun_Id, Tar_Monto, Tar_AnioVigencia, Per_UsuarioRegistra)
    VALUES (@CpaMatricula, NULL, NULL, 50000.00, 2025, 1);
    PRINT '  - Tarifa: Matrícula General 2025 = ₡50,000.00';
END

-- Tarifas para Mensualidad (sin nivel específico - general)
IF NOT EXISTS (SELECT 1 FROM dbo.tbTarifas WHERE Cpa_Id = @CpaMensualidad AND Tar_AnioVigencia = 2025 AND Niv_Id IS NULL AND Cun_Id IS NULL)
BEGIN
    INSERT INTO dbo.tbTarifas (Cpa_Id, Niv_Id, Cun_Id, Tar_Monto, Tar_AnioVigencia, Per_UsuarioRegistra)
    VALUES (@CpaMensualidad, NULL, NULL, 45000.00, 2025, 1);
    PRINT '  - Tarifa: Mensualidad General 2025 = ₡45,000.00';
END

-- Tarifas para Uniformes
IF NOT EXISTS (SELECT 1 FROM dbo.tbTarifas WHERE Cpa_Id = @CpaUniformes AND Tar_AnioVigencia = 2025 AND Niv_Id IS NULL AND Cun_Id IS NULL)
BEGIN
    INSERT INTO dbo.tbTarifas (Cpa_Id, Niv_Id, Cun_Id, Tar_Monto, Tar_AnioVigencia, Per_UsuarioRegistra)
    VALUES (@CpaUniformes, NULL, NULL, 35000.00, 2025, 1);
    PRINT '  - Tarifa: Uniformes 2025 = ₡35,000.00';
END

-- Tarifas para Libros y Materiales
IF NOT EXISTS (SELECT 1 FROM dbo.tbTarifas WHERE Cpa_Id = @CpaLibros AND Tar_AnioVigencia = 2025 AND Niv_Id IS NULL AND Cun_Id IS NULL)
BEGIN
    INSERT INTO dbo.tbTarifas (Cpa_Id, Niv_Id, Cun_Id, Tar_Monto, Tar_AnioVigencia, Per_UsuarioRegistra)
    VALUES (@CpaLibros, NULL, NULL, 25000.00, 2025, 1);
    PRINT '  - Tarifa: Libros y Materiales 2025 = ₡25,000.00';
END

-- Tarifas para Transporte Escolar (mensual)
IF NOT EXISTS (SELECT 1 FROM dbo.tbTarifas WHERE Cpa_Id = @CpaTransporte AND Tar_AnioVigencia = 2025 AND Niv_Id IS NULL AND Cun_Id IS NULL)
BEGIN
    INSERT INTO dbo.tbTarifas (Cpa_Id, Niv_Id, Cun_Id, Tar_Monto, Tar_AnioVigencia, Per_UsuarioRegistra)
    VALUES (@CpaTransporte, NULL, NULL, 20000.00, 2025, 1);
    PRINT '  - Tarifa: Transporte Escolar 2025 = ₡20,000.00/mes';
END

-- Tarifas para Alimentación (mensual)
IF NOT EXISTS (SELECT 1 FROM dbo.tbTarifas WHERE Cpa_Id = @CpaAlimentacion AND Tar_AnioVigencia = 2025 AND Niv_Id IS NULL AND Cun_Id IS NULL)
BEGIN
    INSERT INTO dbo.tbTarifas (Cpa_Id, Niv_Id, Cun_Id, Tar_Monto, Tar_AnioVigencia, Per_UsuarioRegistra)
    VALUES (@CpaAlimentacion, NULL, NULL, 15000.00, 2025, 1);
    PRINT '  - Tarifa: Alimentación 2025 = ₡15,000.00/mes';
END

-- Tarifas para Actividades Extracurriculares
IF NOT EXISTS (SELECT 1 FROM dbo.tbTarifas WHERE Cpa_Id = @CpaExtracurriculares AND Tar_AnioVigencia = 2025 AND Niv_Id IS NULL AND Cun_Id IS NULL)
BEGIN
    INSERT INTO dbo.tbTarifas (Cpa_Id, Niv_Id, Cun_Id, Tar_Monto, Tar_AnioVigencia, Per_UsuarioRegistra)
    VALUES (@CpaExtracurriculares, NULL, NULL, 10000.00, 2025, 1);
    PRINT '  - Tarifa: Actividades Extracurriculares 2025 = ₡10,000.00';
END

-- Tarifas para Seguro Estudiantil
IF NOT EXISTS (SELECT 1 FROM dbo.tbTarifas WHERE Cpa_Id = @CpaSeguro AND Tar_AnioVigencia = 2025 AND Niv_Id IS NULL AND Cun_Id IS NULL)
BEGIN
    INSERT INTO dbo.tbTarifas (Cpa_Id, Niv_Id, Cun_Id, Tar_Monto, Tar_AnioVigencia, Per_UsuarioRegistra)
    VALUES (@CpaSeguro, NULL, NULL, 8000.00, 2025, 1);
    PRINT '  - Tarifa: Seguro Estudiantil 2025 = ₡8,000.00';
END

-- Tarifas para Reposición de Carnet
IF NOT EXISTS (SELECT 1 FROM dbo.tbTarifas WHERE Cpa_Id = @CpaCarnet AND Tar_AnioVigencia = 2025 AND Niv_Id IS NULL AND Cun_Id IS NULL)
BEGIN
    INSERT INTO dbo.tbTarifas (Cpa_Id, Niv_Id, Cun_Id, Tar_Monto, Tar_AnioVigencia, Per_UsuarioRegistra)
    VALUES (@CpaCarnet, NULL, NULL, 3000.00, 2025, 1);
    PRINT '  - Tarifa: Reposición de Carnet 2025 = ₡3,000.00';
END

PRINT 'Tarifas de Ejemplo insertadas correctamente.';
PRINT '';
GO

/* =============================================================
   6) RESUMEN DE DATOS INSERTADOS
   ============================================================= */
PRINT '=== RESUMEN DE DATOS INSERTADOS ===';
PRINT '';

DECLARE @CantEstados int, @CantFormas int, @CantConceptos int, @CantDescuentos int, @CantTarifas int;

SELECT @CantEstados = COUNT(*) FROM dbo.tbEstadosPago WHERE Per_EsEliminado = 0;
SELECT @CantFormas = COUNT(*) FROM dbo.tbFormasPago WHERE Per_EsEliminado = 0;
SELECT @CantConceptos = COUNT(*) FROM dbo.tbConceptosPago WHERE Per_EsEliminado = 0;
SELECT @CantDescuentos = COUNT(*) FROM dbo.tbDescuentos WHERE Per_EsEliminado = 0;
SELECT @CantTarifas = COUNT(*) FROM dbo.tbTarifas WHERE Per_EsEliminado = 0;

PRINT 'Estados de Pago: ' + CAST(@CantEstados AS nvarchar(10)) + ' registros';
PRINT 'Formas de Pago: ' + CAST(@CantFormas AS nvarchar(10)) + ' registros';
PRINT 'Conceptos de Pago: ' + CAST(@CantConceptos AS nvarchar(10)) + ' registros';
PRINT 'Descuentos: ' + CAST(@CantDescuentos AS nvarchar(10)) + ' registros';
PRINT 'Tarifas: ' + CAST(@CantTarifas AS nvarchar(10)) + ' registros';
PRINT '';
PRINT '=== DATOS INICIALES INSERTADOS EXITOSAMENTE ===';
PRINT '';
PRINT 'NOTA: Las tarifas insertadas son generales (sin Niv_Id/Cun_Id específico).';
PRINT '      Puede agregar tarifas diferenciadas por nivel educativo según necesidad.';
PRINT '      Las tablas transaccionales (tbCuentasCobrar, tbPagos, etc.) se llenarán en operación.';
GO
