using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Centro de reportes. Si un rango de fechas llega al revés se ordena.
    /// Los errores quedan en el log; el controlador responde con error para que el ADM marque la corrida como fallida.
    /// </summary>
    public class CentroReportesService : ICentroReportesService
    {
        private readonly ICentroReportesRepository _repository;

        public CentroReportesService(ICentroReportesRepository repository)
        {
            _repository = repository;
        }

        private static Answer Revisar(Answer answer)
        {
            if (answer.Access)
            {
                answer.Message = MessageShow.Error;
                Logs.Error(answer);
            }
            return answer;
        }

        private static (DateTime Desde, DateTime Hasta) Rango(DateTime desde, DateTime hasta) =>
            desde.Date <= hasta.Date ? (desde.Date, hasta.Date) : (hasta.Date, desde.Date);

        public async Task<Answer> ListaClase(int aniId, int? nivId, int? cunId, int? seaId, bool soloActivos, DateTime hoy) =>
            Revisar(await _repository.ListaClase(aniId, nivId, cunId, seaId, soloActivos, hoy));

        public async Task<Answer> SaldosAlumno(int aniId, int? nivId, int? cunId, int? seaId, bool soloConSaldo, DateTime hoy) =>
            Revisar(await _repository.SaldosAlumno(aniId, nivId, cunId, seaId, soloConSaldo, hoy));

        public async Task<Answer> IngresosConcepto(DateTime desde, DateTime hasta, int? cpaId, int? fpaId)
        {
            var r = Rango(desde, hasta);
            return Revisar(await _repository.IngresosConcepto(r.Desde, r.Hasta, cpaId, fpaId));
        }

        public async Task<Answer> AsistenciaPersonal(DateTime desde, DateTime hasta)
        {
            var r = Rango(desde, hasta);
            return Revisar(await _repository.AsistenciaPersonal(r.Desde, r.Hasta));
        }

        public async Task<Answer> Registrar(ReporteGeneradoDTO obj)
        {
            if (obj == null || obj.Usu_Id <= 0 || string.IsNullOrWhiteSpace(obj.Rge_Clave))
                return new Answer { Access = true, Message = "Faltan datos del reporte." };
            return Revisar(await _repository.Registrar(obj));
        }

        public async Task<Answer> Recientes(int usuId, int top) =>
            Revisar(await _repository.Recientes(usuId, top));
    }
}
