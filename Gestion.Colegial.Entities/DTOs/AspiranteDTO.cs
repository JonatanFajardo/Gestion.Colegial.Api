namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>Datos para registrar (Asp_Id 0) o editar un aspirante de la lista de espera.</summary>
    public class AspiranteGuardarDTO
    {
        public int Asp_Id { get; set; }
        public int Ani_Id { get; set; }
        public string? Asp_Nombres { get; set; }
        public string? Asp_Apellidos { get; set; }
        public string? Asp_Identidad { get; set; }
        public DateTime? Asp_FechaNacimiento { get; set; }
        /// <summary>M | F</summary>
        public string? Asp_Sexo { get; set; }
        public string? Asp_EscuelaProcedencia { get; set; }
        public string? Asp_EncargadoNombre { get; set; }
        public string? Asp_EncargadoIdentidad { get; set; }
        public int? Par_Id { get; set; }
        public string? Asp_EncargadoTelefono { get; set; }
        public string? Asp_EncargadoCorreo { get; set; }
        public int Niv_Id { get; set; }
        public int Cun_Id { get; set; }
        public int? Mda_Id { get; set; }
        public int? Cur_Id { get; set; }
        public DateTime? Asp_FechaSolicitud { get; set; }
        /// <summary>0 normal · 1 media · 2 alta.</summary>
        public int Asp_Prioridad { get; set; }
        public string? Asp_MotivoPrioridad { get; set; }
        public string? Asp_Notas { get; set; }
        public int? Usuario { get; set; }
    }

    /// <summary>Mover de estado. Accion: ofrecer | rechazar | desistio | reactivar.</summary>
    public class AspiranteEstadoDTO
    {
        public int Asp_Id { get; set; }
        public string? Accion { get; set; }
        public string? Motivo { get; set; }
        public int? Usuario { get; set; }
    }

    /// <summary>Marca el aspirante como matriculado con el alumno que creó el wizard de Matrícula.</summary>
    public class AspiranteMatricularDTO
    {
        public int Asp_Id { get; set; }
        public int Alu_Id { get; set; }
        public int? Usuario { get; set; }
    }
}
