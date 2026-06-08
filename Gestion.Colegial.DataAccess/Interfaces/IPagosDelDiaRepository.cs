using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IPagosDelDiaRepository
    {
        Task<Answer> List(DateTime Fecha);
    }
}
