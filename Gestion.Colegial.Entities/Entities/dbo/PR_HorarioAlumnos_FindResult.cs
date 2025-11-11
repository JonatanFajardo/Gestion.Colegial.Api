namespace Gestion.Colegial.Entities.DTOs
{
    public class PR_HorarioAlumnos_FindResult
    {
        public int HoAl_Id { get; set; }

        public int Cur_Id { get; set; }
        public string Cur_Nombre { get; set; }

        public int Cun_Id { get; set; }
        public string Cun_Descripcion { get; set; }

        public int Mat_Id { get; set; }
        public string Mat_Nombre { get; set; }

        public int? Sec_Id { get; set; }
        public string? Sec_Descripcion { get; set; }

        public int? Aul_Id { get; set; }
        public string? Aul_Descripcion { get; set; }

        public int? Emp_Id { get; set; }
        public string? ProfesorNombre { get; set; }

        public int? Sem_Id { get; set; }
        public string? Sem_Descripcion { get; set; }

        public int? Mda_Id { get; set; }
        public string? ModalidadDescripcion { get; set; }

        public int? HoAl_Año { get; set; }

        public string HoraInicio { get; set; }
        public string HoraFinaliza { get; set; }
        public string Dia_Descripcion { get; set; }
    }
}
