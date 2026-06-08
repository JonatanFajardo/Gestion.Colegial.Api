using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IBitacoraService
    {
        Task<Answer> List(int? Usu_Id, string Bit_Tabla, int? Top);
        Task<Answer> Insert(int Usu_Id, string Bit_Accion, string Bit_Tabla, int? Bit_RegistroId, string Bit_Descripcion, string Bit_Ip);
    }
}
