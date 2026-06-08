using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IArqueosCajaService
    {
        Task<Answer> Find(int Arq_Id);
        Task<Answer> LastByUsuario(int Usu_Id);
        Task<Answer> Insert(int Usu_Id, DateTime Arq_Fecha, decimal Arq_TotalEfectivo, decimal Arq_TotalTransferencia, decimal Arq_TotalTarjeta, string Arq_Observaciones, int usuarioRegistra);
    }
}
