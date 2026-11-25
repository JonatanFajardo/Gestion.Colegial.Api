using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Cierre del año escolar (espejo de Skuul: Abierto → Cerrando → Cerrado → Archivado con revisión
    /// guardada y reapertura con motivo; y de RosarioSIS: calificación final y "siguiente grado / repetir"
    /// por alumno). Las reglas las aplica el procedimiento; aquí se repiten las de forma para responder antes.
    /// </summary>
    public class CierreAnioService : ICierreAnioService
    {
        public const int MotivoMaximo = 500;
        private static readonly string[] Acciones = { "iniciar", "cancelar", "cerrar", "reabrir", "archivar" };
        private static readonly string[] Decisiones_ = { "promovido", "repite", "gradua" };

        private readonly ICierreAnioRepository _repository;

        public CierreAnioService(ICierreAnioRepository repository)
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

        /// <summary>Validación de forma común: datos, año y permiso.</summary>
        private static string? Validar(CierreAnioAccionDTO? obj)
        {
            if (obj == null) return "No llegaron datos.";
            if (obj.Usuario == null || obj.Usuario <= 0) return "No tiene permiso para cerrar el año escolar.";
            if (obj.Ani_Id <= 0) return "Elija un año lectivo.";
            obj.Motivo = string.IsNullOrWhiteSpace(obj.Motivo) ? null : obj.Motivo.Trim();
            if (obj.Motivo != null && obj.Motivo.Length > MotivoMaximo) return $"El motivo admite hasta {MotivoMaximo} caracteres.";
            return null;
        }

        private static string? ValidarCerrar(CierreAnioAccionDTO? obj) =>
            Validar(obj) ?? (obj!.PuedeCerrar ? null : "No tiene permiso para cerrar el año escolar.");

        public async Task<Answer> Resumen(int aniId) => Revisar(await _repository.Resumen(aniId));
        public async Task<Answer> Revision(int aniId) => Revisar(await _repository.Revision(aniId));
        public async Task<Answer> Reglas(int aniId) => Revisar(await _repository.Reglas(aniId));
        public async Task<Answer> Secciones(int aniId) => Revisar(await _repository.Secciones(aniId));
        public async Task<Answer> Resultados(int aniId, int seaId) => Revisar(await _repository.Resultados(aniId, seaId));
        public async Task<Answer> Decisiones(int aniId, int seaId) => Revisar(await _repository.Decisiones(aniId, seaId));
        public async Task<Answer> Historial(int aniId) => Revisar(await _repository.Historial(aniId));

        public async Task<Answer> CambiarEstado(CierreAnioAccionDTO obj)
        {
            string? problema = Validar(obj);
            if (problema != null) return Rechazo(problema);
            obj.Accion = (obj.Accion ?? "").Trim().ToLowerInvariant();
            if (!Acciones.Contains(obj.Accion)) return Rechazo("Acción desconocida.");
            if (obj.Accion == "reabrir")
            {
                if (!obj.PuedeReabrir) return Rechazo("Reabrir un año cerrado requiere el permiso especial «Reabrir el año escolar».");
                if (obj.Motivo == null) return Rechazo("Escriba el motivo para reabrir el año (qué corrección se autorizó).");
            }
            else if (!obj.PuedeCerrar) return Rechazo("No tiene permiso para cerrar el año escolar.");
            return Escritura(await _repository.CambiarEstado(obj), "No se pudo cambiar el estado del año.");
        }

        public async Task<Answer> Calcular(CierreAnioAccionDTO obj)
        {
            string? problema = ValidarCerrar(obj);
            if (problema != null) return Rechazo(problema);
            return Escritura(await _repository.Calcular(obj), "No se pudieron calcular los resultados.");
        }

        public async Task<Answer> GuardarRegla(CierreAnioAccionDTO obj)
        {
            string? problema = ValidarCerrar(obj);
            if (problema != null) return Rechazo(problema);
            if (obj.Niv_Id == null || obj.Niv_Id <= 0) return Rechazo("Elija un nivel válido.");
            if (obj.NotaMinima == null || obj.NotaMinima < 1 || obj.NotaMinima > 100) return Rechazo("La nota mínima de aprobación debe estar entre 1 y 100.");
            if (obj.MaxRecuperacion == null || obj.MaxRecuperacion < 0 || obj.MaxRecuperacion > 20) return Rechazo("El máximo de materias en recuperación debe estar entre 0 y 20.");
            return Escritura(await _repository.GuardarRegla(obj), "No se pudo guardar la regla.");
        }

        public async Task<Answer> Recuperacion(CierreAnioAccionDTO obj)
        {
            string? problema = ValidarCerrar(obj);
            if (problema != null) return Rechazo(problema);
            if (obj.Rea_Id == null || obj.Rea_Id <= 0) return Rechazo("Elija la materia.");
            if (obj.Nota.HasValue && (obj.Nota < 0 || obj.Nota > 100 || obj.Nota != decimal.Truncate(obj.Nota.Value)))
                return Rechazo("La nota de recuperación debe ser un número entero entre 0 y 100.");
            return Escritura(await _repository.Recuperacion(obj), "No se pudo guardar la nota de recuperación.");
        }

        public async Task<Answer> Decidir(CierreAnioAccionDTO obj)
        {
            string? problema = ValidarCerrar(obj);
            if (problema != null) return Rechazo(problema);
            if (obj.Pra_Id == null || obj.Pra_Id <= 0) return Rechazo("Elija el alumno.");
            obj.Decision = (obj.Decision ?? "").Trim().ToLowerInvariant();
            if (!Decisiones_.Contains(obj.Decision)) return Rechazo("Elija Promovido, Repite o Se gradúa.");
            if (obj.Motivo != null && obj.Motivo.Length > 300) return Rechazo("El motivo admite hasta 300 caracteres.");
            return Escritura(await _repository.Decidir(obj), "No se pudo guardar la decisión.");
        }

        public async Task<Answer> ConfirmarSeccion(CierreAnioAccionDTO obj)
        {
            string? problema = ValidarCerrar(obj);
            if (problema != null) return Rechazo(problema);
            return Escritura(await _repository.ConfirmarSeccion(obj), "No se pudieron confirmar las decisiones.");
        }

        public async Task<Answer> DeshacerSeccion(CierreAnioAccionDTO obj)
        {
            string? problema = ValidarCerrar(obj);
            if (problema != null) return Rechazo(problema);
            if (obj.Motivo == null) return Rechazo("Escriba el motivo para deshacer la confirmación.");
            return Escritura(await _repository.DeshacerSeccion(obj), "No se pudo deshacer la confirmación.");
        }
    }
}
