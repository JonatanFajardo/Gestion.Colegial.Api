namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbMatriculaAnio_ExpedienteResult
    {
        public int Mta_Id { get; set; }
        public int Alu_Id { get; set; }
        public int Ani_Id { get; set; }
        public int Ani_Anio { get; set; }
        public string Ani_Nombre { get; set; }
        public int? Sea_Id { get; set; }
        public string Sea_Nombre { get; set; }
        public byte Mta_Estado { get; set; }
        public string Mta_EstadoDescripcion { get; set; }
    }
}
