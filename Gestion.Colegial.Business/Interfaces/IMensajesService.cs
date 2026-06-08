using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IMensajesService
    {
        Task<Answer> List(int? Alu_Id, int? UsuarioId);
        Task<Answer> Insert(string Msg_Asunto, string Msg_Contenido, int Alu_Id, int UsuarioEnvia);
        Task<Answer> Delete(int Msg_Id, int UsuarioModifica);
    }
}
