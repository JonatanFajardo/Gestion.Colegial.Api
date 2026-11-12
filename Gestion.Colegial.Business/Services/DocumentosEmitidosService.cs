using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Constancias y expediente (espejo de Skuul TranscriptSnapshot / ReportCardSnapshot). Cada emisión
    /// guarda una copia fija del contenido; para corregir se emite una revisión nueva con motivo.
    /// Códigos de la emisión: -1 sin notas, -2 sin matrícula en el año, -3 datos inválidos,
    /// -4 revisión sin motivo; 0 = error inesperado.
    /// </summary>
    public class DocumentosEmitidosService : IDocumentosEmitidosService
    {
        public static readonly string[] Tipos = { "ESTUDIO", "BOLETIN", "EXPEDIENTE" };
        public const int DatosInvalidos = -3;

        private readonly IDocumentosEmitidosRepository _repository;

        public DocumentosEmitidosService(IDocumentosEmitidosRepository repository)
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

        private static string? Tipo(string? tipo)
        {
            string t = (tipo ?? "").Trim().ToUpperInvariant();
            return Tipos.Contains(t) ? t : null;
        }

        public async Task<Answer> List(string? tipo, int? aluId, int? aniId) =>
            Revisar(await _repository.List(Tipo(tipo), aluId, aniId));

        public async Task<Answer> Find(int id)
        {
            Answer answer = await _repository.Find(id);
            // Sin fila = no existe: no es un error.
            return answer.Access && answer.Data == null ? answer : Revisar(answer);
        }

        public async Task<Answer> VistaPrevia(string? tipo, int aluId, int? aniId, int? pacId)
        {
            string? t = Tipo(tipo);
            if (t == null)
                return new Answer { Data = new PR_tbDocumentosEmitidos_VistaPreviaResult { Codigo = DatosInvalidos } };
            return Revisar(await _repository.VistaPrevia(t, aluId, aniId, pacId));
        }

        /// <summary>Data = Id nuevo (mayor que 0), código negativo o 0 si falló.</summary>
        public async Task<Answer> Emitir(DocumentoEmitirDTO obj)
        {
            string? t = Tipo(obj?.Doc_Tipo);
            if (obj == null || t == null || obj.Alu_Id <= 0 || obj.Doc_UsuarioEmite == null
                || (obj.Doc_Motivo ?? "").Trim().Length > 300)
                return new Answer { Data = DatosInvalidos };

            obj.Doc_Tipo = t;
            Answer answer = await _repository.Emitir(obj);
            if (answer.Access)
            {
                answer.Message = MessageShow.Error;
                Logs.Error(answer);
                answer.Data = 0;
                return answer;
            }
            answer.Data = (answer.Data as PR_tbDocumentosEmitidos_EmitirResult)?.NewId ?? 0;
            answer.Message = MessageShow.SuccessSave;
            return answer;
        }
    }
}
