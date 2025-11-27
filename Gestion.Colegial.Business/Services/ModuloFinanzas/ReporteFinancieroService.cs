using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces.ModuloFinanzas;
using Gestion.Colegial.DataAccess.Interfaces.Finanzas;
using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Services.ModuloFinanzas
{
    public class ReporteFinancieroService : IReporteFinancieroService
    {
        private readonly IReporteFinancieroRepository _repository;

        public ReporteFinancieroService(IReporteFinancieroRepository repository)
        {
            _repository = repository;
        }

        public async Task<Answer> IngresosPorMes(int anio, int mes) => await ExecuteRepositoryMethod(() => _repository.IngresosPorMes(anio, mes));
        public async Task<Answer> ProyeccionCobros(int anio, int mes) => await ExecuteRepositoryMethod(() => _repository.ProyeccionCobros(anio, mes));
        public async Task<Answer> ListadoMorosos() => await ExecuteRepositoryMethod(() => _repository.ListadoMorosos());
        public async Task<Answer> EstadoCuentaAlumno(int alumnoId) => await ExecuteRepositoryMethod(() => _repository.EstadoCuentaAlumno(alumnoId));
        public async Task<Answer> ComparativaAnual(int anioInicio, int anioFin) =>
            await ExecuteRepositoryMethod(() => _repository.ComparativaAnual(anioInicio, anioFin));

        private async Task<Answer> ExecuteRepositoryMethod(Func<Task<Answer>> method, string successMessage = null)
        {
            Answer answer = await method();
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                if (successMessage != null) answer.Message = successMessage;
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
