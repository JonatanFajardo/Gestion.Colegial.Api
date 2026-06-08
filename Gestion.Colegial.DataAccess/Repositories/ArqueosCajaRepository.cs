using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class ArqueosCajaRepository : RepositoryBase, IArqueosCajaRepository
    {
        public async Task<Answer> Find(int Arq_Id)
        {
            const string sql = "finanza.PR_tbArqueosCaja_Find";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Arq_Id", DbType = DbType.Int32, Value = Arq_Id },
            };
            return await Search<PR_tbArqueosCaja_FindResult>(sql, parameters);
        }

        public async Task<Answer> LastByUsuario(int Usu_Id)
        {
            const string sql = "finanza.PR_tbArqueosCaja_LastByUsuario";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Usu_Id", DbType = DbType.Int32, Value = Usu_Id },
            };
            return await SearchAll<PR_tbArqueosCaja_LastResult>(sql, parameters);
        }

        public async Task<Answer> Insert(int Usu_Id, DateTime Arq_Fecha, decimal Arq_TotalEfectivo, decimal Arq_TotalTransferencia, decimal Arq_TotalTarjeta, string Arq_Observaciones, int usuarioRegistra)
        {
            const string sql = "finanza.PR_tbArqueosCaja_Insert";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Usu_Id",                 DbType = DbType.Int32,   Value = Usu_Id },
                new SqlParameter { ParameterName = "@Arq_Fecha",              DbType = DbType.Date,    Value = Arq_Fecha },
                new SqlParameter { ParameterName = "@Arq_TotalEfectivo",      DbType = DbType.Decimal, Value = Arq_TotalEfectivo },
                new SqlParameter { ParameterName = "@Arq_TotalTransferencia", DbType = DbType.Decimal, Value = Arq_TotalTransferencia },
                new SqlParameter { ParameterName = "@Arq_TotalTarjeta",       DbType = DbType.Decimal, Value = Arq_TotalTarjeta },
                new SqlParameter { ParameterName = "@Arq_Observaciones",      DbType = DbType.String,  Value = (object)Arq_Observaciones ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Arq_UsuarioRegistra",    DbType = DbType.Int32,   Value = usuarioRegistra },
            };
            return await New(sql, parameters);
        }
    }
}
