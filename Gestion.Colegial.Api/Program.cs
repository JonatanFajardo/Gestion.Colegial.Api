using Gestion.Colegial.Api.Controllers;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Business.Mapping;
using Gestion.Colegial.Business.Services;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.DataAccess.Repositories;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAutoMapper(typeof(DtoMappingProfile).Assembly);

builder.Services.AddScoped<IAlumnoRepository, AlumnoRepository>();
builder.Services.AddScoped<ICargoRepository, CargoRepository>();
builder.Services.AddScoped<ICursoNivelRepository, CursoNivelRepository>();
builder.Services.AddScoped<ICursoRepository, CursoRepository>();
builder.Services.AddScoped<IDiaRepository, DiaRepository>();
builder.Services.AddScoped<IDuracionRepository, DuracionRepository>();
builder.Services.AddScoped<IEmpleadoRepository, EmpleadoRepository>();
builder.Services.AddScoped<IEncargadoRepository, EncargadoRepository>();
builder.Services.AddScoped<IEstadoRepository, EstadoRepository>();
builder.Services.AddScoped<IHomeAndChartsRepository, HomeAndChartsRepository>();
builder.Services.AddScoped<IMateriaRepository, MateriaRepository>();
builder.Services.AddScoped<IModalidadRepository, ModalidadRepository>();
builder.Services.AddScoped<INivelEducativoRepository, NivelEducativoRepository>();
builder.Services.AddScoped<IParcialRepository, ParcialRepository>();
builder.Services.AddScoped<IParentescoRepository, ParentescoRepository>();
builder.Services.AddScoped<ISeccionRepository, SeccionRepository>();
builder.Services.AddScoped<ISemestreRepository, SemestreRepository>();
builder.Services.AddScoped<ITituloRepository, TituloRepository>();

builder.Services.AddTransient<ApiBaseController>();
builder.Services.AddScoped<IAlumnoService, AlumnoService>();
builder.Services.AddScoped<ICargoService, CargoService>();
builder.Services.AddScoped<ICursoNivelService, CursoNivelService>();
builder.Services.AddScoped<ICursoService, CursoService>();
builder.Services.AddScoped<IDiaService, DiaService>();
builder.Services.AddScoped<IDuracionService, DuracionService>();
//builder.Services.AddScoped<IEmpleadoService, EmpleadoService>();
//builder.Services.AddScoped<IEncargadoService, EncargadoService>();
builder.Services.AddScoped<IEstadoService, EstadoService>();
builder.Services.AddScoped<IHomeAndChartsService, HomeAndChartsService>();
builder.Services.AddScoped<IMateriaService, MateriaService>();
builder.Services.AddScoped<IModalidadService, ModalidadService>();
builder.Services.AddScoped<INivelEducativoService, NivelEducativoService>();
builder.Services.AddScoped<IParcialService, ParcialService>();
builder.Services.AddScoped<IParentescoService, ParentescoService>();
builder.Services.AddScoped<ISeccionService, SeccionService>();
builder.Services.AddScoped<ISemestreService, SemestreService>();
builder.Services.AddScoped<ITituloService, TituloService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();