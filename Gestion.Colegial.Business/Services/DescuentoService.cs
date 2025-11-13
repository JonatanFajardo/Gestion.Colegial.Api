using AutoMapper;
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;
using Gestion.Colegial.Entities.Entities;
using static Gestion.Colegial.Business.Extensions.CustomMapping;

namespace Gestion.Colegial.Business.Services
{
    public class DescuentoService : IDescuentoService
    {
        private readonly IDescuentoRepository _repository;
        private readonly IMapper _mapper;

        public DescuentoService(IDescuentoRepository repository, IMapper mapper)
        {
            _repository = repository;
            _mapper = mapper;
        }

        // ============================================================
        // MÉTODOS PRINCIPALES
        // ============================================================

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

                // Mapear de PR_tbDescuentos_ListResult a DescuentoListDto
                if (answer.Data is IEnumerable<PR_tbDescuentos_ListResult> resultList)
                {
                    answer.Data = _mapper.Map<List<DescuentoListDto>>(resultList);
                }

                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
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

                // Mapear de PR_tbDescuentos_FindResult a DescuentoFindDto
                if (answer.Data is PR_tbDescuentos_FindResult result)
                {
                    answer.Data = _mapper.Map<DescuentoFindDto>(result);
                }

                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
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

                // Mapear de PR_tbDescuentos_DetailResult a DescuentoDetailDto
                if (answer.Data is PR_tbDescuentos_DetailResult result)
                {
                    answer.Data = _mapper.Map<DescuentoDetailDto>(result);
                }

                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
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

                // Mapear de PR_tbDescuentos_DropdownResult a DescuentoDropdownDto
                if (answer.Data is IEnumerable<PR_tbDescuentos_DropdownResult> resultList)
                {
                    answer.Data = _mapper.Map<List<DescuentoDropdownDto>>(resultList);
                }

                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
            }
        }

        // ============================================================
        // CREATE / EDIT / DELETE
        // ============================================================

        public async Task<Answer> Create(object obj)
        {
            var ent = DescuentosConversion.Create(obj);
            Answer answer = await _repository.Create(ent);
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
                return HandleException(answer, e);
            }
        }

        public async Task<Answer> Edit(object obj)
        {
            var ent = DescuentosConversion.Edit(obj);
            Answer answer = await _repository.Edit(ent);
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
                return HandleException(answer, e);
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
                return HandleException(answer, e);
            }
        }

        // ============================================================
        // MÉTODOS AUXILIARES
        // ============================================================

        private static Answer HandleException(Answer answer, Exception e)
        {
            answer.Access = true;
            answer.Message = MessageShow.Error;
            answer.Incidents(e);
            Logs.Error(answer);
            return answer;
        }
    }
}
