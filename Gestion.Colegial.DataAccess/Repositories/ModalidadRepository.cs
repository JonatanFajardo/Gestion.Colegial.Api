using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

using System.Threading.Tasks;
using Gestion.Colegial.DataAccess.Repositories;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class ModalidadRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbModalidades_List";
            Answer answer = await Read<PR_tbModalidades_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbModalidades_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Mda_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbModalidades_FindResult>(sql, sqlParameters);
            return answer;

            //const string sql = "PR_tbModalidades_Find";
            //await db.SaveChangesAsync();
            //if (resultado == null)
            //{
            //    return null;
            //}
            //return resultado;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbModalidades_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Mda_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbModalidades_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbModalidades obj)
        {
            obj.Mda_UsuarioRegistra = 1;
            const string sql = "PR_tbModalidades_Insert";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Mda_Descripcion", DbType = DbType.String, Value = obj.Mda_Descripcion },
            new SqlParameter(){ParameterName= "@Mda_UsuarioRegistra", DbType = DbType.Int32, Value = obj.Mda_UsuarioRegistra }
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbModalidades obj)
        {
            obj.Mda_UsuarioModifica = 1;
            const string sql = "PR_tbModalidades_Update";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Mda_Id", DbType = DbType.Int32, Value = obj.Mda_Id },
            new SqlParameter(){ParameterName= "@Mda_Descripcion", DbType = DbType.String, Value = obj.Mda_Descripcion },
            new SqlParameter(){ParameterName= "@Mda_UsuarioModifica", DbType = DbType.Int32, Value = obj.Mda_UsuarioModifica }
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbModalidades_Exist";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Mda_Descripcion", DbType = DbType.String, Value = value }
            };
            Answer answer = await Exist<PR_tbModalidades_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbModalidades_Delete";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Mda_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
