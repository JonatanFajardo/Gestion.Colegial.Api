namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Un documento emitido en el listado (script 064). Doc_EsUltima = es la revisión más nueva de su grupo.</summary>
    public class PR_tbDocumentosEmitidos_ListResult
    {
        public int Doc_Id { get; set; }
        public string Doc_Tipo { get; set; }
        public string Doc_Referencia { get; set; }
        public int Doc_Revision { get; set; }
        public int Alu_Id { get; set; }
        public string Alu_Nombre { get; set; }
        public string Alu_Identidad { get; set; }
        public int? Ani_Id { get; set; }
        public string Ani_Nombre { get; set; }
        public int? Pac_Id { get; set; }
        public string Pac_Descripcion { get; set; }
        public decimal? Doc_Promedio { get; set; }
        public string Doc_Motivo { get; set; }
        public DateTime Doc_FechaEmision { get; set; }
        public string Doc_EmitidoPor { get; set; }
        public bool Doc_EsUltima { get; set; }
    }

    /// <summary>Un documento con su contenido congelado (JSON).</summary>
    public class PR_tbDocumentosEmitidos_FindResult : PR_tbDocumentosEmitidos_ListResult
    {
        public string Doc_Contenido { get; set; }
    }

    /// <summary>Vista previa: Codigo 0 = bien; -1 sin notas; -2 sin matrícula; -3 datos inválidos.</summary>
    public class PR_tbDocumentosEmitidos_VistaPreviaResult
    {
        public int Codigo { get; set; }
        public string Doc_Contenido { get; set; }
        public decimal? Doc_Promedio { get; set; }
        public int RevisionSiguiente { get; set; }
    }

    /// <summary>Emisión: Id nuevo (mayor que 0) o código negativo.</summary>
    public class PR_tbDocumentosEmitidos_EmitirResult
    {
        public int? NewId { get; set; }
    }
}
