namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>
    /// Quién escribe (lo pone la API con el usuario firmado). Los permisos ("Cuaderno de notas",
    /// "Plantillas de evaluación") y el horario del docente los revisa el procedimiento (script 089).
    /// </summary>
    public abstract class EvaluacionEscritorDTO
    {
        public int? Usuario { get; set; }
    }

    /// <summary>
    /// Plantilla de evaluación. Tipos = JSON [{id, n, p, c}] (Plt_Id o 0, nombre, peso en %, suma|promedio|mejor).
    /// Niv_Id / Mat_Id en null = todos los niveles / todas las materias.
    /// </summary>
    public class PlantillaEvaluacionGuardarDTO : EvaluacionEscritorDTO
    {
        public int Ple_Id { get; set; }
        public int Anio { get; set; }
        public int? Niv_Id { get; set; }
        public int? Mat_Id { get; set; }
        public string? Nombre { get; set; }
        public string? Descripcion { get; set; }
        public string? Tipos { get; set; }
        public int Version { get; set; }
    }

    public class PlantillaEvaluacionQuitarDTO : EvaluacionEscritorDTO
    {
        public int Ple_Id { get; set; }
        public int Version { get; set; }
    }

    /// <summary>
    /// Actividad del cuaderno. Nueva: Hor_Id + Pac_Id y el tipo como Cet_Id (cuaderno ya creado) o Plt_Id
    /// (primera actividad); Otras = JSON con más Hor_Id donde crear la misma actividad. Editar: Act_Id + Version.
    /// </summary>
    public class ActividadEvaluacionGuardarDTO : EvaluacionEscritorDTO
    {
        public int Act_Id { get; set; }
        public int Hor_Id { get; set; }
        public int Pac_Id { get; set; }
        public int? Cet_Id { get; set; }
        public int? Plt_Id { get; set; }
        public string? Nombre { get; set; }
        public string? Descripcion { get; set; }
        public decimal PuntosMax { get; set; }
        public DateTime? Fecha { get; set; }
        public bool NoCuenta { get; set; }
        public int Version { get; set; }
        public string? Otras { get; set; }
    }

    public class ActividadEvaluacionQuitarDTO : EvaluacionEscritorDTO
    {
        public int Act_Id { get; set; }
        public int Version { get; set; }
    }

    /// <summary>Puntos = JSON [{a: Act_Id, u: Alu_Id, e: calificado|no_entrego|excusado|vacio, p: puntos, v: versión leída}].</summary>
    public class PuntosEvaluacionGuardarDTO : EvaluacionEscritorDTO
    {
        public int Cev_Id { get; set; }
        public string? Puntos { get; set; }
    }
}
