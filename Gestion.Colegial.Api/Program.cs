using Gestion.Colegial.Api.Controllers;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Business.Interfaces.ModuloFinanzas;
using Gestion.Colegial.Business.Mapping;
using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Business.Services.ModuloFinanzas;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces.Finanzas;
using Gestion.Colegial.DataAccess.Repositories;
using Gestion.Colegial.DataAccess.Repositories.Finanzas;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Serilog;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
builder.Host.UseSerilog((context, configuration) =>
{
    configuration.ReadFrom.Configuration(context.Configuration);
});

// Add services to the container.

// Configure AutoMapper
builder.Services.AddAutoMapper(typeof(DtoMappingProfile));

builder.Services.AddControllers().AddJsonOptions(opts =>
{
    // Preservar nombres de propiedades tal cual están definidos en los entities (PascalCase / snake_case con underscore).
    // Los JS del ADM esperan los nombres EXACTOS de las columnas del SP (ej: Alu_NombreCompleto).
    opts.JsonSerializerOptions.PropertyNamingPolicy = null;
    opts.JsonSerializerOptions.DictionaryKeyPolicy = null;
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
//builder.Services.AddDbContext<DB_OdoremContext>(options => options.UseSqlServer(builder.Configuration.GetConnectionString("ODOREM")));
//var s = builder.Configuration.GetConnectionString("ODOREM");

// Configure JWT Authentication
var jwtKey = builder.Configuration["Jwt:Key"] ?? "GestionColegialSecretKey2025MinLength32Chars!!";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "GestionColegialAPI";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "GestionColegialUI";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtIssuer,
        ValidAudience = jwtAudience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
    };
});

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

// Repositories
builder.Services.AddScoped<IUsuarioRepository, UsuarioRepository>();
builder.Services.AddScoped<IRolesRepository, RolesRepository>();
builder.Services.AddScoped<IAlumnoRepository, AlumnoRepository>();
builder.Services.AddScoped<AulaRepository>();
builder.Services.AddScoped<ICargoRepository, CargoRepository>();
builder.Services.AddScoped<ICursoNivelRepository, CursoNivelRepository>();
builder.Services.AddScoped<ICursoRepository, CursoRepository>();
builder.Services.AddScoped<IDiaRepository, DiaRepository>();
builder.Services.AddScoped<IDuracionRepository, DuracionRepository>();
builder.Services.AddScoped<IEmpleadoRepository, EmpleadoRepository>();
builder.Services.AddScoped<IEncargadoRepository, EncargadoRepository>();
builder.Services.AddScoped<IEstadoRepository, EstadoRepository>();
// builder.Services.AddScoped<IEventoRepository, EventoRepository>(); // tbEventos entity no existe
builder.Services.AddScoped<IHomeAndChartsRepository, HomeAndChartsRepository>();
//builder.Services.AddScoped<IHorarioAlumnoRepository, HorarioAlumnoRepository>();
builder.Services.AddScoped<IHoraRepository, HoraRepository>();
builder.Services.AddScoped<IMateriaRepository, MateriaRepository>();
builder.Services.AddScoped<IModalidadRepository, ModalidadRepository>();
builder.Services.AddScoped<INivelEducativoRepository, NivelEducativoRepository>();
builder.Services.AddScoped<IParcialRepository, ParcialRepository>();
builder.Services.AddScoped<IParentescoRepository, ParentescoRepository>();
builder.Services.AddScoped<ISeccionRepository, SeccionRepository>();
builder.Services.AddScoped<ISemestreRepository, SemestreRepository>();
builder.Services.AddScoped<ITituloRepository, TituloRepository>();

