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
    public class CuentaCobrarService : ICuentaCobrarService
    {
        private readonly ICuentaCobrarRepository _repository;
        private readonly IMapper _mapper;

        public CuentaCobrarService(ICuentaCobrarRepository repository, IMapper mapper)
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

                // Mapear de PR_tbCuentasCobrar_ListResult a CuentaCobrarListDto
                if (answer.Data is IEnumerable<PR_tbCuentasCobrar_ListResult> resultList)
                {
                    answer.Data = _mapper.Map<List<CuentaCobrarListDto>>(resultList);
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

                // Mapear de PR_tbCuentasCobrar_FindResult a CuentaCobrarFindDto
                if (answer.Data is PR_tbCuentasCobrar_FindResult result)
                {
                    answer.Data = _mapper.Map<CuentaCobrarFindDto>(result);
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

                // Mapear de PR_tbCuentasCobrar_DetailResult a CuentaCobrarDetailDto
                if (answer.Data is PR_tbCuentasCobrar_DetailResult result)
                {
                    answer.Data = _mapper.Map<CuentaCobrarDetailDto>(result);
                }

                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
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

                if (answer.Data is IEnumerable<PR_tbCuentasCobrar_ListByAlumnoResult> resultList)
                {
                    answer.Data = _mapper.Map<List<CuentaCobrarListDto>>(resultList);
                }

                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
            }
        }

        public async Task<Answer> ListPendientes() => await ExecuteSimple(() => _repository.ListPendientes(), typeof(PR_tbCuentasCobrar_ListPendientesResult), typeof(CuentaCobrarListDto));
        public async Task<Answer> ListVencidas() => await ExecuteSimple(() => _repository.ListVencidas(), typeof(PR_tbCuentasCobrar_ListVencidasResult), typeof(CuentaCobrarListDto));

        public async Task<Answer> ListDeudores()
        {
            Answer answer = await _repository.ListDeudores();
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
            }
        }

        public async Task<Answer> Create(object obj)
        {
            var ent = CuentasCobrarConversion.Create(obj);
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
            var ent = CuentasCobrarConversion.Edit(obj);
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

        public async Task<Answer> GenerarCargosAlumno(int alumnoId, int anio)
        {
            Answer answer = await _repository.GenerarCargosAlumno(alumnoId, anio);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                }
                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
            }
        }

        public async Task<Answer> AplicarDescuento(int cuentaCobrarId, int descuentoId, decimal monto, string justificacion)
        {
            Answer answer = await _repository.AplicarDescuento(cuentaCobrarId, descuentoId, monto, justificacion);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                }
                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
            }
        }

        public async Task<Answer> CalcularMoratoria(int cuentaCobrarId)
        {
            Answer answer = await _repository.CalcularMoratoria(cuentaCobrarId);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                }
                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
            }
        }

        public async Task<Answer> GenerarCargosMasivos(object filtros)
        {
            Answer answer = await _repository.GenerarCargosMasivos(filtros);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                }
                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
            }
        }

        public async Task<Answer> PrevisualizarCargos(object filtros)
        {
            Answer answer = await _repository.PrevisualizarCargos(filtros);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                }
                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
            }
        }

        public async Task<Answer> GenerarMensualidad(object request)
        {
            dynamic req = request;
            byte mes = req.mes;
            short anio = req.anio;
            int usuarioId = req.usuarioId;
            int? conceptoMensualidadId = req.conceptoMensualidadId;

            Answer answer = await _repository.GenerarMensualidad(mes, anio, usuarioId, conceptoMensualidadId);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                if (answer.Data is IEnumerable<PR_GenerarMensualidadResult> resultList)
                {
                    answer.Data = _mapper.Map<List<GenerarMensualidadResponseDto>>(resultList);
                }

                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
            }
        }

        public async Task<Answer> GenerarMensualidadesRango(object request)
        {
            dynamic req = request;
            byte mesInicio = req.mesInicio;
            byte mesFin = req.mesFin;
            short anio = req.anio;
            int usuarioId = req.usuarioId;

            Answer answer = await _repository.GenerarMensualidadesRango(mesInicio, mesFin, anio, usuarioId);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                if (answer.Data is IEnumerable<PR_GenerarMensualidadesRangoResult> resultList)
                {
                    answer.Data = _mapper.Map<List<GenerarMensualidadesRangoResponseDto>>(resultList);
                }

                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
            }
        }

        public async Task<Answer> MesesPendientesPorAlumno(int alumnoId, short? anio = null)
        {
            Answer answer = await _repository.MesesPendientesPorAlumno(alumnoId, anio);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                if (answer.Data is IEnumerable<PR_MesesPendientesPorAlumnoResult> resultList)
                {
                    answer.Data = _mapper.Map<List<MesPendienteDto>>(resultList);
                }

                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
            }
        }

        // ================================================
        // M�TODOS AUXILIARES
        // ================================================

        private static Answer HandleException(Answer answer, Exception e)
        {
            answer.Access = true;
            answer.Message = MessageShow.Error;
            answer.Incidents(e);
            Logs.Error(answer);
            return answer;
        }

        private async Task<Answer> ExecuteSimple(Func<Task<Answer>> func, Type resultType, Type dtoType)
        {
            Answer answer = await func();
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }

                var dataList = answer.Data as System.Collections.IEnumerable;
                if (dataList != null)
                {
                    var mappedList = _mapper.Map(typeof(List<>).MakeGenericType(dtoType), dataList);
                    answer.Data = mappedList;
                }

                return answer;
            }
            catch (Exception e)
            {
                return HandleException(answer, e);
            }
        }
    }
}
