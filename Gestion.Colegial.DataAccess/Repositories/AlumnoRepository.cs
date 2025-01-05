using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class AlumnoRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbAlumnos_List";
            Answer answer = await Read<PR_tbAlumnos_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbAlumnos_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbAlumnos_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbAlumnos_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbAlumnos_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbAlumnos obj)
        {
            obj.Per.Per_UsuarioRegistra = 1;
            const string sql = "PR_tbAlumnos_Insert";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = obj.Niv_Id },
            new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = obj.Cun_Id },
            new SqlParameter(){ParameterName= "@Mda_Id", DbType = DbType.Int32, Value = obj.Mda_Id },
            new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = obj.Cur_Id },
            new SqlParameter(){ParameterName= "@Sec_Id", DbType = DbType.Int32, Value = obj.Sec_Id },
            new SqlParameter(){ParameterName= "@Est_Id", DbType = DbType.Int32, Value = obj.Est_Id },
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

        public async Task<Answer> Edit(tbAlumnos obj)
        {
            obj.Per.Per_UsuarioModifica = 1;
            const string sql = "PR_tbAlumnos_Update";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = obj.Alu_Id },
            new SqlParameter(){ParameterName= "@Per_Id", DbType = DbType.Int32, Value = obj.Per_Id },
            new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = obj.Niv_Id },
            new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = obj.Cun_Id },
            new SqlParameter(){ParameterName= "@Mda_Id", DbType = DbType.Int32, Value = obj.Mda_Id },
            new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = obj.Cur_Id },
            new SqlParameter(){ParameterName= "@Sec_Id", DbType = DbType.Int32, Value = obj.Sec_Id },
            new SqlParameter(){ParameterName= "@Est_Id", DbType = DbType.String, Value = obj.Est_Id },
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
            new SqlParameter(){ParameterName= "@Per_UsuarioModifica", DbType = DbType.Int32, Value = obj.Per.Per_UsuarioModifica }
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbAlumnos_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> NivelesEducativosDropdown()
        {
            const string sql = "PR_tbNivelesEducativos_Dropdown";
            Answer answer = await Read<PR_tbNivelesEducativos_DropdownResult>(sql);
            return answer;
        }

        public async Task<Answer> CursosNivelesDropdown(int id)
        {
            const string sql = "PR_tbCursosNiveles_By_tbNivelesEducativos_Dropdown";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Read<PR_tbCursosNiveles_DropdownResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> ModalidadesDropdown(int id)
        {
            const string sql = "PR_tbModalidades_By_tbCursosNiveles_Dropdown";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Read<PR_tbModalidades_DropdownResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> CursosDropdown(int id)
        {
            const string sql = "PR_tbCursos_By_tbModalidades_Dropdown";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Mda_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Read<PR_tbCursos_DropdownResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> SeccionesDropdown(int id)
        {
            const string sql = "PR_tbSecciones_By_tbCursos_Dropdown";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Read<PR_tbSecciones_DropdownResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> EstadosDropdown()
        {
            const string sql = "PR_tbEstados_Dropdown";
            Answer answer = await Read<PR_tbEstados_DropdownResult>(sql);
            return answer;
        }
    }
}
