import os
import re

CONTROLLERS = [
    "Cargos", "CursosNiveles", "Cursos", "Dias", "Duraciones", "Empleados",
    "Encargados", "Estados", "Eventos", "HomeAndCharts", "Materias",
    "Modalidades", "NivelesEducativos", "Parciales", "Parentescos",
    "Secciones", "Semestres", "Titulos"
]

for ctrl in CONTROLLERS:
    filepath = f"Gestion.Colegial.Api/Controllers/{ctrl}Controller.cs"

    if not os.path.exists(filepath):
        print(f"[X] {filepath} no existe")
        continue

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extraer nombre del servicio (ej: CargosController -> Cargo)
    service_name = ctrl.rstrip('s') if ctrl != "Cursos" else "Curso"
    if ctrl == "HomeAndCharts":
        service_name = "HomeAndCharts"
    elif ctrl == "NivelesEducativos":
        service_name = "NivelEducativo"
    elif ctrl == "CursosNiveles":
        service_name = "CursoNivel"

    # 1. Cambiar using
    content = re.sub(
        r'using Gestion\.Colegial\.Business\.Services;',
        'using Gestion.Colegial.Business.Interfaces;',
        content
    )

    # 2. Cambiar declaración de campo (ej: private readonly CargoService -> private readonly ICargoService)
    content = re.sub(
        f'private readonly {service_name}Service (_\\w+Service);',
        f'private readonly I{service_name}Service \\1;',
        content
    )

    # 3. Cambiar constructor (ej: public CargosController(CargoService -> public CargosController(ICargoService)
    content = re.sub(
        f'public {ctrl}Controller\\({service_name}Service (\\w+Service)\\)',
        f'public {ctrl}Controller(I{service_name}Service \\1)',
        content
    )

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"[OK] {ctrl}Controller actualizado")

print("\n[OK] Todos los controladores actualizados!")
