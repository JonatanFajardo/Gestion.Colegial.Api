using AutoMapper;
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Services
{
    public class PagoService : IPagoService
    {
        private readonly IPagoRepository _repository;
        private readonly IMapper _mapper;

        public PagoService(IPagoRepository repository, IMapper mapper)
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

                // Mapear de PR_tbPagos_ListResult a PagoListDto
                if (answer.Data != null)
                {
                    var resultList = answer.Data as IEnumerable<PR_tbPagos_ListResult>;
                    if (resultList != null)
                    {
                        answer.Data = _mapper.Map<List<PagoListDto>>(resultList);
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

        public async Task<Answer> ListByAlumno(int alumnoId)
        {
            Answer answer = await _repository.ListByAlumno(alumnoId);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                // Mapear de PR_tbPagos_ListByAlumnoResult a PagoListDto
                if (answer.Data != null)
                {
                    var resultList = answer.Data as IEnumerable<PR_tbPagos_ListByAlumnoResult>;
                    if (resultList != null)
                    {
                        answer.Data = _mapper.Map<List<PagoListDto>>(resultList);
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

        public async Task<Answer> ListByFecha(DateTime fecha)
        {
            Answer answer = await _repository.ListByFecha(fecha);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                // Mapear de PR_tbPagos_ListByFechaResult a PagoListDto
                if (answer.Data != null)
                {
                    var resultList = answer.Data as IEnumerable<PR_tbPagos_ListByFechaResult>;
                    if (resultList != null)
                    {
                        answer.Data = _mapper.Map<List<PagoListDto>>(resultList);
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

        public async Task<Answer> ListByRangoFechas(DateTime fechaInicio, DateTime fechaFin)
        {
            Answer answer = await _repository.ListByRangoFechas(fechaInicio, fechaFin);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                // Mapear de PR_tbPagos_ListByRangoFechasResult a PagoListDto
                if (answer.Data != null)
                {
                    var resultList = answer.Data as IEnumerable<PR_tbPagos_ListByRangoFechasResult>;
                    if (resultList != null)
                    {
                        answer.Data = _mapper.Map<List<PagoListDto>>(resultList);
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

                // Mapear de PR_tbPagos_FindResult a PagoFindDto
                if (answer.Data != null)
                {
                    var result = answer.Data as PR_tbPagos_FindResult;
                    if (result != null)
                    {
                        answer.Data = _mapper.Map<PagoFindDto>(result);
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

                // Mapear de PR_tbPagos_DetailResult a PagoDetailDto
                if (answer.Data != null)
                {
                    var result = answer.Data as PR_tbPagos_DetailResult;
                    if (result != null)
                    {
                        answer.Data = _mapper.Map<PagoDetailDto>(result);
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

        public async Task<Answer> GetRecibo(int pagoId)
        {
            Answer answer = await _repository.GetRecibo(pagoId);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                // Mapear de PR_tbPagos_GetReciboResult a DTO si es necesario
                if (answer.Data != null)
                {
                    var result = answer.Data as PR_tbPagos_GetReciboResult;
                    if (result != null)
                    {
                        answer.Data = _mapper.Map<PagoDetailDto>(result);
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
