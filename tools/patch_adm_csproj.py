"""Agrega los archivos generados por gen_adm_screens.py a los .csproj del ADM."""
import os, re

ROOT_ADM = r"C:\Users\nayel\OneDrive\Documentos\GitHub\001 Proyectos Estables\Gestion Colegial\GESTION_COLEGIAL_ADM"
UI_CSPROJ  = os.path.join(ROOT_ADM, "GESTION_COLEGIAL.UI",       "GESTION_COLEGIAL.UI.csproj")
BIZ_CSPROJ = os.path.join(ROOT_ADM, "GESTION_COLEGIAL.Business", "GESTION_COLEGIAL.Business.csproj")

# ── Archivos nuevos en UI (Controllers) ─────────────────────────────────────
UI_CONTROLLERS = [
    "DashboardAdminController",
    "DashboardDirectorController",
    "DashboardDocenteController",
    "DashboardSecretariaController",
    "DashboardRRHHController",
    "DashboardCajeroController",
    "DashboardFinancieroController",
    "DashboardConsultaController",
    "AgingCuentasController",
    "TopDeudoresController",
    "MorosidadPorNivelController",
    "EmpleadosAntiguedadController",
    "AlumnosEnRiesgoController",
    "AlumnosBusquedaController",
    "BitacoraController",
    "HorariosNuevoController",
    "NotasAdmController",
    "AsistenciaAdmController",
    "VacacionesAdmController",
]

# ── Archivos nuevos en Business (Services + Models) ─────────────────────────
BIZ_FILES = [
    r"Services\DashboardAdminService.cs",
    r"Services\DashboardDirectorService.cs",
    r"Services\DashboardDocenteService.cs",
    r"Services\DashboardSecretariaService.cs",
    r"Services\DashboardRRHHService.cs",
    r"Services\DashboardCajeroService.cs",
    r"Services\DashboardFinancieroService.cs",
    r"Services\DashboardConsultaService.cs",
    r"Services\AgingCuentasService.cs",
    r"Services\TopDeudoresService.cs",
    r"Services\MorosidadPorNivelService.cs",
    r"Services\EmpleadosAntiguedadService.cs",
    r"Services\AlumnosEnRiesgoService.cs",
    r"Services\AlumnosBusquedaService.cs",
    r"Services\BitacoraService.cs",
    r"Services\NotasAdmService.cs",
    r"Services\AsistenciaAdmService.cs",
    r"Services\VacacionesAdmService.cs",
    r"Models\HorarioViewModel.cs",
]

def patch(csproj_path, new_entries, anchor_pattern):
    """Inserta entradas <Compile Include=...> que no existen ya en el csproj."""
    with open(csproj_path, encoding="utf-8") as f:
        txt = f.read()

    added = []
    for entry in new_entries:
        tag = f'<Compile Include="{entry}" />'
        if tag in txt:
            print(f"  [SKIP] {entry}")
            continue
        # Insertar antes de la primera línea que matchea el patrón ancla
        txt = txt.replace(anchor_pattern, tag + "\n    " + anchor_pattern, 1)
        added.append(entry)
        print(f"  [OK]   {entry}")

    if added:
        with open(csproj_path, "w", encoding="utf-8") as f:
            f.write(txt)
    return len(added)


print("\n=== Patching UI.csproj ===")
ui_entries = [rf"Controllers\{c}.cs" for c in UI_CONTROLLERS]
patch(UI_CSPROJ, ui_entries,
      anchor_pattern='<Compile Include="Controllers\\AlumnosController.cs" />')

print("\n=== Patching Business.csproj ===")
patch(BIZ_CSPROJ, BIZ_FILES,
      anchor_pattern='<Compile Include="Services\\AccountService.cs" />')

print("\nListo. Recompila la solución en Visual Studio.")
