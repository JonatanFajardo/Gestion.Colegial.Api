#!/usr/bin/env python3
"""
scaffold_api.py
==============================================================
Genera el backend completo para una pantalla en Gestion.Colegial.Api
siguiendo las convenciones del proyecto (ADO.NET + RepositoryBase).

MODOS:
  --tipo read   Pantalla de solo lectura / dashboard (default)
  --tipo crud   CRUD completo (List, Find, Insert, Update, Delete)

USO — Solo lectura / Dashboard:
    python tools/scaffold_api.py DashboardAdmin
        --sp PR_DashboardAdmin_Resumen --schema app
        --section Kpis "TotalUsuarios:int TotalRoles:int AccionesHoy:int"
        --section Bitacora "Usu_Name:string Bit_Accion:string Bit_Fecha:datetime"

    python tools/scaffold_api.py Perfil
        --sp UDP_tbUsuarios_Perfil --schema Seguridad
        --params "Usu_Id:int"
        --fields "Usu_Id:int Usu_Name:string Rol_Descripcion:string NombreCompleto:string"

USO — CRUD:
    python tools/scaffold_api.py Asistencia
        --tipo crud --schema app --prefix Asi
        --params "Hor_Id:int Alu_Id:int Asi_Fecha:datetime"
        --fields "Asi_Estado:string Asi_Observacion:string?"

Tipos soportados:
    string  int  int?  decimal  decimal?  datetime  datetime?  bit  bool  bool?
==============================================================
"""

import argparse
import re
import sys
from pathlib import Path

# ── Rutas del proyecto ──────────────────────────────────────
ROOT         = Path(__file__).parent.parent
ENTITIES_DIR = ROOT / 'Gestion.Colegial.Entities'  / 'Entities' / 'dbo'
DA_IFACE_DIR = ROOT / 'Gestion.Colegial.DataAccess' / 'Interfaces'
DA_REPO_DIR  = ROOT / 'Gestion.Colegial.DataAccess' / 'Repositories'
BIZ_IFACE_DIR= ROOT / 'Gestion.Colegial.Business'  / 'Interfaces'
BIZ_SVC_DIR  = ROOT / 'Gestion.Colegial.Business'  / 'Services'
CTRL_DIR     = ROOT / 'Gestion.Colegial.Api'        / 'Controllers'
PROGRAM_CS   = ROOT / 'Gestion.Colegial.Api'        / 'Program.cs'

# ── Namespaces ──────────────────────────────────────────────
NS_ENTITIES  = 'Gestion.Colegial.Entities.Entities'
NS_DA_IFACE  = 'Gestion.Colegial.DataAccess.Interfaces'
NS_DA_REPO   = 'Gestion.Colegial.DataAccess.Repositories'
NS_BIZ_IFACE = 'Gestion.Colegial.Business.Interfaces'
NS_BIZ_SVC   = 'Gestion.Colegial.Business.Services'
NS_CTRL      = 'Gestion.Colegial.Api.Controllers'

# ── Mapeo de tipos ──────────────────────────────────────────
CS_TYPES = {
    'string':    'string',   'int':       'int',
    'int?':      'int?',     'decimal':   'decimal',
    'decimal?':  'decimal?', 'datetime':  'DateTime',
    'datetime?': 'DateTime?','bit':       'bool',
    'bit?':      'bool?',    'bool':      'bool',
    'bool?':     'bool?',    'date':      'DateTime',
    'date?':     'DateTime?','char':      'string',
}
DB_TYPES = {
    'string':    'DbType.String',   'int':       'DbType.Int32',
    'int?':      'DbType.Int32',    'decimal':   'DbType.Decimal',
    'decimal?':  'DbType.Decimal',  'datetime':  'DbType.DateTime',
    'datetime?': 'DbType.DateTime', 'bit':       'DbType.Boolean',
    'bit?':      'DbType.Boolean',  'bool':      'DbType.Boolean',
    'bool?':     'DbType.Boolean',  'date':      'DbType.Date',
    'date?':     'DbType.Date',     'char':      'DbType.String',
}
SQL_TYPES = {
    'string':    'VARCHAR(200)',  'int':       'INT',
    'int?':      'INT',          'decimal':   'DECIMAL(10,2)',
    'decimal?':  'DECIMAL(10,2)','datetime':  'DATETIME',
    'datetime?': 'DATETIME',     'bit':       'BIT',
    'bool':      'BIT',          'date':      'DATE',
    'date?':     'DATE',         'char':      'CHAR(1)',
}

