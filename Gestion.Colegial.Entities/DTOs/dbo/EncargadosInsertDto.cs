using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class EncargadoInsertDto
    {
        [Column("ScopeIdentity", TypeName = "decimal(38,0)")]
        public decimal? ScopeIdentity { get; set; }
    }
}