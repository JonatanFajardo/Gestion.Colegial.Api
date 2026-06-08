using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class VacacionesService : IVacacionesService
    {
        private readonly IVacacionesRepository _r;
        public VacacionesService(IVacacionesRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> t, string msg = null)
        {
            Answer a = await t;
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } else if (msg != null) a.Message = msg; return a; }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }
        }

        public Task<Answer> List(int? Emp_Id) => Wrap(_r.List(Emp_Id));
        public Task<Answer> Insert(int Emp_Id, string Vac_Tipo, DateTime Vac_FechaInicio, DateTime Vac_FechaFin, string Vac_Motivo, int usuarioRegistra)
            => Wrap(_r.Insert(Emp_Id, Vac_Tipo, Vac_FechaInicio, Vac_FechaFin, Vac_Motivo, usuarioRegistra), MessageShow.SuccessSave);
        public Task<Answer> Approve(int Vac_Id, string Vac_Estado, int usuarioModifica)
            => Wrap(_r.Approve(Vac_Id, Vac_Estado, usuarioModifica), MessageShow.SuccessEdit);
        public Task<Answer> Delete(int Vac_Id, int usuarioModifica)
            => Wrap(_r.Delete(Vac_Id, usuarioModifica), MessageShow.SuccessDelete);
    }
}
