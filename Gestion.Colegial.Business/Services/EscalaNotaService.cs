using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Services
{
    public class EscalaNotaService : IEscalaNotaService
    {
        private readonly IEscalaNotaRepository _repository;

        public EscalaNotaService(IEscalaNotaRepository repository)
        {
            _repository = repository;
        }

        private static Answer Marca(Answer answer, string exito)
        {
            if (answer.Access)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                Logs.Error(answer);
                return answer;
            }
            answer.Message = exito;
            return answer;
        }

        public async Task<Answer> List()
        {
            Answer answer = await _repository.List();
            try { return Marca(answer, answer.Message); }
            catch (Exception e) { answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Find(int id)
        {
            Answer answer = await _repository.Find(id);
            try { return Marca(answer, answer.Message); }
            catch (Exception e) { answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Detail(int id)
        {
            Answer answer = await _repository.Detail(id);
            try { return Marca(answer, answer.Message); }
            catch (Exception e) { answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Create(tbEscalaNotas obj)
        {
            Answer answer = await _repository.Create(obj);
            try { return Marca(answer, MessageShow.SuccessSave); }
            catch (Exception e) { answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Edit(tbEscalaNotas obj)
        {
            Answer answer = await _repository.Edit(obj);
            try { return Marca(answer, MessageShow.SuccessEdit); }
            catch (Exception e) { answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        /// <summary>Data = la fila que choca (o null si el rango está libre). No es error que sea null.</summary>
        public async Task<Answer> Solapa(decimal desde, decimal hasta, int? id)
        {
            Answer answer = await _repository.Solapa(desde, hasta, id);
            try { return answer; }
            catch (Exception e) { answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Delete(int id)
        {
            Answer answer = await _repository.Delete(id);
            try { return Marca(answer, MessageShow.SuccessDelete); }
            catch (Exception e) { answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> ConfigGet()
        {
            Answer answer = await _repository.ConfigGet();
            try { return Marca(answer, answer.Message); }
            catch (Exception e) { answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> ConfigSet(tbCuadroHonorConfig obj)
        {
            Answer answer = await _repository.ConfigSet(obj);
            try { return Marca(answer, MessageShow.SuccessEdit); }
            catch (Exception e) { answer.Access = true; answer.Message = MessageShow.Error; answer.Incidents(e); Logs.Error(answer); return answer; }
        }
    }
}
