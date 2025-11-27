using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces.ModuloFinanzas
{
    public interface ICuentaCobrarService
    {
        Task<Answer> List();
        Task<Answer> ListByAlumno(int alumnoId);
        Task<Answer> ListPendientes();
        Task<Answer> ListVencidas();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(object obj);
        Task<Answer> Edit(object obj);
        Task<Answer> Delete(int id);
        Task<Answer> GenerarCargosAlumno(int alumnoId, int anio);
        Task<Answer> AplicarDescuento(int cuentaCobrarId, int descuentoId, decimal monto, string justificacion);
        Task<Answer> CalcularMoratoria(int cuentaCobrarId);
        Task<Answer> ListDeudores();
        Task<Answer> GenerarCargosMasivos(object filtros);
        Task<Answer> PrevisualizarCargos(object filtros);
        Task<Answer> GenerarMensualidad(object request);
        Task<Answer> GenerarMensualidadesRango(object request);
        Task<Answer> MesesPendientesPorAlumno(int alumnoId, short? anio = null);
        Task<Answer> ObtenerCargosPendientes(int alumnoId);
        Task<Answer> ObtenerResumenFinanciero(int alumnoId);
        Task<Answer> ObtenerHistoricoPagos(int alumnoId);
    }
}
