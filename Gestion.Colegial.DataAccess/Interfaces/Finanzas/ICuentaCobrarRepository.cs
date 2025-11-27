using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces.Finanzas
{
    public interface ICuentaCobrarRepository
    {
        Task<Answer> List();
        Task<Answer> ListByAlumno(int alumnoId);
        Task<Answer> ListPendientes();
        Task<Answer> ListVencidas();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbCuentasCobrar obj);
        Task<Answer> Edit(tbCuentasCobrar obj);
        Task<Answer> Delete(int id);
        Task<Answer> GenerarCargosAlumno(int alumnoId, int anio);
        Task<Answer> AplicarDescuento(int cuentaCobrarId, int descuentoId, decimal monto, string justificacion);
        Task<Answer> CalcularMoratoria(int cuentaCobrarId);
        Task<Answer> ListDeudores();
        Task<Answer> GenerarCargosMasivos(object filtros);
        Task<Answer> PrevisualizarCargos(object filtros);
        Task<Answer> GenerarMensualidad(byte mes, short anio, int usuarioId, int? conceptoMensualidadId = null);
        Task<Answer> GenerarMensualidadesRango(byte mesInicio, byte mesFin, short anio, int usuarioId);
        Task<Answer> MesesPendientesPorAlumno(int alumnoId, short? anio = null);
        Task<Answer> ObtenerCargosPendientes(int alumnoId);
        Task<Answer> ObtenerResumenFinanciero(int alumnoId);
        Task<Answer> ObtenerHistoricoPagos(int alumnoId);
    }
}
