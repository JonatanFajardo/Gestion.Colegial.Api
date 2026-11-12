using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Constancias y expediente (script 064). Solo lectura y emisión: un documento emitido no se
    /// edita ni se borra (lo impide un trigger en la tabla).
    /// </summary>
    public class DocumentosEmitidosRepository : RepositoryBase, IDocumentosEmitidosRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Texto(string nombre, string? valor, DbType tipo = DbType.String) =>
            new SqlParameter() { ParameterName = nombre, DbType = tipo, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        public async Task<Answer> List(string? tipo, int? aluId, int? aniId)
        {
            SqlParameter[] p = { Texto("@Doc_Tipo", tipo, DbType.AnsiString), Entero("@Alu_Id", aluId), Entero("@Ani_Id", aniId) };
            return await Read<PR_tbDocumentosEmitidos_ListResult>("app.PR_tbDocumentosEmitidos_List", p);
        }

        /// <summary>Sin fila (Data null) si no existe.</summary>
        public async Task<Answer> Find(int id) =>
            await Search<PR_tbDocumentosEmitidos_FindResult>("app.PR_tbDocumentosEmitidos_Find", new[] { Entero("@Doc_Id", id) });

        public async Task<Answer> VistaPrevia(string? tipo, int aluId, int? aniId, int? pacId)
        {
            SqlParameter[] p =
            {
                Texto("@Doc_Tipo", tipo, DbType.AnsiString), Entero("@Alu_Id", aluId), Entero("@Ani_Id", aniId), Entero("@Pac_Id", pacId)
            };
            return await Search<PR_tbDocumentosEmitidos_VistaPreviaResult>("app.PR_tbDocumentosEmitidos_VistaPrevia", p);
        }

        public async Task<Answer> Emitir(DocumentoEmitirDTO obj)
        {
            SqlParameter[] p =
            {
                Texto("@Doc_Tipo", obj.Doc_Tipo, DbType.AnsiString), Entero("@Alu_Id", obj.Alu_Id), Entero("@Ani_Id", obj.Ani_Id),
                Entero("@Pac_Id", obj.Pac_Id), Texto("@Doc_Motivo", obj.Doc_Motivo), Entero("@Doc_UsuarioEmite", obj.Doc_UsuarioEmite)
            };
            return await Search<PR_tbDocumentosEmitidos_EmitirResult>("app.PR_tbDocumentosEmitidos_Emitir", p);
        }
    }
}
