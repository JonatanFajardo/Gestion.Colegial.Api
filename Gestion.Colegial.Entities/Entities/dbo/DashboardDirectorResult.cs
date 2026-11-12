using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    public class DashboardDirectorResult
    {
        public DashboardDirector_KpisResult? Kpis { get; set; }
        public List<DashboardDirector_MatriculaPorCursoResult>? MatriculaPorCurso { get; set; }
        public List<DashboardDirector_CobrosPorMesResult>? CobrosPorMes { get; set; }
        public List<DashboardDirector_AsistenciaHoyCursoResult>? AsistenciaHoy { get; set; }
        public List<DashboardDirector_RendimientoCursoResult>? RendimientoPorCurso { get; set; }
        public List<DashboardDirector_TopDeudaResult>? TopDeuda { get; set; }
        public List<DashboardDirector_AlertaResult>? Alertas { get; set; }
    }
}
