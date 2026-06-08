using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IHistorialTransaccionesService
    {
        Task<Answer> List(int? Alu_Id, DateTime? FechaDesde, DateTime? FechaHasta);
    }
}
