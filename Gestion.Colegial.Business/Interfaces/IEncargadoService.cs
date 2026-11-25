using Gestion.Colegial.Business.Dtos;
using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEncargadoService
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(EncargadosFindDto obj);
        Task<Answer> Edit(EncargadosFindDto obj);
        Task<Answer> Delete(int id);
        Task<Answer> ByAlumno(int Alu_Id);
        Task<Answer> SinVinculo(string tipo);
        Task<Answer> Vincular(int Enc_Id, int Alu_Id, int Par_Id);
        Task<Answer> Desvincular(int Enc_Id, int Alu_Id);
    }
}
