# 📊 MAPEO COMPLETO: PANTALLAS → TABLAS → PROCEDIMIENTOS ALMACENADOS

## Sistema de Gestión Financiera - Cuentas por Cobrar

---

## 🗂️ 1. CONFIGURACIÓN INICIAL (Catálogos)

### 📌 `/ConceptosPago/Index`
**Descripción:** Administrar conceptos de pago (Mensualidad, Matrícula, Examen, etc.)

| Componente | Detalle |
|-----------|---------|
| **Tabla Principal** | `finanza.tbConceptosPago` |
| **SP Listar** | `finanza.PR_tbConceptosPago_List` |
| **SP Buscar** | `finanza.PR_tbConceptosPago_Find` |
| **SP Crear** | `finanza.PR_tbConceptosPago_Create` |
| **SP Editar** | `finanza.PR_tbConceptosPago_Edit` |
| **SP Eliminar** | `finanza.PR_tbConceptosPago_Delete` |
| **SP Dropdown** | `finanza.PR_tbConceptosPago_Dropdown` |

**Campos Clave:**
- `Cpa_Descripcion` - Nombre del concepto
- `Cpa_EsRecurrente` - Si se cobra mensualmente
- `Cpa_EsObligatorio` - Si es obligatorio para todos

---

### 📌 `/Tarifas/Index` ⚠️ PENDIENTE DE IMPLEMENTACIÓN
**Descripción:** Configurar tarifas de mensualidades por Curso/Nivel + Modalidad

| Componente | Detalle |
|-----------|---------|
| **Tabla Principal** | `finanza.tbTarifasMensualidades` ⭐ NUEVA |
| **SP Listar** | `finanza.PR_tbTarifasMensualidades_List` ⚠️ POR CREAR |
| **SP Buscar** | `finanza.PR_tbTarifasMensualidades_Find` ⚠️ POR CREAR |
| **SP Crear** | `finanza.PR_tbTarifasMensualidades_Create` ⚠️ POR CREAR |
| **SP Editar** | `finanza.PR_tbTarifasMensualidades_Edit` ⚠️ POR CREAR |
| **SP Eliminar** | `finanza.PR_tbTarifasMensualidades_Delete` ⚠️ POR CREAR |

**Campos Clave:**
- `Cun_Id` - Curso/Nivel
- `Mda_Id` - Modalidad (Presencial, Virtual, etc.)
- `TarMen_Monto` - Monto mensual
- `TarMen_AnioVigencia` - Año de vigencia

---

### 📌 `/Descuentos/Index`
**Descripción:** Administrar descuentos disponibles

| Componente | Detalle |
|-----------|---------|
| **Tabla Principal** | `finanza.tbDescuentos` |
| **SP Listar** | `finanza.PR_tbDescuentos_List` |
| **SP Dropdown** | `finanza.PR_tbDescuentos_Dropdown` |

---

### 📌 `/FormasPago/Index`
**Descripción:** Administrar formas de pago (Efectivo, Tarjeta, Transferencia)

| Componente | Detalle |
|-----------|---------|
| **Tabla Principal** | `finanza.tbFormasPago` |
| **SP Listar** | `finanza.PR_tbFormasPago_List` |
| **SP Dropdown** | `finanza.PR_tbFormasPago_Dropdown` |

---

## 💰 2. GENERACIÓN DE CUENTAS POR COBRAR

### 📌 `/CuentasCobrar/CargosMasivos` ⭐ PRINCIPAL
**Descripción:** Generar mensualidades automáticamente para todos los alumnos activos

| Componente | Detalle |
|-----------|---------|
| **Tabla Escribe** | `finanza.tbCuentasCobrar` |
| **Tabla Lee** | `finanza.tbTarifasMensualidades` |
| **Tabla Lee** | `gral.tbAlumnos` |
| **SP Generar Mes** | `finanza.PR_GenerarMensualidad` ⭐ NUEVO |
| **SP Generar Rango** | `finanza.PR_GenerarMensualidadesRango` ⭐ NUEVO |
| **Controller** | `CuentasCobrarController.GenerarMensualidadAsync()` |
| **Controller** | `CuentasCobrarController.GenerarMensualidadesRangoAsync()` |

