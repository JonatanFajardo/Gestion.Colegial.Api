"""
Genera pantallas MVC para GESTION_COLEGIAL_ADM.
Cubre: Dashboards (8), Reportes (5), CRUD Horarios, Bitácora,
       Asistencia, Notas, Vacaciones, ArqueosCaja, Ficha360Alumno, Ficha360Empleado.
"""
import os

ROOT_ADM = r"C:\Users\nayel\OneDrive\Documentos\GitHub\001 Proyectos Estables\Gestion Colegial\GESTION_COLEGIAL_ADM"
BIZ = os.path.join(ROOT_ADM, "GESTION_COLEGIAL.Business")
UI  = os.path.join(ROOT_ADM, "GESTION_COLEGIAL.UI")

def write(path, content):
    if os.path.exists(path):
        print(f"  [SKIP] {os.path.relpath(path, ROOT_ADM)}")
        return
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  [OK]   {os.path.relpath(path, ROOT_ADM)}")

# ─────────────────────────────────────────────────────────────────────────────
# DASHBOARDS
# ─────────────────────────────────────────────────────────────────────────────
DASHBOARDS = [
    dict(name="DashboardAdmin",       title="Dashboard Administrador",      icon="fa-shield-halved",   role="Administrador",
         kpis=[("Total Usuarios","totalUsuarios","purple","fa-users"),("Accesos Hoy","accesosHoy","blue","fa-right-to-bracket"),("Roles Activos","rolesActivos","green","fa-user-tag"),("Alertas Sistema","alertasSistema","orange","fa-triangle-exclamation")]),
    dict(name="DashboardDirector",    title="Dashboard Director",           icon="fa-chart-line",      role="Director",
         kpis=[("Alumnos Activos","alumnosActivos","blue","fa-user-graduate"),("Docentes","docentes","green","fa-chalkboard-user"),("Promedio General","promedioGeneral","orange","fa-star"),("Asistencia Hoy","asistenciaHoy","purple","fa-calendar-check")]),
    dict(name="DashboardDocente",     title="Dashboard Docente",            icon="fa-chalkboard-user", role="Docente",
         kpis=[("Clases Hoy","clasesHoy","blue","fa-book-open"),("Alumnos","alumnosTotal","green","fa-users"),("Tareas Pendientes","tareasPendientes","orange","fa-clipboard-list"),("Promedio Sección","promedioSeccion","purple","fa-star-half-stroke")]),
    dict(name="DashboardSecretaria",  title="Dashboard Secretaría",         icon="fa-envelope-open-text", role="Secretaria",
         kpis=[("Trámites Hoy","tramitesHoy","blue","fa-file-pen"),("Docs Pendientes","docsPendientes","orange","fa-folder-open"),("Matrículas Mes","matriculasMes","green","fa-id-card"),("Mensajes","mensajes","purple","fa-comments")]),
    dict(name="DashboardRRHH",        title="Dashboard Recursos Humanos",   icon="fa-people-group",    role="RRHH",
         kpis=[("Empleados Activos","empleadosActivos","blue","fa-briefcase"),("Vacaciones Pendientes","vacacionesPendientes","orange","fa-umbrella-beach"),("Cumpleaños Mes","cumpleanosMes","green","fa-cake-candles"),("Ausencias Hoy","ausenciasHoy","purple","fa-user-clock")]),
    dict(name="DashboardCajero",      title="Dashboard Caja",               icon="fa-cash-register",   role="Cajero",
         kpis=[("Cobros Hoy","cobrosHoy","green","fa-money-bill-wave"),("Monto del Día","montoDia","blue","fa-dollar-sign"),("Pendientes","pendientes","orange","fa-hourglass-half"),("Último Arqueo","ultimoArqueo","purple","fa-scale-balanced")]),
    dict(name="DashboardFinanciero",  title="Dashboard Financiero",         icon="fa-chart-pie",       role="Financiero",
         kpis=[("Ingresos Mes","ingresosMes","green","fa-arrow-trend-up"),("Morosidad","morosidad","orange","fa-arrow-trend-down"),("Cuentas por Cobrar","cuentasCobrar","blue","fa-file-invoice-dollar"),("Proyección","proyeccion","purple","fa-chart-area")]),
    dict(name="DashboardConsulta",    title="Dashboard Consultas",          icon="fa-magnifying-glass-chart", role="Consulta",
         kpis=[("Total Alumnos","totalAlumnos","blue","fa-user-graduate"),("Secciones Activas","seccionesActivas","green","fa-door-open"),("Docentes","docentes","orange","fa-chalkboard-user"),("Promedio Inst.","promedioInstitucional","purple","fa-star")]),
]

def gen_dashboard(d):
    name = d["name"]
    title = d["title"]
    icon = d["icon"]
    kpis = d["kpis"]

    # ── Service ────────────────────────────────────────────────────────────────
    svc = f"""\
using GESTION_COLEGIAL.Business.Helpers;
using Newtonsoft.Json;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{{
    public class {name}Service
    {{
        public async Task<dynamic> Resumen()
        {{
            string url = "{name}/ResumenAsync";
            return await SendHttpClient.GetSingleAsync<dynamic>(url);
        }}
    }}
}}
"""
    write(os.path.join(BIZ, "Services", f"{name}Service.cs"), svc)

    # ── Controller ─────────────────────────────────────────────────────────────
    ctrl = f"""\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{{
    [SessionManager("{title}")]
    public class {name}Controller : BaseController
    {{
        private readonly {name}Service _service = new {name}Service();

        public ActionResult Index() => View();

        public async Task<ActionResult> ResumenAsync()
        {{
            var result = await _service.Resumen();
            return AjaxResult(result, true);
        }}
    }}
}}
"""
    write(os.path.join(UI, "Controllers", f"{name}Controller.cs"), ctrl)

    # ── Cards HTML ─────────────────────────────────────────────────────────────
    cards_html = ""
    for label, field, color, ico in kpis:
        cards_html += f"""\
        <div class="stat-card-modern">
            <div class="stat-header-modern">
                <div class="stat-icon-modern {color}">
                    <i class="fa-solid {ico}"></i>
                </div>
            </div>
            <div class="stat-label-modern">{label}</div>
            <div class="stat-value-modern" id="kpi-{field}">—</div>
        </div>
"""

    # ── View ───────────────────────────────────────────────────────────────────
    view = f"""\
@{{
    ViewBag.Title = "{title}";
    Layout = "~/Views/Shared/_Layout.cshtml";
}}

<link rel="stylesheet" href="~/Content/css/pages/home-modern.css">

<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">{title}</li>
        </ol>
    </nav>
</div>

<div class="home-content-wrapper">
    <div class="welcome-card-modern">
        <div class="welcome-content-modern">
            <h1>{title}</h1>
            <p class="welcome-text-modern">Resumen en tiempo real</p>
        </div>
        <div class="welcome-decoration-modern">
            <i class="fa-solid {icon}" style="font-size:64px;opacity:.3;"></i>
        </div>
    </div>

    <div class="stats-grid-modern">
{cards_html}    </div>

    <div id="dashboard-detail" class="mt-4"></div>
</div>

@section Scripts{{
    <script src="~/Content/js/pages/{name.lower()}.js"></script>
    <script>
        {name}.init("@Url.Action("ResumenAsync")");
    </script>
}}
"""
    os.makedirs(os.path.join(UI, "Views", name), exist_ok=True)
    write(os.path.join(UI, "Views", name, "Index.cshtml"), view)

    # ── JS ─────────────────────────────────────────────────────────────────────
    set_kpis = ""
    for label, field, color, ico in kpis:
        set_kpis += f'        if (d.{field} !== undefined) document.getElementById("kpi-{field}").textContent = d.{field};\n'

    js = f"""\
var {name} = (function () {{
    var obj = {{}};

    obj.init = function (url) {{
        $.getJSON(url, function (res) {{
            var d = res || {{}};
{set_kpis}        }}).fail(function () {{
            console.warn("{name}: no se pudo cargar el resumen.");
        }});
    }};

    return obj;
}}());
"""
    write(os.path.join(UI, "Content", "js", "pages", f"{name.lower()}.js"), js)


