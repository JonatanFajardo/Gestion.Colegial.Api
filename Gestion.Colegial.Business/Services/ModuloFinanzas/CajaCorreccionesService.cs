using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces.ModuloFinanzas;
using Gestion.Colegial.Business.Services;
using Gestion.Colegial.DataAccess.Interfaces.Finanzas;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;

namespace Gestion.Colegial.Business.Services.ModuloFinanzas
{
    /// <summary>
    /// Correcciones de caja: anular pagos, perdonar cargos y saldo a favor.
    /// Las escrituras responden un Answer limpio { Access, Message, Data }:
    /// Access = false si salió bien (Data = resultado), true si no (Message = motivo en español).
    /// </summary>
    public class CajaCorreccionesService : ICajaCorreccionesService
    {
        private static readonly string[] Destinos = { "Devuelto", "SaldoFavor" };
        private static readonly string[] TiposPerdon = { "Exoneración", "Beca", "Ajuste" };
        private static readonly string[] Metodos = { "Efectivo", "Transferencia", "Cheque" };

        private readonly ICajaCorreccionesRepository _repository;

        public CajaCorreccionesService(ICajaCorreccionesRepository repository)
        {
            _repository = repository;
        }

        private static Answer Rechazo(string mensaje) => new Answer { Access = true, Message = mensaje, Data = null };

        /// <summary>Un error de validación del procedimiento (THROW 50000-50099) llega tal cual; otro se registra y se generaliza.</summary>
        private static Answer Escritura(Answer answer, string exito, string general)
        {
            if (!answer.Access && answer.Data != null)
                return new Answer { Access = false, Message = exito, Data = answer.Data };

            string? validacion = EventosCalendarioService.MensajeDeValidacionSql(answer);
            if (validacion == null) Logs.Error(answer);
            return Rechazo(validacion ?? general);
        }

        private static string? Motivo(string? motivo)
        {
            if (string.IsNullOrWhiteSpace(motivo)) return null;
            return motivo.Trim();
        }

        public async Task<Answer> AnularPago(PagoAnularDto obj)
        {
            if (obj == null || obj.PagoId <= 0) return Rechazo("Elija el pago a anular.");
            if (Motivo(obj.Motivo) == null) return Rechazo("Escriba el motivo de la anulación.");
            if (obj.Motivo!.Trim().Length > 500) return Rechazo("El motivo admite hasta 500 caracteres.");
            if (!Destinos.Contains(obj.Destino)) return Rechazo("Indique qué pasa con el dinero: devuelto o saldo a favor.");
            return Escritura(await _repository.AnularPago(obj), "Pago anulado.", "No se pudo anular el pago.");
        }

        public async Task<Answer> PerdonarCargo(CuentaCobrarPerdonarDto obj)
        {
            if (obj == null || obj.CuentaCobrarId <= 0) return Rechazo("Elija el cargo.");
            if (obj.Monto <= 0) return Rechazo("El monto a perdonar debe ser mayor que cero.");
            // Se acepta sin tilde o en minúsculas ("exoneracion") y se guarda con el nombre oficial.
            string? tipo = TiposPerdon.FirstOrDefault(t => string.Compare(t, obj.Tipo?.Trim(),
                System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.CompareOptions.IgnoreCase | System.Globalization.CompareOptions.IgnoreNonSpace) == 0);
            if (tipo == null) return Rechazo("Elija el tipo: exoneración, beca o ajuste.");
            obj.Tipo = tipo;
            if (Motivo(obj.Motivo) == null) return Rechazo("Escriba el motivo.");
            if (obj.Motivo!.Trim().Length > 500) return Rechazo("El motivo admite hasta 500 caracteres.");
            return Escritura(await _repository.PerdonarCargo(obj), "Cargo perdonado.", "No se pudo perdonar el cargo.");
        }

        public async Task<Answer> ObtenerSaldoFavor(int alumnoId)
        {
            Answer answer = await _repository.ObtenerSaldoFavor(alumnoId);
            if (answer.Access) Logs.Error(answer);
            return answer;
        }

        public async Task<Answer> DevolverSaldoFavor(SaldoFavorDevolverDto obj)
        {
            if (obj == null || obj.AlumnoId <= 0) return Rechazo("Elija el alumno.");
            if (obj.Monto <= 0) return Rechazo("El monto a devolver debe ser mayor que cero.");
            if (!Metodos.Contains(obj.Metodo)) return Rechazo("Elija cómo se devuelve: efectivo, transferencia o cheque.");
            if (Motivo(obj.Motivo) == null) return Rechazo("Escriba el motivo de la devolución.");
            if (obj.Motivo!.Trim().Length > 500) return Rechazo("El motivo admite hasta 500 caracteres.");
            return Escritura(await _repository.DevolverSaldoFavor(obj), "Saldo devuelto.", "No se pudo registrar la devolución.");
        }

        public async Task<Answer> AplicarSaldoFavor(SaldoFavorAplicarDto obj)
        {
            if (obj == null || obj.AlumnoId <= 0) return Rechazo("Elija el alumno.");
            if (obj.Monto <= 0) return Rechazo("El monto a aplicar debe ser mayor que cero.");
            if ((obj.Motivo ?? "").Trim().Length > 500) return Rechazo("El motivo admite hasta 500 caracteres.");
            return Escritura(await _repository.AplicarSaldoFavor(obj), "Saldo aplicado.", "No se pudo aplicar el saldo a favor.");
        }

        public async Task<Answer> CorreccionesPorAlumno(int alumnoId)
        {
            Answer answer = await _repository.CorreccionesPorAlumno(alumnoId);
            if (answer.Access) Logs.Error(answer);
            return answer;
        }
    }
}
