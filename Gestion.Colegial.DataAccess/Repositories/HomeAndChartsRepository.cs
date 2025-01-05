using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Gestion.Colegial.Entities.Entities.dbo;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class HomeAndChartsRepository : RepositoryBase
    {
        /// <summary>
        /// Recupera la diferencia en la cantidad de estudiantes en comparación con el año pasado para el dashboard.
        /// </summary>
        /// <returns>Un objeto Answer que contiene los resultados del procedimiento almacenado.</returns>
        public async Task<Answer> DiferenciaEntreCantidadAlumnosAnioPasado_Dashboard()
        {
            const string sql = "PR_DiferenciaEntreCantidadAlumnosAnioPasado_Dashboard";
            Answer answer = await Read<DiferenciaEntreCantidadAlumnosAnioPasado_DashboardResult>(sql);
            return answer;
        }

        /// <summary>
        /// Recupera la cantidad de estudiantes por curso para el dashboard.
        /// </summary>
        /// <returns>Un objeto Answer que contiene los resultados del procedimiento almacenado.</returns>
        public async Task<Answer> ObtenerCantidadAlumnosPorCursoList()
        {
            const string sql = "PR_ObtenerCantidadAlumnosPorCurso_Dashboard";
            Answer answer = await Read<PR_ObtenerCantidadAlumnosPorCurso_DashboardResult>(sql);
            return answer;
        }

        /// <summary>
        /// Recupera el promedio de estudiantes por curso de los últimos años para el dashboard.
        /// </summary>
        /// <returns>Un objeto Answer que contiene los resultados del procedimiento almacenado.</returns>
        public async Task<Answer> ObtenerPromedioCursoUltimosAnios()
        {
            const string sql = "PR_ObtenerPromedioCursoUltimosAnios_Dashboard";
            Answer answer = await Read<ObtenerPromedioCursoUltimosAnios>(sql);
            return answer;
        }

        /// <summary>
        /// Recupera los datos de las tarjetas para mostrar en el dashboard de inicio.
        /// </summary>
        /// <returns>Un objeto Answer que contiene los resultados del procedimiento almacenado.</returns>
        public async Task<Answer> CardsInHomeList()
        {
            const string sql = "PR_CardsInHome_Dashboard";
            Answer answer = await Read<PR_CardsInHome_DashboardResult>(sql);
            return answer;
        }

    }
}
