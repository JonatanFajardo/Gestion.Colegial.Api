using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class MatriculaAnioRepository : RepositoryBase, IMatriculaAnioRepository
    {
        public async Task<Answer> ListBySeccion(int seaId)
        {
            const string sql = "app.PR_tbMatriculaAnio_ListBySeccion";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Sea_Id", DbType = DbType.Int32, Value = seaId },
            };
            Answer answer = await Read<PR_tbMatriculaAnio_ListBySeccionResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Expediente(int aluId)
        {
            const string sql = "app.PR_tbMatriculaAnio_Expediente";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = aluId },
            };
            Answer answer = await Read<PR_tbMatriculaAnio_ExpedienteResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Enroll(tbMatriculaAnio obj)
        {
            obj.Mta_UsuarioRegistra = 1;
            const string sql = "app.PR_tbMatriculaAnio_Enroll";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = obj.Alu_Id },
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = obj.Ani_Id },
                new SqlParameter(){ParameterName= "@Sea_Id", DbType = DbType.Int32, Value = (object)obj.Sea_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Mta_UsuarioRegistra", DbType = DbType.Int32, Value = (object)obj.Mta_UsuarioRegistra ?? DBNull.Value }
            };
            Answer answer = await NewWithId<PR_tbMatriculaAnio_InsertResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Promover(int anioOrigen, int seccionOrigen, int anioDestino, int seccionDestino)
        {
            const string sql = "app.PR_tbMatriculaAnio_Promover";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Origen", DbType = DbType.Int32, Value = anioOrigen },
                new SqlParameter(){ParameterName= "@Sea_Origen", DbType = DbType.Int32, Value = seccionOrigen },
                new SqlParameter(){ParameterName= "@Ani_Destino", DbType = DbType.Int32, Value = anioDestino },
                new SqlParameter(){ParameterName= "@Sea_Destino", DbType = DbType.Int32, Value = seccionDestino },
                new SqlParameter(){ParameterName= "@Usuario", DbType = DbType.Int32, Value = 1 }
            };
            Answer answer = await Search<PR_tbMatriculaAnio_PromoverResult>(sql, sqlParameters);
            return answer;
        }

        /// <summary>Grupos de ubicación de los alumnos del año vs secciones del año e inscritos (aniId null = año activo).</summary>
        public async Task<Answer> ResumenInscripcion(int? aniId)
        {
            const string sql = "app.PR_tbMatriculaAnio_ResumenInscripcion";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = (object)aniId ?? DBNull.Value },
            };
            Answer answer = await Read<PR_tbMatriculaAnio_ResumenInscripcionResult>(sql, sqlParameters);
            return answer;
        }

        /// <summary>Crea las secciones del año que faltan según la ubicación de los alumnos (aluId limita a uno).</summary>
        public async Task<Answer> CrearSeccionesDesdeUbicacion(int? aniId, int? aluId, int? usuario)
        {
            const string sql = "app.PR_tbSeccionesAnio_CrearDesdeUbicacion";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = (object)aniId ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = (object)aluId ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Usuario", DbType = DbType.Int32, Value = (object)usuario ?? DBNull.Value }
            };
            Answer answer = await Search<PR_tbMatriculaAnio_InscribirDesdeUbicacionResult>(sql, sqlParameters);
            return answer;
        }

        /// <summary>Inscribe en el año, en lote o un alumno, según su ubicación.</summary>
        public async Task<Answer> InscribirDesdeUbicacion(int? aniId, int? aluId, bool crearSecciones, bool activarEstado, int? usuario)
        {
            const string sql = "app.PR_tbMatriculaAnio_InscribirDesdeUbicacion";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = (object)aniId ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = (object)aluId ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@CrearSecciones", DbType = DbType.Boolean, Value = crearSecciones },
                new SqlParameter(){ParameterName= "@ActivarEstado", DbType = DbType.Boolean, Value = activarEstado },
                new SqlParameter(){ParameterName= "@Usuario", DbType = DbType.Int32, Value = (object)usuario ?? DBNull.Value }
            };
            Answer answer = await Search<PR_tbMatriculaAnio_InscribirDesdeUbicacionResult>(sql, sqlParameters);
            return answer;
        }
    }
}
