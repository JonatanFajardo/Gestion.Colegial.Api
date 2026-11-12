using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class NotificacionService : INotificacionService
    {
        private readonly INotificacionRepository _repository;

        public NotificacionService(INotificacionRepository repository)
        {
            _repository = repository;
        }

        public async Task<Answer> ListByUsuario(int usuId, bool soloNoLeidas)
        {
            Answer answer = await _repository.ListByUsuario(usuId, soloNoLeidas);
            try
            {
                if (answer.Access)
                {
                    answer.Message = MessageShow.Error;
                    Logs.Error(answer);
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

        public async Task<Answer> MarcarLeida(int notId)
        {
            Answer answer = await _repository.MarcarLeida(notId);
            try
            {
                if (answer.Access)
                {
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

        public async Task<Answer> Insert(int usuId, string titulo, string mensaje, string tipo, string urlDestino, int usuarioRegistra)
        {
            Answer answer = await _repository.Insert(usuId, titulo, mensaje, tipo, urlDestino, usuarioRegistra);
            try
            {
                if (answer.Access)
                {
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
    }
}
