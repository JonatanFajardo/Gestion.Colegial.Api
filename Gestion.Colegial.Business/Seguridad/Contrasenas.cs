using System;
using System.Diagnostics.CodeAnalysis;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;

namespace Gestion.Colegial.Business.Seguridad
{
    /// <summary>
    /// Huella de las contraseñas de los usuarios. Es el ÚNICO lugar donde se calcula: cualquier alta,
    /// cambio, restablecimiento o activación de cuenta (por ejemplo, la del portal de padres) debe usar
    /// <see cref="Crear"/> y guardar el resultado con <c>IUsuarioService.GuardarContrasenaAsync</c>
    /// (procedimiento <c>seguridad.PR_tbUsuarios_GuardarContrasena</c>).
    ///
    /// Formato guardado: <c>v2$iteraciones$sal$huella</c> = PBKDF2-HMAC-SHA256 con sal aleatoria de
    /// 16 bytes por usuario y huella de 32 bytes (sal y huella en Base64).
    /// Formato anterior: SHA-256 sin sal (64 caracteres hexadecimales). Solo se acepta para
    /// convertirlo al formato nuevo cuando el usuario entra con la contraseña correcta.
    /// </summary>
    public static class Contrasenas
    {
        public const string Prefijo = "v2$";
        public const int Iteraciones = 600_000;
        public const int LargoMinimo = 8;
        public const int LargoMaximo = 128;

        private const int BytesSal = 16;
        private const int BytesHuella = 32;
        private const int IteracionesMaximas = 10_000_000;
        private static readonly byte[] SalRelleno = RandomNumberGenerator.GetBytes(BytesSal);

        /// <summary>Calcula la huella en el formato nuevo (con sal nueva cada vez).</summary>
        public static string Crear(string contrasena)
        {
            if (contrasena == null) throw new ArgumentNullException(nameof(contrasena));
            byte[] sal = RandomNumberGenerator.GetBytes(BytesSal);
            byte[] huella = Derivar(contrasena, sal, Iteraciones, BytesHuella);
            return string.Join("$", "v2",
                Iteraciones.ToString(CultureInfo.InvariantCulture),
                Convert.ToBase64String(sal),
                Convert.ToBase64String(huella));
        }

        /// <summary>
        /// Compara la contraseña escrita con la guardada en tiempo constante. Siempre hace el mismo
        /// trabajo (una derivación PBKDF2), aunque no haya nada guardado o el formato sea el anterior:
        /// así la respuesta tarda lo mismo exista o no el usuario.
        /// </summary>
        public static ResultadoContrasena Verificar(string? contrasena, string? guardada)
        {
            contrasena ??= string.Empty;
            if (contrasena.Length > 1024)
            {
                Relleno(string.Empty);
                return ResultadoContrasena.Incorrecta;
            }

            if (guardada != null && guardada.StartsWith(Prefijo, StringComparison.Ordinal))
            {
                string[] partes = guardada.Split('$');
                if (partes.Length == 4
                    && int.TryParse(partes[1], NumberStyles.None, CultureInfo.InvariantCulture, out int iteraciones)
                    && iteraciones > 0 && iteraciones <= IteracionesMaximas
                    && DesdeBase64(partes[2]) is { } sal
                    && DesdeBase64(partes[3]) is { } esperada && esperada.Length > 0)
                {
                    byte[] calculada = Derivar(contrasena, sal, iteraciones, esperada.Length);
                    bool correcta = CryptographicOperations.FixedTimeEquals(calculada, esperada);
                    return new ResultadoContrasena(correcta, false, correcta && iteraciones < Iteraciones);
                }
            }
            else if (EsFormatoAnterior(guardada))
            {
                Relleno(contrasena);
                byte[] calculada = SHA256.HashData(Encoding.UTF8.GetBytes(contrasena));
                byte[] esperada = Convert.FromHexString(guardada);
                bool correcta = CryptographicOperations.FixedTimeEquals(calculada, esperada);
                return new ResultadoContrasena(correcta, true, correcta);
            }

            Relleno(contrasena);
            return ResultadoContrasena.Incorrecta;
        }

        /// <summary>Huella del formato anterior (SHA-256 sin sal, hexadecimal en minúsculas).</summary>
        public static string HuellaAnterior(string? contrasena) =>
            Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(contrasena ?? string.Empty))).ToLowerInvariant();

        public static bool EsFormatoAnterior([NotNullWhen(true)] string? guardada)
        {
            if (guardada == null || guardada.Length != 64) return false;
            foreach (char c in guardada)
            {
                if (!Uri.IsHexDigit(c)) return false;
            }
            return true;
        }

        /// <summary>Reglas para una contraseña nueva. Devuelve el mensaje del problema o null si sirve.</summary>
        public static string? Validar(string? nueva, string? usuario)
        {
            if (string.IsNullOrEmpty(nueva) || nueva.Length < LargoMinimo)
                return $"La contraseña debe tener al menos {LargoMinimo} caracteres.";
            if (nueva.Length > LargoMaximo)
                return $"La contraseña no puede tener más de {LargoMaximo} caracteres.";
            if (string.IsNullOrWhiteSpace(nueva) || nueva.Trim().Length != nueva.Length)
                return "La contraseña no puede empezar ni terminar con espacios.";
            if (!string.IsNullOrWhiteSpace(usuario) && string.Equals(nueva, usuario.Trim(), StringComparison.OrdinalIgnoreCase))
                return "La contraseña no puede ser igual al nombre de usuario.";
            return null;
        }

        private static byte[] Derivar(string contrasena, byte[] sal, int iteraciones, int largo) =>
            Rfc2898DeriveBytes.Pbkdf2(Encoding.UTF8.GetBytes(contrasena), sal, iteraciones, HashAlgorithmName.SHA256, largo);

        private static void Relleno(string contrasena) => Derivar(contrasena, SalRelleno, Iteraciones, BytesHuella);

        private static byte[]? DesdeBase64(string texto)
        {
            try { return Convert.FromBase64String(texto); }
            catch (FormatException) { return null; }
        }
    }

    public sealed class ResultadoContrasena
    {
        public static readonly ResultadoContrasena Incorrecta = new ResultadoContrasena(false, false, false);

        public ResultadoContrasena(bool correcta, bool formatoAnterior, bool debeActualizar)
        {
            Correcta = correcta;
            FormatoAnterior = formatoAnterior;
            DebeActualizar = debeActualizar;
        }

        public bool Correcta { get; }

        /// <summary>La guardada era SHA-256 sin sal.</summary>
        public bool FormatoAnterior { get; }

        /// <summary>Hay que volver a guardarla en el formato nuevo (formato anterior o menos iteraciones).</summary>
        public bool DebeActualizar { get; }
    }
}
