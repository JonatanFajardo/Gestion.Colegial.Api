using System;
using Gestion.Colegial.DataAccess.Extensions;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class Ficha360EmpleadoRepository : RepositoryBase, IFicha360EmpleadoRepository
    {
        public async Task<Answer> Resumen(int Emp_Id)
        {
            var answer = new Answer();
            try
            {
                using var con = new SqlConnection(Connection.GetConnectionString());
                using var cmd = new SqlCommand("app.PR_Empleados_Ficha360", con);
                cmd.CommandType = CommandType.StoredProcedure;
                SqlParameter[] sqlParams =
                {
                new SqlParameter { ParameterName = "@Emp_Id", DbType = DbType.Int32, Value = Emp_Id },
                };
                cmd.Parameters.AddRange(sqlParams);
                con.Open();
                using var reader = await cmd.ExecuteReaderAsync();
                var dt1 = new DataTable(); dt1.Load(reader);
                reader.NextResult();
                var dt2 = new DataTable(); dt2.Load(reader);
                reader.NextResult();
                var dt3 = new DataTable(); dt3.Load(reader);
                answer.Data = new Ficha360EmpleadoResult
                {
                    DatosPersonales = Mapear.Convert.ToList<Ficha360Empleado_DatosPersonalesResult>(dt1).FirstOrDefault(),
                    ClasesAsignadas = Mapear.Convert.ToList<Ficha360Empleado_ClasesAsignadasResult>(dt2),
                    HistorialVacaciones = Mapear.Convert.ToList<Ficha360Empleado_HistorialVacacionesResult>(dt3),
                };
                answer.Access = false;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Incidents(e);
            }
            return answer;
        }
    }
}