builder.Services.AddScoped<IDashboardAdminRepository, DashboardAdminRepository>();
builder.Services.AddScoped<IDashboardDirectorRepository, DashboardDirectorRepository>();
builder.Services.AddScoped<IDashboardDocenteRepository, DashboardDocenteRepository>();
builder.Services.AddScoped<IDashboardSecretariaRepository, DashboardSecretariaRepository>();
builder.Services.AddScoped<IDashboardRRHHRepository, DashboardRRHHRepository>();
builder.Services.AddScoped<IDashboardCajeroRepository, DashboardCajeroRepository>();
builder.Services.AddScoped<IDashboardFinancieroRepository, DashboardFinancieroRepository>();
builder.Services.AddScoped<IDashboardConsultaRepository, DashboardConsultaRepository>();
builder.Services.AddScoped<IEmpleadosAntiguedadRepository, EmpleadosAntiguedadRepository>();
builder.Services.AddScoped<IAlumnosEnRiesgoRepository, AlumnosEnRiesgoRepository>();
builder.Services.AddScoped<IPromediosAlumnosRepository, PromediosAlumnosRepository>();
builder.Services.AddScoped<IAgingCuentasRepository, AgingCuentasRepository>();
builder.Services.AddScoped<ITopDeudoresRepository, TopDeudoresRepository>();
builder.Services.AddScoped<IMorosidadPorNivelRepository, MorosidadPorNivelRepository>();
builder.Services.AddScoped<IEstadoCuentaRepository, EstadoCuentaRepository>();
builder.Services.AddScoped<IAlumnosBusquedaRepository, AlumnosBusquedaRepository>();
builder.Services.AddScoped<IFicha360AlumnoRepository, Ficha360AlumnoRepository>();
builder.Services.AddScoped<IFicha360EmpleadoRepository, Ficha360EmpleadoRepository>();
builder.Services.AddScoped<IAsistenciaRepository, AsistenciaRepository>();
builder.Services.AddScoped<IDocumentosAlumnoRepository, DocumentosAlumnoRepository>();
builder.Services.AddScoped<IVacacionesRepository, VacacionesRepository>();
builder.Services.AddScoped<IArqueosCajaRepository, ArqueosCajaRepository>();
builder.Services.AddScoped<IBitacoraRepository, BitacoraRepository>();
builder.Services.AddScoped<IHorariosRepository, HorariosRepository>();
builder.Services.AddScoped<INotasRepository, NotasRepository>();
builder.Services.AddScoped<IPlanClasesRepository, PlanClasesRepository>();
builder.Services.AddScoped<ITareasRepository, TareasRepository>();
builder.Services.AddScoped<IEntregasTareaRepository, EntregasTareaRepository>();
builder.Services.AddScoped<IMisAlumnosRepository, MisAlumnosRepository>();
builder.Services.AddScoped<IMapaAulasRepository, MapaAulasRepository>();
// Repositorios Fase 1 (Infraestructura compartida)
builder.Services.AddScoped<INotificacionRepository, NotificacionRepository>();
builder.Services.AddScoped<IBuscadorRepository, BuscadorRepository>();
builder.Services.AddScoped<IPerfilRepository, PerfilRepository>();
// Nuevos módulos operativos
builder.Services.AddScoped<IBoletinRepository, BoletinRepository>();
builder.Services.AddScoped<IAlumnosDirectorioRepository, AlumnosDirectorioRepository>();
builder.Services.AddScoped<IPiramideMatriculaRepository, PiramideMatriculaRepository>();
builder.Services.AddScoped<IEmpleadosCumpleanosRepository, EmpleadosCumpleanosRepository>();
builder.Services.AddScoped<IAsistenciaEmpleadosRepository, AsistenciaEmpleadosRepository>();
builder.Services.AddScoped<IPagosDelDiaRepository, PagosDelDiaRepository>();
builder.Services.AddScoped<IPendientesCobrarRepository, PendientesCobrarRepository>();
builder.Services.AddScoped<IHistorialTransaccionesRepository, HistorialTransaccionesRepository>();
// Repositorios Fase 5 - RRHH
builder.Services.AddScoped<ICumplimientoDocumentosRepository, CumplimientoDocumentosRepository>();
builder.Services.AddScoped<ICentroAnunciosRepository, CentroAnunciosRepository>();
// Repositorios Fase 7 - Reportes
builder.Services.AddScoped<IComparativoAniosRepository, ComparativoAniosRepository>();
builder.Services.AddScoped<IRendimientoPorSeccionRepository, RendimientoPorSeccionRepository>();
builder.Services.AddScoped<IKPIsAcademicosRepository, KPIsAcademicosRepository>();
builder.Services.AddScoped<IKPIsFinancierosRepository, KPIsFinancierosRepository>();
// Repositorios Fase 8 - Seguridad/Admin
builder.Services.AddScoped<ISesionesActivasRepository, SesionesActivasRepository>();
builder.Services.AddScoped<IMatrizRolPantallasRepository, MatrizRolPantallasRepository>();
// Repositorio Mensajes a Encargados
builder.Services.AddScoped<IMensajesRepository, MensajesRepository>();
// Repositorios Fase 9 - Financieros restantes y Organigrama
builder.Services.AddScoped<IFlujoCajaRepository, FlujoCajaRepository>();
builder.Services.AddScoped<IEstadoResultadosRepository, EstadoResultadosRepository>();
builder.Services.AddScoped<IAnalisisIngresosRepository, AnalisisIngresosRepository>();
builder.Services.AddScoped<IOrganigramaRepository, OrganigramaRepository>();
// Repositorios Fase 10 - Configuración del sistema
builder.Services.AddScoped<IConfiguracionRepository, ConfiguracionRepository>();
// Repositorio Graduacion (modulo Academico)
builder.Services.AddScoped<IGraduacionRepository, GraduacionRepository>();
// Repositorio Dev Tools
builder.Services.AddScoped<IDevToolsRepository, DevToolsRepository>();
// Repositorio Matrículas (módulo Matrículas)
builder.Services.AddScoped<IMatriculaRepository, MatriculaRepository>();
// Repositorio Año Lectivo (capa multi-año, hueco #1)
builder.Services.AddScoped<IAnioLectivoRepository, AnioLectivoRepository>();
builder.Services.AddScoped<IEventosCalendarioRepository, EventosCalendarioRepository>();
builder.Services.AddScoped<ICasosDisciplinaRepository, CasosDisciplinaRepository>();
builder.Services.AddScoped<IReporteAsistenciaRepository, ReporteAsistenciaRepository>();
builder.Services.AddScoped<IDocumentosEmitidosRepository, DocumentosEmitidosRepository>();
// Repositorios Año Lectivo — Fases 2-5 (períodos, enfoque, secciones, ofertas)
builder.Services.AddScoped<IPeriodoAnioRepository, PeriodoAnioRepository>();
builder.Services.AddScoped<IEnfoqueAnioRepository, EnfoqueAnioRepository>();
builder.Services.AddScoped<ISeccionAnioRepository, SeccionAnioRepository>();
builder.Services.AddScoped<IOfertaAnioRepository, OfertaAnioRepository>();
// Repositorios Año Lectivo — Fase 6 (rollover + expediente/promociones)
builder.Services.AddScoped<IRolloverRepository, RolloverRepository>();
builder.Services.AddScoped<IMatriculaAnioRepository, MatriculaAnioRepository>();

