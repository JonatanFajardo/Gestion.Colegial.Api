using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Sustitución de docente (espejo de Skuul "timetable substitutions"). Dirección ve quién falta,
    /// qué clases quedan sin profesor y asigna un suplente libre; RRHH consulta las horas cubiertas.
    /// Las reglas (suplente libre y no ausente, una sustitución activa por clase y día, bloqueo) las
    /// aplica el procedimiento; aquí se repiten las de forma para responder antes.
    /// </summary>
    public class SustitucionesService : ISustitucionesService
    {
        private readonly ISustitucionesRepository _repository;

        public SustitucionesService(ISustitucionesRepository repository)
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

        private static Answer Vacia() => new Answer { Access = false, Data = new List<object>() };

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

        private static bool FechaValida(DateTime? f) => f.HasValue && f.Value.Year >= 2000 && f.Value.Year <= 2100;

        public async Task<Answer> Dia(DateTime? fecha, int? empId) =>
            FechaValida(fecha) ? Revisar(await _repository.Dia(fecha!.Value, empId)) : Vacia();

        public async Task<Answer> Mes(DateTime? fecha, int? empId) =>
            FechaValida(fecha) ? Revisar(await _repository.Mes(fecha!.Value, empId)) : Rechazo("Indique la fecha.");

        public async Task<Answer> Sugerencias(int horId, DateTime? fecha) =>
            horId > 0 && FechaValida(fecha) ? Revisar(await _repository.Sugerencias(horId, fecha!.Value)) : Vacia();

        public async Task<Answer> Docentes(DateTime? fecha) =>
            FechaValida(fecha) ? Revisar(await _repository.Docentes(fecha!.Value)) : Vacia();

        public async Task<Answer> Historial(DateTime? desde, DateTime? hasta, int? empId)
        {
            if (!FechaValida(desde) || !FechaValida(hasta) || hasta!.Value < desde!.Value || (hasta.Value - desde.Value).TotalDays > 400)
                return Vacia();
            return Revisar(await _repository.Historial(desde.Value, hasta.Value, empId));
        }

        public async Task<Answer> Asignar(SustitucionAsignarDTO obj)
        {
            if (obj == null || obj.Hor_Id <= 0) return Rechazo("Elija la clase.");
            if (!FechaValida(obj.Sus_Fecha)) return Rechazo("Indique la fecha de la clase.");
            if (obj.Emp_IdSuplente <= 0) return Rechazo("Elija al suplente.");
            if ((obj.Sus_Notas ?? "").Trim().Length > 500) return Rechazo("Las notas admiten hasta 500 caracteres.");
            return Escritura(await _repository.Asignar(obj), "No se pudo asignar el suplente.");
        }

        public async Task<Answer> Cancelar(SustitucionCancelarDTO obj)
        {
            if (obj == null || obj.Sus_Id <= 0) return Rechazo("No llegó la sustitución.");
            if ((obj.Motivo ?? "").Trim().Length > 300) return Rechazo("El motivo admite hasta 300 caracteres.");
            return Escritura(await _repository.Cancelar(obj), "No se pudo cancelar la sustitución.");
        }

        public async Task<Answer> MarcarAusencia(AusenciaDocenteMarcarDTO obj)
        {
            if (obj == null || obj.Emp_Id <= 0) return Rechazo("Elija al docente.");
            if (!FechaValida(obj.Aud_Fecha)) return Rechazo("Indique la fecha de la ausencia.");
            if (string.IsNullOrWhiteSpace(obj.Aud_Motivo)) return Rechazo("Escriba el motivo de la ausencia.");
            if (obj.Aud_Motivo.Trim().Length > 300) return Rechazo("El motivo admite hasta 300 caracteres.");
            return Escritura(await _repository.MarcarAusencia(obj), "No se pudo marcar la ausencia.");
        }

        public async Task<Answer> QuitarAusencia(AusenciaDocenteQuitarDTO obj)
        {
            if (obj == null || obj.Aud_Id <= 0) return Rechazo("No llegó la ausencia.");
            return Escritura(await _repository.QuitarAusencia(obj), "No se pudo quitar la ausencia.");
        }
    }
}
