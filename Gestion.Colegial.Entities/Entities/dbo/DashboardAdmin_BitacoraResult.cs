using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardAdmin_BitacoraResult
    {
        public int Bit_Id { get; set; }
        public string Usu_Name { get; set; }
        public string Bit_Accion { get; set; }
        public string Bit_Tabla { get; set; }
        public string Bit_Descripcion { get; set; }
        public string Bit_Ip { get; set; }
        public DateTime Bit_Fecha { get; set; }
    }
}
