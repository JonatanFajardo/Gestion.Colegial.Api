using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Services
{
    public class RolloverService : IRolloverService
    {
        private readonly IRolloverRepository _repository;

        public RolloverService(IRolloverRepository repository)
        {
            _repository = repository;
        }

        public async Task<Answer> RollForward(int origen, int destino)
        {
            Answer answer = await _repository.RollForward(origen, destino);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
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
