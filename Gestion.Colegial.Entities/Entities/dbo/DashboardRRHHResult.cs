using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    public class DashboardRRHHResult
    {
        public DashboardRRHH_KpisResult?                    Kpis                 { get; set; }
        public List<DashboardRRHH_PorDepartamentoResult>?   PorDepartamento      { get; set; }
        public List<DashboardRRHH_PorCargoResult>?          PorCargo             { get; set; }
        public List<DashboardRRHH_AsistenciaDiariaResult>?  AsistenciaDiaria     { get; set; }
        public List<DashboardRRHH_SolicitudTipoResult>?     SolicitudesPorTipo   { get; set; }
        public List<DashboardRRHH_NuevosPorMesResult>?      NuevosPorMes         { get; set; }
        public List<DashboardRRHH_PorGeneroResult>?         PorGenero            { get; set; }
        public List<DashboardRRHH_PorEdadResult>?           PorEdad              { get; set; }
        public List<DashboardRRHH_CumpleanosResult>?        Cumpleanos           { get; set; }
        public List<DashboardRRHH_SolicitudDetalleResult>?  SolicitudesPendientes { get; set; }
        public List<DashboardRRHH_AntiguedadResult>?        TopAntiguedad        { get; set; }
        public List<DashboardRRHH_AlertaResult>?            Alertas              { get; set; }
    }
}
