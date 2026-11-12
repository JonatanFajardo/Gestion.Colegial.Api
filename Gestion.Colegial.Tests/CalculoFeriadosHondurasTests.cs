using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Tests
{
    /// <summary>Feriados y fechas escolares de Honduras que propone el calendario escolar.</summary>
    public class CalculoFeriadosHondurasTests
    {
        private static FeriadoPropuestoDTO Buscar(List<FeriadoPropuestoDTO> lista, string titulo) =>
            Assert.Single(lista, f => f.Titulo == titulo);

        [Theory]
        [InlineData(2024, 3, 31)]
        [InlineData(2025, 4, 20)]
        [InlineData(2026, 4, 5)]
        [InlineData(2027, 3, 28)]
        [InlineData(2028, 4, 16)]
        [InlineData(2030, 4, 21)]
        public void Pascua_DeberiaRetornarElDomingoDePascua_CuandoSeIndicaElAnio(int anio, int mes, int dia)
        {
            DateTime pascua = CalculoFeriadosHonduras.Pascua(anio);

            Assert.Equal(new DateTime(anio, mes, dia), pascua);
            Assert.Equal(DayOfWeek.Sunday, pascua.DayOfWeek);
        }

        [Theory]
        [InlineData(2023, 4, 6)]
        [InlineData(2024, 2, 4)]
        [InlineData(2025, 1, 3)]
        [InlineData(2026, 7, 9)]
        public void Del_DeberiaUbicarElFeriadoMorazanico_DeMiercolesAViernesDeLaPrimeraSemanaDeOctubre(int anio, int diaInicio, int diaFin)
        {
            FeriadoPropuestoDTO morazanico = Buscar(CalculoFeriadosHonduras.Del(anio), "Feriado Morazánico");

            Assert.Equal(new DateTime(anio, 10, diaInicio), morazanico.Inicio);
            Assert.Equal(new DateTime(anio, 10, diaFin), morazanico.Fin);
            Assert.Equal(DayOfWeek.Wednesday, morazanico.Inicio.DayOfWeek);
            Assert.True(morazanico.Verificar);
        }

        [Fact]
        public void Del_DeberiaRetornar12Fechas_8DeEllasFeriadosNacionales_CuandoAnioEs2026()
        {
            List<FeriadoPropuestoDTO> lista = CalculoFeriadosHonduras.Del(2026);

            Assert.Equal(12, lista.Count);
            Assert.Equal(8, lista.Count(f => f.Grupo == "Feriado nacional"));
        }

        [Fact]
        public void Del_DeberiaRetornarClavesUnicasConPrefijoDelAnio_CuandoAnioEs2026()
        {
            List<FeriadoPropuestoDTO> lista = CalculoFeriadosHonduras.Del(2026);

            Assert.All(lista, f => Assert.StartsWith("HN-2026-", f.Clave));
            Assert.Equal(lista.Count, lista.Select(f => f.Clave).Distinct().Count());
        }

        [Fact]
        public void Del_DeberiaRetornarLasFechasOrdenadasPorInicio_CuandoAnioEs2026()
        {
            List<FeriadoPropuestoDTO> lista = CalculoFeriadosHonduras.Del(2026);

            for (int i = 1; i < lista.Count; i++)
                Assert.True(lista[i - 1].Inicio <= lista[i].Inicio,
                    $"'{lista[i - 1].Titulo}' ({lista[i - 1].Inicio:d}) quedó antes que '{lista[i].Titulo}' ({lista[i].Inicio:d}).");
        }

        [Fact]
        public void Del_DeberiaProponerVacacionesDeSemanaSantaDeLunesAMiercolesSanto_ParaVerificar_CuandoAnioEs2026()
        {
            FeriadoPropuestoDTO semanaSanta = Buscar(CalculoFeriadosHonduras.Del(2026), "Semana Santa (vacaciones)");

            Assert.Equal(new DateTime(2026, 3, 30), semanaSanta.Inicio);
            Assert.Equal(new DateTime(2026, 4, 1), semanaSanta.Fin);
            Assert.True(semanaSanta.Verificar);
        }

        [Fact]
        public void Del_DeberiaUbicarJuevesYViernesSanto_CuandoAnioEs2026()
        {
            FeriadoPropuestoDTO juevesViernes = Buscar(CalculoFeriadosHonduras.Del(2026), "Jueves y Viernes Santo");

            Assert.Equal(new DateTime(2026, 4, 2), juevesViernes.Inicio);
            Assert.Equal(new DateTime(2026, 4, 3), juevesViernes.Fin);
        }

        [Fact]
        public void Del_DeberiaDejarSinMarcarLasFechasEscolares_YMarcarLosFeriadosNacionales_CuandoAnioEs2026()
        {
            List<FeriadoPropuestoDTO> lista = CalculoFeriadosHonduras.Del(2026);
            List<FeriadoPropuestoDTO> escolares = lista.Where(f => f.Grupo == "Fecha escolar").ToList();

            Assert.Equal(4, escolares.Count);
            Assert.All(escolares, f => Assert.False(f.Sugerido));
            Assert.All(lista.Where(f => f.Grupo == "Feriado nacional"), f => Assert.True(f.Sugerido));
        }
    }
}
