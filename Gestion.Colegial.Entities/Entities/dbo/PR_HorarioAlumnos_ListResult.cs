using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gestion.Colegial.Entities.Entities.dbo
{
    public class PR_tbHorarioAlumnos_ListResult
    {
        public int HoAl_Id { get; set; }

        // Curso
        public int Cur_Id { get; set; }
        public string? Cur_Nombre { get; set; }

        // Nivel / curso-nivel
        public int Cun_Id { get; set; }
        public string? Cun_Descripcion { get; set; }

        // Materia
        public int Mat_Id { get; set; }
        public string? Mat_Nombre { get; set; }

        // Sección
        public int? Sec_Id { get; set; }
        public string? Sec_Descripcion { get; set; }

        // Aula
        public int? Aul_Id { get; set; }
        public string? Aul_Descripcion { get; set; }

        // Profesor / empleado
        public int? Emp_Id { get; set; }
        public string? ProfesorNombre { get; set; }

        // Semestre
        public int? Sem_Id { get; set; }
        public string? Sem_Descripcion { get; set; }

        // Modalidad
        public int? Mda_Id { get; set; }
        public string? ModalidadDescripcion { get; set; }

        // Año académico
        public int? HoAl_Año { get; set; }

        // Horarios y día
        public string? HoraInicio { get; set; }
        public string? HoraFinaliza { get; set; }
        public string? Dia_Descripcion { get; set; }

        // Auditoría básica
        public int HoAl_UsuarioRegistra { get; set; }
        public string? HoAl_UsuarioRegistraNombre { get; set; }
        public DateTime HoAl_FechaRegistra { get; set; }

        // Opcional: datos de modificación
        public int? HoAl_UsuarioModifica { get; set; }
        public string? HoAl_UsuarioModificaNombre { get; set; }
        public DateTime? HoAl_FechaModifica { get; set; }

        // Estado lógico
        public bool HoAl_EsEliminado { get; set; }
    }
}
