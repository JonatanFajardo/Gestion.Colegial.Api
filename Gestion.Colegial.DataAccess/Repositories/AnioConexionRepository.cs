using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>Conexión con el año lectivo (script 091): cupos, inscripción por año y semestres.</summary>
    public class AnioConexionRepository : RepositoryBase, IAnioConexionRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        public async Task<Answer> Cupos(int aniId) =>
            await Read<PR_tbSeccionesAnio_CuposResult>("app.PR_tbSeccionesAnio_Cupos", new[] { Entero("@Ani_Id", aniId) });

        public async Task<Answer> ActualizarCupo(int seaId, int cupo, int? usuario) =>
            await Search<PR_tbSeccionesAnio_ActualizarCupoResult>("app.PR_tbSeccionesAnio_ActualizarCupo",
                new[] { Entero("@Sea_Id", seaId), Entero("@Sea_Cupo", cupo), Entero("@Usuario", usuario) });

        public async Task<Answer> AniosInscripcion() =>
            await Read<PR_AnioConexion_AniosInscripcionResult>("app.PR_AnioConexion_AniosInscripcion", new SqlParameter[] { });

        public async Task<Answer> VerificarCupo(int? aniId, int nivId, int cunId, int? mdaId, int secId) =>
            await Search<PR_AnioConexion_VerificarCupoResult>("app.PR_AnioConexion_VerificarCupo",
                new[] { Entero("@Ani_Id", aniId), Entero("@Niv_Id", nivId), Entero("@Cun_Id", cunId), Entero("@Mda_Id", mdaId), Entero("@Sec_Id", secId) });

        public async Task<Answer> InscribirAlumno(int aluId, int? aniId, int? usuario) =>
            await Search<PR_AnioConexion_InscribirAlumnoResult>("app.PR_AnioConexion_InscribirAlumno",
                new[] { Entero("@Alu_Id", aluId), Entero("@Ani_Id", aniId), Entero("@Usuario", usuario) });

        public async Task<Answer> AplicarUbicacion(int aniId, int? usuario, bool activar) =>
            await Search<PR_tbAnioLectivo_AplicarUbicacionResult>("app.PR_tbAnioLectivo_AplicarUbicacion",
                new[] { Entero("@Ani_Id", aniId), Entero("@Usuario", usuario),
                        new SqlParameter() { ParameterName = "@Activar", SqlDbType = SqlDbType.Bit, Value = activar } });

        public async Task<Answer> UbicacionPrevia(int aniId) =>
            await Search<PR_tbAnioLectivo_UbicacionPreviaResult>("app.PR_tbAnioLectivo_UbicacionPrevia", new[] { Entero("@Ani_Id", aniId) });

        public async Task<Answer> Semestres(int anio) =>
            await Read<PR_AnioConexion_SemestresResult>("app.PR_AnioConexion_Semestres", new[] { Entero("@Anio", anio) });
    }
}
