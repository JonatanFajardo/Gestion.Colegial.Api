using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class UDP_tbUsuarios_LoginResult
    {
        public int Usu_Id { get; set; }
        public string Usu_Name { get; set; }
        public int Emp_Id { get; set; }
        public int Rol_Id { get; set; }
        public string Rol_Nombre { get; set; }
        public bool Usu_EsActivo { get; set; }
        public bool? Usu_Suspendido { get; set; }
        public bool? Usu_EsEliminado { get; set; }
        public int IsAuthenticated { get; set; }
        public string Message { get; set; }
    }
}