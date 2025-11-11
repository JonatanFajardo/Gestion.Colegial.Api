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