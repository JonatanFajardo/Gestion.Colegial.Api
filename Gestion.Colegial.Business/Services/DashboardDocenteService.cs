using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class DashboardDocenteService : IDashboardDocenteService
    {
        private readonly IDashboardDocenteRepository _repository;
        public DashboardDocenteService(IDashboardDocenteRepository repository) { _repository = repository; }

        public async Task<Answer> Resumen(int Emp_Id, int Dia_Id, int Anio)
        {
            Answer answer = await _repository.Resumen(Emp_Id, Dia_Id, Anio);
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
