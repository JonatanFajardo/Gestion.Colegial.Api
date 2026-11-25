namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>Nuevo cupo de una sección del año (script 091).</summary>
    public class CupoSeccionDTO
    {
        public int Sea_Id { get; set; }
        public int Sea_Cupo { get; set; }
        public int? Usuario { get; set; }
    }

    /// <summary>Inscribe a un alumno ya creado en un año lectivo (null = año activo).</summary>
    public class InscribirAlumnoDTO
    {
        public int Alu_Id { get; set; }
        public int? Ani_Id { get; set; }
        public int? Usuario { get; set; }
    }

    /// <summary>Al abrir un año como activo, pasa la ubicación de sus inscritos a la sección del año.</summary>
    public class AplicarUbicacionDTO
    {
        public int Ani_Id { get; set; }
        public int? Usuario { get; set; }
        /// <summary>true = además marca el año como activo, en la misma transacción.</summary>
        public bool Activar { get; set; }
    }
}
