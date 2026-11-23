namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Una clase de un docente ausente en una fecha (script 073). Un ausente sin clases ese día sale
    /// una vez con Hor_Id null. Origen: vacaciones | permiso | incapacidad | asistencia | manual.
    /// Minutos del día: 420 = 7:00, 780 = 13:00.
    /// </summary>
    public class PR_tbSustituciones_DiaResult
    {
        public int Emp_IdAusente { get; set; }
        public string Ausente { get; set; }
        public string Foto { get; set; }
        public string Origen { get; set; }
        public int? OrigenId { get; set; }
        public string Detalle { get; set; }
        public int? Hor_Id { get; set; }
        public int? MinInicio { get; set; }
        public int? MinFin { get; set; }
        public string Materia { get; set; }
        public string Grado { get; set; }
        public string Seccion { get; set; }
        public string Modalidad { get; set; }
        public string Curso { get; set; }
        public string Aula { get; set; }
        /// <summary>Feriado o cierre publicado que deja sin clase ese día.</summary>
        public string Cierre { get; set; }
        public int? Sus_Id { get; set; }
        public int? Emp_IdSuplente { get; set; }
        public string Suplente { get; set; }
        public string Sus_Notas { get; set; }
        public bool PuedeCancelar { get; set; }
    }

    /// <summary>Indicadores del mes de una fecha (con Emp_Id: lo que cubrió ese docente).</summary>
    public class PR_tbSustituciones_MesResult
    {
        public int ClasesMes { get; set; }
        public int MinutosMes { get; set; }
        public int SuplentesMes { get; set; }
        public int ClasesDia { get; set; }
    }

    /// <summary>Un suplente posible para una clase, con las razones del orden.</summary>
    public class PR_tbSustituciones_SugerenciasResult
    {
        public int Emp_Id { get; set; }
        public string Nombre { get; set; }
        public string Foto { get; set; }
        public bool SabeMateria { get; set; }
        public bool MismoGrado { get; set; }
        public bool MismoGrupo { get; set; }
        public int SustitucionesMes { get; set; }
        public int ClasesDia { get; set; }
        public int Orden { get; set; }
    }

    /// <summary>Un docente para "Marcar docente ausente".</summary>
    public class PR_tbSustituciones_DocentesResult
    {
        public int Emp_Id { get; set; }
        public string Nombre { get; set; }
        public string Foto { get; set; }
        public int ClasesDia { get; set; }
        /// <summary>Si ya figura ausente ese día, el origen.</summary>
        public string AusenteOrigen { get; set; }
    }

    /// <summary>Una sustitución del historial.</summary>
    public class PR_tbSustituciones_HistorialResult
    {
        public int Sus_Id { get; set; }
        public DateTime Sus_Fecha { get; set; }
        public int Hor_Id { get; set; }
        public int? MinInicio { get; set; }
        public int? MinFin { get; set; }
        public int Sus_Minutos { get; set; }
        public string Materia { get; set; }
        public string Grado { get; set; }
        public string Seccion { get; set; }
        public string Modalidad { get; set; }
        public string Curso { get; set; }
        public string Aula { get; set; }
        public int Emp_IdAusente { get; set; }
        public string Ausente { get; set; }
        public int Emp_IdSuplente { get; set; }
        public string Suplente { get; set; }
        public string Sus_Origen { get; set; }
        public int? Sus_OrigenId { get; set; }
        public string OrigenDetalle { get; set; }
        public string Sus_Estado { get; set; }
        public string Sus_Notas { get; set; }
        public string Sus_MotivoCancelacion { get; set; }
        public string RegistradoPor { get; set; }
        public DateTime Sus_FechaRegistra { get; set; }
        public string CanceladoPor { get; set; }
        public DateTime? Sus_FechaCancela { get; set; }
    }

    /// <summary>Lo que devuelven las escrituras: el id afectado y su estado.</summary>
    public class PR_tbSustituciones_EscrituraResult
    {
        public int Id { get; set; }
        public string Estado { get; set; }
    }
}
