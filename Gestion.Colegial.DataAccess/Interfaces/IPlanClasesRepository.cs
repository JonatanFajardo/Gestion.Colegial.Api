using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IPlanClasesRepository
    {
        Task<Answer> List(int Hor_Id);
        Task<Answer> Find(int Pla_Id);
        Task<Answer> Insert(int Hor_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, int usuarioRegistra);
        Task<Answer> Update(int Pla_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, string Pla_Estado, int usuarioModifica);
        Task<Answer> Delete(int Pla_Id, int usuarioModifica);
    }
}
