# Scripts de Graduación — Vista y SPs

Rama: `feature/graduacion-alumnos`
Schema destino: `app` (validado contra `DB_GestionColegial`).

## Orden de ejecución

Los DDL de tablas (`01..03`) se aplican primero. Estos crean:

- `app.tbAlumnosGraduados`
- `app.tbBoletinesGraduados`
- `app.tbArchivoGraduadoLog`

Luego, en este orden:

1. **`04_VW_CandidatosGraduacion.sql`** — Crea `app.vCandidatosGraduacion`.
2. **`05_SP_GraduarAlumno.sql`** — Crea `app.spGraduarAlumno` (transaccional por alumno).
3. **`06_SP_BackfillGraduadosHistoricos.sql`** — Crea `app.spBackfillGraduadosHistoricos`.

## Pre-requisitos

- Base de datos: `DB_GestionColegial` en `(localdb)\MSSQLLocalDB`.
- Schema `app` existente (es el schema real del proyecto — NO `academico`).
- Tablas `tbAlumnosGraduados`, `tbBoletinesGraduados`, `tbArchivoGraduadoLog`
  ya creadas con las columnas listadas en los DDL 01/02/03.

## Vista: `app.vCandidatosGraduacion`

Devuelve alumnos activos que cursan el último curso de su nivel, con
columnas de validación (`NotasOk`, `DeudaPendiente`, `DeudaOk`,
`EstadoValidacion`, `MotivosBloqueo`).

```sql
SELECT * FROM app.vCandidatosGraduacion
WHERE EstadoValidacion = 'Cumple';
```

## SP: `app.spGraduarAlumno`

Procesa la graduación de UN alumno dentro de una transacción.

```sql
EXEC app.spGraduarAlumno
     @Alu_Id    = 123,
     @UsuarioId = 1;
```

Errores típicos (vía `RAISERROR`):
- Alumno no existe.
- Alumno no está Activo.
- Alumno no es candidato (no está en último curso).
- Alumno no cumple (notas o deuda) — el mensaje incluye `MotivosBloqueo`.

### Lista canónica de tablas a purgar

Coincide exactamente con la lista del DDL (`00_README.md`). Validada vía
`sys.columns WHERE name='Alu_Id'`:

| Tabla | Política | Comentario |
|---|---|---|
| `app.tbNotas` | AGGREGATE + DELETE | Pivota a `tbBoletinesGraduados`, luego DELETE. |
| `app.tbAsistencia` | DELETE | Sin reaprovechamiento. |
| `app.tbMensajes` | DELETE | Sin reaprovechamiento. |
| `app.tbDocumentosAlumno` | DELETE | Sin reaprovechamiento. |
| `app.tbEncargados_tbAlumnos` | MIGRATE + DELETE | Snapshot JSON a `AluGrad_EncargadosJson`, luego DELETE. |
| `app.tbMatriculas` | DELETE | Sin reaprovechamiento. |
| `finanza.tbPagos` | AGGREGATE + DELETE | Suma a `AluGrad_TotalPagado`, luego DELETE. |
| `finanza.tbCuentasCobrar` | DELETE | Saldo ya validado = 0. |
| `app.tbAlumnos` | DELETE (final) | Padre — se borra al final. |

Tablas dependientes adicionales que se purgan ANTES por FKs (no tienen `Alu_Id`):

- `finanza.tbMoratorias` (FK a `tbCuentasCobrar`).
- `finanza.tbDescuentosAplicados` (FK a `tbCuentasCobrar`).
- `finanza.tbPagosDetalle` (FK a `tbPagos`).

EXCLUIDAS:

- `app.tbPersonas` — compartida con encargados/empleados (NO se borra).
- `app.tbHorarioAlumnos` — NO tiene `Alu_Id` (verificado).
- `bitacoras.tbAlumnosHistorial`, `bitacoras.tbHorarioAlumnosHistorial` — histórico, SKIP.

## SP: `app.spBackfillGraduadosHistoricos`

Migración masiva de alumnos ya marcados con `Est_Id = 3` (Graduado).

```sql
-- 1) Ver qué pasaría con los primeros 50 (no ejecuta nada):
EXEC app.spBackfillGraduadosHistoricos
     @Anio = NULL, @TopN = 50, @DryRun = 1;

-- 2) Ejecutar para los graduados del año 2024, lotes de 25:
EXEC app.spBackfillGraduadosHistoricos
     @Anio = 2024, @TopN = 25, @DryRun = 0, @UsuarioId = 1;
```

Devuelve `Procesados`, `Exitos`, `Fallos`. Cada caso queda en
`app.tbArchivoGraduadoLog`.

## Decisiones requeridas (input de negocio)

Ver bloques `-- DECISIÓN REQUERIDA:` y `-- TODO:` al inicio de cada `.sql`:

1. **Nota mínima de aprobación**: hoy parametrizada en
   `@NotaMinimaAprobacion DECIMAL(5,2) = 70` dentro del SP (y hardcoded en la
   vista). Confirmar valor real / mover a tabla de configuración.
2. **Identificación del "último curso"**: hoy se usa `MAX(Cun_Orden)` por
   `Niv_Id` en `tbCursosNiveles`. Alternativas si no es confiable:
     (a) Agregar `Cun_EsUltimo BIT` a `app.tbCursosNiveles`.
     (b) Agregar `Niv_CursoFinalCun_Id` en `app.tbNivelesEducativos`.
3. **AnioIngreso**: `tbAlumnos` no expone año de ingreso → se inserta NULL.
4. **TituloObtenido**: hoy aproximado como `Niv_Descripcion + ' - ' + Cun_Descripcion`.
5. **Pivote de parciales**: se asume `Pac_Id 1..4` → `BolGrad_NotaParcialN`.
   Validar contra `app.tbParciales`.

## Supuestos firmes (verificados contra DB)

- `app.tbBoletines` **no existe**; el snapshot se construye desde `app.tbNotas`.
- `app.tbHorarioAlumnos` no se purga: no referencia `Alu_Id`.
- `app.tbPersonas` no se elimina: compartida con otros perfiles.
- Tablas en `bitacoras.*` (historiales) se conservan como auditoría.
