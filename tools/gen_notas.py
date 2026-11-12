"""Genera el módulo Notas completo: IRepository, Repository, IService, Service, Controller + parchea Program.cs."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def path(*parts): return os.path.join(ROOT, *parts)

def write(filepath, content):
    if os.path.exists(filepath):
        print(f"  [SKIP] {os.path.relpath(filepath, ROOT)}")
        return
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"  [OK]   {os.path.relpath(filepath, ROOT)}")

def overwrite(filepath, content):
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"  [OW]   {os.path.relpath(filepath, ROOT)}")

# ─── IRepository ────────────────────────────────────────────────────────────
i_repo = """\
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface INotasRepository
    {
        Task<Answer> Cuaderno(int Sec_Id, int Mat_Id, int Par_Id, int Sem_Id, int Anio);
        Task<Answer> Boletin(int Alu_Id, int Sem_Id, int Anio);
        Task<Answer> Insert(int Alu_Id, int Sec_Id, int Mat_Id, int Sem_Id, int Par_Id,
                            decimal Not_Nota, DateTime Not_Año, int usuarioRegistra);
        Task<Answer> Edit(int Not_Id, decimal Not_Nota, int usuarioModifica);
    }
}
"""

# ─── Repository ─────────────────────────────────────────────────────────────
repo = """\
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class NotasRepository : RepositoryBase, INotasRepository
    {
        public async Task<Answer> Cuaderno(int Sec_Id, int Mat_Id, int Par_Id, int Sem_Id, int Anio)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Sec_Id", DbType = DbType.Int32, Value = Sec_Id },
                new SqlParameter { ParameterName = "@Mat_Id", DbType = DbType.Int32, Value = Mat_Id },
                new SqlParameter { ParameterName = "@Par_Id", DbType = DbType.Int32, Value = Par_Id },
                new SqlParameter { ParameterName = "@Sem_Id", DbType = DbType.Int32, Value = Sem_Id },
                new SqlParameter { ParameterName = "@Anio",   DbType = DbType.Int32, Value = Anio },
            };
            return await SearchAll<NotasCuadernoResult>("PR_Notas_CuadernoParcial", p);
        }

        public async Task<Answer> Boletin(int Alu_Id, int Sem_Id, int Anio)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Alu_Id", DbType = DbType.Int32, Value = Alu_Id },
                new SqlParameter { ParameterName = "@Sem_Id", DbType = DbType.Int32, Value = Sem_Id },
                new SqlParameter { ParameterName = "@Anio",   DbType = DbType.Int32, Value = Anio },
            };
            return await SearchAll<NotasBoletinResult>("PR_Notas_BoletinAlumno", p);
        }

        public async Task<Answer> Insert(int Alu_Id, int Sec_Id, int Mat_Id, int Sem_Id, int Par_Id,
                                         decimal Not_Nota, DateTime Not_Año, int usuarioRegistra)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Alu_Id",              DbType = DbType.Int32,   Value = Alu_Id },
                new SqlParameter { ParameterName = "@Sec_Id",              DbType = DbType.Int32,   Value = Sec_Id },
                new SqlParameter { ParameterName = "@Mat_Id",              DbType = DbType.Int32,   Value = Mat_Id },
                new SqlParameter { ParameterName = "@Sem_Id",              DbType = DbType.Int32,   Value = Sem_Id },
                new SqlParameter { ParameterName = "@Par_Id",              DbType = DbType.Int32,   Value = Par_Id },
                new SqlParameter { ParameterName = "@Not_Nota",            DbType = DbType.Decimal, Value = Not_Nota },
                new SqlParameter { ParameterName = "@Not_Año",             DbType = DbType.Date,    Value = Not_Año },
                new SqlParameter { ParameterName = "@Not_UsuarioRegistra", DbType = DbType.Int32,   Value = usuarioRegistra },
            };
            return await New("PR_tbNotas_Insert", p);
        }

        public async Task<Answer> Edit(int Not_Id, decimal Not_Nota, int usuarioModifica)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Not_Id",              DbType = DbType.Int32,   Value = Not_Id },
                new SqlParameter { ParameterName = "@Not_Nota",            DbType = DbType.Decimal, Value = Not_Nota },
                new SqlParameter { ParameterName = "@Not_UsuarioModifica", DbType = DbType.Int32,   Value = usuarioModifica },
            };
            return await Update("PR_tbNotas_Update", p);
        }
    }
}
"""

# ─── IService ───────────────────────────────────────────────────────────────
i_svc = """\
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface INotasService
    {
        Task<Answer> Cuaderno(int Sec_Id, int Mat_Id, int Par_Id, int Sem_Id, int Anio);
        Task<Answer> Boletin(int Alu_Id, int Sem_Id, int Anio);
        Task<Answer> Insert(int Alu_Id, int Sec_Id, int Mat_Id, int Sem_Id, int Par_Id,
                            decimal Not_Nota, DateTime Not_Año, int usuarioRegistra);
        Task<Answer> Edit(int Not_Id, decimal Not_Nota, int usuarioModifica);
    }
}
"""

# ─── Service ────────────────────────────────────────────────────────────────
svc = """\
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class NotasService : INotasService
    {
        private readonly INotasRepository _r;
        public NotasService(INotasRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> task, string msg = null)
        {
            Answer a = await task;
            try
            {
                if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); }
                else if (msg != null) a.Message = msg;
                return a;
            }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }
        }

        public Task<Answer> Cuaderno(int Sec_Id, int Mat_Id, int Par_Id, int Sem_Id, int Anio)
            => Wrap(_r.Cuaderno(Sec_Id, Mat_Id, Par_Id, Sem_Id, Anio));

        public Task<Answer> Boletin(int Alu_Id, int Sem_Id, int Anio)
            => Wrap(_r.Boletin(Alu_Id, Sem_Id, Anio));

        public Task<Answer> Insert(int Alu_Id, int Sec_Id, int Mat_Id, int Sem_Id, int Par_Id,
                                   decimal Not_Nota, DateTime Not_Año, int usuarioRegistra)
            => Wrap(_r.Insert(Alu_Id, Sec_Id, Mat_Id, Sem_Id, Par_Id, Not_Nota, Not_Año, usuarioRegistra),
                    MessageShow.SuccessSave);

        public Task<Answer> Edit(int Not_Id, decimal Not_Nota, int usuarioModifica)
            => Wrap(_r.Edit(Not_Id, Not_Nota, usuarioModifica), MessageShow.SuccessEdit);
    }
}
"""

# ─── Controller ─────────────────────────────────────────────────────────────
ctrl = """\
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class NotasController : ControllerBase
    {
        private readonly INotasService _service;
        public NotasController(INotasService service) { _service = service; }

        [HttpGet("CuadernoAsync")]
        public async Task<IActionResult> Cuaderno(int Sec_Id, int Mat_Id, int Par_Id, int Sem_Id, int Anio)
        {
            Answer answer = await _service.Cuaderno(Sec_Id, Mat_Id, Par_Id, Sem_Id, Anio);
            return Ok(answer.Data);
        }

        [HttpGet("BoletinAsync")]
        public async Task<IActionResult> Boletin(int Alu_Id, int Sem_Id, int Anio)
        {
            Answer answer = await _service.Boletin(Alu_Id, Sem_Id, Anio);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] NotaCreateRequest request)
        {
            Answer answer = await _service.Insert(
                request.Alu_Id, request.Sec_Id, request.Mat_Id, request.Sem_Id, request.Par_Id,
                request.Not_Nota, request.Not_Año, request.UsuarioRegistra);
            return Ok(answer);
        }

        [HttpPut("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] NotaEditRequest request)
        {
            Answer answer = await _service.Edit(request.Not_Id, request.Not_Nota, request.UsuarioModifica);
            return Ok(answer);
        }
    }

    public class NotaCreateRequest
    {
        public int Alu_Id { get; set; }
        public int Sec_Id { get; set; }
        public int Mat_Id { get; set; }
        public int Sem_Id { get; set; }
        public int Par_Id { get; set; }
        public decimal Not_Nota { get; set; }
        public DateTime Not_Año { get; set; }
        public int UsuarioRegistra { get; set; }
    }

    public class NotaEditRequest
    {
        public int Not_Id { get; set; }
        public decimal Not_Nota { get; set; }
        public int UsuarioModifica { get; set; }
    }
}
"""

# ─── Escribir archivos ───────────────────────────────────────────────────────
print("Generando módulo Notas...")
write(path("Gestion.Colegial.DataAccess", "Interfaces", "INotasRepository.cs"), i_repo)
overwrite(path("Gestion.Colegial.DataAccess", "Repositories", "NotasRepository.cs"), repo)
write(path("Gestion.Colegial.Business",  "Interfaces", "INotasService.cs"), i_svc)
write(path("Gestion.Colegial.Business",  "Services",   "NotasService.cs"), svc)
overwrite(path("Gestion.Colegial.Api",   "Controllers", "NotasController.cs"), ctrl)

# ─── Parchear Program.cs ────────────────────────────────────────────────────
prog = path("Gestion.Colegial.Api", "Program.cs")
with open(prog, encoding='utf-8') as f:
    txt = f.read()

changed = False

repo_line = "builder.Services.AddScoped<INotasRepository, NotasRepository>();\n"
if "INotasRepository" not in txt:
    txt = txt.replace(
        "// Repositorios Fase 1 (Infraestructura compartida)",
        repo_line + "// Repositorios Fase 1 (Infraestructura compartida)"
    )
    changed = True

svc_line = "builder.Services.AddScoped<INotasService, NotasService>();\n"
if "INotasService" not in txt:
    txt = txt.replace(
        "// Servicios Fase 1 (Infraestructura compartida)",
        svc_line + "// Servicios Fase 1 (Infraestructura compartida)"
    )
    changed = True

if changed:
    with open(prog, 'w', encoding='utf-8') as f:
        f.write(txt)
    print("  [OK]   Program.cs parcheado")
else:
    print("  [SKIP] Program.cs ya contiene registros")

print("Listo.")
