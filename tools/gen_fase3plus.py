#!/usr/bin/env python3
"""
gen_fase3plus.py
=================================================================
Genera todos los módulos pendientes de Fases 3-8 para
Gestion.Colegial.Api. Cubre tres patrones:

  read_list   — un endpoint que devuelve lista (SearchAll / Read)
  multi       — un endpoint combinado con reader.NextResult()
  custom      — módulos con múltiples endpoints propios

Uso:
    python tools/gen_fase3plus.py
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
    'int':'int','int?':'int?','decimal':'decimal','decimal?':'decimal?',
    'string':'string','bool':'bool','bool?':'bool?',
    'datetime':'DateTime','datetime?':'DateTime?',
    'date':'DateTime','date?':'DateTime?','char':'string','char?':'string',
}
DB = {
    'int':'DbType.Int32','int?':'DbType.Int32',
    'decimal':'DbType.Decimal','decimal?':'DbType.Decimal',
    'string':'DbType.String','bool':'DbType.Boolean','bool?':'DbType.Boolean',
    'datetime':'DbType.DateTime','datetime?':'DbType.DateTime',
    'date':'DbType.Date','date?':'DbType.Date','char':'DbType.String','char?':'DbType.String',
}

def cs(t):  return CS.get(t.lower(), 'string')
def dbt(t): return DB.get(t.lower(), 'DbType.String')
def needs_system(fields): return any('DateTime' in cs(ft) for _,ft in fields)

def write(path: Path, content: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        print(f'  [SKIP]  {path.relative_to(ROOT)}')
        return
    path.write_text(content, encoding='utf-8')
    print(f'  [NEW]   {path.relative_to(ROOT)}')

def patch_program(entity):
    text = PROGRAM_CS.read_text(encoding='utf-8')
    rl = f'builder.Services.AddScoped<I{entity}Repository, {entity}Repository>();'
    sl = f'builder.Services.AddScoped<I{entity}Service, {entity}Service>();'
    changed = False
    if rl not in text:
        text = text.replace('// Repositorios Fase 1', f'{rl}\n// Repositorios Fase 1')
        changed = True
    if sl not in text:
        text = text.replace('// Servicios Fase 1', f'{sl}\n// Servicios Fase 1')
        changed = True
    if changed:
        PROGRAM_CS.write_text(text, encoding='utf-8')
        print(f'  [PATCH] Program.cs (+{entity})')
    else:
        print(f'  [SKIP]  Program.cs ({entity} ya registrado)')

# ── helpers comunes ──────────────────────────────────────────────

def props(fields):
    return '\n'.join(f'        public {cs(ft)} {fn} {{ get; set; }}' for fn,ft in fields)

def sql_params_block(params, indent=16):
    sp = ' ' * indent
    lines = []
    for n,t in params:
        nullable = t.endswith('?') or t=='string'
        val = f'(object){n} ?? DBNull.Value' if nullable else n
        lines.append(f'{sp}new SqlParameter {{ ParameterName = "@{n}", DbType = {dbt(t)}, Value = {val} }},')
    return '\n'.join(lines)

def param_sig(params):
    return ', '.join(f'{cs(t)} {n}' for n,t in params)

def call_args(params):
    return ', '.join(n for n,_ in params)

# ================================================================
#  PATRÓN 1: READ_LIST
#  Un endpoint que devuelve una lista (SearchAll / Read<T>)
# ================================================================

READ_LIST_MODULES = [
    {
        'entity':  'EmpleadosAntiguedad',
        'sp':      'PR_Empleados_Antiguedad',
        'schema':  'app',
        'method':  'List',
        'params':  [],
        'fields':  [
            ('Emp_Id','int'),('Emp_Codigo','string'),('NombreCompleto','string'),
            ('FechaIngreso','datetime'),('Anos','int'),('Meses','int'),('Per_Imagen','string'),
        ],
        'single':  False,
    },
    {
        'entity':  'AlumnosEnRiesgo',
        'sp':      'PR_Academico_AlumnosEnRiesgo',
        'schema':  'app',
        'method':  'List',
        'params':  [('PromedioMinimo','decimal?'),('Anio','int?')],
        'fields':  [
            ('Alu_Id','int'),('NombreAlumno','string'),('Per_Telefono','string'),
            ('Per_Imagen','string'),('Cur_Nombre','string'),('Sec_Descripcion','string'),
            ('PromedioAnual','decimal?'),('DeudaPendiente','decimal'),
        ],
        'single':  False,
    },
    {
        'entity':  'AgingCuentas',
        'sp':      'PR_Finanza_AgingCuentas',
        'schema':  'finanza',
        'method':  'List',
        'params':  [('FechaCorte','date?')],
        'fields':  [
            ('NombreAlumno','string'),('Alu_Id','int'),
            ('Rango_1_30','decimal'),('Rango_31_60','decimal'),
            ('Rango_61_90','decimal'),('Rango_Mas90','decimal'),('TotalDeuda','decimal'),
        ],
        'single':  False,
    },
    {
        'entity':  'TopDeudores',
        'sp':      'PR_Finanza_TopDeudores',
        'schema':  'finanza',
        'method':  'List',
        'params':  [('Top','int?'),('Anio','int?')],
        'fields':  [
            ('Alu_Id','int'),('NombreAlumno','string'),('Per_Telefono','string'),
            ('Cur_Nombre','string'),('TotalDeuda','decimal'),
            ('CuotasPendientes','int'),('UltimoVencimiento','datetime?'),
        ],
        'single':  False,
    },
    {
        'entity':  'MorosidadPorNivel',
        'sp':      'PR_Finanza_Morosidad_PorNivel',
        'schema':  'finanza',
        'method':  'List',
        'params':  [('Anio','int?')],
        'fields':  [
            ('Cur_Nombre','string'),('TotalAlumnos','int'),('AlumnosMorosos','int'),
            ('MontoMoroso','decimal'),('PorcentajeMorosidad','decimal'),
        ],
        'single':  False,
    },
    {
        'entity':  'EstadoCuenta',
        'sp':      'PR_Finanza_EstadoCuenta',
        'schema':  'finanza',
        'method':  'Find',
        'params':  [('Alu_Id','int'),('Anio','int?')],
        'fields':  [
            ('Cco_Id','int'),('Cco_Mes','int'),('Cco_Anio','int'),('Cpa_Descripcion','string'),
            ('Cco_MontoOriginal','decimal'),('Cco_MontoDescuento','decimal'),
            ('Cco_MontoMora','decimal'),('Cco_MontoTotal','decimal'),('Cco_MontoPendiente','decimal'),
            ('Cco_FechaEmision','datetime'),('Cco_FechaVencimiento','datetime'),
            ('Estado','string'),('MontoPagado','decimal'),
        ],
        'single':  False,
    },
    {
        'entity':  'AlumnosBusqueda',
        'sp':      'PR_Alumnos_BusquedaGlobal',
        'schema':  'app',
        'method':  'Search',
        'params':  [('Termino','string')],
        'fields':  [
            ('Alu_Id','int'),('NombreCompleto','string'),('Per_Identidad','string'),
            ('Per_Telefono','string'),('Per_Imagen','string'),
            ('Cur_Nombre','string'),('Sec_Descripcion','string'),('AnioCursado','int'),
        ],
        'single':  False,
    },
]

def gen_read_list(m):
    entity = m['entity']; sp = m['sp']; fields = m['fields']
    params = m['params']; method = m['method']; single = m['single']
    cls = f'{entity}Result'

    # ── Entity ──────────────────────────────────────────────────
    sys_u = 'using System;\n\n' if needs_system(fields) else ''
    entity_code = f'''\
{sys_u}namespace {NS_ENT}
{{
    public partial class {cls}
    {{
{props(fields)}
    }}
}}
'''

    # ── Repo Interface ───────────────────────────────────────────
    ps = param_sig(params)
    iface_repo = f'''\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace {NS_DAI}
{{
    public interface I{entity}Repository
    {{
        Task<Answer> {method}({ps});
    }}
}}
'''

    # ── Repo Impl ────────────────────────────────────────────────
    sys_u2 = 'using System;\n' if params else ''
    if params:
        p_block = f'''\
            SqlParameter[] parameters =
            {{
{sql_params_block(params)}
            }};
'''
        call = f'SearchAll<{cls}>(sql, parameters)' if not single else f'Search<{cls}>(sql, parameters)'
    else:
        p_block = ''
        call = f'Read<{cls}>(sql)'

    repo_code = f'''\
{sys_u2}\
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace {NS_DAR}
{{
    public class {entity}Repository : RepositoryBase, I{entity}Repository
    {{
        public async Task<Answer> {method}({ps})
        {{
            const string sql = "{sp}";
{p_block}\
            return await {call};
        }}
    }}
}}
'''

    # ── Service Interface ────────────────────────────────────────
    iface_svc = f'''\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace {NS_BI}
{{
    public interface I{entity}Service
    {{
        Task<Answer> {method}({ps});
    }}
}}
'''

    # ── Service Impl ─────────────────────────────────────────────
    ca = call_args(params)
    svc_code = f'''\
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

        public async Task<Answer> {method}({ps})
        {{
            Answer answer = await _repository.{method}({ca});
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

    # ── Controller ───────────────────────────────────────────────
    ctrl_code = f'''\
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

        [HttpGet("{method}Async")]
        public async Task<IActionResult> {method}({ps})
        {{
            Answer answer = await _service.{method}({ca});
            return Ok(answer.Data);
        }}
    }}
}}
'''

    return entity_code, iface_repo, repo_code, iface_svc, svc_code, ctrl_code


# ================================================================
#  PATRÓN 2: MULTI-RESULT (reader.NextResult)
#  Igual que dashboards: un endpoint, un objeto contenedor
# ================================================================

MULTI_MODULES = [
    {
        'entity': 'Ficha360Alumno',
        'sp':     'PR_Alumnos_Ficha360',
        'schema': 'app',
        'params': [('Alu_Id','int')],
        'sections': [
            ('DatosPersonales', [
                ('Alu_Id','int'),('AnioCursado','int'),('PromedioAnual','decimal?'),
                ('Per_PrimerNombre','string'),('Per_SegundoNombre','string'),
                ('Per_ApellidoPaterno','string'),('Per_ApellidoMaterno','string'),
                ('Per_Identidad','string'),('Per_FechaNacimiento','datetime?'),
                ('Per_Sexo','string'),('Per_Telefono','string'),
                ('Per_CorreoElectronico','string'),('Per_Direccion','string'),('Per_Imagen','string'),
                ('Cur_Nombre','string'),('Cun_Descripcion','string'),('Sec_Descripcion','string'),
            ], True),
            ('CuentasPorCobrar', [
                ('Cco_Id','int'),('Cco_Mes','int'),('Cco_Anio','int'),
                ('Cco_MontoTotal','decimal'),('Cco_MontoPendiente','decimal'),
                ('Cco_FechaVencimiento','datetime'),('Epa_Descripcion','string'),('Cpa_Descripcion','string'),
            ], False),
            ('AsistenciaReciente', [
                ('Asi_Fecha','datetime'),('Asi_Estado','string'),('Mat_Nombre','string'),
            ], False),
        ],
    },
    {
        'entity': 'Ficha360Empleado',
        'sp':     'PR_Empleados_Ficha360',
        'schema': 'app',
        'params': [('Emp_Id','int')],
        'sections': [
            ('DatosPersonales', [
                ('Emp_Id','int'),('Emp_Codigo','string'),
                ('Per_PrimerNombre','string'),('Per_SegundoNombre','string'),
                ('Per_ApellidoPaterno','string'),('Per_ApellidoMaterno','string'),
                ('Per_Identidad','string'),('Per_FechaNacimiento','datetime?'),
                ('Per_Sexo','string'),('Per_Telefono','string'),
                ('Per_CorreoElectronico','string'),('Per_Direccion','string'),('Per_Imagen','string'),
                ('FechaContratacion','datetime?'),
            ], True),
            ('ClasesAsignadas', [
                ('Hor_Id','int'),('Mat_Nombre','string'),('Sec_Descripcion','string'),
                ('Cur_Nombre','string'),('Hor_Año','int'),('Dia_Descripcion','string'),
                ('HoraInicio','string'),('HoraFin','string'),
            ], False),
            ('HistorialVacaciones', [
                ('Vac_Tipo','string'),('Vac_FechaInicio','datetime'),('Vac_FechaFin','datetime'),
                ('Vac_DiasTotal','int'),('Vac_Estado','string'),('Vac_Motivo','string'),
            ], False),
        ],
    },
]

def gen_multi(m):
    from gen_dashboards import (
        gen_section_result, gen_container,
        gen_iface_repo, gen_repo,
        gen_iface_svc, gen_svc, gen_ctrl,
    )
    entity   = m['entity']
    sp       = m['sp']
    params   = m['params']
    sections = m['sections']
    files = {}

    # section result classes
    for sec_name, fields, _ in sections:
        k = ENTITIES_DIR / f'{entity}_{sec_name}Result.cs'
        files[k] = gen_section_result(entity, sec_name, fields)

    # container
    files[ENTITIES_DIR / f'{entity}Result.cs']      = gen_container(entity, sections)
    files[DA_IFACE_DIR / f'I{entity}Repository.cs'] = gen_iface_repo(entity, params)
    files[DA_REPO_DIR  / f'{entity}Repository.cs']  = gen_repo(entity, sp, params, sections)
    files[BIZ_IFACE_DIR/ f'I{entity}Service.cs']    = gen_iface_svc(entity, params)
    files[BIZ_SVC_DIR  / f'{entity}Service.cs']     = gen_svc(entity, params)
    files[CTRL_DIR     / f'{entity}Controller.cs']  = gen_ctrl(entity, sections, params)
    return files


# ================================================================
#  PATRÓN 3: CUSTOM — módulos con múltiples endpoints propios
# ================================================================

def gen_asistencia():
    entity = 'Asistencia'
    files = {}

    # ── Result classes ───────────────────────────────────────────
    files[ENTITIES_DIR / 'PR_tbAsistencia_ListResult.cs'] = f'''\
using System;

namespace {NS_ENT}
{{
    public partial class PR_tbAsistencia_ListResult
    {{
        public int Asi_Id {{ get; set; }}
        public int Alu_Id {{ get; set; }}
        public string Asi_Estado {{ get; set; }}
        public string Asi_Observacion {{ get; set; }}
        public DateTime Asi_Fecha {{ get; set; }}
        public string NombreAlumno {{ get; set; }}
        public string Per_Imagen {{ get; set; }}
    }}
}}
'''
    files[ENTITIES_DIR / 'PR_tbAsistencia_ByAlumnoResult.cs'] = f'''\
using System;

namespace {NS_ENT}
{{
    public partial class PR_tbAsistencia_ByAlumnoResult
    {{
        public int Asi_Id {{ get; set; }}
        public DateTime Asi_Fecha {{ get; set; }}
        public string Asi_Estado {{ get; set; }}
        public string Asi_Observacion {{ get; set; }}
        public string Mat_Nombre {{ get; set; }}
        public string Dia_Descripcion {{ get; set; }}
        public string HoraInicio {{ get; set; }}
    }}
}}
'''

    # ── DataAccess Interface ─────────────────────────────────────
    files[DA_IFACE_DIR / f'I{entity}Repository.cs'] = f'''\
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace {NS_DAI}
{{
    public interface I{entity}Repository
    {{
        Task<Answer> List(int Hor_Id, DateTime Fecha);
        Task<Answer> ByAlumno(int Alu_Id, int? Anio);
        Task<Answer> Insert(int Hor_Id, int Alu_Id, DateTime Asi_Fecha, string Asi_Estado, string Asi_Observacion, int usuarioRegistra);
        Task<Answer> Update(int Asi_Id, string Asi_Estado, string Asi_Observacion, int usuarioModifica);
    }}
}}
'''

    # ── DataAccess Repository ────────────────────────────────────
    files[DA_REPO_DIR / f'{entity}Repository.cs'] = f'''\
using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace {NS_DAR}
{{
    public class {entity}Repository : RepositoryBase, I{entity}Repository
    {{
        public async Task<Answer> List(int Hor_Id, DateTime Fecha)
        {{
            const string sql = "PR_tbAsistencia_List";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Hor_Id", DbType = DbType.Int32,   Value = Hor_Id }},
                new SqlParameter {{ ParameterName = "@Fecha",  DbType = DbType.Date,    Value = Fecha }},
            }};
            return await SearchAll<PR_tbAsistencia_ListResult>(sql, parameters);
        }}

        public async Task<Answer> ByAlumno(int Alu_Id, int? Anio)
        {{
            const string sql = "PR_tbAsistencia_ByAlumno";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Alu_Id", DbType = DbType.Int32,   Value = Alu_Id }},
                new SqlParameter {{ ParameterName = "@Anio",   DbType = DbType.Int32,   Value = (object)Anio ?? DBNull.Value }},
            }};
            return await SearchAll<PR_tbAsistencia_ByAlumnoResult>(sql, parameters);
        }}

        public async Task<Answer> Insert(int Hor_Id, int Alu_Id, DateTime Asi_Fecha, string Asi_Estado, string Asi_Observacion, int usuarioRegistra)
        {{
            const string sql = "PR_tbAsistencia_Insert";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Hor_Id",              DbType = DbType.Int32,   Value = Hor_Id }},
                new SqlParameter {{ ParameterName = "@Alu_Id",              DbType = DbType.Int32,   Value = Alu_Id }},
                new SqlParameter {{ ParameterName = "@Asi_Fecha",           DbType = DbType.Date,    Value = Asi_Fecha }},
                new SqlParameter {{ ParameterName = "@Asi_Estado",          DbType = DbType.String,  Value = Asi_Estado }},
                new SqlParameter {{ ParameterName = "@Asi_Observacion",     DbType = DbType.String,  Value = (object)Asi_Observacion ?? DBNull.Value }},
                new SqlParameter {{ ParameterName = "@Asi_UsuarioRegistra", DbType = DbType.Int32,   Value = usuarioRegistra }},
            }};
            return await New(sql, parameters);
        }}

        public async Task<Answer> Update(int Asi_Id, string Asi_Estado, string Asi_Observacion, int usuarioModifica)
        {{
            const string sql = "PR_tbAsistencia_Update";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Asi_Id",              DbType = DbType.Int32,   Value = Asi_Id }},
                new SqlParameter {{ ParameterName = "@Asi_Estado",          DbType = DbType.String,  Value = Asi_Estado }},
                new SqlParameter {{ ParameterName = "@Asi_Observacion",     DbType = DbType.String,  Value = (object)Asi_Observacion ?? DBNull.Value }},
                new SqlParameter {{ ParameterName = "@Asi_UsuarioModifica", DbType = DbType.Int32,   Value = usuarioModifica }},
            }};
            return await Update(sql, parameters);
        }}
    }}
}}
'''

    # ── Business Interface ────────────────────────────────────────
    files[BIZ_IFACE_DIR / f'I{entity}Service.cs'] = f'''\
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace {NS_BI}
{{
    public interface I{entity}Service
    {{
        Task<Answer> List(int Hor_Id, DateTime Fecha);
        Task<Answer> ByAlumno(int Alu_Id, int? Anio);
        Task<Answer> Insert(int Hor_Id, int Alu_Id, DateTime Asi_Fecha, string Asi_Estado, string Asi_Observacion, int usuarioRegistra);
        Task<Answer> Update(int Asi_Id, string Asi_Estado, string Asi_Observacion, int usuarioModifica);
    }}
}}
'''

    # ── Business Service ─────────────────────────────────────────
    files[BIZ_SVC_DIR / f'{entity}Service.cs'] = f'''\
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
        private readonly I{entity}Repository _r;
        public {entity}Service(I{entity}Repository r) {{ _r = r; }}

        private async Task<Answer> Wrap(Task<Answer> task, string successMsg = null)
        {{
            Answer answer = await task;
            try
            {{
                if (answer.Access) {{ answer.Message = MessageShow.Error; Logs.Error(answer); }}
                else if (successMsg != null) answer.Message = successMsg;
                return answer;
            }}
            catch (Exception e)
            {{
                answer.Access = true; answer.Message = MessageShow.Error;
                answer.Incidents(e); Logs.Error(answer); return answer;
            }}
        }}

        public Task<Answer> List(int Hor_Id, DateTime Fecha)
            => Wrap(_r.List(Hor_Id, Fecha));

        public Task<Answer> ByAlumno(int Alu_Id, int? Anio)
            => Wrap(_r.ByAlumno(Alu_Id, Anio));

        public Task<Answer> Insert(int Hor_Id, int Alu_Id, DateTime Asi_Fecha, string Asi_Estado, string Asi_Observacion, int usuarioRegistra)
            => Wrap(_r.Insert(Hor_Id, Alu_Id, Asi_Fecha, Asi_Estado, Asi_Observacion, usuarioRegistra), MessageShow.SuccessSave);

        public Task<Answer> Update(int Asi_Id, string Asi_Estado, string Asi_Observacion, int usuarioModifica)
            => Wrap(_r.Update(Asi_Id, Asi_Estado, Asi_Observacion, usuarioModifica), MessageShow.SuccessEdit);
    }}
}}
'''

    # ── Controller ───────────────────────────────────────────────
    files[CTRL_DIR / f'{entity}Controller.cs'] = f'''\
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace {NS_CTRL}
{{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class {entity}Controller : ControllerBase
    {{
        private readonly I{entity}Service _service;
        public {entity}Controller(I{entity}Service service) {{ _service = service; }}

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Hor_Id, DateTime Fecha)
        {{
            Answer answer = await _service.List(Hor_Id, Fecha);
            return Ok(answer.Data);
        }}

        [HttpGet("ByAlumnoAsync")]
        public async Task<IActionResult> ByAlumno(int Alu_Id, int? Anio)
        {{
            Answer answer = await _service.ByAlumno(Alu_Id, Anio);
            return Ok(answer.Data);
        }}

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] AsistenciaRequest request)
        {{
            Answer answer = await _service.Insert(request.Hor_Id, request.Alu_Id, request.Asi_Fecha, request.Asi_Estado, request.Asi_Observacion, request.UsuarioRegistra);
            return Ok(answer);
        }}

        [HttpPut("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] AsistenciaEditRequest request)
        {{
            Answer answer = await _service.Update(request.Asi_Id, request.Asi_Estado, request.Asi_Observacion, request.UsuarioModifica);
            return Ok(answer);
        }}
    }}

    public class AsistenciaRequest
    {{
        public int Hor_Id {{ get; set; }}
        public int Alu_Id {{ get; set; }}
        public DateTime Asi_Fecha {{ get; set; }}
        public string Asi_Estado {{ get; set; }}
        public string Asi_Observacion {{ get; set; }}
        public int UsuarioRegistra {{ get; set; }}
    }}

    public class AsistenciaEditRequest
    {{
        public int Asi_Id {{ get; set; }}
        public string Asi_Estado {{ get; set; }}
        public string Asi_Observacion {{ get; set; }}
        public int UsuarioModifica {{ get; set; }}
    }}
}}
'''
    return entity, files


def gen_documentos_alumno():
    entity = 'DocumentosAlumno'
    files = {}

    files[ENTITIES_DIR / 'PR_tbDocumentosAlumno_ListResult.cs'] = f'''\
using System;

namespace {NS_ENT}
{{
    public partial class PR_tbDocumentosAlumno_ListResult
    {{
        public int? Doa_Id {{ get; set; }}
        public bool? Doa_EsEntregado {{ get; set; }}
        public DateTime? Doa_FechaEntrega {{ get; set; }}
        public string Doa_Observacion {{ get; set; }}
        public int TDoc_Id {{ get; set; }}
        public string TDoc_Descripcion {{ get; set; }}
        public bool TDoc_EsObligatorio {{ get; set; }}
    }}
}}
'''
    files[ENTITIES_DIR / 'PR_tbDocumentosAlumno_PendientesListResult.cs'] = f'''\

namespace {NS_ENT}
{{
    public partial class PR_tbDocumentosAlumno_PendientesListResult
    {{
        public int Alu_Id {{ get; set; }}
        public string NombreAlumno {{ get; set; }}
        public string Cur_Nombre {{ get; set; }}
        public int DocumentosPendientes {{ get; set; }}
    }}
}}
'''

    files[DA_IFACE_DIR / f'I{entity}Repository.cs'] = f'''\
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace {NS_DAI}
{{
    public interface I{entity}Repository
    {{
        Task<Answer> List(int Alu_Id);
        Task<Answer> PendientesList();
        Task<Answer> Update(int Alu_Id, int TDoc_Id, bool Doa_EsEntregado, DateTime? Doa_FechaEntrega, string Doa_Observacion, int usuarioRegistra);
    }}
}}
'''

    files[DA_REPO_DIR / f'{entity}Repository.cs'] = f'''\
using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace {NS_DAR}
{{
    public class {entity}Repository : RepositoryBase, I{entity}Repository
    {{
        public async Task<Answer> List(int Alu_Id)
        {{
            const string sql = "PR_tbDocumentosAlumno_List";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Alu_Id", DbType = DbType.Int32, Value = Alu_Id }},
            }};
            return await SearchAll<PR_tbDocumentosAlumno_ListResult>(sql, parameters);
        }}

        public async Task<Answer> PendientesList()
        {{
            const string sql = "PR_tbDocumentosAlumno_PendientesList";
            return await Read<PR_tbDocumentosAlumno_PendientesListResult>(sql);
        }}

        public async Task<Answer> Update(int Alu_Id, int TDoc_Id, bool Doa_EsEntregado, DateTime? Doa_FechaEntrega, string Doa_Observacion, int usuarioRegistra)
        {{
            const string sql = "PR_tbDocumentosAlumno_Update";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Alu_Id",              DbType = DbType.Int32,   Value = Alu_Id }},
                new SqlParameter {{ ParameterName = "@TDoc_Id",             DbType = DbType.Int32,   Value = TDoc_Id }},
                new SqlParameter {{ ParameterName = "@Doa_EsEntregado",     DbType = DbType.Boolean, Value = Doa_EsEntregado }},
                new SqlParameter {{ ParameterName = "@Doa_FechaEntrega",    DbType = DbType.Date,    Value = (object)Doa_FechaEntrega ?? DBNull.Value }},
                new SqlParameter {{ ParameterName = "@Doa_Observacion",     DbType = DbType.String,  Value = (object)Doa_Observacion ?? DBNull.Value }},
                new SqlParameter {{ ParameterName = "@Doa_UsuarioRegistra", DbType = DbType.Int32,   Value = usuarioRegistra }},
            }};
            return await Update(sql, parameters);
        }}
    }}
}}
'''

    files[BIZ_IFACE_DIR / f'I{entity}Service.cs'] = f'''\
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace {NS_BI}
{{
    public interface I{entity}Service
    {{
        Task<Answer> List(int Alu_Id);
        Task<Answer> PendientesList();
        Task<Answer> Update(int Alu_Id, int TDoc_Id, bool Doa_EsEntregado, DateTime? Doa_FechaEntrega, string Doa_Observacion, int usuarioRegistra);
    }}
}}
'''

    files[BIZ_SVC_DIR / f'{entity}Service.cs'] = f'''\
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
        private readonly I{entity}Repository _r;
        public {entity}Service(I{entity}Repository r) {{ _r = r; }}

        public async Task<Answer> List(int Alu_Id)
        {{
            Answer answer = await _r.List(Alu_Id);
            try {{ if (answer.Access) {{ answer.Message = MessageShow.Error; Logs.Error(answer); }} return answer; }}
            catch (Exception e) {{ answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }}
        }}

        public async Task<Answer> PendientesList()
        {{
            Answer answer = await _r.PendientesList();
            try {{ if (answer.Access) {{ answer.Message = MessageShow.Error; Logs.Error(answer); }} return answer; }}
            catch (Exception e) {{ answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }}
        }}

        public async Task<Answer> Update(int Alu_Id, int TDoc_Id, bool Doa_EsEntregado, DateTime? Doa_FechaEntrega, string Doa_Observacion, int usuarioRegistra)
        {{
            Answer answer = await _r.Update(Alu_Id, TDoc_Id, Doa_EsEntregado, Doa_FechaEntrega, Doa_Observacion, usuarioRegistra);
            try {{ if (answer.Access) {{ answer.Message = MessageShow.Error; Logs.Error(answer); }} else answer.Message = MessageShow.SuccessEdit; return answer; }}
            catch (Exception e) {{ answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }}
        }}
    }}
}}
'''

    files[CTRL_DIR / f'{entity}Controller.cs'] = f'''\
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace {NS_CTRL}
{{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class {entity}Controller : ControllerBase
    {{
        private readonly I{entity}Service _service;
        public {entity}Controller(I{entity}Service service) {{ _service = service; }}

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Alu_Id)
        {{
            Answer answer = await _service.List(Alu_Id);
            return Ok(answer.Data);
        }}

        [HttpGet("PendientesAsync")]
        public async Task<IActionResult> PendientesList()
        {{
            Answer answer = await _service.PendientesList();
            return Ok(answer.Data);
        }}

        [HttpPut("UpdateAsync")]
        public async Task<IActionResult> Update([FromBody] DocumentosAlumnoRequest request)
        {{
            Answer answer = await _service.Update(request.Alu_Id, request.TDoc_Id, request.Doa_EsEntregado, request.Doa_FechaEntrega, request.Doa_Observacion, request.UsuarioRegistra);
            return Ok(answer);
        }}
    }}

    public class DocumentosAlumnoRequest
    {{
        public int Alu_Id {{ get; set; }}
        public int TDoc_Id {{ get; set; }}
        public bool Doa_EsEntregado {{ get; set; }}
        public DateTime? Doa_FechaEntrega {{ get; set; }}
        public string Doa_Observacion {{ get; set; }}
        public int UsuarioRegistra {{ get; set; }}
    }}
}}
'''
    return entity, files


def gen_vacaciones():
    entity = 'Vacaciones'
    files = {}

    files[ENTITIES_DIR / 'PR_tbVacaciones_ListResult.cs'] = f'''\
using System;

namespace {NS_ENT}
{{
    public partial class PR_tbVacaciones_ListResult
    {{
        public int Vac_Id {{ get; set; }}
        public string Vac_Tipo {{ get; set; }}
        public DateTime Vac_FechaInicio {{ get; set; }}
        public DateTime Vac_FechaFin {{ get; set; }}
        public int Vac_DiasTotal {{ get; set; }}
        public string Vac_Estado {{ get; set; }}
        public string Vac_Motivo {{ get; set; }}
        public DateTime Vac_FechaRegistra {{ get; set; }}
        public string NombreEmpleado {{ get; set; }}
        public string Emp_Codigo {{ get; set; }}
    }}
}}
'''

    files[DA_IFACE_DIR / f'I{entity}Repository.cs'] = f'''\
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace {NS_DAI}
{{
    public interface I{entity}Repository
    {{
        Task<Answer> List(int? Emp_Id);
        Task<Answer> Insert(int Emp_Id, string Vac_Tipo, DateTime Vac_FechaInicio, DateTime Vac_FechaFin, string Vac_Motivo, int usuarioRegistra);
        Task<Answer> Approve(int Vac_Id, string Vac_Estado, int usuarioModifica);
        Task<Answer> Delete(int Vac_Id, int usuarioModifica);
    }}
}}
'''

    files[DA_REPO_DIR / f'{entity}Repository.cs'] = f'''\
using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace {NS_DAR}
{{
    public class {entity}Repository : RepositoryBase, I{entity}Repository
    {{
        public async Task<Answer> List(int? Emp_Id)
        {{
            const string sql = "PR_tbVacaciones_List";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Emp_Id", DbType = DbType.Int32, Value = (object)Emp_Id ?? DBNull.Value }},
            }};
            return await SearchAll<PR_tbVacaciones_ListResult>(sql, parameters);
        }}

        public async Task<Answer> Insert(int Emp_Id, string Vac_Tipo, DateTime Vac_FechaInicio, DateTime Vac_FechaFin, string Vac_Motivo, int usuarioRegistra)
        {{
            const string sql = "PR_tbVacaciones_Insert";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Emp_Id",              DbType = DbType.Int32,   Value = Emp_Id }},
                new SqlParameter {{ ParameterName = "@Vac_Tipo",            DbType = DbType.String,  Value = Vac_Tipo }},
                new SqlParameter {{ ParameterName = "@Vac_FechaInicio",     DbType = DbType.Date,    Value = Vac_FechaInicio }},
                new SqlParameter {{ ParameterName = "@Vac_FechaFin",        DbType = DbType.Date,    Value = Vac_FechaFin }},
                new SqlParameter {{ ParameterName = "@Vac_Motivo",          DbType = DbType.String,  Value = (object)Vac_Motivo ?? DBNull.Value }},
                new SqlParameter {{ ParameterName = "@Vac_UsuarioRegistra", DbType = DbType.Int32,   Value = usuarioRegistra }},
            }};
            return await New(sql, parameters);
        }}

        public async Task<Answer> Approve(int Vac_Id, string Vac_Estado, int usuarioModifica)
        {{
            const string sql = "PR_tbVacaciones_Update";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Vac_Id",              DbType = DbType.Int32,  Value = Vac_Id }},
                new SqlParameter {{ ParameterName = "@Vac_Estado",          DbType = DbType.String, Value = Vac_Estado }},
                new SqlParameter {{ ParameterName = "@Vac_UsuarioModifica", DbType = DbType.Int32,  Value = usuarioModifica }},
            }};
            return await Update(sql, parameters);
        }}

        public async Task<Answer> Delete(int Vac_Id, int usuarioModifica)
        {{
            const string sql = "PR_tbVacaciones_Delete";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Vac_Id",              DbType = DbType.Int32, Value = Vac_Id }},
                new SqlParameter {{ ParameterName = "@Vac_UsuarioModifica", DbType = DbType.Int32, Value = usuarioModifica }},
            }};
            return await Delete(sql, parameters);
        }}
    }}
}}
'''

    files[BIZ_IFACE_DIR / f'I{entity}Service.cs'] = f'''\
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace {NS_BI}
{{
    public interface I{entity}Service
    {{
        Task<Answer> List(int? Emp_Id);
        Task<Answer> Insert(int Emp_Id, string Vac_Tipo, DateTime Vac_FechaInicio, DateTime Vac_FechaFin, string Vac_Motivo, int usuarioRegistra);
        Task<Answer> Approve(int Vac_Id, string Vac_Estado, int usuarioModifica);
        Task<Answer> Delete(int Vac_Id, int usuarioModifica);
    }}
}}
'''

    files[BIZ_SVC_DIR / f'{entity}Service.cs'] = f'''\
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
        private readonly I{entity}Repository _r;
        public {entity}Service(I{entity}Repository r) {{ _r = r; }}

        private async Task<Answer> Wrap(Task<Answer> t, string msg = null)
        {{
            Answer a = await t;
            try {{ if (a.Access) {{ a.Message = MessageShow.Error; Logs.Error(a); }} else if (msg != null) a.Message = msg; return a; }}
            catch (Exception e) {{ a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }}
        }}

        public Task<Answer> List(int? Emp_Id) => Wrap(_r.List(Emp_Id));
        public Task<Answer> Insert(int Emp_Id, string Vac_Tipo, DateTime Vac_FechaInicio, DateTime Vac_FechaFin, string Vac_Motivo, int usuarioRegistra)
            => Wrap(_r.Insert(Emp_Id, Vac_Tipo, Vac_FechaInicio, Vac_FechaFin, Vac_Motivo, usuarioRegistra), MessageShow.SuccessSave);
        public Task<Answer> Approve(int Vac_Id, string Vac_Estado, int usuarioModifica)
            => Wrap(_r.Approve(Vac_Id, Vac_Estado, usuarioModifica), MessageShow.SuccessEdit);
        public Task<Answer> Delete(int Vac_Id, int usuarioModifica)
            => Wrap(_r.Delete(Vac_Id, usuarioModifica), MessageShow.SuccessDelete);
    }}
}}
'''

    files[CTRL_DIR / f'{entity}Controller.cs'] = f'''\
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace {NS_CTRL}
{{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class {entity}Controller : ControllerBase
    {{
        private readonly I{entity}Service _service;
        public {entity}Controller(I{entity}Service service) {{ _service = service; }}

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Emp_Id)
        {{
            Answer answer = await _service.List(Emp_Id);
            return Ok(answer.Data);
        }}

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] VacacionesRequest request)
        {{
            Answer answer = await _service.Insert(request.Emp_Id, request.Vac_Tipo, request.Vac_FechaInicio, request.Vac_FechaFin, request.Vac_Motivo, request.UsuarioRegistra);
            return Ok(answer);
        }}

        [HttpPut("ApproveAsync")]
        public async Task<IActionResult> Approve([FromBody] VacacionesApproveRequest request)
        {{
            Answer answer = await _service.Approve(request.Vac_Id, request.Vac_Estado, request.UsuarioModifica);
            return Ok(answer);
        }}

        [HttpPut("RemoveAsync")]
        public async Task<IActionResult> Remove(int Vac_Id, int usuarioModifica)
        {{
            Answer answer = await _service.Delete(Vac_Id, usuarioModifica);
            return Ok(answer);
        }}
    }}

    public class VacacionesRequest
    {{
        public int Emp_Id {{ get; set; }}
        public string Vac_Tipo {{ get; set; }}
        public DateTime Vac_FechaInicio {{ get; set; }}
        public DateTime Vac_FechaFin {{ get; set; }}
        public string Vac_Motivo {{ get; set; }}
        public int UsuarioRegistra {{ get; set; }}
    }}

    public class VacacionesApproveRequest
    {{
        public int Vac_Id {{ get; set; }}
        public string Vac_Estado {{ get; set; }}
        public int UsuarioModifica {{ get; set; }}
    }}
}}
'''
    return entity, files


def gen_arqueos_caja():
    entity = 'ArqueosCaja'
    files = {}

    files[ENTITIES_DIR / 'PR_tbArqueosCaja_FindResult.cs'] = f'''\
using System;

namespace {NS_ENT}
{{
    public partial class PR_tbArqueosCaja_FindResult
    {{
        public int Arq_Id {{ get; set; }}
        public DateTime Arq_Fecha {{ get; set; }}
        public decimal Arq_TotalEfectivo {{ get; set; }}
        public decimal Arq_TotalTransferencia {{ get; set; }}
        public decimal Arq_TotalTarjeta {{ get; set; }}
        public decimal Arq_TotalGeneral {{ get; set; }}
        public string Arq_Observaciones {{ get; set; }}
        public DateTime Arq_FechaRegistra {{ get; set; }}
        public string Usu_Name {{ get; set; }}
    }}
}}
'''
    files[ENTITIES_DIR / 'PR_tbArqueosCaja_LastResult.cs'] = f'''\
using System;

namespace {NS_ENT}
{{
    public partial class PR_tbArqueosCaja_LastResult
    {{
        public int Arq_Id {{ get; set; }}
        public DateTime Arq_Fecha {{ get; set; }}
        public decimal Arq_TotalEfectivo {{ get; set; }}
        public decimal Arq_TotalTransferencia {{ get; set; }}
        public decimal Arq_TotalTarjeta {{ get; set; }}
        public decimal Arq_TotalGeneral {{ get; set; }}
        public string Arq_Observaciones {{ get; set; }}
    }}
}}
'''

    files[DA_IFACE_DIR / f'I{entity}Repository.cs'] = f'''\
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace {NS_DAI}
{{
    public interface I{entity}Repository
    {{
        Task<Answer> Find(int Arq_Id);
        Task<Answer> LastByUsuario(int Usu_Id);
        Task<Answer> Insert(int Usu_Id, DateTime Arq_Fecha, decimal Arq_TotalEfectivo, decimal Arq_TotalTransferencia, decimal Arq_TotalTarjeta, string Arq_Observaciones, int usuarioRegistra);
    }}
}}
'''

    files[DA_REPO_DIR / f'{entity}Repository.cs'] = f'''\
using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace {NS_DAR}
{{
    public class {entity}Repository : RepositoryBase, I{entity}Repository
    {{
        public async Task<Answer> Find(int Arq_Id)
        {{
            const string sql = "PR_tbArqueosCaja_Find";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Arq_Id", DbType = DbType.Int32, Value = Arq_Id }},
            }};
            return await Search<PR_tbArqueosCaja_FindResult>(sql, parameters);
        }}

        public async Task<Answer> LastByUsuario(int Usu_Id)
        {{
            const string sql = "PR_tbArqueosCaja_LastByUsuario";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Usu_Id", DbType = DbType.Int32, Value = Usu_Id }},
            }};
            return await SearchAll<PR_tbArqueosCaja_LastResult>(sql, parameters);
        }}

        public async Task<Answer> Insert(int Usu_Id, DateTime Arq_Fecha, decimal Arq_TotalEfectivo, decimal Arq_TotalTransferencia, decimal Arq_TotalTarjeta, string Arq_Observaciones, int usuarioRegistra)
        {{
            const string sql = "PR_tbArqueosCaja_Insert";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Usu_Id",                 DbType = DbType.Int32,   Value = Usu_Id }},
                new SqlParameter {{ ParameterName = "@Arq_Fecha",              DbType = DbType.Date,    Value = Arq_Fecha }},
                new SqlParameter {{ ParameterName = "@Arq_TotalEfectivo",      DbType = DbType.Decimal, Value = Arq_TotalEfectivo }},
                new SqlParameter {{ ParameterName = "@Arq_TotalTransferencia", DbType = DbType.Decimal, Value = Arq_TotalTransferencia }},
                new SqlParameter {{ ParameterName = "@Arq_TotalTarjeta",       DbType = DbType.Decimal, Value = Arq_TotalTarjeta }},
                new SqlParameter {{ ParameterName = "@Arq_Observaciones",      DbType = DbType.String,  Value = (object)Arq_Observaciones ?? DBNull.Value }},
                new SqlParameter {{ ParameterName = "@Arq_UsuarioRegistra",    DbType = DbType.Int32,   Value = usuarioRegistra }},
            }};
            return await New(sql, parameters);
        }}
    }}
}}
'''

    files[BIZ_IFACE_DIR / f'I{entity}Service.cs'] = f'''\
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace {NS_BI}
{{
    public interface I{entity}Service
    {{
        Task<Answer> Find(int Arq_Id);
        Task<Answer> LastByUsuario(int Usu_Id);
        Task<Answer> Insert(int Usu_Id, DateTime Arq_Fecha, decimal Arq_TotalEfectivo, decimal Arq_TotalTransferencia, decimal Arq_TotalTarjeta, string Arq_Observaciones, int usuarioRegistra);
    }}
}}
'''

    files[BIZ_SVC_DIR / f'{entity}Service.cs'] = f'''\
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
        private readonly I{entity}Repository _r;
        public {entity}Service(I{entity}Repository r) {{ _r = r; }}

        private async Task<Answer> Wrap(Task<Answer> t, string msg = null)
        {{
            Answer a = await t;
            try {{ if (a.Access) {{ a.Message = MessageShow.Error; Logs.Error(a); }} else if (msg != null) a.Message = msg; return a; }}
            catch (Exception e) {{ a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }}
        }}

        public Task<Answer> Find(int Arq_Id) => Wrap(_r.Find(Arq_Id));
        public Task<Answer> LastByUsuario(int Usu_Id) => Wrap(_r.LastByUsuario(Usu_Id));
        public Task<Answer> Insert(int Usu_Id, DateTime Arq_Fecha, decimal Arq_TotalEfectivo, decimal Arq_TotalTransferencia, decimal Arq_TotalTarjeta, string Arq_Observaciones, int usuarioRegistra)
            => Wrap(_r.Insert(Usu_Id, Arq_Fecha, Arq_TotalEfectivo, Arq_TotalTransferencia, Arq_TotalTarjeta, Arq_Observaciones, usuarioRegistra), MessageShow.SuccessSave);
    }}
}}
'''

    files[CTRL_DIR / f'{entity}Controller.cs'] = f'''\
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace {NS_CTRL}
{{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class {entity}Controller : ControllerBase
    {{
        private readonly I{entity}Service _service;
        public {entity}Controller(I{entity}Service service) {{ _service = service; }}

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int Arq_Id)
        {{
            Answer answer = await _service.Find(Arq_Id);
            return Ok(answer.Data);
        }}

        [HttpGet("LastByUsuarioAsync")]
        public async Task<IActionResult> LastByUsuario(int Usu_Id)
        {{
            Answer answer = await _service.LastByUsuario(Usu_Id);
            return Ok(answer.Data);
        }}

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] ArqueoCajaRequest request)
        {{
            Answer answer = await _service.Insert(request.Usu_Id, request.Arq_Fecha, request.Arq_TotalEfectivo, request.Arq_TotalTransferencia, request.Arq_TotalTarjeta, request.Arq_Observaciones, request.UsuarioRegistra);
            return Ok(answer);
        }}
    }}

    public class ArqueoCajaRequest
    {{
        public int Usu_Id {{ get; set; }}
        public DateTime Arq_Fecha {{ get; set; }}
        public decimal Arq_TotalEfectivo {{ get; set; }}
        public decimal Arq_TotalTransferencia {{ get; set; }}
        public decimal Arq_TotalTarjeta {{ get; set; }}
        public string Arq_Observaciones {{ get; set; }}
        public int UsuarioRegistra {{ get; set; }}
    }}
}}
'''
    return entity, files


def gen_bitacora():
    entity = 'Bitacora'
    files = {}

    files[ENTITIES_DIR / 'UDP_tbBitacora_ListResult.cs'] = f'''\
using System;

namespace {NS_ENT}
{{
    public partial class UDP_tbBitacora_ListResult
    {{
        public int Bit_Id {{ get; set; }}
        public string Bit_Accion {{ get; set; }}
        public string Bit_Tabla {{ get; set; }}
        public int? Bit_RegistroId {{ get; set; }}
        public string Bit_Descripcion {{ get; set; }}
        public string Bit_Ip {{ get; set; }}
        public DateTime Bit_Fecha {{ get; set; }}
        public string Usu_Name {{ get; set; }}
    }}
}}
'''

    files[DA_IFACE_DIR / f'I{entity}Repository.cs'] = f'''\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace {NS_DAI}
{{
    public interface I{entity}Repository
    {{
        Task<Answer> List(int? Usu_Id, string Bit_Tabla, int? Top);
        Task<Answer> Insert(int Usu_Id, string Bit_Accion, string Bit_Tabla, int? Bit_RegistroId, string Bit_Descripcion, string Bit_Ip);
    }}
}}
'''

    files[DA_REPO_DIR / f'{entity}Repository.cs'] = f'''\
using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace {NS_DAR}
{{
    public class {entity}Repository : RepositoryBase, I{entity}Repository
    {{
        public async Task<Answer> List(int? Usu_Id, string Bit_Tabla, int? Top)
        {{
            const string sql = "UDP_tbBitacora_List";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Usu_Id",    DbType = DbType.Int32,  Value = (object)Usu_Id    ?? DBNull.Value }},
                new SqlParameter {{ ParameterName = "@Bit_Tabla", DbType = DbType.String, Value = (object)Bit_Tabla  ?? DBNull.Value }},
                new SqlParameter {{ ParameterName = "@Top",       DbType = DbType.Int32,  Value = (object)Top        ?? DBNull.Value }},
            }};
            return await SearchAll<UDP_tbBitacora_ListResult>(sql, parameters);
        }}

        public async Task<Answer> Insert(int Usu_Id, string Bit_Accion, string Bit_Tabla, int? Bit_RegistroId, string Bit_Descripcion, string Bit_Ip)
        {{
            const string sql = "UDP_tbBitacora_Insert";
            SqlParameter[] parameters =
            {{
                new SqlParameter {{ ParameterName = "@Usu_Id",        DbType = DbType.Int32,  Value = Usu_Id }},
                new SqlParameter {{ ParameterName = "@Bit_Accion",    DbType = DbType.String, Value = Bit_Accion }},
                new SqlParameter {{ ParameterName = "@Bit_Tabla",     DbType = DbType.String, Value = (object)Bit_Tabla     ?? DBNull.Value }},
                new SqlParameter {{ ParameterName = "@Bit_RegistroId",DbType = DbType.Int32,  Value = (object)Bit_RegistroId?? DBNull.Value }},
                new SqlParameter {{ ParameterName = "@Bit_Descripcion",DbType = DbType.String,Value = (object)Bit_Descripcion?? DBNull.Value }},
                new SqlParameter {{ ParameterName = "@Bit_Ip",        DbType = DbType.String, Value = (object)Bit_Ip        ?? DBNull.Value }},
            }};
            return await New(sql, parameters);
        }}
    }}
}}
'''

    files[BIZ_IFACE_DIR / f'I{entity}Service.cs'] = f'''\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace {NS_BI}
{{
    public interface I{entity}Service
    {{
        Task<Answer> List(int? Usu_Id, string Bit_Tabla, int? Top);
        Task<Answer> Insert(int Usu_Id, string Bit_Accion, string Bit_Tabla, int? Bit_RegistroId, string Bit_Descripcion, string Bit_Ip);
    }}
}}
'''

    files[BIZ_SVC_DIR / f'{entity}Service.cs'] = f'''\
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
        private readonly I{entity}Repository _r;
        public {entity}Service(I{entity}Repository r) {{ _r = r; }}

        private async Task<Answer> Wrap(Task<Answer> t, string msg = null)
        {{
            Answer a = await t;
            try {{ if (a.Access) {{ a.Message = MessageShow.Error; Logs.Error(a); }} else if (msg != null) a.Message = msg; return a; }}
            catch (Exception e) {{ a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }}
        }}

        public Task<Answer> List(int? Usu_Id, string Bit_Tabla, int? Top) => Wrap(_r.List(Usu_Id, Bit_Tabla, Top));
        public Task<Answer> Insert(int Usu_Id, string Bit_Accion, string Bit_Tabla, int? Bit_RegistroId, string Bit_Descripcion, string Bit_Ip)
            => Wrap(_r.Insert(Usu_Id, Bit_Accion, Bit_Tabla, Bit_RegistroId, Bit_Descripcion, Bit_Ip), MessageShow.SuccessSave);
    }}
}}
'''

    files[CTRL_DIR / f'{entity}Controller.cs'] = f'''\
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

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Usu_Id, string Bit_Tabla, int? Top)
        {{
            Answer answer = await _service.List(Usu_Id, Bit_Tabla, Top);
            return Ok(answer.Data);
        }}

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] BitacoraRequest request)
        {{
            Answer answer = await _service.Insert(request.Usu_Id, request.Bit_Accion, request.Bit_Tabla, request.Bit_RegistroId, request.Bit_Descripcion, request.Bit_Ip);
            return Ok(answer);
        }}
    }}

    public class BitacoraRequest
    {{
        public int Usu_Id {{ get; set; }}
        public string Bit_Accion {{ get; set; }}
        public string Bit_Tabla {{ get; set; }}
        public int? Bit_RegistroId {{ get; set; }}
        public string Bit_Descripcion {{ get; set; }}
        public string Bit_Ip {{ get; set; }}
    }}
}}
'''
    return entity, files


# ================================================================
#  MAIN
# ================================================================

def main():
    import sys
    sys.path.insert(0, str(Path(__file__).parent))
    from gen_dashboards import gen_section_result, gen_container, gen_iface_repo as gdr_iface_repo, gen_repo as gdr_repo, gen_iface_svc as gdr_iface_svc, gen_svc as gdr_svc, gen_ctrl as gdr_ctrl

    print('\n' + '='*60)
    print('  PATRÓN 1: READ_LIST')
    print('='*60)

    for m in READ_LIST_MODULES:
        entity = m['entity']
        print(f'\n--- {entity} ---')
        ec, ir, rc, is_, sc, cc = gen_read_list(m)
        write(ENTITIES_DIR  / f'{entity}Result.cs',        ec)
        write(DA_IFACE_DIR  / f'I{entity}Repository.cs',   ir)
        write(DA_REPO_DIR   / f'{entity}Repository.cs',    rc)
        write(BIZ_IFACE_DIR / f'I{entity}Service.cs',      is_)
        write(BIZ_SVC_DIR   / f'{entity}Service.cs',       sc)
        write(CTRL_DIR      / f'{entity}Controller.cs',    cc)
        patch_program(entity)

    print('\n' + '='*60)
    print('  PATRÓN 2: MULTI-RESULT (Ficha360)')
    print('='*60)

    for m in MULTI_MODULES:
        entity = m['entity']
        sp     = m['sp']
        params = m['params']
        sections = m['sections']
        print(f'\n--- {entity} ---')
        for sec_name, fields, _ in sections:
            write(ENTITIES_DIR / f'{entity}_{sec_name}Result.cs',
                  gen_section_result(entity, sec_name, fields))
        write(ENTITIES_DIR / f'{entity}Result.cs',       gen_container(entity, sections))
        write(DA_IFACE_DIR / f'I{entity}Repository.cs',  gdr_iface_repo(entity, params))
        write(DA_REPO_DIR  / f'{entity}Repository.cs',   gdr_repo(entity, sp, params, sections))
        write(BIZ_IFACE_DIR/ f'I{entity}Service.cs',     gdr_iface_svc(entity, params))
        write(BIZ_SVC_DIR  / f'{entity}Service.cs',      gdr_svc(entity, params))
        write(CTRL_DIR     / f'{entity}Controller.cs',   gdr_ctrl(entity, params))
        patch_program(entity)

    print('\n' + '='*60)
    print('  PATRÓN 3: CUSTOM')
    print('='*60)

    for gen_fn in [gen_asistencia, gen_documentos_alumno, gen_vacaciones, gen_arqueos_caja, gen_bitacora]:
        entity, files = gen_fn()
        print(f'\n--- {entity} ---')
        for path, content in files.items():
            write(path, content)
        patch_program(entity)

    print('\n' + '='*60)
    print('  Generación completada.')
    print('='*60 + '\n')


if __name__ == '__main__':
    main()
