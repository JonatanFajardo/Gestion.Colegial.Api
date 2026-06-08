using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class SesionesActivasResult
    {
        public int Ses_Id { get; set; }
        public int Usu_Id { get; set; }
        public string Usu_Name { get; set; }
        public string NombreCompleto { get; set; }
        public string Rol_Descripcion { get; set; }
        public DateTime Ses_FechaInicio { get; set; }
        public DateTime Ses_UltimaActividad { get; set; }
        public int MinutosInactivo { get; set; }
        public string Ses_IP { get; set; }
        public string Ses_UserAgent { get; set; }
    }
}
