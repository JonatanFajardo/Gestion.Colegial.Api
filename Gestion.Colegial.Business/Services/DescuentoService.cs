using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Services
{
    public class DescuentoService : IDescuentoService
    {
        private readonly IDescuentoRepository _repository;

        public DescuentoService(IDescuentoRepository repository)
        {
            _repository = repository;
        }

        public async Task<Answer> List() => await ExecuteRepositoryMethod(() => _repository.List());
        public async Task<Answer> Find(int id) => await ExecuteRepositoryMethod(() => _repository.Find(id));
        public async Task<Answer> Detail(int id) => await ExecuteRepositoryMethod(() => _repository.Detail(id));
        public async Task<Answer> Delete(int id) => await ExecuteRepositoryMethod(() => _repository.Delete(id), MessageShow.SuccessDelete);
        public async Task<Answer> Dropdown() => await ExecuteRepositoryMethod(() => _repository.Dropdown());

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
