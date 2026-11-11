using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Servicio de ofertas de asignatura por año (Fase 5). Clona AnioLectivoService.
    /// </summary>
    public class OfertaAnioService : IOfertaAnioService
    {
        private readonly IOfertaAnioRepository _repository;

        public OfertaAnioService(IOfertaAnioRepository repository)
        {
            _repository = repository;
        }

        public async Task<Answer> List(int aniId)
        {
            Answer answer = await _repository.List(aniId);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }

        public async Task<Answer> Find(int id)
        {
            Answer answer = await _repository.Find(id);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }

        public async Task<Answer> Create(tbOfertasAnio obj)
        {
            Answer answer = await _repository.Create(obj);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                var insertResult = answer.Data as PR_tbOfertasAnio_InsertResult;
                answer.Data = insertResult?.NewId.HasValue == true ? (int)insertResult.NewId.Value : (int?)null;

                answer.Message = MessageShow.SuccessSave;
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }

        public async Task<Answer> Edit(tbOfertasAnio obj)
        {
            Answer answer = await _repository.Edit(obj);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                answer.Message = MessageShow.SuccessEdit;
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }

        public async Task<Answer> Delete(int id)
        {
            Answer answer = await _repository.Delete(id);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                answer.Message = MessageShow.SuccessDelete;
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }
    }
}
