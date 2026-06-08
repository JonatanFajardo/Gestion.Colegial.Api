using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class AlumnosEnRiesgoService : IAlumnosEnRiesgoService
    {
        private readonly IAlumnosEnRiesgoRepository _repository;
        public AlumnosEnRiesgoService(IAlumnosEnRiesgoRepository repository) { _repository = repository; }

        public async Task<Answer> List(decimal? PromedioMinimo, int? Anio)
        {
            Answer answer = await _repository.List(PromedioMinimo, Anio);
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
