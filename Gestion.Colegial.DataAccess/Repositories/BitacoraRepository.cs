using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class BitacoraRepository : RepositoryBase, IBitacoraRepository
    {
        public async Task<Answer> List(int? Usu_Id, string Bit_Tabla, int? Top)
        {
            const string sql = "seguridad.UDP_tbBitacora_List";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Usu_Id",    DbType = DbType.Int32,  Value = (object)Usu_Id    ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Bit_Tabla", DbType = DbType.String, Value = (object)Bit_Tabla  ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Top",       DbType = DbType.Int32,  Value = (object)Top        ?? DBNull.Value },
            };
            return await SearchAll<UDP_tbBitacora_ListResult>(sql, parameters);
        }

        public async Task<Answer> Insert(int Usu_Id, string Bit_Accion, string Bit_Tabla, int? Bit_RegistroId, string Bit_Descripcion, string Bit_Ip)
        {
            const string sql = "seguridad.UDP_tbBitacora_Insert";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Usu_Id",        DbType = DbType.Int32,  Value = Usu_Id },
                new SqlParameter { ParameterName = "@Bit_Accion",    DbType = DbType.String, Value = Bit_Accion },
                new SqlParameter { ParameterName = "@Bit_Tabla",     DbType = DbType.String, Value = (object)Bit_Tabla     ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Bit_RegistroId",DbType = DbType.Int32,  Value = (object)Bit_RegistroId?? DBNull.Value },
                new SqlParameter { ParameterName = "@Bit_Descripcion",DbType = DbType.String,Value = (object)Bit_Descripcion?? DBNull.Value },
                new SqlParameter { ParameterName = "@Bit_Ip",        DbType = DbType.String, Value = (object)Bit_Ip        ?? DBNull.Value },
            };
            return await New(sql, parameters);
        }
    }
}