# ─────────────────────────────────────────────────────────────────────────────
# REPORTES (read-only DataTable)
# ─────────────────────────────────────────────────────────────────────────────
REPORTS = [
    dict(
        name="AgingCuentas", title="Aging de Cuentas por Cobrar",
        icon="fa-clock-rotate-left", api_action="ListAsync",
        columns=[("Alu_NombreCompleto","Alumno"),("Tramo","Tramo"),("Total","Monto"),("Cantidad","Cantidad")],
        params=[], description="Antigüedad de saldos pendientes por cobrar",
    ),
    dict(
        name="TopDeudores", title="Top Alumnos con Deuda",
        icon="fa-ranking-star", api_action="ListAsync",
        columns=[("Alu_NombreCompleto","Alumno"),("TotalDeuda","Deuda Total"),("CantCuotas","Cuotas")],
        params=[], description="Alumnos con mayor deuda acumulada",
    ),
    dict(
        name="MorosidadPorNivel", title="Morosidad por Nivel",
        icon="fa-chart-bar", api_action="ListAsync",
        columns=[("Niv_Descripcion","Nivel"),("TotalAlumnos","Alumnos"),("MontoPendiente","Pendiente")],
        params=[], description="Morosidad agrupada por nivel educativo",
    ),
    dict(
        name="EmpleadosAntiguedad", title="Reporte de Antigüedad",
        icon="fa-award", api_action="ListAsync",
        columns=[("Emp_NombreCompleto","Empleado"),("Cargo","Cargo"),("FechaIngreso","Ingreso"),("Anos","Años")],
        params=[], description="Antigüedad laboral de empleados",
    ),
    dict(
        name="AlumnosEnRiesgo", title="Alumnos en Riesgo Académico",
        icon="fa-triangle-exclamation", api_action="ListAsync",
        columns=[("Alu_NombreCompleto","Alumno"),("Sec_Descripcion","Sección"),("Promedio","Promedio")],
        params=[("PromedioMinimo","Promedio mínimo","number","60"),("Anio","Año","number","")],
        description="Alumnos con promedio por debajo del umbral",
    ),
    dict(
        name="AlumnosBusqueda", title="Búsqueda de Alumnos",
        icon="fa-magnifying-glass", api_action="SearchAsync",
        columns=[("Alu_NombreCompleto","Alumno"),("Sec_Descripcion","Sección"),("Cur_Nombre","Curso")],
        params=[("Termino","Buscar alumno...","text","")],
        description="Búsqueda global de alumnos",
    ),
]

def gen_report(r):
    name = r["name"]
    title = r["title"]
    icon = r["icon"]
    api_action = r["api_action"]
    columns = r["columns"]
    params = r["params"]
    desc = r["description"]

    # Params for service call
    param_args   = ", ".join(f"string {p[0]} = null" for p in params)
    param_qs     = "&".join(f"{p[0]}=' + encodeURIComponent({p[0]} || '') + '" for p in params)
    param_csharp = ", ".join(f"string {p[0]} = null" for p in params)
    qs_build     = " + '?" + param_qs + "'" if params else ""

    svc = f"""\
using GESTION_COLEGIAL.Business.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{{
    public class {name}Service
    {{
        public async Task<List<dynamic>> ListAsync({param_csharp})
        {{
            string qs = string.Empty;
"""
    if params:
        qs_lines = []
        for p in params:
            qs_lines.append(f'            if ({p[0]} != null) qs += $"&{p[0]}={{{p[0]}}}";')
        svc += "\n".join(qs_lines) + "\n"
    svc += f"""\
            string url = "{name}/{api_action}" + (qs.Length > 0 ? "?" + qs.TrimStart('&') : "");
            return await SendHttpClient.GetAsync<dynamic>(url);
        }}
    }}
}}
"""
    write(os.path.join(BIZ, "Services", f"{name}Service.cs"), svc)

    # Params for controller action
    ctrl_params = ", ".join(f"string {p[0]} = null" for p in params)
    ctrl = f"""\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{{
    [SessionManager("{title}")]
    public class {name}Controller : BaseController
    {{
        private readonly {name}Service _service = new {name}Service();

        public ActionResult Index() => View();

        public async Task<ActionResult> ListAsync({ctrl_params})
        {{
            var result = await _service.ListAsync({", ".join(p[0] for p in params)});
            return AjaxResult(result);
        }}
    }}
}}
"""
    write(os.path.join(UI, "Controllers", f"{name}Controller.cs"), ctrl)

    # Filter inputs HTML
    filter_html = ""
    for p in params:
        filter_html += f"""\
            <div class="col-md-3">
                <input type="{p[2]}" id="filter-{p[0]}" class="form-control" placeholder="{p[1]}" value="{p[3]}">
            </div>
"""
    filter_row = ""
    if params:
        filter_row = f"""\
    <div class="row mb-3">
{filter_html}        <div class="col-md-2">
            <button class="btn btn-primary btn-sm w-100" id="btn-filtrar">
                <i class="fa-solid fa-filter"></i> Filtrar
            </button>
        </div>
    </div>
"""

    # Table headers
    ths = "".join(f"<th>{c[1]}</th>" for c in columns)

    view = f"""\
@{{
    ViewBag.Title = "{title}";
    Layout = "~/Views/Shared/_Layout.cshtml";
}}

@section Styles{{
    <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" />
}}

<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">{title}</li>
        </ol>
    </nav>
</div>

<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo">
                <i class="fa-solid {icon}" style="font-size:32px;"></i>
            </div>
            <div class="header-text-catalogo">
                <h1>{title}</h1>
                <p>{desc}</p>
            </div>
        </div>
    </div>
</div>

<div class="fluid-container">
{filter_row}    <div class="card-listado-catalogo">
        <div class="card-body-listado-catalogo">
            <div class="table-responsive">
                <table class="table table-striped table-bordered nowrap" id="datatable-{name.lower()}">
                    <thead><tr>{ths}</tr></thead>
                </table>
            </div>
        </div>
    </div>
</div>

@section Scripts{{
    <script src="~/Content/js/pages/{name.lower()}.js"></script>
    <script>
        {name}.init("@Url.Action("ListAsync")");
    </script>
}}
"""
    os.makedirs(os.path.join(UI, "Views", name), exist_ok=True)
    write(os.path.join(UI, "Views", name, "Index.cshtml"), view)

    # JS columns
    col_defs = ",\n            ".join(f'{{ data: "{c[0]}", title: "{c[1]}" }}' for c in columns)
    # Param reads
    param_reads = ""
    for p in params:
        param_reads += f'        var {p[0]} = $("#filter-{p[0]}").val();\n'
    reload_logic = "        table.ajax.reload();" if params else ""

    js = f"""\
var {name} = (function () {{
    var obj = {{}};
    var table;

    obj.init = function (url) {{
        table = $("#datatable-{name.lower()}").DataTable({{
            ajax: {{ url: url, dataSrc: "" }},
            columns: [
            {col_defs}
            ],
            language: {{ url: "//cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json" }},
            responsive: true,
            pageLength: 25
        }});

        $("#btn-filtrar").on("click", function () {{
{param_reads}{reload_logic}
        }});
    }};

    return obj;
}}());
"""
    write(os.path.join(UI, "Content", "js", "pages", f"{name.lower()}.js"), js)


