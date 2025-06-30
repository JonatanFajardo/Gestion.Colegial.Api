using Gestion.Colegial.Entities;
using Serilog;
using Serilog.Sinks.File;
using System;
using System.IO;

namespace Gestion.Colegial.Business.Extensions
{
    public static class Logs
    {
        public static void Error(Answer answer)
        {
            try
            {
                // Implementación con archivo de texto
                //ErrorWithSerilog(answer);
                ErrorToConsole(answer);
            }
            catch (Exception ex)
            {
                // Si falla el logging, intenta escribir en un archivo de backup
                try
                {
                    LogToBackupFile(ex, answer);
                }
                catch
                {
                    // Si todo falla, al menos escribe en consola
                    Console.WriteLine($"Error crítico en logging: {ex.Message}");
                }
            }
        }

        private static void LogToFile(Answer answer)
        {
            // Crear directorio de logs si no existe
            string logDirectory = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Logs");
            if (!Directory.Exists(logDirectory))
            {
                Directory.CreateDirectory(logDirectory);
            }

            string logPath = Path.Combine(logDirectory, $"log_{DateTime.Now:yyyyMMdd}.txt");

            string innerException = answer.InnerException?.ToString() ?? "No contiene.";

            string logResult = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] " +
                              $"[MENSAJE] {answer.Message} " +
                              $"[MSJGENERAL] {answer.ErrorGeneral} " +
                              $"[DETALLES] {answer.ErrorDetails} " +
                              $"[MSJINTERNO] {innerException}{Environment.NewLine}";

            // Escribir al archivo de log
            File.AppendAllText(logPath, logResult);
        }

        private static void LogToBackupFile(Exception loggingException, Answer answer)
        {
            string backupPath = Path.Combine(Path.GetTempPath(), "GestionColegial_ErrorLog.txt");

            string backupLog = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] LOGGING ERROR: {loggingException.Message}" +
                              $"{Environment.NewLine}ORIGINAL ERROR: {answer.Message}" +
                              $"{Environment.NewLine}---{Environment.NewLine}";

            File.AppendAllText(backupPath, backupLog);
        }
        public static void ErrorWithSerilog(Answer answer)
        {
            // Descomenta este código al usar Serilog

            string logdirectory = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "logs");
            if (!Directory.Exists(logdirectory))
            {
                Directory.CreateDirectory(logdirectory);
            }

            var logpath = Path.Combine(logdirectory, "log_.txt");
            var log = new LoggerConfiguration()
    .WriteTo.File(logpath, rollingInterval: RollingInterval.Day) // La propiedad es 'RollingInterval' y es un enum
    .CreateLogger();

            string innerexception = answer.InnerException?.ToString() ?? "no contiene.";

            string logresult = $"[mensaje] {answer.Message} " +
                              $"[msjgeneral] {answer.ErrorGeneral} " +
                              $"[detalles] {answer.ErrorDetails} " +
                              $"[msjinterno] {innerexception}";

            log.Error(logresult);
            log.Dispose();
        }

        // Método para logging en consola (útil para desarrollo)
        public static void ErrorToConsole(Answer answer)
        {
            string innerException = answer.InnerException?.ToString() ?? "No contiene.";

            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"[ERROR - {DateTime.Now:yyyy-MM-dd HH:mm:ss}]");
            Console.WriteLine($"Mensaje: {answer.Message}");
            Console.WriteLine($"Error General: {answer.ErrorGeneral}");
            Console.WriteLine($"Detalles: {answer.ErrorDetails}");
            Console.WriteLine($"Excepción Interna: {innerException}");
            Console.ResetColor();
        }
    }
}