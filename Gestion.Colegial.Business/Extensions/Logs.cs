using Gestion.Colegial.Entities;
using Serilog;
using Serilog.Sinks.File;
using System;
using System.IO;

namespace Gestion.Colegial.Business.Extensions
{
    public static class Logs
    {
        /// <summary>
        /// Registra un error utilizando Serilog configurado globalmente.
        /// </summary>
        /// <param name="answer">Objeto Answer que contiene la información del error.</param>
        public static void Error(Answer answer)
        {
            try
            {
                // Usar Serilog global configurado en Program.cs
                LogWithSerilog(answer);
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

        /// <summary>
        /// Utiliza el logger global de Serilog para registrar errores.
        /// </summary>
        private static void LogWithSerilog(Answer answer)
        {
            string innerException = answer.InnerException?.ToString() ?? "No contiene";
            string stackTrace = answer.StackTrace ?? "No disponible";

            // Logging estructurado con Serilog
            Log.Error(
                "Error en la aplicación. " +
                "Mensaje: {Message}, " +
                "Error General: {ErrorGeneral}, " +
                "Detalles: {ErrorDetails}, " +
                "StackTrace: {StackTrace}, " +
                "InnerException: {InnerException}",
                answer.Message,
                answer.ErrorGeneral,
                answer.ErrorDetails,
                stackTrace,
                innerException
            );
        }

        /// <summary>
        /// Archivo de respaldo en caso de que falle el sistema de logging principal.
        /// </summary>
        private static void LogToBackupFile(Exception loggingException, Answer answer)
        {
            string backupPath = Path.Combine(Path.GetTempPath(), "GestionColegial_ErrorLog.txt");

            string backupLog = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] LOGGING ERROR: {loggingException.Message}" +
                              $"{Environment.NewLine}ORIGINAL ERROR: {answer.Message}" +
                              $"{Environment.NewLine}---{Environment.NewLine}";

            File.AppendAllText(backupPath, backupLog);
        }
    }
}