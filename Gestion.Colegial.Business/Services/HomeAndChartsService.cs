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

        /// <summary>
        /// Calcula la diferencia en la cantidad de alumnos entre el año pasado y el actual para el dashboard.
        /// </summary>
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

        /// <summary>
        /// Obtiene la cantidad de alumnos por curso en el sistema.
        /// </summary>
        /// <returns>Lista con la cantidad de alumnos por curso. Devuelve un error si ocurre una excepción.</returns>
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

        /// <summary>
        /// Calcula el promedio de alumnos por curso en los últimos años.
        /// </summary>
        /// <returns>Promedio de alumnos por curso. Devuelve un error si ocurre una excepción.</returns>
        public async Task<Answer> ObtenerPromedioCursoUltimosAnios()
        {
            Answer answer = await homeAndChartsRepository.ObtenerPromedioCursoUltimosAnios();
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

        /// <summary>
        /// Recupera la lista de tarjetas con información destacada para la página de inicio.
        /// </summary>
        /// <returns>Lista de tarjetas con datos relevantes. Devuelve un error si ocurre una excepción.</returns>
        public async Task<Answer> CardsInHomeList()
        {
            Answer answer = await homeAndChartsRepository.CardsInHomeList();
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
