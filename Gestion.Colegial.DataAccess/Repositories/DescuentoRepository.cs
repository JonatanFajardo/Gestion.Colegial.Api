using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class DescuentoRepository : RepositoryBase, IDescuentoRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbDescuentos_List";
            Answer answer = await Read<PR_tbDescuentos_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbDescuentos_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Des_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbDescuentos_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbDescuentos_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Des_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbDescuentos_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbDescuentos obj)
        {
            const string sql = "PR_tbDescuentos_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Des_Descripcion", DbType = DbType.String, Value = obj.Des_Descripcion },
                new SqlParameter(){ParameterName= "@Des_TipoDescuento", DbType = DbType.String, Value = obj.Des_TipoDescuento },
                new SqlParameter(){ParameterName= "@Des_Valor", DbType = DbType.Decimal, Value = obj.Des_Valor },
                new SqlParameter(){ParameterName= "@Des_UsuarioRegistra", DbType = DbType.Int32, Value = obj.Des_UsuarioRegistra },
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbDescuentos obj)
        {
            const string sql = "PR_tbDescuentos_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Des_Id", DbType = DbType.Int32, Value = obj.Des_Id },
                new SqlParameter(){ParameterName= "@Des_Descripcion", DbType = DbType.String, Value = obj.Des_Descripcion },
                new SqlParameter(){ParameterName= "@Des_TipoDescuento", DbType = DbType.String, Value = obj.Des_TipoDescuento },
                new SqlParameter(){ParameterName= "@Des_Valor", DbType = DbType.Decimal, Value = obj.Des_Valor },
                new SqlParameter(){ParameterName= "@Des_UsuarioModifica", DbType = DbType.Int32, Value = obj.Des_UsuarioModifica },
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbDescuentos_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Des_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Dropdown()
        {
            const string sql = "PR_tbDescuentos_Dropdown";
            Answer answer = await Read<PR_tbDescuentos_DropdownResult>(sql);
            return answer;
        }
    }
}
