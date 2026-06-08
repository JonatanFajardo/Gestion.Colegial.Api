using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class NotasRepository : RepositoryBase, INotasRepository
    {
        public async Task<Answer> List(int Hor_Id, int Par_Id)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Hor_Id", DbType = DbType.Int32, Value = Hor_Id },
                new SqlParameter { ParameterName = "@Par_Id", DbType = DbType.Int32, Value = Par_Id },
            };
            return await SearchAll<NotasCuadernoResult>("app.PR_tbNotas_List", p);
        }

        public async Task<Answer> Cuaderno(int Sec_Id, int Mat_Id, int Par_Id, int Sem_Id, int Anio)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Sec_Id", DbType = DbType.Int32, Value = Sec_Id },
                new SqlParameter { ParameterName = "@Mat_Id", DbType = DbType.Int32, Value = Mat_Id },
                new SqlParameter { ParameterName = "@Par_Id", DbType = DbType.Int32, Value = Par_Id },
                new SqlParameter { ParameterName = "@Sem_Id", DbType = DbType.Int32, Value = Sem_Id },
                new SqlParameter { ParameterName = "@Anio",   DbType = DbType.Int32, Value = Anio },
            };
            return await SearchAll<NotasCuadernoResult>("app.PR_Notas_CuadernoParcial", p);
        }

        public async Task<Answer> Boletin(int Alu_Id, int Sem_Id, int Anio)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Alu_Id", DbType = DbType.Int32, Value = Alu_Id },
                new SqlParameter { ParameterName = "@Sem_Id", DbType = DbType.Int32, Value = Sem_Id },
                new SqlParameter { ParameterName = "@Anio",   DbType = DbType.Int32, Value = Anio },
            };
            return await SearchAll<NotasBoletinResult>("app.PR_Notas_BoletinAlumno", p);
        }

        public async Task<Answer> Insert(int Alu_Id, int Sec_Id, int Mat_Id, int Sem_Id, int Par_Id,
                                         decimal Not_Nota, DateTime Not_Año, int usuarioRegistra)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Alu_Id",              DbType = DbType.Int32,   Value = Alu_Id },
                new SqlParameter { ParameterName = "@Sec_Id",              DbType = DbType.Int32,   Value = Sec_Id },
                new SqlParameter { ParameterName = "@Mat_Id",              DbType = DbType.Int32,   Value = Mat_Id },
                new SqlParameter { ParameterName = "@Sem_Id",              DbType = DbType.Int32,   Value = Sem_Id },
                new SqlParameter { ParameterName = "@Par_Id",              DbType = DbType.Int32,   Value = Par_Id },
                new SqlParameter { ParameterName = "@Not_Nota",            DbType = DbType.Decimal, Value = Not_Nota },
                new SqlParameter { ParameterName = "@Not_Año",             DbType = DbType.Date,    Value = Not_Año },
                new SqlParameter { ParameterName = "@Not_UsuarioRegistra", DbType = DbType.Int32,   Value = usuarioRegistra },
            };
            return await New("app.PR_tbNotas_Insert", p);
        }

        public async Task<Answer> Edit(int Not_Id, decimal Not_Nota, int usuarioModifica)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Not_Id",              DbType = DbType.Int32,   Value = Not_Id },
                new SqlParameter { ParameterName = "@Not_Nota",            DbType = DbType.Decimal, Value = Not_Nota },
                new SqlParameter { ParameterName = "@Not_UsuarioModifica", DbType = DbType.Int32,   Value = usuarioModifica },
            };
            return await Update("app.PR_tbNotas_Update", p);
        }
    }
}
