namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Resultado de crear secciones del año y/o inscribir alumnos desde su ubicación.
    /// </summary>
    public class PR_tbMatriculaAnio_InscribirDesdeUbicacionResult
    {
        public int SeccionesCreadas { get; set; }
        public int Inscritos { get; set; }
        public int Reactivados { get; set; }
        public int YaInscritos { get; set; }
        public int SinSeccion { get; set; }
        public int Activados { get; set; }
    }
}
