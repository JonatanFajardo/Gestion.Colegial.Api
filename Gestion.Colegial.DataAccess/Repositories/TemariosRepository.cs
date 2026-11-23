using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Temario y avance del programa (script 074). Toda lectura y escritura recibe el usuario: el
    /// procedimiento calcula con él sus permisos y las materias o secciones que imparte.
    /// Las escrituras devuelven una fila (Id, Tem_Id, Cantidad), por eso usan Search; si el procedimiento
    /// lanza un error, Search lo deja en Answer y no lo relanza.
    /// </summary>
    public class TemariosRepository : RepositoryBase, ITemariosRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Fecha(string nombre, DateTime? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Date, Value = valor.HasValue ? valor.Value.Date : DBNull.Value };

        private static SqlParameter Texto(string nombre, string? valor, DbType tipo = DbType.String) =>
            new SqlParameter() { ParameterName = nombre, DbType = tipo, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        private static SqlParameter Usuario(TemarioEscritorDTO obj) => Entero("@Usuario", obj.Usuario);

        public async Task<Answer> List(int usuId) =>
            await Read<PR_tbTemarios_ListResult>("app.PR_tbTemarios_List", new[] { Entero("@Usu_Id", usuId) });

        /// <summary>Sin fila (Data null) si no existe o la persona no lo puede leer.</summary>
        public async Task<Answer> Find(int id, int usuId) =>
            await Search<PR_tbTemarios_ListResult>("app.PR_tbTemarios_Find", new[] { Entero("@Tem_Id", id), Entero("@Usu_Id", usuId) });

        public async Task<Answer> Temas(int id, int usuId) =>
            await Read<PR_tbTemarioTemas_ListResult>("app.PR_tbTemarioTemas_List", new[] { Entero("@Tem_Id", id), Entero("@Usu_Id", usuId) });

        public async Task<Answer> Grupos(int id, int usuId) =>
            await Read<PR_tbTemarios_GruposResult>("app.PR_tbTemarios_Grupos", new[] { Entero("@Tem_Id", id), Entero("@Usu_Id", usuId) });

        public async Task<Answer> Avance(int id, int usuId) =>
            await Read<PR_tbTemarioAvance_ListResult>("app.PR_tbTemarioAvance_List", new[] { Entero("@Tem_Id", id), Entero("@Usu_Id", usuId) });

        public async Task<Answer> Resumen(int usuId, int? anio, int? semId) =>
            await Read<PR_tbTemarios_ResumenResult>("app.PR_tbTemarios_Resumen",
                new[] { Entero("@Usu_Id", usuId), Entero("@Anio", anio), Entero("@Sem_Id", semId) });

        public async Task<Answer> SinTemario(int usuId, int? anio, int? semId) =>
            await Read<PR_tbTemarios_SinTemarioResult>("app.PR_tbTemarios_SinTemario",
                new[] { Entero("@Usu_Id", usuId), Entero("@Anio", anio), Entero("@Sem_Id", semId) });

        public async Task<Answer> Opciones(int usuId, string tipo, int? nivId, int? cunId, int? curId, int? anio) =>
            await Read<PR_tbTemarios_OpcionResult>("app.PR_tbTemarios_Opciones", new[]
            {
                Entero("@Usu_Id", usuId), Texto("@Tipo", tipo, DbType.AnsiString),
                Entero("@Niv_Id", nivId), Entero("@Cun_Id", cunId), Entero("@Cur_Id", curId), Entero("@Anio", anio)
            });

        public async Task<Answer> TemasDeHorario(int horId, int semana, int usuId) =>
            await Read<PR_tbTemarios_TemaHorarioResult>("app.PR_tbTemarios_TemasDeHorario",
                new[] { Entero("@Hor_Id", horId), Entero("@Semana", semana), Entero("@Usu_Id", usuId) });

        private Task<Answer> Escribir(string procedimiento, IEnumerable<SqlParameter> parametros) =>
            Search<PR_tbTemarios_EscrituraResult>(procedimiento, parametros.ToArray());

        public Task<Answer> Crear(TemarioGuardarDTO obj) => Escribir("app.PR_tbTemarios_Crear", new[]
        {
            Entero("@Mat_Id", obj.Mat_Id), Entero("@Cun_Id", obj.Cun_Id), Entero("@Cur_Id", obj.Cur_Id),
            Entero("@Sem_Id", obj.Sem_Id), Entero("@Tem_Anio", obj.Tem_Anio), Texto("@Tem_Nombre", obj.Tem_Nombre),
            Texto("@Tem_Descripcion", obj.Tem_Descripcion), Fecha("@Tem_FechaInicio", obj.Tem_FechaInicio), Usuario(obj)
        });

        public Task<Answer> Editar(TemarioGuardarDTO obj) => Escribir("app.PR_tbTemarios_Editar", new[]
        {
            Entero("@Tem_Id", obj.Tem_Id), Texto("@Tem_Nombre", obj.Tem_Nombre), Texto("@Tem_Descripcion", obj.Tem_Descripcion),
            Fecha("@Tem_FechaInicio", obj.Tem_FechaInicio), Usuario(obj)
        });

        public Task<Answer> Eliminar(TemarioEliminarDTO obj) =>
            Escribir("app.PR_tbTemarios_Eliminar", new[] { Entero("@Tem_Id", obj.Tem_Id), Usuario(obj) });

        public Task<Answer> Copiar(TemarioCopiarDTO obj) => Escribir("app.PR_tbTemarios_Copiar", new[]
        {
            Entero("@Tem_IdOrigen", obj.Tem_IdOrigen), Entero("@Tem_IdDestino", obj.Tem_IdDestino),
            Entero("@Sem_Id", obj.Sem_Id), Entero("@Tem_Anio", obj.Tem_Anio), Texto("@Tem_Nombre", obj.Tem_Nombre),
            Fecha("@Tem_FechaInicio", obj.Tem_FechaInicio), Usuario(obj)
        });

        public Task<Answer> GuardarTema(TemarioTemaDTO obj) => Escribir("app.PR_tbTemarioTemas_Guardar", new[]
        {
            Entero("@Tet_Id", obj.Tet_Id), Entero("@Tem_Id", obj.Tem_Id), Entero("@Tet_Semana", obj.Tet_Semana),
            Texto("@Tet_Titulo", obj.Tet_Titulo), Texto("@Tet_Objetivos", obj.Tet_Objetivos),
            Texto("@Tet_Contenido", obj.Tet_Contenido), Texto("@Tet_Recursos", obj.Tet_Recursos), Usuario(obj)
        });

        public Task<Answer> MoverTema(TemarioTemaAccionDTO obj) => Escribir("app.PR_tbTemarioTemas_Mover", new[]
        {
            Entero("@Tet_Id", obj.Tet_Id), Texto("@Direccion", obj.Direccion, DbType.AnsiString), Usuario(obj)
        });

        public Task<Answer> QuitarTema(TemarioTemaAccionDTO obj) =>
            Escribir("app.PR_tbTemarioTemas_Quitar", new[] { Entero("@Tet_Id", obj.Tet_Id), Usuario(obj) });

        public Task<Answer> MarcarAvance(TemarioAvanceDTO obj) => Escribir("app.PR_tbTemarioAvance_Marcar", new[]
        {
            Entero("@Tet_Id", obj.Tet_Id), Entero("@Cur_Id", obj.Cur_Id), Entero("@Sec_Id", obj.Sec_Id), Entero("@Mda_Id", obj.Mda_Id),
            Texto("@Tav_Estado", obj.Tav_Estado, DbType.AnsiString), Fecha("@Tav_Fecha", obj.Tav_Fecha),
            Texto("@Tav_Nota", obj.Tav_Nota), Usuario(obj)
        });

        public Task<Answer> QuitarAvance(TemarioAvanceDTO obj) => Escribir("app.PR_tbTemarioAvance_Quitar", new[]
        {
            Entero("@Tet_Id", obj.Tet_Id), Entero("@Cur_Id", obj.Cur_Id), Entero("@Sec_Id", obj.Sec_Id), Entero("@Mda_Id", obj.Mda_Id), Usuario(obj)
        });
    }
}
