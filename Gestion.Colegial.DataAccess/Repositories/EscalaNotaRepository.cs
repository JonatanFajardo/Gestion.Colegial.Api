using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Escala de notas (script 065): filas concepto-por-rango + umbrales del cuadro de honor.
    /// </summary>
    public class EscalaNotaRepository : RepositoryBase, IEscalaNotaRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Decimal_(string nombre, decimal valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Decimal, Value = valor };

        private static SqlParameter Texto(string nombre, string? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.String, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        private static SqlParameter Booleano(string nombre, bool valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Boolean, Value = valor };

        public async Task<Answer> List() =>
            await Read<PR_tbEscalaNotas_ListResult>("app.PR_tbEscalaNotas_List");

        public async Task<Answer> Find(int id) =>
            await Search<PR_tbEscalaNotas_FindResult>("app.PR_tbEscalaNotas_Find", new[] { Entero("@Esc_Id", id) });

        public async Task<Answer> Detail(int id) =>
            await Details<PR_tbEscalaNotas_DetailResult>("app.PR_tbEscalaNotas_Detail", new[] { Entero("@Esc_Id", id) }, id);

        public async Task<Answer> Create(tbEscalaNotas obj)
        {
            SqlParameter[] p =
            {
                Texto("@Esc_Concepto", obj.Esc_Concepto),
                Texto("@Esc_Abreviatura", obj.Esc_Abreviatura),
                Decimal_("@Esc_NotaDesde", obj.Esc_NotaDesde),
                Decimal_("@Esc_NotaHasta", obj.Esc_NotaHasta),
                Booleano("@Esc_Aprueba", obj.Esc_Aprueba),
                Entero("@Esc_Orden", obj.Esc_Orden),
                Entero("@Esc_UsuarioRegistra", 1)
            };
            return await New("app.PR_tbEscalaNotas_Insert", p);
        }

        public async Task<Answer> Edit(tbEscalaNotas obj)
        {
            SqlParameter[] p =
            {
                Entero("@Esc_Id", obj.Esc_Id),
                Texto("@Esc_Concepto", obj.Esc_Concepto),
                Texto("@Esc_Abreviatura", obj.Esc_Abreviatura),
                Decimal_("@Esc_NotaDesde", obj.Esc_NotaDesde),
                Decimal_("@Esc_NotaHasta", obj.Esc_NotaHasta),
                Booleano("@Esc_Aprueba", obj.Esc_Aprueba),
                Entero("@Esc_Orden", obj.Esc_Orden),
                Entero("@Esc_UsuarioModifica", 1)
            };
            return await Update("app.PR_tbEscalaNotas_Update", p);
        }

        /// <summary>Devuelve la fila cuyo rango se solapa con el dado (o Data null si no hay choque).</summary>
        public async Task<Answer> Solapa(decimal desde, decimal hasta, int? id)
        {
            SqlParameter[] p = { Decimal_("@Esc_NotaDesde", desde), Decimal_("@Esc_NotaHasta", hasta), Entero("@Esc_Id", id) };
            return await Exist<PR_tbEscalaNotas_ExistResult>("app.PR_tbEscalaNotas_Exist", p);
        }

        public async Task<Answer> Delete(int id) =>
            await Delete("app.PR_tbEscalaNotas_Delete", new[] { Entero("@Esc_Id", id) });

        public async Task<Answer> CuadroHonor(int anio, int? nivId, int? secId)
        {
            SqlParameter[] p = { Entero("@Anio", anio), Entero("@Niv_Id", nivId), Entero("@Sec_Id", secId) };
            return await Read<PR_CuadroHonorResult>("app.PR_CuadroHonor", p);
        }

        public async Task<Answer> ConfigGet() =>
            await Search<PR_tbCuadroHonorConfig_GetResult>("app.PR_tbCuadroHonorConfig_Get", Array.Empty<SqlParameter>());

        public async Task<Answer> ConfigSet(tbCuadroHonorConfig obj)
        {
            SqlParameter[] p =
            {
                Decimal_("@Chc_UmbralHonor", obj.Chc_UmbralHonor),
                Decimal_("@Chc_UmbralHonorSuperior", obj.Chc_UmbralHonorSuperior),
                Entero("@Chc_UsuarioModifica", 1)
            };
            return await Update("app.PR_tbCuadroHonorConfig_Set", p);
        }
    }
}
