#nullable disable

namespace Gestion.Colegial.Entities.Entities
{
    public partial class tbEventoError
    {
        public int? Err_Id { get; set; }
        public string Err_NombreArchivo { get; set; }
        public DateTime? Err_Fecha { get; set; }
        public string Err_Ruta { get; set; }
        public string Err_Message { get; set; }
        public string Err_InnerException { get; set; }
    }
}