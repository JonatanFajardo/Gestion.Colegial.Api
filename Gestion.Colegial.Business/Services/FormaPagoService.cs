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
    public class FormaPagoService : IFormaPagoService
    {
        private readonly IFormaPagoRepository _repository;
        private readonly IMapper _mapper;

        public FormaPagoService(IFormaPagoRepository repository, IMapper mapper)
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

                // Mapear de PR_tbFormasPago_ListResult a FormaPagoListDto
                if (answer.Data is IEnumerable<PR_tbFormasPago_ListResult> resultList)
                {
                    answer.Data = _mapper.Map<List<FormaPagoListDto>>(resultList);
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

                // Mapear de PR_tbFormasPago_FindResult a FormaPagoFindDto
                if (answer.Data is PR_tbFormasPago_FindResult result)
                {
                    answer.Data = _mapper.Map<FormaPagoFindDto>(result);
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

                // Mapear de PR_tbFormasPago_DetailResult a FormaPagoDetailDto
                if (answer.Data is PR_tbFormasPago_DetailResult result)
                {
                    answer.Data = _mapper.Map<FormaPagoDetailDto>(result);
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

                // Mapear de PR_tbFormasPago_DropdownResult a FormaPagoDropdownDto
                if (answer.Data is IEnumerable<PR_tbFormasPago_DropdownResult> resultList)
                {
                    answer.Data = _mapper.Map<List<FormaPagoDropdownDto>>(resultList);
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
            var ent = FormasPagoConversion.Create(obj);
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
            var ent = FormasPagoConversion.Edit(obj);
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
