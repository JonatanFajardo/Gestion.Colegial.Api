using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class AsistenciaRepository : RepositoryBase, IAsistenciaRepository
    {
        public async Task<Answer> List(int Hor_Id, DateTime Fecha)
        {
            const string sql = "app.PR_tbAsistencia_List";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Hor_Id", DbType = DbType.Int32,   Value = Hor_Id },
                new SqlParameter { ParameterName = "@Fecha",  DbType = DbType.Date,    Value = Fecha },
            };
            return await SearchAll<PR_tbAsistencia_ListResult>(sql, parameters);
        }

        public async Task<Answer> Horarios(int Usu_Id, DateTime Fecha, int? Niv_Id, int? Cun_Id, int? Sec_Id)
        {
            const string sql = "app.PR_Asistencia_Horarios";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Usu_Id", DbType = DbType.Int32, Value = Usu_Id },
                new SqlParameter { ParameterName = "@Fecha",  DbType = DbType.Date,  Value = Fecha },
                new SqlParameter { ParameterName = "@Niv_Id", DbType = DbType.Int32, Value = (object)Niv_Id ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Cun_Id", DbType = DbType.Int32, Value = (object)Cun_Id ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Sec_Id", DbType = DbType.Int32, Value = (object)Sec_Id ?? DBNull.Value },
            };
            return await SearchAll<PR_Asistencia_HorariosResult>(sql, parameters);
        }

        public async Task<Answer> Puede(int Usu_Id, int Hor_Id, DateTime Fecha)
        {
            const string sql = "app.PR_Asistencia_Puede";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Usu_Id", DbType = DbType.Int32, Value = Usu_Id },
                new SqlParameter { ParameterName = "@Hor_Id", DbType = DbType.Int32, Value = Hor_Id },
                new SqlParameter { ParameterName = "@Fecha",  DbType = DbType.Date,  Value = Fecha },
            };
            return await SearchAll<PR_Asistencia_PuedeResult>(sql, parameters);
        }

        public async Task<Answer> ByAlumno(int Alu_Id, int? Anio)
        {
            const string sql = "app.PR_tbAsistencia_ByAlumno";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Alu_Id", DbType = DbType.Int32,   Value = Alu_Id },
                new SqlParameter { ParameterName = "@Anio",   DbType = DbType.Int32,   Value = (object)Anio ?? DBNull.Value },
            };
            return await SearchAll<PR_tbAsistencia_ByAlumnoResult>(sql, parameters);
        }

        public async Task<Answer> Insert(int Hor_Id, int Alu_Id, DateTime Asi_Fecha, string Asi_Estado, string Asi_Observacion, int usuarioRegistra)
        {
            const string sql = "app.PR_tbAsistencia_Insert";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Hor_Id",              DbType = DbType.Int32,   Value = Hor_Id },
                new SqlParameter { ParameterName = "@Alu_Id",              DbType = DbType.Int32,   Value = Alu_Id },
                new SqlParameter { ParameterName = "@Asi_Fecha",           DbType = DbType.Date,    Value = Asi_Fecha },
                new SqlParameter { ParameterName = "@Asi_Estado",          DbType = DbType.String,  Value = Asi_Estado },
                new SqlParameter { ParameterName = "@Asi_Observacion",     DbType = DbType.String,  Value = (object)Asi_Observacion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Asi_UsuarioRegistra", DbType = DbType.Int32,   Value = usuarioRegistra },
            };
            return await New(sql, parameters);
        }

        public async Task<Answer> Update(int Asi_Id, string Asi_Estado, string Asi_Observacion, int usuarioModifica)
        {
            const string sql = "app.PR_tbAsistencia_Update";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Asi_Id",              DbType = DbType.Int32,   Value = Asi_Id },
                new SqlParameter { ParameterName = "@Asi_Estado",          DbType = DbType.String,  Value = Asi_Estado },
                new SqlParameter { ParameterName = "@Asi_Observacion",     DbType = DbType.String,  Value = (object)Asi_Observacion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Asi_UsuarioModifica", DbType = DbType.Int32,   Value = usuarioModifica },
            };
            return await Update(sql, parameters);
        }
    }
}
