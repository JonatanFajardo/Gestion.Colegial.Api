using Gestion.Colegial.Api.Controllers;
using Gestion.Colegial.Business.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
//builder.Services.AddDbContext<DB_OdoremContext>(options => options.UseSqlServer(builder.Configuration.GetConnectionString("ODOREM")));
//var s = builder.Configuration.GetConnectionString("ODOREM");

builder.Services.AddTransient<ApiBaseController>();
builder.Services.AddTransient<AlumnoService>();
builder.Services.AddTransient<DuracionService>();
builder.Services.AddTransient<EmpleadoService>();
builder.Services.AddTransient<EncargadoService>();
builder.Services.AddTransient<EstadoService>();
builder.Services.AddTransient<EventoService>();
builder.Services.AddTransient<HoraService>();
builder.Services.AddTransient<MateriaService>();
builder.Services.AddTransient<ModalidadService>();
builder.Services.AddTransient<NivelEducativoService>();
builder.Services.AddTransient<ParcialService>();
builder.Services.AddTransient<ParentescoService>();
builder.Services.AddTransient<SeccionService>();
builder.Services.AddTransient<SemestreService>();
builder.Services.AddTransient<TituloService>();
builder.Services.AddTransient<AlumnoService>();
builder.Services.AddTransient<CargoService>();
builder.Services.AddTransient<CursoNivelService>();
builder.Services.AddTransient<CursoService>();
builder.Services.AddTransient<DiaService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
