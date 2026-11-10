using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface ICumplimientoDocumentosService
    {
        Task<Answer> List(int? Emp_Id);
        Task<Answer> MarcarEntregado(int Emp_Id, string Documento, bool EsEntregado, DateTime? FechaEntrega, DateTime? Doc_FechaVencimiento, string Observacion, int usuarioRegistra);
    }
}
