using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class TopDeudoresResult
    {
        public int Alu_Id { get; set; }
        public string NombreAlumno { get; set; }
        public string Per_Telefono { get; set; }
        public string Cur_Nombre { get; set; }
        public decimal TotalDeuda { get; set; }
        public int CuotasPendientes { get; set; }
        public DateTime? UltimoVencimiento { get; set; }
    }
}
