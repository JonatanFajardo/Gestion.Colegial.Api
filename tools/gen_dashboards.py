#!/usr/bin/env python3
"""
gen_dashboards.py
=================================================================
Genera los 8 módulos de Dashboard para Gestion.Colegial.Api.

Patrón: un único endpoint por dashboard que llama al SP una sola
vez y lee todos los result sets con reader.NextResult(), devolviendo
un objeto contenedor con todas las secciones.

Uso:
    python tools/gen_dashboards.py
=================================================================
"""

from pathlib import Path

ROOT          = Path(__file__).parent.parent
ENTITIES_DIR  = ROOT / 'Gestion.Colegial.Entities'   / 'Entities' / 'dbo'
DA_IFACE_DIR  = ROOT / 'Gestion.Colegial.DataAccess' / 'Interfaces'
DA_REPO_DIR   = ROOT / 'Gestion.Colegial.DataAccess' / 'Repositories'
BIZ_IFACE_DIR = ROOT / 'Gestion.Colegial.Business'   / 'Interfaces'
BIZ_SVC_DIR   = ROOT / 'Gestion.Colegial.Business'   / 'Services'
CTRL_DIR      = ROOT / 'Gestion.Colegial.Api'         / 'Controllers'
PROGRAM_CS    = ROOT / 'Gestion.Colegial.Api'         / 'Program.cs'

NS_ENT  = 'Gestion.Colegial.Entities.Entities'
NS_DAI  = 'Gestion.Colegial.DataAccess.Interfaces'
NS_DAR  = 'Gestion.Colegial.DataAccess.Repositories'
NS_BI   = 'Gestion.Colegial.Business.Interfaces'
NS_BS   = 'Gestion.Colegial.Business.Services'
NS_CTRL = 'Gestion.Colegial.Api.Controllers'

CS = {
    'int': 'int', 'int?': 'int?', 'decimal': 'decimal', 'decimal?': 'decimal?',
    'string': 'string', 'bool': 'bool', 'bool?': 'bool?',
    'datetime': 'DateTime', 'datetime?': 'DateTime?',
    'date': 'DateTime', 'date?': 'DateTime?',
}
DB = {
    'int': 'DbType.Int32',    'int?': 'DbType.Int32',
    'decimal': 'DbType.Decimal', 'decimal?': 'DbType.Decimal',
    'string': 'DbType.String',
    'bool': 'DbType.Boolean',  'bool?': 'DbType.Boolean',
    'datetime': 'DbType.DateTime', 'datetime?': 'DbType.DateTime',
    'date': 'DbType.Date',    'date?': 'DbType.Date',
}

def cs(t):  return CS.get(t.lower(), 'string')
def dbt(t): return DB.get(t.lower(), 'DbType.String')

def has_datetime(sections):
    for _, fields in sections:
        for _, ft in fields:
            if 'datetime' in ft.lower() or ft.lower() == 'date':
                return True
    return False

