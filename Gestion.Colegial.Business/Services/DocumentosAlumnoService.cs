using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class DocumentosAlumnoService : IDocumentosAlumnoService
    {
        private readonly IDocumentosAlumnoRepository _r;
        public DocumentosAlumnoService(IDocumentosAlumnoRepository r) { _r = r; }

        public async Task<Answer> List(int Alu_Id)
        {
            Answer answer = await _r.List(Alu_Id);
            try { if (answer.Access) { answer.Message = MessageShow.Error; Logs.Error(answer); } return answer; }
            catch (Exception e) { answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> PendientesList()
        {
            Answer answer = await _r.PendientesList();
            try { if (answer.Access) { answer.Message = MessageShow.Error; Logs.Error(answer); } return answer; }
            catch (Exception e) { answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Update(int Alu_Id, int TDoc_Id, bool Doa_EsEntregado, DateTime? Doa_FechaEntrega, string Doa_Observacion, int usuarioRegistra)
        {
            Answer answer = await _r.Update(Alu_Id, TDoc_Id, Doa_EsEntregado, Doa_FechaEntrega, Doa_Observacion, usuarioRegistra);
            try { if (answer.Access) { answer.Message = MessageShow.Error; Logs.Error(answer); } else answer.Message = MessageShow.SuccessEdit; return answer; }
            catch (Exception e) { answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }
        }
    }
}
