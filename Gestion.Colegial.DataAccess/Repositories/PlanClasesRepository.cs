using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class PlanClasesRepository : RepositoryBase, IPlanClasesRepository
    {
        public async Task<Answer> List(int Hor_Id)
        {
            const string sql = "app.PR_tbPlanClases_List";
            SqlParameter[] p = { new SqlParameter { ParameterName = "@Hor_Id", DbType = DbType.Int32, Value = Hor_Id } };
            return await SearchAll<PR_tbPlanClases_ListResult>(sql, p);
        }

        public async Task<Answer> Find(int Pla_Id)
        {
            const string sql = "app.PR_tbPlanClases_Find";
            SqlParameter[] p = { new SqlParameter { ParameterName = "@Pla_Id", DbType = DbType.Int32, Value = Pla_Id } };
            return await Search<PR_tbPlanClases_FindResult>(sql, p);
        }

        public async Task<Answer> Insert(int Hor_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, int usuarioRegistra)
        {
            const string sql = "app.PR_tbPlanClases_Insert";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Hor_Id",              DbType = DbType.Int32,  Value = Hor_Id },
                new SqlParameter { ParameterName = "@Pla_Semana",          DbType = DbType.Int16,  Value = Pla_Semana },
                new SqlParameter { ParameterName = "@Pla_Tema",            DbType = DbType.String, Value = Pla_Tema },
                new SqlParameter { ParameterName = "@Pla_Objetivos",       DbType = DbType.String, Value = (object)Pla_Objetivos ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@Pla_Recursos",        DbType = DbType.String, Value = (object)Pla_Recursos  ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@Pla_UsuarioRegistra", DbType = DbType.Int32,  Value = usuarioRegistra },
            };
            return await New(sql, p);
        }

        public async Task<Answer> Update(int Pla_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, string Pla_Estado, int usuarioModifica)
        {
            const string sql = "app.PR_tbPlanClases_Update";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Pla_Id",              DbType = DbType.Int32,  Value = Pla_Id },
                new SqlParameter { ParameterName = "@Pla_Semana",          DbType = DbType.Int16,  Value = Pla_Semana },
                new SqlParameter { ParameterName = "@Pla_Tema",            DbType = DbType.String, Value = Pla_Tema },
                new SqlParameter { ParameterName = "@Pla_Objetivos",       DbType = DbType.String, Value = (object)Pla_Objetivos ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@Pla_Recursos",        DbType = DbType.String, Value = (object)Pla_Recursos  ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@Pla_Estado",          DbType = DbType.String, Value = Pla_Estado },
                new SqlParameter { ParameterName = "@Pla_UsuarioModifica", DbType = DbType.Int32,  Value = usuarioModifica },
            };
            return await Update(sql, p);
        }

        public async Task<Answer> Delete(int Pla_Id, int usuarioModifica)
        {
            const string sql = "app.PR_tbPlanClases_Delete";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Pla_Id",              DbType = DbType.Int32, Value = Pla_Id },
                new SqlParameter { ParameterName = "@Pla_UsuarioModifica", DbType = DbType.Int32, Value = usuarioModifica },
            };
            return await Delete(sql, p);
        }
    }
}
