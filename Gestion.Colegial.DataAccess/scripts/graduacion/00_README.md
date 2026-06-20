# Archivado de Alumnos Graduados - DDL

Solucion de archivo para alumnos que pasan a estado **Graduado**. Mueve los
datos relevantes a tablas planas de archivo y libera las tablas operativas.

## Sorpresas del esquema descubiertas

- El schema real **no es `academico`**, es **`app`**. Mantengo el prefijo
  `tb` y los prefijos de columna pedidos (`AluGrad_`, `BolGrad_`, `LogArc_`),
  pero las tablas se crean en `app.*` para ser consistentes con el resto
  (`app.tbAlumnos`, `app.tbPersonas`, etc.).
- `app.tbAlumnos` es muy lean: solo IDs (`Alu_Id, Per_Id, Niv_Id, Cun_Id,
  Mda_Id, Cur_Id, Sec_Id, Est_Id, AnioCursado, PromedioAnual`). Los datos
  personales (nombre, identidad, fecha nac., correo, etc.) viven en
  `app.tbPersonas` via `Per_Id`. El servicio de archivado debera hacer JOIN
  hacia `tbPersonas` para llenar el snapshot.
- El schema de finanzas se llama **`finanza`** (singular), no `finanzas`,
  aunque ambos schemas existen en la DB. Las tablas vivas estan en `finanza`.
- Solo **3 FKs declaradas** apuntan a `tbAlumnos`, pero hay **9 tablas**
  con columna `Alu_Id` (la mayoria sin FK formal). El servicio de archivado
  debe tratarlas todas explicitamente.
- `app.tbHorarioAlumnos` **NO** tiene `Alu_Id` (validado contra
  `sys.columns`). No aplica al flujo de purga.

## Lista canonica de tablas a purgar (verdad unica con el SP)

Esta lista debe coincidir 1:1 con la cabecera de `05_SP_GraduarAlumno.sql`.

| # | Tabla | FK declarada | Politica | Orden |
|---|---|---|---|---|
| 1 | `app.tbAsistencia` | Si | **DELETE** total | 5 |
| 2 | `app.tbDocumentosAlumno` | Si | **DELETE** | 7 |
| 3 | `app.tbEncargados_tbAlumnos` | Si | **MIGRATE** a `AluGrad_EncargadosJson` + DELETE | 8 |
| 4 | `app.tbMatriculas` | No | **DELETE** total | 9 |
| 5 | `app.tbMensajes` | No | **DELETE** total | 6 |
| 6 | `app.tbNotas` | No | **AGGREGATE** a `tbBoletinesGraduados` + DELETE | 4 |
| 7 | `finanza.tbPagos` | No | **AGGREGATE** a `AluGrad_TotalPagado` + DELETE | 2 |
| 8 | `finanza.tbCuentasCobrar` | No | **DELETE** (saldo ya validado en 0) | 3 |
| 9 | `app.tbAlumnos` | (padre) | **DELETE** final | 10 |

Cascade-aware (sin `Alu_Id` directo, pero con FK que bloquea el borrado):

| Tabla | FK hacia | Politica |
|---|---|---|
| `finanza.tbMoratorias` | `tbCuentasCobrar` | **DELETE** ANTES de `tbPagos` y `tbCuentasCobrar` (orden 1) |
| `finanza.tbDescuentosAplicados` | `tbCuentasCobrar` | **DELETE** ANTES (orden 1) |
| `finanza.tbPagosDetalle` | `tbPagos` | **DELETE** ANTES de `tbPagos` (orden 1) |

Excluidas:

| Tabla | Razon |
|---|---|
| `bitacoras.tbAlumnosHistorial` | **SKIP** — ya es archivo historico |
| `bitacoras.tbHorarioAlumnosHistorial` | **SKIP** — historico |
| `app.tbPersonas` | NO se borra (compartida con encargados/docentes) |
| `app.tbHorarioAlumnos` | No tiene `Alu_Id` (no aplica) |

> Toda accion debe quedar registrada en `app.tbArchivoGraduadoLog` con
> `LogArc_Accion` = `DELETE | MIGRATE | AGGREGATE | SKIP` y el conteo.

## Prerequisitos

### Estado "Graduado" en tbEstados

Verificado en la DB: **ya existe** con `Est_Id = 3, Est_Descripcion = 'Graduado'`.
No se requiere INSERT.

Si en otra instancia no existiera, ejecutar:

```sql
-- Solo si NO existe en el ambiente destino
INSERT INTO app.tbEstados (Est_Descripcion) VALUES ('Graduado');
```

## Orden de ejecucion

```
01_CREATE_tbAlumnosGraduados.sql     -- snapshot plano del alumno
02_CREATE_tbBoletinesGraduados.sql   -- detalle academico consolidado (FK a 01)
03_CREATE_tbArchivoGraduadoLog.sql   -- auditoria (FK informativa a 01)
```

## Notas de diseno

- `tbAlumnosGraduados.AluGrad_AluIdOriginal` es **referencia informativa** sin
  FK -- el `Alu_Id` original sera eliminado de `tbAlumnos`.
- `AluGrad_EncargadosJson` evita arrastrar `tbEncargados_tbAlumnos` al archivo.
  Si el negocio decide conservar la tabla puente, crear despues
  `tbEncargadosGraduados`.
- Las tres tablas son **idempotentes en creacion** (`IF OBJECT_ID ... DROP`).
  En produccion conviene cambiar a un patron migratorio sin DROP.
- No se crearon SPs todavia -- el siguiente paso del feature es escribir el
  `PR_ArchivarAlumnoGraduado` que orqueste la transaccion.