# ─── Dashboard definitions ──────────────────────────────────────
# Each section: (SectionName, [(FieldName, type)], is_single_row)
#   is_single_row=True  → FirstOrDefault()  (KPI row)
#   is_single_row=False → ToList()          (collection)
DASHBOARDS = [
    {
        'entity': 'DashboardAdmin',
        'sp': 'PR_DashboardAdmin_Resumen',
        'schema': 'app',
        'params': [],  # (name, type)
        'sections': [
            ('Kpis', [
                ('TotalUsuariosActivos', 'int'),
                ('TotalRoles', 'int'),
                ('TotalPantallas', 'int'),
                ('AccionesHoy', 'int'),
            ], True),
            ('Bitacora', [
                ('Bit_Id', 'int'),
                ('Usu_Name', 'string'),
                ('Bit_Accion', 'string'),
                ('Bit_Tabla', 'string'),
                ('Bit_Descripcion', 'string'),
                ('Bit_Ip', 'string'),
                ('Bit_Fecha', 'datetime'),
            ], False),
            ('UsuariosPorRol', [
                ('Rol_Descripcion', 'string'),
                ('Total', 'int'),
            ], False),
        ],
    },
    {
        'entity': 'DashboardDirector',
        'sp': 'PR_DashboardDirector_KPIs',
        'schema': 'app',
        'params': [('Anio', 'int'), ('Mes', 'int')],
        'sections': [
            ('Kpis', [
                ('TotalAlumnos', 'int'),
                ('TotalEmpleados', 'int'),
                ('TotalCobradoMes', 'decimal'),
                ('TotalDeudaPendiente', 'decimal'),
                ('CuentasVencidas', 'int'),
            ], True),
            ('MatriculaPorCurso', [
                ('Cur_Nombre', 'string'),
                ('TotalAlumnos', 'int'),
            ], False),
            ('CobrosPorMes', [
                ('Mes', 'int'),
                ('Anio', 'int'),
                ('TotalCobrado', 'decimal'),
            ], False),
        ],
    },
    {
        'entity': 'DashboardDocente',
        'sp': 'PR_DashboardDocente_Hoy',
        'schema': 'app',
        'params': [('Emp_Id', 'int'), ('Dia_Id', 'int'), ('Anio', 'int')],
        'sections': [
            ('ClasesHoy', [
                ('Hor_Id', 'int'),
                ('Mat_Nombre', 'string'),
                ('Aul_Descripcion', 'string'),
                ('Sec_Descripcion', 'string'),
                ('Cur_Nombre', 'string'),
                ('Cun_Descripcion', 'string'),
                ('HoraInicio', 'string'),
                ('HoraFin', 'string'),
                ('AsistenciaRegistrada', 'int'),
            ], False),
            ('KpisDocente', [
                ('TotalAlumnos', 'int'),
                ('TotalMaterias', 'int'),
            ], True),
        ],
    },
    {
        'entity': 'DashboardSecretaria',
        'sp': 'PR_DashboardSecretaria_Resumen',
        'schema': 'app',
        'params': [('Anio', 'int')],
        'sections': [
            ('Kpis', [
                ('TotalMatriculados', 'int'),
                ('NuevasMesActual', 'int'),
                ('DocumentosPendientes', 'int'),
                ('AlumnosSinFoto', 'int'),
            ], True),
            ('MatriculaPorSeccion', [
                ('Cur_Nombre', 'string'),
                ('Sec_Descripcion', 'string'),
                ('TotalAlumnos', 'int'),
            ], False),
        ],
    },
    {
        'entity': 'DashboardRRHH',
        'sp': 'PR_DashboardRRHH_Resumen',
        'schema': 'app',
        'params': [('Anio', 'int'), ('Mes', 'int')],
        'sections': [
            ('Kpis', [
                ('TotalEmpleadosActivos', 'int'),
                ('CumpleanosMes', 'int'),
                ('PermisosPendientes', 'int'),
                ('NuevosEmpleadosAnio', 'int'),
            ], True),
            ('Cumpleanos', [
                ('NombreCompleto', 'string'),
                ('Per_FechaNacimiento', 'datetime'),
                ('Dia', 'int'),
                ('Per_Imagen', 'string'),
            ], False),
            ('VacacionesPendientes', [
                ('Vac_Id', 'int'),
                ('Vac_Tipo', 'string'),
                ('Vac_FechaInicio', 'datetime'),
                ('Vac_FechaFin', 'datetime'),
                ('Vac_DiasTotal', 'int'),
                ('Vac_Motivo', 'string'),
                ('NombreEmpleado', 'string'),
            ], False),
        ],
    },
    {
        'entity': 'DashboardCajero',
        'sp': 'PR_DashboardCajero_Hoy',
        'schema': 'app',
        'params': [('Usu_Id', 'int'), ('Fecha', 'date?')],
        'sections': [
            ('KpisCaja', [
                ('TotalCobradoHoy', 'decimal'),
                ('CantidadCobros', 'int'),
            ], True),
            ('CuentasPendientes', [
                ('CuentasPendientesHoy', 'int'),
                ('MontoPendienteHoy', 'decimal'),
            ], True),
            ('UltimoArqueo', [
                ('Arq_Id', 'int'),
                ('Arq_Fecha', 'datetime'),
                ('Arq_TotalGeneral', 'decimal'),
                ('Arq_Observaciones', 'string'),
            ], True),
            ('TimelinePagos', [
                ('Pag_Id', 'int'),
                ('Pag_MontoTotal', 'decimal'),
                ('Pag_FechaPago', 'datetime'),
                ('Pag_NumeroReferencia', 'string'),
                ('Fpa_Descripcion', 'string'),
                ('NombreAlumno', 'string'),
            ], False),
        ],
    },
    {
        'entity': 'DashboardFinanciero',
        'sp': 'PR_DashboardFinanciero_Resumen',
        'schema': 'app',
        'params': [('Anio', 'int'), ('Mes', 'int')],
        'sections': [
            ('KpisFinancieros', [
                ('TotalFacturadoMes', 'decimal'),
                ('TotalCobradoMes', 'decimal'),
                ('TotalPendiente', 'decimal'),
                ('TotalMora', 'decimal'),
            ], True),
            ('CobrosPorFormaPago', [
                ('Fpa_Descripcion', 'string'),
                ('Total', 'decimal'),
                ('Cantidad', 'int'),
            ], False),
            ('MorosidadPorConcepto', [
                ('Cpa_Descripcion', 'string'),
                ('CuentasMorosas', 'int'),
                ('MontoMoroso', 'decimal'),
            ], False),
        ],
    },
    {
        'entity': 'DashboardConsulta',
        'sp': 'PR_DashboardConsulta_KPIs',
        'schema': 'app',
        'params': [('Anio', 'int')],
        'sections': [
            ('Kpis', [
                ('TotalAlumnos', 'int'),
                ('TotalEmpleados', 'int'),
                ('TotalClases', 'int'),
                ('PorcentajeCobrado', 'decimal'),
            ], True),
            ('MatriculaPorCurso', [
                ('Cur_Nombre', 'string'),
                ('TotalAlumnos', 'int'),
            ], False),
        ],
    },
]


