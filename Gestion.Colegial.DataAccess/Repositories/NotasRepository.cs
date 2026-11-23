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

        /// <summary>
        /// app.PR_tbNotas_Update (script 016) recibe @Not_Calificacion (int) y @UsuarioModifica y responde
        /// CodeResult (1 = guardó). Antes se le mandaban @Not_Nota/@Not_UsuarioModifica y siempre fallaba.
        /// Si el parcial está cerrado el procedimiento lanza THROW 50070 (queda en Answer).
        /// </summary>
        public async Task<Answer> Edit(int Not_Id, decimal Not_Nota, int usuarioModifica)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Not_Id",           DbType = DbType.Int32, Value = Not_Id },
                new SqlParameter { ParameterName = "@Not_Calificacion", DbType = DbType.Int32, Value = (int)Math.Round(Not_Nota, MidpointRounding.AwayFromZero) },
                new SqlParameter { ParameterName = "@UsuarioModifica",  DbType = DbType.Int32, Value = usuarioModifica },
            };
            Answer answer = await Search<PR_tbNotas_UpdateResult>("app.PR_tbNotas_Update", p);
            if (!answer.Access && (answer.Data as PR_tbNotas_UpdateResult)?.CodeResult != 1)
            {
                answer.Access = true;
                answer.Message = "app.PR_tbNotas_Update no guardó la nota (CodeResult 0).";
            }
            return answer;
        }
    }
}
