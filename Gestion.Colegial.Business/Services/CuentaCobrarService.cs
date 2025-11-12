using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Services
{
    public class CuentaCobrarService : ICuentaCobrarService
    {
        private readonly ICuentaCobrarRepository _repository;

        public CuentaCobrarService(ICuentaCobrarRepository repository)
        {
            _repository = repository;
        }

        public async Task<Answer> List() => await ExecuteRepositoryMethod(() => _repository.List());
        public async Task<Answer> ListByAlumno(int alumnoId) => await ExecuteRepositoryMethod(() => _repository.ListByAlumno(alumnoId));
        public async Task<Answer> ListPendientes() => await ExecuteRepositoryMethod(() => _repository.ListPendientes());
        public async Task<Answer> ListVencidas() => await ExecuteRepositoryMethod(() => _repository.ListVencidas());
        public async Task<Answer> Find(int id) => await ExecuteRepositoryMethod(() => _repository.Find(id));
        public async Task<Answer> Detail(int id) => await ExecuteRepositoryMethod(() => _repository.Detail(id));
        public async Task<Answer> Delete(int id) => await ExecuteRepositoryMethod(() => _repository.Delete(id), MessageShow.SuccessDelete);
        public async Task<Answer> GenerarCargosAlumno(int alumnoId, int anio) => await ExecuteRepositoryMethod(() => _repository.GenerarCargosAlumno(alumnoId, anio));
        public async Task<Answer> AplicarDescuento(int cuentaCobrarId, int descuentoId, decimal monto, string justificacion) =>
            await ExecuteRepositoryMethod(() => _repository.AplicarDescuento(cuentaCobrarId, descuentoId, monto, justificacion));
        public async Task<Answer> CalcularMoratoria(int cuentaCobrarId) => await ExecuteRepositoryMethod(() => _repository.CalcularMoratoria(cuentaCobrarId));

        public async Task<Answer> Create(object obj) => await ExecuteRepositoryMethod(() => _repository.Create(obj as dynamic), MessageShow.SuccessSave);
        public async Task<Answer> Edit(object obj) => await ExecuteRepositoryMethod(() => _repository.Edit(obj as dynamic), MessageShow.SuccessEdit);

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
