using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    public class Ficha360EmpleadoResult
    {
        public Ficha360Empleado_DatosPersonalesResult? DatosPersonales { get; set; }
        public List<Ficha360Empleado_ClasesAsignadasResult>? ClasesAsignadas { get; set; }
        public List<Ficha360Empleado_HistorialVacacionesResult>? HistorialVacaciones { get; set; }
    }
}
