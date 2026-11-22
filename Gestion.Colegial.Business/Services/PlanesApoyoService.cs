using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using System.Text.RegularExpressions;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Plan de apoyo al alumno (espejo de Skuul "support plans"). Dirección abre un plan para un alumno
    /// en riesgo, le pone pasos con responsable y fecha, y lo sigue con notas. Los cambios de estado y
    /// las notas solo se agregan. Las reglas de lectura (confidencial, solo lo propio) y de escritura
    /// las aplica el procedimiento; aquí se repiten las de forma para responder antes.
    /// </summary>
    public class PlanesApoyoService : IPlanesApoyoService
    {
        public static readonly string[] Categorias = { "refuerzo", "orientacion", "conducta", "salud", "adecuacion" };
        public static readonly string[] Estados_ = { "borrador", "activo", "en_pausa", "completado", "cancelado" };
        private static readonly Regex ListaIds = new Regex(@"^\d{1,9}(,\d{1,9}){0,499}$");

        private readonly IPlanesApoyoRepository _repository;

        public PlanesApoyoService(IPlanesApoyoRepository repository)
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

        public async Task<Answer> List(bool verTodos, bool verConfidenciales, int? usuId) =>
            Revisar(await _repository.List(verTodos, verConfidenciales, usuId));

        public async Task<Answer> Resumen(bool verTodos, bool verConfidenciales, int? usuId) =>
            Revisar(await _repository.Resumen(verTodos, verConfidenciales, usuId));

        public async Task<Answer> Find(int id, bool verTodos, bool verConfidenciales, int? usuId)
        {
            Answer answer = await _repository.Find(id, verTodos, verConfidenciales, usuId);
            // Sin fila = no existe o no lo puede leer: no es un error.
            return answer.Access && answer.Data == null ? answer : Revisar(answer);
        }

        public async Task<Answer> Pasos(int id, bool verTodos, bool verConfidenciales, int? usuId) =>
            Revisar(await _repository.Pasos(id, verTodos, verConfidenciales, usuId));

        public async Task<Answer> Notas(int id, bool verTodos, bool verConfidenciales, int? usuId) =>
            Revisar(await _repository.Notas(id, verTodos, verConfidenciales, usuId));

        public async Task<Answer> Estados(int id, bool verTodos, bool verConfidenciales, int? usuId) =>
            Revisar(await _repository.Estados(id, verTodos, verConfidenciales, usuId));

        public async Task<Answer> Usuarios() => Revisar(await _repository.Usuarios());
        public async Task<Answer> Alumnos() => Revisar(await _repository.Alumnos());
        public async Task<Answer> Secciones(int cunId) => Revisar(await _repository.Secciones(cunId));

        /// <summary>alumnos = "1,2,3" (hasta 500 números); otro texto devuelve la lista vacía.</summary>
        public async Task<Answer> AbiertosDeAlumnos(string? alumnos, bool verTodos, bool verConfidenciales, int? usuId)
        {
            string lista = (alumnos ?? "").Replace(" ", "");
            if (!ListaIds.IsMatch(lista)) return new Answer { Access = false, Data = new List<object>() };
            return Revisar(await _repository.AbiertosDeAlumnos(lista, verTodos, verConfidenciales, usuId));
        }

        /// <summary>Mismas reglas que Skuul: alumno, objetivo, categoría, la revisión no antes del inicio, responsable.</summary>
        public static string? Validar(PlanApoyoGuardarDTO? obj, bool nuevo)
        {
            if (obj == null) return "No llegaron datos.";
            if (nuevo && obj.Alu_Id <= 0) return "Elija el alumno.";
            if (!nuevo && obj.Apo_Id <= 0) return "No llegó el plan.";
            if (!Categorias.Contains(obj.Apo_Categoria)) return "Elija la categoría del plan.";
            if (string.IsNullOrWhiteSpace(obj.Apo_Titulo)) return "Escriba el objetivo del plan.";
            if (obj.Apo_Titulo.Trim().Length > 150) return "El objetivo admite hasta 150 caracteres.";
            if ((obj.Apo_Resumen ?? "").Trim().Length > 5000) return "La descripción admite hasta 5000 caracteres.";
            if (!obj.Apo_FechaInicio.HasValue || obj.Apo_FechaInicio.Value.Year < 2000 || obj.Apo_FechaInicio.Value.Year > 2100)
                return "Indique cuándo empieza el plan.";
            if (!obj.Apo_FechaRevision.HasValue || obj.Apo_FechaRevision.Value.Year < 2000 || obj.Apo_FechaRevision.Value.Year > 2100)
                return "Indique cuándo se revisa el plan.";
            if (obj.Apo_FechaRevision.Value.Date < obj.Apo_FechaInicio.Value.Date) return "La revisión no puede ser antes del inicio del plan.";
            if (!obj.Usu_IdResponsable.HasValue || obj.Usu_IdResponsable.Value <= 0) return "Elija al responsable del plan.";
            if (!nuevo && !obj.Apo_Version.HasValue) return "No llegó la versión del plan. Recargue la página.";
            return null;
        }

        public async Task<Answer> Crear(PlanApoyoGuardarDTO obj)
        {
            string? problema = Validar(obj, nuevo: true);
            if (problema != null) return Rechazo(problema);
            return Escritura(await _repository.Crear(obj), "No se pudo abrir el plan.");
        }

        public async Task<Answer> Editar(PlanApoyoGuardarDTO obj)
        {
            string? problema = Validar(obj, nuevo: false);
            if (problema != null) return Rechazo(problema);
            return Escritura(await _repository.Editar(obj), "No se pudieron guardar los cambios del plan.");
        }

        public async Task<Answer> CambiarEstado(PlanApoyoEstadoDTO obj)
        {
            if (obj == null || obj.Apo_Id <= 0 || !Estados_.Contains(obj.Estado)) return Rechazo("Elija el estado.");
            if ((obj.Motivo ?? "").Trim().Length > 500) return Rechazo("El motivo admite hasta 500 caracteres.");
            return Escritura(await _repository.CambiarEstado(obj), "No se pudo cambiar el estado del plan.");
        }

        public async Task<Answer> AgregarPaso(PlanApoyoPasoDTO obj)
        {
            if (obj == null || obj.Apo_Id <= 0) return Rechazo("No llegaron datos.");
            if (string.IsNullOrWhiteSpace(obj.Apa_Descripcion)) return Rechazo("Diga qué tiene que pasar.");
            if (obj.Apa_Descripcion.Trim().Length > 500) return Rechazo("El paso admite hasta 500 caracteres.");
            if (!obj.Apa_FechaLimite.HasValue) return Rechazo("Indique la fecha límite del paso.");
            if (!obj.Usu_IdResponsable.HasValue || obj.Usu_IdResponsable.Value <= 0) return Rechazo("Elija al responsable del paso.");
            return Escritura(await _repository.AgregarPaso(obj), "No se pudo agregar el paso.");
        }

        public async Task<Answer> CompletarPaso(PlanApoyoPasoAccionDTO obj)
        {
            if (obj == null || obj.Apo_Id <= 0 || obj.Apa_Id <= 0) return Rechazo("No llegaron datos.");
            return Escritura(await _repository.CompletarPaso(obj), "No se pudo marcar el paso como hecho.");
        }

        public async Task<Answer> QuitarPaso(PlanApoyoPasoAccionDTO obj)
        {
            if (obj == null || obj.Apo_Id <= 0 || obj.Apa_Id <= 0) return Rechazo("No llegaron datos.");
            return Escritura(await _repository.QuitarPaso(obj), "No se pudo quitar el paso.");
        }

        public async Task<Answer> AgregarNota(PlanApoyoNotaDTO obj)
        {
            if (obj == null || obj.Apo_Id <= 0 || string.IsNullOrWhiteSpace(obj.Apn_Texto)) return Rechazo("Escriba la nota.");
            if (obj.Apn_Texto.Trim().Length > 5000) return Rechazo("La nota admite hasta 5000 caracteres.");
            return Escritura(await _repository.AgregarNota(obj), "No se pudo agregar la nota.");
        }

        public async Task<Answer> Eliminar(PlanApoyoEliminarDTO obj)
        {
            if (obj == null || obj.Apo_Id <= 0) return Rechazo("No llegaron datos.");
            return Escritura(await _repository.Eliminar(obj), "No se pudo eliminar el plan.");
        }
    }
}
