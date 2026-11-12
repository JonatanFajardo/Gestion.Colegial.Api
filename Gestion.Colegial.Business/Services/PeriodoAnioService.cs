using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Services
{
    public class PeriodoAnioService : IPeriodoAnioService
    {
        private readonly IPeriodoAnioRepository _repository;

        public PeriodoAnioService(IPeriodoAnioRepository repository)
        {
            _repository = repository;
        }

        public async Task<Answer> List(int anioId)
        {
            Answer answer = await _repository.List(anioId);
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

        public async Task<Answer> Create(tbPeriodosAnio obj)
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

                var insertResult = answer.Data as PR_tbPeriodosAnio_InsertResult;
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

        public async Task<Answer> Edit(tbPeriodosAnio obj)
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
