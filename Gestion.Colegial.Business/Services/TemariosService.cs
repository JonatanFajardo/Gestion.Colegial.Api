using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Temario y avance del programa (espejo de Skuul "syllabus", "coverage" y "library"). El docente arma
    /// el temario de su materia por semanas y marca qué tema dio en cada sección; Dirección ve el avance
    /// contra la semana esperada. Los permisos y el alcance del docente los decide el procedimiento con el
    /// usuario; aquí solo se descartan pedidos sin usuario o con valores fuera de lo permitido.
    /// </summary>
    public class TemariosService : ITemariosService
    {
        public static readonly string[] TiposOpcion = { "nivel", "grado", "curso", "materia", "semestre", "anio" };
        public static readonly string[] EstadosAvance = { "dado", "parcial", "omitido" };

        private readonly ITemariosRepository _repository;

        public TemariosService(ITemariosRepository repository)
        {
            _repository = repository;
        }

        private static Answer Vacia() => new Answer { Access = false, Data = new List<object>() };

        private static Answer Rechazo(string mensaje) => new Answer { Access = true, Message = mensaje, Data = "" };

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

        public async Task<Answer> List(int usuId) => usuId <= 0 ? Vacia() : Revisar(await _repository.List(usuId));

        public async Task<Answer> Find(int id, int usuId)
        {
            if (id <= 0 || usuId <= 0) return new Answer { Access = true, Data = null };
            Answer answer = await _repository.Find(id, usuId);
            // Sin fila = no existe o no lo puede leer: no es un error.
            return answer.Access && answer.Data == null ? answer : Revisar(answer);
        }

        public async Task<Answer> Temas(int id, int usuId) => id <= 0 || usuId <= 0 ? Vacia() : Revisar(await _repository.Temas(id, usuId));
        public async Task<Answer> Grupos(int id, int usuId) => id <= 0 || usuId <= 0 ? Vacia() : Revisar(await _repository.Grupos(id, usuId));
        public async Task<Answer> Avance(int id, int usuId) => id <= 0 || usuId <= 0 ? Vacia() : Revisar(await _repository.Avance(id, usuId));

        public async Task<Answer> Resumen(int usuId, int? anio, int? semId) =>
            usuId <= 0 ? Vacia() : Revisar(await _repository.Resumen(usuId, anio, semId));

        public async Task<Answer> SinTemario(int usuId, int? anio, int? semId) =>
            usuId <= 0 ? Vacia() : Revisar(await _repository.SinTemario(usuId, anio, semId));

        public async Task<Answer> Opciones(int usuId, string? tipo, int? nivId, int? cunId, int? curId, int? anio)
        {
            if (usuId <= 0 || tipo == null || !TiposOpcion.Contains(tipo)) return Vacia();
            return Revisar(await _repository.Opciones(usuId, tipo, nivId, cunId, curId, anio));
        }

        public async Task<Answer> TemasDeHorario(int horId, int semana, int usuId) =>
            horId <= 0 || usuId <= 0 || semana < 1 || semana > 30 ? Vacia() : Revisar(await _repository.TemasDeHorario(horId, semana, usuId));

        private static string? SinUsuario(TemarioEscritorDTO? obj) =>
            obj == null ? "No llegaron datos." : (obj.Usuario ?? 0) <= 0 ? "La sesión expiró: vuelva a entrar." : null;

        public async Task<Answer> Crear(TemarioGuardarDTO obj)
        {
            string? r = SinUsuario(obj);
            if (r != null) return Rechazo(r);
            return Escritura(await _repository.Crear(obj), "No se pudo crear el temario.");
        }

        public async Task<Answer> Editar(TemarioGuardarDTO obj)
        {
            string? r = SinUsuario(obj) ?? (obj.Tem_Id <= 0 ? "No llegó el temario." : null);
            if (r != null) return Rechazo(r);
            return Escritura(await _repository.Editar(obj), "No se pudieron guardar los cambios del temario.");
        }

        public async Task<Answer> Eliminar(TemarioEliminarDTO obj)
        {
            string? r = SinUsuario(obj) ?? (obj.Tem_Id <= 0 ? "No llegó el temario." : null);
            if (r != null) return Rechazo(r);
            return Escritura(await _repository.Eliminar(obj), "No se pudo quitar el temario.");
        }

        public async Task<Answer> Copiar(TemarioCopiarDTO obj)
        {
            string? r = SinUsuario(obj) ?? (obj.Tem_IdOrigen <= 0 ? "Elija el temario que quiere copiar." : null);
            if (r == null && !obj.Tem_IdDestino.HasValue && (!obj.Sem_Id.HasValue || !obj.Tem_Anio.HasValue))
                r = "Elija el semestre y el año del nuevo temario.";
            if (r != null) return Rechazo(r);
            return Escritura(await _repository.Copiar(obj), "No se pudo copiar el temario.");
        }

        public async Task<Answer> GuardarTema(TemarioTemaDTO obj)
        {
            string? r = SinUsuario(obj) ?? (obj.Tet_Id <= 0 && obj.Tem_Id <= 0 ? "No llegó el temario." : null);
            if (r != null) return Rechazo(r);
            return Escritura(await _repository.GuardarTema(obj), "No se pudo guardar el tema.");
        }

        public async Task<Answer> MoverTema(TemarioTemaAccionDTO obj)
        {
            string? r = SinUsuario(obj) ?? (obj.Tet_Id <= 0 ? "No llegó el tema." : null);
            if (r != null) return Rechazo(r);
            return Escritura(await _repository.MoverTema(obj), "No se pudo mover el tema.");
        }

        public async Task<Answer> QuitarTema(TemarioTemaAccionDTO obj)
        {
            string? r = SinUsuario(obj) ?? (obj.Tet_Id <= 0 ? "No llegó el tema." : null);
            if (r != null) return Rechazo(r);
            return Escritura(await _repository.QuitarTema(obj), "No se pudo quitar el tema.");
        }

        public async Task<Answer> MarcarAvance(TemarioAvanceDTO obj)
        {
            string? r = SinUsuario(obj) ?? (obj.Tet_Id <= 0 || obj.Cur_Id <= 0 || obj.Sec_Id <= 0 || obj.Mda_Id <= 0 ? "No llegó el tema o la sección." : null);
            if (r == null && (obj.Tav_Estado == null || !EstadosAvance.Contains(obj.Tav_Estado)))
                r = "Elija si el tema se dio, se dio en parte o se omitió.";
            if (r != null) return Rechazo(r);
            return Escritura(await _repository.MarcarAvance(obj), "No se pudo guardar el avance.");
        }

        public async Task<Answer> QuitarAvance(TemarioAvanceDTO obj)
        {
            string? r = SinUsuario(obj) ?? (obj.Tet_Id <= 0 || obj.Cur_Id <= 0 || obj.Sec_Id <= 0 || obj.Mda_Id <= 0 ? "No llegó el tema o la sección." : null);
            if (r != null) return Rechazo(r);
            return Escritura(await _repository.QuitarAvance(obj), "No se pudo quitar la marca de avance.");
        }
    }
}
