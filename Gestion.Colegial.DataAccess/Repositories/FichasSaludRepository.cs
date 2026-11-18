using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Ficha de salud del alumno (script 070). Guardar devuelve una fila, por eso usa Search;
    /// si el procedimiento lanza un error de validación, queda en Answer (Incidents).
    /// </summary>
    public class FichasSaludRepository : RepositoryBase, IFichasSaludRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Booleano(string nombre, bool valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Boolean, Value = valor };

        private static SqlParameter Fecha(string nombre, DateTime? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Date, Value = valor.HasValue ? valor.Value.Date : DBNull.Value };

        private static SqlParameter Texto(string nombre, string? valor, DbType tipo = DbType.String) =>
            new SqlParameter() { ParameterName = nombre, DbType = tipo, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        public async Task<Answer> Directorio(int? nivId, int? cunId, int? secId, string? texto, bool soloSinFicha, bool soloConAlerta)
        {
            SqlParameter[] p =
            {
                Entero("@Niv_Id", nivId), Entero("@Cun_Id", cunId), Entero("@Sec_Id", secId), Texto("@Texto", texto),
                Booleano("@SoloSinFicha", soloSinFicha), Booleano("@SoloConAlerta", soloConAlerta)
            };
            return await Read<PR_tbFichasSalud_DirectorioResult>("app.PR_tbFichasSalud_Directorio", p);
        }

        /// <summary>Sin fila (Data null) si el alumno no existe.</summary>
        public async Task<Answer> Find(int aluId) =>
            await Search<PR_tbFichasSalud_FindResult>("app.PR_tbFichasSalud_Find", new[] { Entero("@Alu_Id", aluId) });

        public async Task<Answer> Contactos(int aluId) =>
            await Read<PR_tbFichasSalud_ContactosResult>("app.PR_tbFichasSalud_Contactos", new[] { Entero("@Alu_Id", aluId) });

        public async Task<Answer> Bitacora(int aluId) =>
            await Read<PR_tbFichasSaludBitacora_ListResult>("app.PR_tbFichasSaludBitacora_List", new[] { Entero("@Alu_Id", aluId) });

        public async Task<Answer> AlertasSeccion(int horId, DateTime? fecha) =>
            await Read<PR_tbFichasSalud_AlertasSeccionResult>("app.PR_tbFichasSalud_AlertasSeccion",
                new[] { Entero("@Hor_Id", horId), Fecha("@Fecha", fecha) });

        public async Task<Answer> Guardar(FichaSaludGuardarDTO obj)
        {
            SqlParameter[] p =
            {
                Entero("@Alu_Id", obj.Alu_Id),
                Texto("@Fsa_TipoSangre", obj.Fsa_TipoSangre, DbType.AnsiString),
                Booleano("@Fsa_TieneAlerta", obj.Fsa_TieneAlerta),
                Texto("@Fsa_Alerta", obj.Fsa_Alerta),
                Texto("@Fsa_Alergias", obj.Fsa_Alergias),
                Texto("@Fsa_Condiciones", obj.Fsa_Condiciones),
                Texto("@Fsa_Medicamentos", obj.Fsa_Medicamentos),
                Texto("@Fsa_RestriccionesAlimentarias", obj.Fsa_RestriccionesAlimentarias),
                Texto("@Fsa_MedicoNombre", obj.Fsa_MedicoNombre),
                Texto("@Fsa_MedicoTelefono", obj.Fsa_MedicoTelefono, DbType.AnsiString),
                Texto("@Fsa_Hospital", obj.Fsa_Hospital),
                Texto("@Fsa_Seguro", obj.Fsa_Seguro),
                Texto("@Fsa_SeguroPoliza", obj.Fsa_SeguroPoliza),
                Texto("@Fsa_ContactoEmergenciaNombre", obj.Fsa_ContactoEmergenciaNombre),
                Texto("@Fsa_ContactoEmergenciaParentesco", obj.Fsa_ContactoEmergenciaParentesco),
                Texto("@Fsa_ContactoEmergenciaTelefono", obj.Fsa_ContactoEmergenciaTelefono, DbType.AnsiString),
                Texto("@Fsa_Notas", obj.Fsa_Notas),
                Entero("@Fsa_Version", obj.Fsa_Version),
                Entero("@Usuario", obj.Usuario)
            };
            return await Search<PR_tbFichasSalud_GuardarResult>("app.PR_tbFichasSalud_Guardar", p);
        }
    }
}
