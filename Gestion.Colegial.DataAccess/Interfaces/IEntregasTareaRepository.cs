using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IEntregasTareaRepository
    {
        Task<Answer> List(int Tar_Id);
        Task<Answer> Upsert(int Tar_Id, int Alu_Id, bool Ent_Entregado, string Ent_Observacion, int usuarioRegistra);
        Task<Answer> Update(int Ent_Id, decimal Ent_Nota, string Ent_Observacion, int usuarioModifica);
    }
}
