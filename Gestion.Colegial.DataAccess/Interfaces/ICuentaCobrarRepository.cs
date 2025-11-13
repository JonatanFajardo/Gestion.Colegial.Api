using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
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
    }
}
