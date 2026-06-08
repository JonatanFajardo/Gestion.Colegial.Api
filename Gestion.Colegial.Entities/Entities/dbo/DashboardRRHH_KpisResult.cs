namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardRRHH_KpisResult
    {
        public int TotalEmpleadosActivos    { get; set; }
        public int TotalEmpleadosInactivos  { get; set; }
        public int CumpleanosMes            { get; set; }
        public int CumpleanosHoy            { get; set; }
        public int VacacionesPendientes     { get; set; }
        public int PermisosPendientes       { get; set; }
        public int IncapacidadesPendientes  { get; set; }
        public int NuevosEmpleadosAnio      { get; set; }
        public int PresentesHoy             { get; set; }
        public int AusentesHoy              { get; set; }
        public int TardanzasHoy             { get; set; }
        public int TotalCargos              { get; set; }
        public int TotalDepartamentos       { get; set; }
    }
}
