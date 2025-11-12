using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface ITarifaRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbTarifas obj);
        Task<Answer> Edit(tbTarifas obj);
        Task<Answer> Delete(int id);
        Task<Answer> GetByConceptoAndNivel(int conceptoId, int nivelId, int anio);
    }
}
