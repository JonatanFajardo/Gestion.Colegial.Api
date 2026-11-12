using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IAlumnosDirectorioService
    {
        Task<Answer> List(int? Cur_Id, int? Sec_Id);
    }
}
