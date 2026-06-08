using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class MisAlumnosService : IMisAlumnosService
    {
        private readonly IMisAlumnosRepository _r;
        public MisAlumnosService(IMisAlumnosRepository r) { _r = r; }

        public async Task<Answer> GetByHorario(int Hor_Id)
        {
            var a = await _r.GetByHorario(Hor_Id);
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); }
            return a;
        }
    }
}
