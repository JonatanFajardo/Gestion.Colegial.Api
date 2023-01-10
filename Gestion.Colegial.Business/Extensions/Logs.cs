using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Extensions
{
    public static class Logs
    {
        public static void Error(Answer answer)
        {
            //string path = Properties.Settings.Default.pathLog.ToString();
            //var logPath = $"{path}log.txt";
            //var log = new LoggerConfiguration().WriteTo.File(logPath).CreateLogger();
            //dynamic InnerException = "";

            //if (answer.InnerException == null)
            //{
            //    InnerException = "No contiene.";
            //}
            //else
            //{
            //    InnerException = answer.InnerException;
            //}
            //string logResult = $"[MENSAJE] {answer.Message} [MSJGENERAL] {answer.ErrorGeneral} [DETALLES] {answer.ErrorDetails} [MSJINTERNO] {InnerException}";
            //log.Error(logResult);

            throw new NotImplementedException();
        }
    }
}
