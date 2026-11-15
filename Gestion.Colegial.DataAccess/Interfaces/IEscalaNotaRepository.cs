using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IEscalaNotaRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbEscalaNotas obj);
        Task<Answer> Edit(tbEscalaNotas obj);
        Task<Answer> Solapa(decimal desde, decimal hasta, int? id);
        Task<Answer> Delete(int id);
        Task<Answer> CuadroHonor(int anio, int? nivId, int? secId);
        Task<Answer> ConfigGet();
        Task<Answer> ConfigSet(tbCuadroHonorConfig obj);
    }
}
