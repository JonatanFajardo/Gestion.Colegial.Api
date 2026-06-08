using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_tbNotificaciones_ListResult
    {
        public int Not_Id { get; set; }
        public string Not_Titulo { get; set; }
        public string Not_Mensaje { get; set; }
        public string Not_Tipo { get; set; }
        public bool Not_EsLeida { get; set; }
        public string Not_UrlDestino { get; set; }
        public DateTime Not_FechaEnvio { get; set; }
    }
}
