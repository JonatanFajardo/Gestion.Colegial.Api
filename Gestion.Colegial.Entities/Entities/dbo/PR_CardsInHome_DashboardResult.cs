using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gestion.Colegial.Entities.Entities.dbo
{
    public class PR_CardsInHome_DashboardResult
    {
        public int Graduados { get; set; }            // Número de graduados
        public int DiferenciaPromedioAnual { get; set; }  // Diferencia con el promedio anual
        public int ActualPromedioAnual { get; set; }   // Promedio anual actual
        public int DiferenciaNuevoIngreso { get; set; }  // Diferencia de nuevo ingreso

    }
}
