using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>Resultado de una escritura: lo que respondió el procedimiento y las notas del parcial que se pasaron a app.tbNotas.</summary>
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
    /// Permisos y alcance del docente: los revisa el procedimiento con el usuario. Después de cada cambio en
    /// actividades o puntos, la nota calculada del parcial se escribe en app.tbNotas con el procedimiento de
    /// siempre (app.PR_tbNotas_Insert, vía INotasRepository): así el boletín, las constancias y el cierre de
    /// parciales ven lo mismo. Solo se escriben las notas que cambiaron.
    /// </summary>
    public class EvaluacionesService : IEvaluacionesService
    {
        public static readonly string[] TiposOpcion = { "anio", "nivel", "materia" };
        private const int EscriturasALaVez = 4;

        private readonly IEvaluacionesRepository _repository;
        private readonly INotasRepository _notas;

        public EvaluacionesService(IEvaluacionesRepository repository, INotasRepository notas)
        {
            _repository = repository;
            _notas = notas;
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

        /// <summary>Escribe en app.tbNotas las notas calculadas que cambiaron (de un cuaderno o de los cuadernos abiertos de una plantilla).</summary>
        private async Task EscribirNotas(EvaluacionEscrituraRespuesta respuesta, int? cevId, int? pleId, int usuId)
        {
            Answer pendientes = await _repository.NotasParaEscribir(cevId, pleId, usuId);
            if (pendientes.Access || pendientes.Data is not List<PR_Evaluacion_NotaPendienteResult> lista)
            {
                if (pendientes.Access) Logs.Error(pendientes);
                respuesta.AvisoNotas = "Se guardó, pero no se pudieron actualizar las notas del parcial. Use \"Actualizar notas del parcial\".";
                return;
            }

            using var turno = new SemaphoreSlim(EscriturasALaVez);
            string? primerError = null;
            int escritas = 0, fallidas = 0;
            await Task.WhenAll(lista.Select(async n =>
            {
                await turno.WaitAsync();
                try
                {
                    Answer r = await _notas.Insert(n.Alu_Id, n.Hor_Id, n.Pac_Id, n.Nota, usuId);
                    if (r.Access)
                    {
                        Interlocked.Increment(ref fallidas);
                        string? validacion = EventosCalendarioService.MensajeDeValidacionSql(r);
                        if (validacion == null && !string.IsNullOrEmpty(r.ErrorDetails)) Logs.Error(r);
                        Interlocked.CompareExchange(ref primerError, validacion ?? r.Message, null);
                    }
                    else Interlocked.Increment(ref escritas);
                }
                finally { turno.Release(); }
            }));

            respuesta.NotasEscritas = escritas;
            respuesta.NotasFallidas = fallidas;
            if (fallidas > 0)
                respuesta.AvisoNotas = $"No se pudieron actualizar {fallidas} nota(s) del parcial" + (primerError != null ? $": {primerError}" : ".");
        }

        private async Task<Answer> Escritura(Answer answer, string general, int usuId, bool porPlantilla)
        {
            answer = Revisar(answer, general);
            if (answer.Access) return answer;
            if (answer.Data is not PR_Evaluacion_EscrituraResult r) return Rechazo(general);

            var respuesta = new EvaluacionEscrituraRespuesta
            {
                Id = r.Id, Cev_Id = r.Cev_Id, Version = r.Version, Cantidad = r.Cantidad, Omitidas = r.Omitidas,
                Sincronizados = r.Sincronizados ?? 0, Conservados = r.Conservados ?? 0
            };
            if (porPlantilla)
            {
                if (respuesta.Sincronizados > 0) await EscribirNotas(respuesta, null, r.Id, usuId);
            }
            else if (r.Cev_Id.HasValue)
                await EscribirNotas(respuesta, r.Cev_Id, null, usuId);
            answer.Data = respuesta;
            return answer;
        }

        public async Task<Answer> GuardarActividad(ActividadEvaluacionGuardarDTO obj)
        {
            if (obj?.Usuario is not > 0) return Rechazo("Inicie sesión de nuevo.");
            if (obj.Act_Id <= 0 && (obj.Hor_Id <= 0 || obj.Pac_Id <= 0)) return Rechazo("Elija la materia, la sección y el parcial.");
            return await Escritura(await _repository.GuardarActividad(obj), "No se pudo guardar la actividad.", obj.Usuario.Value, false);
        }

        public async Task<Answer> QuitarActividad(ActividadEvaluacionQuitarDTO obj)
        {
            if (obj?.Usuario is not > 0) return Rechazo("Inicie sesión de nuevo.");
            if (obj.Act_Id <= 0) return Rechazo("Elija la actividad.");
            return await Escritura(await _repository.QuitarActividad(obj), "No se pudo quitar la actividad.", obj.Usuario.Value, false);
        }

        public async Task<Answer> GuardarPuntos(PuntosEvaluacionGuardarDTO obj)
        {
            if (obj?.Usuario is not > 0) return Rechazo("Inicie sesión de nuevo.");
            if (obj.Cev_Id <= 0 || string.IsNullOrWhiteSpace(obj.Puntos)) return Rechazo("No hay cambios para guardar.");
            return await Escritura(await _repository.GuardarPuntos(obj), "No se pudieron guardar los puntos.", obj.Usuario.Value, false);
        }

        /// <summary>Vuelve a pasar a app.tbNotas las notas calculadas de un cuaderno (si alguna quedó sin escribir).</summary>
        public async Task<Answer> ActualizarNotas(int cevId, int usuId)
        {
            if (cevId <= 0 || usuId <= 0) return Rechazo("Elija el cuaderno.");
            var respuesta = new EvaluacionEscrituraRespuesta { Id = cevId, Cev_Id = cevId };
            Answer pendientes = Revisar(await _repository.NotasParaEscribir(cevId, null, usuId), "No se pudieron actualizar las notas del parcial.");
            if (pendientes.Access) return pendientes;
            await EscribirNotas(respuesta, cevId, null, usuId);
            return new Answer { Access = false, Data = respuesta };
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
            return await Escritura(await _repository.GuardarPlantilla(obj), "No se pudo guardar la plantilla.", obj.Usuario.Value, true);
        }

        public async Task<Answer> QuitarPlantilla(PlantillaEvaluacionQuitarDTO obj)
        {
            if (obj?.Usuario is not > 0) return Rechazo("Inicie sesión de nuevo.");
            if (obj.Ple_Id <= 0) return Rechazo("Elija la plantilla.");
            return await Escritura(await _repository.QuitarPlantilla(obj), "No se pudo quitar la plantilla.", obj.Usuario.Value, true);
        }

        public async Task<Answer> Avance(int anio, int semId, int pacId, int usuId) =>
            anio < 2000 || semId <= 0 || pacId <= 0 || usuId <= 0 ? Vacia()
                : Revisar(await _repository.Avance(anio, semId, pacId, usuId), MessageShow.Error);
    }
}
