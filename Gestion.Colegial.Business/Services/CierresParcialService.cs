using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Cierre y publicación de parciales (espejo de Skuul exams.active / publish_result). Dirección revisa
    /// qué notas faltan, cierra el período para que nadie cambie notas, publica los resultados y, con
    /// motivo, lo reabre. Las reglas las aplica el procedimiento; aquí se repiten las de forma para
    /// responder antes.
    /// </summary>
    public class CierresParcialService : ICierresParcialService
    {
        public const int MotivoMaximo = 500;

        private readonly ICierresParcialRepository _repository;

        public CierresParcialService(ICierresParcialRepository repository)
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

        private static Answer Rechazo(string mensaje) => new Answer { Access = true, Message = mensaje, Data = "" };

        /// <summary>Un error de validación del procedimiento (THROW 50000-50099) llega tal cual; otro se registra y se generaliza.</summary>
        private static Answer Escritura(Answer answer, string general)
        {
            if (answer.Access)
            {
                string? validacion = EventosCalendarioService.MensajeDeValidacionSql(answer);
                if (validacion == null) Logs.Error(answer);
                answer.Message = validacion ?? general;
            }
            return answer;
        }

        /// <summary>Validación de forma común a todas las acciones.</summary>
        private static string? Validar(CierreParcialAccionDTO? obj, bool motivoObligatorio)
        {
            if (obj == null) return "No llegaron datos.";
            if (!obj.PuedeCerrar || obj.Usuario == null || obj.Usuario <= 0) return "No tiene permiso para cerrar ni publicar parciales.";
            if (obj.Anio < 2000 || obj.Anio > 2100) return "Elija un año válido.";
            if (obj.Sem_Id <= 0 || obj.Pac_Id <= 0) return "Elija un semestre y un parcial válidos.";
            obj.Motivo = string.IsNullOrWhiteSpace(obj.Motivo) ? null : obj.Motivo.Trim();
            if (motivoObligatorio && obj.Motivo == null) return "Escriba el motivo.";
            if (obj.Motivo != null && obj.Motivo.Length > MotivoMaximo) return $"El motivo admite hasta {MotivoMaximo} caracteres.";
            return null;
        }

        public async Task<Answer> Anios() => Revisar(await _repository.Anios());

        public async Task<Answer> Estado(int anio) => Revisar(await _repository.Estado(anio));

        public async Task<Answer> Faltantes(int anio, int semId, int pacId) => Revisar(await _repository.Faltantes(anio, semId, pacId));

        public async Task<Answer> Historial(int anio) => Revisar(await _repository.Historial(anio));

        public async Task<Answer> Periodos(int? anio, int? semId, int? pacId, int? notId) =>
            Revisar(await _repository.Periodos(anio, semId, pacId, notId));

        public async Task<Answer> Cerrar(CierreParcialAccionDTO obj)
        {
            string? problema = Validar(obj, motivoObligatorio: false);
            if (problema != null) return Rechazo(problema);
            if (obj.ConfirmarFaltantes && obj.Motivo == null) return Rechazo("Escriba por qué cierra el parcial con notas faltantes.");
            return Escritura(await _repository.Cerrar(obj), "No se pudo cerrar el parcial.");
        }

        public async Task<Answer> Publicar(CierreParcialAccionDTO obj)
        {
            string? problema = Validar(obj, motivoObligatorio: false);
            if (problema != null) return Rechazo(problema);
            return Escritura(await _repository.Publicar(obj), "No se pudieron publicar los resultados.");
        }

        public async Task<Answer> Despublicar(CierreParcialAccionDTO obj)
        {
            string? problema = Validar(obj, motivoObligatorio: true);
            if (problema != null) return Rechazo(problema == "Escriba el motivo." ? "Escriba el motivo para retirar la publicación." : problema);
            return Escritura(await _repository.Despublicar(obj), "No se pudo retirar la publicación.");
        }

        public async Task<Answer> Reabrir(CierreParcialAccionDTO obj)
        {
            string? problema = Validar(obj, motivoObligatorio: true);
            if (problema != null) return Rechazo(problema == "Escriba el motivo." ? "Escriba el motivo para reabrir el parcial (qué corrección se autorizó)." : problema);
            return Escritura(await _repository.Reabrir(obj), "No se pudo reabrir el parcial.");
        }

        public async Task<Answer> Fechas(CierreParcialAccionDTO obj)
        {
            string? problema = Validar(obj, motivoObligatorio: false);
            if (problema != null) return Rechazo(problema);
            if (obj.FechaInicio.HasValue && obj.FechaLimite.HasValue && obj.FechaInicio.Value.Date > obj.FechaLimite.Value.Date)
                return Rechazo("La fecha de inicio no puede ser posterior a la fecha límite.");
            return Escritura(await _repository.Fechas(obj), "No se pudieron guardar las fechas.");
        }
    }
}
