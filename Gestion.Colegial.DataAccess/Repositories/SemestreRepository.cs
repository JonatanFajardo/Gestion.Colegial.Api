using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;


namespace Gestion.Colegial.DataAccess.Repositories
{
	public class SemestreRepository : RepositoryBase
	{
		public async Task<Answer> List()
		{
			const string sql = "PR_tbSemestres_List";
			Answer answer = await Read<PR_tbSemestres_ListResult>(sql);
			return answer;
		}

		public async Task<Answer> Find(int id)
		{
			const string sql = "PR_tbSemestres_Find";
			SqlParameter[] sqlParameters = {
				new SqlParameter() { ParameterName = "@Sem_Id", DbType = DbType.Int32, Value = id },
			};
			Answer answer = await Search<PR_tbSemestres_FindResult>(sql, sqlParameters);
			return answer;
		}

		public async Task<Answer> Detail(int id)
		{
			const string sql = "PR_tbSemestres_Detail";
			SqlParameter[] sqlParameters = {
				new SqlParameter() { ParameterName = "@Sem_Id", DbType = DbType.Int32, Value = id },
			};
			Answer answer = await Details<PR_tbSemestres_DetailResult>(sql, sqlParameters, id);
			return answer;
		}

		public async Task<Answer> Create(tbSemestres obj)
		{
			obj.Sem_UsuarioRegistra = 1;
			const string sql = "PR_tbSemestres_Insert";
			SqlParameter[] sqlParameters = {
				new SqlParameter(){ParameterName= "@Sem_Descripcion", DbType = DbType.String, Value = obj.Sem_Descripcion},
				new SqlParameter(){ParameterName= "@Sem_EsActivo", DbType = DbType.String, Value = obj.Sem_EsActivo},
				new SqlParameter(){ParameterName= "@Sem_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Sem_UsuarioRegistra}
			};
			Answer answer = await New(sql, sqlParameters);
			return answer;
		}

		public async Task<Answer> Edit(tbSemestres obj)
		{
			obj.Sem_UsuarioModifica = 1;
			const string sql = "PR_tbSemestres_Update";
			SqlParameter[] sqlParameters = {
				new SqlParameter(){ParameterName= "@Sem_Id", DbType = DbType.Int32, Value = obj.Sem_Id},
				new SqlParameter(){ParameterName= "@Sem_Descripcion", DbType = DbType.String, Value = obj.Sem_Descripcion},
				new SqlParameter(){ParameterName= "@Sem_EsActivo", DbType = DbType.String, Value = obj.Sem_EsActivo},
				new SqlParameter(){ParameterName= "@Sem_UsuarioModifica", DbType = DbType.Int32, Value = obj.Sem_UsuarioModifica}
			};
			Answer answer = await Update(sql, sqlParameters);
			return answer;
		}

		public async Task<Answer> Exist(string value)
		{
			const string sql = "PR_tbSemestres_ExistResult";
			SqlParameter[] sqlParameters = {
				new SqlParameter(){ParameterName= "@Sem_Descripcion", DbType = DbType.String, Value = value}
			};
			Answer answer = await Exist<PR_tbModalidades_ListResult>(sql, sqlParameters);
			return answer;
		}

		public async Task<Answer> Delete(int id)
		{
			const string sql = "PR_tbSemestres_Delete";
			SqlParameter[] sqlParameters = {
				new SqlParameter() { ParameterName = "@Sem_Id", DbType = DbType.Int32, Value = id },
			};
			Answer answer = await Delete(sql, sqlParameters);
			return answer;
		}
	}
}
