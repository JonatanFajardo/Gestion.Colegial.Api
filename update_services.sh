#!/bin/bash

# Script para actualizar servicios con DI

SERVICES=(
    "Cargo"
    "CursoNivel"
    "Curso"
    "Dia"
    "Duracion"
    "Empleado"
    "Encargado"
    "Estado"
    "Evento"
    "HomeAndCharts"
    "Hora"
    "Materia"
    "Modalidad"
    "NivelEducativo"
    "Parcial"
    "Parentesco"
    "Seccion"
    "Semestre"
    "Titulo"
)

for service in "${SERVICES[@]}"; do
    file="Gestion.Colegial.Business/Services/${service}Service.cs"

    if [ -f "$file" ]; then
        echo "Actualizando $file..."

        # Backup
        cp "$file" "${file}.bak"

        # 1. Agregar usings
        sed -i '1a using Gestion.Colegial.Business.Interfaces;\nusing Gestion.Colegial.DataAccess.Interfaces;' "$file"

        # 2. Cambiar declaración de clase
        sed -i "s/public class ${service}Service/public class ${service}Service : I${service}Service/" "$file"

        # 3. Cambiar instanciación de repositorio
        sed -i "s/private readonly ${service}Repository Repository = new ${service}Repository();/private readonly I${service}Repository _repository;\n\n    public ${service}Service(I${service}Repository repository)\n    {\n        _repository = repository;\n    }/" "$file"

        # 4. Reemplazar todas las referencias Repository por _repository
        sed -i "s/Repository\./_repository./g" "$file"

        echo "✓ $file actualizado"
    fi
done

echo "Completado!"
