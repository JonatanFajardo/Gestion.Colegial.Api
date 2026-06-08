using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface ICumplimientoDocumentosService
    {
        Task<Answer> List(int? Emp_Id);
    }
}