def write(path: Path, content: str, label: str = ''):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        print(f'  [SKIP]  {path.relative_to(ROOT)}')
        return
    path.write_text(content, encoding='utf-8')
    print(f'  [NEW]   {path.relative_to(ROOT)}')


# ─── Generators ─────────────────────────────────────────────────

def gen_section_result(entity, sec_name, fields):
    props = '\n'.join(
        f'        public {cs(ft)} {fn} {{ get; set; }}'
        for fn, ft in fields
    )
    need_system = any('DateTime' in cs(ft) for _, ft in fields)
    using = 'using System;\n\n' if need_system else ''
    return f'''\
{using}namespace {NS_ENT}
{{
    public partial class {entity}_{sec_name}Result
    {{
{props}
    }}
}}
'''


def gen_container(entity, sections):
    props = []
    for sec_name, _, single_row in sections:
        cls = f'{entity}_{sec_name}Result'
        if single_row:
            props.append(f'        public {cls}? {sec_name} {{ get; set; }}')
        else:
            props.append(f'        public List<{cls}>? {sec_name} {{ get; set; }}')
    props_str = '\n'.join(props)
    return f'''\
using System.Collections.Generic;

namespace {NS_ENT}
{{
    public class {entity}Result
    {{
{props_str}
    }}
}}
'''


def gen_iface_repo(entity, params):
    param_sig = ', '.join(f'{cs(t)} {n}' for n, t in params)
    return f'''\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace {NS_DAI}
{{
    public interface I{entity}Repository
    {{
        Task<Answer> Resumen({param_sig});
    }}
}}
'''


def gen_repo(entity, sp, params, sections):
    param_sig = ', '.join(f'{cs(t)} {n}' for n, t in params)

    # Build SqlParameter[] block
    if params:
        sp_lines = []
        for n, t in params:
            nullable = t.endswith('?') or t == 'string'
            val = f'(object){n} ?? DBNull.Value' if nullable else n
            sp_lines.append(
                f'                new SqlParameter {{ ParameterName = "@{n}", DbType = {dbt(t)}, Value = {val} }},'
            )
        params_block = (
            '                SqlParameter[] sqlParams =\n'
            '                {\n'
            + '\n'.join(sp_lines) + '\n'
            '                };\n'
            '                cmd.Parameters.AddRange(sqlParams);\n'
        )
    else:
        params_block = ''

    # Build result set reads
    rs_reads = []
    for i, (sec_name, fields, single_row) in enumerate(sections):
        dt_var = f'dt{i+1}'
        if i > 0:
            rs_reads.append(f'                reader.NextResult();')
        rs_reads.append(f'                var {dt_var} = new DataTable(); {dt_var}.Load(reader);')

    rs_reads_str = '\n'.join(rs_reads)

    # Build container assignment
    container_props = []
    for i, (sec_name, fields, single_row) in enumerate(sections):
        dt_var = f'dt{i+1}'
        cls = f'{entity}_{sec_name}Result'
        if single_row:
            container_props.append(
                f'                    {sec_name} = Mapear.Convert.ToList<{cls}>({dt_var}).FirstOrDefault(),'
            )
        else:
            container_props.append(
                f'                    {sec_name} = Mapear.Convert.ToList<{cls}>({dt_var}),'
            )
    container_str = '\n'.join(container_props)

    need_system = bool(params) or has_datetime([(s, f) for s, f, _ in sections])

    return f'''\
{'using System;' + chr(10) if need_system else ''}\
using Gestion.Colegial.DataAccess.Extensions;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace {NS_DAR}
{{
    public class {entity}Repository : RepositoryBase, I{entity}Repository
    {{
        public async Task<Answer> Resumen({param_sig})
        {{
            var answer = new Answer();
            try
            {{
                using var con = new SqlConnection(Connection.GetConnectionString());
                using var cmd = new SqlCommand("{sp}", con);
                cmd.CommandType = CommandType.StoredProcedure;
{params_block}\
                con.Open();
                using var reader = await cmd.ExecuteReaderAsync();
{rs_reads_str}
                answer.Data = new {entity}Result
                {{
{container_str}
                }};
                answer.Access = false;
            }}
            catch (Exception e)
            {{
                answer.Access = true;
                answer.Incidents(e);
            }}
            return answer;
        }}
    }}
}}
'''


