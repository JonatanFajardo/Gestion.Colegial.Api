using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface ICursoRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbCursos obj);
        Task<Answer> Edit(tbCursos obj);
        Task<Answer> Delete(int id);
        Task<Answer> NivelesEducativosDropdown();
        Task<Answer> ModalidadesList();
        Task<Answer> MateriasList();
        Task<Answer> CursosNivelesList();
        Task<Answer> SeccionesList();
        Task<Answer> CursosModalidadesCreate(tbCursos obj);
        Task<Answer> CursosModalidadesEdit(tbCursos obj);
        Task<Answer> CursosModalidadesFind(int id);
        Task<Answer> CursosModalidadesDelete(int id);
        Task<Answer> CursosMateriasCreate(tbCursos obj);
        Task<Answer> CursosMateriasEdit(tbCursos obj);
        Task<Answer> CursosMateriasFind(int id);
        Task<Answer> CursosMateriasDelete(int id);
        Task<Answer> CursosSeccionesCreate(tbCursos obj);
        Task<Answer> CursosSeccionesEdit(tbCursos obj);
        Task<Answer> CursosSeccionesFind(int id);
        Task<Answer> CursosSeccionesDelete(int id);
        Task<Answer> CursosNivelesCreate(tbCursos obj);
        Task<Answer> CursosNivelesEdit(tbCursos obj);
        Task<Answer> CursosNivelesFind(int id);
        Task<Answer> CursosNivelesDelete(int id);
        Task<Answer> CursosDropdown(int id);
    }
}