// Repositorios Financieros
builder.Services.AddScoped<IConceptoPagoRepository, ConceptoPagoRepository>();
builder.Services.AddScoped<ITarifaRepository, TarifaRepository>();
builder.Services.AddScoped<IFormaPagoRepository, FormaPagoRepository>();
builder.Services.AddScoped<IDescuentoRepository, DescuentoRepository>();
builder.Services.AddScoped<IEstadoPagoRepository, EstadoPagoRepository>();
builder.Services.AddScoped<ICuentaCobrarRepository, CuentaCobrarRepository>();
builder.Services.AddScoped<IPagoRepository, PagoRepository>();
//builder.Services.AddScoped<IReporteFinancieroRepository, ReporteFinancieroRepository>();

// Services
builder.Services.AddTransient<ApiBaseController>();
builder.Services.AddScoped<IUsuarioService, UsuarioService>();
builder.Services.AddScoped<IRolesService, RolesService>();
builder.Services.AddScoped<IAlumnoService, AlumnoService>();
builder.Services.AddScoped<IAulaService, AulaService>();
builder.Services.AddScoped<ICargoService, CargoService>();
builder.Services.AddScoped<ICursoNivelService, CursoNivelService>();
builder.Services.AddScoped<ICursoService, CursoService>();
builder.Services.AddScoped<IDiaService, DiaService>();
builder.Services.AddScoped<IDuracionService, DuracionService>();
builder.Services.AddScoped<IEmpleadoService, EmpleadoService>();
builder.Services.AddScoped<IEncargadoService, EncargadoService>();
builder.Services.AddScoped<IEstadoService, EstadoService>();
// builder.Services.AddScoped<IEventoService, EventoService>(); // tbEventos entity no existe
builder.Services.AddScoped<IHomeAndChartsService, HomeAndChartsService>();
//builder.Services.AddScoped<IHorarioAlumnosService, HorarioAlumnosService>();
builder.Services.AddScoped<IHoraService, HoraService>();
builder.Services.AddScoped<IMateriaService, MateriaService>();
builder.Services.AddScoped<IModalidadService, ModalidadService>();
builder.Services.AddScoped<INivelEducativoService, NivelEducativoService>();
builder.Services.AddScoped<IParcialService, ParcialService>();
builder.Services.AddScoped<IParentescoService, ParentescoService>();
builder.Services.AddScoped<ISeccionService, SeccionService>();
builder.Services.AddScoped<ISemestreService, SemestreService>();
builder.Services.AddScoped<ITituloService, TituloService>();

