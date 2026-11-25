using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class NotasService : INotasService
    {
        private readonly INotasRepository _r;
        private readonly ICierresParcialRepository _cierres;
        private readonly IEvaluacionesRepository _evaluaciones;
        public NotasService(INotasRepository r, ICierresParcialRepository cierres, IEvaluacionesRepository evaluaciones)
        { _r = r; _cierres = cierres; _evaluaciones = evaluaciones; }

        private async Task<Answer> Wrap(Task<Answer> task, string msg = null)
        {
            Answer a = await task;
            try
            {
                if (a.Access)
                {
                    // Un rechazo del procedimiento (THROW 50000-50099, p. ej. parcial cerrado) llega tal cual.
                    string validacion = EventosCalendarioService.MensajeDeValidacionSql(a);
                    if (validacion == null) Logs.Error(a);
                    a.Message = validacion ?? MessageShow.Error;
                }
                else if (msg != null) a.Message = msg;
                return a;
            }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); return a; }
        }

        /// <summary>
        /// Mensaje si el período (año, semestre, parcial) o el de la nota está cerrado (script 075); null si
        /// está abierto o no se pudo leer: el procedimiento que escribe la nota lo vuelve a revisar.
        /// </summary>
        private async Task<string> PeriodoCerrado(int? anio, int? semId, int? pacId, int? notId)
        {
            Answer a = await _cierres.Periodos(anio, semId, pacId, notId);
            if (a.Access || a.Data is not List<PR_CierresParcial_PeriodosResult> lista) return null;
            PR_CierresParcial_PeriodosResult p = lista.FirstOrDefault(x => x.Estado == "cerrado");
            if (p == null) return null;
            return $"El {p.Parcial?.ToLower()} del {p.Semestre?.ToLower()} de {p.Anio} está cerrado: ya no se pueden registrar, "
                 + "cambiar ni quitar notas. Si hace falta una corrección, pida a Dirección que lo reabra.";
        }

        private static Answer Rechazo(string mensaje) => new Answer { Access = true, Message = mensaje, Data = "" };

        public Task<Answer> List(int Hor_Id, int Par_Id, int Usu_Id)
            => Wrap(_r.List(Hor_Id, Par_Id, Usu_Id));

        public Task<Answer> Horarios(int Usu_Id)
            => Wrap(_r.Horarios(Usu_Id));

        public Task<Answer> Cuaderno(int Sec_Id, int Mat_Id, int Par_Id, int Sem_Id, int Anio)
            => Wrap(_r.Cuaderno(Sec_Id, Mat_Id, Par_Id, Sem_Id, Anio));

        public Task<Answer> Boletin(int Alu_Id, int Sem_Id, int Anio)
            => Wrap(_r.Boletin(Alu_Id, Sem_Id, Anio));

        public async Task<Answer> Insert(int Alu_Id, int Hor_Id, int Par_Id, decimal Not_Nota, int usuarioRegistra)
        {
            // Notas ponderadas (script 089): con actividades, la nota del parcial sale del cálculo y no se escribe a mano.
            Answer usa = await _evaluaciones.UsaActividades(Hor_Id, Par_Id);
            if (!usa.Access && usa.Data is PR_Evaluacion_UsaActividadesResult u && u.UsaActividades)
                return Rechazo("Esta materia se califica con actividades en este parcial: la nota del parcial se calcula sola "
                             + "con los puntos de las actividades del cuaderno.");
            // El procedimiento revisa el cierre del parcial dentro de la transaccion (THROW 50070).
            return await Wrap(_r.Insert(Alu_Id, Hor_Id, Par_Id, Not_Nota, usuarioRegistra), MessageShow.SuccessSave);
        }

        public async Task<Answer> Edit(int Not_Id, decimal Not_Nota, int usuarioModifica)
        {
            string cerrado = await PeriodoCerrado(null, null, null, Not_Id);
            if (cerrado != null) return Rechazo(cerrado);
            return await Wrap(_r.Edit(Not_Id, Not_Nota, usuarioModifica), MessageShow.SuccessEdit);
        }
    }
}
