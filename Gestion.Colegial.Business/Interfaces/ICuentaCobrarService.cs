using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
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
    }
}
