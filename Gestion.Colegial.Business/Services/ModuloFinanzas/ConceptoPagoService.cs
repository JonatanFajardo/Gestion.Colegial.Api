using AutoMapper;
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces.ModuloFinanzas;
using Gestion.Colegial.DataAccess.Interfaces.Finanzas;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Services.ModuloFinanzas
{
    public class ConceptoPagoService : IConceptoPagoService
    {
        private readonly IConceptoPagoRepository _repository;
        private readonly IMapper _mapper;

        public ConceptoPagoService(IConceptoPagoRepository repository, IMapper mapper)
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

                // Mapear de PR_tbConceptosPago_ListResult a ConceptoPagoListDto
                if (answer.Data is IEnumerable<PR_tbConceptosPago_ListResult> resultList)
                {
                    answer.Data = _mapper.Map<List<ConceptoPagoListDto>>(resultList);
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

                // Mapear de PR_tbConceptosPago_FindResult a ConceptoPagoFindDto
                if (answer.Data is PR_tbConceptosPago_FindResult result)
                {
                    answer.Data = _mapper.Map<ConceptoPagoFindDto>(result);
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

        public async Task<Answer> Detail(int id)
        {
            Answer answer = await _repository.Detail(id);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                // Mapear de PR_tbConceptosPago_DetailResult a ConceptoPagoDetailDto
                if (answer.Data is PR_tbConceptosPago_DetailResult result)
                {
                    answer.Data = _mapper.Map<ConceptoPagoDetailDto>(result);
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

        public async Task<Answer> Create(object obj)
        {
            Answer answer = await _repository.Create(obj as dynamic);
            try
            {
                if (answer.Access)
                {
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

        public async Task<Answer> Edit(object obj)
        {
            Answer answer = await _repository.Edit(obj as dynamic);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                answer.Message = MessageShow.SuccessEdit;
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

        public async Task<Answer> Delete(int id)
        {
            Answer answer = await _repository.Delete(id);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                answer.Message = MessageShow.SuccessDelete;
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

                // Mapear de PR_tbConceptosPago_DropdownResult a ConceptoPagoDropdownDto
                if (answer.Data is IEnumerable<PR_tbConceptosPago_DropdownResult> resultList)
                {
                    answer.Data = _mapper.Map<List<ConceptoPagoDropdownDto>>(resultList);
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
