namespace Gestion.Colegial.Entities.Entities
{
    public partial class MatrizRolPantallasResult
    {
        public int Rol_Id { get; set; }
        public string Rol_Descripcion { get; set; }
        public int Pan_Id { get; set; }
        public string Pan_Descripcion { get; set; }
        public string Pan_Grupo { get; set; }
        public bool TieneAcceso { get; set; }
    }
}
