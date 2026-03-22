using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class RolesService : IRolesService
    {
        private readonly IRolesRepository _repository;

        public RolesService(IRolesRepository repository)
        {
            _repository = repository;
        }

        public async Task<Answer> List()
        {
            Answer answer = await _repository.List();
            try { if (answer.Access) { Logs.Error(answer); } return answer; }
            catch (Exception e) { answer.Access = true; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Find(int id)
        {
            Answer answer = await _repository.Find(id);
            try { if (answer.Access) { Logs.Error(answer); } return answer; }
            catch (Exception e) { answer.Access = true; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Detail(int id)
        {
            Answer answer = await _repository.Detail(id);
            try { if (answer.Access) { Logs.Error(answer); } return answer; }
            catch (Exception e) { answer.Access = true; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Create(tbRoles obj)
        {
            obj.Rol_UsuarioRegistra = 1;
            Answer answer = await _repository.Create(obj);
            try { if (answer.Access) { Logs.Error(answer); return answer; } answer.Message = "Registro guardado exitosamente"; return answer; }
            catch (Exception e) { answer.Access = true; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Edit(tbRoles obj)
        {
            obj.Rol_UsuarioModifica = 1;
            Answer answer = await _repository.Edit(obj);
            try { if (answer.Access) { Logs.Error(answer); return answer; } answer.Message = "Registro editado exitosamente"; return answer; }
            catch (Exception e) { answer.Access = true; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Exist(string value)
        {
            Answer answer = await _repository.Exist(value);
            try { if (answer.Access) { Logs.Error(answer); } return answer; }
            catch (Exception e) { answer.Access = true; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> Delete(int id)
        {
            Answer answer = await _repository.Delete(id);
            try { if (answer.Access) { Logs.Error(answer); return answer; } answer.Message = "Registro eliminado exitosamente"; return answer; }
            catch (Exception e) { answer.Access = true; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> PantallasList()
        {
            Answer answer = await _repository.PantallasList();
            try { if (answer.Access) { Logs.Error(answer); } return answer; }
            catch (Exception e) { answer.Access = true; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> PantallasByRol(int rolId)
        {
            Answer answer = await _repository.PantallasByRol(rolId);
            try { if (answer.Access) { Logs.Error(answer); } return answer; }
            catch (Exception e) { answer.Access = true; answer.Incidents(e); Logs.Error(answer); return answer; }
        }

        public async Task<Answer> SavePantallas(int rolId, List<int> pantallaIds)
        {
            var response = new Answer();
            try
            {
                // 1. Delete all existing pantallas for this role
                await _repository.DeletePantallasByRol(rolId);

                // 2. Insert each new pantalla
                if (pantallaIds != null)
                {
                    foreach (var panId in pantallaIds)
                    {
                        await _repository.InsertPantalla(rolId, panId);
                    }
                }

                response.Access = false;
                response.Message = "Pantallas asignadas exitosamente";
                return response;
            }
            catch (Exception e)
            {
                response.Access = true;
                response.Incidents(e);
                Logs.Error(response);
                return response;
            }
        }
    }
}
