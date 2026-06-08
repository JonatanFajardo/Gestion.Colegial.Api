using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class DocumentosAlumnoRepository : RepositoryBase, IDocumentosAlumnoRepository
    {
        public async Task<Answer> List(int Alu_Id)
        {
            const string sql = "app.PR_tbDocumentosAlumno_List";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Alu_Id", DbType = DbType.Int32, Value = Alu_Id },
            };
            return await SearchAll<PR_tbDocumentosAlumno_ListResult>(sql, parameters);
        }

        public async Task<Answer> PendientesList()
        {
            const string sql = "app.PR_tbDocumentosAlumno_PendientesList";
            return await Read<PR_tbDocumentosAlumno_PendientesListResult>(sql);
        }

        public async Task<Answer> Update(int Alu_Id, int TDoc_Id, bool Doa_EsEntregado, DateTime? Doa_FechaEntrega, string Doa_Observacion, int usuarioRegistra)
        {
            const string sql = "app.PR_tbDocumentosAlumno_Update";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Alu_Id",              DbType = DbType.Int32,   Value = Alu_Id },
                new SqlParameter { ParameterName = "@TDoc_Id",             DbType = DbType.Int32,   Value = TDoc_Id },
                new SqlParameter { ParameterName = "@Doa_EsEntregado",     DbType = DbType.Boolean, Value = Doa_EsEntregado },
                new SqlParameter { ParameterName = "@Doa_FechaEntrega",    DbType = DbType.Date,    Value = (object)Doa_FechaEntrega ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Doa_Observacion",     DbType = DbType.String,  Value = (object)Doa_Observacion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Doa_UsuarioRegistra", DbType = DbType.Int32,   Value = usuarioRegistra },
            };
            return await Update(sql, parameters);
        }
    }
}
