using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Disciplina (espejo de Skuul "Cases"). Un caso registra qué pasó, quiénes participaron, qué hizo
    /// el colegio y cómo avanzó. Los cambios de estado y las notas solo se agregan, no se editan.
    /// </summary>
    public class CasosDisciplinaService : ICasosDisciplinaService
    {
        public static readonly string[] Tipos = { "conducta", "proteccion" };
        public static readonly string[] Estados_ = { "reportado", "en_revision", "derivado", "con_medidas", "resuelto", "cerrado" };
        public static readonly string[] Papeles = { "implicado", "afectado", "testigo", "reporta", "atiende" };
        public const int MaxPersonas = 20;

        private readonly ICasosDisciplinaRepository _repository;

        public CasosDisciplinaService(ICasosDisciplinaRepository repository)
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

        public async Task<Answer> List(string? estado, string? tipo, bool soloAbiertos, bool verReservados, int? usuId, int? empId, int pagina) =>
            Revisar(await _repository.List(
                Estados_.Contains(estado) ? estado : null, Tipos.Contains(tipo) ? tipo : null,
                soloAbiertos, verReservados, usuId, empId, Math.Max(1, pagina), 20));

        public async Task<Answer> Abiertos(bool verReservados, int? usuId, int? empId) =>
            Revisar(await _repository.Abiertos(verReservados, usuId, empId));

        public async Task<Answer> Find(int id, bool verReservados, int? usuId, int? empId)
        {
            Answer answer = await _repository.Find(id, verReservados, usuId, empId);
            // Sin fila = no existe o no lo puede leer: no es un error.
            return answer.Access && answer.Data == null ? answer : Revisar(answer);
        }

        public async Task<Answer> Personas(int id) => Revisar(await _repository.Personas(id));
        public async Task<Answer> Acciones(int id) => Revisar(await _repository.Acciones(id));
        public async Task<Answer> Estados(int id) => Revisar(await _repository.Estados(id));
        public async Task<Answer> Notas(int id, bool verReservados, int? usuId, int? empId) => Revisar(await _repository.Notas(id, verReservados, usuId, empId));
        public async Task<Answer> Alumnos() => Revisar(await _repository.Alumnos());
        public async Task<Answer> Empleados() => Revisar(await _repository.Empleados());

        /// <summary>Mismas reglas que Skuul: resumen, tipo, fecha que ya pasó, hasta 20 personas con papel.</summary>
        public static string? Validar(CasoDisciplinaRegistrarDTO? obj)
        {
            if (obj == null) return "No llegaron datos.";
            if (string.IsNullOrWhiteSpace(obj.Cas_Resumen)) return "Escriba un resumen del caso.";
            if (obj.Cas_Resumen.Trim().Length > 255) return "El resumen admite hasta 255 caracteres.";
            if (!Tipos.Contains(obj.Cas_Tipo)) return "Elija el tipo de caso.";
            if ((obj.Cas_Lugar ?? "").Trim().Length > 150) return "El lugar admite hasta 150 caracteres.";
            if ((obj.Cas_Descripcion ?? "").Trim().Length > 5000) return "Lo que pasó admite hasta 5000 caracteres.";
            if (obj.Cas_FechaOcurrio == default || obj.Cas_FechaOcurrio.Year < 2000 || obj.Cas_FechaOcurrio.Year > 2100)
                return "Indique cuándo ocurrió.";
            var personas = (obj.Personas ?? new List<CasoDisciplinaPersonaDTO>()).Where(x => x.Alu_Id.HasValue).ToList();
            if (personas.Count > MaxPersonas) return "Un caso admite hasta 20 personas.";
            if (personas.Any(x => !Papeles.Contains(x.Papel))) return "Elija por qué aparece cada persona.";
            if (personas.Any(x => (x.Nota ?? "").Trim().Length > 255)) return "La nota de cada persona admite hasta 255 caracteres.";
            return null;
        }

        public async Task<Answer> Registrar(CasoDisciplinaRegistrarDTO obj)
        {
            string? problema = Validar(obj);
            if (problema != null) return Rechazo(problema);
            return Escritura(await _repository.Registrar(obj), "No se pudo registrar el caso.");
        }

        public async Task<Answer> CambiarEstado(CasoDisciplinaEstadoDTO obj)
        {
            if (obj == null || !Estados_.Contains(obj.Estado)) return Rechazo("Elija el estado.");
            if ((obj.Motivo ?? "").Trim().Length > 500) return Rechazo("El motivo admite hasta 500 caracteres.");
            return Escritura(await _repository.CambiarEstado(obj), "No se pudo mover el caso.");
        }

        public async Task<Answer> AgregarAccion(CasoDisciplinaAccionDTO obj)
        {
            if (obj == null) return Rechazo("No llegaron datos.");
            if (string.IsNullOrWhiteSpace(obj.Cac_Tipo)) return Rechazo("Diga qué tipo de paso es.");
            if (obj.Cac_Tipo.Trim().Length > 100) return Rechazo("El tipo de paso admite hasta 100 caracteres.");
            if (string.IsNullOrWhiteSpace(obj.Cac_Descripcion)) return Rechazo("Diga qué tiene que pasar.");
            if (obj.Cac_Descripcion.Trim().Length > 1000) return Rechazo("Lo que tiene que pasar admite hasta 1000 caracteres.");
            return Escritura(await _repository.AgregarAccion(obj), "No se pudo agregar la acción.");
        }

        public async Task<Answer> CompletarAccion(int casId, int cacId, int? usuario) =>
            Escritura(await _repository.CompletarAccion(casId, cacId, usuario), "No se pudo marcar la acción como hecha.");

        public async Task<Answer> AgregarNota(CasoDisciplinaNotaDTO obj)
        {
            if (obj == null || string.IsNullOrWhiteSpace(obj.Cno_Texto)) return Rechazo("Escriba la nota.");
            if (obj.Cno_Texto.Trim().Length > 5000) return Rechazo("La nota admite hasta 5000 caracteres.");
            return Escritura(await _repository.AgregarNota(obj), "No se pudo agregar la nota.");
        }
    }
}
