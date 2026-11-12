using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    /// <summary>
    /// Rollover (RollForward): arrastra la estructura de un año lectivo a otro.
    /// </summary>
    public interface IRolloverService
    {
        /// <summary>Copia la estructura del año <paramref name="origen"/> al año <paramref name="destino"/> (como borrador).</summary>
        Task<Answer> RollForward(int origen, int destino);
    }
}
