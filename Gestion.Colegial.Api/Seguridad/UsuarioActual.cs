using Gestion.Colegial.DataAccess;
using Microsoft.Extensions.Caching.Memory;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.Api.Seguridad
{
    /// <summary>Usuario de la petición en curso, según el encabezado firmado por el ADM.</summary>
    public interface IUsuarioActual
    {
        /// <summary>True cuando GC_API_KEY está configurada (la API ya no cree lo que mande el ADM).</summary>
        bool ModoSeguro { get; }

        /// <summary>Usu_Id firmado que trajo la petición; null si no vino.</summary>
        int? UsuId { get; }

        /// <summary>Rol, empleado, si es admin y pantallas del usuario firmado; null si no vino o no está activo.</summary>
        Task<DatosUsuario?> ObtenerAsync();
    }

    /// <summary>Lo que el servidor sabe del usuario (leído de la base, no del ADM).</summary>
    public sealed class DatosUsuario
    {
        public DatosUsuario(int usuId, int? empId, int? rolId, bool esAdmin, IEnumerable<string> pantallas)
        {
            UsuId = usuId;
            EmpId = empId;
            RolId = rolId;
            EsAdmin = esAdmin;
            Pantallas = new HashSet<string>(pantallas, StringComparer.OrdinalIgnoreCase);
        }

        public int UsuId { get; }
        public int? EmpId { get; }
        public int? RolId { get; }
        public bool EsAdmin { get; }
        public IReadOnlySet<string> Pantallas { get; }

        /// <summary>El admin pasa todo; el resto necesita al menos una de las pantallas.</summary>
        public bool TieneAlguna(IEnumerable<string> pantallas) => EsAdmin || pantallas.Any(Pantallas.Contains);
    }

    public sealed class UsuarioActual : IUsuarioActual
    {
        private static readonly TimeSpan Cache = TimeSpan.FromSeconds(60);

        private const string Consulta = @"
SELECT u.Usu_Id, u.Emp_Id, u.Rol_Id, r.Rol_Descripcion
FROM seguridad.tbUsuarios u
LEFT JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
WHERE u.Usu_Id = @Usu_Id AND u.Usu_EsActivo = 1
  AND ISNULL(u.Usu_Suspendido, 0) = 0 AND ISNULL(u.Usu_EsEliminado, 0) = 0;

SELECT p.Pan_Descripcion
FROM seguridad.tbUsuarios u
JOIN seguridad.tbRolesPantallas rp ON rp.Rol_Id = u.Rol_Id
JOIN seguridad.tbPantallas p ON p.Pan_Id = rp.Pan_Id
WHERE u.Usu_Id = @Usu_Id AND p.Pan_Estado = 1 AND p.Pan_EsEliminado = 0;";

        private readonly OpcionesSeguridad _opciones;
        private readonly IHttpContextAccessor _contexto;
        private readonly IMemoryCache _cache;
        private Task<DatosUsuario?>? _carga;

        public UsuarioActual(OpcionesSeguridad opciones, IHttpContextAccessor contexto, IMemoryCache cache)
        {
            _opciones = opciones;
            _contexto = contexto;
            _cache = cache;
        }

        public bool ModoSeguro => _opciones.Activa;

        public int? UsuId =>
            _opciones.Activa && _contexto.HttpContext?.Items[LlaveApiMiddleware.ClaveUsuario] is int id ? id : null;

        public Task<DatosUsuario?> ObtenerAsync()
        {
            int? usuId = UsuId;
            if (usuId == null) return Task.FromResult<DatosUsuario?>(null);
            return _carga ??= _cache.GetOrCreateAsync("gc.usuario." + usuId.Value, entrada =>
            {
                entrada.AbsoluteExpirationRelativeToNow = Cache;
                return Leer(usuId.Value);
            });
        }

        private static async Task<DatosUsuario?> Leer(int usuId)
        {
            using var conexion = new SqlConnection(Connection.GetConnectionString());
            using var comando = new SqlCommand(Consulta, conexion);
            comando.Parameters.Add(new SqlParameter("@Usu_Id", SqlDbType.Int) { Value = usuId });
            await conexion.OpenAsync();
            using var lector = await comando.ExecuteReaderAsync();

            if (!await lector.ReadAsync()) return null;
            int? empId = lector.IsDBNull(1) ? null : lector.GetInt32(1);
            int? rolId = lector.IsDBNull(2) ? null : lector.GetInt32(2);
            string rol = lector.IsDBNull(3) ? "" : lector.GetString(3);

            var pantallas = new List<string>();
            if (await lector.NextResultAsync())
            {
                while (await lector.ReadAsync())
                {
                    if (!lector.IsDBNull(0)) pantallas.Add(lector.GetString(0).Trim());
                }
            }

            // Mismo criterio que el ADM (SessionManager.EsAdmin): el rol llamado "admin" pasa todo.
            bool esAdmin = rol.Trim().Equals("admin", StringComparison.OrdinalIgnoreCase);
            return new DatosUsuario(usuId, empId, rolId, esAdmin, pantallas);
        }
    }
}
