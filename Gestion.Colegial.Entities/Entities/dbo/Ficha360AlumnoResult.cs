using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    public class Ficha360AlumnoResult
    {
        public Ficha360Alumno_DatosPersonalesResult? DatosPersonales { get; set; }
        public List<Ficha360Alumno_CuentasPorCobrarResult>? CuentasPorCobrar { get; set; }
        public List<Ficha360Alumno_AsistenciaRecienteResult>? AsistenciaReciente { get; set; }
    }
}
