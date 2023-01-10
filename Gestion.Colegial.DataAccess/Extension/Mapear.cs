using System;
using System.Collections.Generic;
using System.Data;
using System.Reflection;

namespace Gestion.Colegial.DataAccess.Extension
{
    internal class Mapear
    {
        internal class Convert
        {
            /// <summary>
            /// Convertimos un DataTable a una lista del tipo especificado.
            /// </summary>
            /// <typeparam name="T">Tipo el cual retornara.</typeparam>
            /// <param name="datatable">Datatable a convertir.</param>
            /// <returns>Listado de tipo especifico.</returns>
            public static List<T> ToList<T>(DataTable datatable)
            {
                // Creamos una lista on el tipo de dato recibido
                List<T> data = new List<T>();
                // Recorremos las rows
                foreach (DataRow row in datatable.Rows)
                {
                    T item = GetItem<T>(row);
                    data.Add(item);
                }
                return data;
            }

            private static T GetItem<T>(DataRow dr)
            {
                // Obtenemos el tipo de dato obtenido.
                Type temp = typeof(T);
                // creamos uns intancia del objeto.
                T obj = Activator.CreateInstance<T>();
                //recorremos las columnas de la tabla que contenga el datarow.
                foreach (DataColumn column in dr.Table.Columns)
                {
                    // Recorrido de las propiedades del objeto recibido.
                    foreach (PropertyInfo pro in temp.GetProperties())
                    {
                        // si la columna y la propiedad del tipo de dato que se obtuvo son las mismas, se le asigna el nombre.
                        if (pro.Name == column.ColumnName)
                            pro.SetValue(obj, dr[column.ColumnName], null);
                        else
                            continue;
                    }
                }
                return obj;
            }
        }
    }
}
