namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbOfertasAnio_ListResult
    {
        public int Ofa_Id { get; set; }
        public int Ani_Id { get; set; }
        public int Mat_Id { get; set; }
        public string Mat_Nombre { get; set; }
        public int? Cun_Id { get; set; }
        public string Cun_Descripcion { get; set; }
        public int? Sea_Id { get; set; }
        public int? Emp_Id { get; set; }
        public string Emp_Nombre { get; set; }
        public int? Pan_Id { get; set; }
        public int? Ofa_HorasSemana { get; set; }
        public byte Ofa_Estado { get; set; }
        public string Ofa_EstadoDescripcion { get; set; }
    }
}
