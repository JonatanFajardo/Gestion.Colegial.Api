namespace Gestion.Colegial.Entities.Entities
{
    public class PR_Mensajes_ListResult
    {
        public int    Msg_Id             { get; set; }
        public string Msg_Asunto         { get; set; }
        public string Msg_Resumen        { get; set; }
        public string Msg_FechaEnvio     { get; set; }
        public string Msg_Estado         { get; set; }
        public string Alu_NombreCompleto { get; set; }
        public int    Alu_Id             { get; set; }
        public int    UsuarioEnvia       { get; set; }
    }
}
