using Gestion.Colegial.Business.Services;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Moq;

namespace Gestion.Colegial.Tests
{
    /// <summary>
    /// Reglas de EventosCalendarioService: Validar (las mismas del procedimiento de guardar), Guardar
    /// (feriado/cierre de día completo y errores de validación del procedimiento) y la carga de feriados.
    /// </summary>
    public class EventosCalendarioServiceTests
    {
        private const string MensajeGenerico = "No se pudo guardar el día en el calendario.";
        private const string MensajeFeriadoConPersonas =
            "Un feriado o cierre es para todo el colegio o para secciones: quite los roles y las personas.";

        /// <summary>
        /// Lo que Answer.Incidents guarda de una SqlException: Message = ToString() (empieza con el tipo y
        /// termina con "Error Number:n,State:s,Class:c") y ErrorDetails = el texto del error.
        /// </summary>
        private static Answer ErrorSql(int numero, string texto, string tipo = "System.Data.SqlClient.SqlException") => new Answer
        {
            Access = true,
            Data = "",
            Message = tipo + " (0x80131904): " + texto + "\r\n"
                      + "   at System.Data.SqlClient.SqlCommand.<>c.<ExecuteDbDataReaderAsync>b__126_0(Task`1 result)\r\n"
                      + "   at Gestion.Colegial.DataAccess.Repositories.RepositoryBase.Search[T](String queryString, Object parameters)\r\n"
                      + "ClientConnectionId:3f1c2a4e-1b2c-4d5e-8f90-a1b2c3d4e5f6\r\n"
                      + "Error Number:" + numero + ",State:1,Class:16",
            ErrorDetails = texto
        };

        private static Answer Guardado(int id, bool creado) => new Answer
        {
            Access = false,
            Data = new PR_tbEventosCalendario_GuardarResult { Eve_Id = id, Creado = creado }
        };
        /// <summary>Un día de todo el día, válido, que cada prueba ajusta.</summary>
        private static EventoCalendarioGuardarDTO EventoValido() => new EventoCalendarioGuardarDTO
        {
            Eve_Titulo = "Reunión de padres",
            Eve_Tipo = "reunion_padres",
            Eve_TodoElDia = true,
            Eve_Inicio = new DateTime(2026, 3, 10),
            Eve_Fin = new DateTime(2026, 3, 10)
        };

        [Theory]
        [InlineData(null)]
        [InlineData("")]
        [InlineData("   ")]
        public void Validar_DeberiaRetornarError_CuandoElTituloEstaVacio(string? titulo)
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_Titulo = titulo;

            Assert.Equal("Escriba un título.", EventosCalendarioService.Validar(evento));
        }

        [Fact]
        public void Validar_DeberiaRetornarError_CuandoElTituloPasaDe150Caracteres()
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_Titulo = new string('a', 151);

