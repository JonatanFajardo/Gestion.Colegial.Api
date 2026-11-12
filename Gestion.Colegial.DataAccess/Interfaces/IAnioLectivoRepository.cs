using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IAnioLectivoRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Create(tbAnioLectivo obj);
        Task<Answer> Edit(tbAnioLectivo obj);
        Task<Answer> Delete(int id);
        Task<Answer> Exist(string value);
        Task<Answer> SetActivo(int id);
        Task<Answer> Activo();
    }
}
