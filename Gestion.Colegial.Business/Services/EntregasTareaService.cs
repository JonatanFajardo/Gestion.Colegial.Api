using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class EntregasTareaService : IEntregasTareaService
    {
        private readonly IEntregasTareaRepository _r;
        public EntregasTareaService(IEntregasTareaRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> task, string msg = null)
        {
            var a = await task;
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } else if (msg != null) a.Message = msg; }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); }
            return a;
        }

        public Task<Answer> List(int Tar_Id) => Wrap(_r.List(Tar_Id));
        public Task<Answer> Upsert(int Tar_Id, int Alu_Id, bool Ent_Entregado, string Ent_Observacion, int usuarioRegistra)
            => Wrap(_r.Upsert(Tar_Id, Alu_Id, Ent_Entregado, Ent_Observacion, usuarioRegistra), MessageShow.SuccessSave);
        public Task<Answer> Update(int Ent_Id, decimal Ent_Nota, string Ent_Observacion, int usuarioModifica)
            => Wrap(_r.Update(Ent_Id, Ent_Nota, Ent_Observacion, usuarioModifica), MessageShow.SuccessEdit);
    }
}
