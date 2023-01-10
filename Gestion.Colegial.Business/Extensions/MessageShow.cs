namespace Gestion.Colegial.Business.Extensions
{
    public class MessageShow
    {
        public static string Error { get; set; }
        public static string SuccessSave { get; set; }
        public static string SuccessEdit { get; set; }
        public static string SuccessDelete { get; set; }
        public static string SuccessExist { get; set; }

        public MessageShow()
        {
            Error = ".";
            SuccessSave = "Operación completada correctamente.";
            SuccessEdit = "Operación completada correctamente.";
            SuccessDelete = "Operación completada correctamente.";
            SuccessExist = "Operación completada correctamente.";
        }
    }
}
