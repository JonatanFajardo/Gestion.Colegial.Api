using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    public class DashboardSecretariaResult
    {
        public DashboardSecretaria_KpisResult? Kpis { get; set; }
        public List<DashboardSecretaria_MatriculaPorSeccionResult>? MatriculaPorSeccion { get; set; }
        public List<DashboardSecretaria_TramiteResult>? TramitesHoy { get; set; }
        public List<DashboardSecretaria_MatriculaPorMesResult>? MatriculaPorMes { get; set; }
        public List<DashboardSecretaria_DocumentoPorTipoResult>? DocumentosPorTipo { get; set; }
        public List<DashboardSecretaria_AlumnoDocsPendientesResult>? AlumnosConDocsPendientes { get; set; }
        public List<DashboardSecretaria_EncargadoIncompletoResult>? EncargadosIncompletos { get; set; }
        public List<DashboardSecretaria_CumpleanosResult>? CumpleanosSemana { get; set; }
    }
}