**Funcionalidad:**
1. Busca todos los alumnos activos
2. Obtiene la tarifa según su `Cun_Id` + `Mda_Id`
3. Crea una cuenta por cobrar por cada alumno
4. Evita duplicados (mismo mes/año)

**Parámetros de entrada:**
- `@Mes` (1-12)
- `@Anio` (2025)
- `@Usu_Id` (Usuario que ejecuta)

**Retorna:**
- Total de cuentas generadas
- Monto total
- Nombre del mes

---

## 📋 3. CONSULTA DE CUENTAS POR COBRAR

### 📌 `/CuentasCobrar/Index`
**Descripción:** Listado general de todas las cuentas por cobrar

| Componente | Detalle |
|-----------|---------|
| **Tabla Lee** | `finanza.tbCuentasCobrar` |
| **SP Listar** | `finanza.PR_tbCuentasCobrar_List` |
| **Controller** | `CuentasCobrarController.ListAsync()` |

---

### 📌 `/CuentasCobrar/EstadoCuenta`
**Descripción:** Ver estado de cuenta de un alumno específico (qué meses debe)

| Componente | Detalle |
|-----------|---------|
| **Tabla Lee** | `finanza.tbCuentasCobrar` |
| **SP Principal** | `finanza.PR_MesesPendientesPorAlumno` ⭐ NUEVO |
| **SP Detalle** | `finanza.PR_tbCuentasCobrar_ListByAlumno` ⭐ NUEVO |
| **Controller** | `CuentasCobrarController.MesesPendientesPorAlumnoAsync()` |

**Retorna:**
- Lista de 12 meses con estado:
  - No Generado
  - Pendiente
  - Pago Parcial
  - Pagado
  - Vencido

---

### 📌 `/CuentasCobrar/CargosPendientes`
**Descripción:** Ver todos los cargos pendientes de pago

| Componente | Detalle |
|-----------|---------|
| **Tabla Lee** | `finanza.tbCuentasCobrar` |
| **SP Listar** | `finanza.PR_tbCuentasCobrar_ListPendientes` |
| **Controller** | `CuentasCobrarController.ListPendientesAsync()` |

---

### 📌 `/CuentasCobrar/Deudores`
**Descripción:** Ver alumnos con deudas vencidas

| Componente | Detalle |
|-----------|---------|
| **Tabla Lee** | `finanza.tbCuentasCobrar` |
| **SP Listar** | `finanza.PR_tbCuentasCobrar_ListDeudores` |
| **Controller** | `CuentasCobrarController.ListDeudoresAsync()` |

---

## 💳 4. REGISTRO DE PAGOS

### 📌 `/Pagos/NuevoPago` ⭐ MUY IMPORTANTE
**Descripción:** Registrar pagos de alumnos

| Componente | Detalle |
|-----------|---------|
| **Tabla Lee** | `finanza.tbCuentasCobrar` |
| **Tabla Escribe** | `finanza.tbPagos` |
| **Tabla Escribe** | `finanza.tbDetallePagos` |
| **SP Buscar Alumno** | `gral.PR_tbAlumnos_FindByIdentidad` |
| **SP Cuentas Alumno** | `finanza.PR_tbCuentasCobrar_ListByAlumno` ⭐ NUEVO |
| **SP Descuentos** | `finanza.PR_tbDescuentos_Dropdown` |
| **SP Formas Pago** | `finanza.PR_tbFormasPago_Dropdown` |
| **SP Registrar Pago** | `finanza.PR_tbPagos_Create` |
| **Controller** | `PagosController.NuevoPagoAsync()` |

**Flujo:**
1. Buscar alumno por identidad
2. Listar sus cuentas por cobrar pendientes
3. Seleccionar conceptos a pagar
4. Aplicar descuentos (opcional)
5. Seleccionar forma de pago
6. Confirmar y registrar pago

---

## 📊 5. REPORTES

### 📌 `/CuentasCobrar/HistoricoPagos`
**Descripción:** Ver historial de todos los pagos registrados

| Componente | Detalle |
|-----------|---------|
| **Tabla Lee** | `finanza.tbPagos` |
| **Tabla Lee** | `finanza.tbDetallePagos` |
| **SP Listar** | `finanza.PR_tbPagos_ListHistorico` |

---

### 📌 `/CuentasCobrar/Moratorias`
**Descripción:** Calcular y aplicar moras por pagos atrasados

