using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Lista de espera de admisión (espejo de Skuul "admission waitlist"). La cola es año + grado,
    /// ordenada por prioridad y posición; una oferta abierta reserva el asiento. Las reglas de cola
    /// y de cupo viven en los procedimientos (script 071); aquí se revisa lo básico antes de llamarlos.
    /// </summary>
    public class AspirantesService : IAspirantesService
    {
        public static readonly string[] Acciones = { "ofrecer", "rechazar", "desistio", "reactivar" };

        private readonly IAspirantesRepository _repository;

        public AspirantesService(IAspirantesRepository repository)
        {
            _repository = repository;
        }

        /// <summary>Marca el error para el log sin perder Data (las lecturas devuelven "" al fallar).</summary>
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

        /// <summary>Un error de validación del procedimiento (THROW 50000-50099) llega tal cual; otro se registra y se generaliza.</summary>
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

        public async Task<Answer> Anios() => Revisar(await _repository.Anios());
        public async Task<Answer> Resumen(int aniId) => Revisar(await _repository.Resumen(aniId));
        public async Task<Answer> List(int aniId) => Revisar(await _repository.List(aniId));
        public async Task<Answer> Historial(int id) => Revisar(await _repository.Historial(id));
        public async Task<Answer> Cursos(int cunId) => Revisar(await _repository.Cursos(cunId));

        public async Task<Answer> Find(int id)
        {
            Answer answer = await _repository.Find(id);
            // Sin fila = no existe: no es un error.
            return answer.Access && answer.Data == null ? answer : Revisar(answer);
        }

        public async Task<Answer> Duplicado(int aniId, string? identidad, string? nombres, string? apellidos, DateTime? fechaNacimiento, int? aspId) =>
            Revisar(await _repository.Duplicado(aniId, identidad, nombres, apellidos, fechaNacimiento, aspId));

        private static bool Largo(string? texto, int max) => (texto ?? "").Trim().Length > max;

        /// <summary>Lo básico del formulario; el procedimiento repite estas reglas y agrega las de la cola.</summary>
        public static string? Validar(AspiranteGuardarDTO? obj)
        {
            if (obj == null) return "No llegaron datos.";
            if (string.IsNullOrWhiteSpace(obj.Asp_Nombres) || string.IsNullOrWhiteSpace(obj.Asp_Apellidos))
                return "Escriba los nombres y los apellidos del aspirante.";
            if (Largo(obj.Asp_Nombres, 100) || Largo(obj.Asp_Apellidos, 100)) return "Los nombres y los apellidos admiten hasta 100 caracteres.";
            if (!obj.Asp_FechaNacimiento.HasValue) return "Indique la fecha de nacimiento.";
            if (obj.Asp_Sexo != "M" && obj.Asp_Sexo != "F") return "Elija el sexo del aspirante.";
            if (Largo(obj.Asp_EscuelaProcedencia, 150)) return "La escuela de procedencia admite hasta 150 caracteres.";
            if (string.IsNullOrWhiteSpace(obj.Asp_EncargadoNombre)) return "Escriba el nombre del encargado.";
            if (Largo(obj.Asp_EncargadoNombre, 150)) return "El nombre del encargado admite hasta 150 caracteres.";
            if (Largo(obj.Asp_EncargadoTelefono, 20)) return "El teléfono admite hasta 20 caracteres.";
            if (Largo(obj.Asp_EncargadoCorreo, 150)) return "El correo admite hasta 150 caracteres.";
            if (obj.Ani_Id <= 0) return "Elija el año lectivo.";
            if (obj.Niv_Id <= 0 || obj.Cun_Id <= 0) return "Elija el nivel y el grado al que aspira.";
            if (obj.Asp_Prioridad < 0 || obj.Asp_Prioridad > 2) return "Elija la prioridad.";
            if (Largo(obj.Asp_MotivoPrioridad, 200)) return "El motivo de la prioridad admite hasta 200 caracteres.";
            if (Largo(obj.Asp_Notas, 1000)) return "Las notas admiten hasta 1000 caracteres.";
            return null;
        }

        public async Task<Answer> Guardar(AspiranteGuardarDTO obj)
        {
            string? problema = Validar(obj);
            if (problema != null) return Rechazo(problema);
            return Escritura(await _repository.Guardar(obj), "No se pudo guardar el aspirante.");
        }

        public async Task<Answer> CambiarEstado(AspiranteEstadoDTO obj)
        {
            if (obj == null || !Acciones.Contains(obj.Accion)) return Rechazo("Elija qué hacer con el aspirante.");
            if (Largo(obj.Motivo, 500)) return Rechazo("El motivo admite hasta 500 caracteres.");
            if (obj.Accion != "ofrecer" && string.IsNullOrWhiteSpace(obj.Motivo)) return Rechazo("Escriba el motivo.");
            return Escritura(await _repository.CambiarEstado(obj.Asp_Id, obj.Accion!, obj.Motivo, null, obj.Usuario),
                             "No se pudo cambiar el estado del aspirante.");
        }

        public async Task<Answer> Matricular(AspiranteMatricularDTO obj)
        {
            if (obj == null || obj.Asp_Id <= 0 || obj.Alu_Id <= 0) return Rechazo("Faltan el aspirante o el alumno.");
            return Escritura(await _repository.CambiarEstado(obj.Asp_Id, "matricular", null, obj.Alu_Id, obj.Usuario),
                             "No se pudo marcar al aspirante como matriculado.");
        }
    }
}
