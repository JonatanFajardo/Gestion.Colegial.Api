using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class CentroAnunciosRepository : RepositoryBase, ICentroAnunciosRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "app.PR_CentroAnuncios_List";
            SqlParameter[] parameters = { };
            return await SearchAll<CentroAnunciosResult>(sql, parameters);
        }

        public async Task<Answer> Insert(string Anu_Titulo, string Anu_Contenido, DateTime? Anu_FechaExpiracion, int UsuarioRegistra,
            string Anu_Publico, int? Anu_NivId, int? Anu_CunId, int? Anu_SecId)
        {
            const string sql = "app.PR_CentroAnuncios_Insert";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Anu_Titulo",           DbType = DbType.String,     Value = Anu_Titulo },
                new SqlParameter { ParameterName = "@Anu_Contenido",        DbType = DbType.String,     Value = Anu_Contenido },
                new SqlParameter { ParameterName = "@Anu_FechaExpiracion",  DbType = DbType.Date,       Value = (object)Anu_FechaExpiracion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Anu_UsuarioRegistra",  DbType = DbType.Int32,      Value = UsuarioRegistra },
                new SqlParameter { ParameterName = "@Anu_Publico",          DbType = DbType.AnsiString, Value = Anu_Publico },
                new SqlParameter { ParameterName = "@Anu_NivId",            DbType = DbType.Int32,      Value = (object)Anu_NivId ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Anu_CunId",            DbType = DbType.Int32,      Value = (object)Anu_CunId ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Anu_SecId",            DbType = DbType.Int32,      Value = (object)Anu_SecId ?? DBNull.Value },
            };
            return await Search<CentroAnunciosInsertResult>(sql, parameters);
        }

        public async Task<Answer> Opciones(string tipo, int? padre)
        {
            const string sql = "app.PR_CentroAnuncios_Opciones";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Tipo",  DbType = DbType.AnsiString, Value = tipo },
                new SqlParameter { ParameterName = "@Padre", DbType = DbType.Int32,      Value = (object)padre ?? DBNull.Value },
            };
            return await SearchAll<CentroAnunciosOpcionResult>(sql, parameters);
        }

        // Solo lo dirigido a familias que aplique a algún hijo del encargado de este usuario
        public async Task<Answer> ParaFamilia(int usuId)
        {
            const string sql = "app.PR_Portal_Anuncios";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Usu_Id", DbType = DbType.Int32, Value = usuId },
            };
            return await SearchAll<CentroAnunciosResult>(sql, parameters);
        }

        public async Task<Answer> Delete(int Anu_Id, int UsuarioModifica)
        {
            const string sql = "app.PR_CentroAnuncios_Delete";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Anu_Id",         DbType = DbType.Int32, Value = Anu_Id },
                new SqlParameter { ParameterName = "@Anu_UsuarioModifica", DbType = DbType.Int32, Value = UsuarioModifica },
            };
            return await Delete(sql, parameters);
        }
    }
}
