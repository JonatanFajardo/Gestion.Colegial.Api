﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class tbHorarioAlumnosHistorial
    {
        public int HoAl_Id { get; set; }
        public int? Cur_Id { get; set; }
        public int? Cun_Id { get; set; }
        public int? Mat_Id { get; set; }
        public int? HoAl_HoraInicio { get; set; }
        public int? HoAl_HoraFinaliza { get; set; }
        public int? Dia_Id { get; set; }
        public bool? EsEliminado { get; set; }
        public string Accion { get; set; }
        public DateTime? Fecha { get; set; }
        public string Usuario { get; set; }
        public string HostName { get; set; }
    }
}