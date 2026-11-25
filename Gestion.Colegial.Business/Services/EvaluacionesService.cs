using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>Resultado de una escritura: lo que respondió el procedimiento y cuántas notas del parcial cambiaron en app.tbNotas.</summary>
    public class EvaluacionEscrituraRespuesta
    {
        public int Id { get; set; }
        public int? Cev_Id { get; set; }
        public int? Version { get; set; }
        public int Cantidad { get; set; }
        public int Omitidas { get; set; }
        public int Sincronizados { get; set; }
        public int Conservados { get; set; }
        public int NotasEscritas { get; set; }
        public int NotasFallidas { get; set; }
        public string? AvisoNotas { get; set; }
    }

    /// <summary>
    /// Notas ponderadas (espejo de RosarioSIS "Assignment Types" y de Skuul "assessment templates" + gradebook).
    /// Permisos y alcance del docente: los revisa el procedimiento con el usuario. Cada cambio en actividades,
    /// puntos o pesos escribe la nota calculada del parcial en app.tbNotas dentro de su misma transacción
    /// (app.PR_Evaluacion_EscribirNotas): el boletín, las constancias y el cierre de parciales ven lo mismo.
    /// </summary>
    public class EvaluacionesService : IEvaluacionesService
    {
        public static readonly string[] TiposOpcion = { "anio", "nivel", "materia" };
        private readonly IEvaluacionesRepository _repository;

        public EvaluacionesService(IEvaluacionesRepository repository)
        {
            _repository = repository;
        }

        private static Answer Vacia() => new Answer { Access = false, Data = new List<object>() };

        private static Answer Rechazo(string mensaje) => new Answer { Access = true, Message = mensaje, Data = "" };

        /// <summary>Lectura: un rechazo del procedimiento (THROW 50000-50099) llega tal cual; otro error se registra.</summary>
        private static Answer Revisar(Answer answer, string general)
        {
            if (answer.Access)
            {
                string? validacion = EventosCalendarioService.MensajeDeValidacionSql(answer);
                if (validacion == null) Logs.Error(answer);
                answer.Message = validacion ?? general;
            }
            return answer;
        }

        public async Task<Answer> Cuaderno(int horId, int pacId, int usuId)
        {
            if (horId <= 0 || pacId <= 0 || usuId <= 0) return Rechazo("Elija la materia, la sección y el parcial.");
            Answer answer = Revisar(await _repository.Cuaderno(horId, pacId, usuId), "No se pudo cargar el cuaderno de actividades.");
            if (!answer.Access) answer.Data = (answer.Data as PR_Evaluacion_JsonResult)?.Json ?? "";
            return answer;
        }

        public async Task<bool> UsaActividades(int horId, int pacId)
        {
            Answer answer = await _repository.UsaActividades(horId, pacId);
            return !answer.Access && answer.Data is PR_Evaluacion_UsaActividadesResult r && r.UsaActividades;
        }

        private static Answer Escritura(Answer answer, string general)
        {
            answer = Revisar(answer, general);
            if (answer.Access) return answer;
            if (answer.Data is not PR_Evaluacion_EscrituraResult r) return Rechazo(general);
            answer.Data = new EvaluacionEscrituraRespuesta
            {
                Id = r.Id, Cev_Id = r.Cev_Id, Version = r.Version, Cantidad = r.Cantidad, Omitidas = r.Omitidas,
                Sincronizados = r.Sincronizados ?? 0, Conservados = r.Conservados ?? 0, NotasEscritas = r.NotasEscritas ?? 0
            };
            return answer;
        }

        public async Task<Answer> GuardarActividad(ActividadEvaluacionGuardarDTO obj)
        {
            if (obj?.Usuario is not > 0) return Rechazo("Inicie sesión de nuevo.");
            if (obj.Act_Id <= 0 && (obj.Hor_Id <= 0 || obj.Pac_Id <= 0)) return Rechazo("Elija la materia, la sección y el parcial.");
            return Escritura(await _repository.GuardarActividad(obj), "No se pudo guardar la actividad.");
        }

        public async Task<Answer> QuitarActividad(ActividadEvaluacionQuitarDTO obj)
        {
            if (obj?.Usuario is not > 0) return Rechazo("Inicie sesión de nuevo.");
            if (obj.Act_Id <= 0) return Rechazo("Elija la actividad.");
            return Escritura(await _repository.QuitarActividad(obj), "No se pudo quitar la actividad.");
        }

        public async Task<Answer> GuardarPuntos(PuntosEvaluacionGuardarDTO obj)
        {
            if (obj?.Usuario is not > 0) return Rechazo("Inicie sesión de nuevo.");
            if (obj.Cev_Id <= 0 || string.IsNullOrWhiteSpace(obj.Puntos)) return Rechazo("No hay cambios para guardar.");
            return Escritura(await _repository.GuardarPuntos(obj), "No se pudieron guardar los puntos.");
        }

        /// <summary>Vuelve a escribir en app.tbNotas las notas calculadas de un cuaderno (si alguien las cambió por otro camino).</summary>
        public async Task<Answer> ActualizarNotas(int cevId, int usuId)
        {
            if (cevId <= 0 || usuId <= 0) return Rechazo("Elija el cuaderno.");
            return Escritura(await _repository.ActualizarNotas(cevId, usuId), "No se pudieron actualizar las notas del parcial.");
        }

        public async Task<Answer> Plantillas(int anio, int usuId) =>
            anio < 2000 || anio > 2100 || usuId <= 0 ? Vacia() : Revisar(await _repository.Plantillas(anio, usuId), MessageShow.Error);

        public async Task<Answer> Opciones(int usuId, string? tipo, int? anio, int? nivId)
        {
            if (usuId <= 0 || tipo == null || !TiposOpcion.Contains(tipo)) return Vacia();
            return Revisar(await _repository.Opciones(usuId, tipo, anio, nivId), MessageShow.Error);
        }

        public async Task<Answer> GuardarPlantilla(PlantillaEvaluacionGuardarDTO obj)
        {
            if (obj?.Usuario is not > 0) return Rechazo("Inicie sesión de nuevo.");
            return Escritura(await _repository.GuardarPlantilla(obj), "No se pudo guardar la plantilla.");
        }

        public async Task<Answer> QuitarPlantilla(PlantillaEvaluacionQuitarDTO obj)
        {
            if (obj?.Usuario is not > 0) return Rechazo("Inicie sesión de nuevo.");
            if (obj.Ple_Id <= 0) return Rechazo("Elija la plantilla.");
            return Escritura(await _repository.QuitarPlantilla(obj), "No se pudo quitar la plantilla.");
        }

        public async Task<Answer> Avance(int anio, int semId, int pacId, int usuId) =>
            anio < 2000 || semId <= 0 || pacId <= 0 || usuId <= 0 ? Vacia()
                : Revisar(await _repository.Avance(anio, semId, pacId, usuId), MessageShow.Error);
    }
}
