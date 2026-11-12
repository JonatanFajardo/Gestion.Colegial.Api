using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Reporte de asistencia de alumnos. La asistencia diaria de un alumno resume sus registros del día:
    /// P presente, T tardanza, A ausente, J justificado. % asistencia = (P+T) / (P+T+A+J).
    /// En riesgo = menos de 90 % o 3 o más ausencias sin justificar en el rango.
    /// </summary>
    public class ReporteAsistenciaService : IReporteAsistenciaService
    {
        private readonly IReporteAsistenciaRepository _repository;

        public ReporteAsistenciaService(IReporteAsistenciaRepository repository)
        {
            _repository = repository;
        }

        /// <summary>Marca el error para el log sin perder Data (las lecturas devuelven "" al fallar).</summary>
        private static Answer Revisar(Answer answer)
        {
            if (answer.Access)
            {
                answer.Message = MessageShow.Error;
                Logs.Error(answer);
            }
            return answer;
        }

        /// <summary>Para los procedimientos de una fila: sin fila (Data null) no es un error.</summary>
        private static Answer UnaFila(Answer answer) =>
            answer.Access && answer.Data == null ? answer : Revisar(answer);

        /// <summary>Si el rango llega al revés, se ordena.</summary>
        private static (DateTime Desde, DateTime Hasta) Rango(DateTime desde, DateTime hasta) =>
            desde.Date <= hasta.Date ? (desde.Date, hasta.Date) : (hasta.Date, desde.Date);

        public async Task<Answer> Anio(DateTime fecha) => UnaFila(await _repository.Anio(fecha.Date));
        public async Task<Answer> Periodos(int aniId) => Revisar(await _repository.Periodos(aniId));
        public async Task<Answer> Filtros(int aniId, int? empId) => Revisar(await _repository.Filtros(aniId, empId));

        public async Task<Answer> Secciones(int aniId, DateTime desde, DateTime hasta, int? nivId, int? cunId, int? seaId, int? empId)
        {
            var r = Rango(desde, hasta);
            return Revisar(await _repository.Secciones(aniId, r.Desde, r.Hasta, nivId, cunId, seaId, empId));
        }

        public async Task<Answer> SeccionInfo(int seaId) => UnaFila(await _repository.SeccionInfo(seaId));

        public async Task<Answer> Alumnos(int seaId, DateTime desde, DateTime hasta)
        {
            var r = Rango(desde, hasta);
            return Revisar(await _repository.Alumnos(seaId, r.Desde, r.Hasta));
        }

        public async Task<Answer> Dias(int seaId, DateTime desde, DateTime hasta)
        {
            var r = Rango(desde, hasta);
            return Revisar(await _repository.Dias(seaId, r.Desde, r.Hasta));
        }

        public async Task<Answer> Planilla(int seaId, DateTime desde, DateTime hasta)
        {
            var r = Rango(desde, hasta);
            return Revisar(await _repository.Planilla(seaId, r.Desde, r.Hasta));
        }
    }
}
