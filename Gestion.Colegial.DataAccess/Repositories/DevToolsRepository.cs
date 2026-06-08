using Gestion.Colegial.DataAccess.Extensions;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class DevToolsRepository : RepositoryBase, IDevToolsRepository
    {
        public async Task<Answer> Detectar(int? AnioObjetivo)
        {
            const string sql = "dbo.PR_ActualizarFechas_Detectar";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@AnioObjetivo", DbType = DbType.Int32, Value = (object)AnioObjetivo ?? DBNull.Value },
            };
            return await SearchAll<PR_ActualizarFechas_DetectarResult>(sql, parameters);
        }

        public async Task<Answer> Paso(string Tabla, int Delta)
        {
            const string sql = "dbo.PR_ActualizarFechas_Paso";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Tabla", DbType = DbType.String, Value = Tabla },
                new SqlParameter { ParameterName = "@Delta", DbType = DbType.Int32,  Value = Delta },
            };
            return await SearchAll<PR_ActualizarFechas_PasoResult>(sql, parameters);
        }

        public async Task<Answer> EstadoBD()
        {
            const string sql = "dbo.PR_DevTools_EstadoBD";
            return await SearchAll<PR_DevTools_EstadoBDResult>(sql, new SqlParameter[0]);
        }

        public async Task<Answer> ListarRoles()
        {
            var answer = new Answer();
            try
            {
                const string sql = @"
                    SELECT r.Rol_Id, r.Rol_Descripcion, COUNT(rp.Pan_Id) AS CantidadPantallas
                    FROM Seguridad.tbRoles r
                    LEFT JOIN Seguridad.tbRolesPantallas rp ON rp.Rol_Id = r.Rol_Id
                    WHERE r.Rol_EsEliminado = 0
                    GROUP BY r.Rol_Id, r.Rol_Descripcion
                    ORDER BY r.Rol_Id";

                using var con = new SqlConnection(Connection.GetConnectionString());
                using var cmd = new SqlCommand(sql, con) { CommandType = CommandType.Text };
                con.Open();
                using var reader = await cmd.ExecuteReaderAsync();
                var dt = new DataTable();
                dt.Load(reader);
                answer.Data = Mapear.Convert.ToList<PR_DevTools_RolPantallaResult>(dt);
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
