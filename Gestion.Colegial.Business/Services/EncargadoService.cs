using Gestion.Colegial.Business.Dtos;
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.DataAccess.Repositories;
using Gestion.Colegial.Entities;
using static Gestion.Colegial.Business.Extensions.CustomMapping;

namespace Gestion.Colegial.Business.Services
{
    public class EncargadoService : IEncargadoService
    {
        private readonly IEncargadoRepository _repository;

        public EncargadoService(IEncargadoRepository repository)
        {
            _repository = repository;
        }

        public async Task<Answer> List()
        {
            Answer answer = await _repository.List();
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }

        public async Task<Answer> Find(int id)
        {
            Answer answer = await _repository.Find(id);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }

        public async Task<Answer> Detail(int id)
        {
            Answer answer = await _repository.Detail(id);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }

        public async Task<Answer> Create(EncargadosFindDto obj)
        {
            var ent = EncargadosConversion.Create(obj);
            Answer answer = await _repository.Create(ent);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                answer.Message = MessageShow.SuccessSave;
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }

        public async Task<Answer> Edit(EncargadosFindDto obj)
        {
            var ent = EncargadosConversion.Edit(obj);
            Answer answer = await _repository.Edit(ent);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                answer.Message = MessageShow.SuccessEdit;
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }

        public async Task<Answer> Delete(int id)
        {
            Answer answer = await _repository.Delete(id);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                answer.Message = MessageShow.SuccessDelete;
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }

        public async Task<Answer> ByAlumno(int Alu_Id)
        {
            Answer answer = await _repository.ByAlumno(Alu_Id);
            try
            {
                if (answer.Access)
                {
                    answer.Access = true;
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
                    return answer;
                }
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Message = MessageShow.Error;
                answer.Incidents(e);
                Logs.Error(answer);
                return answer;
            }
        }

        public async Task<Answer> Vincular(int Enc_Id, int Alu_Id, int Par_Id)
        {
            if (Enc_Id <= 0 || Alu_Id <= 0 || Par_Id <= 0)
            {
                return new Answer { Access = true, Message = "Faltan el encargado, el alumno o el parentesco.", ErrorDetails = "Faltan el encargado, el alumno o el parentesco." };
            }
            Answer answer = await _repository.Vincular(Enc_Id, Alu_Id, Par_Id);
            if (answer.Access) Logs.Error(answer);
            return answer;
        }

        public async Task<Answer> Desvincular(int Enc_Id, int Alu_Id)
        {
            Answer answer = await _repository.Desvincular(Enc_Id, Alu_Id);
            if (answer.Access) Logs.Error(answer);
            return answer;
        }
    }
}