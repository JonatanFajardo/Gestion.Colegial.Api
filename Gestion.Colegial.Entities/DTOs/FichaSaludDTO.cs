namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>
    /// Datos para crear o cambiar la ficha de salud de un alumno.
    /// Fsa_Version = versión que se leyó (null si la ficha era nueva); Usuario = quien guarda.
    /// </summary>
    public class FichaSaludGuardarDTO
    {
        public int Alu_Id { get; set; }
        public string? Fsa_TipoSangre { get; set; }
        public bool Fsa_TieneAlerta { get; set; }
        public string? Fsa_Alerta { get; set; }
        public string? Fsa_Alergias { get; set; }
        public string? Fsa_Condiciones { get; set; }
        public string? Fsa_Medicamentos { get; set; }
        public string? Fsa_RestriccionesAlimentarias { get; set; }
        public string? Fsa_MedicoNombre { get; set; }
        public string? Fsa_MedicoTelefono { get; set; }
        public string? Fsa_Hospital { get; set; }
        public string? Fsa_Seguro { get; set; }
        public string? Fsa_SeguroPoliza { get; set; }
        public string? Fsa_ContactoEmergenciaNombre { get; set; }
        public string? Fsa_ContactoEmergenciaParentesco { get; set; }
        public string? Fsa_ContactoEmergenciaTelefono { get; set; }
        public string? Fsa_Notas { get; set; }
        public int? Fsa_Version { get; set; }
        public int? Usuario { get; set; }
    }
}
