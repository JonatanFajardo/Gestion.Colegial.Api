using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IDocumentosAlumnoService
    {
        Task<Answer> List(int Alu_Id);
        Task<Answer> PendientesList();
        Task<Answer> Update(int Alu_Id, int TDoc_Id, bool Doa_EsEntregado, DateTime? Doa_FechaEntrega, string Doa_Observacion, int usuarioRegistra);
    }
}
