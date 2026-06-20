namespace Gestion.Colegial.DataAccess.Models.Graduacion
{
    /// <summary>
    /// Proyeccion de la tabla app.tbAlumnosGraduados.
    /// Snapshot plano del alumno al momento de la graduacion.
    /// </summary>
    public class AlumnoGraduadoViewModel
    {
        public int AluGrad_Id { get; set; }
        public string? AluGrad_Identidad { get; set; }
        public string? AluGrad_NombreCompleto { get; set; }
        public DateTime? AluGrad_FechaNacimiento { get; set; }
        public string? AluGrad_Sexo { get; set; }
        public string? AluGrad_Correo { get; set; }
        public string? AluGrad_Telefono { get; set; }
        public string? AluGrad_NivelEducativo { get; set; }
        public string? AluGrad_TituloObtenido { get; set; }
        public int? AluGrad_AnioIngreso { get; set; }
        public int AluGrad_AnioGraduacion { get; set; }
        public decimal AluGrad_TotalPagado { get; set; }
        public string? AluGrad_EncargadosJson { get; set; }
        public int? AluGrad_AluIdOriginal { get; set; }
        public DateTime AluGrad_FechaArchivo { get; set; }
        public int AluGrad_UsuarioArchivo { get; set; }
    }
}
