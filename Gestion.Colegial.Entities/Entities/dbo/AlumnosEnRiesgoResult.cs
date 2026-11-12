namespace Gestion.Colegial.Entities.Entities
{
    public partial class AlumnosEnRiesgoResult
    {
        public int Alu_Id { get; set; }
        public string NombreAlumno { get; set; }
        public string Per_Telefono { get; set; }
        public string Per_Imagen { get; set; }
        public string Cur_Nombre { get; set; }
        public string Sec_Descripcion { get; set; }
        public decimal? PromedioAnual { get; set; }
        public decimal DeudaPendiente { get; set; }
    }
}