            Assert.Equal("El título admite hasta 150 caracteres.", EventosCalendarioService.Validar(evento));
        }

        [Fact]
        public void Validar_DeberiaAceptarElTitulo_CuandoTieneJusto150Caracteres()
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_Titulo = new string('a', 150);

            Assert.Null(EventosCalendarioService.Validar(evento));
        }

        [Theory]
        [InlineData("vacaciones")]
        [InlineData("")]
        [InlineData(null)]
        public void Validar_DeberiaRetornarError_CuandoElTipoNoExiste(string? tipo)
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_Tipo = tipo;

            Assert.Equal("Elija el tipo de día.", EventosCalendarioService.Validar(evento));
        }

        [Fact]
        public void Validar_DeberiaRetornarError_CuandoConHoraTerminaAntesDeEmpezar()
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_TodoElDia = false;
            evento.Eve_Inicio = new DateTime(2026, 3, 10, 10, 0, 0);
            evento.Eve_Fin = new DateTime(2026, 3, 10, 9, 0, 0);

            Assert.Equal("Un día del calendario no puede terminar antes de empezar.", EventosCalendarioService.Validar(evento));
        }

        /// <summary>De todo el día cuenta solo la fecha: la hora que llegue no importa.</summary>
        [Theory]
        [InlineData(0, 0)]
        [InlineData(15, 8)]
        public void Validar_DeberiaSerValido_CuandoEsDeTodoElDiaYEmpiezaYTerminaElMismoDia(int horaInicio, int horaFin)
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_TodoElDia = true;
            evento.Eve_Inicio = new DateTime(2026, 3, 10, horaInicio, 0, 0);
            evento.Eve_Fin = new DateTime(2026, 3, 10, horaFin, 0, 0);

            Assert.Null(EventosCalendarioService.Validar(evento));
        }

        [Theory]
        [InlineData(true, "2026-03-10", "2027-03-10")]
        [InlineData(false, "2026-03-10 08:00", "2027-03-10 08:01")]
        public void Validar_DeberiaRetornarError_CuandoDuraMasDeUnAnio(bool todoElDia, string inicio, string fin)
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_TodoElDia = todoElDia;
            evento.Eve_Inicio = DateTime.Parse(inicio, System.Globalization.CultureInfo.InvariantCulture);
            evento.Eve_Fin = DateTime.Parse(fin, System.Globalization.CultureInfo.InvariantCulture);

            Assert.Equal("Un día del calendario no puede durar más de un año. Revise el año.", EventosCalendarioService.Validar(evento));
        }

        [Fact]
        public void Validar_DeberiaSerValido_CuandoTieneHoraYTerminaDespuesDeEmpezar()
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_TodoElDia = false;
            evento.Eve_Inicio = new DateTime(2026, 3, 10, 14, 0, 0);
            evento.Eve_Fin = new DateTime(2026, 3, 10, 16, 30, 0);
            evento.Eve_Lugar = "Salón de actos";

            Assert.Null(EventosCalendarioService.Validar(evento));
        }

        /* ------------------------------------------------------------ Año de las fechas */

        /// <summary>Con año 9999 sumar un día o un año lanza excepción: debe devolver el mensaje antes.</summary>
        [Theory]
        [InlineData(true, "2026-03-10", "9999-12-31")]
        [InlineData(true, "9999-12-31", "9999-12-31")]
        [InlineData(false, "9999-12-31 08:00", "9999-12-31 09:00")]
        [InlineData(true, "1999-12-31", "2026-01-01")]
        [InlineData(true, "2026-03-10", "2101-01-01")]
        public void Validar_DeberiaRetornarRevisarElAnio_CuandoAlgunaFechaTieneAnioFueraDe2000A2100(bool todoElDia, string inicio, string fin)
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_TodoElDia = todoElDia;
            evento.Eve_Inicio = DateTime.Parse(inicio, System.Globalization.CultureInfo.InvariantCulture);
            evento.Eve_Fin = DateTime.Parse(fin, System.Globalization.CultureInfo.InvariantCulture);

            Assert.Equal("Revise el año de las fechas.", EventosCalendarioService.Validar(evento));
        }

        [Theory]
        [InlineData("2000-01-01", "2000-01-01")]
        [InlineData("2100-12-31", "2100-12-31")]
        public void Validar_DeberiaAceptarElAnio_CuandoEstaEnLosLimites(string inicio, string fin)
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_Inicio = DateTime.Parse(inicio, System.Globalization.CultureInfo.InvariantCulture);
            evento.Eve_Fin = DateTime.Parse(fin, System.Globalization.CultureInfo.InvariantCulture);

            Assert.Null(EventosCalendarioService.Validar(evento));
        }

        [Fact]
        public void Validar_DeberiaPedirLasFechas_CuandoNoLlegan()
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_Inicio = default;

            Assert.Equal("Indique cuándo empieza y cuándo termina.", EventosCalendarioService.Validar(evento));
        }

        /* ------------------------------------------------------------ Feriado y cierre */

        [Theory]
        [InlineData("feriado", "roles")]
        [InlineData("feriado", "empleados")]
        [InlineData("feriado", "alumnos")]
        [InlineData("cierre", "roles")]
        [InlineData("cierre", "empleados")]
        [InlineData("cierre", "alumnos")]
        public void Validar_DeberiaRetornarError_CuandoFeriadoOCierreTieneRolesOPersonas(string tipo, string paraQuien)
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_Tipo = tipo;
            if (paraQuien == "roles") evento.Roles = new List<int> { 1005 };
            if (paraQuien == "empleados") evento.Empleados = new List<int> { 1 };
            if (paraQuien == "alumnos") evento.Alumnos = new List<int> { 1 };

            Assert.Equal(MensajeFeriadoConPersonas, EventosCalendarioService.Validar(evento));
        }

        [Theory]
        [InlineData("feriado")]
        [InlineData("cierre")]
        public void Validar_DeberiaAceptarFeriadoOCierre_CuandoEsParaSecciones(string tipo)
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_Tipo = tipo;
            evento.Secciones = new List<int> { 3, 4 };

            Assert.Null(EventosCalendarioService.Validar(evento));
        }

        [Fact]
        public void Validar_DeberiaAceptarRolesYPersonas_CuandoNoEsFeriadoNiCierre()
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Roles = new List<int> { 1005 };
            evento.Empleados = new List<int> { 1 };
            evento.Alumnos = new List<int> { 1 };

            Assert.Null(EventosCalendarioService.Validar(evento));
        }

        [Theory]
        [InlineData("feriado")]
        [InlineData("cierre")]
        public void Normalizar_DeberiaDejarloDeTodoElDia_CuandoEsFeriadoOCierreConHora(string tipo)
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_Tipo = tipo;
            evento.Eve_TodoElDia = false;

            EventosCalendarioService.Normalizar(evento);

            Assert.True(evento.Eve_TodoElDia);
        }

        [Fact]
        public void Normalizar_NoDeberiaCambiarLaHora_CuandoNoEsFeriadoNiCierre()
        {
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_Tipo = "actividad";
            evento.Eve_TodoElDia = false;

            EventosCalendarioService.Normalizar(evento);

            Assert.False(evento.Eve_TodoElDia);
        }

        /* ------------------------------------------------------------ Guardar */

        /// <summary>
        /// Un feriado con hora que "termina antes de empezar" (15:00 → 08:00 del mismo día) es válido porque
        /// primero se vuelve de día completo; y así llega al repositorio.
        /// </summary>
        [Fact]
        public async Task Guardar_DeberiaGuardarloDeTodoElDia_CuandoUnFeriadoLlegaConHora()
        {
            EventoCalendarioGuardarDTO? enviado = null;
            var repositorio = new Mock<IEventosCalendarioRepository>();
            repositorio.Setup(r => r.Guardar(It.IsAny<EventoCalendarioGuardarDTO>()))
                       .Callback<EventoCalendarioGuardarDTO>(e => enviado = e)
                       .ReturnsAsync(Guardado(7, true));
            var servicio = new EventosCalendarioService(repositorio.Object);

            Answer answer = await servicio.Guardar(new EventoCalendarioGuardarDTO
            {
                Eve_Titulo = "Día de la Independencia",
                Eve_Tipo = "feriado",
                Eve_TodoElDia = false,
                Eve_Inicio = new DateTime(2026, 9, 15, 15, 0, 0),
                Eve_Fin = new DateTime(2026, 9, 15, 8, 0, 0)
            });

            Assert.False(answer.Access);
            Assert.NotNull(enviado);
            Assert.True(enviado!.Eve_TodoElDia);
        }

        [Fact]
        public async Task Guardar_DeberiaRetornarRevisarElAnioSinLlamarAlRepositorio_CuandoElAnioEs9999()
        {
            var repositorio = new Mock<IEventosCalendarioRepository>(MockBehavior.Strict);
            var servicio = new EventosCalendarioService(repositorio.Object);
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_Inicio = new DateTime(9999, 12, 31);
            evento.Eve_Fin = new DateTime(9999, 12, 31);

            Answer answer = await servicio.Guardar(evento);

            Assert.True(answer.Access);
            Assert.Equal("Revise el año de las fechas.", answer.Message);
        }

        [Fact]
        public async Task Guardar_DeberiaRetornarError_CuandoUnCierreConHoraTieneRoles()
        {
            var repositorio = new Mock<IEventosCalendarioRepository>(MockBehavior.Strict);
            var servicio = new EventosCalendarioService(repositorio.Object);
            EventoCalendarioGuardarDTO evento = EventoValido();
            evento.Eve_Tipo = "cierre";
            evento.Eve_TodoElDia = false;
            evento.Roles = new List<int> { 1005 };

            Answer answer = await servicio.Guardar(evento);

            Assert.True(answer.Access);
            Assert.Equal(MensajeFeriadoConPersonas, answer.Message);
        }

        /// <summary>Los THROW 50010–50018 del procedimiento son de validación: su texto llega al cliente.</summary>
        [Fact]
        public async Task Guardar_DeberiaRetornarElMensajeDelProcedimiento_CuandoEsUnErrorDeValidacion()
        {
            const string texto = "Las secciones, roles o personas elegidos ya no existen. Elija de nuevo para quién es.";
            var repositorio = new Mock<IEventosCalendarioRepository>();
            repositorio.Setup(r => r.Guardar(It.IsAny<EventoCalendarioGuardarDTO>())).ReturnsAsync(ErrorSql(50018, texto));
            var servicio = new EventosCalendarioService(repositorio.Object);

            Answer answer = await servicio.Guardar(EventoValido());

            Assert.True(answer.Access);
            Assert.Equal(texto, answer.Message);
        }

        [Fact]
        public async Task Guardar_DeberiaRetornarElMensajeGenerico_CuandoElErrorDeSqlNoEsDeValidacion()
        {
            var repositorio = new Mock<IEventosCalendarioRepository>();
            repositorio.Setup(r => r.Guardar(It.IsAny<EventoCalendarioGuardarDTO>()))
                       .ReturnsAsync(ErrorSql(547, "The INSERT statement conflicted with the FOREIGN KEY constraint \"FK_x\"."));
            var servicio = new EventosCalendarioService(repositorio.Object);

            Answer answer = await servicio.Guardar(EventoValido());

            Assert.True(answer.Access);
            Assert.Equal(MensajeGenerico, answer.Message);
        }

        /* ------------------------------------------------------------ Errores de validación del procedimiento */

        [Theory]
        [InlineData(50000)]
        [InlineData(50016)]
        [InlineData(50099)]
        public void MensajeDeValidacionSql_DeberiaRetornarElTexto_CuandoElNumeroEstaEntre50000Y50099(int numero)
        {
            Assert.Equal("Revise el año de las fechas.",
                EventosCalendarioService.MensajeDeValidacionSql(ErrorSql(numero, "Revise el año de las fechas.")));
        }

        [Fact]
        public void MensajeDeValidacionSql_DeberiaAceptarMicrosoftDataSqlClient()
        {
            Answer answer = ErrorSql(50013, "Un día del calendario no puede terminar antes de empezar.", "Microsoft.Data.SqlClient.SqlException");

            Assert.Equal("Un día del calendario no puede terminar antes de empezar.", EventosCalendarioService.MensajeDeValidacionSql(answer));
        }

        [Theory]
        [InlineData(49999)]
        [InlineData(50100)]
        [InlineData(547)]
        [InlineData(2627)]
        public void MensajeDeValidacionSql_DeberiaRetornarNull_CuandoElNumeroNoEsDeValidacion(int numero)
        {
            Assert.Null(EventosCalendarioService.MensajeDeValidacionSql(ErrorSql(numero, "Otro error de SQL.")));
        }

        [Fact]
        public void MensajeDeValidacionSql_DeberiaRetornarNull_CuandoNoEsUnaSqlException()
        {
            var answer = new Answer();
            answer.Incidents(new InvalidOperationException("Error Number:50018,State:1,Class:16"));

            Assert.Null(EventosCalendarioService.MensajeDeValidacionSql(answer));
        }

        /// <summary>Si la SqlException viene envuelta, ErrorDetails es el texto de la de afuera: no se usa.</summary>
        [Fact]
        public void MensajeDeValidacionSql_DeberiaRetornarNull_CuandoLaSqlExceptionVieneEnvuelta()
        {
            Answer sql = ErrorSql(50018, "Texto de SQL.");
            var answer = new Answer
            {
                Message = "System.InvalidOperationException: Algo falló.\r\n ---> " + sql.Message,
                ErrorDetails = "Algo falló."
            };

            Assert.Null(EventosCalendarioService.MensajeDeValidacionSql(answer));
        }

        [Fact]
        public void MensajeDeValidacionSql_DeberiaRetornarNull_CuandoNoHuboExcepcion()
        {
            Assert.Null(EventosCalendarioService.MensajeDeValidacionSql(new Answer { Access = true }));
            Assert.Null(EventosCalendarioService.MensajeDeValidacionSql(null));
        }

        /* ------------------------------------------------------------ Cargar feriados */

        private static CargarFeriadosDTO CargarPrimeros(int anio, int cuantos, out List<FeriadoPropuestoDTO> feriados)
        {
            feriados = CalculoFeriadosHonduras.Del(anio).Take(cuantos).ToList();
            return new CargarFeriadosDTO
            {
                Anio = anio,
                Items = feriados.Select(f => new FeriadoACargarDTO { Clave = f.Clave, Publicar = true }).ToList()
            };
        }

        [Fact]
        public async Task CargarFeriadosHonduras_DeberiaConservarLoCargadoYDecirQueFalto_CuandoUnaCargaFalla()
        {
            var repositorio = new Mock<IEventosCalendarioRepository>();
            repositorio.SetupSequence(r => r.Guardar(It.IsAny<EventoCalendarioGuardarDTO>()))
                       .ReturnsAsync(Guardado(1, true))
                       .ReturnsAsync(Guardado(2, false))
                       .ReturnsAsync(ErrorSql(1205, "Transaction was deadlocked."))
                       .ReturnsAsync(Guardado(4, true));
            var servicio = new EventosCalendarioService(repositorio.Object);
            CargarFeriadosDTO pedido = CargarPrimeros(2026, 4, out List<FeriadoPropuestoDTO> feriados);

            Answer answer = await servicio.CargarFeriadosHonduras(pedido);

            CargarFeriadosResultadoDTO resultado = Assert.IsType<CargarFeriadosResultadoDTO>(answer.Data);
            Assert.Equal(1, resultado.Creados);
            Assert.Equal(1, resultado.YaEstaban);
            Assert.Equal("No se pudo cargar «" + feriados[2].Titulo + "». Se cargaron 2 de 4.", resultado.Mensaje);
            repositorio.Verify(r => r.Guardar(It.IsAny<EventoCalendarioGuardarDTO>()), Times.Exactly(3));
        }

        [Fact]
        public async Task CargarFeriadosHonduras_DeberiaDejarElMensajeNulo_CuandoTodoSaleBien()
        {
            var repositorio = new Mock<IEventosCalendarioRepository>();
            repositorio.SetupSequence(r => r.Guardar(It.IsAny<EventoCalendarioGuardarDTO>()))
                       .ReturnsAsync(Guardado(1, true))
                       .ReturnsAsync(Guardado(2, true))
                       .ReturnsAsync(Guardado(3, false));
            var servicio = new EventosCalendarioService(repositorio.Object);

            Answer answer = await servicio.CargarFeriadosHonduras(CargarPrimeros(2026, 3, out _));

            CargarFeriadosResultadoDTO resultado = Assert.IsType<CargarFeriadosResultadoDTO>(answer.Data);
            Assert.False(answer.Access);
            Assert.Equal(2, resultado.Creados);
            Assert.Equal(1, resultado.YaEstaban);
            Assert.Null(resultado.Mensaje);
        }
    }
}
