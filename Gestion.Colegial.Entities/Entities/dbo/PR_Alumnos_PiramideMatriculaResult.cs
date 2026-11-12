namespace Gestion.Colegial.Entities.Entities
{
    public class PR_Alumnos_PiramideMatriculaResult
    {
        public int? Niv_Id { get; set; }
        public string Niv_Descripcion { get; set; }
        public int Cur_Id { get; set; }
        public string Cur_Nombre { get; set; }
        public int TotalMasculino { get; set; }
        public int TotalFemenino { get; set; }
        public int TotalOtro { get; set; }
        public int TotalGeneral { get; set; }
    }
}
