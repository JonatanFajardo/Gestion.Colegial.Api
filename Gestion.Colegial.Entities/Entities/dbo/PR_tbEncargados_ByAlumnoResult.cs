using System;

namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Resultado de la SP PR_tbEncargados_ByAlumno.
    /// Encargados vinculados a un alumno con datos de persona, parentesco
    /// e indicador de si es el encargado principal.
    /// </summary>
    public partial class PR_tbEncargados_ByAlumnoResult
    {
        public int? Enc_Id { get; set; }
        public int? Par_Id { get; set; }
        public string Par_Descripcion { get; set; }
        public int? Per_Id { get; set; }
        public string Per_PrimerNombre { get; set; }
        public string Per_SegundoNombre { get; set; }
        public string Per_ApellidoPaterno { get; set; }
        public string Per_ApellidoMaterno { get; set; }
        public string Per_Telefono { get; set; }
        public string Per_CorreoElectronico { get; set; }
        public string Per_Direccion { get; set; }
        public string Enc_Ocupacion { get; set; }
        public bool? EncargadoPrincipal { get; set; }
    }
}
