namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Un grupo de ubicación (nivel + grado + modalidad + sección) de los alumnos del año,
    /// con su sección del año (si existe) y cuántos están inscritos.
    /// </summary>
    public class PR_tbMatriculaAnio_ResumenInscripcionResult
    {
        public int? Ani_Id { get; set; }
        public int Niv_Id { get; set; }
        public int Cun_Id { get; set; }
        public int? Mda_Id { get; set; }
        public int Sec_Id { get; set; }
        public string Niv_Descripcion { get; set; }
        public string Cun_Descripcion { get; set; }
        public string Mda_Descripcion { get; set; }
        public string Sec_Descripcion { get; set; }
        public int Alumnos { get; set; }
        public int Inscritos { get; set; }
        public int Pendientes { get; set; }
        public int? Sea_Id { get; set; }
        public string Sea_Nombre { get; set; }
    }
}
