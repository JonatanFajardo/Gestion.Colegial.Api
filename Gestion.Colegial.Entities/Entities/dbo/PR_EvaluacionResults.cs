#nullable disable
namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Respuesta en un solo JSON (cuaderno de evaluación, script 089).</summary>
    public class PR_Evaluacion_JsonResult
    {
        public string Json { get; set; }
    }

    /// <summary>Respuesta de las escrituras (actividades, puntos y plantillas).</summary>
    public class PR_Evaluacion_EscrituraResult
    {
        public int Id { get; set; }
        public int? Cev_Id { get; set; }
        public int? Version { get; set; }
        public int Cantidad { get; set; }
        public int Omitidas { get; set; }
        public int? Sincronizados { get; set; }
        public int? Conservados { get; set; }
    }

    /// <summary>Nota del parcial que hay que escribir en app.tbNotas con app.PR_tbNotas_Insert.</summary>
    public class PR_Evaluacion_NotaPendienteResult
    {
        public int Cev_Id { get; set; }
        public int Hor_Id { get; set; }
        public int Pac_Id { get; set; }
        public int Alu_Id { get; set; }
        public int Nota { get; set; }
        public int? NotaActual { get; set; }
    }

    public class PR_Evaluacion_UsaActividadesResult
    {
        public bool UsaActividades { get; set; }
    }

    /// <summary>Una plantilla de evaluación con sus tipos (TiposJson) y su uso.</summary>
    public class PR_Evaluacion_PlantillaResult
    {
        public int Ple_Id { get; set; }
        public int Anio { get; set; }
        public int? Niv_Id { get; set; }
        public string Nivel { get; set; }
        public int? Mat_Id { get; set; }
        public string Materia { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public int Version { get; set; }
        public string Alcance { get; set; }
        public bool PorDefecto { get; set; }
        public int Cuadernos { get; set; }
        public int? CuadernosCerrados { get; set; }
        public int? Actividades { get; set; }
        public string TiposJson { get; set; }
        public string ModificadoPor { get; set; }
        public DateTime? Modificado { get; set; }
    }

    public class PR_Evaluacion_OpcionResult
    {
        public int Id { get; set; }
        public string Texto { get; set; }
        public bool EsActual { get; set; }
    }

    /// <summary>Uso de las actividades en un grupo (materia x sección) para un parcial.</summary>
    public class PR_Evaluacion_AvanceResult
    {
        public int Hor_Id { get; set; }
        public int Pac_Id { get; set; }
        public string Docente { get; set; }
        public string Nivel { get; set; }
        public string Grado { get; set; }
        public int GradoOrden { get; set; }
        public string Seccion { get; set; }
        public string Curso { get; set; }
        public string Materia { get; set; }
        public int? Cev_Id { get; set; }
        public string Plantilla { get; set; }
        public int Alumnos { get; set; }
        public int Actividades { get; set; }
        public int ActividadesQueCuentan { get; set; }
        public int Capturadas { get; set; }
        public int Esperadas { get; set; }
        public decimal? Porcentaje { get; set; }
        public int ConCalculo { get; set; }
        public int NotasAlDia { get; set; }
        public DateTime? UltimoCambio { get; set; }
        public string Estado { get; set; }
    }
}
