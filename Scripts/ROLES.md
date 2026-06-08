# Roles del Sistema — Gestión Colegial

Este documento describe los roles iniciales del sistema y el alcance de cada uno. Los inserts correspondientes están en [005_Roles_Iniciales.sql](005_Roles_Iniciales.sql).

> **Leyenda:** ✅ CRUD completo · ✏️ Crear/Editar · 👁 Solo lectura · ❌ Sin acceso

---

## Resumen

| Rol_Id | Rol | Propósito |
|---|---|---|
| 1 | **admin** | Súper administrador del sistema. Único con acceso al módulo de Seguridad. |
| 2 | **director** | Visión completa del colegio, sin gestionar usuarios/roles. |
| 3 | **docente** | Consulta académica y registro de notas. |
| 4 | **secretaria** | Matrícula de alumnos y atención a encargados. |
| 5 | **recursos humanos** | Gestión de empleados y cargos. |
| 6 | **cajero** | Cobros del día y consulta de cuentas. |
| 7 | **contador** | Configuración financiera completa y reportes. |
| 8 | **consulta** | Solo lectura para auditoría / junta directiva. |

---

## Matriz de permisos por grupo de pantallas

| Rol | General | Cursos | Alumnos | RRHH | Horarios | Institución | Financiero | Académico | Seguridad |
|---|---|---|---|---|---|---|---|---|---|
| admin | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| director | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| docente | ✅ | 👁 | 👁 | ❌ | 👁 | 👁 (parciales/secciones) | ❌ | 👁 | ❌ |
| secretaria | ✅ | 👁 | ✅ | ❌ | 👁 | 👁 | ❌ | 👁 (personas) | ❌ |
| recursos humanos | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | 👁 (personas) | ❌ |
| cajero | ✅ | ❌ | 👁 | ❌ | ❌ | ❌ | ✏️ (pagos) + 👁 catálogos | 👁 (personas) | ❌ |
| contador | ✅ | ❌ | 👁 | ❌ | ❌ | ❌ | ✅ | 👁 (personas) | ❌ |
| consulta | ✅ | 👁 | 👁 | 👁 | 👁 | 👁 | 👁 | 👁 | ❌ |

---

## Detalle por rol

### 1. admin
Rol heredado del seed inicial de la base de datos. Tiene **todas las pantallas** asignadas, incluyendo el grupo `Seguridad` (gestión de usuarios, roles y asignación de pantallas).

### 2. director
- **Incluye:** Todas las pantallas de los grupos `General`, `Cursos`, `Alumnos`, `Recursos Humanos`, `Horarios`, `Institucion`, `Financiero`, `Academico`.
- **Excluye:** Todo el grupo `Seguridad` (no puede crear usuarios, ni modificar roles, ni reasignar pantallas).

### 3. docente
Rol orientado al uso diario del profesor. Solo lectura sobre lo que necesita para dar clase:

- `Home`
- `Listado de cursos`, `Listado de materias`
- `Listado de alumnos`
- `Listado de horarios`, `Listado de horas`, `Listado de dias`, `Listado de aulas`
- `Listado de secciones`, `Listado de parciales`
- `Listado de notas`

> ⚠️ Actualmente no existen pantallas CRUD para `notas` ni `parciales`. Cuando se creen, deben asignarse a este rol (al menos `Crear/Editar notas`).

### 4. secretaria
Encargada de matrícula y datos de contacto:

- **CRUD:** `alumnos`, `encargados`, `parentescos` (sin eliminar parentescos por ser catálogo)
- **Lectura:** `personas`, `cursos`, `cursos niveles`, `materias`, `duraciones`, `secciones`, `semestres`, `modalidades`, `niveles educativos`, `horarios`, `horas`, `dias`, `aulas`, `titulos`, `estados`

### 5. recursos humanos
Gestión de planilla y puestos:

- **CRUD:** `empleados`, `cargos`
- **Lectura:** `personas`

### 6. cajero
Caja del día. Puede registrar y corregir pagos, pero **no eliminarlos** (auditabilidad):

- **Crear/Editar:** `pagos`
- **Lectura:** `cuentas por cobrar`, `conceptos de pago`, `formas de pago`, `estados de pago`, `alumnos`, `personas`

### 7. contador
Configuración financiera y reportes consolidados:

- **CRUD completo** de todo el grupo `Financiero` (incluye `descuentos`, `tarifas`, `cuentas por cobrar`, `pagos`, `reportes financieros`, `guia financiera`)
- **Lectura:** `alumnos`, `personas`

### 8. consulta
Rol de solo lectura para auditores externos, junta directiva o supervisores:

- Todos los `Listado de…` de cualquier grupo **excepto** `Seguridad`
- `Reportes financieros`, `Guia financiera`, `Home`
- Sin ningún permiso de `Crear/Editar/Eliminar`

---

## Notas de mantenimiento

- **Idempotencia:** El script 005 verifica `IF NOT EXISTS` antes de insertar cada rol, así que se puede re-ejecutar sin duplicar.
- **Nuevas pantallas:** Cuando se agreguen pantallas al sistema, hay que decidir manualmente a qué roles asignarlas. Considerar agregar al admin automáticamente como hacen los scripts 001 y 004.
- **Coordinador Académico:** Se evaluó este rol pero se descartó por solaparse con `director` y `secretaria`. Si en el futuro hace falta, sus permisos sugeridos serían: CRUD de `Cursos`, `Horarios`, `Institucion` y `Academico`; lectura de `Alumnos`; sin `RRHH`, `Financiero` ni `Seguridad`.
- **Convención de nombres:** Los nombres de rol se guardan en minúsculas, coherentes con `admin` (el rol existente).
