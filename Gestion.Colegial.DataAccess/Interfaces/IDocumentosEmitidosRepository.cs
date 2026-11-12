using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    /// <summary>Constancias y expediente: documentos emitidos e inmutables (script 064).</summary>
    public interface IDocumentosEmitidosRepository
    {
        Task<Answer> List(string? tipo, int? aluId, int? aniId);
        Task<Answer> Find(int id);
        Task<Answer> VistaPrevia(string? tipo, int aluId, int? aniId, int? pacId);
        Task<Answer> Emitir(DocumentoEmitirDTO obj);
    }
}