| Componente | Detalle |
|-----------|---------|
| **Tabla Lee/Actualiza** | `finanza.tbCuentasCobrar` |
| **SP Calcular** | `finanza.PR_tbCuentasCobrar_CalcularMoratoria` |

---

## 📦 ESTRUCTURA DE TABLAS PRINCIPALES

### `finanza.tbTarifasMensualidades` ⭐ NUEVA
```sql
TarMen_Id              INT            -- ID de la tarifa
Cun_Id                 INT            -- Curso/Nivel
Mda_Id                 INT            -- Modalidad
TarMen_Monto           DECIMAL(18,2)  -- Monto mensual
TarMen_AnioVigencia    SMALLINT       -- Año
TarMen_EsActivo        BIT            -- Activa/Inactiva
```

### `finanza.tbCuentasCobrar` ✏️ MODIFICADA
```sql
-- Campos existentes:
Cco_Id                 INT            -- ID
Alu_Id                 INT            -- Alumno
Cpa_Id                 INT            -- Concepto de pago
Tar_Id                 INT            -- Tarifa usada
Cco_MontoOriginal      DECIMAL(18,2)  -- Monto
Cco_MontoPendiente     DECIMAL(18,2)  -- Saldo pendiente
Cco_FechaEmision       DATE           -- Fecha emisión
Cco_FechaVencimiento   DATE           -- Fecha vencimiento
Epa_Id                 INT            -- Estado de pago

-- Campos NUEVOS agregados:
Cco_Mes                TINYINT        -- Mes (1-12) ⭐ NUEVO
Cco_Anio               SMALLINT       -- Año (2025) ⭐ NUEVO
```

---

## 🔄 FLUJO COMPLETO DEL SISTEMA

```
1. CONFIGURACIÓN
   └─ Crear tarifas en /Tarifas/Index
      (Ejemplo: 3er Grado Presencial = L.500/mes)

2. GENERACIÓN MENSUAL
   └─ Ir a /CuentasCobrar/CargosMasivos
   └─ Click "Generar Mensualidad" (Enero 2025)
   └─ Sistema crea automáticamente cuentas para todos los alumnos

3. REGISTRO DE PAGOS
   └─ Alumno viene a pagar
   └─ Ir a /Pagos/NuevoPago
   └─ Buscar alumno por identidad
   └─ Sistema muestra sus cuentas pendientes
   └─ Seleccionar qué pagar
   └─ Registrar pago

4. CONSULTAS
   └─ /CuentasCobrar/EstadoCuenta → Ver qué meses debe un alumno
   └─ /CuentasCobrar/Deudores → Ver alumnos atrasados
   └─ /CuentasCobrar/HistoricoPagos → Ver historial
```

---

## ✅ PROCEDIMIENTOS ALMACENADOS NUEVOS CREADOS

| Nombre | Propósito |
|--------|-----------|
| `finanza.PR_GenerarMensualidad` | Generar mensualidad de un mes |
| `finanza.PR_GenerarMensualidadesRango` | Generar múltiples meses |
| `finanza.PR_MesesPendientesPorAlumno` | Ver estado de 12 meses |
| `finanza.PR_tbCuentasCobrar_ListByAlumno` | Listar cuentas pendientes |

---

## ⚠️ PENDIENTE DE IMPLEMENTACIÓN

1. ❌ CRUD completo de `tbTarifasMensualidades`
2. ❌ Vista `/Tarifas/Index` para configurar tarifas
3. ❌ Métodos en `CuentasCobrarService` para llamar a los nuevos SP
4. ❌ Actualizar sidebar para cambiar nombre "Cargos Masivos" → "Generar Mensualidades"

---

## 📝 NOTAS IMPORTANTES

- ✅ El sistema usa **esquema `finanza`** para tablas financieras
- ✅ El sistema usa **esquema `gral`** para tablas generales (Alumnos, etc.)
- ✅ Todos los SP nuevos están en el archivo: `sistema_mensualidades_completo.sql`
- ✅ La vista `CargosMasivos.cshtml` fue simplificada completamente
- ✅ Ya no se necesitan filtros complejos, solo 3 botones simples
- ✅ El sistema previene duplicados automáticamente

---

**Fecha de creación:** 2025-01-18
**Última actualización:** 2025-01-18
**Versión:** 1.0
