using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class BitacoraService : IBitacoraService
    {
        private readonly IBitacoraRepository _r;
        public BitacoraService(IBitacoraRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> t, string msg = null)
        {
            Answer a = await t;
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } else if (msg != null) a.Message = msg; return a; }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }
        }

        public Task<Answer> List(int? Usu_Id, string Bit_Tabla, int? Top) => Wrap(_r.List(Usu_Id, Bit_Tabla, Top));
        public Task<Answer> Insert(int Usu_Id, string Bit_Accion, string Bit_Tabla, int? Bit_RegistroId, string Bit_Descripcion, string Bit_Ip)
            => Wrap(_r.Insert(Usu_Id, Bit_Accion, Bit_Tabla, Bit_RegistroId, Bit_Descripcion, Bit_Ip), MessageShow.SuccessSave);
    }
}
