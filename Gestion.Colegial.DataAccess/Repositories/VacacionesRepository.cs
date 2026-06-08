using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class VacacionesRepository : RepositoryBase, IVacacionesRepository
    {
        public async Task<Answer> List(int? Emp_Id)
        {
            const string sql = "app.PR_tbVacaciones_List";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Emp_Id", DbType = DbType.Int32, Value = (object)Emp_Id ?? DBNull.Value },
            };
            return await SearchAll<PR_tbVacaciones_ListResult>(sql, parameters);
        }

        public async Task<Answer> Insert(int Emp_Id, string Vac_Tipo, DateTime Vac_FechaInicio, DateTime Vac_FechaFin, string Vac_Motivo, int usuarioRegistra)
        {
            const string sql = "app.PR_tbVacaciones_Insert";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Emp_Id",              DbType = DbType.Int32,   Value = Emp_Id },
                new SqlParameter { ParameterName = "@Vac_Tipo",            DbType = DbType.String,  Value = Vac_Tipo },
                new SqlParameter { ParameterName = "@Vac_FechaInicio",     DbType = DbType.Date,    Value = Vac_FechaInicio },
                new SqlParameter { ParameterName = "@Vac_FechaFin",        DbType = DbType.Date,    Value = Vac_FechaFin },
                new SqlParameter { ParameterName = "@Vac_Motivo",          DbType = DbType.String,  Value = (object)Vac_Motivo ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Vac_UsuarioRegistra", DbType = DbType.Int32,   Value = usuarioRegistra },
            };
            return await New(sql, parameters);
        }

        public async Task<Answer> Approve(int Vac_Id, string Vac_Estado, int usuarioModifica)
        {
            const string sql = "app.PR_tbVacaciones_Update";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Vac_Id",              DbType = DbType.Int32,  Value = Vac_Id },
                new SqlParameter { ParameterName = "@Vac_Estado",          DbType = DbType.String, Value = Vac_Estado },
                new SqlParameter { ParameterName = "@Vac_UsuarioModifica", DbType = DbType.Int32,  Value = usuarioModifica },
            };
            return await Update(sql, parameters);
        }

        public async Task<Answer> Delete(int Vac_Id, int usuarioModifica)
        {
            const string sql = "app.PR_tbVacaciones_Delete";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Vac_Id",              DbType = DbType.Int32, Value = Vac_Id },
                new SqlParameter { ParameterName = "@Vac_UsuarioModifica", DbType = DbType.Int32, Value = usuarioModifica },
            };
            return await Delete(sql, parameters);
        }
    }
}
