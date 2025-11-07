import os
import re

SERVICES = [
    "Cargo", "CursoNivel", "Curso", "Dia", "Duracion", "Empleado",
    "Encargado", "Estado", "Evento", "HomeAndCharts", "Hora", "Materia",
    "Modalidad", "NivelEducativo", "Parcial", "Parentesco", "Seccion",
    "Semestre", "Titulo"
]

for service in SERVICES:
    filepath = f"Gestion.Colegial.Business/Services/{service}Service.cs"

    if not os.path.exists(filepath):
        print(f"[X] {filepath} no existe")
        continue

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Agregar usings
    if "using Gestion.Colegial.Business.Interfaces;" not in content:
        content = content.replace(
            "using Gestion.Colegial.Business.Extensions;",
            "using Gestion.Colegial.Business.Extensions;\nusing Gestion.Colegial.Business.Interfaces;\nusing Gestion.Colegial.DataAccess.Interfaces;"
        )

    # 2. Implementar interfaz
    content = re.sub(
        f"public class {service}Service\r?\n",
        f"public class {service}Service : I{service}Service\n",
        content
    )

    # 3. Reemplazar instanciación con DI
    old_pattern = f"private readonly {service}Repository Repository = new {service}Repository();"
    new_pattern = f"""private readonly I{service}Repository _repository;

        public {service}Service(I{service}Repository repository)
        {{
            _repository = repository;
        }}"""
    content = content.replace(old_pattern, new_pattern)

    # 4. Reemplazar Referencias
    content = content.replace("Repository.", "_repository.")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"[OK] {service}Service actualizado")

print("\n[OK] Todos los servicios actualizados!")
