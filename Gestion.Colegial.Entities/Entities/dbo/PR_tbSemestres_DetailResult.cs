﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_tbSemestres_DetailResult
    {
        public int? Sem_Id { get; set; }
        public string Sem_Descripcion { get; set; }
        public string Sem_EsActivo { get; set; }
        public string Sem_UsuarioRegistraNombre { get; set; }
        public DateTime? Sem_FechaRegistra { get; set; }
        public string Sem_UsuarioModificaNombre { get; set; }
        public DateTime? Sem_FechaModifica { get; set; }
    }
}
