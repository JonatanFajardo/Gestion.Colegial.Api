namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>Quién escribe: su usuario y si puede asignar ("Asignar sustituciones"); los calcula el ADM con la sesión.</summary>
    public abstract class SustitucionEscritorDTO
    {
        public int? Usuario { get; set; }
        public bool PuedeAsignar { get; set; }
    }

    /// <summary>Asignar un suplente a una clase (Hor_Id) en una fecha.</summary>
    public class SustitucionAsignarDTO : SustitucionEscritorDTO
    {
        public int Hor_Id { get; set; }
        public DateTime? Sus_Fecha { get; set; }
        public int Emp_IdSuplente { get; set; }
        public string? Sus_Notas { get; set; }
    }

    /// <summary>Cancelar una sustitución (motivo opcional).</summary>
    public class SustitucionCancelarDTO : SustitucionEscritorDTO
    {
        public int Sus_Id { get; set; }
        public string? Motivo { get; set; }
    }

    /// <summary>Marcar a mano que un docente falta un día.</summary>
    public class AusenciaDocenteMarcarDTO : SustitucionEscritorDTO
    {
        public int Emp_Id { get; set; }
        public DateTime? Aud_Fecha { get; set; }
        public string? Aud_Motivo { get; set; }
    }

    /// <summary>Quitar una ausencia marcada a mano.</summary>
    public class AusenciaDocenteQuitarDTO : SustitucionEscritorDTO
    {
        public int Aud_Id { get; set; }
    }
}