builder.Services.AddScoped<IDashboardAdminService, DashboardAdminService>();
builder.Services.AddScoped<IDashboardDirectorService, DashboardDirectorService>();
builder.Services.AddScoped<IDashboardDocenteService, DashboardDocenteService>();
builder.Services.AddScoped<IDashboardSecretariaService, DashboardSecretariaService>();
builder.Services.AddScoped<IDashboardRRHHService, DashboardRRHHService>();
builder.Services.AddScoped<IDashboardCajeroService, DashboardCajeroService>();
builder.Services.AddScoped<IDashboardFinancieroService, DashboardFinancieroService>();
builder.Services.AddScoped<IDashboardConsultaService, DashboardConsultaService>();
builder.Services.AddScoped<IEmpleadosAntiguedadService, EmpleadosAntiguedadService>();
builder.Services.AddScoped<IAlumnosEnRiesgoService, AlumnosEnRiesgoService>();
builder.Services.AddScoped<IPromediosAlumnosService, PromediosAlumnosService>();
builder.Services.AddScoped<IAgingCuentasService, AgingCuentasService>();
builder.Services.AddScoped<ITopDeudoresService, TopDeudoresService>();
builder.Services.AddScoped<IMorosidadPorNivelService, MorosidadPorNivelService>();
builder.Services.AddScoped<IEstadoCuentaService, EstadoCuentaService>();
builder.Services.AddScoped<IAlumnosBusquedaService, AlumnosBusquedaService>();
builder.Services.AddScoped<IFicha360AlumnoService, Ficha360AlumnoService>();
builder.Services.AddScoped<IFicha360EmpleadoService, Ficha360EmpleadoService>();
builder.Services.AddScoped<IAsistenciaService, AsistenciaService>();
builder.Services.AddScoped<IDocumentosAlumnoService, DocumentosAlumnoService>();
builder.Services.AddScoped<IVacacionesService, VacacionesService>();
builder.Services.AddScoped<IArqueosCajaService, ArqueosCajaService>();
builder.Services.AddScoped<IBitacoraService, BitacoraService>();
builder.Services.AddScoped<IHorariosService, HorariosService>();
builder.Services.AddScoped<INotasService, NotasService>();
builder.Services.AddScoped<IPlanClasesService, PlanClasesService>();
builder.Services.AddScoped<ITareasService, TareasService>();
builder.Services.AddScoped<IEntregasTareaService, EntregasTareaService>();
builder.Services.AddScoped<IMisAlumnosService, MisAlumnosService>();
builder.Services.AddScoped<IMapaAulasService, MapaAulasService>();
// Servicios Fase 1 (Infraestructura compartida)
builder.Services.AddScoped<INotificacionService, NotificacionService>();
builder.Services.AddScoped<IBuscadorService, BuscadorService>();
builder.Services.AddScoped<IPerfilService, PerfilService>();
// Nuevos módulos operativos
builder.Services.AddScoped<IBoletinService, BoletinService>();
builder.Services.AddScoped<IAlumnosDirectorioService, AlumnosDirectorioService>();
builder.Services.AddScoped<IPiramideMatriculaService, PiramideMatriculaService>();
builder.Services.AddScoped<IEmpleadosCumpleanosService, EmpleadosCumpleanosService>();
builder.Services.AddScoped<IAsistenciaEmpleadosService, AsistenciaEmpleadosService>();
builder.Services.AddScoped<IPagosDelDiaService, PagosDelDiaService>();
builder.Services.AddScoped<IPendientesCobrarService, PendientesCobrarService>();
builder.Services.AddScoped<IHistorialTransaccionesService, HistorialTransaccionesService>();
// Servicios Fase 5 - RRHH
builder.Services.AddScoped<ICumplimientoDocumentosService, CumplimientoDocumentosService>();
builder.Services.AddScoped<ICentroAnunciosService, CentroAnunciosService>();
// Servicios Fase 7 - Reportes
builder.Services.AddScoped<IComparativoAniosService, ComparativoAniosService>();
builder.Services.AddScoped<IRendimientoPorSeccionService, RendimientoPorSeccionService>();
builder.Services.AddScoped<IKPIsAcademicosService, KPIsAcademicosService>();
builder.Services.AddScoped<IKPIsFinancierosService, KPIsFinancierosService>();
// Servicios Fase 8 - Seguridad/Admin
builder.Services.AddScoped<ISesionesActivasService, SesionesActivasService>();
builder.Services.AddScoped<IMatrizRolPantallasService, MatrizRolPantallasService>();
// Servicio Mensajes a Encargados
builder.Services.AddScoped<IMensajesService, MensajesService>();
// Servicios Fase 9 - Financieros restantes y Organigrama
builder.Services.AddScoped<IFlujoCajaService, FlujoCajaService>();
builder.Services.AddScoped<IEstadoResultadosService, EstadoResultadosService>();
builder.Services.AddScoped<IAnalisisIngresosService, AnalisisIngresosService>();
builder.Services.AddScoped<IOrganigramaService, OrganigramaService>();
// Servicios Fase 10 - Configuración del sistema
builder.Services.AddScoped<IConfiguracionService, ConfiguracionService>();
// Servicio Graduacion (modulo Academico)
builder.Services.AddScoped<IGraduacionService, GraduacionService>();
// Servicio Dev Tools
builder.Services.AddScoped<IDevToolsService, DevToolsService>();
// Servicio Matrículas (módulo Matrículas)
builder.Services.AddScoped<IMatriculaService, MatriculaService>();
// Servicio Año Lectivo (capa multi-año, hueco #1)
builder.Services.AddScoped<IAnioLectivoService, AnioLectivoService>();
builder.Services.AddScoped<IEventosCalendarioService, EventosCalendarioService>();
builder.Services.AddScoped<ICasosDisciplinaService, CasosDisciplinaService>();
builder.Services.AddScoped<IReporteAsistenciaService, ReporteAsistenciaService>();
builder.Services.AddScoped<IDocumentosEmitidosService, DocumentosEmitidosService>();
// Servicios Año Lectivo — Fases 2-5 (períodos, enfoque, secciones, ofertas)
builder.Services.AddScoped<IPeriodoAnioService, PeriodoAnioService>();
builder.Services.AddScoped<IEnfoqueAnioService, EnfoqueAnioService>();
builder.Services.AddScoped<ISeccionAnioService, SeccionAnioService>();
builder.Services.AddScoped<IOfertaAnioService, OfertaAnioService>();
// Servicios Año Lectivo — Fase 6 (rollover + expediente/promociones)
builder.Services.AddScoped<IRolloverService, RolloverService>();
builder.Services.AddScoped<IMatriculaAnioService, MatriculaAnioService>();

// Servicios Financieros
builder.Services.AddScoped<IConceptoPagoService, ConceptoPagoService>();
builder.Services.AddScoped<ITarifaService, TarifaService>();
builder.Services.AddScoped<IFormaPagoService, FormaPagoService>();
builder.Services.AddScoped<IDescuentoService, DescuentoService>();
builder.Services.AddScoped<IEstadoPagoService, EstadoPagoService>();
builder.Services.AddScoped<ICuentaCobrarService, CuentaCobrarService>();
builder.Services.AddScoped<IPagoService, PagoService>();
//builder.Services.AddScoped<IReporteFinancieroService, ReporteFinancieroService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
