using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    /// <summary>Constancias y expediente: documentos oficiales congelados de un alumno.</summary>
    public interface IDocumentosEmitidosService
    {
        Task<Answer> List(string? tipo, int? aluId, int? aniId);
        Task<Answer> Find(int id);
        Task<Answer> VistaPrevia(string? tipo, int aluId, int? aniId, int? pacId);
        Task<Answer> Emitir(DocumentoEmitirDTO obj);
    }
}
