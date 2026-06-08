using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class TareasService : ITareasService
    {
        private readonly ITareasRepository _r;
        public TareasService(ITareasRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> task, string msg = null)
        {
            var a = await task;
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } else if (msg != null) a.Message = msg; }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); }
            return a;
        }

        public Task<Answer> List(int Hor_Id)  => Wrap(_r.List(Hor_Id));
        public Task<Answer> Find(int Tar_Id)  => Wrap(_r.Find(Tar_Id));
        public Task<Answer> Insert(int Hor_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, int usuarioRegistra)
            => Wrap(_r.Insert(Hor_Id, Tar_Titulo, Tar_Descripcion, Tar_FechaEntrega, Tar_Punteo, usuarioRegistra), MessageShow.SuccessSave);
        public Task<Answer> Update(int Tar_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, string Tar_Estado, int usuarioModifica)
            => Wrap(_r.Update(Tar_Id, Tar_Titulo, Tar_Descripcion, Tar_FechaEntrega, Tar_Punteo, Tar_Estado, usuarioModifica), MessageShow.SuccessEdit);
        public Task<Answer> Delete(int Tar_Id, int usuarioModifica)
            => Wrap(_r.Delete(Tar_Id, usuarioModifica), MessageShow.SuccessDelete);
    }
}
