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
    public class TarifaService : ITarifaService
    {
        private readonly ITarifaRepository _repository;
        private readonly IMapper _mapper;
        
        public TarifaService(ITarifaRepository repository, IMapper mapper)
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

                // Mapear de PR_tbTarifas_ListResult a TarifaListDto
                if (answer.Data != null)
                {
                    var resultList = answer.Data as IEnumerable<PR_tbTarifas_ListResult>;
                    if (resultList != null)
                    {
                        answer.Data = _mapper.Map<List<TarifaListDto>>(resultList);
                    }
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

                // Mapear de PR_tbTarifas_FindResult a TarifaFindDto
                if (answer.Data != null)
                {
                    var result = answer.Data as PR_tbTarifas_FindResult;
                    if (result != null)
                    {
                        answer.Data = _mapper.Map<TarifaFindDto>(result);
                    }
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

                // Mapear de PR_tbTarifas_DetailResult a TarifaDetailDto
                if (answer.Data != null)
                {
                    var result = answer.Data as PR_tbTarifas_DetailResult;
                    if (result != null)
                    {
                        answer.Data = _mapper.Map<TarifaDetailDto>(result);
                    }
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
            var ent = TarifasConversion.Create(obj);
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
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }

        public async Task<Answer> Edit(object obj)
        {
            var ent = TarifasConversion.Edit(obj);
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

        public async Task<Answer> GetByConceptoAndNivel(int conceptoId, int nivelId, int anio)
        {
            Answer answer = await _repository.GetByConceptoAndNivel(conceptoId, nivelId, anio);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                // Mapear el resultado a DTO si existe
                if (answer.Data != null)
                {
                    var result = answer.Data as PR_tbTarifas_GetByConceptoAndNivelResult;
                    if (result != null)
                    {
                        answer.Data = _mapper.Map<TarifaFindDto>(result);
                    }
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
