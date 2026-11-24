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
        public async Task<Answer> Insert(string Anu_Titulo, string Anu_Contenido, DateTime? Anu_FechaExpiracion, int UsuarioRegistra,
            string Anu_Publico, int? Anu_NivId, int? Anu_CunId, int? Anu_SecId)
        {
            Anu_Publico = (Anu_Publico ?? "personal").Trim().ToLowerInvariant();
            if (Anu_Publico != "todos" && Anu_Publico != "personal" && Anu_Publico != "familias")
                return new Answer { Access = true, Message = "El público del anuncio no es válido." };
            if (Anu_Publico != "familias") { Anu_NivId = null; Anu_CunId = null; Anu_SecId = null; }
            else if ((Anu_SecId.HasValue && !Anu_CunId.HasValue) || (Anu_CunId.HasValue && !Anu_NivId.HasValue))
                return new Answer { Access = true, Message = "Elija el público en orden: nivel, grado y sección." };
            return await Wrap(_r.Insert(Anu_Titulo, Anu_Contenido, Anu_FechaExpiracion, UsuarioRegistra, Anu_Publico, Anu_NivId, Anu_CunId, Anu_SecId), MessageShow.SuccessSave);
        }

        public Task<Answer> Opciones(string tipo, int? padre)
            => Wrap(_r.Opciones(tipo, padre));

        public Task<Answer> ParaFamilia(int usuId)
            => Wrap(_r.ParaFamilia(usuId));
        public Task<Answer> Delete(int Anu_Id, int UsuarioModifica)
            => Wrap(_r.Delete(Anu_Id, UsuarioModifica), MessageShow.SuccessDelete);
    }
}
