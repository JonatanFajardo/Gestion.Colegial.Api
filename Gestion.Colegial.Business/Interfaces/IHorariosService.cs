using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IHorariosService
    {
        Task<Answer> List();
        Task<Answer> Find(int Hor_Id);
        Task<Answer> Insert(int Cur_Id, int Cun_Id, int Mat_Id, int Emp_Id, int Sec_Id, int Aul_Id,
                            int Dia_Id, int Hor_HoraInicio, int Hor_HoraFinaliza, int Sem_Id,
                            int? Mda_Id, int Hor_Año, int usuarioRegistra);
        Task<Answer> Edit(int Hor_Id, int Cur_Id, int Cun_Id, int Mat_Id, int Emp_Id, int Sec_Id,
                          int Aul_Id, int Dia_Id, int Hor_HoraInicio, int Hor_HoraFinaliza,
                          int Sem_Id, int? Mda_Id, int Hor_Año, int usuarioModifica);
        Task<Answer> Remove(int Hor_Id, int usuarioModifica);
    }
}
