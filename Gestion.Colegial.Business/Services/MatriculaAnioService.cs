using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Matrícula por año + promociones (expediente/transcript, capa multi-año).
    /// </summary>
    public class MatriculaAnioService : IMatriculaAnioService
    {
        private readonly IMatriculaAnioRepository _repository;

        public MatriculaAnioService(IMatriculaAnioRepository repository)
        {
            _repository = repository;
        }

        public async Task<Answer> ListBySeccion(int seaId)
        {
            Answer answer = await _repository.ListBySeccion(seaId);
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

        public async Task<Answer> Expediente(int aluId)
        {
            Answer answer = await _repository.Expediente(aluId);
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

        public async Task<Answer> Enroll(tbMatriculaAnio obj)
        {
            Answer answer = await _repository.Enroll(obj);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                var insertResult = answer.Data as PR_tbMatriculaAnio_InsertResult;
                answer.Data = insertResult?.NewId;

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

        public async Task<Answer> Promover(int anioOrigen, int seccionOrigen, int anioDestino, int seccionDestino)
        {
            Answer answer = await _repository.Promover(anioOrigen, seccionOrigen, anioDestino, seccionDestino);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                var result = answer.Data as PR_tbMatriculaAnio_PromoverResult;
                answer.Data = result?.Promovidos ?? 0;

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
    }
}
