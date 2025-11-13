using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories.Finanzas
{
    public class FormaPagoRepository : RepositoryBase, IFormaPagoRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "finanza.PR_tbFormasPago_List";
            Answer answer = await Read<PR_tbFormasPago_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "finanza.PR_tbFormasPago_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Fpa_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbFormasPago_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "finanza.PR_tbFormasPago_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Fpa_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbFormasPago_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbFormasPago obj)
        {
            const string sql = "finanza.PR_tbFormasPago_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Fpa_Descripcion", DbType = DbType.String, Value = obj.Fpa_Descripcion },
                new SqlParameter(){ParameterName= "@Fpa_UsuarioRegistra", DbType = DbType.Int32, Value = obj.Fpa_UsuarioRegistra },
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbFormasPago obj)
        {
            const string sql = "finanza.PR_tbFormasPago_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Fpa_Id", DbType = DbType.Int32, Value = obj.Fpa_Id },
                new SqlParameter(){ParameterName= "@Fpa_Descripcion", DbType = DbType.String, Value = obj.Fpa_Descripcion },
                new SqlParameter(){ParameterName= "@Fpa_UsuarioModifica", DbType = DbType.Int32, Value = obj.Fpa_UsuarioModifica },
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "finanza.PR_tbFormasPago_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Fpa_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Dropdown()
        {
            const string sql = "finanza.PR_tbFormasPago_Dropdown";
            Answer answer = await Read<PR_tbFormasPago_DropdownResult>(sql);
            return answer;
        }
    }
}