def cs(t):   return CS_TYPES.get(t.lower(), 'string')
def dbt(t):  return DB_TYPES.get(t.lower(), 'DbType.String')
def sqlt(t): return SQL_TYPES.get(t.lower(), 'VARCHAR(200)')

def parse_fields(s):
    out = []
    for tok in s.strip().split():
        if ':' in tok:
            name, typ = tok.split(':', 1)
        else:
            name, typ = tok, 'string'
        out.append({'name': name, 'type': typ.lower()})
    return out

def write(path: Path, content: str, entity: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        print(f'  [SKIP]  {path.relative_to(ROOT)}  (ya existe)')
        return
    path.write_text(content, encoding='utf-8')
    print(f'  [NEW]   {path.relative_to(ROOT)}')

def patch_program(entity: str):
    """Agrega el repo y servicio al Program.cs si no están ya."""
    text = PROGRAM_CS.read_text(encoding='utf-8')
    iface_repo = f'I{entity}Repository'
    iface_svc  = f'I{entity}Service'
    repo_line  = f'builder.Services.AddScoped<{iface_repo}, {entity}Repository>();'
    svc_line   = f'builder.Services.AddScoped<{iface_svc}, {entity}Service>();'
    changed = False

    if repo_line not in text:
        anchor = '// Repositorios Fase 1'
        text = text.replace(anchor, f'{repo_line}\n{anchor}')
        changed = True

    if svc_line not in text:
        anchor = '// Servicios Fase 1'
        text = text.replace(anchor, f'{svc_line}\n{anchor}')
        changed = True

    if changed:
        PROGRAM_CS.write_text(text, encoding='utf-8')
        print(f'  [PATCH] Program.cs  (+{entity}Repository, +{entity}Service)')
    else:
        print(f'  [SKIP]  Program.cs  ({entity} ya registrado)')


# ============================================================
#  GENERADORES — MODO READ
# ============================================================

def gen_result_class(entity: str, section: str, fields: list) -> str:
    suffix = section if section else 'Result'
    class_name = f'{entity}_{suffix}Result'
    props = '\n'.join(
        f'        public {cs(f["type"])} {f["name"]} {{ get; set; }}'
        for f in fields
    )
    return f'''\
using System;

namespace {NS_ENTITIES}
{{
    public partial class {class_name}
    {{
{props}
    }}
}}
'''

def gen_iface_read(entity: str, sections: list, params: list) -> str:
    param_sig = ', '.join(f'{cs(p["type"])} {p["name"]}' for p in params)
    methods = '\n'.join(
        f'        Task<Answer> {sec}({"" if not params else param_sig});'
        for sec, _ in sections
    )
    return f'''\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace {NS_DA_IFACE}
{{
    public interface I{entity}Repository
    {{
{methods}
    }}
}}
'''

def gen_repo_read(entity: str, sp: str, schema: str, sections: list, params: list) -> str:
    using_dt = any('DateTime' in cs(f['type']) for _, fields in sections for f in fields)
    param_sig  = ', '.join(f'{cs(p["type"])} {p["name"]}' for p in params)
    param_decl = ''.join(
        f'                new SqlParameter {{ ParameterName = "@{p["name"]}", DbType = {dbt(p["type"])}, Value = (object){p["name"]} ?? DBNull.Value }},\n'
        for p in params
    )

    methods = []
    for sec, fields in sections:
        result_cls = f'{entity}_{sec}Result'
        if params:
            m = f'''\
        public async Task<Answer> {sec}({param_sig})
        {{
            const string sql = "{sp}";
            SqlParameter[] parameters = {{
{param_decl.rstrip()}
            }};
            return await SearchAll<{result_cls}>(sql, parameters);
        }}'''
        else:
            m = f'''\
        public async Task<Answer> {sec}()
        {{
            const string sql = "{sp}";
            return await Read<{result_cls}>(sql);
        }}'''
        methods.append(m)

    body = '\n\n'.join(methods)
    dt_using = 'using System;\n' if params else ''
    return f'''\
{dt_using}using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace {NS_DA_REPO}
{{
    public class {entity}Repository : RepositoryBase, I{entity}Repository
    {{
{body}
    }}
}}
'''

def gen_iface_svc_read(entity: str, sections: list, params: list) -> str:
    param_sig = ', '.join(f'{cs(p["type"])} {p["name"]}' for p in params)
    methods = '\n'.join(
        f'        Task<Answer> {sec}({"" if not params else param_sig});'
        for sec, _ in sections
    )
    return f'''\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace {NS_BIZ_IFACE}
{{
    public interface I{entity}Service
    {{
{methods}
    }}
}}
'''

def gen_svc_read(entity: str, sections: list, params: list) -> str:
    param_sig  = ', '.join(f'{cs(p["type"])} {p["name"]}' for p in params)
    call_args  = ', '.join(p['name'] for p in params)
    methods = []
    for sec, _ in sections:
        call = f'_repository.{sec}({call_args})'
        m = f'''\
        public async Task<Answer> {sec}({param_sig if params else ""})
        {{
            Answer answer = await {call};
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
        }}'''
        methods.append(m)

    body = '\n\n'.join(methods)
    return f'''\
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace {NS_BIZ_SVC}
{{
    public class {entity}Service : I{entity}Service
    {{
        private readonly I{entity}Repository _repository;
        public {entity}Service(I{entity}Repository repository) {{ _repository = repository; }}

{body}
    }}
}}
'''

def gen_ctrl_read(entity: str, sections: list, params: list) -> str:
    param_sig  = ', '.join(f'{cs(p["type"])} {p["name"]}' for p in params)
    call_args  = ', '.join(p['name'] for p in params)
    route_qs   = '?' + '&'.join(f'{p["name"]}={{{p["name"]}}}' for p in params) if params else ''
    actions = []
    for sec, _ in sections:
        a = f'''\
        [HttpGet("{sec}Async")]
        public async Task<IActionResult> {sec}({param_sig if params else ""})
        {{
            Answer answer = await _service.{sec}({call_args});
            return Ok(answer.Data);
        }}'''
        actions.append(a)

    body = '\n\n'.join(actions)
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

{body}
    }}
}}
'''


# ============================================================
#  GENERADORES — MODO CRUD
# ============================================================

def gen_result_list(entity: str, prefix: str, fields: list) -> str:
    pk = f'{prefix}_Id'
    props_pk = f'        public int {pk} {{ get; set; }}'
    props = '\n'.join(
        f'        public {cs(f["type"])} {f["name"]} {{ get; set; }}'
        for f in fields
    )
    return f'''\
