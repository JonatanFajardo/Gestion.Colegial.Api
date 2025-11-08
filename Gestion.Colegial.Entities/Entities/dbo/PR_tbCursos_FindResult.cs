namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_tbCursos_FindResult
    {
        public int Cur_Id { get; set; }
        public string Cur_Nombre { get; set; }
        public int Niv_Id { get; set; }
        public string Niv_Descripcion { get; set; }
        public bool Cur_EsActivo { get; set; }
    }
}