using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class AsistenciaService : IAsistenciaService
    {
        private readonly IAsistenciaRepository _r;
        public AsistenciaService(IAsistenciaRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> task, string successMsg = null)
        {
            Answer answer = await task;
            try
            {
                if (answer.Access) { answer.Message = MessageShow.Error; Logs.Error(answer); }
                else if (successMsg != null) answer.Message = successMsg;
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true; answer.Message = MessageShow.Error;
                answer.Incidents(e); Logs.Error(answer); return answer;
            }
        }

        public Task<Answer> List(int Hor_Id, DateTime Fecha)
            => Wrap(_r.List(Hor_Id, Fecha));

        public Task<Answer> ByAlumno(int Alu_Id, int? Anio)
            => Wrap(_r.ByAlumno(Alu_Id, Anio));

        public Task<Answer> Insert(int Hor_Id, int Alu_Id, DateTime Asi_Fecha, string Asi_Estado, string Asi_Observacion, int usuarioRegistra)
            => Wrap(_r.Insert(Hor_Id, Alu_Id, Asi_Fecha, Asi_Estado, Asi_Observacion, usuarioRegistra), MessageShow.SuccessSave);

        public Task<Answer> Update(int Asi_Id, string Asi_Estado, string Asi_Observacion, int usuarioModifica)
            => Wrap(_r.Update(Asi_Id, Asi_Estado, Asi_Observacion, usuarioModifica), MessageShow.SuccessEdit);
    }
}
