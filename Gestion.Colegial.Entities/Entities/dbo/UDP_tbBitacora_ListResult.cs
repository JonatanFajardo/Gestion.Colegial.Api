using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class UDP_tbBitacora_ListResult
    {
        public int Bit_Id { get; set; }
        public string Bit_Accion { get; set; }
        public string Bit_Tabla { get; set; }
        public int? Bit_RegistroId { get; set; }
        public string Bit_Descripcion { get; set; }
        public string Bit_Ip { get; set; }
        public DateTime Bit_Fecha { get; set; }
        public string Usu_Name { get; set; }
    }
}
