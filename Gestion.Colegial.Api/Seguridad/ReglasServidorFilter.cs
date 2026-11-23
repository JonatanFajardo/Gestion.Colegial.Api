using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.Mvc.Filters;
using System.Collections.Concurrent;
using System.Reflection;

namespace Gestion.Colegial.Api.Seguridad
{
    /// <summary>
    /// Aplica las reglas <see cref="ReglaServidorAttribute"/> del controller y de la acción:
    /// sobrescribe usuario, empleado, rol y banderas de permiso con lo que calcula el servidor.
    /// Solo actúa con GC_API_KEY configurada y en acciones que tienen alguno de esos campos
    /// (o que exigen pantalla). Sin usuario firmado en esas acciones responde 401.
    /// </summary>
    public sealed class ReglasServidorFilter : IAsyncActionFilter
    {
        private static readonly ConcurrentDictionary<(Type, string), PropertyInfo?> Propiedades = new();

        private readonly IUsuarioActual _usuario;
        private readonly ILogger<ReglasServidorFilter> _logger;

        public ReglasServidorFilter(IUsuarioActual usuario, ILogger<ReglasServidorFilter> logger)
        {
            _usuario = usuario;
            _logger = logger;
        }

        public async Task OnActionExecutionAsync(ActionExecutingContext contexto, ActionExecutionDelegate siguiente)
        {
            if (!_usuario.ModoSeguro)
            {
                await siguiente();
                return;
            }

            var reglas = contexto.ActionDescriptor.EndpointMetadata.OfType<ReglaServidorAttribute>().ToList();
            var destinos = reglas.Select(r => (Regla: r, Campos: Buscar(contexto, r.Campos))).ToList();
            bool dependeDelUsuario = reglas.Any(r => r is RequierePantallaAttribute) || destinos.Any(d => d.Campos.Count > 0);
            if (!dependeDelUsuario)
            {
                await siguiente();
                return;
            }

            DatosUsuario? datos = await _usuario.ObtenerAsync();
            if (datos == null)
            {
                _logger.LogWarning("Acción {Accion} rechazada: no trae un usuario firmado activo.", contexto.ActionDescriptor.DisplayName);
                contexto.Result = new ObjectResult(new { Ok = false, Mensaje = "Esta acción necesita el usuario de la sesión." })
                {
                    StatusCode = StatusCodes.Status401Unauthorized
                };
                return;
            }

            foreach (var regla in reglas.OfType<RequierePantallaAttribute>())
            {
                if (!datos.TieneAlguna(regla.Pantallas))
                {
                    _logger.LogWarning("Usuario {UsuId} sin permiso para {Accion}.", datos.UsuId, contexto.ActionDescriptor.DisplayName);
                    contexto.Result = new ObjectResult(new { Ok = false, Mensaje = "No tiene permiso para esta acción." })
                    {
                        StatusCode = StatusCodes.Status403Forbidden
                    };
                    return;
                }
            }

            foreach (var (regla, campos) in destinos)
            {
                foreach (var campo in campos)
                {
                    campo.Escribir(Calcular(regla, datos, campo.Leer()));
                }
            }

            await siguiente();
        }

        private static object? Calcular(ReglaServidorAttribute regla, DatosUsuario datos, object? pedido) => regla switch
        {
            DatoDelServidorAttribute d => d.Dato switch
            {
                DatoUsuario.Usuario => datos.UsuId,
                DatoUsuario.Empleado => datos.EmpId,
                _ => datos.RolId
            },
            PermisoDelServidorAttribute p => pedido is true && datos.TieneAlguna(p.Pantallas),
            AlcanceEmpleadoAttribute a => datos.TieneAlguna(a.Pantallas) ? pedido : (datos.EmpId ?? -1),
            _ => pedido
        };

        /// <summary>Parámetros de la acción y propiedades de los objetos recibidos que se llamen como los campos.</summary>
        private static List<Campo> Buscar(ActionExecutingContext contexto, IReadOnlyList<string> nombres)
        {
            var campos = new List<Campo>();
            if (nombres.Count == 0) return campos;

            foreach (var parametro in contexto.ActionDescriptor.Parameters)
            {
                if (!EsSimple(parametro.ParameterType) || !nombres.Contains(parametro.Name, StringComparer.OrdinalIgnoreCase)) continue;
                var info = (parametro as ControllerParameterDescriptor)?.ParameterInfo;
                string nombre = parametro.Name;
                campos.Add(new Campo(
                    parametro.ParameterType,
                    () => contexto.ActionArguments.TryGetValue(nombre, out var v) ? v : (info?.HasDefaultValue == true ? info.DefaultValue : null),
                    v => contexto.ActionArguments[nombre] = v));
            }

            foreach (var argumento in contexto.ActionArguments.Values.ToList())
            {
                if (argumento == null) continue;
                Type tipo = argumento.GetType();
                if (!tipo.IsClass || tipo == typeof(string)) continue;
                foreach (string nombre in nombres)
                {
                    var propiedad = Propiedades.GetOrAdd((tipo, nombre), clave =>
                    {
                        var p = clave.Item1.GetProperty(clave.Item2, BindingFlags.Public | BindingFlags.Instance | BindingFlags.IgnoreCase);
                        return p != null && p.CanRead && p.CanWrite && EsSimple(p.PropertyType) ? p : null;
                    });
                    if (propiedad == null) continue;
                    campos.Add(new Campo(propiedad.PropertyType, () => propiedad.GetValue(argumento), v => propiedad.SetValue(argumento, v)));
                }
            }

            return campos;
        }

        private static bool EsSimple(Type tipo)
        {
            Type t = Nullable.GetUnderlyingType(tipo) ?? tipo;
            return t == typeof(int) || t == typeof(bool);
        }

        private sealed class Campo
        {
            private readonly Type _tipo;
            private readonly Action<object?> _escribir;

            public Campo(Type tipo, Func<object?> leer, Action<object?> escribir)
            {
                _tipo = tipo;
                Leer = leer;
                _escribir = escribir;
            }

            public Func<object?> Leer { get; }

            /// <summary>
            /// Escribe respetando el tipo del campo. Null, o un valor de otro tipo (un permiso sobre un
            /// campo int), deja el campo vacío (null, 0 o false): nunca se queda lo que mandó el ADM.
            /// </summary>
            public void Escribir(object? valor)
            {
                Type t = Nullable.GetUnderlyingType(_tipo) ?? _tipo;
                if (valor == null || valor.GetType() != t)
                {
                    _escribir(Nullable.GetUnderlyingType(_tipo) != null ? null : Activator.CreateInstance(t));
                    return;
                }
                _escribir(valor);
            }
        }
    }
}
