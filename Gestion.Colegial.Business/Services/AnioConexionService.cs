using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Conexión con el año lectivo (script 091). Las reglas viven en los procedimientos;
    /// un error de validación (THROW 50000-50099) llega al usuario tal cual.
    /// </summary>
    public class AnioConexionService : IAnioConexionService
    {
        private readonly IAnioConexionRepository _repository;

        public AnioConexionService(IAnioConexionRepository repository)
        {
            _repository = repository;
        }

        private static Answer Revisar(Answer answer)
        {
            if (answer.Access)
            {
                answer.Message = MessageShow.Error;
                Logs.Error(answer);
            }
            return answer;
        }

        private static Answer Rechazo(string mensaje) => new Answer { Access = true, Message = mensaje, Data = "" };

        private static Answer Escritura(Answer answer, string general)
        {
            if (answer.Access)
            {
                string? validacion = EventosCalendarioService.MensajeDeValidacionSql(answer);
                if (validacion == null) Logs.Error(answer);
                answer.Message = validacion ?? general;
            }
            return answer;
        }

        public async Task<Answer> Cupos(int aniId) => Revisar(await _repository.Cupos(aniId));

        public async Task<Answer> ActualizarCupo(CupoSeccionDTO obj)
        {
            if (obj == null || obj.Sea_Id <= 0) return Rechazo("Elija la sección.");
            return Escritura(await _repository.ActualizarCupo(obj.Sea_Id, obj.Sea_Cupo, obj.Usuario), "No se pudo cambiar el cupo.");
        }

        public async Task<Answer> AniosInscripcion() => Revisar(await _repository.AniosInscripcion());

        public async Task<Answer> VerificarCupo(int? aniId, int nivId, int cunId, int? mdaId, int secId) =>
            Revisar(await _repository.VerificarCupo(aniId, nivId, cunId, mdaId, secId));

        public async Task<Answer> InscribirAlumno(InscribirAlumnoDTO obj)
        {
            if (obj == null || obj.Alu_Id <= 0) return Rechazo("Falta el alumno.");
            return Escritura(await _repository.InscribirAlumno(obj.Alu_Id, obj.Ani_Id, obj.Usuario), "No se pudo inscribir al alumno en el año.");
        }

        public async Task<Answer> AplicarUbicacion(AplicarUbicacionDTO obj)
        {
            if (obj == null || obj.Ani_Id <= 0) return Rechazo("Falta el año lectivo.");
            return Escritura(await _repository.AplicarUbicacion(obj.Ani_Id, obj.Usuario, obj.Activar), "No se pudo pasar la ubicación de los alumnos al año.");
        }

        public async Task<Answer> UbicacionPrevia(int aniId) => Revisar(await _repository.UbicacionPrevia(aniId));

        public async Task<Answer> Semestres(int anio) => Revisar(await _repository.Semestres(anio));
    }
}
