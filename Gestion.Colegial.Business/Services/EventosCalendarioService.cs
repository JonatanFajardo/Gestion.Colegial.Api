using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Text.RegularExpressions;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Calendario escolar (espejo de Skuul). Un Feriado o Cierre publicado cierra el colegio
    /// (sin pase de lista ese día para la sección); un borrador no cierra nada.
    /// </summary>
    public class EventosCalendarioService : IEventosCalendarioService
    {
        public static readonly string[] Tipos =
            { "feriado", "cierre", "dia_especial", "acto_civico", "actividad", "reunion_padres", "cita", "examen", "otro" };

        private readonly IEventosCalendarioRepository _repository;

        public EventosCalendarioService(IEventosCalendarioRepository repository)
        {
            _repository = repository;
        }

        /// <summary>Marca el error para el log sin perder Data (las lecturas devuelven "" al fallar).</summary>
        private static Answer Revisar(Answer answer)
        {
            if (answer.Access)
            {
                answer.Message = MessageShow.Error;
                Logs.Error(answer);
            }
            return answer;
        }

        public async Task<Answer> ListRango(DateTime desde, DateTime hasta, bool incluirBorradores, bool verTodo, int? empId, int? rolId) =>
            Revisar(await _repository.ListRango(desde, hasta, incluirBorradores, verTodo, empId, rolId));

        public async Task<Answer> Find(int id, bool verTodo, int? empId, int? rolId)
        {
            Answer answer = await _repository.Find(id, verTodo, empId, rolId);
            // Sin fila (Data null) = no existe o no es para esa persona: no es un error.
            return answer.Access && answer.Data == null ? answer : Revisar(answer);
        }

        public async Task<Answer> Audiencia(int id) => Revisar(await _repository.Audiencia(id));

        public async Task<Answer> Borradores() => Revisar(await _repository.Borradores());

        public async Task<Answer> CierreEnFecha(DateTime fecha, int? seaId, int? horId) =>
            Revisar(await _repository.CierreEnFecha(fecha, seaId, horId));

        public async Task<Answer> Proximos(DateTime? hoy, int dias, bool verTodo, int? empId, int? rolId, int limite) =>
            Revisar(await _repository.Proximos(hoy, Math.Clamp(dias, 1, 60), verTodo, empId, rolId, Math.Clamp(limite, 1, 20)));

        public async Task<Answer> ParaAlumno(int aluId, DateTime desde, DateTime hasta) =>
            Revisar(await _repository.ParaAlumno(aluId, desde, hasta));

        public async Task<Answer> SeccionesAudiencia(DateTime? fecha, int? eveId) =>
            Revisar(await _repository.SeccionesAudiencia(fecha, eveId));

        public async Task<Answer> RolesAudiencia() => Revisar(await _repository.RolesAudiencia());

        public async Task<Answer> BuscarPersonas(string texto, int limite) =>
            Revisar(await _repository.BuscarPersonas(texto ?? "", Math.Clamp(limite, 1, 20)));

        /// <summary>Feriado y cierre cierran el colegio: son de día completo y solo para todo el colegio o para secciones.</summary>
        public static bool CierraElColegio(string? tipo) => tipo == "feriado" || tipo == "cierre";

        private static bool Hay(List<int>? ids) => ids != null && ids.Count > 0;

        private static bool AnioValido(DateTime fecha) => fecha.Year >= 2000 && fecha.Year <= 2100;

        /// <summary>Ajusta los datos como el procedimiento antes de validar: un feriado o cierre es de todo el día.</summary>
        public static void Normalizar(EventoCalendarioGuardarDTO? obj)
        {
            if (obj != null && CierraElColegio(obj.Eve_Tipo)) obj.Eve_TodoElDia = true;
        }

        /// <summary>Valida igual que el procedimiento para devolver un mensaje claro.</summary>
        public static string? Validar(EventoCalendarioGuardarDTO obj)
        {
            if (obj == null) return "No llegaron datos.";
            if (string.IsNullOrWhiteSpace(obj.Eve_Titulo)) return "Escriba un título.";
            if (obj.Eve_Titulo.Trim().Length > 150) return "El título admite hasta 150 caracteres.";
            if (string.IsNullOrWhiteSpace(obj.Eve_Tipo) || !Tipos.Contains(obj.Eve_Tipo)) return "Elija el tipo de día.";
            if (CierraElColegio(obj.Eve_Tipo) && (Hay(obj.Roles) || Hay(obj.Empleados) || Hay(obj.Alumnos)))
                return "Un feriado o cierre es para todo el colegio o para secciones: quite los roles y las personas.";
            if ((obj.Eve_Lugar ?? "").Trim().Length > 150) return "El lugar admite hasta 150 caracteres.";
            if ((obj.Eve_Descripcion ?? "").Trim().Length > 2000) return "La descripción admite hasta 2000 caracteres.";
            if (obj.Eve_Inicio == default || obj.Eve_Fin == default) return "Indique cuándo empieza y cuándo termina.";
            // Antes de sumar días o años: con un año como 9999 la suma se sale del calendario y lanza excepción.
            if (!AnioValido(obj.Eve_Inicio) || !AnioValido(obj.Eve_Fin)) return "Revise el año de las fechas.";

            DateTime inicio = obj.Eve_TodoElDia ? obj.Eve_Inicio.Date : obj.Eve_Inicio;
            DateTime fin = obj.Eve_TodoElDia ? obj.Eve_Fin.Date.AddDays(1).AddSeconds(-1) : obj.Eve_Fin;
            if (fin < inicio) return "Un día del calendario no puede terminar antes de empezar.";
            if (inicio.AddYears(1) < fin) return "Un día del calendario no puede durar más de un año. Revise el año.";
            return null;
        }

        /// <summary>"Error Number:50018,State:1,Class:16" al final del ToString de una SqlException.</summary>
        private static readonly Regex ErrorSql = new Regex(
            @"^(?:System|Microsoft)\.Data\.SqlClient\.SqlException\b.*Error Number:(\d+),State:",
            RegexOptions.Singleline | RegexOptions.CultureInvariant);

        /// <summary>
        /// Texto de un error de validación del procedimiento (THROW 50000–50099), o null si fue otro error.
        /// Answer.Incidents guarda exception.ToString() en Message (empieza con el tipo de la excepción y,
        /// si es una SqlException, termina con "Error Number:n,State:s,Class:c") y exception.Message en ErrorDetails.
        /// </summary>
        public static string? MensajeDeValidacionSql(Answer? answer)
        {
            if (answer == null || string.IsNullOrWhiteSpace(answer.Message) || string.IsNullOrWhiteSpace(answer.ErrorDetails))
                return null;

            Match error = ErrorSql.Match(answer.Message);
            if (!error.Success || !int.TryParse(error.Groups[1].Value, out int numero) || numero < 50000 || numero > 50099)
                return null;

            // Con varios errores, SqlException une sus textos en líneas; el número es el del primero.
            return answer.ErrorDetails.Split('\n')[0].Trim();
        }

        public async Task<Answer> Guardar(EventoCalendarioGuardarDTO obj)
        {
            Normalizar(obj);
            string? problema = Validar(obj);
            if (problema != null)
                return new Answer { Access = true, Message = problema, Data = "" };

            Answer answer = await _repository.Guardar(obj);
            if (answer.Access)
            {
                // Un error de validación del procedimiento llega tal cual; cualquier otro se registra y se generaliza.
                string? validacion = MensajeDeValidacionSql(answer);
                if (validacion == null) Logs.Error(answer);
                answer.Message = validacion ?? "No se pudo guardar el día en el calendario.";
            }
            return answer;
        }

        public async Task<Answer> Publicar(int id, bool publicar, int? usuario) =>
            Revisar(await _repository.Publicar(id, publicar, usuario));

        public async Task<Answer> Eliminar(int id, int? usuario) =>
            Revisar(await _repository.Eliminar(id, usuario));

        public async Task<Answer> FeriadosHonduras(int anio)
        {
            var answer = new Answer();
            if (anio < 2000 || anio > 2100)
            {
                answer.Access = true;
                answer.Message = "Año fuera de rango.";
                answer.Data = "";
                return answer;
            }

            List<FeriadoPropuestoDTO> lista = CalculoFeriadosHonduras.Del(anio);
            Answer cargados = await _repository.ClavesOrigen(CalculoFeriadosHonduras.Prefijo(anio));
            if (!cargados.Access && cargados.Data is List<PR_tbEventosCalendario_ClavesOrigenResult> ya)
            {
                foreach (FeriadoPropuestoDTO f in lista)
                {
                    PR_tbEventosCalendario_ClavesOrigenResult? c = ya.FirstOrDefault(x => x.Eve_ClaveOrigen == f.Clave);
                    if (c == null) continue;
                    f.YaCargado = true;
                    f.Eve_Id = c.Eve_Id;
                    f.Publicado = c.Eve_EsPublicado;
                }
            }

            answer.Data = lista;
            return answer;
        }

        /// <summary>
        /// Carga los feriados elegidos de uno en uno. Si uno falla, se detiene: el resultado conserva lo que
        /// sí se cargó y Mensaje dice cuál falló ("Se cargaron n de total", n = creados + los que ya estaban).
        /// </summary>
        public async Task<Answer> CargarFeriadosHonduras(CargarFeriadosDTO obj)
        {
            var answer = new Answer { Access = false };
            var resultado = new CargarFeriadosResultadoDTO();
            Dictionary<string, FeriadoPropuestoDTO> propuestos =
                CalculoFeriadosHonduras.Del(obj != null && obj.Anio > 1999 ? obj.Anio : DateTime.Today.Year).ToDictionary(f => f.Clave!);

            // Solo las claves que existen en la propuesta del año; el resto se ignora.
            List<(FeriadoACargarDTO Item, FeriadoPropuestoDTO Feriado)> aCargar = (obj?.Items ?? new List<FeriadoACargarDTO>())
                .Where(i => i?.Clave != null && propuestos.ContainsKey(i.Clave))
                .Select(i => (i, propuestos[i.Clave!]))
                .ToList();

            foreach ((FeriadoACargarDTO item, FeriadoPropuestoDTO f) in aCargar)
            {
                Answer r = await _repository.Guardar(new EventoCalendarioGuardarDTO
                {
                    Eve_Titulo = f.Titulo,
                    Eve_Descripcion = f.Descripcion,
                    Eve_Tipo = f.Tipo,
                    Eve_TodoElDia = true,
                    Eve_Inicio = f.Inicio,
                    Eve_Fin = f.Fin,
                    Eve_ClaveOrigen = f.Clave,
                    Publicar = item.Publicar,
                    Usuario = obj!.Usuario
                });

                if (r.Access)
                {
                    Logs.Error(r);
                    resultado.Mensaje = "No se pudo cargar «" + f.Titulo + "». Se cargaron "
                                        + (resultado.Creados + resultado.YaEstaban) + " de " + aCargar.Count + ".";
                    answer.Access = true;
                    answer.Message = resultado.Mensaje;
                    break;
                }

                if (r.Data is PR_tbEventosCalendario_GuardarResult g && g.Creado) resultado.Creados++;
                else resultado.YaEstaban++;
            }

            answer.Data = resultado;
            return answer;
        }
    }
}
