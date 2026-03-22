using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
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

        public async Task<Answer> AuthenticateAsync(LoginRequestDTO loginRequest, string userIp)
        {
            var response = new Answer();

            try
            {
                // Autenticar usuario
                var loginResult = await _usuarioRepository.LoginAsync(loginRequest.Username, loginRequest.Password);

                // CORRECCI�N: l�gica invertida (debe ser !loginResult.Access)
                if (loginResult.Access || loginResult.Data == null)
                {
                    response.Access = false;
                    response.Message = "Error de autenticacion";
                    response.Data = new LoginResponseDTO
                    {
                        Success = false,
                        Message = "Error al conectar con el servidor"
                    };
                    return response;
                }

                // Ya no usamos FirstOrDefault porque el repositorio ya devuelve un �nico registro
                var userData = loginResult.Data as UDP_tbUsuarios_LoginResult;

                if (userData == null || userData.IsAuthenticated == 0)
                {
                    response.Access = false;
                    response.Data = new LoginResponseDTO
                    {
                        Success = false,
                        Message = userData?.Message ?? "Usuario o contrase�a incorrectos"
                    };
                    return response;
                }

                // Registrar login
                var loginInResult = await _usuarioRepository.LoginInAsync(userData.Usu_Id, userIp);

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
                        Rol_Nombre = userData.Rol_Nombre
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
                    Message = "Error interno del servidor"
                };
            }

            return response;
        }


        public async Task<Answer> LogoutAsync(int usuId)
        {
            var response = new Answer();

            try
            {
                var logoutResult = await _usuarioRepository.LogoutAsync(usuId);

                if (logoutResult.Access && logoutResult.Data != null)
                {
                    var dataList = logoutResult.Data as List<UDP_tbUsuarios_LogoutResult>;
                    var result = dataList?.FirstOrDefault();

                    if (result?.Success == 1)
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