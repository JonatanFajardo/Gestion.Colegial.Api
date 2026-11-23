using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IEncargadoRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbEncargados obj);
        Task<Answer> Edit(tbEncargados obj);
        Task<Answer> Delete(int id);
        Task<Answer> ByAlumno(int Alu_Id);
        Task<Answer> Vincular(int Enc_Id, int Alu_Id, int Par_Id);
        Task<Answer> Desvincular(int Enc_Id, int Alu_Id);
    }
}
