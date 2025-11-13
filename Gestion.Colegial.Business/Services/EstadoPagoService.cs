using AutoMapper;
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Services
{
    public class EstadoPagoService : IEstadoPagoService
    {
        private readonly IEstadoPagoRepository _repository;
        private readonly IMapper _mapper;

        public EstadoPagoService(IEstadoPagoRepository repository, IMapper mapper)
        {
            _repository = repository;
            _mapper = mapper;
        }

        public async Task<Answer> List()
        {
            Answer answer = await _repository.List();
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                if (answer.Data is IEnumerable<PR_tbEstadosPago_ListResult> resultList)
                {
                    answer.Data = _mapper.Map<List<EstadoPagoListDto>>(resultList);
                }

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

        public async Task<Answer> Find(int id)
        {
            Answer answer = await _repository.Find(id);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                if (answer.Data is PR_tbEstadosPago_FindResult result)
                {
                    answer.Data = _mapper.Map<EstadoPagoFindDto>(result);
                }

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

        public async Task<Answer> Dropdown()
        {
            Answer answer = await _repository.Dropdown();
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                if (answer.Data is IEnumerable<PR_tbEstadosPago_DropdownResult> resultList)
                {
                    answer.Data = _mapper.Map<List<EstadoPagoDropdownDto>>(resultList);
                }

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
