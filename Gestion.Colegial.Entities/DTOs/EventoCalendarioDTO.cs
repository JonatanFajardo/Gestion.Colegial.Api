namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>
    /// Datos para crear (Eve_Id = 0) o cambiar un día del calendario escolar.
    /// Sin secciones, roles ni personas = es para todo el colegio.
    /// </summary>
    public class EventoCalendarioGuardarDTO
    {
        public int Eve_Id { get; set; }
        public string? Eve_Titulo { get; set; }
        public string? Eve_Descripcion { get; set; }
        public string? Eve_Tipo { get; set; }
        public string? Eve_Lugar { get; set; }
        public bool Eve_TodoElDia { get; set; } = true;
        public DateTime Eve_Inicio { get; set; }
        public DateTime Eve_Fin { get; set; }
        public List<int> Secciones { get; set; } = new List<int>();
        public List<int> Roles { get; set; } = new List<int>();
        public List<int> Empleados { get; set; } = new List<int>();
        public List<int> Alumnos { get; set; } = new List<int>();
        public string? Eve_ClaveOrigen { get; set; }
        public bool? Publicar { get; set; }
        public int? Usuario { get; set; }
    }

    /// <summary>Un feriado o fecha escolar de Honduras propuesto para un año.</summary>
    public class FeriadoPropuestoDTO
    {
        public string? Clave { get; set; }
        public string? Titulo { get; set; }
        public string? Tipo { get; set; }
        public DateTime Inicio { get; set; }
        public DateTime Fin { get; set; }
        public string? Descripcion { get; set; }
        /// <summary>"Feriado nacional" o "Fecha escolar".</summary>
        public string? Grupo { get; set; }
        /// <summary>Marcado por defecto al cargar.</summary>
        public bool Sugerido { get; set; }
        /// <summary>Fechas que fija un decreto cada año: se cargan como borrador para revisarlas.</summary>
        public bool Verificar { get; set; }
        public bool YaCargado { get; set; }
        public int? Eve_Id { get; set; }
        public bool? Publicado { get; set; }
    }

    /// <summary>Qué feriados cargar y si cada uno nace publicado.</summary>
    public class CargarFeriadosDTO
    {
        public int Anio { get; set; }
        public List<FeriadoACargarDTO> Items { get; set; } = new List<FeriadoACargarDTO>();
        public int? Usuario { get; set; }
    }

    public class FeriadoACargarDTO
    {
        public string? Clave { get; set; }
        public bool Publicar { get; set; }
    }

    /// <summary>Resultado de cargar feriados. Si una carga falla a medias, queda lo que sí se cargó y Mensaje dice qué faltó.</summary>
    public class CargarFeriadosResultadoDTO
    {
        public int Creados { get; set; }
        public int YaEstaban { get; set; }
        /// <summary>null si todo salió bien.</summary>
        public string? Mensaje { get; set; }
    }
}
