using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class CumplimientoDocumentosRepository : RepositoryBase, ICumplimientoDocumentosRepository
    {
        public async Task<Answer> List(int? Emp_Id)
        {
            const string sql = "app.PR_Empleados_CumplimientoDocumentos";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Emp_Id", DbType = DbType.Int32, Value = (object)Emp_Id ?? System.DBNull.Value },
            };
            return await SearchAll<CumplimientoDocumentosResult>(sql, parameters);
        }

        public async Task<Answer> MarcarEntregado(int Emp_Id, string Documento, bool EsEntregado, DateTime? FechaEntrega, DateTime? Doc_FechaVencimiento, string Observacion, int usuarioRegistra)
        {
            const string sql = "app.PR_DocumentosEmpleado_MarcarEntregado";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Emp_Id",              DbType = DbType.Int32,    Value = Emp_Id },
                new SqlParameter { ParameterName = "@Documento",           DbType = DbType.String,   Value = Documento },
                new SqlParameter { ParameterName = "@EsEntregado",         DbType = DbType.Boolean,  Value = EsEntregado },
                new SqlParameter { ParameterName = "@FechaEntrega",        DbType = DbType.Date,     Value = (object)FechaEntrega ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Doc_FechaVencimiento",DbType = DbType.DateTime, Value = (object)Doc_FechaVencimiento ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Observacion",         DbType = DbType.String,   Value = (object)Observacion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@UsuarioRegistra",     DbType = DbType.Int32,    Value = usuarioRegistra },
            };
            return await Update(sql, parameters);
        }
    }
}
