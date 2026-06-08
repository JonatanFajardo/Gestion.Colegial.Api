using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface ICumplimientoDocumentosRepository
    {
        Task<Answer> List(int? Emp_Id);
    }
}
