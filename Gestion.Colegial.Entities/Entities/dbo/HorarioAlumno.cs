using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gestion.Colegial.Entities.Entities.dbo
{
    public class HorarioAlumno
    {
        public int HoAl_Id { get; set; }
        public int Cur_Id { get; set; }
        public int Cun_Id { get; set; }
        public int Mat_Id { get; set; }
        public int HoAl_HoraInicio { get; set; }
        public int HoAl_HoraFinaliza { get; set; }
        public int Dia_Id { get; set; }
        public bool HoAl_EsEliminado { get; set; }
        public int HoAl_UsuarioRegistra { get; set; }
        public DateTime HoAl_FechaRegistra { get; set; }
        public int? HoAl_UsuarioModifica { get; set; }
        public DateTime? HoAl_FechaModifica { get; set; }
        public int Sec_Id { get; set; }
        public int Aul_Id { get; set; }
        public int Emp_Id { get; set; }
        public int Sem_Id { get; set; }
        public int Mda_Id { get; set; }
        public int HoAl_Año { get; set; }
    }
}
