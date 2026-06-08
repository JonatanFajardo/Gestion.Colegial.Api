using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IAsistenciaEmpleadosService
    {
        Task<Answer> List(int? Emp_Id, DateTime? Fecha);
        Task<Answer> Insert(int Emp_Id, DateTime AsiEmp_Fecha, string AsiEmp_Estado, string AsiEmp_Observacion, int usuarioRegistra);
    }
}
