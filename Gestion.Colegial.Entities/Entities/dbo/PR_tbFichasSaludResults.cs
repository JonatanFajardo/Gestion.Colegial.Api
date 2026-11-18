namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Un alumno activo en el directorio de fichas de salud (script 070).</summary>
    public class PR_tbFichasSalud_DirectorioResult
    {
        public int Alu_Id { get; set; }
        public string? Alumno { get; set; }
        public string? Identidad { get; set; }
        public string? Foto { get; set; }
        public int? Niv_Id { get; set; }
        public string? Nivel { get; set; }
        public int? Cun_Id { get; set; }
        public string? Grado { get; set; }
        public int? Sec_Id { get; set; }
        public string? Seccion { get; set; }
        public bool TieneFicha { get; set; }
        public bool TieneAlerta { get; set; }
        public string? Alerta { get; set; }
        public string? TipoSangre { get; set; }
        public string? Encargado { get; set; }
        public string? EncargadoTelefono { get; set; }
        public string? ContactoNombre { get; set; }
        public string? ContactoTelefono { get; set; }
        /// <summary>Hay a quién llamar: algún encargado con teléfono o el contacto adicional.</summary>
        public bool TieneTelefono { get; set; }
        public DateTime? Actualizada { get; set; }
    }

    /// <summary>El alumno y su ficha; las columnas Fsa_* vienen en null si todavía no tiene ficha.</summary>
    public class PR_tbFichasSalud_FindResult
    {
        public int Alu_Id { get; set; }
        public string? Alumno { get; set; }
        public string? PrimerNombre { get; set; }
        public string? ApellidoPaterno { get; set; }
        public string? Identidad { get; set; }
        public string? Foto { get; set; }
        public string? Sexo { get; set; }
        public DateTime? FechaNacimiento { get; set; }
        public string? Nivel { get; set; }
        public string? Grado { get; set; }
        public string? Seccion { get; set; }
        public string? Curso { get; set; }
        public string? Estado { get; set; }
        public int? Fsa_Id { get; set; }
        public string? Fsa_TipoSangre { get; set; }
        public bool Fsa_TieneAlerta { get; set; }
        public string? Fsa_Alerta { get; set; }
        public string? Fsa_Alergias { get; set; }
        public string? Fsa_Condiciones { get; set; }
        public string? Fsa_Medicamentos { get; set; }
        public string? Fsa_RestriccionesAlimentarias { get; set; }
        public string? Fsa_MedicoNombre { get; set; }
        public string? Fsa_MedicoTelefono { get; set; }
        public string? Fsa_Hospital { get; set; }
        public string? Fsa_Seguro { get; set; }
        public string? Fsa_SeguroPoliza { get; set; }
        public string? Fsa_ContactoEmergenciaNombre { get; set; }
        public string? Fsa_ContactoEmergenciaParentesco { get; set; }
        public string? Fsa_ContactoEmergenciaTelefono { get; set; }
        public string? Fsa_Notas { get; set; }
        public int? Fsa_Version { get; set; }
        public DateTime? Fsa_FechaRegistra { get; set; }
        public DateTime? Actualizada { get; set; }
        public string? ActualizadaPor { get; set; }
    }

    /// <summary>Un encargado del alumno con su teléfono ("a quién llamar").</summary>
    public class PR_tbFichasSalud_ContactosResult
    {
        public int Enc_Id { get; set; }
        public string? Nombre { get; set; }
        public string? Parentesco { get; set; }
        public string? Telefono { get; set; }
        public string? Correo { get; set; }
        public bool EsPrincipal { get; set; }
    }

    /// <summary>Resultado de guardar: Accion = creada | editada | sin_cambios; Campos = lo que cambió.</summary>
    public class PR_tbFichasSalud_GuardarResult
    {
        public int Fsa_Id { get; set; }
        public int Fsa_Version { get; set; }
        public string? Accion { get; set; }
        public string? Campos { get; set; }
    }

    /// <summary>Una entrada del historial: quién, cuándo y qué campos (sin valores).</summary>
    public class PR_tbFichasSaludBitacora_ListResult
    {
        public int Fsb_Id { get; set; }
        public string? Fsb_Accion { get; set; }
        public string? Fsb_Campos { get; set; }
        public DateTime Fsb_Fecha { get; set; }
        public int? Fsb_Usuario { get; set; }
        public string? Usuario { get; set; }
    }

    /// <summary>Alerta crítica de un alumno para el pase de lista: solo el texto corto.</summary>
    public class PR_tbFichasSalud_AlertasSeccionResult
    {
        public int Alu_Id { get; set; }
        public string? Fsa_Alerta { get; set; }
    }
}
