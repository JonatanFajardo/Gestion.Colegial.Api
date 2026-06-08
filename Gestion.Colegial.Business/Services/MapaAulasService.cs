using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class MapaAulasService : IMapaAulasService
    {
        private readonly IMapaAulasRepository _r;
        public MapaAulasService(IMapaAulasRepository r) { _r = r; }

        public async Task<Answer> GetMapa()
        {
            var a = await _r.GetMapa();
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); }
            return a;
        }
    }
}
