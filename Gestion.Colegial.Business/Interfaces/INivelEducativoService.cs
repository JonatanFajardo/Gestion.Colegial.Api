using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface INivelEducativoService
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbNivelesEducativos obj);
        Task<Answer> Edit(tbNivelesEducativos obj);
        Task<Answer> Exist(string value);
        Task<Answer> Delete(int id);
        Task<Answer> NivelesEducativosDropdown();
    }
}
