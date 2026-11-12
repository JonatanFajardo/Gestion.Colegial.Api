using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class HorariosResult
    {
        public int Hor_Id { get; set; }
        public int Cur_Id { get; set; }
        public string Cur_Nombre { get; set; }
        public int Cun_Id { get; set; }
        public string Cun_Descripcion { get; set; }
        public int Mat_Id { get; set; }
        public string Mat_Nombre { get; set; }
        public int Emp_Id { get; set; }
        public string Emp_NombreCompleto { get; set; }
        public int Sec_Id { get; set; }
        public string Sec_Descripcion { get; set; }
        public int Aul_Id { get; set; }
        public string Aul_Descripcion { get; set; }
        public int Dia_Id { get; set; }
        public string Dia_Descripcion { get; set; }
        public int Hor_HoraInicio { get; set; }
        public string Hor_HoraInicioDescripcion { get; set; }
        public int Hor_HoraFinaliza { get; set; }
        public string Hor_HoraFinalizaDescripcion { get; set; }
        public int Sem_Id { get; set; }
        public string Sem_Descripcion { get; set; }
        public int? Mda_Id { get; set; }
        public string Mda_Descripcion { get; set; }
        public int Hor_Año { get; set; }
        public bool Hor_EsEliminado { get; set; }
        public int Hor_UsuarioRegistra { get; set; }
        public DateTime Hor_FechaRegistra { get; set; }
        public int? Hor_UsuarioModifica { get; set; }
        public DateTime? Hor_FechaModifica { get; set; }
    }
}
