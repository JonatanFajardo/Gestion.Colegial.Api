using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class CentroAnunciosResult
    {
        public int Anu_Id { get; set; }
        public string Anu_Titulo { get; set; }
        public string Anu_Contenido { get; set; }
        public DateTime Anu_FechaPublicacion { get; set; }
        public DateTime? Anu_FechaExpiracion { get; set; }
        public bool Anu_Activo { get; set; }
        public int EsVigente { get; set; }
        public DateTime Anu_FechaRegistra { get; set; }
        public string PublicadoPor { get; set; }
    }
}
