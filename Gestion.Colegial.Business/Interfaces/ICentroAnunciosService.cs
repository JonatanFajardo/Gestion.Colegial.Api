using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface ICentroAnunciosService
    {
        Task<Answer> List();
        Task<Answer> Insert(string Anu_Titulo, string Anu_Contenido, DateTime? Anu_FechaExpiracion, int UsuarioRegistra, string Anu_Publico, int? Anu_NivId, int? Anu_CunId, int? Anu_SecId);
        Task<Answer> Opciones(string tipo, int? padre);
        Task<Answer> ParaFamilia(int usuId);
        Task<Answer> Delete(int Anu_Id, int UsuarioModifica);
    }
}