# ─────────────────────────────────────────────────────────────────────────────
# BITÁCORA (read-only list, special)
# ─────────────────────────────────────────────────────────────────────────────
def gen_bitacora():
    name = "Bitacora"

    svc = """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class BitacoraService
    {
        public async Task<List<dynamic>> ListAsync(string Usu_Id = null, string Bit_Tabla = null, string Top = null)
        {
            string qs = string.Empty;
            if (Usu_Id   != null) qs += $"&Usu_Id={Usu_Id}";
            if (Bit_Tabla!= null) qs += $"&Bit_Tabla={Bit_Tabla}";
            if (Top      != null) qs += $"&Top={Top}";
            string url = "Bitacora/ListAsync" + (qs.Length > 0 ? "?" + qs.TrimStart('&') : "");
            return await SendHttpClient.GetAsync<dynamic>(url);
        }
    }
}
"""
    write(os.path.join(BIZ, "Services", "BitacoraService.cs"), svc)

    ctrl = """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Bitácora de actividad")]
    public class BitacoraController : BaseController
    {
        private readonly BitacoraService _service = new BitacoraService();

        public ActionResult Index() => View();

        public async Task<ActionResult> ListAsync(string Usu_Id = null, string Bit_Tabla = null, string Top = null)
        {
            var result = await _service.ListAsync(Usu_Id, Bit_Tabla, Top);
            return AjaxResult(result);
        }
    }
}
"""
    write(os.path.join(UI, "Controllers", "BitacoraController.cs"), ctrl)

    view = """\
@{
    ViewBag.Title = "Bitácora de Actividad";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{
    <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" />
}
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Bitácora</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-scroll" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Bitácora de Actividad</h1>
                <p>Registro de acciones realizadas en el sistema</p>
            </div>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="row mb-3">
        <div class="col-md-3">
            <input type="number" id="filter-usu" class="form-control" placeholder="ID Usuario">
        </div>
        <div class="col-md-3">
            <input type="text" id="filter-tabla" class="form-control" placeholder="Tabla (ej: tbAlumnos)">
        </div>
        <div class="col-md-2">
            <input type="number" id="filter-top" class="form-control" placeholder="Top N" value="200">
        </div>
        <div class="col-md-2">
            <button class="btn btn-primary btn-sm w-100" id="btn-filtrar">
                <i class="fa-solid fa-filter"></i> Filtrar
            </button>
        </div>
    </div>
    <div class="card-listado-catalogo">
        <div class="card-body-listado-catalogo">
            <div class="table-responsive">
                <table class="table table-striped table-bordered nowrap" id="datatable-bitacora">
                    <thead>
                        <tr>
                            <th>Fecha</th><th>Usuario</th><th>Tabla</th>
                            <th>Acción</th><th>Detalle</th>
                        </tr>
                    </thead>
                </table>
            </div>
        </div>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/bitacora.js"></script>
    <script>Bitacora.init("@Url.Action("ListAsync")");</script>
}
"""
    os.makedirs(os.path.join(UI, "Views", "Bitacora"), exist_ok=True)
    write(os.path.join(UI, "Views", "Bitacora", "Index.cshtml"), view)

    js = """\
var Bitacora = (function () {
    var obj = {};
    var table;

    obj.init = function (url) {
        table = $("#datatable-bitacora").DataTable({
            ajax: { url: url, dataSrc: "" },
            columns: [
                { data: "Bit_Fecha",    title: "Fecha" },
                { data: "Usu_Nombre",   title: "Usuario" },
                { data: "Bit_Tabla",    title: "Tabla" },
                { data: "Bit_Accion",   title: "Acción" },
                { data: "Bit_Detalle",  title: "Detalle" }
            ],
            language: { url: "//cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json" },
            order: [[0, "desc"]],
            pageLength: 50
        });

        $("#btn-filtrar").on("click", function () {
            var u = $("#filter-usu").val();
            var t = $("#filter-tabla").val();
            var n = $("#filter-top").val();
            var qs = "?";
            if (u) qs += "Usu_Id=" + u + "&";
            if (t) qs += "Bit_Tabla=" + encodeURIComponent(t) + "&";
            if (n) qs += "Top=" + n;
            table.ajax.url(url + qs).load();
        });
    };

    return obj;
}());
"""
    write(os.path.join(UI, "Content", "js", "pages", "bitacora.js"), js)


