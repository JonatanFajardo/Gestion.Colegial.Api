using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.dbo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class HomeAndChartsRepository: RepositoryBase
    {
        public async Task<Answer> DiferenciaEntreCantidadAlumnosAnioPasado_Dashboard()
        {
            const string sql = "PR_DiferenciaEntreCantidadAlumnosAnioPasado_Dashboard";
            Answer answer = await Read<DiferenciaEntreCantidadAlumnosAnioPasado_DashboardResult>(sql);
            return answer;
        }

        public async Task<Answer> ObtenerCantidadAlumnosPorCursoList()
        {
            const string sql = "PR_ObtenerCantidadAlumnosPorCurso_Dashboard";
            Answer answer = await Read<PR_ObtenerCantidadAlumnosPorCurso_DashboardResult>(sql);
            return answer;
        }


        public async Task<Answer> ObtenerPromedioCursoUltimosAnios()
        {
            const string sql = "PR_ObtenerPromedioCursoUltimosAnios_Dashboard";
            Answer answer = await Read<ObtenerPromedioCursoUltimosAnios>(sql);
            return answer;
        }
    }
}
