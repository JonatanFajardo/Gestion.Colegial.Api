using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    public class DashboardConsultaResult
    {
        public DashboardConsulta_KpisResult? Kpis { get; set; }
        public List<DashboardConsulta_EvolucionMatriculaResult>? EvolucionMatricula { get; set; }
        public List<DashboardConsulta_MatriculaPorNivelResult>? MatriculaPorNivel { get; set; }
        public List<DashboardConsulta_MatriculaPorJornadaResult>? MatriculaPorJornada { get; set; }
        public List<DashboardConsulta_MatriculaPorCursoResult>? MatriculaPorCurso { get; set; }
        public List<DashboardConsulta_AlumnosPorGeneroResult>? AlumnosPorGenero { get; set; }
        public List<DashboardConsulta_AlumnosPorEdadResult>? AlumnosPorEdad { get; set; }
        public List<DashboardConsulta_EmpleadosPorDepartamentoResult>? EmpleadosPorDepartamento { get; set; }
        public List<DashboardConsulta_EmpleadosPorCargoResult>? EmpleadosPorCargo { get; set; }
        public List<DashboardConsulta_IndicadorInstitucionalResult>? IndicadoresInstitucionales { get; set; }
    }
}
