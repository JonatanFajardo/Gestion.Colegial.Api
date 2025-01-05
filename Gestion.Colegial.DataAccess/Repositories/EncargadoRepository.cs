using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class EncargadoRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbEncargados_List";
            Answer answer = await Read<PR_tbEncargados_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbEncargados_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Enc_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbEncargados_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbEncargados_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Enc_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbEncargados_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbEncargados obj)
        {
            obj.Per.Per_UsuarioRegistra = 1;
            const string sql = "PR_tbEncargados_Insert";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Enc_Ocupacion", DbType = DbType.String, Value = obj.Enc_Ocupacion },
            new SqlParameter(){ParameterName= "@Per_Identidad", DbType = DbType.String, Value = obj.Per.Per_Identidad },
            new SqlParameter(){ParameterName= "@Per_PrimerNombre", DbType = DbType.String, Value = obj.Per.Per_PrimerNombre },
            new SqlParameter(){ParameterName= "@Per_SegundoNombre", DbType = DbType.String, Value = obj.Per.Per_SegundoNombre },
            new SqlParameter(){ParameterName= "@Per_ApellidoPaterno", DbType = DbType.String, Value = obj.Per.Per_ApellidoPaterno },
            new SqlParameter(){ParameterName= "@Per_ApellidoMaterno", DbType = DbType.String, Value = obj.Per.Per_ApellidoMaterno },
            new SqlParameter(){ParameterName= "@Per_FechaNacimiento", DbType = DbType.DateTime, Value = obj.Per.Per_FechaNacimiento },
            new SqlParameter(){ParameterName= "@Per_CorreoElectronico", DbType = DbType.String, Value = obj.Per.Per_CorreoElectronico },
            new SqlParameter(){ParameterName= "@Per_Telefono", DbType = DbType.String, Value = obj.Per.Per_Telefono },
            new SqlParameter(){ParameterName= "@Per_Direccion", DbType = DbType.String, Value = obj.Per.Per_Direccion },
            new SqlParameter(){ParameterName= "@Per_Sexo", DbType = DbType.String, Value = obj.Per.Per_Sexo },
            new SqlParameter(){ParameterName= "@Per_UsuarioRegistra", DbType = DbType.Int32, Value = obj.Per.Per_UsuarioRegistra }
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbEncargados obj)
        {
            obj.Per.Per_UsuarioModifica = 1;
            const string sql = "PR_tbEncargados_Update";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Enc_Id", DbType = DbType.Int32, Value = obj.Enc_Id },
            new SqlParameter(){ParameterName= "@Per_Id", DbType = DbType.Int32, Value = obj.Per.Per_Id },
            new SqlParameter(){ParameterName= "@Enc_Ocupacion", DbType = DbType.String, Value = obj.Enc_Ocupacion },
            new SqlParameter(){ParameterName= "@Per_Identidad", DbType = DbType.String, Value = obj.Per.Per_Identidad },
            new SqlParameter(){ParameterName= "@Per_PrimerNombre", DbType = DbType.String, Value = obj.Per.Per_PrimerNombre },
            new SqlParameter(){ParameterName= "@Per_SegundoNombre", DbType = DbType.String, Value = obj.Per.Per_SegundoNombre },
            new SqlParameter(){ParameterName= "@Per_ApellidoPaterno", DbType = DbType.String, Value = obj.Per.Per_ApellidoPaterno },
            new SqlParameter(){ParameterName= "@Per_ApellidoMaterno", DbType = DbType.String, Value = obj.Per.Per_ApellidoMaterno },
            new SqlParameter(){ParameterName= "@Per_FechaNacimiento", DbType = DbType.DateTime, Value = obj.Per.Per_FechaNacimiento },
            new SqlParameter(){ParameterName= "@Per_CorreoElectronico", DbType = DbType.String, Value = obj.Per.Per_CorreoElectronico },
            new SqlParameter(){ParameterName= "@Per_Telefono", DbType = DbType.String, Value = obj.Per.Per_Telefono },
            new SqlParameter(){ParameterName= "@Per_Direccion", DbType = DbType.String, Value = obj.Per.Per_Direccion },
            new SqlParameter(){ParameterName= "@Per_EsActivo", DbType = DbType.Boolean, Value = obj.Per.Per_EsActivo },
            new SqlParameter(){ParameterName= "@Per_Sexo", DbType = DbType.String, Value = obj.Per.Per_Sexo },
            new SqlParameter(){ParameterName= "@Per_UsuarioModifica", DbType = DbType.Int32, Value = obj.Per.Per_UsuarioModifica }
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbEncargados_Delete";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Enc_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
