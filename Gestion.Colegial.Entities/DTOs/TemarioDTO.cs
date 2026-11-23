namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>
    /// Quién escribe (lo pone el ADM con la sesión). Los permisos los calcula el procedimiento con
    /// este usuario: "Editar temarios", "Supervisar temarios" y las materias que imparte.
    /// </summary>
    public abstract class TemarioEscritorDTO
    {
        public int? Usuario { get; set; }
    }

    /// <summary>Datos de un temario. Al editar solo cambian nombre, descripción e inicio de clases.</summary>
    public class TemarioGuardarDTO : TemarioEscritorDTO
    {
        public int Tem_Id { get; set; }
        public int Mat_Id { get; set; }
        public int Cun_Id { get; set; }
        public int? Cur_Id { get; set; }
        public int Sem_Id { get; set; }
        public int Tem_Anio { get; set; }
        public string? Tem_Nombre { get; set; }
        public string? Tem_Descripcion { get; set; }
        public DateTime? Tem_FechaInicio { get; set; }
    }

    /// <summary>
    /// Copiar los temas de un temario. Sin Tem_IdDestino crea uno nuevo (misma materia, grado y curso)
    /// para Sem_Id y Tem_Anio; con Tem_IdDestino agrega los temas al final de ese temario.
    /// </summary>
    public class TemarioCopiarDTO : TemarioEscritorDTO
    {
        public int Tem_IdOrigen { get; set; }
        public int? Tem_IdDestino { get; set; }
        public int? Sem_Id { get; set; }
        public int? Tem_Anio { get; set; }
        public string? Tem_Nombre { get; set; }
        public DateTime? Tem_FechaInicio { get; set; }
    }

    public class TemarioEliminarDTO : TemarioEscritorDTO
    {
        public int Tem_Id { get; set; }
    }

    /// <summary>Agregar (Tet_Id = 0) o editar un tema.</summary>
    public class TemarioTemaDTO : TemarioEscritorDTO
    {
        public int Tet_Id { get; set; }
        public int Tem_Id { get; set; }
        public int Tet_Semana { get; set; }
        public string? Tet_Titulo { get; set; }
        public string? Tet_Objetivos { get; set; }
        public string? Tet_Contenido { get; set; }
        public string? Tet_Recursos { get; set; }
    }

    /// <summary>Mover (Direccion = arriba | abajo) o quitar un tema.</summary>
    public class TemarioTemaAccionDTO : TemarioEscritorDTO
    {
        public int Tet_Id { get; set; }
        public string? Direccion { get; set; }
    }

    /// <summary>Avance de un tema en una sección (curso + sección + jornada). Estado: dado | parcial | omitido.</summary>
    public class TemarioAvanceDTO : TemarioEscritorDTO
    {
        public int Tet_Id { get; set; }
        public int Cur_Id { get; set; }
        public int Sec_Id { get; set; }
        public int Mda_Id { get; set; }
        public string? Tav_Estado { get; set; }
        public DateTime? Tav_Fecha { get; set; }
        public string? Tav_Nota { get; set; }
    }
}
