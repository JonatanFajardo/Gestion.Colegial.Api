namespace Gestion.Colegial.DataAccess.Models.Graduacion
{
    /// <summary>
    /// Proyeccion de la vista app.vCandidatosGraduacion.
    /// Representa un alumno que esta cursando el ultimo grado de su nivel
    /// y cuyo estado de validacion (notas + deuda) puede o no permitir su graduacion.
    /// </summary>
    public class CandidatoGraduacionViewModel
    {
        public int Alu_Id { get; set; }
        public string? NombreCompleto { get; set; }
        public string? Niv_Descripcion { get; set; }
        public string? Cur_Descripcion { get; set; }
        public string? Sec_Descripcion { get; set; }
        public bool NotasOk { get; set; }
        public decimal DeudaPendiente { get; set; }
        public bool DeudaOk { get; set; }
        public string? EstadoValidacion { get; set; }
        public string? MotivosBloqueo { get; set; }
    }
}