using System;

namespace {NS_ENTITIES}
{{
    public partial class PR_tb{entity}_ListResult
    {{
{props_pk}
{props}
    }}
}}
'''

def gen_result_find(entity: str, prefix: str, fields: list) -> str:
    pk = f'{prefix}_Id'
    props_pk = f'        public int {pk} {{ get; set; }}'
    props = '\n'.join(
        f'        public {cs(f["type"])} {f["name"]} {{ get; set; }}'
        for f in fields
    )
    return f'''\
using System;

namespace {NS_ENTITIES}
{{
    public partial class PR_tb{entity}_FindResult
    {{
{props_pk}
{props}
    }}
}}
'''

def gen_iface_crud(entity: str, prefix: str, fields: list, params: list) -> str:
    pk     = f'{prefix}_Id'
    fields_sig = ', '.join(f'{cs(f["type"])} {f["name"]}' for f in fields)
    return f'''\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace {NS_DA_IFACE}
{{
    public interface I{entity}Repository
    {{
        Task<Answer> List();
        Task<Answer> Find(int {pk});
        Task<Answer> Insert({", ".join(f'{cs(f["type"])} {f["name"]}' for f in (params + fields))}, int usuarioRegistra);
        Task<Answer> Update(int {pk}, {fields_sig}, int usuarioModifica);
        Task<Answer> Delete(int {pk}, int usuarioModifica);
    }}
}}
'''

def gen_repo_crud(entity: str, schema: str, prefix: str, fields: list, params: list) -> str:
    pk      = f'{prefix}_Id'
    sp_base = f'PR_tb{entity}'

    def make_params(pairs):
        lines = []
        for name, typ in pairs:
            nullable = typ.endswith('?') or typ == 'string'
            val = f'(object){name} ?? DBNull.Value' if nullable else name
            lines.append(
                f'                new SqlParameter {{ ParameterName = "@{name}", DbType = {dbt(typ)}, Value = {val} }},'
            )
        return '\n'.join(lines)

    insert_pairs = [(p['name'], p['type']) for p in params + fields] + [('usuarioRegistra', 'int')]
    update_pairs = [(pk, 'int')] + [(f['name'], f['type']) for f in fields] + [('usuarioModifica', 'int')]
    insert_sig = ', '.join(f'{cs(p["type"])} {p["name"]}' for p in params + fields) + ', int usuarioRegistra'
    fields_sig = ', '.join(f'{cs(f["type"])} {f["name"]}' for f in fields)

    return f'''\
