using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IPagosDelDiaService
    {
        Task<Answer> List(DateTime Fecha);
    }
}
