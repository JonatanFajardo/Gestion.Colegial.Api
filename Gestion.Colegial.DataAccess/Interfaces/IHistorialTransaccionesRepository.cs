using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IHistorialTransaccionesRepository
    {
        Task<Answer> List(int? Alu_Id, DateTime? FechaDesde, DateTime? FechaHasta);
    }
}