using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace {NS_DA_REPO}
{{
    public class {entity}Repository : RepositoryBase, I{entity}Repository
    {{
        public async Task<Answer> List()
        {{
            const string sql = "{sp_base}_List";
            return await Read<PR_tb{entity}_ListResult>(sql);
        }}

        public async Task<Answer> Find(int {pk})
        {{
            const string sql = "{sp_base}_Find";
            SqlParameter[] parameters = {{
                new SqlParameter {{ ParameterName = "@{pk}", DbType = DbType.Int32, Value = {pk} }},
            }};
            return await Search<PR_tb{entity}_FindResult>(sql, parameters);
        }}

        public async Task<Answer> Insert({insert_sig})
        {{
            const string sql = "{sp_base}_Insert";
            SqlParameter[] parameters = {{
{make_params(insert_pairs)}
            }};
            return await New(sql, parameters);
        }}

        public async Task<Answer> Update(int {pk}, {fields_sig}, int usuarioModifica)
        {{
            const string sql = "{sp_base}_Update";
            SqlParameter[] parameters = {{
{make_params(update_pairs)}
            }};
            return await Update(sql, parameters);
        }}

        public async Task<Answer> Delete(int {pk}, int usuarioModifica)
        {{
            const string sql = "{sp_base}_Delete";
            SqlParameter[] parameters = {{
                new SqlParameter {{ ParameterName = "@{pk}", DbType = DbType.Int32, Value = {pk} }},
                new SqlParameter {{ ParameterName = "@usuarioModifica", DbType = DbType.Int32, Value = usuarioModifica }},
            }};
            return await Delete(sql, parameters);
        }}
    }}
}}
'''

def gen_iface_svc_crud(entity: str, prefix: str, fields: list, params: list) -> str:
    pk = f'{prefix}_Id'
    insert_sig = ', '.join(f'{cs(f["type"])} {f["name"]}' for f in params + fields) + ', int usuarioRegistra'
    fields_sig = ', '.join(f'{cs(f["type"])} {f["name"]}' for f in fields)
    return f'''\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace {NS_BIZ_IFACE}
{{
    public interface I{entity}Service
    {{
        Task<Answer> List();
        Task<Answer> Find(int {pk});
        Task<Answer> Insert({insert_sig});
        Task<Answer> Update(int {pk}, {fields_sig}, int usuarioModifica);
        Task<Answer> Delete(int {pk}, int usuarioModifica);
    }}
}}
'''

def gen_svc_crud(entity: str, prefix: str, fields: list, params: list) -> str:
    pk = f'{prefix}_Id'
    insert_sig = ', '.join(f'{cs(f["type"])} {f["name"]}' for f in params + fields) + ', int usuarioRegistra'
    insert_call = ', '.join(f['name'] for f in params + fields) + ', usuarioRegistra'
    fields_sig  = ', '.join(f'{cs(f["type"])} {f["name"]}' for f in fields)
    fields_call = ', '.join(f['name'] for f in fields)

    def wrap(method_sig, call, msg=''):
        msg_str = f'answer.Message = MessageShow.{msg};' if msg else ''
        return f'''\
        public async Task<Answer> {method_sig}
        {{
            Answer answer = await {call};
            try
            {{
                if (answer.Access) {{ answer.Message = MessageShow.Error; Logs.Error(answer); return answer; }}
                {msg_str}
                return answer;
            }}
            catch (Exception e)
            {{
                answer.Access = true; answer.Message = MessageShow.Error;
                answer.Incidents(e); Logs.Error(answer); return answer;
            }}
        }}'''

    return f'''\
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace {NS_BIZ_SVC}
{{
    public class {entity}Service : I{entity}Service
    {{
        private readonly I{entity}Repository _repository;
        public {entity}Service(I{entity}Repository repository) {{ _repository = repository; }}

{wrap("List()", "_repository.List()")}

{wrap(f"Find(int {pk})", f"_repository.Find({pk})")}

{wrap(f"Insert({insert_sig})", f"_repository.Insert({insert_call})", "SuccessSave")}

{wrap(f"Update(int {pk}, {fields_sig}, int usuarioModifica)", f"_repository.Update({pk}, {fields_call}, usuarioModifica)", "SuccessEdit")}

{wrap(f"Delete(int {pk}, int usuarioModifica)", f"_repository.Delete({pk}, usuarioModifica)", "SuccessDelete")}
    }}
}}
'''

def gen_ctrl_crud(entity: str, prefix: str, fields: list, params: list) -> str:
    pk = f'{prefix}_Id'
    insert_sig  = ', '.join(f'{cs(f["type"])} {f["name"]}' for f in params + fields) + ', int usuarioRegistra'
    insert_call = ', '.join(f['name'] for f in params + fields) + ', usuarioRegistra'
    fields_sig  = ', '.join(f'{cs(f["type"])} {f["name"]}' for f in fields)
    fields_call = ', '.join(f['name'] for f in fields)

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

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List()
        {{
            Answer answer = await _service.List();
            return Ok(answer.Data);
        }}

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int {pk})
        {{
            Answer answer = await _service.Find({pk});
            return Ok(answer.Data);
        }}

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] {entity}Request request)
        {{
            Answer answer = await _service.Insert({insert_call.replace('usuarioRegistra', 'request.UsuarioRegistra').replace(', '.join(f['name'] for f in params + fields), ', '.join(f'request.{f["name"]}' for f in params + fields))});
            return Ok(answer.Data);
        }}

        [HttpPut("EditAsync")]
        public async Task<IActionResult> Edit(int {pk}, [FromBody] {entity}Request request)
        {{
            Answer answer = await _service.Update({pk}, {", ".join(f'request.{f["name"]}' for f in fields)}, request.UsuarioRegistra);
            return Ok(answer.Data);
        }}

        [HttpPut("RemoveAsync")]
        public async Task<IActionResult> Remove(int {pk}, int usuarioModifica)
        {{
            Answer answer = await _service.Delete({pk}, usuarioModifica);
            return Ok(answer.Data);
        }}
    }}

    public class {entity}Request
    {{
        public int UsuarioRegistra {{ get; set; }}
{chr(10).join(f"        public {cs(f['type'])} {f['name']} {{ get; set; }}" for f in params + fields)}
    }}
}}
'''


