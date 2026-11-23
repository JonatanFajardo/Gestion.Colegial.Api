namespace Gestion.Colegial.Api.Seguridad
{
    /// <summary>
    /// Con GC_API_KEY configurada: responde 401 si falta la llave o no coincide, y también si llega
    /// un X-Gc-Usuario falsificado o vencido. El usuario válido queda en HttpContext.Items.
    /// Sin GC_API_KEY deja pasar todo, como antes.
    /// </summary>
    public sealed class LlaveApiMiddleware
    {
        /// <summary>Clave de HttpContext.Items donde queda el Usu_Id firmado.</summary>
        public const string ClaveUsuario = "gc.UsuarioFirmado";

        private readonly RequestDelegate _next;
        private readonly OpcionesSeguridad _opciones;
        private readonly bool _swaggerLibre;
        private readonly ILogger<LlaveApiMiddleware> _logger;

        public LlaveApiMiddleware(RequestDelegate next, OpcionesSeguridad opciones, IWebHostEnvironment entorno,
                                  ILogger<LlaveApiMiddleware> logger)
        {
            _next = next;
            _opciones = opciones;
            _logger = logger;
            // La página de Swagger solo existe en desarrollo; se puede abrir sin llave (las llamadas sí la piden).
            _swaggerLibre = entorno.IsDevelopment();
        }

        public async Task InvokeAsync(HttpContext contexto)
        {
            if (!_opciones.Activa || (_swaggerLibre && contexto.Request.Path.StartsWithSegments("/swagger")))
            {
                await _next(contexto);
                return;
            }

            if (!_opciones.LlaveValida(contexto.Request.Headers[OpcionesSeguridad.EncabezadoLlave].ToString()))
            {
                _logger.LogWarning("Llamada rechazada sin llave válida: {Metodo} {Ruta} desde {Ip}",
                    contexto.Request.Method, contexto.Request.Path, contexto.Connection.RemoteIpAddress);
                await Rechazar(contexto, "Falta la llave de la API o no es válida.");
                return;
            }

            string firmado = contexto.Request.Headers[OpcionesSeguridad.EncabezadoUsuario].ToString();
            if (!string.IsNullOrEmpty(firmado))
            {
                int? usuId = _opciones.LeerUsuario(firmado, DateTimeOffset.UtcNow);
                if (usuId == null)
                {
                    _logger.LogWarning("Usuario firmado no válido o vencido: {Metodo} {Ruta}", contexto.Request.Method, contexto.Request.Path);
                    await Rechazar(contexto, "El usuario de la sesión no es válido o ya venció.");
                    return;
                }
                contexto.Items[ClaveUsuario] = usuId.Value;
            }

            await _next(contexto);
        }

        // Mismos nombres que el resto de respuestas de la API (Ok, Mensaje).
        private static readonly System.Text.Json.JsonSerializerOptions Json = new() { PropertyNamingPolicy = null };

        private static Task Rechazar(HttpContext contexto, string mensaje)
        {
            contexto.Response.StatusCode = StatusCodes.Status401Unauthorized;
            return contexto.Response.WriteAsJsonAsync(new { Ok = false, Mensaje = mensaje }, Json);
        }
    }
}
