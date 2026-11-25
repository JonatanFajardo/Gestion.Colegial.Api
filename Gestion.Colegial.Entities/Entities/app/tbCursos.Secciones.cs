#nullable disable
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class tbCursos
    {
        /// <summary>
        /// Ids de las secciones que la pantalla de cursos envía al crear o editar un curso
        /// (no es una columna: el vínculo vive en app.tbCursos_tbSecciones). null = no se envió.
        /// </summary>
        [NotMapped]
        public int[] Secciones { get; set; }
    }
}
