using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface INotasService
    {
        Task<Answer> List(int Hor_Id, int Par_Id);
        Task<Answer> Cuaderno(int Sec_Id, int Mat_Id, int Par_Id, int Sem_Id, int Anio);
        Task<Answer> Boletin(int Alu_Id, int Sem_Id, int Anio);
        Task<Answer> Insert(int Alu_Id, int Sec_Id, int Mat_Id, int Sem_Id, int Par_Id,
                            decimal Not_Nota, DateTime Not_Año, int usuarioRegistra);
        Task<Answer> Edit(int Not_Id, decimal Not_Nota, int usuarioModifica);
    }
}
