using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_tbEncargados_InsertResult
    {
        [Column("SCOPE_IDENTITY", TypeName = "decimal(38,0)")]
        public decimal? SCOPE_IDENTITY { get; set; }
    }
}