# ─────────────────────────────────────────────────────────────────────────────
# HORARIOS (CRUD)
# ─────────────────────────────────────────────────────────────────────────────
def gen_horarios():
    svc = """\
using GESTION_COLEGIAL.Business.Helpers;
using GESTION_COLEGIAL.Business.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class HorariosService
    {
        public async Task<List<dynamic>> ListAsync()
            => await SendHttpClient.GetAsync<dynamic>("Horarios/ListAsync");

        public async Task<dynamic> FindAsync(int id)
            => await SendHttpClient.GetSingleAsync<dynamic>($"Horarios/FindAsync?Hor_Id={id}");

        public async Task<bool> CreateAsync(HorarioViewModel model)
            => await SendHttpClient.PostAsync("Horarios/CreateAsync", model);

        public async Task<bool> EditAsync(HorarioViewModel model)
            => await SendHttpClient.PutAsync("Horarios/EditAsync", model);

        public async Task<bool> RemoveAsync(HorarioRemoveViewModel model)
            => await SendHttpClient.PutAsync("Horarios/RemoveAsync", model);
    }
}
"""
    write(os.path.join(BIZ, "Services", "HorariosService.cs"), svc)

    model = """\
using System.ComponentModel.DataAnnotations;

namespace GESTION_COLEGIAL.Business.Models
{
    public class HorarioViewModel
    {
        public int Hor_Id { get; set; }
        [Required] public int Cur_Id { get; set; }
        [Required] public int Cun_Id { get; set; }
        [Required] public int Mat_Id { get; set; }
        [Required] public int Emp_Id { get; set; }
        [Required] public int Sec_Id { get; set; }
        [Required] public int Aul_Id { get; set; }
        [Required] public int Dia_Id { get; set; }
        [Required] public int Hor_HoraInicio { get; set; }
        [Required] public int Hor_HoraFinaliza { get; set; }
        [Required] public int Sem_Id { get; set; }
        public int? Mda_Id { get; set; }
        [Required] public int Hor_Año { get; set; }
        public int UsuarioRegistra { get; set; }
        public int UsuarioModifica { get; set; }
    }

    public class HorarioRemoveViewModel
    {
        public int Hor_Id { get; set; }
        public int UsuarioModifica { get; set; }
    }
}
"""
    write(os.path.join(BIZ, "Models", "HorarioViewModel.cs"), model)

    ctrl = """\
using GESTION_COLEGIAL.Business.Models;
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using GESTION_COLEGIAL.UI.Helpers;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Horario semanal")]
    public class HorariosNuevoController : BaseController
    {
        private readonly HorariosService _service = new HorariosService();

        public ActionResult Index()
        {
            ViewBag.PuedeCrear   = TienePantalla("Crear horario");
            ViewBag.PuedeEditar  = TienePantalla("Editar horario");
            ViewBag.PuedeEliminar= TienePantalla("Eliminar horario");
            return View();
        }

        public async Task<ActionResult> ListAsync()
        {
            var result = await _service.ListAsync();
            return AjaxResult(result);
        }

        public async Task<ActionResult> FindAsync(int id)
        {
            var result = await _service.FindAsync(id);
            return AjaxResult(result, true);
        }

        [HttpPost]
        [SessionManager("Crear horario")]
        public async Task<ActionResult> CreateAsync(HorarioViewModel model)
        {
            model.UsuarioRegistra = GetUsuarioId();
            if (model.Hor_Id == 0)
            {
                bool err = await _service.CreateAsync(model);
                return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                           : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessInsert);
            }
            model.UsuarioModifica = GetUsuarioId();
            bool err2 = await _service.EditAsync(model);
            return err2 ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                        : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessUpdate);
        }

        [HttpPost]
        [SessionManager("Eliminar horario")]
        public async Task<ActionResult> DeleteAsync(HorarioRemoveViewModel model)
        {
            model.UsuarioModifica = GetUsuarioId();
            bool err = await _service.RemoveAsync(model);
            return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessDelete);
        }
    }
}
"""
    write(os.path.join(UI, "Controllers", "HorariosNuevoController.cs"), ctrl)

    view = """\
@model GESTION_COLEGIAL.Business.Models.HorarioViewModel
@{
    ViewBag.Title = "Horario Semanal";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{
    <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" />
    <link href="~/Content/css/modal-catalogos.css" rel="stylesheet" />
}
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Horario Semanal</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-calendar-week" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Horario Semanal</h1>
                <p>Gestione el horario consolidado de clases</p>
            </div>
        </div>
        <div class="header-action-catalogo">
            @if (ViewBag.PuedeCrear == true)
            {
                <button class="btn-nuevo-catalogo" id="add-btn-header" data-toggle="modal" data-target="#edit-modal">
                    <i class="mdi mdi-plus-circle-outline"></i> Nuevo Horario
                </button>
            }
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="card-listado-catalogo">
        <div class="card-body-listado-catalogo">
            <div class="table-responsive">
                <table class="table table-striped table-bordered nowrap" id="datatable-horarios">
                    <thead>
                        <tr>
                            <th>Año</th><th>Semestre</th><th>Día</th><th>Hora</th>
                            <th>Materia</th><th>Docente</th><th>Sección</th><th>Aula</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Modal Crear/Editar -->
<div class="modal fade" id="edit-modal" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
        <div class="modal-content modal-content-catalogo">
            <div class="modal-header-catalogo">
                <div class="modal-title-wrapper-catalogo">
                    <div class="modal-icon-catalogo"><i class="fa-solid fa-calendar-week"></i></div>
                    <div>
                        <h5 class="modal-title-catalogo">Gestión de Horario</h5>
                        <p class="modal-subtitle-catalogo">Configure los datos del bloque de clase</p>
                    </div>
                </div>
                <button type="button" class="close close-catalogo" data-dismiss="modal">&times;</button>
            </div>
            @using (Ajax.BeginForm("CreateAsync", "HorariosNuevo", new AjaxOptions {
                HttpMethod = "Post", OnBegin = "Catalogs.begin",
                OnComplete = "Catalogs.complete", OnFailure = "Catalogs.failure", OnSuccess = "Catalogs.success"
            }))
            {
            <div class="fluid-container">
                @Html.HiddenFor(m => m.Hor_Id, new { @id = "item-id" })
                <div class="modal-body-catalogo">
                    <div class="form-card-catalogo">
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group-catalogo">
                                    <label class="form-label-catalogo">Año <span class="required-asterisk-catalogo">*</span></label>
                                    @Html.EditorFor(m => m.Hor_Año, new { htmlAttributes = new { @class = "form-control form-input-catalogo", placeholder = "2025" } })
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group-catalogo">
                                    <label class="form-label-catalogo">Semestre ID <span class="required-asterisk-catalogo">*</span></label>
                                    @Html.EditorFor(m => m.Sem_Id, new { htmlAttributes = new { @class = "form-control form-input-catalogo" } })
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group-catalogo">
                                    <label class="form-label-catalogo">Día ID <span class="required-asterisk-catalogo">*</span></label>
                                    @Html.EditorFor(m => m.Dia_Id, new { htmlAttributes = new { @class = "form-control form-input-catalogo" } })
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group-catalogo">
                                    <label class="form-label-catalogo">Hora Inicio ID <span class="required-asterisk-catalogo">*</span></label>
                                    @Html.EditorFor(m => m.Hor_HoraInicio, new { htmlAttributes = new { @class = "form-control form-input-catalogo" } })
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group-catalogo">
                                    <label class="form-label-catalogo">Hora Fin ID <span class="required-asterisk-catalogo">*</span></label>
                                    @Html.EditorFor(m => m.Hor_HoraFinaliza, new { htmlAttributes = new { @class = "form-control form-input-catalogo" } })
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group-catalogo">
                                    <label class="form-label-catalogo">Materia ID <span class="required-asterisk-catalogo">*</span></label>
                                    @Html.EditorFor(m => m.Mat_Id, new { htmlAttributes = new { @class = "form-control form-input-catalogo" } })
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group-catalogo">
                                    <label class="form-label-catalogo">Docente ID <span class="required-asterisk-catalogo">*</span></label>
                                    @Html.EditorFor(m => m.Emp_Id, new { htmlAttributes = new { @class = "form-control form-input-catalogo" } })
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group-catalogo">
                                    <label class="form-label-catalogo">Sección ID <span class="required-asterisk-catalogo">*</span></label>
                                    @Html.EditorFor(m => m.Sec_Id, new { htmlAttributes = new { @class = "form-control form-input-catalogo" } })
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group-catalogo">
                                    <label class="form-label-catalogo">Aula ID <span class="required-asterisk-catalogo">*</span></label>
                                    @Html.EditorFor(m => m.Aul_Id, new { htmlAttributes = new { @class = "form-control form-input-catalogo" } })
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group-catalogo">
                                    <label class="form-label-catalogo">Curso ID <span class="required-asterisk-catalogo">*</span></label>
                                    @Html.EditorFor(m => m.Cur_Id, new { htmlAttributes = new { @class = "form-control form-input-catalogo" } })
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer-catalogo">
                    <button type="button" class="btn-cancel-catalogo" data-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn-save-catalogo">Guardar</button>
                </div>
            </div>
            }
        </div>
    </div>
</div>

<!-- Modal Delete -->
<div class="modal fade" id="delete-modal" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-dialog-centered" role="document" style="max-width:440px;">
        @using (Ajax.BeginForm("DeleteAsync", "HorariosNuevo", new AjaxOptions {
            HttpMethod = "Post", OnBegin = "Catalogs.begin",
            OnComplete = "Catalogs.complete", OnFailure = "Catalogs.failure", OnSuccess = "Catalogs.success"
        }))
        {
        <div class="modal-content" style="border-radius:12px;border:none;">
            <div class="modal-header" style="border-bottom:none;padding:20px 24px 0;">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body text-center" style="padding:0 40px 32px;">
                <input type="hidden" name="Hor_Id" id="delete-item-id" />
                <div class="d-flex justify-content-center mb-3">
                    <div style="width:80px;height:80px;background:linear-gradient(135deg,#fee2e2,#fecaca);border-radius:50%;display:flex;align-items:center;justify-content:center;">
                        <div style="width:56px;height:56px;background-color:#dc2626;border-radius:50%;display:flex;align-items:center;justify-content:center;">
                            <i class="fas fa-exclamation-triangle" style="color:white;font-size:28px;"></i>
                        </div>
                    </div>
                </div>
                <h5 style="color:#1f2937;font-weight:600;">Eliminar horario</h5>
                <p style="color:#6b7280;font-size:14px;">¿Está seguro de eliminar este bloque de horario?</p>
            </div>
            <div class="modal-footer" style="border-top:none;padding:0 40px 32px;gap:12px;">
                <button type="button" class="btn" data-dismiss="modal" style="flex:1;background:#f3f4f6;border:1px solid #d1d5db;color:#374151;border-radius:8px;">Cancelar</button>
                <button type="submit" class="btn btn-danger" style="flex:1;border-radius:8px;">Eliminar</button>
            </div>
        </div>
        }
    </div>
</div>

@section Scripts{
    <script src="~/Content/js/pages/horariosnuevo.js"></script>
    <script>
        HorariosNuevo.datatableInit({
            urlList:   "@Url.Action("ListAsync")",
            urlDetail: "@Url.Action("FindAsync")",
            permisos: {
                editar:   @(ViewBag.PuedeEditar   == true ? "true" : "false"),
                eliminar: @(ViewBag.PuedeEliminar == true ? "true" : "false")
            }
        });
        Catalogs.configure({ displayName: "horario", urlUpdate: "@Url.Action("FindAsync")" });
    </script>
}
"""
    os.makedirs(os.path.join(UI, "Views", "HorariosNuevo"), exist_ok=True)
    write(os.path.join(UI, "Views", "HorariosNuevo", "Index.cshtml"), view)

    js = """\
var HorariosNuevo = (function () {
    var obj = {};

    obj.datatableInit = function (cfg) {
        $(function () {
            datatableCatalogs.init(cfg, [
                { FieldName: "Hor_Año",                   Size: 70 },
                { FieldName: "Sem_Descripcion",           Size: 100 },
                { FieldName: "Dia_Descripcion",           Size: 100 },
                { FieldName: "Hor_HoraInicioDescripcion", Size: 90 },
                { FieldName: "Mat_Nombre" },
                { FieldName: "Emp_NombreCompleto" },
                { FieldName: "Sec_Descripcion",           Size: 90 },
                { FieldName: "Aul_Descripcion",           Size: 90 }
            ]);
        });
    };

    return obj;
}());
"""
    write(os.path.join(UI, "Content", "js", "pages", "horariosnuevo.js"), js)


