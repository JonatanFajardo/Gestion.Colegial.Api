namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>Datos para registrar un caso de disciplina con las personas que participaron.</summary>
    public class CasoDisciplinaRegistrarDTO
    {
        public string? Cas_Resumen { get; set; }
        /// <summary>conducta | proteccion (protección del menor = reservado).</summary>
        public string? Cas_Tipo { get; set; }
        public string? Cas_Descripcion { get; set; }
        public string? Cas_Lugar { get; set; }
        public DateTime Cas_FechaOcurrio { get; set; }
        public int? Emp_IdAtiende { get; set; }
        public List<CasoDisciplinaPersonaDTO> Personas { get; set; } = new List<CasoDisciplinaPersonaDTO>();
        public int? Usuario { get; set; }
    }

    /// <summary>Una persona del caso. Papel: implicado | afectado | testigo | reporta | atiende.</summary>
    public class CasoDisciplinaPersonaDTO
    {
        public int? Alu_Id { get; set; }
        public string? Papel { get; set; }
        public string? Nota { get; set; }
    }

    public class CasoDisciplinaEstadoDTO
    {
        public int Cas_Id { get; set; }
        public string? Estado { get; set; }
        public string? Motivo { get; set; }
        public int? Usuario { get; set; }
    }

    public class CasoDisciplinaAccionDTO
    {
        public int Cas_Id { get; set; }
        public string? Cac_Tipo { get; set; }
        public string? Cac_Descripcion { get; set; }
        public DateTime? Cac_FechaLimite { get; set; }
        public int? Emp_IdResponsable { get; set; }
        public int? Usuario { get; set; }
    }

    public class CasoDisciplinaNotaDTO
    {
        public int Cas_Id { get; set; }
        public string? Cno_Texto { get; set; }
        public bool Cno_EsPrivada { get; set; } = true;
        public int? Usuario { get; set; }
    }
}
