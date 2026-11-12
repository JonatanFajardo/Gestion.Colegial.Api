using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class PlanClasesService : IPlanClasesService
    {
        private readonly IPlanClasesRepository _r;
        public PlanClasesService(IPlanClasesRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> task, string msg = null)
        {
            var a = await task;
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } else if (msg != null) a.Message = msg; }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); }
            return a;
        }

        public Task<Answer> List(int Hor_Id)   => Wrap(_r.List(Hor_Id));
        public Task<Answer> Find(int Pla_Id)   => Wrap(_r.Find(Pla_Id));
        public Task<Answer> Insert(int Hor_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, int usuarioRegistra)
            => Wrap(_r.Insert(Hor_Id, Pla_Semana, Pla_Tema, Pla_Objetivos, Pla_Recursos, usuarioRegistra), MessageShow.SuccessSave);
        public Task<Answer> Update(int Pla_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, string Pla_Estado, int usuarioModifica)
            => Wrap(_r.Update(Pla_Id, Pla_Semana, Pla_Tema, Pla_Objetivos, Pla_Recursos, Pla_Estado, usuarioModifica), MessageShow.SuccessEdit);
        public Task<Answer> Delete(int Pla_Id, int usuarioModifica)
            => Wrap(_r.Delete(Pla_Id, usuarioModifica), MessageShow.SuccessDelete);
    }
}
