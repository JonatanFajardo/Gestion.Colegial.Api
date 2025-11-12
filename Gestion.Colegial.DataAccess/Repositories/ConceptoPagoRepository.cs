using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class ConceptoPagoRepository : RepositoryBase, IConceptoPagoRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbConceptosPago_List";
            Answer answer = await Read<PR_tbConceptosPago_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbConceptosPago_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cpa_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbConceptosPago_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbConceptosPago_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cpa_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbConceptosPago_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbConceptosPago obj)
        {
            const string sql = "PR_tbConceptosPago_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cpa_Descripcion", DbType = DbType.String, Value = obj.Cpa_Descripcion },
                new SqlParameter(){ParameterName= "@Cpa_EsRecurrente", DbType = DbType.Boolean, Value = obj.Cpa_EsRecurrente },
                new SqlParameter(){ParameterName= "@Cpa_EsObligatorio", DbType = DbType.Boolean, Value = obj.Cpa_EsObligatorio },
                new SqlParameter(){ParameterName= "@Cpa_UsuarioRegistra", DbType = DbType.Int32, Value = obj.Cpa_UsuarioRegistra },
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbConceptosPago obj)
        {
            const string sql = "PR_tbConceptosPago_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cpa_Id", DbType = DbType.Int32, Value = obj.Cpa_Id },
                new SqlParameter(){ParameterName= "@Cpa_Descripcion", DbType = DbType.String, Value = obj.Cpa_Descripcion },
                new SqlParameter(){ParameterName= "@Cpa_EsRecurrente", DbType = DbType.Boolean, Value = obj.Cpa_EsRecurrente },
                new SqlParameter(){ParameterName= "@Cpa_EsObligatorio", DbType = DbType.Boolean, Value = obj.Cpa_EsObligatorio },
                new SqlParameter(){ParameterName= "@Cpa_UsuarioModifica", DbType = DbType.Int32, Value = obj.Cpa_UsuarioModifica },
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbConceptosPago_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cpa_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Dropdown()
        {
            const string sql = "PR_tbConceptosPago_Dropdown";
            Answer answer = await Read<PR_tbConceptosPago_DropdownResult>(sql);
            return answer;
        }
    }
}
