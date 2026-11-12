using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class CentroAnunciosService : ICentroAnunciosService
    {
        private readonly ICentroAnunciosRepository _r;
        public CentroAnunciosService(ICentroAnunciosRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> t, string msg = null)
        {
            Answer a = await t;
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } else if (msg != null) a.Message = msg; return a; }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }
        }

        public Task<Answer> List() => Wrap(_r.List());
        public Task<Answer> Insert(string Anu_Titulo, string Anu_Contenido, DateTime? Anu_FechaExpiracion, int UsuarioRegistra)
            => Wrap(_r.Insert(Anu_Titulo, Anu_Contenido, Anu_FechaExpiracion, UsuarioRegistra), MessageShow.SuccessSave);
        public Task<Answer> Delete(int Anu_Id, int UsuarioModifica)
            => Wrap(_r.Delete(Anu_Id, UsuarioModifica), MessageShow.SuccessDelete);
    }
}
