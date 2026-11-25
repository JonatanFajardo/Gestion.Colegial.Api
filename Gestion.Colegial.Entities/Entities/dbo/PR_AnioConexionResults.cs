namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbSeccionesAnio_CuposResult
    {
        public int Sea_Id { get; set; }
        public int Ani_Id { get; set; }
        public string? Sea_Nombre { get; set; }
        public string? Niv_Descripcion { get; set; }
        public string? Cun_Descripcion { get; set; }
        public string? Sec_Descripcion { get; set; }
        public string? Mda_Descripcion { get; set; }
        public int? Sea_Cupo { get; set; }
        public int Inscritos { get; set; }
        public int? Libres { get; set; }
    }

    public class PR_tbSeccionesAnio_ActualizarCupoResult
    {
        public int Sea_Id { get; set; }
        public int Sea_Cupo { get; set; }
        public int Inscritos { get; set; }
        public int Libres { get; set; }
    }

    public class PR_AnioConexion_AniosInscripcionResult
    {
        public int Ani_Id { get; set; }
        public int Ani_Anio { get; set; }
        public string? Ani_Nombre { get; set; }
        public int Ani_Estado { get; set; }
        public string? Ani_EstadoTexto { get; set; }
        public bool EsActivo { get; set; }
        public int Secciones { get; set; }
        public int SeccionesConCupo { get; set; }
        public int? Cupo { get; set; }
        public int Inscritos { get; set; }
    }

    public class PR_AnioConexion_VerificarCupoResult
    {
        public int? Ani_Id { get; set; }
        public string? Ani_Nombre { get; set; }
        public bool EsActivo { get; set; }
        public int? Sea_Id { get; set; }
        public string? Sea_Nombre { get; set; }
        public int? Cupo { get; set; }
        public int Inscritos { get; set; }
        public int? Libres { get; set; }
        public bool Permitido { get; set; }
        public string? Mensaje { get; set; }
    }

    public class PR_AnioConexion_InscribirAlumnoResult
    {
        public int Mta_Id { get; set; }
        public int Sea_Id { get; set; }
        public string? Sea_Nombre { get; set; }
        public string? Ani_Nombre { get; set; }
        public int? Cupo { get; set; }
        public int Inscritos { get; set; }
    }

    public class PR_tbAnioLectivo_AplicarUbicacionResult
    {
        public int Aplicados { get; set; }
        public int CursoPorRevisar { get; set; }
    }

    public class PR_tbAnioLectivo_UbicacionPreviaResult
    {
        public int Mover { get; set; }
        public int CursoPorRevisar { get; set; }
        public int NoActivos { get; set; }
    }

    public class PR_AnioConexion_SemestresResult
    {
        public int Sem_Id { get; set; }
        public string? Nombre { get; set; }
        public DateTime? Inicio { get; set; }
        public DateTime? Fin { get; set; }
    }
}
