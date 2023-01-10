using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    internal interface IServices<T>
    {
        Task<Answer> List();

        Task<Answer> Find(int id);

        Task<Answer> Create(T entity);

        Task<Answer> Edit(T entity);

        Task<Answer> Delete(int id);
    }
}
