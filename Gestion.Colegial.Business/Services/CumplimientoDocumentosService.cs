using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class CumplimientoDocumentosService : ICumplimientoDocumentosService
    {
        private readonly ICumplimientoDocumentosRepository _r;
        public CumplimientoDocumentosService(ICumplimientoDocumentosRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> t, string msg = null)
        {
            Answer a = await t;
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } else if (msg != null) a.Message = msg; return a; }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }
        }

        public Task<Answer> List(int? Emp_Id) => Wrap(_r.List(Emp_Id));

        public Task<Answer> MarcarEntregado(int Emp_Id, string Documento, bool EsEntregado, DateTime? FechaEntrega, DateTime? Doc_FechaVencimiento, string Observacion, int usuarioRegistra) =>
            Wrap(_r.MarcarEntregado(Emp_Id, Documento, EsEntregado, FechaEntrega, Doc_FechaVencimiento, Observacion, usuarioRegistra), MessageShow.SuccessEdit);
    }
}
