using System.Globalization;
using System.Security.Cryptography;
using System.Text;

namespace Gestion.Colegial.Api.Seguridad
{
    /// <summary>
    /// Llave compartida con el ADM (variable de entorno GC_API_KEY).
    /// - Con llave: toda llamada trae X-Api-Key y, si hay sesión, X-Gc-Usuario firmado.
    /// - Sin llave: la API funciona como siempre (no pide encabezados ni valida usuarios).
    /// </summary>
    public sealed class OpcionesSeguridad
    {
        public const string VariableLlave = "GC_API_KEY";
        public const string EncabezadoLlave = "X-Api-Key";
        public const string EncabezadoUsuario = "X-Gc-Usuario";

        /// <summary>Tiempo que vale la firma del usuario (hacia atrás y hacia adelante).</summary>
        public static readonly TimeSpan Vigencia = TimeSpan.FromMinutes(5);

        private readonly byte[]? _llave;
        private readonly byte[]? _huellaLlave;

        public OpcionesSeguridad(string? llave)
        {
            if (string.IsNullOrWhiteSpace(llave)) return;
            _llave = Encoding.UTF8.GetBytes(llave.Trim());
            _huellaLlave = SHA256.HashData(_llave);
        }

        /// <summary>True cuando GC_API_KEY está configurada.</summary>
        public bool Activa => _llave != null;

        /// <summary>Compara la llave recibida sin revelar por tiempo cuánto acertó.</summary>
        public bool LlaveValida(string? recibida)
        {
            if (_huellaLlave == null || string.IsNullOrEmpty(recibida)) return false;
            byte[] huella = SHA256.HashData(Encoding.UTF8.GetBytes(recibida.Trim()));
            return CryptographicOperations.FixedTimeEquals(huella, _huellaLlave);
        }

        /// <summary>
        /// Lee "Usu_Id|segundos|firma" (firma = HMAC-SHA256 de "Usu_Id|segundos" con la llave, en hexadecimal).
        /// Devuelve el Usu_Id si la firma cuadra y no venció; null en cualquier otro caso.
        /// </summary>
        public int? LeerUsuario(string? valor, DateTimeOffset ahora)
        {
            if (_llave == null || string.IsNullOrWhiteSpace(valor)) return null;

            string[] partes = valor.Trim().Split('|');
            if (partes.Length != 3) return null;
            if (!int.TryParse(partes[0], NumberStyles.None, CultureInfo.InvariantCulture, out int usuId) || usuId <= 0) return null;
            if (!long.TryParse(partes[1], NumberStyles.None, CultureInfo.InvariantCulture, out long segundos)) return null;

            long diferencia = Math.Abs(ahora.ToUnixTimeSeconds() - segundos);
            if (diferencia > (long)Vigencia.TotalSeconds) return null;

            byte[] esperada = Encoding.ASCII.GetBytes(Firmar(partes[0] + "|" + partes[1]));
            byte[] recibida = Encoding.ASCII.GetBytes(partes[2].ToLowerInvariant());
            return CryptographicOperations.FixedTimeEquals(esperada, recibida) ? usuId : null;
        }

        private string Firmar(string datos) =>
            Convert.ToHexString(HMACSHA256.HashData(_llave!, Encoding.UTF8.GetBytes(datos))).ToLowerInvariant();
    }
}
