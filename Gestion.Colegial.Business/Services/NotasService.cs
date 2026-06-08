using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class NotasService : INotasService
    {
        private readonly INotasRepository _r;
        public NotasService(INotasRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> task, string msg = null)
        {
            Answer a = await task;
            try
            {
                if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); }
                else if (msg != null) a.Message = msg;
                return a;
            }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }
        }

        public Task<Answer> List(int Hor_Id, int Par_Id)
            => Wrap(_r.List(Hor_Id, Par_Id));

        public Task<Answer> Cuaderno(int Sec_Id, int Mat_Id, int Par_Id, int Sem_Id, int Anio)
            => Wrap(_r.Cuaderno(Sec_Id, Mat_Id, Par_Id, Sem_Id, Anio));

        public Task<Answer> Boletin(int Alu_Id, int Sem_Id, int Anio)
            => Wrap(_r.Boletin(Alu_Id, Sem_Id, Anio));

        public Task<Answer> Insert(int Alu_Id, int Sec_Id, int Mat_Id, int Sem_Id, int Par_Id,
                                   decimal Not_Nota, DateTime Not_Año, int usuarioRegistra)
            => Wrap(_r.Insert(Alu_Id, Sec_Id, Mat_Id, Sem_Id, Par_Id, Not_Nota, Not_Año, usuarioRegistra),
                    MessageShow.SuccessSave);

        public Task<Answer> Edit(int Not_Id, decimal Not_Nota, int usuarioModifica)
            => Wrap(_r.Edit(Not_Id, Not_Nota, usuarioModifica), MessageShow.SuccessEdit);
    }
}
