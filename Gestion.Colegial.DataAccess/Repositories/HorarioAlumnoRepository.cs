using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

using System.Threading.Tasks;
using Gestion.Colegial.DataAccess.Repositories;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class HorarioAlumnoRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbHorarioAlumnos_List";
            Answer answer = await Read<PR_tbHorarioAlumnos_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbHorarioAlumnos_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@HoAl_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Search<PR_tbHorarioAlumnos_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbHorarioAlumnos_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@HoAl_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Details<PR_tbHorarioAlumnos_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbHorarioAlumnos obj)
        {
            obj.HoAl_UsuarioRegistra = 1;
            const string sql = "PR_tbHorarioAlumnos_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = obj.Cur_Id},
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = obj.Cun_Id},
                new SqlParameter(){ParameterName= "@Mat_Id", DbType = DbType.Int32, Value = obj.Mat_Id},
                new SqlParameter(){ParameterName= "@HoAl_HoraInicio", DbType = DbType.Int32, Value = obj.HoAl_HoraInicio},
                new SqlParameter(){ParameterName= "@HoAl_HoraFinaliza", DbType = DbType.Int32, Value = obj.HoAl_HoraFinaliza},
                new SqlParameter(){ParameterName= "@Dia_Id", DbType = DbType.Int32, Value = obj.Dia_Id},
                new SqlParameter(){ParameterName= "@HoAl_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.HoAl_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbHorarioAlumnos obj)
        {
            obj.HoAl_UsuarioModifica = 1;
            const string sql = "PR_tbHorarioAlumnos_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@HoAl_Id", DbType = DbType.Int32, Value = obj.HoAl_Id},
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = obj.Cur_Id},
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = obj.Cun_Id},
                new SqlParameter(){ParameterName= "@Mat_Id", DbType = DbType.Int32, Value = obj.Mat_Id},
                new SqlParameter(){ParameterName= "@HoAl_HoraInicio", DbType = DbType.Int32, Value = obj.HoAl_HoraInicio},
                new SqlParameter(){ParameterName= "@HoAl_HoraFinaliza", DbType = DbType.Int32, Value = obj.HoAl_HoraFinaliza},
                new SqlParameter(){ParameterName= "@Dia_Id", DbType = DbType.Int32, Value = obj.Dia_Id},
                new SqlParameter(){ParameterName= "@HoAl_UsuarioModifica", DbType = DbType.Int32, Value = obj.HoAl_UsuarioModifica},
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbHorarioAlumnos_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@HoAl_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
