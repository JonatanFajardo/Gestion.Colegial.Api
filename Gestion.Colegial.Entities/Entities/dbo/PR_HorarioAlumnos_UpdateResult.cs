namespace Gestion.Colegial.Entities.DTOs
{
    public class PR_HorarioAlumnos_UpdateResult
    {
        public int HoAl_Id { get; set; }
        public int Cur_Id { get; set; }
        public int Cun_Id { get; set; }
        public int Mat_Id { get; set; }
        public int HoAl_HoraInicio { get; set; }
        public int HoAl_HoraFinaliza { get; set; }
        public int Dia_Id { get; set; }
        public int? Sec_Id { get; set; }          // Nuevo campo opcional
        public int? Aul_Id { get; set; }          // Nuevo campo opcional
        public int? Emp_Id { get; set; }          // Nuevo campo opcional
        public int? Sem_Id { get; set; }          // Nuevo campo opcional
        public int? Mda_Id { get; set; }          // Nuevo campo opcional
        public int? HoAl_Año { get; set; }        // Nuevo campo opcional
        public int HoAl_UsuarioModifica { get; set; }
    }
}