# ─────────────────────────────────────────────────────────────────────────────
# NOTAS (cuaderno de notas)
# ─────────────────────────────────────────────────────────────────────────────
def gen_notas_adm():
    svc = """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class NotasAdmService
    {
        public async Task<List<dynamic>> CuadernoAsync(int Sec_Id, int Mat_Id, int Par_Id, int Sem_Id, int Anio)
            => await SendHttpClient.GetAsync<dynamic>($"Notas/CuadernoAsync?Sec_Id={Sec_Id}&Mat_Id={Mat_Id}&Par_Id={Par_Id}&Sem_Id={Sem_Id}&Anio={Anio}");

        public async Task<bool> CreateAsync(dynamic model)
            => await SendHttpClient.PostAsync("Notas/CreateAsync", model);

        public async Task<bool> EditAsync(dynamic model)
            => await SendHttpClient.PutAsync("Notas/EditAsync", model);
    }
}
"""
    write(os.path.join(BIZ, "Services", "NotasAdmService.cs"), svc)

    ctrl = """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Cuaderno de notas")]
    public class NotasAdmController : BaseController
    {
        private readonly NotasAdmService _service = new NotasAdmService();

        public ActionResult Index() => View();

        public async Task<ActionResult> CuadernoAsync(int Sec_Id, int Mat_Id, int Par_Id, int Sem_Id, int Anio)
        {
            var result = await _service.CuadernoAsync(Sec_Id, Mat_Id, Par_Id, Sem_Id, Anio);
            return AjaxResult(result);
        }

        [HttpPost]
        public async Task<ActionResult> GuardarNota(int? Not_Id, int Alu_Id, int Sec_Id,
            int Mat_Id, int Sem_Id, int Par_Id, decimal Not_Nota, string Not_Año)
        {
            bool err;
            if (Not_Id == null || Not_Id == 0)
                err = await _service.CreateAsync(new { Alu_Id, Sec_Id, Mat_Id, Sem_Id, Par_Id, Not_Nota, Not_Año, UsuarioRegistra = GetUsuarioId() });
            else
                err = await _service.EditAsync(new { Not_Id, Not_Nota, UsuarioModifica = GetUsuarioId() });

            return err ? AjaxResult(false, GESTION_COLEGIAL.UI.Helpers.AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true, GESTION_COLEGIAL.UI.Helpers.AlertMessage.AlertMessageCustomType.SuccessInsert);
        }
    }
}
"""
    write(os.path.join(UI, "Controllers", "NotasAdmController.cs"), ctrl)

    view = """\
@{
    ViewBag.Title = "Cuaderno de Notas";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{
    <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" />
}
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Cuaderno de Notas</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-book-open" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Cuaderno de Notas</h1>
                <p>Ingrese y consulte las notas por sección, materia y parcial</p>
            </div>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="card mb-3 p-3">
        <div class="row g-2">
            <div class="col-md-2"><input type="number" id="f-sec"  class="form-control" placeholder="Sección ID"></div>
            <div class="col-md-2"><input type="number" id="f-mat"  class="form-control" placeholder="Materia ID"></div>
            <div class="col-md-2"><input type="number" id="f-par"  class="form-control" placeholder="Parcial ID"></div>
            <div class="col-md-2"><input type="number" id="f-sem"  class="form-control" placeholder="Semestre ID"></div>
            <div class="col-md-2"><input type="number" id="f-anio" class="form-control" placeholder="Año" value="2025"></div>
            <div class="col-md-2"><button class="btn btn-primary w-100" id="btn-cargar"><i class="fa-solid fa-magnifying-glass"></i> Cargar</button></div>
        </div>
    </div>
    <div class="card-listado-catalogo">
        <div class="card-body-listado-catalogo">
            <div class="table-responsive">
                <table class="table table-striped table-bordered" id="tabla-notas">
                    <thead><tr><th>Alumno</th><th style="width:150px;">Nota</th><th style="width:100px;">Guardar</th></tr></thead>
                    <tbody id="tbody-notas"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/notasadm.js"></script>
    <script>NotasAdm.init("@Url.Action("CuadernoAsync")", "@Url.Action("GuardarNota")");</script>
}
"""
    os.makedirs(os.path.join(UI, "Views", "NotasAdm"), exist_ok=True)
    write(os.path.join(UI, "Views", "NotasAdm", "Index.cshtml"), view)

    js = """\
var NotasAdm = (function () {
    var obj = {};
    var urlCuaderno, urlGuardar;
    var contexto = {};

    obj.init = function (cu, gu) {
        urlCuaderno = cu;
        urlGuardar  = gu;

        $("#btn-cargar").on("click", function () {
            contexto = {
                Sec_Id: $("#f-sec").val(),
                Mat_Id: $("#f-mat").val(),
                Par_Id: $("#f-par").val(),
                Sem_Id: $("#f-sem").val(),
                Anio:   $("#f-anio").val()
            };
            if (!contexto.Sec_Id || !contexto.Mat_Id || !contexto.Par_Id || !contexto.Sem_Id || !contexto.Anio) {
                alert("Complete todos los filtros.");
                return;
            }
            $.getJSON(urlCuaderno, contexto, function (data) {
                var tbody = $("#tbody-notas").empty();
                $.each(data, function (_, row) {
                    var btn = '<button class="btn btn-sm btn-success btn-guardar" data-id="' + (row.Not_Id || 0) +
                              '" data-alu="' + row.Alu_Id + '">Guardar</button>';
                    var input = '<input type="number" class="form-control nota-input" step="0.01" min="0" max="100" value="' + (row.Not_Nota || "") + '">';
                    tbody.append("<tr><td>" + row.Alu_NombreCompleto + "</td><td>" + input + "</td><td>" + btn + "</td></tr>");
                });
            });
        });

        $(document).on("click", ".btn-guardar", function () {
            var btn   = $(this);
            var nota  = btn.closest("tr").find(".nota-input").val();
            var year  = contexto.Anio + "-01-01";
            $.post(urlGuardar, {
                Not_Id:  btn.data("id"),
                Alu_Id:  btn.data("alu"),
                Sec_Id:  contexto.Sec_Id,
                Mat_Id:  contexto.Mat_Id,
                Sem_Id:  contexto.Sem_Id,
                Par_Id:  contexto.Par_Id,
                Not_Nota: nota,
                Not_Año: year
            }, function (res) {
                if (res && res.success) btn.removeClass("btn-success").addClass("btn-secondary").text("Guardado");
            });
        });
    };

    return obj;
}());
"""
    write(os.path.join(UI, "Content", "js", "pages", "notasadm.js"), js)


