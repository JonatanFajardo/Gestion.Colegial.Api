namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>Datos para emitir una constancia, boletín o expediente (script 064).</summary>
    public class DocumentoEmitirDTO
    {
        /// <summary>ESTUDIO | BOLETIN | EXPEDIENTE.</summary>
        public string? Doc_Tipo { get; set; }
        public int Alu_Id { get; set; }
        /// <summary>Obligatorio en ESTUDIO y BOLETIN; el expediente no lleva año.</summary>
        public int? Ani_Id { get; set; }
        /// <summary>Solo en BOLETIN, para un solo parcial.</summary>
        public int? Pac_Id { get; set; }
        /// <summary>Obligatorio desde la segunda revisión.</summary>
        public string? Doc_Motivo { get; set; }
        public int? Doc_UsuarioEmite { get; set; }
    }
}
