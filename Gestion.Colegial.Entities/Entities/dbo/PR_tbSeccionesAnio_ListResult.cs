namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbSeccionesAnio_ListResult
    {
        public int Sea_Id { get; set; }
        public int Ani_Id { get; set; }
        public int Niv_Id { get; set; }
        public string Niv_Descripcion { get; set; }
        public int Cun_Id { get; set; }
        public string Cun_Descripcion { get; set; }
        public int Sec_Id { get; set; }
        public string Sec_Descripcion { get; set; }
        public int? Mda_Id { get; set; }
        public string Mda_Descripcion { get; set; }
        public int? Emp_Id { get; set; }
        public string Emp_Nombre { get; set; }
        public string Sea_Nombre { get; set; }
        public int? Sea_Cupo { get; set; }
        public byte Sea_Estado { get; set; }
        public string Sea_EstadoDescripcion { get; set; }
    }
}
