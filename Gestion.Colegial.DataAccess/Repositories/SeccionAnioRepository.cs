using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class SeccionAnioRepository : RepositoryBase, ISeccionAnioRepository
    {
        public async Task<Answer> List(int aniId)
        {
            const string sql = "app.PR_tbSeccionesAnio_List";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = aniId },
            };
            Answer answer = await Read<PR_tbSeccionesAnio_ListResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "app.PR_tbSeccionesAnio_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@value", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbSeccionesAnio_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Create(tbSeccionesAnio obj)
        {
            obj.Sea_UsuarioRegistra = 1;
            const string sql = "app.PR_tbSeccionesAnio_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = obj.Ani_Id },
                new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = obj.Niv_Id },
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = obj.Cun_Id },
                new SqlParameter(){ParameterName= "@Sec_Id", DbType = DbType.Int32, Value = obj.Sec_Id },
                new SqlParameter(){ParameterName= "@Mda_Id", DbType = DbType.Int32, Value = (object)obj.Mda_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Emp_Id", DbType = DbType.Int32, Value = (object)obj.Emp_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Sea_Nombre", DbType = DbType.String, Value = (object)obj.Sea_Nombre ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Sea_Cupo", DbType = DbType.Int32, Value = (object)obj.Sea_Cupo ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Sea_Estado", DbType = DbType.Byte, Value = obj.Sea_Estado == 0 ? (byte)2 : obj.Sea_Estado },
                new SqlParameter(){ParameterName= "@Sea_UsuarioRegistra", DbType = DbType.Int32, Value = (object)obj.Sea_UsuarioRegistra ?? DBNull.Value }
            };
            Answer answer = await NewWithId<PR_tbSeccionesAnio_InsertResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbSeccionesAnio obj)
        {
            obj.Sea_UsuarioModifica = 1;
            const string sql = "app.PR_tbSeccionesAnio_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Sea_Id", DbType = DbType.Int32, Value = obj.Sea_Id },
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = obj.Ani_Id },
                new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = obj.Niv_Id },
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = obj.Cun_Id },
                new SqlParameter(){ParameterName= "@Sec_Id", DbType = DbType.Int32, Value = obj.Sec_Id },
                new SqlParameter(){ParameterName= "@Mda_Id", DbType = DbType.Int32, Value = (object)obj.Mda_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Emp_Id", DbType = DbType.Int32, Value = (object)obj.Emp_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Sea_Nombre", DbType = DbType.String, Value = (object)obj.Sea_Nombre ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Sea_Cupo", DbType = DbType.Int32, Value = (object)obj.Sea_Cupo ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Sea_Estado", DbType = DbType.Byte, Value = obj.Sea_Estado == 0 ? (byte)2 : obj.Sea_Estado },
                new SqlParameter(){ParameterName= "@Sea_UsuarioModifica", DbType = DbType.Int32, Value = (object)obj.Sea_UsuarioModifica ?? DBNull.Value }
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "app.PR_tbSeccionesAnio_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Sea_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
