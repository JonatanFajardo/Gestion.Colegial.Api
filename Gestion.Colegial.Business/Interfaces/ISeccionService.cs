using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface ISeccionService
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbSecciones obj);
        Task<Answer> Edit(tbSecciones obj);
        Task<Answer> Exist(string value);
        Task<Answer> Delete(int id);
    }
}
