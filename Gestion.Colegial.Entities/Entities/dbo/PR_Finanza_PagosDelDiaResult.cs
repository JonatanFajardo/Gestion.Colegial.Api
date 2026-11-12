using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_Finanza_PagosDelDiaResult
    {
        public int Pag_Id { get; set; }
        public DateTime Pag_FechaPago { get; set; }
        public decimal Pag_MontoTotal { get; set; }
        public string Pag_NumeroReferencia { get; set; }
        public string Pag_Observaciones { get; set; }
        public int Alu_Id { get; set; }
        public string Alu_NombreCompleto { get; set; }
        public string Alu_Identidad { get; set; }
        public string Cur_Nombre { get; set; }
        public int Fpa_Id { get; set; }
        public string Fpa_Descripcion { get; set; }
        public int Usu_Id { get; set; }
        public string CajeroNombre { get; set; }
        public string ConceptosCobrados { get; set; }
    }
}
