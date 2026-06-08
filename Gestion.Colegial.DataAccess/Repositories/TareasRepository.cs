using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class TareasRepository : RepositoryBase, ITareasRepository
    {
        public async Task<Answer> List(int Hor_Id)
        {
            const string sql = "app.PR_tbTareas_List";
            SqlParameter[] p = { new SqlParameter { ParameterName = "@Hor_Id", DbType = DbType.Int32, Value = Hor_Id } };
            return await SearchAll<PR_tbTareas_ListResult>(sql, p);
        }

        public async Task<Answer> Find(int Tar_Id)
        {
            const string sql = "app.PR_tbTareas_Find";
            SqlParameter[] p = { new SqlParameter { ParameterName = "@Tar_Id", DbType = DbType.Int32, Value = Tar_Id } };
            return await Search<PR_tbTareas_FindResult>(sql, p);
        }

        public async Task<Answer> Insert(int Hor_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, int usuarioRegistra)
        {
            const string sql = "app.PR_tbTareas_Insert";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Hor_Id",             DbType = DbType.Int32,   Value = Hor_Id },
                new SqlParameter { ParameterName = "@Tar_Titulo",         DbType = DbType.String,  Value = Tar_Titulo },
                new SqlParameter { ParameterName = "@Tar_Descripcion",    DbType = DbType.String,  Value = (object)Tar_Descripcion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Tar_FechaEntrega",   DbType = DbType.Date,    Value = Tar_FechaEntrega },
                new SqlParameter { ParameterName = "@Tar_Punteo",         DbType = DbType.Decimal, Value = Tar_Punteo },
                new SqlParameter { ParameterName = "@Tar_UsuarioRegistra",DbType = DbType.Int32,   Value = usuarioRegistra },
            };
            return await New(sql, p);
        }

        public async Task<Answer> Update(int Tar_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, string Tar_Estado, int usuarioModifica)
        {
            const string sql = "app.PR_tbTareas_Update";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Tar_Id",              DbType = DbType.Int32,   Value = Tar_Id },
                new SqlParameter { ParameterName = "@Tar_Titulo",          DbType = DbType.String,  Value = Tar_Titulo },
                new SqlParameter { ParameterName = "@Tar_Descripcion",     DbType = DbType.String,  Value = (object)Tar_Descripcion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Tar_FechaEntrega",    DbType = DbType.Date,    Value = Tar_FechaEntrega },
                new SqlParameter { ParameterName = "@Tar_Punteo",          DbType = DbType.Decimal, Value = Tar_Punteo },
                new SqlParameter { ParameterName = "@Tar_Estado",          DbType = DbType.String,  Value = Tar_Estado },
                new SqlParameter { ParameterName = "@Tar_UsuarioModifica", DbType = DbType.Int32,   Value = usuarioModifica },
            };
            return await Update(sql, p);
        }

        public async Task<Answer> Delete(int Tar_Id, int usuarioModifica)
        {
            const string sql = "app.PR_tbTareas_Delete";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Tar_Id",              DbType = DbType.Int32, Value = Tar_Id },
                new SqlParameter { ParameterName = "@Tar_UsuarioModifica", DbType = DbType.Int32, Value = usuarioModifica },
            };
            return await Delete(sql, p);
        }
    }
}
