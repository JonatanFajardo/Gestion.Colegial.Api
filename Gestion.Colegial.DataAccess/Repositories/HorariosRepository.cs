using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class HorariosRepository : RepositoryBase, IHorariosRepository
    {
        public async Task<Answer> List()
        {
            return await Read<HorariosResult>("app.PR_tbHorarios_List");
        }

        public async Task<Answer> Find(int Hor_Id)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Hor_Id", DbType = DbType.Int32, Value = Hor_Id },
            };
            return await Search<HorariosResult>("app.PR_tbHorarios_Find", p);
        }

        public async Task<Answer> Insert(int Cur_Id, int Cun_Id, int Mat_Id, int Emp_Id, int Sec_Id,
            int Aul_Id, int Dia_Id, int Hor_HoraInicio, int Hor_HoraFinaliza, int Sem_Id,
            int? Mda_Id, int Hor_Año, int usuarioRegistra)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Cur_Id",              DbType = DbType.Int32, Value = Cur_Id },
                new SqlParameter { ParameterName = "@Cun_Id",              DbType = DbType.Int32, Value = Cun_Id },
                new SqlParameter { ParameterName = "@Mat_Id",              DbType = DbType.Int32, Value = Mat_Id },
                new SqlParameter { ParameterName = "@Emp_Id",              DbType = DbType.Int32, Value = Emp_Id },
                new SqlParameter { ParameterName = "@Sec_Id",              DbType = DbType.Int32, Value = Sec_Id },
                new SqlParameter { ParameterName = "@Aul_Id",              DbType = DbType.Int32, Value = Aul_Id },
                new SqlParameter { ParameterName = "@Dia_Id",              DbType = DbType.Int32, Value = Dia_Id },
                new SqlParameter { ParameterName = "@Hor_HoraInicio",      DbType = DbType.Int32, Value = Hor_HoraInicio },
                new SqlParameter { ParameterName = "@Hor_HoraFinaliza",    DbType = DbType.Int32, Value = Hor_HoraFinaliza },
                new SqlParameter { ParameterName = "@Sem_Id",              DbType = DbType.Int32, Value = Sem_Id },
                new SqlParameter { ParameterName = "@Mda_Id",              DbType = DbType.Int32, Value = (object)Mda_Id ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@Hor_Año",             DbType = DbType.Int32, Value = Hor_Año },
                new SqlParameter { ParameterName = "@Hor_UsuarioRegistra", DbType = DbType.Int32, Value = usuarioRegistra },
            };
            return await New("app.PR_tbHorarios_Insert", p);
        }

        public async Task<Answer> Edit(int Hor_Id, int Cur_Id, int Cun_Id, int Mat_Id, int Emp_Id,
            int Sec_Id, int Aul_Id, int Dia_Id, int Hor_HoraInicio, int Hor_HoraFinaliza,
            int Sem_Id, int? Mda_Id, int Hor_Año, int usuarioModifica)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Hor_Id",              DbType = DbType.Int32, Value = Hor_Id },
                new SqlParameter { ParameterName = "@Cur_Id",              DbType = DbType.Int32, Value = Cur_Id },
                new SqlParameter { ParameterName = "@Cun_Id",              DbType = DbType.Int32, Value = Cun_Id },
                new SqlParameter { ParameterName = "@Mat_Id",              DbType = DbType.Int32, Value = Mat_Id },
                new SqlParameter { ParameterName = "@Emp_Id",              DbType = DbType.Int32, Value = Emp_Id },
                new SqlParameter { ParameterName = "@Sec_Id",              DbType = DbType.Int32, Value = Sec_Id },
                new SqlParameter { ParameterName = "@Aul_Id",              DbType = DbType.Int32, Value = Aul_Id },
                new SqlParameter { ParameterName = "@Dia_Id",              DbType = DbType.Int32, Value = Dia_Id },
                new SqlParameter { ParameterName = "@Hor_HoraInicio",      DbType = DbType.Int32, Value = Hor_HoraInicio },
                new SqlParameter { ParameterName = "@Hor_HoraFinaliza",    DbType = DbType.Int32, Value = Hor_HoraFinaliza },
                new SqlParameter { ParameterName = "@Sem_Id",              DbType = DbType.Int32, Value = Sem_Id },
                new SqlParameter { ParameterName = "@Mda_Id",              DbType = DbType.Int32, Value = (object)Mda_Id ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@Hor_Año",             DbType = DbType.Int32, Value = Hor_Año },
                new SqlParameter { ParameterName = "@Hor_UsuarioModifica", DbType = DbType.Int32, Value = usuarioModifica },
            };
            return await Update("app.PR_tbHorarios_Update", p);
        }

        public async Task<Answer> Remove(int Hor_Id, int usuarioModifica)
        {
            SqlParameter[] p =
            {
                new SqlParameter { ParameterName = "@Hor_Id",              DbType = DbType.Int32, Value = Hor_Id },
                new SqlParameter { ParameterName = "@Hor_UsuarioModifica", DbType = DbType.Int32, Value = usuarioModifica },
            };
            return await Delete("app.PR_tbHorarios_Delete", p);
        }
    }
}
