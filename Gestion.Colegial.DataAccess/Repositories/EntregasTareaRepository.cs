using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class EntregasTareaRepository : RepositoryBase, IEntregasTareaRepository
    {
        public async Task<Answer> List(int Tar_Id)
        {
            const string sql = "app.PR_tbEntregasTarea_List";
            SqlParameter[] p = { new SqlParameter { ParameterName = "@Tar_Id", DbType = DbType.Int32, Value = Tar_Id } };
            return await SearchAll<PR_tbEntregasTarea_ListResult>(sql, p);
        }

        public async Task<Answer> Upsert(int Tar_Id, int Alu_Id, bool Ent_Entregado, string Ent_Observacion, int usuarioRegistra)
        {
            const string sql = "app.PR_tbEntregasTarea_Upsert";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Tar_Id",          DbType = DbType.Int32,   Value = Tar_Id },
                new SqlParameter { ParameterName = "@Alu_Id",          DbType = DbType.Int32,   Value = Alu_Id },
                new SqlParameter { ParameterName = "@Ent_Entregado",   DbType = DbType.Boolean, Value = Ent_Entregado },
                new SqlParameter { ParameterName = "@Ent_Observacion",DbType = DbType.String,  Value = (object)Ent_Observacion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@UsuarioRegistra", DbType = DbType.Int32,   Value = usuarioRegistra },
            };
            return await NewWithId<PR_tbEntregasTarea_UpsertResult>(sql, p);
        }

        public async Task<Answer> Update(int Ent_Id, decimal Ent_Nota, string Ent_Observacion, int usuarioModifica)
        {
            const string sql = "app.PR_tbEntregasTarea_Update";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Ent_Id",          DbType = DbType.Int32,   Value = Ent_Id },
                new SqlParameter { ParameterName = "@Ent_Nota",        DbType = DbType.Decimal, Value = Ent_Nota },
                new SqlParameter { ParameterName = "@Ent_Observacion",DbType = DbType.String,  Value = (object)Ent_Observacion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@UsuarioModifica", DbType = DbType.Int32,   Value = usuarioModifica },
            };
            return await base.Update(sql, p);
        }
    }
}
