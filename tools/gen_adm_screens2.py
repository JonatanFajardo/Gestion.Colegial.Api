"""
Genera las pantallas ADM faltantes que ya tienen endpoint en la API:
  - BoletinAdm       (Notas/BoletinAsync)
  - Ficha360Alumno   (Ficha360Alumno/ResumenAsync)
  - Ficha360Empleado (Ficha360Empleado/ResumenAsync)
  - DocumentosAlumno (DocumentosAlumno/ListAsync + UpdateAsync)
  - ArqueosCaja      (ArqueosCaja/CreateAsync + FindAsync)
  - EstadoCuenta     (EstadoCuenta/FindAsync)
"""
import os, re

ROOT_ADM = r"C:\Users\nayel\OneDrive\Documentos\GitHub\001 Proyectos Estables\Gestion Colegial\GESTION_COLEGIAL_ADM"
BIZ = os.path.join(ROOT_ADM, "GESTION_COLEGIAL.Business")
UI  = os.path.join(ROOT_ADM, "GESTION_COLEGIAL.UI")
UI_CSPROJ  = os.path.join(UI,  "GESTION_COLEGIAL.UI.csproj")
BIZ_CSPROJ = os.path.join(BIZ, "GESTION_COLEGIAL.Business.csproj")

def write(path, content):
    if os.path.exists(path):
        print(f"  [SKIP] {os.path.relpath(path, ROOT_ADM)}")
        return False
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  [OK]   {os.path.relpath(path, ROOT_ADM)}")
    return True

