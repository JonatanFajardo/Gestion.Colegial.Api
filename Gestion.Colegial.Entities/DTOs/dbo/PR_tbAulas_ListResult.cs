using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class AulaListDto
    {
        public int AulaId { get; set; }
        public string DescripcionAula { get; set; }
    }
}
