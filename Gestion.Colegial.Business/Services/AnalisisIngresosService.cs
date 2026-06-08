using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class AnalisisIngresosService : IAnalisisIngresosService
    {
        private readonly IAnalisisIngresosRepository _repository;
        public AnalisisIngresosService(IAnalisisIngresosRepository repository) { _repository = repository; }

        public async Task<Answer> List(int Anio)
        {
            Answer answer = await _repository.List(Anio);
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
