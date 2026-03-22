using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class UsuarioRepository : RepositoryBase, IUsuarioRepository
    {
        public async Task<Answer> LoginAsync(string username, string password)
        {
            const string sql = "Seguridad.UDP_tbUsuarios_Login";

            // Hash password using SHA256
            string hashedPassword = HashPassword(password);

            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Usu_Name", DbType = DbType.String, Value = username },
                new SqlParameter(){ParameterName= "@Usu_Contrasena", DbType = DbType.String, Value = hashedPassword },
            };

            Answer answer = await Search<UDP_tbUsuarios_LoginResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> LoginInAsync(int usuId, string userIp)
        {
            const string sql = "Seguridad.UDP_tbUsuarios_LoginIn";

            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Usu_Id", DbType = DbType.Int32, Value = usuId },
                new SqlParameter(){ParameterName= "@Usu_Ip", DbType = DbType.String, Value = userIp ?? string.Empty },
            };

            Answer answer = await Search<UDP_tbUsuarios_LoginInResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> LogoutAsync(int usuId)
        {
            const string sql = "Seguridad.UDP_tbUsuarios_Logout";

            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Usu_Id", DbType = DbType.Int32, Value = usuId },
            };

            Answer answer = await Search<UDP_tbUsuarios_LogoutResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> GetPantallasByRolAsync(int rolId)
        {
            const string sql = "Seguridad.UDP_tbRolesPantallas_ByRolId";

            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Rol_Id", DbType = DbType.Int32, Value = rolId },
            };

            Answer answer = await Read<UDP_tbRolesPantallas_ByRolIdResult>(sql, sqlParameters);
            return answer;
        }

        // ==================== CRUD ====================

        public async Task<Answer> List()
        {
            const string sql = "Seguridad.UDP_tbUsuarios_List";
            Answer answer = await Read<UDP_tbUsuarios_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "Seguridad.UDP_tbUsuarios_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Usu_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<UDP_tbUsuarios_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "Seguridad.UDP_tbUsuarios_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Usu_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<UDP_tbUsuarios_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbUsuarios obj)
        {
            string hashedPassword = HashPassword(obj.Usu_Contraseña ?? "Temporal123");
            const string sql = "Seguridad.UDP_tbUsuarios_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Usu_Name", DbType = DbType.String, Value = obj.Usu_Name},
                new SqlParameter(){ParameterName= "@Usu_Contrasena", DbType = DbType.String, Value = hashedPassword},
                new SqlParameter(){ParameterName= "@Rol_Id", DbType = DbType.Int32, Value = obj.Rol_Id},
                new SqlParameter(){ParameterName= "@Emp_Id", DbType = DbType.Int32, Value = obj.Emp_Id}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbUsuarios obj)
        {
            const string sql = "Seguridad.UDP_tbUsuarios_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Usu_Id", DbType = DbType.Int32, Value = obj.Usu_Id},
                new SqlParameter(){ParameterName= "@Usu_Name", DbType = DbType.String, Value = obj.Usu_Name},
                new SqlParameter(){ParameterName= "@Rol_Id", DbType = DbType.Int32, Value = obj.Rol_Id},
                new SqlParameter(){ParameterName= "@Emp_Id", DbType = DbType.Int32, Value = obj.Emp_Id},
                new SqlParameter(){ParameterName= "@Usu_EsActivo", DbType = DbType.Boolean, Value = obj.Usu_EsActivo}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "Seguridad.UDP_tbUsuarios_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Usu_Name", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<UDP_tbUsuarios_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "Seguridad.UDP_tbUsuarios_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Usu_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> RolesDropdown()
        {
            const string sql = "Seguridad.UDP_tbRoles_Dropdown";
            Answer answer = await Read<UDP_tbRoles_DropdownResult>(sql);
            return answer;
        }

        // ==================== Helpers ====================

        private string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder builder = new StringBuilder();
                foreach (byte b in bytes)
                {
                    builder.Append(b.ToString("x2"));
                }
                return builder.ToString();
            }
        }
    }
}