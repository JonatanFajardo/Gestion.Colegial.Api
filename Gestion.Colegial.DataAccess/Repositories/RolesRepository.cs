using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class RolesRepository : RepositoryBase, IRolesRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "Seguridad.UDP_tbRoles_List";
            Answer answer = await Read<UDP_tbRoles_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "Seguridad.UDP_tbRoles_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Rol_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<UDP_tbRoles_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "Seguridad.UDP_tbRoles_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Rol_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<UDP_tbRoles_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbRoles obj)
        {
            const string sql = "Seguridad.UDP_tbRoles_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Rol_Descripcion", DbType = DbType.String, Value = obj.Rol_Descripcion},
                new SqlParameter(){ParameterName= "@Rol_UsuarioRegistra", DbType = DbType.Int32, Value = obj.Rol_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbRoles obj)
        {
            const string sql = "Seguridad.UDP_tbRoles_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Rol_Id", DbType = DbType.Int32, Value = obj.Rol_Id},
                new SqlParameter(){ParameterName= "@Rol_Descripcion", DbType = DbType.String, Value = obj.Rol_Descripcion},
                new SqlParameter(){ParameterName= "@Rol_Estado", DbType = DbType.Boolean, Value = obj.Rol_Estado},
                new SqlParameter(){ParameterName= "@Rol_UsuarioModifica", DbType = DbType.Int32, Value = obj.Rol_UsuarioModifica ?? 1}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "Seguridad.UDP_tbRoles_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Rol_Descripcion", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<UDP_tbRoles_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "Seguridad.UDP_tbRoles_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Rol_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> PantallasList()
        {
            const string sql = "Seguridad.UDP_tbPantallas_List";
            Answer answer = await Read<UDP_tbPantallas_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> PantallasByRol(int rolId)
        {
            const string sql = "Seguridad.UDP_tbRolesPantallas_IdsByRol";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Rol_Id", DbType = DbType.Int32, Value = rolId },
            };
            Answer answer = await Read<UDP_tbRolesPantallas_IdsByRolResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> DeletePantallasByRol(int rolId)
        {
            const string sql = "Seguridad.UDP_tbRolesPantallas_DeleteByRol";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Rol_Id", DbType = DbType.Int32, Value = rolId },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> InsertPantalla(int rolId, int panId)
        {
            const string sql = "Seguridad.UDP_tbRolesPantallas_InsertSingle";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Rol_Id", DbType = DbType.Int32, Value = rolId},
                new SqlParameter(){ParameterName= "@Pan_Id", DbType = DbType.Int32, Value = panId}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }
    }
}
