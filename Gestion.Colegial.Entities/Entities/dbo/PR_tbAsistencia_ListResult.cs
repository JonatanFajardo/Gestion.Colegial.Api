using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_tbAsistencia_ListResult
    {
        public int Asi_Id { get; set; }
        public int Alu_Id { get; set; }
        public string Asi_Estado { get; set; }
        public string Asi_Observacion { get; set; }
        public DateTime Asi_Fecha { get; set; }
        public string NombreAlumno { get; set; }
        public string Per_Imagen { get; set; }
    }
}
