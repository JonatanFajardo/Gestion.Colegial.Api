namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>finanza.PR_tbPagos_Registrar</summary>
    public class PR_tbPagos_RegistrarResult
    {
        public decimal? NewId { get; set; }
        public decimal MontoAplicado { get; set; }
        public decimal Excedente { get; set; }
        public decimal SaldoFavor { get; set; }
    }

    /// <summary>finanza.PR_tbPagos_Anular</summary>
    public class PR_tbPagos_AnularResult
    {
        public int PagoId { get; set; }
        public decimal Monto { get; set; }
        public string Destino { get; set; } = string.Empty;
        public int CargosReabiertos { get; set; }
        public decimal SaldoFavor { get; set; }
    }

    /// <summary>finanza.PR_tbCuentasCobrar_Perdonar</summary>
    public class PR_tbCuentasCobrar_PerdonarResult
    {
        public int CuentaCobrarId { get; set; }
        public decimal Pendiente { get; set; }
        public decimal MontoTotal { get; set; }
        public string EstadoPago { get; set; } = string.Empty;
    }

    /// <summary>finanza.PR_SaldoFavor_Obtener y PR_SaldoFavor_Devolver</summary>
    public class PR_SaldoFavorResult
    {
        public int AlumnoId { get; set; }
        public decimal Saldo { get; set; }
    }

    /// <summary>finanza.PR_SaldoFavor_Aplicar</summary>
    public class PR_SaldoFavor_AplicarResult
    {
        public int AlumnoId { get; set; }
        public decimal MontoAplicado { get; set; }
        public int CargosAfectados { get; set; }
        public decimal Saldo { get; set; }
    }

    /// <summary>finanza.PR_Correcciones_ListByAlumno</summary>
    public class PR_Correcciones_ListByAlumnoResult
    {
        public DateTime Fecha { get; set; }
        public string Tipo { get; set; } = string.Empty;
        public string? Detalle { get; set; }
        public string? Motivo { get; set; }
        public string? Usuario { get; set; }
        public decimal Monto { get; set; }
    }
}
