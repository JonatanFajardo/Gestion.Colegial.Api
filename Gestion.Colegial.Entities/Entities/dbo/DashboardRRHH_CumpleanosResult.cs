using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardRRHH_CumpleanosResult
    {
        public string?   NombreCompleto      { get; set; }
        public DateTime  Per_FechaNacimiento { get; set; }
        public int       Dia                 { get; set; }
        public int       Edad                { get; set; }
        public string?   Per_Imagen          { get; set; }
        public string?   Cargo               { get; set; }
        public string?   Departamento        { get; set; }
    }
}
