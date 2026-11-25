using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Business.Seguridad;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class UsuarioService : IUsuarioService
    {
        private readonly IUsuarioRepository _usuarioRepository;
        private readonly IConfiguration _configuration;

        public UsuarioService(IUsuarioRepository usuarioRepository, IConfiguration configuration)
        {
            _usuarioRepository = usuarioRepository;
            _configuration = configuration;
        }

        public const string MensajeIncorrecto = "Usuario o contraseña incorrectos.";

        /// <summary>
        /// Inicio de sesión. Mismo mensaje y mismo trabajo (una derivación PBKDF2) exista o no el
        /// usuario. Los fallos se cuentan por usuario y por IP; al llegar al máximo, se bloquea un rato.
        /// Una contraseña en formato viejo correcta se vuelve a guardar en el formato nuevo.
        /// </summary>
        public async Task<Answer> AuthenticateAsync(LoginRequestDTO loginRequest, string userIp)
        {
            var response = new Answer();

            try
            {
                string usuario = (loginRequest.Username ?? string.Empty).Trim();
                if (usuario.Length > 100) usuario = usuario.Substring(0, 100);
                string clave = loginRequest.Password ?? string.Empty;

                // El intento se cuenta antes de revisar la contraseña (así no se puede probar en paralelo).
                PR_tbIntentosLogin_ReservarResult? reserva = await ReservarIntento(usuario, userIp);
                if (reserva == null)
                {
                    return Rechazo(response, "No se pudo iniciar sesión. Intente de nuevo.");
                }
                if (reserva.Permitido != 1)
                {
                    return Rechazo(response, MensajeBloqueo(reserva.Segundos));
                }

                var datos = (await _usuarioRepository.DatosLoginAsync(usuario, null)).Data as PR_tbUsuarios_DatosLoginResult;
                ResultadoContrasena verificacion = Contrasenas.Verificar(clave, datos?.Usu_Contrasena);

                if (datos == null || !verificacion.Correcta || datos.Habilitado != 1)
                {
                    string motivo = datos == null ? "Usuario no existe"
                        : !verificacion.Correcta ? "Contraseña incorrecta"
                        : "Cuenta inactiva, suspendida o eliminada";
                    await RegistrarFallo(datos?.Usu_Id, userIp, motivo, reserva);
                    return Rechazo(response, reserva.Segundos > 0 ? MensajeBloqueo(reserva.Segundos) : MensajeIncorrecto);
                }

                await _usuarioRepository.RegistrarExitoAsync(usuario, userIp, MaxFallosIp);

                if (verificacion.DebeActualizar)
                {
                    // Conversión al formato nuevo. Mientras dure la transición se guarda también la huella
                    // vieja para que el código anterior siga aceptando a este usuario.
                    Answer conversion = await _usuarioRepository.GuardarContrasenaAsync(datos.Usu_Id, Contrasenas.Crear(clave),
                        verificacion.FormatoAnterior ? Contrasenas.HuellaAnterior(clave) : null, datos.Usu_Contrasena, null, null, null);
                    if (conversion.Access) Logs.Error(conversion);
                }

                var userData = new UDP_tbUsuarios_LoginResult
                {
                    Usu_Id = datos.Usu_Id,
                    Usu_Name = datos.Usu_Name ?? usuario,
                    Emp_Id = datos.Emp_Id,
                    Rol_Id = datos.Rol_Id,
                    Rol_Nombre = datos.Rol_Nombre ?? string.Empty,
                    IsAuthenticated = 1,
                    Message = "Login exitoso"
                };

                // Registrar login
                await _usuarioRepository.LoginInAsync(userData.Usu_Id, userIp);

                // Obtener pantallas/permisos del rol
                var pantallasResult = await _usuarioRepository.GetPantallasByRolAsync(userData.Rol_Id);
                var pantallas = new List<string>();
                if (!pantallasResult.Access && pantallasResult.Data != null)
                {
                    var pantallasList = pantallasResult.Data as List<UDP_tbRolesPantallas_ByRolIdResult>;
                    if (pantallasList != null)
                    {
                        pantallas = pantallasList.Select(p => p.Pan_Descripcion).ToList();
                    }
                }

                // Generar token JWT
                var token = GenerateJwtToken(userData, loginRequest.RememberMe);

                response.Access = true;
                response.Message = "Login exitoso";
                response.Data = new LoginResponseDTO
                {
                    Success = true,
                    Message = userData.Message,
                    Token = token,
                    User = new UserInfoDTO
                    {
                        Usu_Id = userData.Usu_Id,
                        Usu_Name = userData.Usu_Name,
                        Emp_Id = userData.Emp_Id,
                        Rol_Id = userData.Rol_Id,
                        Rol_Nombre = userData.Rol_Nombre,
                        Sello = datos.Usu_SelloSesion
                    },
                    Pantallas = pantallas
                };
            }
            catch (Exception ex)
            {
                response.Access = false;
                response.Message = $"Error: {ex.Message}";
                response.Incidents(ex);
                Logs.Error(response);
                response.Data = new LoginResponseDTO
                {
                    Success = false,
                    Message = "No se pudo iniciar sesión. Intente de nuevo."
                };
            }

            return response;
        }

        /// <summary>
        /// Cambio de la propia contraseña: pide la actual (los fallos cuentan para el bloqueo del
        /// usuario igual que en el inicio de sesión). Answer.Access = true significa error.
        /// </summary>
        public async Task<Answer> CambiarContrasenaAsync(CambiarContrasenaDTO dto)
        {
            var answer = new Answer();
            try
            {
                var datos = dto.Usu_Id > 0
                    ? (await _usuarioRepository.DatosLoginAsync(null, dto.Usu_Id)).Data as PR_tbUsuarios_DatosLoginResult
                    : null;
                if (datos == null || datos.Habilitado != 1)
                {
                    return Error(answer, "No se encontró la cuenta.");
                }

                string usuario = datos.Usu_Name ?? string.Empty;
                PR_tbIntentosLogin_ReservarResult? reserva = await ReservarIntento(usuario, dto.IpCliente);
                if (reserva == null)
                {
                    return Error(answer, "No se pudo cambiar la contraseña.");
                }
                if (reserva.Permitido != 1)
                {
                    return Error(answer, MensajeBloqueo(reserva.Segundos));
                }

                if (!Contrasenas.Verificar(dto.ContrasenaActual, datos.Usu_Contrasena).Correcta)
                {
                    await RegistrarFallo(datos.Usu_Id, dto.IpCliente, "Cambio de contraseña: la actual no coincide", reserva);
                    return Error(answer, reserva.Segundos > 0 ? MensajeBloqueo(reserva.Segundos) : "La contraseña actual no es correcta.");
                }
                await _usuarioRepository.RegistrarExitoAsync(usuario, dto.IpCliente, MaxFallosIp);

                if (dto.ContrasenaNueva == dto.ContrasenaActual)
                {
                    return Error(answer, "La contraseña nueva debe ser distinta de la actual.");
                }

                return await GuardarContrasenaAsync(datos.Usu_Id, usuario, dto.ContrasenaNueva, datos.Usu_Id,
                    "Cambio de contraseña", dto.IpCliente);
            }
            catch (Exception e)
            {
                answer.Incidents(e);
                Logs.Error(answer);
                return Error(answer, "No se pudo cambiar la contraseña.");
            }
        }

        /// <summary>
        /// ÚNICO camino para poner una contraseña nueva a un usuario existente (cambio, restablecimiento,
        /// activación de cuentas): valida las reglas, calcula la huella y la guarda con
        /// seguridad.PR_tbUsuarios_GuardarContrasena. Answer.Access = true significa error.
        /// </summary>
        public async Task<Answer> GuardarContrasenaAsync(int usuId, string usuName, string? nueva, int? actorId, string accion, string? ip)
        {
            var answer = new Answer();
            string? problema = Contrasenas.Validar(nueva, usuName);
            if (problema != null)
            {
                return Error(answer, problema);
            }

            Answer guardado = await _usuarioRepository.GuardarContrasenaAsync(usuId, Contrasenas.Crear(nueva!), null, null,
                actorId, accion, ip);
            if (guardado.Access || guardado.Data is not PR_FilasResult { Filas: > 0 })
            {
                Logs.Error(guardado);
                return Error(answer, "No se pudo guardar la contraseña.");
            }

            answer.Access = false;
            answer.Message = "Contraseña actualizada.";
            return answer;
        }

        private int MaxFallosUsuario => Limite("Login:MaxFallosUsuario", 5);
        private int MaxFallosIp => Limite("Login:MaxFallosIp", 20);
        private int VentanaMinutos => Limite("Login:VentanaMinutos", 15);
        private int BloqueoMinutos => Limite("Login:BloqueoMinutos", 15);

        private int Limite(string clave, int porDefecto) =>
            int.TryParse(_configuration[clave], out int valor) && valor >= 0 ? valor : porDefecto;

        /// <summary>Cuenta el intento antes de revisar la contraseña. null = no se pudo (se rechaza).</summary>
        private async Task<PR_tbIntentosLogin_ReservarResult?> ReservarIntento(string usuario, string? ip)
        {
            Answer a = await _usuarioRepository.ReservarIntentoAsync(usuario, ip,
                MaxFallosUsuario, MaxFallosIp, Math.Max(1, VentanaMinutos), Math.Max(1, BloqueoMinutos));
            if (a.Access) Logs.Error(a);
            return a.Data as PR_tbIntentosLogin_ReservarResult;
        }

        private async Task RegistrarFallo(int? usuId, string? ip, string motivo, PR_tbIntentosLogin_ReservarResult reserva)
        {
            Answer a = await _usuarioRepository.RegistrarFalloAsync(usuId, ip, motivo,
                reserva.BloqueoUsuario == 1, reserva.BloqueoIp == 1, Math.Max(1, BloqueoMinutos));
            if (a.Access && usuId != null) Logs.Error(a);
        }

        private static string MensajeBloqueo(int segundos)
        {
            int minutos = Math.Max(1, (int)Math.Ceiling(segundos / 60.0));
            return $"Demasiados intentos fallidos. Espere {minutos} {(minutos == 1 ? "minuto" : "minutos")} e intente de nuevo.";
        }

        private static Answer Rechazo(Answer response, string mensaje)
        {
            response.Access = false;
            response.Message = mensaje;
            response.Data = new LoginResponseDTO { Success = false, Message = mensaje };
            return response;
        }

        private static Answer Error(Answer answer, string mensaje)
        {
            answer.Access = true;
            answer.Message = mensaje;
            return answer;
        }


        /// <summary>
        /// Cierre de sesión: deja la hora en el registro del usuario. Answer.Access = true significa que se
        /// registró (mismo criterio que usa AccountController.Logout).
        /// </summary>
        public async Task<Answer> LogoutAsync(int usuId)
        {
            var response = new Answer();

            try
            {
                Answer logoutResult = await _usuarioRepository.LogoutAsync(usuId);

                // Search deja Access = false cuando salió bien y Data con una sola fila.
                if (!logoutResult.Access && logoutResult.Data is UDP_tbUsuarios_LogoutResult { Success: 1 })
                {
                    response.Access = true;
                    response.Message = "Logout exitoso";
                    response.Data = "Sesion cerrada correctamente";
                }
                else
                {
                    response.Access = false;
                    response.Message = "Error al cerrar sesion";
                }
            }
            catch (Exception ex)
            {
                response.Access = false;
                response.Message = $"Error: {ex.Message}";
                response.Incidents(ex);
                Logs.Error(response);
            }

            return response;
        }

        /// <summary>Estado de la sesión del usuario: Data = PR_tbUsuarios_EstadoSesionResult (null si la cuenta no existe).</summary>
        public async Task<Answer> EstadoSesionAsync(int usuId)
        {
            Answer a = await _usuarioRepository.EstadoSesionAsync(usuId);
            if (a.Access && a.Data is string) Logs.Error(a); // error real; "sin fila" deja Data en null
            return a;
        }

        // ==================== CRUD ====================

        public async Task<Answer> List()
        {
            Answer answer = await _usuarioRepository.List();
            try
            {
                if (answer.Access) { answer.Access = true; answer.Message = "Error"; Logs.Error(answer); return answer; }
                return answer;
            }
            catch (Exception e) { answer.Access = true; answer.Message = "Error"; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Find(int id)
        {
            Answer answer = await _usuarioRepository.Find(id);
            try
            {
                if (answer.Access) { answer.Access = true; answer.Message = "Error"; Logs.Error(answer); return answer; }
                return answer;
            }
            catch (Exception e) { answer.Access = true; answer.Message = "Error"; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Detail(int id)
        {
            Answer answer = await _usuarioRepository.Detail(id);
            try
            {
                if (answer.Access) { answer.Access = true; answer.Message = "Error"; Logs.Error(answer); return answer; }
                return answer;
            }
            catch (Exception e) { answer.Access = true; answer.Message = "Error"; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Create(tbUsuarios obj)
        {
            string? problema = Contrasenas.Validar(obj.Usu_Contraseña, obj.Usu_Name);
            if (problema != null) return Error(new Answer(), problema);
            obj.Usu_Contraseña = Contrasenas.Crear(obj.Usu_Contraseña!);
            Answer answer = await _usuarioRepository.Create(obj);
            try
            {
                if (answer.Access) { answer.Access = true; answer.Message = "Error"; Logs.Error(answer); return answer; }
                answer.Message = "Registro guardado exitosamente";
                return answer;
            }
            catch (Exception e) { answer.Access = true; answer.Message = "Error"; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Edit(tbUsuarios obj)
        {
            Answer answer = await _usuarioRepository.Edit(obj);
            try
            {
                if (answer.Access) { answer.Access = true; answer.Message = "Error"; Logs.Error(answer); return answer; }
                answer.Message = "Registro editado exitosamente";
                return answer;
            }
            catch (Exception e) { answer.Access = true; answer.Message = "Error"; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Exist(string value)
        {
            Answer answer = await _usuarioRepository.Exist(value);
            try
            {
                if (answer.Access) { answer.Access = true; answer.Message = "Error"; Logs.Error(answer); return answer; }
                return answer;
            }
            catch (Exception e) { answer.Access = true; answer.Message = "Error"; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Delete(int id)
        {
            Answer answer = await _usuarioRepository.Delete(id);
            try
            {
                if (answer.Access) { answer.Access = true; answer.Message = "Error"; Logs.Error(answer); return answer; }
                answer.Message = "Registro eliminado exitosamente";
                return answer;
            }
            catch (Exception e) { answer.Access = true; answer.Message = "Error"; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> RolesDropdown()
        {
            Answer answer = await _usuarioRepository.RolesDropdown();
            try
            {
                if (answer.Access) { answer.Access = true; answer.Message = "Error"; Logs.Error(answer); return answer; }
                return answer;
            }
            catch (Exception e) { answer.Access = true; answer.Message = "Error"; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        private string GenerateJwtToken(UDP_tbUsuarios_LoginResult user, bool rememberMe)
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"] ?? "GestionColegialSecretKey2025MinLength32Chars!!"));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Usu_Id.ToString()),
                new Claim(ClaimTypes.Name, user.Usu_Name),
                new Claim(ClaimTypes.Role, user.Rol_Nombre),
                new Claim("Emp_Id", user.Emp_Id.ToString()),
                new Claim("Rol_Id", user.Rol_Id.ToString())
            };

            var expiration = rememberMe ? DateTime.Now.AddDays(30) : DateTime.Now.AddHours(8);

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"] ?? "GestionColegialAPI",
                audience: _configuration["Jwt:Audience"] ?? "GestionColegialUI",
                claims: claims,
                expires: expiration,
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}