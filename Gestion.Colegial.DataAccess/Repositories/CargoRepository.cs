using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

using System.Threading.Tasks;
using Gestion.Colegial.DataAccess.Repositories;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class CargoRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbCargos_List";
            Answer answer = await Read<PR_tbCargos_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbCargos_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Car_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbCargos_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbCargos_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Car_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbCargos_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbCargos obj)
        {
            obj.Car_UsuarioRegistra = 1;
            const string sql = "PR_tbCargos_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Car_Descripcion", DbType = DbType.String, Value = obj.Car_Descripcion},
                new SqlParameter(){ParameterName= "@Car_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Car_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbCargos obj)
        {
            obj.Car_UsuarioModifica = 1;
            const string sql = "PR_tbCargos_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Car_Id", DbType = DbType.Int32, Value = obj.Car_Id},
                new SqlParameter(){ParameterName= "@Car_Descripcion", DbType = DbType.String, Value = obj.Car_Descripcion},
                new SqlParameter(){ParameterName= "@Car_UsuarioModifica", DbType = DbType.Int32, Value = obj.Car_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbCargos_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Car_Descripcion", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<PR_tbCargos_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbCargos_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Car_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
