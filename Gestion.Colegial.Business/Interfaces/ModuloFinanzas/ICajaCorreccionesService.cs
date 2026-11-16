using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;

namespace Gestion.Colegial.Business.Interfaces.ModuloFinanzas
{
    public interface ICajaCorreccionesService
    {
        Task<Answer> AnularPago(PagoAnularDto obj);
        Task<Answer> PerdonarCargo(CuentaCobrarPerdonarDto obj);
        Task<Answer> ObtenerSaldoFavor(int alumnoId);
        Task<Answer> DevolverSaldoFavor(SaldoFavorDevolverDto obj);
        Task<Answer> AplicarSaldoFavor(SaldoFavorAplicarDto obj);
        Task<Answer> CorreccionesPorAlumno(int alumnoId);
    }
}
