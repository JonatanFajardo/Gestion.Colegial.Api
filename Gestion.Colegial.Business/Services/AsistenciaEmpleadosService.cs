using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class AsistenciaEmpleadosService : IAsistenciaEmpleadosService
    {
        private readonly IAsistenciaEmpleadosRepository _r;
        public AsistenciaEmpleadosService(IAsistenciaEmpleadosRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> t, string msg = null)
        {
            Answer a = await t;
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } else if (msg != null) a.Message = msg; return a; }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }
        }

        public Task<Answer> List(int? Emp_Id, DateTime? Fecha) => Wrap(_r.List(Emp_Id, Fecha));
        public Task<Answer> Insert(int Emp_Id, DateTime AsiEmp_Fecha, string AsiEmp_Estado, string AsiEmp_Observacion, int usuarioRegistra)
            => Wrap(_r.Insert(Emp_Id, AsiEmp_Fecha, AsiEmp_Estado, AsiEmp_Observacion, usuarioRegistra), MessageShow.SuccessSave);
    }
}
