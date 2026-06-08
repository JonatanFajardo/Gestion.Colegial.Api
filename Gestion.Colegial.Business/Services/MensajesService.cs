using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class MensajesService : IMensajesService
    {
        private readonly IMensajesRepository _r;
        public MensajesService(IMensajesRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> t, string msg = null)
        {
            Answer a = await t;
            try
            {
                if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); }
                else if (msg != null) a.Message = msg;
                return a;
            }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }
        }

        public Task<Answer> List(int? Alu_Id, int? UsuarioId)
            => Wrap(_r.List(Alu_Id, UsuarioId));

        public Task<Answer> Insert(string Msg_Asunto, string Msg_Contenido, int Alu_Id, int UsuarioEnvia)
            => Wrap(_r.Insert(Msg_Asunto, Msg_Contenido, Alu_Id, UsuarioEnvia), MessageShow.SuccessSave);

        public Task<Answer> Delete(int Msg_Id, int UsuarioModifica)
            => Wrap(_r.Delete(Msg_Id, UsuarioModifica), MessageShow.SuccessDelete);
    }
}