def overwrite(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  [OW]   {os.path.relpath(path, ROOT_ADM)}")

def add_to_csproj(csproj, entries, anchor):
    with open(csproj, encoding="utf-8") as f:
        txt = f.read()
    added = []
    for entry in entries:
        tag = f'<Compile Include="{entry}" />'
        if tag in txt:
            continue
        txt = txt.replace(anchor, tag + "\n    " + anchor, 1)
        added.append(entry)
    if added:
        with open(csproj, "w", encoding="utf-8") as f:
            f.write(txt)
        for e in added: print(f"  [CSPROJ] {e}")

# ─────────────────────────────────────────────────────────────────────────────
# 1. BOLETÍN DE CALIFICACIONES
# ─────────────────────────────────────────────────────────────────────────────
def gen_boletin():
    write(os.path.join(BIZ, "Services", "BoletinAdmService.cs"), """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class BoletinAdmService
    {
        public async Task<List<dynamic>> GetAsync(int Alu_Id, int Sem_Id, int Anio)
            => await SendHttpClient.GetAsync<dynamic>(
                $"Notas/BoletinAsync?Alu_Id={Alu_Id}&Sem_Id={Sem_Id}&Anio={Anio}");
    }
}
""")

    write(os.path.join(UI, "Controllers", "BoletinAdmController.cs"), """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Boletín de calificaciones")]
    public class BoletinAdmController : BaseController
    {
        private readonly BoletinAdmService _service  = new BoletinAdmService();
        private readonly AlumnosService    _alumnos  = new AlumnosService();
        private readonly SemestresService  _semestres = new SemestresService();

        public ActionResult Index() => View();

        public async Task<ActionResult> DropdownsAsync()
        {
            var alumnos  = await _alumnos.ListAsync();
            var semestres = await _semestres.ListAsync();
            return Json(new
            {
                alumnos   = alumnos.Select(a => new { id = a.Alu_Id, texto = a.Alu_Nombre }),
                semestres = semestres.Select(s => new { id = s.Sem_Id, texto = s.Sem_Descripcion })
            }, JsonRequestBehavior.AllowGet);
        }

        public async Task<ActionResult> GetAsync(int Alu_Id, int Sem_Id, int Anio)
        {
            var result = await _service.GetAsync(Alu_Id, Sem_Id, Anio);
            return AjaxResult(result);
        }
    }
}
""")

    os.makedirs(os.path.join(UI, "Views", "BoletinAdm"), exist_ok=True)
    write(os.path.join(UI, "Views", "BoletinAdm", "Index.cshtml"), """\
@{
    ViewBag.Title = "Boletín de Calificaciones";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{ <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" /> }
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Boletín de Calificaciones</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-file-lines" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Boletín de Calificaciones</h1>
                <p>Consulte el boletín completo de notas por alumno y semestre</p>
            </div>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="card mb-3 p-3">
        <div class="row g-2">
            <div class="col-md-4">
                <select id="f-alu" class="form-control"><option value="">-- Seleccione Alumno --</option></select>
            </div>
            <div class="col-md-3">
                <select id="f-sem" class="form-control"><option value="">-- Semestre --</option></select>
            </div>
            <div class="col-md-2">
                <input type="number" id="f-anio" class="form-control" placeholder="Año" value="2025">
            </div>
            <div class="col-md-2">
                <button class="btn btn-primary w-100" id="btn-ver">
                    <i class="fa-solid fa-magnifying-glass"></i> Ver Boletín
                </button>
            </div>
        </div>
    </div>
    <div class="card-listado-catalogo" id="panel-boletin" style="display:none;">
        <div class="card-body-listado-catalogo">
            <div class="table-responsive">
                <table class="table table-striped table-bordered" id="tabla-boletin">
                    <thead>
                        <tr>
                            <th>Materia</th><th>Parcial</th><th>Nota</th><th>Semestre</th>
                        </tr>
                    </thead>
                    <tbody id="tbody-boletin"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/boletinadm.js"></script>
    <script>
        BoletinAdm.init(
            "@Url.Action("GetAsync")",
            "@Url.Action("DropdownsAsync")"
        );
    </script>
}
""")

    write(os.path.join(UI, "Content", "js", "pages", "boletinadm.js"), """\
var BoletinAdm = (function () {
    var obj = {};

    obj.init = function (urlGet, urlDropdowns) {
        $.getJSON(urlDropdowns, function (data) {
            var sa = $("#f-alu"), ss = $("#f-sem");
            $.each(data.alumnos,   function (_, a) { sa.append('<option value="' + a.id + '">' + a.texto + '</option>'); });
            $.each(data.semestres, function (_, s) { ss.append('<option value="' + s.id + '">' + s.texto + '</option>'); });
        });

        $("#btn-ver").on("click", function () {
            var alu  = $("#f-alu").val();
            var sem  = $("#f-sem").val();
            var anio = $("#f-anio").val();
            if (!alu || !sem || !anio) { alert("Complete todos los filtros."); return; }

            $.getJSON(urlGet, { Alu_Id: alu, Sem_Id: sem, Anio: anio }, function (res) {
                var data = res.data || res || [];
                var tbody = $("#tbody-boletin").empty();
                if (!data.length) {
                    tbody.append('<tr><td colspan="4" class="text-center text-muted">Sin notas registradas.</td></tr>');
                } else {
                    $.each(data, function (_, r) {
                        var cls = r.Not_Nota < 60 ? 'text-danger fw-bold' : '';
                        tbody.append('<tr><td>' + r.Mat_Nombre + '</td><td>' + r.Pac_Descripcion +
                            '</td><td class="' + cls + '">' + r.Not_Nota +
                            '</td><td>' + r.Sem_Descripcion + '</td></tr>');
                    });
                }
                $("#panel-boletin").show();
            });
        });
    };

    return obj;
}());
""")


# ─────────────────────────────────────────────────────────────────────────────
# 2. FICHA 360 ALUMNO
# ─────────────────────────────────────────────────────────────────────────────
def gen_ficha360_alumno():
    write(os.path.join(BIZ, "Services", "Ficha360AlumnoAdmService.cs"), """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class Ficha360AlumnoAdmService
    {
        public async Task<dynamic> GetAsync(int Alu_Id)
            => await SendHttpClient.GetSingleAsync<dynamic>($"Ficha360Alumno/ResumenAsync?Alu_Id={Alu_Id}");
    }
}
""")

    write(os.path.join(UI, "Controllers", "Ficha360AlumnoAdmController.cs"), """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Ficha 360 alumno")]
    public class Ficha360AlumnoAdmController : BaseController
    {
        private readonly Ficha360AlumnoAdmService _service = new Ficha360AlumnoAdmService();
        private readonly AlumnosService           _alumnos = new AlumnosService();

        public ActionResult Index() => View();

        public async Task<ActionResult> AlumnosDropdownAsync()
        {
            var list = await _alumnos.ListAsync();
            return Json(
                list.Select(a => new { id = a.Alu_Id, texto = a.Alu_Nombre }),
                JsonRequestBehavior.AllowGet);
        }

        public async Task<ActionResult> GetAsync(int Alu_Id)
        {
            var result = await _service.GetAsync(Alu_Id);
            return AjaxResult(result, true);
        }
    }
}
""")

    os.makedirs(os.path.join(UI, "Views", "Ficha360AlumnoAdm"), exist_ok=True)
    write(os.path.join(UI, "Views", "Ficha360AlumnoAdm", "Index.cshtml"), """\
@{
    ViewBag.Title = "Ficha 360° Alumno";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{ <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" /> }
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Ficha 360° Alumno</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-id-card" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Ficha 360° del Alumno</h1>
                <p>Información académica, financiera y personal del alumno</p>
            </div>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="card mb-3 p-3">
        <div class="row g-2">
            <div class="col-md-6">
                <select id="f-alu" class="form-control"><option value="">-- Seleccione Alumno --</option></select>
            </div>
            <div class="col-md-2">
                <button class="btn btn-primary w-100" id="btn-ver">
                    <i class="fa-solid fa-magnifying-glass"></i> Ver Ficha
                </button>
            </div>
        </div>
    </div>
    <div id="panel-ficha" style="display:none;">
        <div class="row">
            <div class="col-md-4">
                <div class="card p-3 mb-3">
                    <h6 class="fw-bold mb-3"><i class="fa-solid fa-user me-2"></i>Datos Personales</h6>
                    <div id="datos-personales"></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card p-3 mb-3">
                    <h6 class="fw-bold mb-3"><i class="fa-solid fa-graduation-cap me-2"></i>Datos Académicos</h6>
                    <div id="datos-academicos"></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card p-3 mb-3">
                    <h6 class="fw-bold mb-3"><i class="fa-solid fa-dollar-sign me-2"></i>Estado Financiero</h6>
                    <div id="datos-financieros"></div>
                </div>
            </div>
        </div>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/ficha360alumnoadm.js"></script>
    <script>
        Ficha360AlumnoAdm.init(
            "@Url.Action("GetAsync")",
            "@Url.Action("AlumnosDropdownAsync")"
        );
    </script>
}
""")

    write(os.path.join(UI, "Content", "js", "pages", "ficha360alumnoadm.js"), """\
var Ficha360AlumnoAdm = (function () {
    var obj = {};

    function kv(label, val) {
        return '<div class="mb-2"><small class="text-muted">' + label + '</small><div class="fw-semibold">' + (val || '—') + '</div></div>';
    }

    obj.init = function (urlGet, urlDropdown) {
        $.getJSON(urlDropdown, function (data) {
            var sel = $("#f-alu");
            $.each(data, function (_, a) {
                sel.append('<option value="' + a.id + '">' + a.texto + '</option>');
            });
        });

        $("#btn-ver").on("click", function () {
            var id = $("#f-alu").val();
            if (!id) { alert("Seleccione un alumno."); return; }

            $.getJSON(urlGet, { Alu_Id: id }, function (res) {
                var d = res.item || res || {};
                $("#datos-personales").html(
                    kv("Nombre completo", d.Alu_NombreCompleto) +
                    kv("Fecha nacimiento", d.Alu_FechaNacimiento) +
                    kv("Género", d.Alu_Genero) +
                    kv("Encargado", d.Enc_NombreCompleto) +
                    kv("Teléfono encargado", d.Enc_Telefono)
                );
                $("#datos-academicos").html(
                    kv("Sección", d.Sec_Descripcion) +
                    kv("Curso", d.Cur_Nombre) +
                    kv("Nivel", d.Niv_Descripcion) +
                    kv("Año cursado", d.AnioCursado) +
                    kv("Promedio", d.Promedio)
                );
                $("#datos-financieros").html(
                    kv("Saldo pendiente", d.SaldoPendiente) +
                    kv("Último pago", d.UltimoPago) +
                    kv("Estado cuenta", d.EstadoCuenta)
                );
                $("#panel-ficha").show();
            });
        });
    };

    return obj;
}());
""")


# ─────────────────────────────────────────────────────────────────────────────
# 3. FICHA 360 EMPLEADO
# ─────────────────────────────────────────────────────────────────────────────
def gen_ficha360_empleado():
    write(os.path.join(BIZ, "Services", "Ficha360EmpleadoAdmService.cs"), """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class Ficha360EmpleadoAdmService
    {
        public async Task<dynamic> GetAsync(int Emp_Id)
            => await SendHttpClient.GetSingleAsync<dynamic>($"Ficha360Empleado/ResumenAsync?Emp_Id={Emp_Id}");
    }
}
""")

    write(os.path.join(UI, "Controllers", "Ficha360EmpleadoAdmController.cs"), """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Ficha 360 empleado")]
    public class Ficha360EmpleadoAdmController : BaseController
    {
        private readonly Ficha360EmpleadoAdmService _service   = new Ficha360EmpleadoAdmService();
        private readonly EmpleadosService           _empleados = new EmpleadosService();

        public ActionResult Index() => View();

        public async Task<ActionResult> EmpleadosDropdownAsync()
        {
            var list = await _empleados.ListAsync();
            return Json(
                list.Select(e => new { id = e.Emp_Id, texto = e.Emp_Nombre }),
                JsonRequestBehavior.AllowGet);
        }

        public async Task<ActionResult> GetAsync(int Emp_Id)
        {
            var result = await _service.GetAsync(Emp_Id);
            return AjaxResult(result, true);
        }
    }
}
""")

    os.makedirs(os.path.join(UI, "Views", "Ficha360EmpleadoAdm"), exist_ok=True)
    write(os.path.join(UI, "Views", "Ficha360EmpleadoAdm", "Index.cshtml"), """\
@{
    ViewBag.Title = "Ficha 360° Empleado";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{ <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" /> }
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Ficha 360° Empleado</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-user-tie" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Ficha 360° del Empleado</h1>
                <p>Información laboral, académica y contractual del empleado</p>
            </div>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="card mb-3 p-3">
        <div class="row g-2">
            <div class="col-md-6">
                <select id="f-emp" class="form-control"><option value="">-- Seleccione Empleado --</option></select>
            </div>
            <div class="col-md-2">
                <button class="btn btn-primary w-100" id="btn-ver">
                    <i class="fa-solid fa-magnifying-glass"></i> Ver Ficha
                </button>
            </div>
        </div>
    </div>
    <div id="panel-ficha" style="display:none;">
        <div class="row">
            <div class="col-md-4">
                <div class="card p-3 mb-3">
                    <h6 class="fw-bold mb-3"><i class="fa-solid fa-user me-2"></i>Datos Personales</h6>
                    <div id="datos-personales"></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card p-3 mb-3">
                    <h6 class="fw-bold mb-3"><i class="fa-solid fa-briefcase me-2"></i>Datos Laborales</h6>
                    <div id="datos-laborales"></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card p-3 mb-3">
                    <h6 class="fw-bold mb-3"><i class="fa-solid fa-calendar me-2"></i>Historial</h6>
                    <div id="datos-historial"></div>
                </div>
            </div>
        </div>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/ficha360empleadoadm.js"></script>
    <script>
        Ficha360EmpleadoAdm.init(
            "@Url.Action("GetAsync")",
            "@Url.Action("EmpleadosDropdownAsync")"
        );
    </script>
}
""")

    write(os.path.join(UI, "Content", "js", "pages", "ficha360empleadoadm.js"), """\
var Ficha360EmpleadoAdm = (function () {
    var obj = {};

    function kv(label, val) {
        return '<div class="mb-2"><small class="text-muted">' + label + '</small><div class="fw-semibold">' + (val || '—') + '</div></div>';
    }

    obj.init = function (urlGet, urlDropdown) {
        $.getJSON(urlDropdown, function (data) {
            var sel = $("#f-emp");
            $.each(data, function (_, e) {
                sel.append('<option value="' + e.id + '">' + e.texto + '</option>');
            });
        });

        $("#btn-ver").on("click", function () {
            var id = $("#f-emp").val();
            if (!id) { alert("Seleccione un empleado."); return; }

            $.getJSON(urlGet, { Emp_Id: id }, function (res) {
                var d = res.item || res || {};
                $("#datos-personales").html(
                    kv("Nombre completo", d.Emp_NombreCompleto) +
                    kv("Código", d.Emp_Codigo) +
                    kv("Fecha nacimiento", d.Emp_FechaNacimiento) +
                    kv("Género", d.Emp_Genero)
                );
                $("#datos-laborales").html(
                    kv("Cargo", d.Car_Descripcion) +
                    kv("Título", d.Tit_Descripcion) +
                    kv("Fecha ingreso", d.Emp_FechaIngreso) +
                    kv("Antigüedad", d.Antiguedad)
                );
                $("#datos-historial").html(
                    kv("Vacaciones pendientes", d.VacacionesPendientes) +
                    kv("Asistencia mes", d.AsistenciaMes) +
                    kv("Estado", d.Emp_Estado)
                );
                $("#panel-ficha").show();
            });
        });
    };

    return obj;
}());
""")


# ─────────────────────────────────────────────────────────────────────────────
# 4. DOCUMENTOS ALUMNO
# ─────────────────────────────────────────────────────────────────────────────
def gen_documentos_alumno():
    write(os.path.join(BIZ, "Services", "DocumentosAlumnoAdmService.cs"), """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class DocumentosAlumnoAdmService
    {
        public async Task<List<dynamic>> ListAsync(int Alu_Id)
            => await SendHttpClient.GetAsync<dynamic>($"DocumentosAlumno/ListAsync?Alu_Id={Alu_Id}");

        public async Task<List<dynamic>> PendientesAsync()
            => await SendHttpClient.GetAsync<dynamic>("DocumentosAlumno/PendientesAsync");

        public async Task<bool> UpdateAsync(dynamic model)
            => await SendHttpClient.PutAsync("DocumentosAlumno/UpdateAsync", model);
    }
}
""")

    write(os.path.join(UI, "Controllers", "DocumentosAlumnoAdmController.cs"), """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Extensions;
using GESTION_COLEGIAL.UI.Filters;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Documentos alumno")]
    public class DocumentosAlumnoAdmController : BaseController
    {
        private readonly DocumentosAlumnoAdmService _service = new DocumentosAlumnoAdmService();
        private readonly AlumnosService             _alumnos = new AlumnosService();

        public ActionResult Index() => View();

        public async Task<ActionResult> AlumnosDropdownAsync()
        {
            var list = await _alumnos.ListAsync();
            return Json(list.Select(a => new { id = a.Alu_Id, texto = a.Alu_Nombre }),
                JsonRequestBehavior.AllowGet);
        }

        public async Task<ActionResult> ListAsync(int Alu_Id)
        {
            var result = await _service.ListAsync(Alu_Id);
            return AjaxResult(result);
        }

        public async Task<ActionResult> PendientesAsync()
        {
            var result = await _service.PendientesAsync();
            return AjaxResult(result);
        }

        [HttpPost]
        public async Task<ActionResult> UpdateAsync(int Doc_Id, string Doc_Estado, string Doc_Observacion)
        {
            bool err = await _service.UpdateAsync(new { Doc_Id, Doc_Estado, Doc_Observacion, UsuarioModifica = GetUsuarioId() });
            return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessUpdate);
        }
    }
}
""")

    os.makedirs(os.path.join(UI, "Views", "DocumentosAlumnoAdm"), exist_ok=True)
    write(os.path.join(UI, "Views", "DocumentosAlumnoAdm", "Index.cshtml"), """\
@{
    ViewBag.Title = "Documentos del Alumno";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{ <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" /> }
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Documentos del Alumno</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-folder-open" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Documentos del Alumno</h1>
                <p>Gestione los documentos requeridos por alumno</p>
            </div>
        </div>
        <div class="header-action-catalogo">
            <button class="btn btn-outline-warning btn-sm" id="btn-pendientes">
                <i class="fa-solid fa-triangle-exclamation"></i> Ver Pendientes
            </button>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="card mb-3 p-3">
        <div class="row g-2">
            <div class="col-md-6">
                <select id="f-alu" class="form-control"><option value="">-- Seleccione Alumno --</option></select>
            </div>
            <div class="col-md-2">
                <button class="btn btn-primary w-100" id="btn-cargar">
                    <i class="fa-solid fa-magnifying-glass"></i> Cargar
                </button>
            </div>
        </div>
    </div>
    <div class="card-listado-catalogo">
        <div class="card-body-listado-catalogo">
            <div class="table-responsive">
                <table class="table table-striped table-bordered" id="tabla-docs">
                    <thead><tr><th>Documento</th><th>Estado</th><th>Observación</th><th>Acciones</th></tr></thead>
                    <tbody id="tbody-docs"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/documentosalumnoadm.js"></script>
    <script>
        DocumentosAlumnoAdm.init(
            "@Url.Action("ListAsync")",
            "@Url.Action("PendientesAsync")",
            "@Url.Action("UpdateAsync")",
            "@Url.Action("AlumnosDropdownAsync")"
        );
    </script>
}
""")

    write(os.path.join(UI, "Content", "js", "pages", "documentosalumnoadm.js"), """\
var DocumentosAlumnoAdm = (function () {
    var obj = {};
    var urlList, urlPend, urlUpdate;

    obj.init = function (ul, up, uu, urlDD) {
        urlList = ul; urlPend = up; urlUpdate = uu;

        $.getJSON(urlDD, function (data) {
            var sel = $("#f-alu");
            $.each(data, function (_, a) { sel.append('<option value="' + a.id + '">' + a.texto + '</option>'); });
        });

        $("#btn-cargar").on("click", function () {
            var id = $("#f-alu").val();
            if (!id) { alert("Seleccione un alumno."); return; }
            cargar(urlList + "?Alu_Id=" + id);
        });

        $("#btn-pendientes").on("click", function () { cargar(urlPend); });

        $(document).on("click", ".btn-actualizar", function () {
            var tr  = $(this).closest("tr");
            var id  = tr.data("id");
            var est = tr.find(".sel-estado").val();
            var obs = tr.find(".txt-obs").val();
            $.post(urlUpdate, { Doc_Id: id, Doc_Estado: est, Doc_Observacion: obs }, function (res) {
                if (res && res.success) $(this).text("✓").removeClass("btn-warning").addClass("btn-secondary");
            }.bind(this));
        });
    };

    function cargar(url) {
        $.getJSON(url, function (res) {
            var data = res.data || res || [];
            var tbody = $("#tbody-docs").empty();
            if (!data.length) {
                tbody.append('<tr><td colspan="4" class="text-center text-muted">Sin documentos.</td></tr>');
                return;
            }
            $.each(data, function (_, r) {
                var estados = ["Pendiente","Entregado","Rechazado"].map(function(e) {
                    return '<option' + (r.Doc_Estado === e ? ' selected' : '') + '>' + e + '</option>';
                }).join("");
                tbody.append('<tr data-id="' + r.Doc_Id + '">' +
                    '<td>' + r.Doc_Nombre + '</td>' +
                    '<td><select class="form-control sel-estado">' + estados + '</select></td>' +
                    '<td><input class="form-control txt-obs" value="' + (r.Doc_Observacion || '') + '"></td>' +
                    '<td><button class="btn btn-sm btn-warning btn-actualizar">Guardar</button></td></tr>');
            });
        });
    }

    return obj;
}());
""")


# ─────────────────────────────────────────────────────────────────────────────
# 5. ARQUEO DE CAJA
# ─────────────────────────────────────────────────────────────────────────────
def gen_arqueo_caja():
    write(os.path.join(BIZ, "Services", "ArqueosCajaAdmService.cs"), """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class ArqueosCajaAdmService
    {
        public async Task<dynamic> LastAsync(int Usu_Id)
            => await SendHttpClient.GetSingleAsync<dynamic>($"ArqueosCaja/LastByUsuarioAsync?Usu_Id={Usu_Id}");

        public async Task<bool> CreateAsync(dynamic model)
            => await SendHttpClient.PostAsync("ArqueosCaja/CreateAsync", model);
    }
}
""")

    write(os.path.join(UI, "Controllers", "ArqueosCajaAdmController.cs"), """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Extensions;
using GESTION_COLEGIAL.UI.Filters;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Arqueo de caja")]
    public class ArqueosCajaAdmController : BaseController
    {
        private readonly ArqueosCajaAdmService _service = new ArqueosCajaAdmService();

        public ActionResult Index() => View();

        public async Task<ActionResult> LastAsync()
        {
            var result = await _service.LastAsync(GetUsuarioId());
            return AjaxResult(result, true);
        }

        [HttpPost]
        public async Task<ActionResult> CreateAsync(decimal Arq_MontoInicial, decimal Arq_MontoFinal,
            decimal Arq_TotalEfectivo, decimal Arq_TotalTarjeta, string Arq_Observacion)
        {
            bool err = await _service.CreateAsync(new {
                Arq_MontoInicial, Arq_MontoFinal, Arq_TotalEfectivo,
                Arq_TotalTarjeta, Arq_Observacion, UsuarioRegistra = GetUsuarioId()
            });
            return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessInsert);
        }
    }
}
""")

    os.makedirs(os.path.join(UI, "Views", "ArqueosCajaAdm"), exist_ok=True)
    write(os.path.join(UI, "Views", "ArqueosCajaAdm", "Index.cshtml"), """\
@{
    ViewBag.Title = "Arqueo de Caja";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{ <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" /> <link href="~/Content/css/modal-catalogos.css" rel="stylesheet" /> }
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Arqueo de Caja</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-scale-balanced" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Arqueo de Caja</h1>
                <p>Registre el cierre y arqueo de caja del turno actual</p>
            </div>
        </div>
        <div class="header-action-catalogo">
            <button class="btn-nuevo-catalogo" data-toggle="modal" data-target="#modal-arqueo">
                <i class="mdi mdi-plus-circle-outline"></i> Nuevo Arqueo
            </button>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="row">
        <div class="col-md-6">
            <div class="card p-4" id="panel-ultimo" style="display:none;">
                <h5 class="fw-bold mb-3">Último Arqueo</h5>
                <div id="info-arqueo"></div>
            </div>
            <div class="card p-4 text-center text-muted" id="panel-sin-arqueo">
                <i class="fa-solid fa-scale-balanced fa-3x mb-3 opacity-25"></i>
                <p>No hay arqueos registrados. Cree el primero.</p>
            </div>
        </div>
    </div>
</div>
<!-- Modal Nuevo Arqueo -->
<div class="modal fade" id="modal-arqueo" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content modal-content-catalogo">
            <div class="modal-header-catalogo">
                <div><h5 class="modal-title-catalogo">Nuevo Arqueo de Caja</h5></div>
                <button type="button" class="close close-catalogo" data-dismiss="modal">&times;</button>
            </div>
            <form id="form-arqueo">
                <div class="modal-body-catalogo">
                    <div class="form-card-catalogo">
                        <div class="row">
                            <div class="col-md-6 form-group-catalogo">
                                <label class="form-label-catalogo">Monto Inicial *</label>
                                <input type="number" step="0.01" name="Arq_MontoInicial" class="form-control form-input-catalogo" value="0">
                            </div>
                            <div class="col-md-6 form-group-catalogo">
                                <label class="form-label-catalogo">Monto Final *</label>
                                <input type="number" step="0.01" name="Arq_MontoFinal" class="form-control form-input-catalogo" value="0">
                            </div>
                            <div class="col-md-6 form-group-catalogo">
                                <label class="form-label-catalogo">Total Efectivo *</label>
                                <input type="number" step="0.01" name="Arq_TotalEfectivo" class="form-control form-input-catalogo" value="0">
                            </div>
                            <div class="col-md-6 form-group-catalogo">
                                <label class="form-label-catalogo">Total Tarjeta *</label>
                                <input type="number" step="0.01" name="Arq_TotalTarjeta" class="form-control form-input-catalogo" value="0">
                            </div>
                            <div class="col-md-12 form-group-catalogo">
                                <label class="form-label-catalogo">Observación</label>
                                <textarea name="Arq_Observacion" class="form-control form-input-catalogo" rows="2"></textarea>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer-catalogo">
                    <button type="button" class="btn-cancel-catalogo" data-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn-save-catalogo">Guardar Arqueo</button>
                </div>
            </form>
        </div>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/arqueosCajaAdm.js"></script>
    <script>
        ArqueosCajaAdm.init(
            "@Url.Action("LastAsync")",
            "@Url.Action("CreateAsync")"
        );
    </script>
}
""")

    write(os.path.join(UI, "Content", "js", "pages", "arqueosCajaAdm.js"), """\
var ArqueosCajaAdm = (function () {
    var obj = {};

    function kv(label, val) {
        return '<div class="row mb-2"><div class="col-5 text-muted small">' + label + '</div>' +
               '<div class="col-7 fw-semibold">' + (val !== undefined && val !== null ? val : '—') + '</div></div>';
    }

    obj.init = function (urlLast, urlCreate) {
        $.getJSON(urlLast, function (res) {
            var d = res.item || res;
            if (d && d.Arq_Id) {
                $("#info-arqueo").html(
                    kv("Fecha", d.Arq_Fecha) +
                    kv("Monto Inicial", "Q " + d.Arq_MontoInicial) +
                    kv("Monto Final",   "Q " + d.Arq_MontoFinal) +
                    kv("Total Efectivo","Q " + d.Arq_TotalEfectivo) +
                    kv("Total Tarjeta", "Q " + d.Arq_TotalTarjeta) +
                    kv("Observación",   d.Arq_Observacion)
                );
                $("#panel-ultimo").show();
                $("#panel-sin-arqueo").hide();
            }
        });

        $("#form-arqueo").on("submit", function (e) {
            e.preventDefault();
            $.post(urlCreate, $(this).serialize(), function (res) {
                if (res && res.success) {
                    $("#modal-arqueo").modal("hide");
                    location.reload();
                }
            });
        });
    };

    return obj;
}());
""")


# ─────────────────────────────────────────────────────────────────────────────
# 6. ESTADO DE CUENTA
# ─────────────────────────────────────────────────────────────────────────────
def gen_estado_cuenta():
    write(os.path.join(BIZ, "Services", "EstadoCuentaAdmService.cs"), """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class EstadoCuentaAdmService
    {
        public async Task<dynamic> GetAsync(int Alu_Id, int? Anio = null)
        {
            string url = $"EstadoCuenta/FindAsync?Alu_Id={Alu_Id}";
            if (Anio.HasValue) url += $"&Anio={Anio}";
            return await SendHttpClient.GetSingleAsync<dynamic>(url);
        }
    }
}
""")

    write(os.path.join(UI, "Controllers", "EstadoCuentaAdmController.cs"), """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Estado de cuenta alumno")]
    public class EstadoCuentaAdmController : BaseController
    {
        private readonly EstadoCuentaAdmService _service = new EstadoCuentaAdmService();
        private readonly AlumnosService         _alumnos = new AlumnosService();

        public ActionResult Index() => View();

        public async Task<ActionResult> AlumnosDropdownAsync()
        {
            var list = await _alumnos.ListAsync();
            return Json(list.Select(a => new { id = a.Alu_Id, texto = a.Alu_Nombre }),
                JsonRequestBehavior.AllowGet);
        }

        public async Task<ActionResult> GetAsync(int Alu_Id, int? Anio = null)
        {
            var result = await _service.GetAsync(Alu_Id, Anio);
            return AjaxResult(result, true);
        }
    }
}
""")

    os.makedirs(os.path.join(UI, "Views", "EstadoCuentaAdm"), exist_ok=True)
    write(os.path.join(UI, "Views", "EstadoCuentaAdm", "Index.cshtml"), """\
@{
    ViewBag.Title = "Estado de Cuenta";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{ <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" /> }
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Estado de Cuenta</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-file-invoice-dollar" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Estado de Cuenta del Alumno</h1>
                <p>Consulte saldos, pagos y cuentas por cobrar</p>
            </div>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="card mb-3 p-3">
        <div class="row g-2">
            <div class="col-md-5">
                <select id="f-alu" class="form-control"><option value="">-- Seleccione Alumno --</option></select>
            </div>
            <div class="col-md-2">
                <input type="number" id="f-anio" class="form-control" placeholder="Año (opcional)">
            </div>
            <div class="col-md-2">
                <button class="btn btn-primary w-100" id="btn-ver">
                    <i class="fa-solid fa-magnifying-glass"></i> Consultar
                </button>
            </div>
        </div>
    </div>
    <div id="panel-estado" style="display:none;">
        <div class="row mb-3">
            <div class="col-md-3">
                <div class="card text-center p-3">
                    <div class="text-muted small">Total Cobrado</div>
                    <div class="fs-4 fw-bold text-success" id="kpi-cobrado">—</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center p-3">
                    <div class="text-muted small">Total Pendiente</div>
                    <div class="fs-4 fw-bold text-danger" id="kpi-pendiente">—</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center p-3">
                    <div class="text-muted small">Descuentos</div>
                    <div class="fs-4 fw-bold text-info" id="kpi-descuento">—</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center p-3">
                    <div class="text-muted small">Cuotas Pendientes</div>
                    <div class="fs-4 fw-bold text-warning" id="kpi-cuotas">—</div>
                </div>
            </div>
        </div>
        <div class="card-listado-catalogo">
            <div class="card-body-listado-catalogo">
                <h6 class="fw-bold mb-2">Detalle de Cuentas</h6>
                <div class="table-responsive">
                    <table class="table table-sm table-striped" id="tabla-cuentas">
                        <thead><tr><th>Concepto</th><th>Monto</th><th>Pagado</th><th>Saldo</th><th>Vencimiento</th><th>Estado</th></tr></thead>
                        <tbody id="tbody-cuentas"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/estadocuentaadm.js"></script>
    <script>
        EstadoCuentaAdm.init(
            "@Url.Action("GetAsync")",
            "@Url.Action("AlumnosDropdownAsync")"
        );
    </script>
}
""")

    write(os.path.join(UI, "Content", "js", "pages", "estadocuentaadm.js"), """\
var EstadoCuentaAdm = (function () {
    var obj = {};

    obj.init = function (urlGet, urlDD) {
        $.getJSON(urlDD, function (data) {
            var sel = $("#f-alu");
            $.each(data, function (_, a) { sel.append('<option value="' + a.id + '">' + a.texto + '</option>'); });
        });

        $("#btn-ver").on("click", function () {
            var id   = $("#f-alu").val();
            var anio = $("#f-anio").val();
            if (!id) { alert("Seleccione un alumno."); return; }
            var params = { Alu_Id: id };
            if (anio) params.Anio = anio;

            $.getJSON(urlGet, params, function (res) {
                var d = res.item || res || {};
                $("#kpi-cobrado").text("Q " + (d.TotalCobrado   || "0.00"));
                $("#kpi-pendiente").text("Q " + (d.TotalPendiente || "0.00"));
                $("#kpi-descuento").text("Q " + (d.TotalDescuento || "0.00"));
                $("#kpi-cuotas").text(d.CuotasPendientes || "0");

                var tbody = $("#tbody-cuentas").empty();
                var cuentas = d.Cuentas || d.detalle || [];
                if (!cuentas.length) {
                    tbody.append('<tr><td colspan="6" class="text-center text-muted">Sin cuentas registradas.</td></tr>');
                } else {
                    $.each(cuentas, function (_, c) {
                        var cls = c.Cue_Saldo > 0 ? 'text-danger' : 'text-success';
                        tbody.append('<tr><td>' + c.Con_Descripcion + '</td>' +
                            '<td>Q ' + c.Cue_Monto + '</td>' +
                            '<td>Q ' + c.Cue_Pagado + '</td>' +
                            '<td class="' + cls + '">Q ' + c.Cue_Saldo + '</td>' +
                            '<td>' + (c.Cue_FechaVence || '—') + '</td>' +
                            '<td>' + (c.Est_Descripcion || '—') + '</td></tr>');
                    });
                }
                $("#panel-estado").show();
            });
        });
    };

    return obj;
}());
""")


# ─────────────────────────────────────────────────────────────────────────────
# PATCH csproj
# ─────────────────────────────────────────────────────────────────────────────
def patch_csproj():
    ui_controllers = [
        r"Controllers\BoletinAdmController.cs",
        r"Controllers\Ficha360AlumnoAdmController.cs",
        r"Controllers\Ficha360EmpleadoAdmController.cs",
        r"Controllers\DocumentosAlumnoAdmController.cs",
        r"Controllers\ArqueosCajaAdmController.cs",
        r"Controllers\EstadoCuentaAdmController.cs",
    ]
    biz_services = [
        r"Services\BoletinAdmService.cs",
        r"Services\Ficha360AlumnoAdmService.cs",
        r"Services\Ficha360EmpleadoAdmService.cs",
        r"Services\DocumentosAlumnoAdmService.cs",
        r"Services\ArqueosCajaAdmService.cs",
        r"Services\EstadoCuentaAdmService.cs",
    ]
    add_to_csproj(UI_CSPROJ,  ui_controllers,
                  anchor='<Compile Include="Controllers\\AlumnosController.cs" />')
    add_to_csproj(BIZ_CSPROJ, biz_services,
                  anchor='<Compile Include="Services\\AccountService.cs" />')


# ─────────────────────────────────────────────────────────────────────────────
# PATCH sidebar
# ─────────────────────────────────────────────────────────────────────────────
def patch_sidebar():
    sidebar = os.path.join(UI, "Views", "Shared", "_sidebar.cshtml")
    with open(sidebar, encoding="utf-8") as f:
        txt = f.read()

    new_items = ""
    if 'Ficha360AlumnoAdm' not in txt:
        new_items += """
            @if (tiene("Ficha 360 alumno"))
            {
                <li class="menu">
                    <a href="#Fichas" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle">
                        <div class="h6">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-credit-card nav-icon"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>
                            <span>Fichas 360°</span>
                        </div>
                        <div><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-chevron-right"><polyline points="9 18 15 12 9 6"></polyline></svg></div>
                    </a>
                    <ul class="collapse submenu list-unstyled" id="Fichas" data-parent="#accordionExample">
                        @if (tiene("Ficha 360 alumno"))    { <li>@Html.ActionLink("Ficha Alumno",   "Index", "Ficha360AlumnoAdm")</li> }
                        @if (tiene("Ficha 360 empleado"))  { <li>@Html.ActionLink("Ficha Empleado", "Index", "Ficha360EmpleadoAdm")</li> }
                    </ul>
                </li>
            }
"""

    # Inject after Alumnos section
    if new_items and 'Ficha360AlumnoAdm' not in txt:
        txt = txt.replace(
            '@if (tiene("Listado de empleados"))',
            new_items + '\n            @if (tiene("Listado de empleados"))', 1)

    # Add Boletín to Académico section
    if 'BoletinAdm' not in txt:
        txt = txt.replace(
            '@if (tiene("Cuaderno de notas"))\n                        {\n                            <li>@Html.ActionLink("Cuaderno de Notas"',
            '@if (tiene("Boletín de calificaciones")) { <li>@Html.ActionLink("Boletín", "Index", "BoletinAdm")</li> }\n                        @if (tiene("Cuaderno de notas"))\n                        {\n                            <li>@Html.ActionLink("Cuaderno de Notas"')

    # Add Documentos Alumno to Alumnos section (if exists)
    if 'DocumentosAlumnoAdm' not in txt:
        txt = txt.replace(
            '@if (tiene("Listado de parentescos"))\n                        {\n                            <li>@Html.ActionLink("Parentescos"',
            '@if (tiene("Documentos alumno"))   { <li>@Html.ActionLink("Documentos", "Index", "DocumentosAlumnoAdm")</li> }\n                        @if (tiene("Listado de parentescos"))\n                        {\n                            <li>@Html.ActionLink("Parentescos"')

    # Add Estado de Cuenta + Arqueo to Financiero section
    if 'EstadoCuentaAdm' not in txt:
        txt = txt.replace(
            '@if (tiene("Guia financiera"))',
            '@if (tiene("Estado de cuenta alumno")) { <li>@Html.ActionLink("Estado de Cuenta",  "Index", "EstadoCuentaAdm")</li> }\n                        @if (tiene("Arqueo de caja"))            { <li>@Html.ActionLink("Arqueo de Caja",     "Index", "ArqueosCajaAdm")</li> }\n                        @if (tiene("Guia financiera"))')

    with open(sidebar, "w", encoding="utf-8") as f:
        f.write(txt)
    print("  [OK]   _sidebar.cshtml parcheado")


# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("\n=== Boletín de Calificaciones ===")
    gen_boletin()

    print("\n=== Ficha 360° Alumno ===")
    gen_ficha360_alumno()

    print("\n=== Ficha 360° Empleado ===")
    gen_ficha360_empleado()

    print("\n=== Documentos del Alumno ===")
    gen_documentos_alumno()

    print("\n=== Arqueo de Caja ===")
    gen_arqueo_caja()

    print("\n=== Estado de Cuenta ===")
    gen_estado_cuenta()

    print("\n=== Parchando csproj ===")
    patch_csproj()

    print("\n=== Parchando sidebar ===")
    patch_sidebar()

    print("\n=== COMPLETO ===")
