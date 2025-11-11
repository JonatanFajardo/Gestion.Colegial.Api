using Gestion.Colegial.Api.Controllers;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Business.Services;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.DataAccess.Repositories;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
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
builder.Services.AddScoped<IAlumnoRepository, AlumnoRepository>();
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
//builder.Services.AddScoped<IHoraRepository, HoraRepository>();
builder.Services.AddScoped<IMateriaRepository, MateriaRepository>();
builder.Services.AddScoped<IModalidadRepository, ModalidadRepository>();
builder.Services.AddScoped<INivelEducativoRepository, NivelEducativoRepository>();
builder.Services.AddScoped<IParcialRepository, ParcialRepository>();
builder.Services.AddScoped<IParentescoRepository, ParentescoRepository>();
builder.Services.AddScoped<ISeccionRepository, SeccionRepository>();
builder.Services.AddScoped<ISemestreRepository, SemestreRepository>();
builder.Services.AddScoped<ITituloRepository, TituloRepository>();

// Services
builder.Services.AddTransient<ApiBaseController>();
builder.Services.AddScoped<IUsuarioService, UsuarioService>();
builder.Services.AddScoped<IAlumnoService, AlumnoService>();
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
//builder.Services.AddScoped<IHoraService, HoraService>();
builder.Services.AddScoped<IMateriaService, MateriaService>();
builder.Services.AddScoped<IModalidadService, ModalidadService>();
builder.Services.AddScoped<INivelEducativoService, NivelEducativoService>();
builder.Services.AddScoped<IParcialService, ParcialService>();
builder.Services.AddScoped<IParentescoService, ParentescoService>();
builder.Services.AddScoped<ISeccionService, SeccionService>();
builder.Services.AddScoped<ISemestreService, SemestreService>();
builder.Services.AddScoped<ITituloService, TituloService>();

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
