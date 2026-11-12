using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Feriados nacionales de Honduras (Código del Trabajo, art. 339 y reformas) y fechas
    /// escolares habituales, calculados para un año.
    /// - Semana Santa se calcula desde la fecha de Pascua.
    /// - El Feriado Morazánico (3, 12 y 21 de octubre) se goza junto, de miércoles a viernes de la
    ///   primera semana de octubre; lo confirma un decreto cada año, por eso se marca "Verificar".
    /// La clave (HN-{año}-{nombre}) evita cargarlos dos veces.
    /// </summary>
    public static class CalculoFeriadosHonduras
    {
        public const string GrupoNacional = "Feriado nacional";
        public const string GrupoEscolar = "Fecha escolar";

        public static string Prefijo(int anio) => $"HN-{anio}-";

        public static List<FeriadoPropuestoDTO> Del(int anio)
        {
            DateTime pascua = Pascua(anio);
            DateTime miercolesMorazanico = new DateTime(anio, 10, 1);
            while (miercolesMorazanico.DayOfWeek != DayOfWeek.Wednesday)
                miercolesMorazanico = miercolesMorazanico.AddDays(1);

            var lista = new List<FeriadoPropuestoDTO>
            {
                Nacional(anio, "anio-nuevo", "Año Nuevo", new DateTime(anio, 1, 1)),
                new FeriadoPropuestoDTO
                {
                    Clave = Prefijo(anio) + "semana-santa-asueto",
                    Titulo = "Semana Santa (vacaciones)",
                    Tipo = "cierre",
                    Inicio = pascua.AddDays(-6),
                    Fin = pascua.AddDays(-4),
                    Descripcion = "Lunes a miércoles santo. El asueto lo decreta el gobierno cada año: confirme las fechas.",
                    Grupo = GrupoNacional,
                    Sugerido = true,
                    Verificar = true
                },
                Nacional(anio, "jueves-viernes-santo", "Jueves y Viernes Santo", pascua.AddDays(-3), pascua.AddDays(-2)),
                Nacional(anio, "dia-americas", "Día de las Américas", new DateTime(anio, 4, 14)),
                Nacional(anio, "dia-trabajo", "Día del Trabajador", new DateTime(anio, 5, 1)),
                Nacional(anio, "independencia", "Día de la Independencia", new DateTime(anio, 9, 15)),
                new FeriadoPropuestoDTO
                {
                    Clave = Prefijo(anio) + "feriado-morazanico",
                    Titulo = "Feriado Morazánico",
                    Tipo = "feriado",
                    Inicio = miercolesMorazanico,
                    Fin = miercolesMorazanico.AddDays(2),
                    Descripcion = "Agrupa el 3, 12 y 21 de octubre. Las fechas las confirma un decreto cada año.",
                    Grupo = GrupoNacional,
                    Sugerido = true,
                    Verificar = true
                },
                Nacional(anio, "navidad", "Navidad", new DateTime(anio, 12, 25)),

                Escolar(anio, "dia-estudiante", "Día del Estudiante", "dia_especial", new DateTime(anio, 6, 11), null),
                Escolar(anio, "dia-bandera", "Día de la Bandera", "acto_civico", new DateTime(anio, 9, 1), null),
                Escolar(anio, "dia-nino", "Día del Niño", "dia_especial", new DateTime(anio, 9, 10), null),
                Escolar(anio, "dia-maestro", "Día del Maestro", "dia_especial", new DateTime(anio, 9, 17),
                        "Si ese día no hay clases, cámbielo a Cierre.")
            };

            return lista.OrderBy(f => f.Inicio).ToList();
        }

        private static FeriadoPropuestoDTO Nacional(int anio, string clave, string titulo, DateTime inicio, DateTime? fin = null) =>
            new FeriadoPropuestoDTO
            {
                Clave = Prefijo(anio) + clave,
                Titulo = titulo,
                Tipo = "feriado",
                Inicio = inicio,
                Fin = fin ?? inicio,
                Descripcion = "Feriado nacional.",
                Grupo = GrupoNacional,
                Sugerido = true
            };

        private static FeriadoPropuestoDTO Escolar(int anio, string clave, string titulo, string tipo, DateTime dia, string? descripcion) =>
            new FeriadoPropuestoDTO
            {
                Clave = Prefijo(anio) + clave,
                Titulo = titulo,
                Tipo = tipo,
                Inicio = dia,
                Fin = dia,
                Descripcion = descripcion ?? "Fecha escolar.",
                Grupo = GrupoEscolar,
                Sugerido = false
            };

        /// <summary>Domingo de Pascua (algoritmo gregoriano de Meeus/Jones/Butcher).</summary>
        public static DateTime Pascua(int anio)
        {
            int a = anio % 19, b = anio / 100, c = anio % 100, d = b / 4, e = b % 4;
            int f = (b + 8) / 25, g = (b - f + 1) / 3;
            int h = (19 * a + b - d - g + 15) % 30;
            int i = c / 4, k = c % 4;
            int l = (32 + 2 * e + 2 * i - h - k) % 7;
            int m = (a + 11 * h + 22 * l) / 451;
            int mes = (h + l - 7 * m + 114) / 31;
            int dia = ((h + l - 7 * m + 114) % 31) + 1;
            return new DateTime(anio, mes, dia);
        }
    }
}