# ─────────────────────────────────────────────────────────────────────────────
# ASISTENCIA
# ─────────────────────────────────────────────────────────────────────────────
def gen_asistencia():
    svc = """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class AsistenciaAdmService
    {
        public async Task<List<dynamic>> ListAsync(int Hor_Id, string Fecha)
            => await SendHttpClient.GetAsync<dynamic>($"Asistencia/ListAsync?Hor_Id={Hor_Id}&Fecha={Fecha}");

        public async Task<bool> CreateAsync(dynamic model)
            => await SendHttpClient.PostAsync("Asistencia/CreateAsync", model);

        public async Task<bool> EditAsync(dynamic model)
            => await SendHttpClient.PutAsync("Asistencia/EditAsync", model);
    }
}
"""
    write(os.path.join(BIZ, "Services", "AsistenciaAdmService.cs"), svc)

    ctrl = """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using GESTION_COLEGIAL.UI.Helpers;
using System;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Pase de lista")]
    public class AsistenciaAdmController : BaseController
    {
        private readonly AsistenciaAdmService _service = new AsistenciaAdmService();

        public ActionResult Index() => View();

        public async Task<ActionResult> ListAsync(int Hor_Id, string Fecha)
        {
            var result = await _service.ListAsync(Hor_Id, Fecha);
            return AjaxResult(result);
        }

        [HttpPost]
        public async Task<ActionResult> MarcarAsync(int? Asi_Id, int Hor_Id, int Alu_Id,
            string Asi_Fecha, string Asi_Estado, string Asi_Observacion)
        {
            bool err;
            if (Asi_Id == null || Asi_Id == 0)
                err = await _service.CreateAsync(new { Hor_Id, Alu_Id, Asi_Fecha, Asi_Estado, Asi_Observacion, UsuarioRegistra = GetUsuarioId() });
            else
                err = await _service.EditAsync(new { Asi_Id, Asi_Estado, Asi_Observacion, UsuarioModifica = GetUsuarioId() });

            return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessInsert);
        }
    }
}
"""
    write(os.path.join(UI, "Controllers", "AsistenciaAdmController.cs"), ctrl)

    view = """\
@{
    ViewBag.Title = "Pase de Lista";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{ <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" /> }
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Pase de Lista</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-clipboard-check" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo"><h1>Pase de Lista</h1><p>Registre la asistencia diaria por horario</p></div>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="card mb-3 p-3">
        <div class="row g-2">
            <div class="col-md-3"><input type="number" id="f-hor" class="form-control" placeholder="ID Horario"></div>
            <div class="col-md-3"><input type="date"   id="f-fecha" class="form-control" value=""></div>
            <div class="col-md-2"><button class="btn btn-primary w-100" id="btn-cargar"><i class="fa-solid fa-magnifying-glass"></i> Cargar</button></div>
            <div class="col-md-2"><button class="btn btn-success w-100" id="btn-guardar-todos">Guardar Todo</button></div>
        </div>
    </div>
    <div class="card-listado-catalogo">
        <div class="card-body-listado-catalogo">
            <table class="table table-striped table-bordered" id="tabla-asistencia">
                <thead><tr><th>Alumno</th><th>Estado</th><th>Observación</th><th>Guardar</th></tr></thead>
                <tbody id="tbody-asistencia"></tbody>
            </table>
        </div>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/asistenciaadm.js"></script>
    <script>AsistenciaAdm.init("@Url.Action("ListAsync")", "@Url.Action("MarcarAsync")");</script>
}
"""
    os.makedirs(os.path.join(UI, "Views", "AsistenciaAdm"), exist_ok=True)
    write(os.path.join(UI, "Views", "AsistenciaAdm", "Index.cshtml"), view)

    js = """\
var AsistenciaAdm = (function () {
    var obj = {};
    var urlList, urlMarcar;
    var fecha, horId;

    obj.init = function (ul, um) {
        urlList   = ul;
        urlMarcar = um;

        // Default today
        var hoy = new Date().toISOString().split("T")[0];
        $("#f-fecha").val(hoy);

        $("#btn-cargar").on("click", cargar);
        $("#btn-guardar-todos").on("click", guardarTodos);
        $(document).on("click", ".btn-marcar", function () { guardarFila($(this).closest("tr")); });
    };

    function cargar() {
        horId = $("#f-hor").val();
        fecha = $("#f-fecha").val();
        if (!horId || !fecha) { alert("Seleccione horario y fecha."); return; }

        $.getJSON(urlList, { Hor_Id: horId, Fecha: fecha }, function (data) {
            var tbody = $("#tbody-asistencia").empty();
            $.each(data, function (_, row) {
                var estados = ["Presente","Ausente","Tardanza","Justificado"].map(function(e) {
                    var sel = row.Asi_Estado === e ? " selected" : "";
                    return "<option" + sel + ">" + e + "</option>";
                }).join("");
                tbody.append(
                    "<tr data-asi='" + (row.Asi_Id || 0) + "' data-alu='" + row.Alu_Id + "'>" +
                    "<td>" + row.Alu_NombreCompleto + "</td>" +
                    "<td><select class='form-control est-select'>" + estados + "</select></td>" +
                    "<td><input class='form-control obs-input' value='" + (row.Asi_Observacion || "") + "'></td>" +
                    "<td><button class='btn btn-sm btn-primary btn-marcar'>Guardar</button></td></tr>"
                );
            });
        });
    }

    function guardarFila(tr, cb) {
        $.post(urlMarcar, {
            Asi_Id:          tr.data("asi"),
            Hor_Id:          horId,
            Alu_Id:          tr.data("alu"),
            Asi_Fecha:       fecha,
            Asi_Estado:      tr.find(".est-select").val(),
            Asi_Observacion: tr.find(".obs-input").val()
        }, function (res) { if (cb) cb(res); });
    }

    function guardarTodos() {
        $("#tbody-asistencia tr").each(function () { guardarFila($(this)); });
    }

    return obj;
}());
"""
    write(os.path.join(UI, "Content", "js", "pages", "asistenciaadm.js"), js)


