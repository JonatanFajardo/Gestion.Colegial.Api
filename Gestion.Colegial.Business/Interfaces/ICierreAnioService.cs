using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    /// <summary>Cierre del año escolar: revisión, resultados finales, decisiones de promoción y estado del año.</summary>
    public interface ICierreAnioService
    {
        Task<Answer> Resumen(int aniId);
        Task<Answer> Revision(int aniId);
        Task<Answer> Reglas(int aniId);
        Task<Answer> Secciones(int aniId);
        Task<Answer> Resultados(int aniId, int seaId);
        Task<Answer> Decisiones(int aniId, int seaId);
        Task<Answer> Historial(int aniId);
        Task<Answer> CambiarEstado(CierreAnioAccionDTO obj);
        Task<Answer> Calcular(CierreAnioAccionDTO obj);
        Task<Answer> GuardarRegla(CierreAnioAccionDTO obj);
        Task<Answer> Recuperacion(CierreAnioAccionDTO obj);
        Task<Answer> Decidir(CierreAnioAccionDTO obj);
        Task<Answer> ConfirmarSeccion(CierreAnioAccionDTO obj);
        Task<Answer> DeshacerSeccion(CierreAnioAccionDTO obj);
    }
}
