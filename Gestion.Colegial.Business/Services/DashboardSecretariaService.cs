using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class DashboardSecretariaService : IDashboardSecretariaService
    {
        private readonly IDashboardSecretariaRepository _repository;
        public DashboardSecretariaService(IDashboardSecretariaRepository repository) { _repository = repository; }

        public async Task<Answer> Resumen(int Anio)
        {
            Answer answer = await _repository.Resumen(Anio);
            try
            {
                if (answer.Access) { answer.Message = MessageShow.Error; Logs.Error(answer); }
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true; answer.Message = MessageShow.Error;
                answer.Incidents(e); Logs.Error(answer);
                return answer;
            }
        }
    }
}
