using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IRepository<T>
    {
        /// <summary>
        /// Obtiene un listado.
        /// </summary>
        /// <returns>Listado de tipo Answer.</returns>
        Task<List<T>> List();

        /// <summary>
        /// Crea una busqueda.
        /// </summary>
        /// <param name="id">Identificador a buscar.</param>
        /// <returns></returns>
        Task<T> Find(int id);

        /// <summary>
        /// Crea un nuevo registro.
        /// </summary>
        /// <param name="obj">Objeto que recibe los datos.</param>
        /// <returns>Listado de tipo Answer.</returns>
        Task<Boolean> Create(T obj);

        /// <summary>
        /// Edita un registro existente.
        /// </summary>
        /// <param name="obj">Objeto que recibe los datos.</param>
        /// <returns></returns>
        Task<Boolean> Edit(T obj);

        /// <summary>
        /// Elimina un registro.
        /// </summary>
        /// <param name="id">Identificador del registro a eliminar.</param>
        /// <returns></returns>
        Task<Boolean> Delete(int id);
    }
}
