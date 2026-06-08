using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface ITareasService
    {
        Task<Answer> List(int Hor_Id);
        Task<Answer> Find(int Tar_Id);
        Task<Answer> Insert(int Hor_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, int usuarioRegistra);
        Task<Answer> Update(int Tar_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, string Tar_Estado, int usuarioModifica);
        Task<Answer> Delete(int Tar_Id, int usuarioModifica);
    }
}