# ============================================================
#  MAIN
# ============================================================

def main():
    p = argparse.ArgumentParser(description='Scaffold para Gestion.Colegial.Api')
    p.add_argument('entity',               help='Nombre de la entidad en PascalCase (ej: DashboardAdmin)')
    p.add_argument('--tipo', '-t',         default='read', choices=['read', 'crud'],
                                           help='Modo: read (default) o crud')
    p.add_argument('--sp',                 default=None,
                                           help='Nombre del SP (sin schema). Requerido en modo read.')
    p.add_argument('--schema', '-s',       default='app',
                                           help='Schema SQL (app, finanza, Seguridad). Default: app')
    p.add_argument('--prefix', '-x',       default=None,
                                           help='Prefijo de columnas para modo crud (ej: Asi → Asi_Id)')
    p.add_argument('--params',             default='',
                                           help='Parámetros del SP: "Hor_Id:int Fecha:date"')
    p.add_argument('--fields', '-f',       default='',
                                           help='Campos del result/entity: "campo:tipo campo2:tipo?"')
    p.add_argument('--section', '-sec',    nargs=2, action='append', metavar=('NOMBRE', 'CAMPOS'),
                                           default=[],
                                           help='Sección del dashboard: --section Kpis "Total:int Activos:int"')
    args = p.parse_args()

    entity  = args.entity
    params  = parse_fields(args.params) if args.params else []
    fields  = parse_fields(args.fields) if args.fields else []
    sections = [(sec, parse_fields(flds)) for sec, flds in args.section] if args.section else []

    print()
    print('=' * 60)
    print(f'  scaffold_api.py — {entity} ({args.tipo.upper()})')
    print('=' * 60)

    # ── Modo READ ───────────────────────────────────────────
    if args.tipo == 'read':
        if not args.sp:
            print('[ERROR] --sp es requerido en modo read.')
            sys.exit(1)

        # Si no hay sections pero sí fields, crear una sección "Result"
        if not sections and fields:
            sections = [('Result', fields)]
        elif not sections:
            print('[ERROR] Especifica --section o --fields con los campos del resultado.')
            sys.exit(1)

        # Result classes
        for sec, flds in sections:
            cls_name = f'{entity}_{sec}Result'
            write(ENTITIES_DIR / f'{cls_name}.cs',
                  gen_result_class(entity, sec, flds), entity)

        # DataAccess
        write(DA_IFACE_DIR / f'I{entity}Repository.cs',
              gen_iface_read(entity, sections, params), entity)
        write(DA_REPO_DIR  / f'{entity}Repository.cs',
              gen_repo_read(entity, args.sp, args.schema, sections, params), entity)

        # Business
        write(BIZ_IFACE_DIR / f'I{entity}Service.cs',
              gen_iface_svc_read(entity, sections, params), entity)
        write(BIZ_SVC_DIR   / f'{entity}Service.cs',
              gen_svc_read(entity, sections, params), entity)

        # Controller
        write(CTRL_DIR / f'{entity}Controller.cs',
              gen_ctrl_read(entity, sections, params), entity)

    # ── Modo CRUD ───────────────────────────────────────────
    elif args.tipo == 'crud':
        if not args.prefix:
            print('[ERROR] --prefix es requerido en modo crud (ej: --prefix Asi)')
            sys.exit(1)

        prefix = args.prefix

        # Result classes
        write(ENTITIES_DIR / f'PR_tb{entity}_ListResult.cs',
              gen_result_list(entity, prefix, fields), entity)
        write(ENTITIES_DIR / f'PR_tb{entity}_FindResult.cs',
              gen_result_find(entity, prefix, fields), entity)

        # DataAccess
        write(DA_IFACE_DIR / f'I{entity}Repository.cs',
              gen_iface_crud(entity, prefix, fields, params), entity)
        write(DA_REPO_DIR  / f'{entity}Repository.cs',
              gen_repo_crud(entity, args.schema, prefix, fields, params), entity)

        # Business
        write(BIZ_IFACE_DIR / f'I{entity}Service.cs',
              gen_iface_svc_crud(entity, prefix, fields, params), entity)
        write(BIZ_SVC_DIR   / f'{entity}Service.cs',
              gen_svc_crud(entity, prefix, fields, params), entity)

        # Controller
        write(CTRL_DIR / f'{entity}Controller.cs',
              gen_ctrl_crud(entity, prefix, fields, params), entity)

    # ── Patch Program.cs ────────────────────────────────────
    patch_program(entity)

    print()
    print('  Endpoints generados:')
    if args.tipo == 'read':
        for sec, _ in sections:
            print(f'    GET api/v1/{entity}/{sec}Async')
    else:
        pk = f'{args.prefix}_Id'
        print(f'    GET  api/v1/{entity}/ListAsync')
        print(f'    GET  api/v1/{entity}/FindAsync?{pk}=1')
        print(f'    POST api/v1/{entity}/CreateAsync')
        print(f'    PUT  api/v1/{entity}/EditAsync?{pk}=1')
        print(f'    PUT  api/v1/{entity}/RemoveAsync?{pk}=1')
    print()
    print('=' * 60)
    print()


if __name__ == '__main__':
    main()