def gen_iface_svc(entity, params):
    param_sig = ', '.join(f'{cs(t)} {n}' for n, t in params)
    return f'''\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace {NS_BI}
{{
    public interface I{entity}Service
    {{
        Task<Answer> Resumen({param_sig});
    }}
}}
'''


def gen_svc(entity, params):
    param_sig  = ', '.join(f'{cs(t)} {n}' for n, t in params)
    call_args  = ', '.join(n for n, _ in params)
    return f'''\
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace {NS_BS}
{{
    public class {entity}Service : I{entity}Service
    {{
        private readonly I{entity}Repository _repository;
        public {entity}Service(I{entity}Repository repository) {{ _repository = repository; }}

        public async Task<Answer> Resumen({param_sig})
        {{
            Answer answer = await _repository.Resumen({call_args});
            try
            {{
                if (answer.Access) {{ answer.Message = MessageShow.Error; Logs.Error(answer); }}
                return answer;
            }}
            catch (Exception e)
            {{
                answer.Access = true; answer.Message = MessageShow.Error;
                answer.Incidents(e); Logs.Error(answer);
                return answer;
            }}
        }}
    }}
}}
'''


def gen_ctrl(entity, params):
    param_sig  = ', '.join(f'{cs(t)} {n}' for n, t in params)
    call_args  = ', '.join(n for n, _ in params)
    return f'''\
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace {NS_CTRL}
{{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class {entity}Controller : ControllerBase
    {{
        private readonly I{entity}Service _service;
        public {entity}Controller(I{entity}Service service) {{ _service = service; }}

        [HttpGet("ResumenAsync")]
        public async Task<IActionResult> Resumen({param_sig})
        {{
            Answer answer = await _service.Resumen({call_args});
            return Ok(answer.Data);
        }}
    }}
}}
'''


def patch_program(entity):
    text = PROGRAM_CS.read_text(encoding='utf-8')
    repo_line = f'builder.Services.AddScoped<I{entity}Repository, {entity}Repository>();'
    svc_line  = f'builder.Services.AddScoped<I{entity}Service, {entity}Service>();'
    changed = False
    if repo_line not in text:
        text = text.replace('// Repositorios Fase 1', f'{repo_line}\n// Repositorios Fase 1')
        changed = True
    if svc_line not in text:
        text = text.replace('// Servicios Fase 1', f'{svc_line}\n// Servicios Fase 1')
        changed = True
    if changed:
        PROGRAM_CS.write_text(text, encoding='utf-8')
        print(f'  [PATCH] Program.cs  (+{entity})')
    else:
        print(f'  [SKIP]  Program.cs  ({entity} ya registrado)')


# ─── Main ────────────────────────────────────────────────────────

def main():
    for d in DASHBOARDS:
        entity   = d['entity']
        sp       = d['sp']
        params   = d['params']
        sections = d['sections']

        print()
        print('=' * 60)
        print(f'  {entity}')
        print('=' * 60)

        # 1) Section result classes
        for sec_name, fields, _ in sections:
            write(
                ENTITIES_DIR / f'{entity}_{sec_name}Result.cs',
                gen_section_result(entity, sec_name, fields),
            )

        # 2) Container class
        write(
            ENTITIES_DIR / f'{entity}Result.cs',
            gen_container(entity, sections),
        )

        # 3) DataAccess interface
        write(
            DA_IFACE_DIR / f'I{entity}Repository.cs',
            gen_iface_repo(entity, params),
        )

        # 4) DataAccess repository
        write(
            DA_REPO_DIR / f'{entity}Repository.cs',
            gen_repo(entity, sp, params, sections),
        )

        # 5) Business interface
        write(
            BIZ_IFACE_DIR / f'I{entity}Service.cs',
            gen_iface_svc(entity, params),
        )

        # 6) Business service
        write(
            BIZ_SVC_DIR / f'{entity}Service.cs',
            gen_svc(entity, params),
        )

        # 7) Controller
        write(
            CTRL_DIR / f'{entity}Controller.cs',
            gen_ctrl(entity, params),
        )

        # 8) Patch Program.cs
        patch_program(entity)

    print()
    print('=' * 60)
    print('  Listo. Endpoints generados:')
    for d in DASHBOARDS:
        p = ', '.join(f'{n}={{{n}}}' for n, _ in d['params'])
        qs = ('?' + p) if p else ''
        print(f"    GET api/v1/{d['entity']}/ResumenAsync{qs}")
    print('=' * 60)
    print()


if __name__ == '__main__':
    main()
