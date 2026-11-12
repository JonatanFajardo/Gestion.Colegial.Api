using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    public class DashboardDocenteResult
    {
        public List<DashboardDocente_ClasesHoyResult>? ClasesHoy { get; set; }
        public DashboardDocente_KpisDocenteResult? KpisDocente { get; set; }
    }
}
