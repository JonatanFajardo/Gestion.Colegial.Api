using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class CursoRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbCursos_List";
            Answer answer = await Read<PR_tbCursos_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbCursos_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Cur_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbCursos_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbCursos_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Cur_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbCursos_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbCursos obj)
        {
            obj.Cur_UsuarioRegistra = 1;
            const string sql = "PR_tbCursos_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Nombre", DbType = DbType.String, Value = obj.Cur_Nombre},
                new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = obj.Niv_Id},
                new SqlParameter(){ParameterName= "@Cur_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Cur_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbCursos obj)
        {
            obj.Cur_UsuarioModifica = 1;
            const string sql = "PR_tbCursos_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = obj.Cur_Id},
                new SqlParameter(){ParameterName= "@Cur_Nombre", DbType = DbType.Int32, Value = obj.Cur_Nombre},
                new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = obj.Niv_Id},
                new SqlParameter(){ParameterName= "@Cur_EsActivo", DbType = DbType.String, Value = obj.Cur_EsActivo},
                new SqlParameter(){ParameterName= "@Cur_UsuarioModifica", DbType = DbType.Int32, Value = obj.Cur_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        //public async Task<IEnumerable<PR_tbCursos_ExistResult>> Exist(string value)
        //{
        //    const string sql = "PR_tbCursos_Exist";
        //    await db.SaveChangesAsync();
        //    if (resultado == null)
        //    {
        //        return null;
        //    }
        //    return resultado;
        //}

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbCursos_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Cur_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        #region Dropdown

        public async Task<Answer> NivelesEducativosDropdown()
        {
            const string sql = "PR_tbNivelesEducativos_Dropdown";
            Answer answer = await Read<PR_tbNivelesEducativos_DropdownResult>(sql);
            return answer;
        }

        #endregion Dropdown

        #region CheckList

        public async Task<Answer> ModalidadesList()
        {
            const string sql = "PR_tbModalidades_Dropdown";
            Answer answer = await Read<PR_tbModalidades_DropdownResult>(sql);
            return answer;
        }

        public async Task<Answer> MateriasList()
        {
            const string sql = "PR_tbMaterias_Dropdown";
            Answer answer = await Read<PR_tbMaterias_DropdownResult>(sql);
            return answer;
        }

        public async Task<Answer> CursosNivelesList()
        {
            const string sql = "PR_tbCursosNiveles_Dropdown";
            Answer answer = await Read<PR_tbCursosNiveles_DropdownResult>(sql);
            return answer;
        }

        public async Task<Answer> SeccionesList()
        {
            const string sql = "PR_tbSecciones_Dropdown";
            Answer answer = await Read<PR_tbSecciones_DropdownResult>(sql);
            return answer;
        }

        #endregion CheckList

        #region CursosModalidades

        public async Task<Answer> CursosModalidadesCreate(tbCursos obj)
        {
            obj.Cur_UsuarioModifica = 1;
            Answer answer = new Answer();
            const string sql = "PR_tbCursos_tbModalidades_Insert";
            foreach (var idModalidades in obj.Modalidades)
            {
                SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Mda_Id", DbType = DbType.Int32, Value = idModalidades}
                };
                answer = await New(sql, sqlParameters);
            }

            return answer;
        }

        public async Task<Answer> CursosModalidadesEdit(tbCursos obj)
        {
            obj.Cur_UsuarioModifica = 1;
            Answer answer = new Answer();
            const string sql = "PR_tbCursos_tbModalidades_Update";
            foreach (var idModalidades in obj.Modalidades)
            {
                SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = obj.Cur_Id},
                new SqlParameter(){ParameterName= "@Mda_Id", DbType = DbType.Int32, Value = idModalidades}
                };
                answer = await Update(sql, sqlParameters);
            }
            return answer;
        }

        public async Task<Answer> CursosModalidadesFind(int id)
        {
            const string sql = "PR_tbCursos_tbModalidades_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = id}
            };
            Answer answer = await SearchAll<PR_tbCursos_tbModalidades_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> CursosModalidadesDelete(int id)
        {
            const string sql = "PR_tbCursos_tbModalidades_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = id}
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        #endregion CursosModalidades

        #region CursosMaterias

        public async Task<Answer> CursosMateriasCreate(tbCursos obj)
        {
            obj.Cur_UsuarioModifica = 1;
            const string sql = "PR_tbCursos_tbMaterias_Insert";
            Answer answer = new Answer();
            foreach (var idMaterias in obj.Materias)
            {
                SqlParameter[] sqlParameters = {
                    new SqlParameter(){ParameterName= "@Mat_Id", DbType = DbType.Int32, Value = idMaterias}
                };
                answer = await New(sql, sqlParameters);
            }
            return answer;
        }

        public async Task<Answer> CursosMateriasEdit(tbCursos obj)
        {
            obj.Cur_UsuarioModifica = 1;
            const string sql = "PR_tbCursos_tbMaterias_Update";
            Answer answer = new Answer();
            foreach (var idMaterias in obj.Materias)
            {
                SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = obj.Cur_Id},
                new SqlParameter(){ParameterName= "@Mat_Id", DbType = DbType.Int32, Value = idMaterias}
                };
                answer = await Update(sql, sqlParameters);
            }
            return answer;
        }

        public async Task<Answer> CursosMateriasFind(int id)
        {
            const string sql = "PR_tbCursos_tbMaterias_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = id}
            };
            Answer answer = await SearchAll<PR_tbCursos_tbMaterias_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> CursosMateriasDelete(int id)
        {
            const string sql = "PR_tbCursos_tbMaterias_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = id}
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        #endregion CursosMaterias

        #region CursosSecciones

        public async Task<Answer> CursosSeccionesCreate(tbCursos obj)
        {
            obj.Cur_UsuarioModifica = 1;
            const string sql = "PR_tbCursos_tbSecciones_Insert";
            Answer answer = new Answer();
            foreach (var idSecciones in obj.Secciones)
            {
                SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Sec_Id", DbType = DbType.Int32, Value = idSecciones}
                };
                answer = await New(sql, sqlParameters);
            }
            return answer;
        }

        public async Task<Answer> CursosSeccionesEdit(tbCursos obj)
        {
            obj.Cur_UsuarioModifica = 1;
            const string sql = "PR_tbCursos_tbSecciones_Update";
            Answer answer = new Answer();
            foreach (var idSecciones in obj.Secciones)
            {
                SqlParameter[] sqlParameters = {
                    new SqlParameter() { ParameterName = "@Sec_Id", DbType = DbType.Int32, Value = idSecciones },
                    new SqlParameter() { ParameterName = "@Cur_Id", DbType = DbType.Int32, Value = obj.Cur_Id }
                };
                answer = await New(sql, sqlParameters);
            }
            return answer;
        }

        public async Task<Answer> CursosSeccionesFind(int id)
        {
            const string sql = "PR_tbCursos_tbSecciones_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = id}
            };
            Answer answer = await SearchAll<PR_tbCursos_tbSecciones_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> CursosSeccionesDelete(int id)
        {
            const string sql = "PR_tbCursos_tbSecciones_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = id}
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        #endregion CursosSecciones

        #region CursosNiveles

        public async Task<Answer> CursosNivelesCreate(tbCursos obj)
        {
            obj.Cur_UsuarioModifica = 1;
            const string sql = "PR_tbCursos_tbCursosNiveles_Insert";
            Answer answer = new Answer();
            foreach (var idCursoNiveles in obj.CursoNiveles)
            {
                SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = idCursoNiveles}
                };
                answer = await New(sql, sqlParameters);
            }
            return answer;
        }

        public async Task<Answer> CursosNivelesEdit(tbCursos obj)
        {
            obj.Cur_UsuarioModifica = 1;
            const string sql = "PR_tbCursos_tbCursosNiveles_Update";
            Answer answer = new Answer();
            foreach (var idCursoNiveles in obj.CursoNiveles)
            {
                SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = idCursoNiveles},
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = obj.Cur_Id}
                };
                answer = await New(sql, sqlParameters);
            }
            return answer;
        }

        public async Task<Answer> CursosNivelesFind(int id)
        {
            const string sql = "PR_tbCursos_tbCursosNiveles_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = id}
            };
            Answer answer = await SearchAll<PR_tbCursos_tbCursosNiveles_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> CursosNivelesDelete(int id)
        {
            const string sql = "PR_tbCursos_tbCursosNiveles_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cur_Id", DbType = DbType.Int32, Value = id}
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        #endregion CursosNiveles
    }
}