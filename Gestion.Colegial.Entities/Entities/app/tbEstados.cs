﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Indica en que estado se encuentra el alumno, activo o inactivo.
    /// </summary>
    public partial class tbEstados
    {
        public tbEstados()
        {
            tbAlumnos = new HashSet<tbAlumnos>();
        }

        /// <summary>
        /// Identificador único de un estado.
        /// </summary>
        public int Est_Id { get; set; }
        /// <summary>
        /// Información del estado actual del alumno en el instituto.
        /// </summary>
        public string Est_Descripcion { get; set; }
        public bool Est_EsEliminado { get; set; }
        public int Est_UsuarioRegistra { get; set; }
        public DateTime Est_FechaRegistra { get; set; }
        public int? Est_UsuarioModifica { get; set; }
        public DateTime? Est_FechaModifica { get; set; }

        public virtual tbUsuarios Est_UsuarioModificaNavigation { get; set; }
        public virtual tbUsuarios Est_UsuarioRegistraNavigation { get; set; }
        public virtual ICollection<tbAlumnos> tbAlumnos { get; set; }
    }
}