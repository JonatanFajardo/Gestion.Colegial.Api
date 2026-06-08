namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_Organigrama_GetTreeResult
    {
        public int Emp_Id { get; set; }
        public string Emp_NombreCompleto { get; set; }
        public string Emp_Cargo { get; set; }
        public int? Emp_IdDepartamento { get; set; }
        public string NombreDepartamento { get; set; }
        public int? Emp_IdSupervisor { get; set; }
        public string NombreSupervisor { get; set; }
    }
}
