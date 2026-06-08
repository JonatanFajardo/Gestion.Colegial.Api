using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_tbAsistencia_ByAlumnoResult
    {
        public int Asi_Id { get; set; }
        public DateTime Asi_Fecha { get; set; }
        public string Asi_Estado { get; set; }
        public string Asi_Observacion { get; set; }
        public string Mat_Nombre { get; set; }
        public string Dia_Descripcion { get; set; }
        public string HoraInicio { get; set; }
    }
}
