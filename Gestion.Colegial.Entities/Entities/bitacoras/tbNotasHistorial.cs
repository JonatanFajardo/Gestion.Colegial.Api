﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class tbNotasHistorial
    {
        public int Not_Id { get; set; }
        public int? Not_Nota { get; set; }
        public int? Mat_Id { get; set; }
        public int? Sem_Id { get; set; }
        public int? Pac_Id { get; set; }
        public DateTime? Not_Ano { get; set; }
        public bool? EsActivo { get; set; }
        public bool? EsEliminado { get; set; }
        public string Accion { get; set; }
        public DateTime? Fecha { get; set; }
        public string Usuario { get; set; }
        public string HostName { get; set; }
    }
}