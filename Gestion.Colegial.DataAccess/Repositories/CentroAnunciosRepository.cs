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

        public async Task<Answer> Insert(string Anu_Titulo, string Anu_Contenido, DateTime? Anu_FechaExpiracion, int UsuarioRegistra)
        {
            const string sql = "app.PR_CentroAnuncios_Insert";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Anu_Titulo",          DbType = DbType.String,   Value = Anu_Titulo },
                new SqlParameter { ParameterName = "@Anu_Contenido",       DbType = DbType.String,   Value = Anu_Contenido },
                new SqlParameter { ParameterName = "@Anu_FechaExpiracion", DbType = DbType.DateTime, Value = (object)Anu_FechaExpiracion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@UsuarioRegistra",     DbType = DbType.Int32,    Value = UsuarioRegistra },
            };
            return await New(sql, parameters);
        }

        public async Task<Answer> Delete(int Anu_Id, int UsuarioModifica)
        {
            const string sql = "app.PR_CentroAnuncios_Delete";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Anu_Id",         DbType = DbType.Int32, Value = Anu_Id },
                new SqlParameter { ParameterName = "@UsuarioModifica", DbType = DbType.Int32, Value = UsuarioModifica },
            };
            return await Delete(sql, parameters);
        }
    }
}
