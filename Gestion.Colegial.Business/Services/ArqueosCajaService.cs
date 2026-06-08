using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class ArqueosCajaService : IArqueosCajaService
    {
        private readonly IArqueosCajaRepository _r;
        public ArqueosCajaService(IArqueosCajaRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> t, string msg = null)
        {
            Answer a = await t;
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } else if (msg != null) a.Message = msg; return a; }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }
        }

        public Task<Answer> Find(int Arq_Id) => Wrap(_r.Find(Arq_Id));
        public Task<Answer> LastByUsuario(int Usu_Id) => Wrap(_r.LastByUsuario(Usu_Id));
        public Task<Answer> Insert(int Usu_Id, DateTime Arq_Fecha, decimal Arq_TotalEfectivo, decimal Arq_TotalTransferencia, decimal Arq_TotalTarjeta, string Arq_Observaciones, int usuarioRegistra)
            => Wrap(_r.Insert(Usu_Id, Arq_Fecha, Arq_TotalEfectivo, Arq_TotalTransferencia, Arq_TotalTarjeta, Arq_Observaciones, usuarioRegistra), MessageShow.SuccessSave);
    }
}
