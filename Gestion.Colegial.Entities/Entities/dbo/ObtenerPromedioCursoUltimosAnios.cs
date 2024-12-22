using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gestion.Colegial.Entities.Entities.dbo
{
    public  class ObtenerPromedioCursoUltimosAnios
    {
        public string Curso { get; set; }
        public int AnioCursado { get; set; }
        public decimal PromedioAnual { get; set; }
    }
}
