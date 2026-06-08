using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IVacacionesService
    {
        Task<Answer> List(int? Emp_Id);
        Task<Answer> Insert(int Emp_Id, string Vac_Tipo, DateTime Vac_FechaInicio, DateTime Vac_FechaFin, string Vac_Motivo, int usuarioRegistra);
        Task<Answer> Approve(int Vac_Id, string Vac_Estado, int usuarioModifica);
        Task<Answer> Delete(int Vac_Id, int usuarioModifica);
    }
}
