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

                // CORRECCIÓN: lógica invertida (debe ser !loginResult.Access)
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

                // Ya no usamos FirstOrDefault porque el repositorio ya devuelve un único registro
                var userData = loginResult.Data as UDP_tbUsuarios_LoginResult;

                if (userData == null || userData.IsAuthenticated == 0)
                {
                    response.Access = false;
                    response.Data = new LoginResponseDTO
                    {
                        Success = false,
                        Message = userData?.Message ?? "Usuario o contraseña incorrectos"
                    };
                    return response;
                }

                // Registrar login
                var loginInResult = await _usuarioRepository.LoginInAsync(userData.Usu_Id, userIp);

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
                    }
                };
            }
            catch (Exception ex)
            {
                response.Access = false;
                response.Message = $"Error: {ex.Message}";
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
            }

            return response;
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