using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class HorariosService : IHorariosService
    {
        private readonly IHorariosRepository _r;
        public HorariosService(IHorariosRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> task, string successMsg = null)
        {
            Answer answer = await task;
            try
            {
                if (answer.Access) { answer.Message = MessageShow.Error; Logs.Error(answer); }
                else if (successMsg != null) answer.Message = successMsg;
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true; answer.Message = MessageShow.Error;
                answer.Incidents(e); Logs.Error(answer); return answer;
            }
        }

        public Task<Answer> List() => Wrap(_r.List());
        public Task<Answer> Find(int Hor_Id) => Wrap(_r.Find(Hor_Id));

        public Task<Answer> Insert(int Cur_Id, int Cun_Id, int Mat_Id, int Emp_Id, int Sec_Id,
            int Aul_Id, int Dia_Id, int Hor_HoraInicio, int Hor_HoraFinaliza, int Sem_Id,
            int? Mda_Id, int Hor_Año, int usuarioRegistra)
            => Wrap(_r.Insert(Cur_Id, Cun_Id, Mat_Id, Emp_Id, Sec_Id, Aul_Id, Dia_Id,
                              Hor_HoraInicio, Hor_HoraFinaliza, Sem_Id, Mda_Id, Hor_Año,
                              usuarioRegistra), MessageShow.SuccessSave);

        public Task<Answer> Edit(int Hor_Id, int Cur_Id, int Cun_Id, int Mat_Id, int Emp_Id,
            int Sec_Id, int Aul_Id, int Dia_Id, int Hor_HoraInicio, int Hor_HoraFinaliza,
            int Sem_Id, int? Mda_Id, int Hor_Año, int usuarioModifica)
            => Wrap(_r.Edit(Hor_Id, Cur_Id, Cun_Id, Mat_Id, Emp_Id, Sec_Id, Aul_Id, Dia_Id,
                            Hor_HoraInicio, Hor_HoraFinaliza, Sem_Id, Mda_Id, Hor_Año,
                            usuarioModifica), MessageShow.SuccessEdit);

        public Task<Answer> Remove(int Hor_Id, int usuarioModifica)
            => Wrap(_r.Remove(Hor_Id, usuarioModifica), MessageShow.SuccessDelete);
    }
}
