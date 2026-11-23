using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    /// <summary>Cierre y publicación de parciales: estado, faltantes, historial y acciones.</summary>
    public interface ICierresParcialService
    {
        Task<Answer> Anios();
        Task<Answer> Estado(int anio);
        Task<Answer> Faltantes(int anio, int semId, int pacId);
        Task<Answer> Historial(int anio);
        Task<Answer> Periodos(int? anio, int? semId, int? pacId, int? notId);
        Task<Answer> Cerrar(CierreParcialAccionDTO obj);
        Task<Answer> Publicar(CierreParcialAccionDTO obj);
        Task<Answer> Despublicar(CierreParcialAccionDTO obj);
        Task<Answer> Reabrir(CierreParcialAccionDTO obj);
        Task<Answer> Fechas(CierreParcialAccionDTO obj);
    }
}
