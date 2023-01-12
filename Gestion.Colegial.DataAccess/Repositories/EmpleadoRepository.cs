using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

using System.Threading.Tasks;
using Gestion.Colegial.DataAccess.Repositories;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class EmpleadoRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbEmpleados_List";
            Answer answer = await Read<PR_tbEmpleados_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbEmpleados_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Emp_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbEmpleados_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbEmpleados_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Emp_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbEmpleados_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbEmpleados obj)
        {
            obj.Per.Per_UsuarioRegistra = 1;
            const string sql = "PR_tbEmpleados_Insert";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Emp_Codigo", DbType = DbType.String, Value = obj.Emp_Codigo },
            new SqlParameter(){ParameterName= "@Tit_Id", DbType = DbType.Int32, Value = obj.Tit_Id },
            new SqlParameter(){ParameterName= "@Car_Id", DbType = DbType.Int32, Value = obj.Car_Id },
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

        public async Task<Answer> Edit(tbEmpleados obj)
        {
            obj.Per.Per_UsuarioModifica = 1;
            const string sql = "PR_tbEmpleados_Update";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Emp_Id", DbType = DbType.Int32, Value = obj.Emp_Id },
            new SqlParameter(){ParameterName= "@Per_Id", DbType = DbType.Int32, Value = obj.Per.Per_Id },
            new SqlParameter(){ParameterName= "@Emp_Codigo", DbType = DbType.String, Value = obj.Emp_Codigo },
            new SqlParameter(){ParameterName= "@Tit_Id", DbType = DbType.Int32, Value = obj.Tit_Id },
            new SqlParameter(){ParameterName= "@Car_Id", DbType = DbType.Int32, Value = obj.Car_Id },
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

        //public async Task<Answer> Exist(string value)
        //{
        //    const string sql = "PR_tbEmpleados_Exist";
        //    SqlParameter[] sqlParameters = {
        //    new SqlParameter(){ParameterName= "@Emp_Descripcion", DbType = DbType.String, Value = value }
        //    };
        //    Answer answer = await Exist<PR_tbEmpleados_ExistResult>(sql, sqlParameters);
        //    return answer;
        //}

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbEmpleados_Delete";
            SqlParameter[] sqlParameters = {
            new SqlParameter(){ParameterName= "@Emp_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> TitulosDropdown()
        {
            const string sql = "PR_tbTitulos_Dropdown";
            Answer answer = await Read<PR_tbTitulos_DropdownResult>(sql);
            return answer;
        }

        public async Task<Answer> CargosDropdown()
        {
            const string sql = "PR_tbCargos_Dropdown";
            Answer answer = await Read<PR_tbCargos_DropdownResult>(sql);
            return answer;
        }

        public async Task<Answer> ModalidadesDropdown()
        {
            const string sql = "PR_tbModalidades_Dropdown";
            Answer answer = await Read<PR_tbModalidades_DropdownResult>(sql);
            return answer;
        }
    }
}