# ─────────────────────────────────────────────────────────────────────────────
# VACACIONES
# ─────────────────────────────────────────────────────────────────────────────
def gen_vacaciones():
    svc = """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class VacacionesAdmService
    {
        public async Task<List<dynamic>> ListAsync(string Emp_Id = null)
        {
            string url = "Vacaciones/ListAsync" + (Emp_Id != null ? $"?Emp_Id={Emp_Id}" : "");
            return await SendHttpClient.GetAsync<dynamic>(url);
        }

        public async Task<bool> CreateAsync(dynamic model)
            => await SendHttpClient.PostAsync("Vacaciones/CreateAsync", model);

        public async Task<bool> ApproveAsync(dynamic model)
            => await SendHttpClient.PutAsync("Vacaciones/ApproveAsync", model);

        public async Task<bool> RemoveAsync(dynamic model)
            => await SendHttpClient.PutAsync("Vacaciones/RemoveAsync", model);
    }
}
"""
    write(os.path.join(BIZ, "Services", "VacacionesAdmService.cs"), svc)

    ctrl = """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using GESTION_COLEGIAL.UI.Helpers;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Control de vacaciones")]
    public class VacacionesAdmController : BaseController
    {
        private readonly VacacionesAdmService _service = new VacacionesAdmService();

        public ActionResult Index() => View();

        public async Task<ActionResult> ListAsync(string Emp_Id = null)
        {
            var result = await _service.ListAsync(Emp_Id);
            return AjaxResult(result);
        }

        [HttpPost]
        public async Task<ActionResult> CreateAsync(int Emp_Id, string Vac_FechaInicio, string Vac_FechaFin, string Vac_Tipo, string Vac_Observacion)
        {
            bool err = await _service.CreateAsync(new { Emp_Id, Vac_FechaInicio, Vac_FechaFin, Vac_Tipo, Vac_Observacion, UsuarioRegistra = GetUsuarioId() });
            return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessInsert);
        }

        [HttpPost]
        public async Task<ActionResult> ApproveAsync(int Vac_Id, string Vac_EstadoAprobacion)
        {
            bool err = await _service.ApproveAsync(new { Vac_Id, Vac_EstadoAprobacion, UsuarioModifica = GetUsuarioId() });
            return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessUpdate);
        }
    }
}
"""
    write(os.path.join(UI, "Controllers", "VacacionesAdmController.cs"), ctrl)

    view = """\
@{
    ViewBag.Title = "Control de Vacaciones";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{ <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" /> <link href="~/Content/css/modal-catalogos.css" rel="stylesheet" /> }
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Vacaciones / Permisos</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-umbrella-beach" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo"><h1>Vacaciones y Permisos</h1><p>Gestione las solicitudes de vacaciones del personal</p></div>
        </div>
        <div class="header-action-catalogo">
            <button class="btn-nuevo-catalogo" data-toggle="modal" data-target="#modal-nueva">
                <i class="mdi mdi-plus-circle-outline"></i> Nueva Solicitud
            </button>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="card-listado-catalogo">
        <div class="card-body-listado-catalogo">
            <div class="table-responsive">
                <table class="table table-striped table-bordered nowrap" id="datatable-vac">
                    <thead><tr>
                        <th>Empleado</th><th>Tipo</th><th>Inicio</th><th>Fin</th>
                        <th>Estado</th><th>Acciones</th>
                    </tr></thead>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Modal Nueva Solicitud -->
<div class="modal fade" id="modal-nueva" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content modal-content-catalogo">
            <div class="modal-header-catalogo">
                <div class="modal-title-wrapper-catalogo">
                    <div><h5 class="modal-title-catalogo">Nueva Solicitud</h5></div>
                </div>
                <button type="button" class="close close-catalogo" data-dismiss="modal">&times;</button>
            </div>
            <form id="form-nueva">
                <div class="modal-body-catalogo">
                    <div class="form-card-catalogo">
                        <div class="row">
                            <div class="col-md-12 form-group-catalogo">
                                <label class="form-label-catalogo">Empleado ID *</label>
                                <input type="number" name="Emp_Id" class="form-control form-input-catalogo">
                            </div>
                            <div class="col-md-6 form-group-catalogo">
                                <label class="form-label-catalogo">Fecha Inicio *</label>
                                <input type="date" name="Vac_FechaInicio" class="form-control form-input-catalogo">
                            </div>
                            <div class="col-md-6 form-group-catalogo">
                                <label class="form-label-catalogo">Fecha Fin *</label>
                                <input type="date" name="Vac_FechaFin" class="form-control form-input-catalogo">
                            </div>
                            <div class="col-md-6 form-group-catalogo">
                                <label class="form-label-catalogo">Tipo *</label>
                                <select name="Vac_Tipo" class="form-control form-input-catalogo">
                                    <option>Vacaciones</option><option>Permiso</option><option>Incapacidad</option>
                                </select>
                            </div>
                            <div class="col-md-12 form-group-catalogo">
                                <label class="form-label-catalogo">Observación</label>
                                <textarea name="Vac_Observacion" class="form-control form-input-catalogo" rows="2"></textarea>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer-catalogo">
                    <button type="button" class="btn-cancel-catalogo" data-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn-save-catalogo">Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

@section Scripts{
    <script src="~/Content/js/pages/vacacionesadm.js"></script>
    <script>
        VacacionesAdm.init(
            "@Url.Action("ListAsync")",
            "@Url.Action("CreateAsync")",
            "@Url.Action("ApproveAsync")"
        );
    </script>
}
"""
    os.makedirs(os.path.join(UI, "Views", "VacacionesAdm"), exist_ok=True)
    write(os.path.join(UI, "Views", "VacacionesAdm", "Index.cshtml"), view)

    js = """\
var VacacionesAdm = (function () {
    var obj = {};
    var urlList, urlCreate, urlApprove;
    var table;

    obj.init = function (ul, uc, ua) {
        urlList = ul; urlCreate = uc; urlApprove = ua;

        table = $("#datatable-vac").DataTable({
            ajax: { url: urlList, dataSrc: "" },
            columns: [
                { data: "Emp_NombreCompleto" },
                { data: "Vac_Tipo" },
                { data: "Vac_FechaInicio" },
                { data: "Vac_FechaFin" },
                { data: "Vac_EstadoAprobacion" },
                { data: null, render: function (r) {
                    if (r.Vac_EstadoAprobacion === "Pendiente")
                        return '<button class="btn btn-sm btn-success btn-aprobar" data-id="' + r.Vac_Id + '">Aprobar</button> ' +
                               '<button class="btn btn-sm btn-danger btn-rechazar" data-id="' + r.Vac_Id + '">Rechazar</button>';
                    return '<span class="badge badge-secondary">' + r.Vac_EstadoAprobacion + '</span>';
                }}
            ],
            language: { url: "//cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json" }
        });

        $("#form-nueva").on("submit", function (e) {
            e.preventDefault();
            $.post(urlCreate, $(this).serialize(), function (res) {
                if (res && res.success) { $("#modal-nueva").modal("hide"); table.ajax.reload(); }
            });
        });

        $(document).on("click", ".btn-aprobar", function () {
            $.post(urlApprove, { Vac_Id: $(this).data("id"), Vac_EstadoAprobacion: "Aprobado" },
                function () { table.ajax.reload(); });
        });
        $(document).on("click", ".btn-rechazar", function () {
            $.post(urlApprove, { Vac_Id: $(this).data("id"), Vac_EstadoAprobacion: "Rechazado" },
                function () { table.ajax.reload(); });
        });
    };

    return obj;
}());
"""
    write(os.path.join(UI, "Content", "js", "pages", "vacacionesadm.js"), js)


# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("\n=== Dashboards ===")
    for d in DASHBOARDS:
        gen_dashboard(d)

    print("\n=== Reportes ===")
    for r in REPORTS:
        gen_report(r)

    print("\n=== Bitácora ===")
    gen_bitacora()

    print("\n=== Horarios (nuevo CRUD) ===")
    gen_horarios()

    print("\n=== Cuaderno de Notas ===")
    gen_notas_adm()

    print("\n=== Pase de Lista (Asistencia) ===")
    gen_asistencia()

    print("\n=== Vacaciones / Permisos ===")
    gen_vacaciones()

    print("\n=== COMPLETO ===")
