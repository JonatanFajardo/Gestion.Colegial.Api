using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IAsistenciaRepository
    {
        Task<Answer> List(int Hor_Id, DateTime Fecha);
        Task<Answer> ByAlumno(int Alu_Id, int? Anio);
        Task<Answer> Insert(int Hor_Id, int Alu_Id, DateTime Asi_Fecha, string Asi_Estado, string Asi_Observacion, int usuarioRegistra);
        Task<Answer> Update(int Asi_Id, string Asi_Estado, string Asi_Observacion, int usuarioModifica);
    }
}
