//using Gestion.Colegial.DataAccess.Access;
//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Threading.Tasks;

//namespace GESTION_COLEGIAL.DataAccess.Repositories
//{
//    public class PersonaRepository : RepositoryBase
//    {
//        ConnectionString_GestionColegial_Entities db = new ConnectionString_GestionColegial_Entities();
//        public async Task<Answer> Create(tbPersonas obj)
//        {
//            obj.Per_UsuarioRegistra = 1;
//            const string sql = "PR_tbPersonas_Insert(obj.Per_Identidad, obj.Per_PrimerNombre, obj.Per_SegundoNombre, obj.Per_ApellidoPaterno, obj.Per_ApellidoMaterno, obj.Per_FechaNacimiento, obj.Per_CorreoElectronico, obj.Per_Telefono, obj.Per_Direccion, obj.Per_Sexo, obj.Per_EsActivo, obj.Per_UsuarioRegistra);
//            await db.SaveChangesAsync();
//            if (resultado == 0)
//            {
//                return true;
//            }
//            return false;
//        }

//        public async Task<PR_tbModalidades_ExistResult> Exist(string value)
//        {
//            const string sql = "PR_tbModalidades_Exist";
//            await db.SaveChangesAsync();
//            if (resultado == null)
//            {
//                return null;
//            }
//            return resultado;
//        }

//        public async Task<Answer> Delete(int id)
//        {
//            const string sql = "PR_tbPersonas_Delete";
//            await db.SaveChangesAsync();
//            if (resultado == 0)
//            {
//                return true;
//            }
//            return false;
//        }

//        public async Task<Answer> Edit(tbPersonas obj)
//        {
//            obj.Per_UsuarioModifica = 1;
//            const string sql = "PR_tbPersonas_Update(obj.Per_Id, obj.Per_Identidad, obj.Per_PrimerNombre, obj.Per_SegundoNombre, obj.Per_ApellidoPaterno, obj.Per_ApellidoMaterno, obj.Per_FechaNacimiento, obj.Per_CorreoElectronico, obj.Per_Telefono, obj.Per_Direccion, obj.Per_Sexo, obj.Per_EsActivo, obj.Per_UsuarioModifica);
//            await db.SaveChangesAsync();
//            if (resultado == 0)
//            {
//                return true;
//            }
//            return false;
//        }
//        public async Task<PR_tbModalidades_FindResult> Find(int id)
//        {
//            const string sql = "PR_tbModalidades_Find";
//            await db.SaveChangesAsync();
//            if (resultado == null)
//            {
//                return null;
//            }
//            return resultado;
//        }

//        public async Task<PR_tbTitulos_DetailResult> Detail(int id)
//        {
//            const string sql = "PR_tbTitulos_Detail";
//            await db.SaveChangesAsync();
//            if (resultado == null)
//            {
//                return null;
//            }
//            return resultado;
//        }

//        public async Task<IEnumerable<PR_tbModalidades_ListResult>> List()
//        {
//            const string sql = "PR_tbModalidades_List";
//            await db.SaveChangesAsync();
//            if (resultado == null)
//            {
//                return null;
//            }
//            return resultado;
//        }
//    }
//}