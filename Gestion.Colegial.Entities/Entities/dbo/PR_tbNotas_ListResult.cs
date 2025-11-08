namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_tbNotas_ListResult
    {
        public int Not_Id { get; set; }
        public int Not_Nota { get; set; }
        public string Mat_Nombre { get; set; }
        public string Sem_Descripcion { get; set; }
        public string Pac_Descripcion { get; set; }
        public DateTime Not_Año { get; set; }
        public string EsActivo { get; set; }
    }
}