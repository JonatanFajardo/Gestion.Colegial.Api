using Gestion.Colegial.Business.Dtos;
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.DataAccess.Repositories;
using Gestion.Colegial.Entities;
using static Gestion.Colegial.Business.Extensions.CustomMapping;

namespace Gestion.Colegial.Business.Services
{
    public class HomeAndChartsService
    {
        private readonly HomeAndChartsRepository homeAndChartsRepository = new HomeAndChartsRepository();


        public async Task<Answer> DiferenciaEntreCantidadAlumnosAnioPasado_Dashboard()
        {
            Answer answer = await homeAndChartsRepository.DiferenciaEntreCantidadAlumnosAnioPasado_Dashboard();
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


        public async Task<Answer> ObtenerCantidadAlumnosPorCursoList()
        {
            Answer answer = await homeAndChartsRepository.ObtenerCantidadAlumnosPorCursoList();
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
    }
}
