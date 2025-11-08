using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_tbParciales_ExistResult
    {
        public int Pac_Id { get; set; }
        public string Pac_Descripcion { get; set; }
    }
}