using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class UsuarioRepository : RepositoryBase, IUsuarioRepository
    {
        /// <summary>Datos del usuario y su huella guardada (por nombre o por Id). La comparación se hace en Business.</summary>
        public async Task<Answer> DatosLoginAsync(string? usuName, int? usuId)
        {
            SqlParameter[] sqlParameters = {
                Texto("@Usu_Name", usuName, 100),
                Entero("@Usu_Id", usuId),
            };
            return await Search<PR_tbUsuarios_DatosLoginResult>("seguridad.PR_tbUsuarios_DatosLogin", sqlParameters);
        }

        /// <summary>Único punto para guardar la contraseña de un usuario existente (huella ya calculada).</summary>
        public async Task<Answer> GuardarContrasenaAsync(int usuId, string huella, string? huellaLegado, string? huellaEsperada,
            int? bitUsuId, string? bitAccion, string? ip)
        {
            SqlParameter[] sqlParameters = {
                Entero("@Usu_Id", usuId),
                Ascii("@Contrasena", huella, 255),
                Ascii("@ContrasenaLegado", huellaLegado, 64),
                Ascii("@ContrasenaEsperada", huellaEsperada, 255),
                Entero("@Bit_UsuId", bitUsuId),
                Ascii("@Bit_Accion", bitAccion, 50),
                Ascii("@Bit_Ip", ip, 45),
            };
            return await Search<PR_FilasResult>("seguridad.PR_tbUsuarios_GuardarContrasena", sqlParameters);
        }

        public async Task<Answer> ConsultarBloqueoAsync(string usuario, string? ip)
        {
            SqlParameter[] sqlParameters = {
                Texto("@Usuario", usuario, 100),
                Ascii("@Ip", ip, 45),
            };
            return await Search<PR_tbIntentosLogin_SegundosResult>("seguridad.PR_tbIntentosLogin_Consultar", sqlParameters);
        }

        public async Task<Answer> RegistrarFalloAsync(string usuario, string? ip, int? usuId, string motivo,
            int maxUsuario, int maxIp, int ventanaMinutos, int bloqueoMinutos)
        {
            SqlParameter[] sqlParameters = {
                Texto("@Usuario", usuario, 100),
                Ascii("@Ip", ip, 45),
                Entero("@Usu_Id", usuId),
                Ascii("@Motivo", motivo, 500),
                Entero("@MaxUsuario", maxUsuario),
                Entero("@MaxIp", maxIp),
                Entero("@VentanaMinutos", ventanaMinutos),
                Entero("@BloqueoMinutos", bloqueoMinutos),
            };
            return await Search<PR_tbIntentosLogin_SegundosResult>("seguridad.PR_tbIntentosLogin_RegistrarFallo", sqlParameters);
        }

        public async Task<Answer> RegistrarExitoAsync(string usuario)
        {
            SqlParameter[] sqlParameters = { Texto("@Usuario", usuario, 100) };
            return await Search<PR_FilasResult>("seguridad.PR_tbIntentosLogin_RegistrarExito", sqlParameters);
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
            // La huella la calcula UsuarioService (Business/Seguridad/Contrasenas.cs).
            const string sql = "Seguridad.UDP_tbUsuarios_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Usu_Name", DbType = DbType.String, Value = obj.Usu_Name},
                new SqlParameter(){ParameterName= "@Usu_Contrasena", DbType = DbType.String, Value = obj.Usu_Contraseña},
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

        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, SqlDbType = SqlDbType.Int, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Texto(string nombre, string? valor, int largo) =>
            new SqlParameter() { ParameterName = nombre, SqlDbType = SqlDbType.NVarChar, Size = largo, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Ascii(string nombre, string? valor, int largo) =>
            new SqlParameter() { ParameterName = nombre, SqlDbType = SqlDbType.VarChar, Size = largo, Value = (object?)valor ?? DBNull.Value };
    }
}
