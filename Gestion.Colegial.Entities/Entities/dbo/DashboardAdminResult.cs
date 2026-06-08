using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    public class DashboardAdminResult
    {
        public DashboardAdmin_KpisResult? Kpis { get; set; }
        public List<DashboardAdmin_BitacoraResult>? Bitacora { get; set; }
        public List<DashboardAdmin_UsuariosPorRolResult>? UsuariosPorRol { get; set; }
    }
}
