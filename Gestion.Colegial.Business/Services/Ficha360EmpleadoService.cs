using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class Ficha360EmpleadoService : IFicha360EmpleadoService
    {
        private readonly IFicha360EmpleadoRepository _repository;
        public Ficha360EmpleadoService(IFicha360EmpleadoRepository repository) { _repository = repository; }

        public async Task<Answer> Resumen(int Emp_Id)
        {
            Answer answer = await _repository.Resumen(Emp_Id);
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
