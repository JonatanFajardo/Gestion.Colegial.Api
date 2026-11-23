using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using System.Text.RegularExpressions;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Ficha de salud del alumno (espejo de Skuul "health records"): una ficha por alumno con lo que
    /// el colegio necesita en una emergencia. Guardar crea o cambia la ficha y la bitácora anota qué
    /// campos cambiaron, sin los valores.
    /// </summary>
    public class FichasSaludService : IFichasSaludService
    {
        public static readonly string[] TiposSangre = { "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" };

        // Teléfono de Honduras: 8 dígitos; se acepta con guion o espacio en medio.
        private static readonly Regex Telefono = new Regex(@"^\d{4}[-\s]?\d{4}$", RegexOptions.Compiled);

        private readonly IFichasSaludRepository _repository;

        public FichasSaludService(IFichasSaludRepository repository)
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

        /// <summary>"99998888" o "9999 8888" → "9999-8888". Null si viene vacío; el mismo texto si no tiene forma de teléfono.</summary>
        public static string? NormalizarTelefono(string? valor)
        {
            if (string.IsNullOrWhiteSpace(valor)) return null;
            string t = valor.Trim();
            if (!Telefono.IsMatch(t)) return t;
            string digitos = new string(t.Where(char.IsDigit).ToArray());
            return digitos.Substring(0, 4) + "-" + digitos.Substring(4, 4);
        }

        private static bool EsTelefono(string? valor) => valor == null || Regex.IsMatch(valor, @"^\d{4}-\d{4}$");

        private static string? Largo(string? valor, int maximo, string campo) =>
            (valor ?? "").Trim().Length > maximo ? $"{campo} admite hasta {maximo} caracteres." : null;

        /// <summary>Las mismas reglas que el procedimiento (y que el formulario), con mensajes para la persona.</summary>
        public static string? Validar(FichaSaludGuardarDTO? obj)
        {
            if (obj == null) return "No llegaron datos.";
            if (obj.Alu_Id <= 0) return "Elija un alumno.";

            obj.Fsa_TipoSangre = string.IsNullOrWhiteSpace(obj.Fsa_TipoSangre) ? null : obj.Fsa_TipoSangre.Trim().ToUpperInvariant();
            if (obj.Fsa_TipoSangre != null && !TiposSangre.Contains(obj.Fsa_TipoSangre)) return "Elija un tipo de sangre de la lista.";

            if (!obj.Fsa_TieneAlerta) obj.Fsa_Alerta = null;
            if (obj.Fsa_TieneAlerta && string.IsNullOrWhiteSpace(obj.Fsa_Alerta))
                return "Escriba la alerta que verá el docente (ej. \"Alergia grave al maní, lleva epinefrina\").";

            obj.Fsa_MedicoTelefono = NormalizarTelefono(obj.Fsa_MedicoTelefono);
            obj.Fsa_ContactoEmergenciaTelefono = NormalizarTelefono(obj.Fsa_ContactoEmergenciaTelefono);
            if (!EsTelefono(obj.Fsa_MedicoTelefono)) return "El teléfono del médico debe tener 8 dígitos (ej. 9999-9999).";
            if (!EsTelefono(obj.Fsa_ContactoEmergenciaTelefono)) return "El teléfono del contacto adicional debe tener 8 dígitos (ej. 9999-9999).";

            bool hayNombre = !string.IsNullOrWhiteSpace(obj.Fsa_ContactoEmergenciaNombre);
            bool hayParentesco = !string.IsNullOrWhiteSpace(obj.Fsa_ContactoEmergenciaParentesco);
            if (obj.Fsa_ContactoEmergenciaTelefono == null && (hayNombre || hayParentesco)) return "Escriba el teléfono del contacto adicional.";
            if (!hayNombre && obj.Fsa_ContactoEmergenciaTelefono != null) return "Escriba el nombre del contacto adicional.";

            return Largo(obj.Fsa_Alerta, 150, "La alerta")
                ?? Largo(obj.Fsa_Alergias, 2000, "Alergias")
                ?? Largo(obj.Fsa_Condiciones, 2000, "Condiciones")
                ?? Largo(obj.Fsa_Medicamentos, 2000, "Medicamentos")
                ?? Largo(obj.Fsa_RestriccionesAlimentarias, 2000, "Restricciones alimentarias")
                ?? Largo(obj.Fsa_MedicoNombre, 100, "El nombre del médico")
                ?? Largo(obj.Fsa_Hospital, 150, "Hospital o clínica")
                ?? Largo(obj.Fsa_Seguro, 100, "Seguro")
                ?? Largo(obj.Fsa_SeguroPoliza, 50, "Póliza")
                ?? Largo(obj.Fsa_ContactoEmergenciaNombre, 100, "El nombre del contacto")
                ?? Largo(obj.Fsa_ContactoEmergenciaParentesco, 50, "El parentesco del contacto")
                ?? Largo(obj.Fsa_Notas, 4000, "Notas");
        }

        public async Task<Answer> Directorio(int? nivId, int? cunId, int? secId, string? texto, bool soloSinFicha, bool soloConAlerta)
        {
            string? q = string.IsNullOrWhiteSpace(texto) ? null : texto.Trim();
            if (q != null && q.Length > 100) q = q.Substring(0, 100);
            return Revisar(await _repository.Directorio(nivId, cunId, secId, q, soloSinFicha, soloConAlerta));
        }

        public async Task<Answer> Find(int aluId)
        {
            Answer answer = await _repository.Find(aluId);
            // Sin fila = el alumno no existe: no es un error.
            return answer.Access && answer.Data == null ? answer : Revisar(answer);
        }

        public async Task<Answer> Contactos(int aluId) => Revisar(await _repository.Contactos(aluId));

        public async Task<Answer> Bitacora(int aluId) => Revisar(await _repository.Bitacora(aluId));

        public async Task<Answer> AlertasSeccion(int horId, DateTime? fecha, int? usuId) => Revisar(await _repository.AlertasSeccion(horId, fecha, usuId));

        public async Task<Answer> Guardar(FichaSaludGuardarDTO obj)
        {
            string? problema = Validar(obj);
            if (problema != null) return Rechazo(problema);

            Answer answer = await _repository.Guardar(obj);
            if (answer.Access)
            {
                // Un error de validación del procedimiento (THROW 50000-50099) llega tal cual; otro se registra y se generaliza.
                string? validacion = EventosCalendarioService.MensajeDeValidacionSql(answer);
                if (validacion == null) Logs.Error(answer);
                answer.Message = validacion ?? "No se pudo guardar la ficha de salud.";
            }
            return answer;
        }
    }
}
