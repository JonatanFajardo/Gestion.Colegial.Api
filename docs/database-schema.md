# Esquema de Base de Datos — `DB_GestionColegial`

> **Generado desde el servidor real** (`(localdb)\MSSQLLocalDB`, base `DB_GestionColegial`) consultando `sys.tables`, `sys.columns` y `sys.foreign_keys`.
>
> **Resumen:** 4 schemas · 79 tablas · 124 foreign keys físicas.

## Índice
- [1. Resumen por schema](#1-resumen-por-schema)
- [2. Schema `seguridad`](#2-schema-seguridad)
- [3. Schema `app`](#3-schema-app)
- [4. Schema `finanza`](#4-schema-finanza)
- [5. Schema `bitacoras`](#5-schema-bitacoras)
- [6. Foreign keys consolidadas](#6-foreign-keys-consolidadas)
- [7. Diagrama de relaciones principales](#7-diagrama-de-relaciones-principales)
- [8. Hallazgos e inconsistencias](#8-hallazgos-e-inconsistencias)

---

## 1. Resumen por schema

| Schema | # Tablas | Propósito |
|---|---|---|
| `app` | 51 | Académico, operativo y catálogos |
| `finanza` | 14 | Pagos, cuentas por cobrar, caja, tarifas |
| `seguridad` | 5 | Usuarios, roles, pantallas, sesiones, bitácora |
| `bitacoras` | 7 | Histórico append-only de cambios (sin FK) |

**Convención de columnas de auditoría** (presentes en casi todas las tablas, omitidas en las tablas siguientes salvo mención):
`{Prefix}_EsEliminado BIT`, `{Prefix}_UsuarioRegistra INT`, `{Prefix}_FechaRegistra DATETIME`, `{Prefix}_UsuarioModifica INT NULL`, `{Prefix}_FechaModifica DATETIME NULL`.

---

## 2. Schema `seguridad`

### `seguridad.tbUsuarios`
| Columna | Tipo | Nullable | Notas |
|---|---|---|---|
| **`Usu_Id`** | int | NOT NULL | PK, IDENTITY |
| `Emp_Id` | int | NOT NULL | FK lógica → `app.tbEmpleados` (sin restricción física) |
| `Usu_Name` | nvarchar | NOT NULL | |
| `Usu_Contraseña` | varchar | NOT NULL | |
| `Rol_Id` | int | NOT NULL | FK lógica → `seguridad.tbRoles` (sin restricción física) |
| `Usu_Ip` | varchar | NULL | |
| `Usu_EsActivo` | bit | NOT NULL | |
| `Usu_Suspendido` | bit | NULL | |
| `Usu_EsEliminado` | bit | NULL | |
| `Usu_FechaCreacion` | datetime | NULL | |
| `Usu_fechaModificacion` | datetime | NULL | |

### `seguridad.tbRoles`
| Columna | Tipo | Nullable | Notas |
|---|---|---|---|
| **`Rol_Id`** | int | NOT NULL | PK, IDENTITY |
| `Rol_Descripcion` | nvarchar | NOT NULL | |
| `Rol_Estado` | bit | NOT NULL | |
| *audit* | | | `Rol_EsEliminado`, `Rol_UsuarioRegistra`, `Rol_FechaRegistra`, `Rol_UsuarioModifica`, `Rol_FechaModifica` |

### `seguridad.tbPantallas`
| Columna | Tipo | Nullable | Notas |
|---|---|---|---|
| **`Pan_Id`** | int | NOT NULL | PK, IDENTITY |
| `Pan_Descripcion` | nvarchar | NOT NULL | |
| `Pan_Estado` | bit | NOT NULL | |
| `Pan_Grupo` | nvarchar | NULL | Agrupa pantallas por menú |
| *audit* | | | `Pan_EsEliminado`, `Pan_UsuarioRegistra` (NULL), `Pan_FechaRegistra`, `Pan_UsuarioModifica`, `Pan_FechaModifica` |

### `seguridad.tbRolesPantallas` (puente N:N)
| Columna | Tipo | Nullable | FK |
|---|---|---|---|
| **`RolPan_Id`** | int | NOT NULL | PK, IDENTITY |
| `Rol_Id` | int | NOT NULL | → `seguridad.tbRoles.Rol_Id` |
| `Pan_Id` | int | NOT NULL | → `seguridad.tbPantallas.Pan_Id` |

### `seguridad.tbSesiones`
| Columna | Tipo | Nullable | FK |
|---|---|---|---|
| **`Ses_Id`** | int | NOT NULL | PK, IDENTITY |
| `Usu_Id` | int | NOT NULL | → `seguridad.tbUsuarios.Usu_Id` |
| `Ses_Token` | nvarchar | NOT NULL | |
| `Ses_FechaInicio` | datetime | NOT NULL | |
| `Ses_UltimaActividad` | datetime | NOT NULL | |
| `Ses_IP` | varchar | NULL | |
| `Ses_UserAgent` | nvarchar | NULL | |
| `Ses_EsActiva` | bit | NOT NULL | |
| `Ses_FechaCierre` | datetime | NULL | |

### `seguridad.tbBitacora`
| Columna | Tipo | Nullable | FK |
|---|---|---|---|
| **`Bit_Id`** | int | NOT NULL | PK, IDENTITY |
| `Usu_Id` | int | NOT NULL | → `seguridad.tbUsuarios.Usu_Id` |
| `Bit_Accion` | varchar | NOT NULL | |
| `Bit_Tabla` | varchar | NULL | Tabla afectada |
| `Bit_RegistroId` | int | NULL | |
| `Bit_Descripcion` | varchar | NULL | |
| `Bit_Ip` | varchar | NULL | |
| `Bit_Fecha` | datetime | NOT NULL | |

> **Nota:** Casi todas las tablas de `app` y `finanza` tienen FK físicas hacia `seguridad.tbUsuarios.Usu_Id` a través de `*_UsuarioRegistra` y `*_UsuarioModifica` (más de 40 FK de auditoría en total).

---

## 3. Schema `app`

### 3.1 Personas y relaciones

#### `app.tbPersonas`
| Columna | Tipo | Nullable |
|---|---|---|
| **`Per_Id`** | int | NOT NULL — PK, IDENTITY |
| `Per_Imagen` | varchar | NULL |
| `Per_Identidad` | varchar | NOT NULL |
| `Per_PrimerNombre` | nvarchar | NOT NULL |
| `Per_SegundoNombre` | nvarchar | NULL |
| `Per_ApellidoPaterno` | nvarchar | NOT NULL |
| `Per_ApellidoMaterno` | nvarchar | NULL |
| `Per_FechaNacimiento` | date | NOT NULL |
| `Per_CorreoElectronico` | varchar | NULL |
| `Per_Telefono` | varchar | NOT NULL |
| `Per_Direccion` | varchar | NOT NULL |
| `Per_Sexo` | char | NOT NULL |
| `Per_EsActivo` | bit | NOT NULL |
| *audit* | | `Per_EsEliminado`, `Per_UsuarioRegistra`, `Per_FechaRegistra`, `Per_UsuarioModifica`, `Per_FechaModifica` |

#### `app.tbAlumnos`
| Columna | Tipo | FK |
|---|---|---|
| **`Alu_Id`** | int — PK, IDENTITY | |
| `Per_Id` | int NOT NULL | → `app.tbPersonas.Per_Id` |
| `Niv_Id` | int NULL | → `app.tbNivelesEducativos.Niv_Id` |
| `Cun_Id` | int NULL | → `app.tbCursosNiveles.Cun_Id` |
| `Mda_Id` | int NULL | → `app.tbModalidades.Mda_Id` |
| `Cur_Id` | int NOT NULL | → `app.tbCursos.Cur_Id` |
| `Sec_Id` | int NULL | → `app.tbSecciones.Sec_Id` |
| `Est_Id` | int NOT NULL | → `app.tbEstados.Est_Id` |
| `AnioCursado` | int NULL | |
| `PromedioAnual` | decimal NULL | |

#### `app.tbEmpleados`
| Columna | Tipo | FK |
|---|---|---|
| **`Emp_Id`** | int — PK, IDENTITY | |
| `Emp_Codigo` | varchar NOT NULL | |
| `Per_Id` | int NOT NULL | → `app.tbPersonas.Per_Id` |
| `Tit_Id` | int NOT NULL | → `app.tbTitulos.Tit_Id` |
| `Car_Id` | int NOT NULL | → `app.tbCargos.Car_Id` |
| `Dep_Id` | int NULL | → `app.tbDepartamentoEmpleados.Dep_Id` |

#### `app.tbEncargados`
| Columna | Tipo | FK |
|---|---|---|
| **`Enc_Id`** | int — PK, IDENTITY | |
| `Per_Id` | int NOT NULL | → `app.tbPersonas.Per_Id` |
| `Enc_Ocupacion` | varchar NULL | |

#### `app.tbEncargados_tbAlumnos` (puente N:N)
| Columna | Tipo | FK |
|---|---|---|
| **`Enc_Id`** | int — PK | → `app.tbEncargados.Enc_Id` |
| **`Alu_Id`** | int — PK | → `app.tbAlumnos.Alu_Id` |
| `Par_Id` | int NOT NULL | → `app.tbParentescos.Par_Id` |

### 3.2 Catálogos académicos

| Tabla | PK | Columnas notables | FK |
|---|---|---|---|
| `app.tbNivelesEducativos` | `Niv_Id` (IDENT) | `Niv_Descripcion`, `Niv_EsActivo` | — |
| `app.tbCursosNiveles` | `Cun_Id` (IDENT) | `Cun_Orden`, `Cun_Descripcion`, `Niv_Id` | → `tbNivelesEducativos` |
| `app.tbCursos` | `Cur_Id` (IDENT) | `Cur_Nombre`, `Niv_Id`, `Cur_EsActivo` | → `tbNivelesEducativos` |
| `app.tbSecciones` | `Sec_Id` (IDENT) | `Sec_Descripcion` | — |
| `app.tbMaterias` | `Mat_Id` (IDENT) | `Mat_Nombre`, `Dur_Id`, `Mat_EsActivo` | → `tbDuraciones` |
| `app.tbDuraciones` | `Dur_Id` (IDENT) | `Dur_Descripcion` | — |
| `app.tbAulas` | `Aul_Id` (IDENT) | `Aul_Descripcion` | — |
| `app.tbDias` | `Dia_Id` (IDENT) | `Dia_Descripcion` | — |
| `app.tbHoras` | `Hor_Id` (IDENT) | `Hor_Hora` (varchar slot) | — |
| `app.tbModalidades` | `Mda_Id` (IDENT) | `Mda_Descripcion` | — |
| `app.tbSemestres` | `Sem_Id` (IDENT) | `Sem_Descripcion`, `Sem_EsActivo` | — |
| `app.tbParciales` | `Pac_Id` (IDENT) | `Pac_Descripcion` | — |
| `app.tbCargos` | `Car_Id` (IDENT) | `Car_Descripcion` | — |
| `app.tbTitulos` | `Tit_Id` (IDENT) | `Tit_Descripcion` | — |
| `app.tbDepartamentoEmpleados` | `Dep_Id` (IDENT) | `Nombre` (varchar) | — |
| `app.tbParentescos` | `Par_Id` (IDENT) | `Par_Descripcion` | — |
| `app.tbEstados` | `Est_Id` (IDENT) | `Est_Descripcion` | — |
| `app.tbTiposDocumento` | `TDoc_Id` (IDENT) | `TDoc_Descripcion`, `TDoc_EsObligatorio`, `TDoc_EsActivo` | — |

### 3.3 Tablas puente N:N

| Tabla puente | PK compuesta | FKs |
|---|---|---|
| `app.tbCursos_tbCursosNiveles` | `Cur_Id`, `Cun_Id` | → `tbCursos`, `tbCursosNiveles` |
| `app.tbCursos_tbMaterias` | `Cur_Id`, `Mat_Id` | → `tbCursos`, `tbMaterias` |
| `app.tbCursos_tbModalidades` | `Cur_Id`, `Mda_Id` | → `tbCursos`, `tbModalidades` |
| `app.tbCursos_tbSecciones` | `Cur_Id`, `Sec_Id` | → `tbCursos`, `tbSecciones`, `tbAulas` |
| `app.tbEmpleados_tbMaterias` | `Emp_Id`, `Mat_Id` | → `tbEmpleados`, `tbMaterias` |
| `app.tbModalidades_tbCursosNiveles` | `Cun_Id`, `Mda_Id` | → `tbCursosNiveles`, `tbModalidades` |

### 3.4 Horarios (⚠️ ver hallazgo de duplicación en §8)

#### `app.tbHorario` (legacy, sin FK declaradas)
PK `Hor_Id` (IDENT). Columnas: `Cur_Id`, `Cun_Id`, `Mat_Id`, `Emp_Id`, `Sec_Id`, `Aul_Id`, `Dia_Id`, `Hor_HoraInicio`, `Hor_HoraFinaliza`, `Sem_Id`, `Mda_Id`, `Hor_Año`. Sin FKs físicas.

#### `app.tbHorarios` (canónica)
PK `Hor_Id` (IDENT). Mismas columnas que `tbHorario`, **con FK completas**:
- `Cur_Id` → `tbCursos`, `Cun_Id` → `tbCursosNiveles`, `Mat_Id` → `tbMaterias`, `Emp_Id` → `tbEmpleados`, `Sec_Id` → `tbSecciones`, `Aul_Id` → `tbAulas`, `Dia_Id` → `tbDias`
- `Hor_HoraInicio` → `tbHoras.Hor_Id`, `Hor_HoraFinaliza` → `tbHoras.Hor_Id`
- `Sem_Id` → `tbSemestres`, `Mda_Id` → `tbModalidades`

#### `app.tbHorarioAlumnos`
PK `HoAl_Id` (IDENT). Estructura paralela: `Cur_Id`, `Cun_Id`, `Mat_Id`, `HoAl_HoraInicio`/`Finaliza`, `Dia_Id`, `Sec_Id`, `Aul_Id`, `Emp_Id`, `Sem_Id`, `Mda_Id`, `HoAl_Año`. Todas con FK físicas.

#### `app.tbHorarioProfesores`
PK `HoPr_Id` (IDENT). Misma estructura que `tbHorarioAlumnos`, prefijo `HoPr_`. Todas con FK físicas.

### 3.5 Académico transaccional

#### `app.tbAsistencia`
| Columna | Tipo | FK |
|---|---|---|
| **`Asi_Id`** | int — PK, IDENT | |
| `Hor_Id` | int NOT NULL | → `app.tbHorario.Hor_Id` ⚠️ (legacy, no `tbHorarios`) |
| `Alu_Id` | int NOT NULL | → `app.tbAlumnos.Alu_Id` |
| `Asi_Fecha` | date NOT NULL | |
| `Asi_Estado` | char NOT NULL | P/A/T/J |
| `Asi_Observacion` | varchar NULL | |

#### `app.tbAsistenciaEmpleados`
| Columna | Tipo | FK |
|---|---|---|
| **`AsiEmp_Id`** | int — PK, IDENT | |
| `Emp_Id` | int NOT NULL | → `app.tbEmpleados.Emp_Id` |
| `AsiEmp_Fecha` | date NOT NULL | |
| `AsiEmp_Tipo` | varchar NOT NULL | |
| `AsiEmp_Observacion` | varchar NULL | |

#### `app.tbNotas`
| Columna | Tipo | FK |
|---|---|---|
| **`Not_Id`** | int — PK, IDENT | |
| `Alu_Id` | int NULL | ⚠️ FK lógica → `tbAlumnos` (sin restricción física) |
| `Aul_Id` | int NULL | ⚠️ FK lógica → `tbAulas` (sin restricción física) |
| `Sec_Id` | int NULL | ⚠️ FK lógica → `tbSecciones` (sin restricción física) |
| `Not_Nota` | int NOT NULL | |
| `Mat_Id` | int NOT NULL | → `app.tbMaterias.Mat_Id` |
| `Sem_Id` | int NOT NULL | → `app.tbSemestres.Sem_Id` |
| `Pac_Id` | int NOT NULL | → `app.tbParciales.Pac_Id` |
| `Not_Año` | **date** | ⚠️ Es DATE, no INT — filtrar con `YEAR(Not_Año)=@Anio` |
| `Not_EsActivo` | bit NOT NULL | |

#### `app.tbPlanClases`
PK `Pla_Id`. FK: `Hor_Id` → `app.tbHorarios.Hor_Id`. Columnas: `Pla_Semana`, `Pla_Tema`, `Pla_Objetivos`, `Pla_Recursos`, `Pla_Estado`.

#### `app.tbTareas`
PK `Tar_Id`. FK: `Hor_Id` → `app.tbHorarios.Hor_Id`. Columnas: `Tar_Titulo`, `Tar_Descripcion`, `Tar_FechaEntrega`, `Tar_Punteo`, `Tar_Estado`.

#### `app.tbDocumentosAlumno`
PK `Doa_Id`. FKs: `Alu_Id` → `tbAlumnos`, `TDoc_Id` → `tbTiposDocumento`. Columnas: `Doa_EsEntregado`, `Doa_FechaEntrega`, `Doa_Observacion`.

#### `app.tbDocumentosEmpleado`
PK `DocEmp_Id`. FK: `Emp_Id` → `tbEmpleados`. Columnas: `Documento` (varchar libre), `EsEntregado`, `FechaEntrega`, `Observacion`. **Sin tabla catálogo para `Documento`.**

#### `app.tbVacaciones`
PK `Vac_Id`. FK: `Emp_Id` → `tbEmpleados`. Columnas: `Vac_Tipo` (V/P/I), `Vac_FechaInicio`, `Vac_FechaFin`, `Vac_DiasTotal`, `Vac_Estado` (P/A/R), `Vac_Motivo`.

### 3.6 Graduación (snapshot histórico)

#### `app.tbAlumnosGraduados`
PK `AluGrad_Id`. **Sin FK** (snapshot denormalizado). Columnas: `AluGrad_Identidad`, `AluGrad_NombreCompleto`, `AluGrad_FechaNacimiento`, `AluGrad_Sexo`, `AluGrad_Correo`, `AluGrad_Telefono`, `AluGrad_NivelEducativo`, `AluGrad_TituloObtenido`, `AluGrad_AnioIngreso`, `AluGrad_AnioGraduacion`, `AluGrad_TotalPagado`, `AluGrad_EncargadosJson`, `AluGrad_AluIdOriginal` (referencia informativa, sin FK), `AluGrad_FechaArchivo`, `AluGrad_UsuarioArchivo`.

#### `app.tbBoletinesGraduados`
PK `BolGrad_Id`. FK: `AluGrad_Id` → `tbAlumnosGraduados`. Columnas: `BolGrad_Anio`, `BolGrad_NivelEducativo`, `BolGrad_Grado`, `BolGrad_Seccion`, `BolGrad_Materia`, `BolGrad_NotaParcial1..4`, `BolGrad_NotaFinal`, `BolGrad_Observaciones`, `BolGrad_FechaArchivo`.

#### `app.tbArchivoGraduadoLog`
PK `LogArc_Id` (bigint). FK: `LogArc_AluGrad_Id` → `tbAlumnosGraduados`. Columnas: `LogArc_AluIdOriginal`, `LogArc_TablaAfectada`, `LogArc_Accion` (DELETE/MIGRATE/AGGREGATE), `LogArc_RegistrosAfectados`, `LogArc_Detalle` (nvarchar JSON), `LogArc_FechaEvento`, `LogArc_UsuarioId`.

### 3.7 Comunicación y configuración

| Tabla | PK | Notas |
|---|---|---|
| `app.tbAnuncios` | `Anu_Id` (IDENT) | `Anu_Titulo`, `Anu_Contenido`, `Anu_FechaPublicacion`, `Anu_FechaExpiracion`, `Anu_Activo`. Sin FK. |
| `app.tbMensajes` | `Msg_Id` (IDENT) | `Msg_Asunto`, `Msg_Contenido`, `Msg_FechaEnvio`, `Msg_Estado`, `Alu_Id`, `Enc_Id`, `UsuarioEnvia`. ⚠️ Sin FK físicas. |
| `app.tbNotificaciones` | `Not_Id` (IDENT) | `Usu_Id` → `seguridad.tbUsuarios`, `Not_Titulo`, `Not_Mensaje`, `Not_Tipo`, `Not_EsLeida`, `Not_UrlDestino`, `Not_FechaEnvio`, `Not_FechaLectura`. |
| `app.tbConfiguracion` | `Con_Id` (IDENT) | Clave-valor del sistema: `Con_Clave`, `Con_Valor`, `Con_Descripcion`, `Con_Grupo`, `Con_Tipo`. ⚠️ Audit sin prefijo (`FechaModifica`, `UsuarioModifica`). |
| `app.tbEventoError` | **sin PK** ⚠️ | `Err_Id` (no IDENT, no PK), `Err_NombreArchivo`, `Err_Fecha`, `Err_Ruta`, `Err_Message`, `Err_InnerException`. |
| `app.tbCursosDetalles` | `CursoDetalleId` (IDENT) | Combinaciones de `Niv_Id`, `Cun_Id`, `Mda_Id`, `Cur_Id`, `Sec_Id`. Sin FK. |
| `app.tbMatriculas` | **sin PK** ⚠️ | Solo `Matri_Id`, `Alu_Id`, **ambos nullable**. Estructura incompleta. |
| `app.tbModalidad_tbDias-PROXIMAMENTE` | `Mdia_Id` (IDENT) | ⚠️ Tabla WIP. Nombre con guion → requiere `[brackets]`. FKs: `Mda_Id` → `tbModalidades`, `Dia_Id` → `tbDias`. |

---

## 4. Schema `finanza`

### 4.1 Catálogos financieros

| Tabla | PK | Columnas notables |
|---|---|---|
| `finanza.tbConceptosPago` | `Cpa_Id` (IDENT) | `Cpa_Descripcion`, `Cpa_EsRecurrente`, `Cpa_EsObligatorio`, `Cpa_EsActivo` |
| `finanza.tbFormasPago` | `Fpa_Id` (IDENT) | `Fpa_Descripcion`, `Fpa_EsActivo` |
| `finanza.tbEstadosPago` | `Epa_Id` (IDENT) | `Epa_Descripcion`, `Epa_EsActivo` |
| `finanza.tbDescuentos` | `Des_Id` (IDENT) | `Des_Descripcion`, `Des_TipoDescuento` (char), `Des_Valor` (decimal), `Des_EsActivo` |

### 4.2 Tarifas

#### `finanza.tbTarifas`
| Columna | Tipo | FK |
|---|---|---|
| **`Tar_Id`** | int — PK, IDENT | |
| `Cpa_Id` | int NOT NULL | → `finanza.tbConceptosPago` |
| `Niv_Id` | int NULL | ⚠️ FK lógica → `app.tbNivelesEducativos` (sin restricción física) |
| `Cun_Id` | int NULL | ⚠️ FK lógica → `app.tbCursosNiveles` (sin restricción física) |
| `Tar_Monto` | decimal NOT NULL | |
| `Tar_AnioVigencia` | smallint NOT NULL | |
| `Tar_EsActivo` | bit NOT NULL | |

#### `finanza.tbTarifasMensualidades`
| Columna | Tipo | FK |
|---|---|---|
| **`TarMen_Id`** | int — PK, IDENT | |
| `Cun_Id` | int NOT NULL | ⚠️ FK lógica → `app.tbCursosNiveles` |
| `Mda_Id` | int NOT NULL | ⚠️ FK lógica → `app.tbModalidades` |
| `TarMen_Monto` | decimal NOT NULL | |
| `TarMen_EsActivo` | bit NOT NULL | |

### 4.3 Cuentas por cobrar

#### `finanza.tbCuentasCobrar`
| Columna | Tipo | FK |
|---|---|---|
| **`Cco_Id`** | int — PK, IDENT | |
| `Alu_Id` | int NOT NULL | ⚠️ FK lógica → `app.tbAlumnos` (sin restricción física) |
| `Cpa_Id` | int NOT NULL | → `finanza.tbConceptosPago` |
| `Tar_Id` | int NULL | → `finanza.tbTarifas` |
| `Cco_MontoOriginal` | decimal NOT NULL | |
| `Cco_MontoDescuento` | decimal NOT NULL | |
| `Cco_MontoMora` | decimal NOT NULL | |
| `Cco_MontoTotal` | decimal NOT NULL | |
| `Cco_MontoPendiente` | decimal NOT NULL | |
| `Cco_FechaEmision` | date NOT NULL | |
| `Cco_FechaVencimiento` | date NOT NULL | |
| `Epa_Id` | int NOT NULL | → `finanza.tbEstadosPago` |
| `Cco_Observaciones` | nvarchar NULL | |
| `Cco_Mes` | tinyint NULL | |
| `Cco_Anio` | smallint NULL | |

#### `finanza.tbDescuentosAplicados`
| Columna | Tipo | FK |
|---|---|---|
| **`Dap_Id`** | int — PK, IDENT | |
| `Cco_Id` | int NOT NULL | → `finanza.tbCuentasCobrar` |
| `Des_Id` | int NOT NULL | → `finanza.tbDescuentos` |
| `Dap_MontoAplicado` | decimal NOT NULL | |
| `Dap_Justificacion` | nvarchar NULL | |

#### `finanza.tbMoratorias`
| Columna | Tipo | FK |
|---|---|---|
| **`Mor_Id`** | int — PK, IDENT | |
| `Cco_Id` | int NOT NULL | → `finanza.tbCuentasCobrar` |
| `Mor_DiasAtraso` | int NOT NULL | |
| `Mor_Porcentaje` | decimal NOT NULL | |
| `Mor_MontoMora` | decimal NOT NULL | |
| `Mor_FechaCalculo` | date NOT NULL | |

#### `finanza.tbCuentasCobrarHistorial`
PK `Cgh_Id` (IDENT). `Cco_Id`, `Cgh_Accion` (nvarchar), `Cgh_Detalle` (nvarchar JSON), `Cgh_Fecha`, `Cgh_Usuario`. Sin FK física.

### 4.4 Pagos y caja

#### `finanza.tbPagos`
| Columna | Tipo | FK |
|---|---|---|
| **`Pag_Id`** | int — PK, IDENT | |
| `Alu_Id` | int NOT NULL | ⚠️ FK lógica → `app.tbAlumnos` |
| `Enc_Id` | int NULL | ⚠️ FK lógica → `app.tbEncargados` |
| `Fpa_Id` | int NOT NULL | → `finanza.tbFormasPago` |
| `Pag_MontoTotal` | decimal NOT NULL | |
| `Pag_FechaPago` | datetime2 NOT NULL | |
| `Pag_NumeroReferencia` | nvarchar NULL | |
| `Pag_Observaciones` | nvarchar NULL | |
| `Usu_Id` | int NOT NULL | ⚠️ FK lógica → `seguridad.tbUsuarios` |

#### `finanza.tbPagosDetalle`
| Columna | Tipo | FK |
|---|---|---|
| **`Pde_Id`** | int — PK, IDENT | |
| `Pag_Id` | int NOT NULL | → `finanza.tbPagos` |
| `Cco_Id` | int NOT NULL | → `finanza.tbCuentasCobrar` |
| `Pde_MontoAplicado` | decimal NOT NULL | |

#### `finanza.tbRecibos`
PK `Rec_Id` (IDENT). FK: `Pag_Id` → `tbPagos`. Columnas: `Rec_NumeroRecibo`, `Rec_FechaEmision`, `Rec_RutaArchivo`.

#### `finanza.tbPagosHistorial`
PK `Pgh_Id` (IDENT). `Pag_Id`, `Pgh_Accion`, `Pgh_Detalle` (JSON), `Pgh_Fecha`, `Pgh_Usuario`.

#### `finanza.tbArqueosCaja`
| Columna | Tipo | FK |
|---|---|---|
| **`Arq_Id`** | int — PK, IDENT | |
| `Usu_Id` | int NOT NULL | → `seguridad.tbUsuarios` (cajero) |
| `Arq_Fecha` | date NOT NULL | |
| `Arq_TotalEfectivo` | decimal NOT NULL | |
| `Arq_TotalTransferencia` | decimal NOT NULL | |
| `Arq_TotalTarjeta` | decimal NOT NULL | |
| `Arq_TotalGeneral` | decimal NULL | (computed) |
| `Arq_Observaciones` | varchar NULL | |

---

## 5. Schema `bitacoras`

Tablas **append-only sin FK** (por diseño). Cada una replica la estructura de su entidad origen + 4 columnas de auditoría: `Accion` (char I/U/D), `Fecha` (datetime), `Usuario` (varchar), `HostName` (varchar). Pobladas típicamente por triggers en las tablas origen.

| Tabla | Espejo de | PK |
|---|---|---|
| `bitacoras.tbAlumnosHistorial` | `app.tbAlumnos` | `AluHistorialId` (IDENT) |
| `bitacoras.tbCursosHistorial` | `app.tbCursos` | `Cur_Id` (IDENT) |
| `bitacoras.tbEncargadosHistorial` | `app.tbEncargados` | `Enc_Id` (IDENT) |
| `bitacoras.tbHorarioAlumnosHistorial` | `app.tbHorarioAlumnos` | `HoAl_Id` (IDENT) |
| `bitacoras.tbMateriasHistorial` | `app.tbMaterias` | `Mat_Id` (IDENT) |
| `bitacoras.tbNotasHistorial` | `app.tbNotas` | `Not_Id` (IDENT) |
| `bitacoras.tbPersonasHistorial` | `app.tbPersonas` | `Per_Id` (IDENT) |

---

## 6. Foreign keys consolidadas

> Total: **124 FK físicas declaradas** en la BD. Omitidas las FK de auditoría (`*_UsuarioRegistra`/`*_UsuarioModifica` → `seguridad.tbUsuarios.Usu_Id`) por volumen.

### 6.1 Relacionales (no audit)

| Tabla origen | Columna origen | → | Tabla destino | Columna destino |
|---|---|---|---|---|
| `app.tbAlumnos` | `Per_Id` | → | `app.tbPersonas` | `Per_Id` |
| `app.tbAlumnos` | `Niv_Id` | → | `app.tbNivelesEducativos` | `Niv_Id` |
| `app.tbAlumnos` | `Cun_Id` | → | `app.tbCursosNiveles` | `Cun_Id` |
| `app.tbAlumnos` | `Cur_Id` | → | `app.tbCursos` | `Cur_Id` |
| `app.tbAlumnos` | `Sec_Id` | → | `app.tbSecciones` | `Sec_Id` |
| `app.tbAlumnos` | `Mda_Id` | → | `app.tbModalidades` | `Mda_Id` |
| `app.tbAlumnos` | `Est_Id` | → | `app.tbEstados` | `Est_Id` |
| `app.tbEmpleados` | `Per_Id` | → | `app.tbPersonas` | `Per_Id` |
| `app.tbEmpleados` | `Tit_Id` | → | `app.tbTitulos` | `Tit_Id` |
| `app.tbEmpleados` | `Car_Id` | → | `app.tbCargos` | `Car_Id` |
| `app.tbEmpleados` | `Dep_Id` | → | `app.tbDepartamentoEmpleados` | `Dep_Id` |
| `app.tbEncargados` | `Per_Id` | → | `app.tbPersonas` | `Per_Id` |
| `app.tbEncargados_tbAlumnos` | `Enc_Id` | → | `app.tbEncargados` | `Enc_Id` |
| `app.tbEncargados_tbAlumnos` | `Alu_Id` | → | `app.tbAlumnos` | `Alu_Id` |
| `app.tbEncargados_tbAlumnos` | `Par_Id` | → | `app.tbParentescos` | `Par_Id` |
| `app.tbCursos` | `Niv_Id` | → | `app.tbNivelesEducativos` | `Niv_Id` |
| `app.tbCursosNiveles` | `Niv_Id` | → | `app.tbNivelesEducativos` | `Niv_Id` |
| `app.tbMaterias` | `Dur_Id` | → | `app.tbDuraciones` | `Dur_Id` |
| `app.tbCursos_tbCursosNiveles` | `Cur_Id`, `Cun_Id` | → | `tbCursos`, `tbCursosNiveles` | |
| `app.tbCursos_tbMaterias` | `Cur_Id`, `Mat_Id` | → | `tbCursos`, `tbMaterias` | |
| `app.tbCursos_tbModalidades` | `Cur_Id`, `Mda_Id` | → | `tbCursos`, `tbModalidades` | |
| `app.tbCursos_tbSecciones` | `Cur_Id`, `Sec_Id`, `Aul_Id` | → | `tbCursos`, `tbSecciones`, `tbAulas` | |
| `app.tbEmpleados_tbMaterias` | `Emp_Id`, `Mat_Id` | → | `tbEmpleados`, `tbMaterias` | |
| `app.tbModalidades_tbCursosNiveles` | `Cun_Id`, `Mda_Id` | → | `tbCursosNiveles`, `tbModalidades` | |
| `app.tbAsistencia` | `Hor_Id` | → | `app.tbHorario` ⚠️ | `Hor_Id` |
| `app.tbAsistencia` | `Alu_Id` | → | `app.tbAlumnos` | `Alu_Id` |
| `app.tbAsistenciaEmpleados` | `Emp_Id` | → | `app.tbEmpleados` | `Emp_Id` |
| `app.tbNotas` | `Mat_Id` | → | `app.tbMaterias` | `Mat_Id` |
| `app.tbNotas` | `Sem_Id` | → | `app.tbSemestres` | `Sem_Id` |
| `app.tbNotas` | `Pac_Id` | → | `app.tbParciales` | `Pac_Id` |
| `app.tbHorarios` | `Cur_Id` | → | `app.tbCursos` | `Cur_Id` |
| `app.tbHorarios` | `Cun_Id` | → | `app.tbCursosNiveles` | `Cun_Id` |
| `app.tbHorarios` | `Mat_Id` | → | `app.tbMaterias` | `Mat_Id` |
| `app.tbHorarios` | `Emp_Id` | → | `app.tbEmpleados` | `Emp_Id` |
| `app.tbHorarios` | `Sec_Id` | → | `app.tbSecciones` | `Sec_Id` |
| `app.tbHorarios` | `Aul_Id` | → | `app.tbAulas` | `Aul_Id` |
| `app.tbHorarios` | `Dia_Id` | → | `app.tbDias` | `Dia_Id` |
| `app.tbHorarios` | `Hor_HoraInicio` | → | `app.tbHoras` | `Hor_Id` |
| `app.tbHorarios` | `Hor_HoraFinaliza` | → | `app.tbHoras` | `Hor_Id` |
| `app.tbHorarios` | `Sem_Id` | → | `app.tbSemestres` | `Sem_Id` |
| `app.tbHorarios` | `Mda_Id` | → | `app.tbModalidades` | `Mda_Id` |
| `app.tbHorarioAlumnos` | (11 FKs idénticas a `tbHorarios`) | → | catálogos correspondientes | |
| `app.tbHorarioProfesores` | (11 FKs idénticas a `tbHorarios`) | → | catálogos correspondientes | |
| `app.tbPlanClases` | `Hor_Id` | → | `app.tbHorarios` | `Hor_Id` |
| `app.tbTareas` | `Hor_Id` | → | `app.tbHorarios` | `Hor_Id` |
| `app.tbDocumentosAlumno` | `Alu_Id` | → | `app.tbAlumnos` | `Alu_Id` |
| `app.tbDocumentosAlumno` | `TDoc_Id` | → | `app.tbTiposDocumento` | `TDoc_Id` |
| `app.tbDocumentosEmpleado` | `Emp_Id` | → | `app.tbEmpleados` | `Emp_Id` |
| `app.tbVacaciones` | `Emp_Id` | → | `app.tbEmpleados` | `Emp_Id` |
| `app.tbNotificaciones` | `Usu_Id` | → | `seguridad.tbUsuarios` | `Usu_Id` |
| `app.tbBoletinesGraduados` | `AluGrad_Id` | → | `app.tbAlumnosGraduados` | `AluGrad_Id` |
| `app.tbArchivoGraduadoLog` | `LogArc_AluGrad_Id` | → | `app.tbAlumnosGraduados` | `AluGrad_Id` |
| `app.tbModalidad_tbDias-PROXIMAMENTE` | `Mda_Id`, `Dia_Id` | → | `tbModalidades`, `tbDias` | |
| `finanza.tbCuentasCobrar` | `Cpa_Id` | → | `finanza.tbConceptosPago` | `Cpa_Id` |
| `finanza.tbCuentasCobrar` | `Tar_Id` | → | `finanza.tbTarifas` | `Tar_Id` |
| `finanza.tbCuentasCobrar` | `Epa_Id` | → | `finanza.tbEstadosPago` | `Epa_Id` |
| `finanza.tbTarifas` | `Cpa_Id` | → | `finanza.tbConceptosPago` | `Cpa_Id` |
| `finanza.tbDescuentosAplicados` | `Cco_Id` | → | `finanza.tbCuentasCobrar` | `Cco_Id` |
| `finanza.tbDescuentosAplicados` | `Des_Id` | → | `finanza.tbDescuentos` | `Des_Id` |
| `finanza.tbMoratorias` | `Cco_Id` | → | `finanza.tbCuentasCobrar` | `Cco_Id` |
| `finanza.tbPagos` | `Fpa_Id` | → | `finanza.tbFormasPago` | `Fpa_Id` |
| `finanza.tbPagosDetalle` | `Pag_Id` | → | `finanza.tbPagos` | `Pag_Id` |
| `finanza.tbPagosDetalle` | `Cco_Id` | → | `finanza.tbCuentasCobrar` | `Cco_Id` |
| `finanza.tbRecibos` | `Pag_Id` | → | `finanza.tbPagos` | `Pag_Id` |
| `finanza.tbArqueosCaja` | `Usu_Id` | → | `seguridad.tbUsuarios` | `Usu_Id` |
| `seguridad.tbRolesPantallas` | `Rol_Id` | → | `seguridad.tbRoles` | `Rol_Id` |
| `seguridad.tbRolesPantallas` | `Pan_Id` | → | `seguridad.tbPantallas` | `Pan_Id` |
| `seguridad.tbSesiones` | `Usu_Id` | → | `seguridad.tbUsuarios` | `Usu_Id` |
| `seguridad.tbBitacora` | `Usu_Id` | → | `seguridad.tbUsuarios` | `Usu_Id` |

### 6.2 FKs de auditoría (resumidas)

Las siguientes tablas tienen FK `*_UsuarioRegistra` → `seguridad.tbUsuarios.Usu_Id` y `*_UsuarioModifica` → `seguridad.tbUsuarios.Usu_Id`:
`tbAulas`, `tbCargos`, `tbCursos`, `tbDias`, `tbDuraciones`, `tbEstados`, `tbMaterias`, `tbModalidades`, `tbNivelesEducativos`, `tbNotas`, `tbParciales`, `tbParentescos`, `tbPersonas`, `tbSecciones`, `tbSemestres`, `tbTitulos`, `tbHorarioAlumnos`.

---

## 7. Diagrama de relaciones principales

```
                     seguridad.tbUsuarios ──┐
                            │               │ (FK *_UsuarioRegistra/Modifica
                            │               │  en >17 tablas de app)
                            ├──► tbSesiones │
                            ├──► tbBitacora │
                            ├──► tbRolesPantallas ◄── tbRoles
                            │                  └─── tbPantallas
                            └──► finanza.tbArqueosCaja

app.tbPersonas (Per_Id)
   ├──► tbAlumnos ──► Niv / Cun / Cur / Sec / Mda / Est
   │        │
   │        ├──► tbAsistencia ──► tbHorario (LEGACY) ⚠️
   │        ├──► tbNotas (FK físicas solo a Mat/Sem/Pac)
   │        ├──► tbDocumentosAlumno ──► tbTiposDocumento
   │        ├──► tbEncargados_tbAlumnos ──► tbParentescos
   │        └──► finanza.tbCuentasCobrar [lógica, sin FK]
   │                  │
   │                  ├──► tbConceptosPago / tbTarifas / tbEstadosPago
   │                  ├──► tbDescuentosAplicados ──► tbDescuentos
   │                  ├──► tbMoratorias
   │                  └──► finanza.tbPagosDetalle ──► tbPagos ──► tbFormasPago
   │                                                         └──► tbRecibos
   ├──► tbEmpleados ──► tbTitulos / tbCargos / tbDepartamentoEmpleados
   │        ├──► tbHorarios / tbHorarioProfesores ──► Mat / Aul / Dia / Hora / Sec / Sem / Mda
   │        ├──► tbAsistenciaEmpleados
   │        ├──► tbVacaciones
   │        ├──► tbDocumentosEmpleado
   │        └──► tbEmpleados_tbMaterias ──► tbMaterias
   └──► tbEncargados

app.tbHorarios ──► tbPlanClases
              └──► tbTareas

app.tbAlumnosGraduados ──► tbBoletinesGraduados
                      └──► tbArchivoGraduadoLog

(bitacoras.* — append-only, sin FK)
```

---

## 8. Hallazgos e inconsistencias

1. **Duplicación de horarios.** `app.tbHorario` (legacy, sin FK) coexiste con `app.tbHorarios` (canónica). `app.tbAsistencia` aún apunta al legacy.
2. **Tablas sin PK.** `app.tbEventoError` y `app.tbMatriculas` no tienen PK declarada.
3. **`app.tbMatriculas`** además tiene todas sus columnas nullable — funcionalmente inutilizable hasta completar.
4. **Tabla WIP con guion.** `app.tbModalidad_tbDias-PROXIMAMENTE` requiere `[brackets]` en consultas.
5. **Schema en minúscula.** En BD es `seguridad` (lowercase); código C# y convenciones documentadas usan `Seguridad` (PascalCase). SQL Server case-insensitive lo tolera.
6. **FKs lógicas sin restricción física** — la integridad depende de la aplicación:
   - `seguridad.tbUsuarios.Emp_Id`, `Rol_Id`
   - `finanza.tbCuentasCobrar.Alu_Id`
   - `finanza.tbPagos.Alu_Id`, `Enc_Id`, `Usu_Id`
   - `finanza.tbTarifas.Niv_Id`, `Cun_Id`
   - `finanza.tbTarifasMensualidades.Cun_Id`, `Mda_Id`
   - `app.tbNotas.Alu_Id`, `Aul_Id`, `Sec_Id`
   - `app.tbMensajes.Alu_Id`, `Enc_Id`, `UsuarioEnvia`
7. **Convención de prefijo violada.** `app.tbConfiguracion` usa `FechaModifica`/`UsuarioModifica` sin prefijo `Con_`.
8. **Dos enfoques de historial coexisten:**
   - `bitacoras.*Historial` (trigger-based, tabla espejo).
   - `finanza.tbCuentasCobrarHistorial`, `finanza.tbPagosHistorial` (Accion + Detalle JSON, llenado desde SPs).
   - `seguridad.tbBitacora` (auditoría genérica centralizada).
9. **`app.tbDocumentosEmpleado.Documento`** es texto libre — no usa catálogo equivalente a `tbTiposDocumento`.
10. **`app.tbNotas.Not_Año` es DATE** (no INT). Filtrar siempre con `YEAR(Not_Año) = @Anio`.

---

*Documento generado consultando el catálogo del sistema. Para regenerar tras cambios en el esquema, ejecutar las consultas de `sys.tables`, `sys.columns` y `sys.foreign_keys` contra `DB_GestionColegial` y actualizar este archivo.*
