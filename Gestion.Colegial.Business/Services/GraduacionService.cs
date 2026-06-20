using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Servicio del modulo Graduacion. Orquesta el repositorio
    /// y propaga los mensajes de RAISERROR del SP hacia el controller.
    /// </summary>
    public class GraduacionService : IGraduacionService
    {
        private readonly IGraduacionRepository _repository;

        public GraduacionService(IGraduacionRepository repository)
        {
            _repository = repository;
        }

        public async Task<Answer> ListCandidatos()
        {
            Answer answer = await _repository.ListCandidatos();
            if (answer.Access)
            {
                if (string.IsNullOrEmpty(answer.Message)) answer.Message = MessageShow.Error;
                Logs.Error(answer);
            }
            return answer;
        }

        public async Task<Answer> GraduarAlumno(int aluId, int usuarioId)
        {
            Answer answer = await _repository.GraduarAlumno(aluId, usuarioId);
            if (answer.Access)
            {
                // El mensaje viene del SP — no lo sobrescribimos.
                Logs.Error(answer);
            }
            return answer;
        }

        public async Task<Answer> Backfill(int? anio, int topN, bool dryRun)
        {
            Answer answer = await _repository.Backfill(anio, topN, dryRun);
            if (answer.Access)
            {
                Logs.Error(answer);
            }
            return answer;
        }

        public async Task<Answer> ListGraduados()
        {
            Answer answer = await _repository.ListGraduados();
            if (answer.Access)
            {
                if (string.IsNullOrEmpty(answer.Message)) answer.Message = MessageShow.Error;
                Logs.Error(answer);
            }
            return answer;
        }

        public async Task<Answer> FindGraduado(int aluGradId)
        {
            Answer answer = await _repository.FindGraduado(aluGradId);
            if (answer.Access)
            {
                if (string.IsNullOrEmpty(answer.Message)) answer.Message = MessageShow.Error;
                Logs.Error(answer);
            }
            return answer;
        }
    }
}
