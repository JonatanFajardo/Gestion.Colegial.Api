using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories.Finanzas
{
    public class TarifaRepository : RepositoryBase, ITarifaRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "finanza.PR_tbTarifas_List";
            Answer answer = await Read<PR_tbTarifas_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "finanza.PR_tbTarifas_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Tar_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbTarifas_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "finanza.PR_tbTarifas_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Tar_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbTarifas_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbTarifas obj)
        {
            const string sql = "finanza.PR_tbTarifas_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cpa_Id", DbType = DbType.Int32, Value = obj.Cpa_Id },
                new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = obj.Niv_Id },
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = (object)obj.Cun_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Tar_Monto", DbType = DbType.Decimal, Value = obj.Tar_Monto },
                new SqlParameter(){ParameterName= "@Tar_AnioVigencia", DbType = DbType.Int32, Value = obj.Tar_AnioVigencia },
                new SqlParameter(){ParameterName= "@Tar_UsuarioRegistra", DbType = DbType.Int32, Value = obj.Tar_UsuarioRegistra },
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbTarifas obj)
        {
            const string sql = "finanza.PR_tbTarifas_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Tar_Id", DbType = DbType.Int32, Value = obj.Tar_Id },
                new SqlParameter(){ParameterName= "@Cpa_Id", DbType = DbType.Int32, Value = obj.Cpa_Id },
                new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = obj.Niv_Id },
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = (object)obj.Cun_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Tar_Monto", DbType = DbType.Decimal, Value = obj.Tar_Monto },
                new SqlParameter(){ParameterName= "@Tar_AnioVigencia", DbType = DbType.Int32, Value = obj.Tar_AnioVigencia },
                new SqlParameter(){ParameterName= "@Tar_UsuarioModifica", DbType = DbType.Int32, Value = obj.Tar_UsuarioModifica },
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "finanza.PR_tbTarifas_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Tar_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> GetByConceptoAndNivel(int conceptoId, int nivelId, int anio)
        {
            const string sql = "finanza.PR_tbTarifas_GetByConceptoAndNivel";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cpa_Id", DbType = DbType.Int32, Value = conceptoId },
                new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = nivelId },
                new SqlParameter(){ParameterName= "@Tar_AnioVigencia", DbType = DbType.Int32, Value = anio },
            };
            Answer answer = await Search<PR_tbTarifas_GetByConceptoAndNivelResult>(sql, sqlParameters);
            return answer;
        }
    }
}
