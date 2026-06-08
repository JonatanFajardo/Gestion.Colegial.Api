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
    public class DashboardDocenteRepository : RepositoryBase, IDashboardDocenteRepository
    {
        public async Task<Answer> Resumen(int Emp_Id, int Dia_Id, int Anio)
        {
            var answer = new Answer();
            try
            {
                using var con = new SqlConnection(Connection.GetConnectionString());
                using var cmd = new SqlCommand("app.PR_DashboardDocente_Hoy", con);
                cmd.CommandType = CommandType.StoredProcedure;
            SqlParameter[] sqlParams =
            {
                new SqlParameter { ParameterName = "@Emp_Id", DbType = DbType.Int32, Value = Emp_Id },
                new SqlParameter { ParameterName = "@Dia_Id", DbType = DbType.Int32, Value = Dia_Id },
                new SqlParameter { ParameterName = "@Anio", DbType = DbType.Int32, Value = Anio },
            };
            cmd.Parameters.AddRange(sqlParams);
                con.Open();
                using var reader = await cmd.ExecuteReaderAsync();
                var dt1 = new DataTable(); dt1.Load(reader);
                reader.NextResult();
                var dt2 = new DataTable(); dt2.Load(reader);
                answer.Data = new DashboardDocenteResult
                {
                    ClasesHoy = Mapear.Convert.ToList<DashboardDocente_ClasesHoyResult>(dt1),
                    KpisDocente = Mapear.Convert.ToList<DashboardDocente_KpisDocenteResult>(dt2).FirstOrDefault(),
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
