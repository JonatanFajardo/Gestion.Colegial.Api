#nullable disable
namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Un temario de la biblioteca o su ficha (script 074). Solo los que la persona puede leer.</summary>
    public class PR_tbTemarios_ListResult
    {
        public int Tem_Id { get; set; }
        public int Mat_Id { get; set; }
        public string Materia { get; set; }
        public int? Niv_Id { get; set; }
        public string Nivel { get; set; }
        public int Cun_Id { get; set; }
        public string Grado { get; set; }
        public int Cun_Orden { get; set; }
        public int? Cur_Id { get; set; }
        public string Curso { get; set; }
        public int Sem_Id { get; set; }
        public string Semestre { get; set; }
        public int Tem_Anio { get; set; }
        public string Tem_Nombre { get; set; }
        public string Tem_Descripcion { get; set; }
        public DateTime Tem_FechaInicio { get; set; }
        public int? SemanaActual { get; set; }
        public int Temas { get; set; }
        public int Semanas { get; set; }
        public int Secciones { get; set; }
        public int AvancePct { get; set; }
        public int SeccionesAtrasadas { get; set; }
        public bool EsMio { get; set; }
        public bool PuedeEditar { get; set; }
        public bool PuedeSupervisar { get; set; }
        public int? Tem_IdOrigen { get; set; }
        public string Origen { get; set; }
        public int? OrigenAnio { get; set; }
        public string Registra { get; set; }
        public DateTime Tem_FechaRegistra { get; set; }
        public DateTime? Tem_FechaModifica { get; set; }
    }

    /// <summary>Un tema del temario, con cuántas secciones ya lo dieron.</summary>
    public class PR_tbTemarioTemas_ListResult
    {
        public int Tet_Id { get; set; }
        public int Tem_Id { get; set; }
        public int Tet_Semana { get; set; }
        public int Tet_Orden { get; set; }
        public string Tet_Titulo { get; set; }
        public string Tet_Objetivos { get; set; }
        public string Tet_Contenido { get; set; }
        public string Tet_Recursos { get; set; }
        public bool Esperado { get; set; }
        public int SeccionesDado { get; set; }
        public int Marcas { get; set; }
    }

    /// <summary>Una sección (curso + sección + jornada) que lleva la materia, con su avance y semáforo.</summary>
    public class PR_tbTemarios_GruposResult
    {
        public int Cur_Id { get; set; }
        public string Curso { get; set; }
        public int Sec_Id { get; set; }
        public string Seccion { get; set; }
        public int Mda_Id { get; set; }
        public string Jornada { get; set; }
        public string Docentes { get; set; }
        public int CantidadDocentes { get; set; }
        public bool PuedeMarcar { get; set; }
        public int Total { get; set; }
        public int Dados { get; set; }
        public int Parciales { get; set; }
        public int Omitidos { get; set; }
        public int Esperados { get; set; }
        public int Atrasados { get; set; }
        public int? SemanaActual { get; set; }
        public int Pct { get; set; }
        public string Semaforo { get; set; }
    }

    /// <summary>Una marca de avance (tema × sección).</summary>
    public class PR_tbTemarioAvance_ListResult
    {
        public int Tav_Id { get; set; }
        public int Tet_Id { get; set; }
        public int Cur_Id { get; set; }
        public int Sec_Id { get; set; }
        public int Mda_Id { get; set; }
        public string Tav_Estado { get; set; }
        public DateTime? Tav_Fecha { get; set; }
        public string Tav_Nota { get; set; }
        public string Usuario { get; set; }
        public DateTime FechaRegistro { get; set; }
    }

    /// <summary>Resumen de Dirección: una fila por sección de cada temario del año.</summary>
    public class PR_tbTemarios_ResumenResult
    {
        public int Tem_Id { get; set; }
        public string Tem_Nombre { get; set; }
        public int Mat_Id { get; set; }
        public string Materia { get; set; }
        public int? Niv_Id { get; set; }
        public string Nivel { get; set; }
        public int Cun_Id { get; set; }
        public string Grado { get; set; }
        public int Cun_Orden { get; set; }
        public int Cur_Id { get; set; }
        public string Curso { get; set; }
        public int Sec_Id { get; set; }
        public string Seccion { get; set; }
        public int Mda_Id { get; set; }
        public string Jornada { get; set; }
        public int Sem_Id { get; set; }
        public int Tem_Anio { get; set; }
        public int Total { get; set; }
        public int Dados { get; set; }
        public int Parciales { get; set; }
        public int Omitidos { get; set; }
        public int Esperados { get; set; }
        public int Atrasados { get; set; }
        public int? SemanaActual { get; set; }
        public int Pct { get; set; }
        public string Semaforo { get; set; }
        public DateTime? UltimaFecha { get; set; }
        public string Docentes { get; set; }
    }

    /// <summary>Materia que se da en el horario del año y aún no tiene temario.</summary>
    public class PR_tbTemarios_SinTemarioResult
    {
        public int Sem_Id { get; set; }
        public string Semestre { get; set; }
        public int Mat_Id { get; set; }
        public string Materia { get; set; }
        public int? Niv_Id { get; set; }
        public string Nivel { get; set; }
        public int Cun_Id { get; set; }
        public string Grado { get; set; }
        public int Cun_Orden { get; set; }
        public int Secciones { get; set; }
    }

    /// <summary>Opción de un filtro en cascada.</summary>
    public class PR_tbTemarios_OpcionResult
    {
        public int Value { get; set; }
        public string Text { get; set; }
    }

    /// <summary>Tema del temario de un horario para una semana (lo ofrece "Plan de clases").</summary>
    public class PR_tbTemarios_TemaHorarioResult
    {
        public int Tet_Id { get; set; }
        public int Tem_Id { get; set; }
        public string Tem_Nombre { get; set; }
        public int Tet_Semana { get; set; }
        public int Tet_Orden { get; set; }
        public string Tet_Titulo { get; set; }
        public string Tet_Objetivos { get; set; }
        public string Tet_Contenido { get; set; }
        public string Tet_Recursos { get; set; }
    }

    /// <summary>Lo que devuelven las escrituras: el registro tocado, su temario y una cantidad (temas copiados, marcas…).</summary>
    public class PR_tbTemarios_EscrituraResult
    {
        public int Id { get; set; }
        public int Tem_Id { get; set; }
        public int Cantidad { get; set; }
    }
}
