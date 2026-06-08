using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class AsistenciaEmpleadosRepository : RepositoryBase, IAsistenciaEmpleadosRepository
    {
        public async Task<Answer> List(int? Emp_Id, DateTime? Fecha)
        {
            const string sql = "app.PR_Empleados_Asistencia_List";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Emp_Id", DbType = DbType.Int32,   Value = (object)Emp_Id ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Fecha",  DbType = DbType.Date,    Value = (object)Fecha  ?? DBNull.Value },
            };
            return await SearchAll<PR_Empleados_Asistencia_ListResult>(sql, parameters);
        }

        public async Task<Answer> Insert(int Emp_Id, DateTime AsiEmp_Fecha, string AsiEmp_Estado, string AsiEmp_Observacion, int usuarioRegistra)
        {
            const string sql = "app.PR_Empleados_Asistencia_Insert";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Emp_Id",                 DbType = DbType.Int32,  Value = Emp_Id },
                new SqlParameter { ParameterName = "@AsiEmp_Fecha",           DbType = DbType.Date,   Value = AsiEmp_Fecha },
                new SqlParameter { ParameterName = "@AsiEmp_Estado",          DbType = DbType.String, Value = AsiEmp_Estado },
                new SqlParameter { ParameterName = "@AsiEmp_Observacion",     DbType = DbType.String, Value = (object)AsiEmp_Observacion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@AsiEmp_UsuarioRegistra", DbType = DbType.Int32,  Value = usuarioRegistra },
            };
            return await New(sql, parameters);
        }
    }
}
