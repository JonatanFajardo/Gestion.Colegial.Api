using Gestion.Colegial.Business.Dtos;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Extensions
{
    public class CustomMapping
    {
        #region Alumnos

        public class AlumnosConversion
        {
            public static tbAlumnos Create(AlumnosFindDto obj)
            {
                tbAlumnos entity = new tbAlumnos
                {
                    Niv_Id = obj.Niv_Id,
                    Cun_Id = obj.Cun_Id,
                    Mda_Id = obj.Mda_Id,
                    Cur_Id = obj.Cur_Id,
                    Sec_Id = obj.Sec_Id,
                    Est_Id = obj.Est_Id,
                    Alu_Id = obj.Alu_Id,
                    Per = new tbPersonas()
                    {
                        Per_Identidad = obj.Per_Identidad,
                        Per_PrimerNombre = obj.Per_PrimerNombre,
                        Per_SegundoNombre = obj.Per_SegundoNombre,
                        Per_ApellidoPaterno = obj.Per_ApellidoPaterno,
                        Per_ApellidoMaterno = obj.Per_ApellidoMaterno,
                        Per_FechaNacimiento = obj.Per_FechaNacimiento,
                        Per_CorreoElectronico = obj.Per_CorreoElectronico,
                        Per_Telefono = obj.Per_Telefono,
                        Per_Direccion = obj.Per_Direccion,
                        Per_Sexo = obj.Per_Sexo,
                        Per_UsuarioRegistra = obj.Per_UsuarioRegistra
                    },
                };
                return entity;
            }

            public static tbAlumnos Edit(AlumnosFindDto obj)
            {
                tbAlumnos entity = new tbAlumnos
                {
                    Niv_Id = obj.Niv_Id,
                    Cun_Id = obj.Cun_Id,
                    Mda_Id = obj.Mda_Id,
                    Cur_Id = obj.Cur_Id,
                    Sec_Id = obj.Sec_Id,
                    Est_Id = obj.Est_Id,
                    Alu_Id = obj.Alu_Id,
                    Per = new tbPersonas()
                    {
                        Per_Id = obj.Per_Id,
                        Per_Identidad = obj.Per_Identidad,
                        Per_PrimerNombre = obj.Per_PrimerNombre,
                        Per_SegundoNombre = obj.Per_SegundoNombre,
                        Per_ApellidoPaterno = obj.Per_ApellidoPaterno,
                        Per_ApellidoMaterno = obj.Per_ApellidoMaterno,
                        Per_FechaNacimiento = obj.Per_FechaNacimiento,
                        Per_CorreoElectronico = obj.Per_CorreoElectronico,
                        Per_Telefono = obj.Per_Telefono,
                        Per_Direccion = obj.Per_Direccion,
                        Per_Sexo = obj.Per_Sexo,
                        Per_EsActivo = obj.Per_EsActivo,
                        Per_UsuarioModifica = obj.Per_UsuarioModifica
                    },
                };
                return entity;
            }
        }

        #endregion Alumnos

        #region Empleados

        public class EmpleadosConversion
        {
            public static tbEmpleados Create(EmpleadosFindDto obj)
            {
                tbEmpleados entity = new tbEmpleados
                {
                    Emp_Codigo = obj.Emp_Codigo,
                    Tit_Id = obj.Tit_Id,
                    Car_Id = obj.Car_Id,
                    Per = new tbPersonas()
                    {
                        Per_Identidad = obj.Per_Identidad,
                        Per_PrimerNombre = obj.Per_PrimerNombre,
                        Per_SegundoNombre = obj.Per_SegundoNombre,
                        Per_ApellidoPaterno = obj.Per_ApellidoPaterno,
                        Per_ApellidoMaterno = obj.Per_ApellidoMaterno,
                        Per_FechaNacimiento = obj.Per_FechaNacimiento,
                        Per_CorreoElectronico = obj.Per_CorreoElectronico,
                        Per_Telefono = obj.Per_Telefono,
                        Per_Direccion = obj.Per_Direccion,
                        Per_Sexo = obj.Per_Sexo,
                        Per_UsuarioRegistra = obj.Per_UsuarioRegistra
                    },
                };
                return entity;
            }

            public static tbEmpleados Edit(EmpleadosFindDto obj)
            {
                tbEmpleados entity = new tbEmpleados
                {
                    Emp_Id = obj.Emp_Id,
                    Emp_Codigo = obj.Emp_Codigo,
                    Tit_Id = obj.Tit_Id,
                    Car_Id = obj.Car_Id,
                    Per = new tbPersonas()
                    {
                        Per_Id = obj.Per_Id,
                        Per_Identidad = obj.Per_Identidad,
                        Per_PrimerNombre = obj.Per_PrimerNombre,
                        Per_SegundoNombre = obj.Per_SegundoNombre,
                        Per_ApellidoPaterno = obj.Per_ApellidoPaterno,
                        Per_ApellidoMaterno = obj.Per_ApellidoMaterno,
                        Per_FechaNacimiento = obj.Per_FechaNacimiento,
                        Per_CorreoElectronico = obj.Per_CorreoElectronico,
                        Per_Telefono = obj.Per_Telefono,
                        Per_Direccion = obj.Per_Direccion,
                        Per_Sexo = obj.Per_Sexo,
                        Per_EsActivo = obj.Per_EsActivo,
                        Per_UsuarioModifica = obj.Per_UsuarioModifica
                    },
                };
                return entity;
            }
        }

        #endregion Empleados

        #region Encargados

        public class EncargadosConversion
        {
            public static tbEncargados Create(EncargadosFindDto obj)
            {
                tbEncargados entity = new tbEncargados
                {
                    Enc_Ocupacion = obj.Enc_Ocupacion,
                    Per = new tbPersonas()
                    {
                        Per_Identidad = obj.Per_Identidad,
                        Per_PrimerNombre = obj.Per_PrimerNombre,
                        Per_SegundoNombre = obj.Per_SegundoNombre,
                        Per_ApellidoPaterno = obj.Per_ApellidoPaterno,
                        Per_ApellidoMaterno = obj.Per_ApellidoMaterno,
                        Per_FechaNacimiento = obj.Per_FechaNacimiento,
                        Per_CorreoElectronico = obj.Per_CorreoElectronico,
                        Per_Telefono = obj.Per_Telefono,
                        Per_Direccion = obj.Per_Direccion,
                        Per_Sexo = obj.Per_Sexo,
                        Per_UsuarioRegistra = obj.Per_UsuarioRegistra
                    },
                };
                return entity;
            }

            public static tbEncargados Edit(EncargadosFindDto obj)
            {
                tbEncargados entity = new tbEncargados
                {
                    Enc_Id = obj.Enc_Id,
                    Enc_Ocupacion = obj.Enc_Ocupacion,
                    Per = new tbPersonas()
                    {
                        Per_Id = obj.Per_Id,
                        Per_Identidad = obj.Per_Identidad,
                        Per_PrimerNombre = obj.Per_PrimerNombre,
                        Per_SegundoNombre = obj.Per_SegundoNombre,
                        Per_ApellidoPaterno = obj.Per_ApellidoPaterno,
                        Per_ApellidoMaterno = obj.Per_ApellidoMaterno,
                        Per_FechaNacimiento = obj.Per_FechaNacimiento,
                        Per_CorreoElectronico = obj.Per_CorreoElectronico,
                        Per_Telefono = obj.Per_Telefono,
                        Per_Direccion = obj.Per_Direccion,
                        Per_Sexo = obj.Per_Sexo,
                        Per_EsActivo = obj.Per_EsActivo,
                        Per_UsuarioModifica = obj.Per_UsuarioModifica
                    },
                };
                return entity;
            }
        }

        #endregion Encargados
    }
}
