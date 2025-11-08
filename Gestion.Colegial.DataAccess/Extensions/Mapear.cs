using System.Data;
using System.Reflection;

namespace Gestion.Colegial.DataAccess.Extensions
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
                List<T> data = new List<T>();
                foreach (DataRow row in datatable.Rows)
                {
                    T item = GetItem<T>(row);
                    data.Add(item);
                }
                return data;
            }

            private static T GetItem<T>(DataRow dr)
            {
                Type temp = typeof(T);
                T obj = Activator.CreateInstance<T>();
                foreach (DataColumn column in dr.Table.Columns)
                {
                    foreach (PropertyInfo pro in temp.GetProperties())
                    {
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