using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IAlumnosDirectorioRepository
    {
        Task<Answer> List(int? Cur_Id, int? Sec_Id);
    }
}
