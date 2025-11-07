using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface ISemestreService
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbSemestres obj);
        Task<Answer> Edit(tbSemestres obj);
        Task<Answer> Exist(string value);
        Task<Answer> Delete(int id);
    }
}
