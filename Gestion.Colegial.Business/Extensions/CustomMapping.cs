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

        #region Tarifas

        public class TarifasConversion
        {
            public static tbTarifas Create(object obj)
            {
                dynamic dto = obj;
                tbTarifas entity = new tbTarifas
                {
                    Cpa_Id = dto.ConceptoPagoId,
                    Niv_Id = dto.NivelId,
                    Cun_Id = dto.CursoNivelId,
                    Tar_Monto = dto.Monto,
                    Tar_AnioVigencia = dto.AnioVigencia,
                    Tar_UsuarioRegistra = dto.UsuarioRegistraId ?? 1
                };
                return entity;
            }

            public static tbTarifas Edit(object obj)
            {
                dynamic dto = obj;
                tbTarifas entity = new tbTarifas
                {
                    Tar_Id = dto.TarifaId,
                    Cpa_Id = dto.ConceptoPagoId,
                    Niv_Id = dto.NivelId,
                    Cun_Id = dto.CursoNivelId,
                    Tar_Monto = dto.Monto,
                    Tar_AnioVigencia = dto.AnioVigencia,
                    Tar_UsuarioModifica = dto.UsuarioModificaId ?? 1
                };
                return entity;
            }
        }

        #endregion Tarifas

        #region ConceptosPago

        public class ConceptosPagoConversion
        {
            public static tbConceptosPago Create(object obj)
            {
                dynamic dto = obj;
                tbConceptosPago entity = new tbConceptosPago
                {
                    Cpa_Descripcion = dto.Descripcion,
                    Cpa_EsRecurrente = dto.EsRecurrente,
                    Cpa_EsObligatorio = dto.EsObligatorio,
                    Cpa_UsuarioRegistra = dto.UsuarioRegistraId ?? 1
                };
                return entity;
            }

            public static tbConceptosPago Edit(object obj)
            {
                dynamic dto = obj;
                tbConceptosPago entity = new tbConceptosPago
                {
                    Cpa_Id = dto.ConceptoPagoId,
                    Cpa_Descripcion = dto.Descripcion,
                    Cpa_EsRecurrente = dto.EsRecurrente,
                    Cpa_EsObligatorio = dto.EsObligatorio,
                    Cpa_UsuarioModifica = dto.UsuarioModificaId ?? 1
                };
                return entity;
            }
        }

        #endregion ConceptosPago

        #region FormasPago

        public class FormasPagoConversion
        {
            public static tbFormasPago Create(object obj)
            {
                dynamic dto = obj;
                tbFormasPago entity = new tbFormasPago
                {
                    Fpa_Descripcion = dto.Descripcion,
                    Fpa_EsActivo = dto.EsActivo,
                    Fpa_UsuarioRegistra = dto.UsuarioRegistraId ?? 1
                };
                return entity;
            }

            public static tbFormasPago Edit(object obj)
            {
                dynamic dto = obj;
                tbFormasPago entity = new tbFormasPago
                {
                    Fpa_Id = dto.FormaPagoId,
                    Fpa_Descripcion = dto.Descripcion,
                    Fpa_EsActivo = dto.EsActivo,
                    Fpa_UsuarioModifica = dto.UsuarioModificaId ?? 1
                };
                return entity;
            }
        }

        #endregion FormasPago

        #region Descuentos

        public class DescuentosConversion
        {
            public static tbDescuentos Create(object obj)
            {
                dynamic dto = obj;
                tbDescuentos entity = new tbDescuentos
                {
                    Des_Descripcion = dto.Descripcion,
                    Des_TipoDescuento = dto.TipoDescuento,
                    Des_Valor = dto.Valor,
                    Des_EsActivo = dto.EsActivo,
                    Des_UsuarioRegistra = dto.UsuarioRegistraId ?? 1
                };
                return entity;
            }

            public static tbDescuentos Edit(object obj)
            {
                dynamic dto = obj;
                tbDescuentos entity = new tbDescuentos
                {
                    Des_Id = dto.DescuentoId,
                    Des_Descripcion = dto.Descripcion,
                    Des_TipoDescuento = dto.TipoDescuento,
                    Des_Valor = dto.Valor,
                    Des_EsActivo = dto.EsActivo,
                    Des_UsuarioModifica = dto.UsuarioModificaId ?? 1
                };
                return entity;
            }
        }

        #endregion Descuentos

        #region CuentasCobrar

        public class CuentasCobrarConversion
        {
            public static tbCuentasCobrar Create(object obj)
            {
                dynamic dto = obj;
                tbCuentasCobrar entity = new tbCuentasCobrar
                {
                    Alu_Id = dto.AlumnoId,
                    Cpa_Id = dto.ConceptoPagoId,
                    Tar_Id = dto.TarifaId,
                    Cco_MontoOriginal = dto.MontoOriginal,
                    Cco_MontoDescuento = dto.MontoDescuento ?? 0,
                    Cco_MontoMora = dto.MontoMora ?? 0,
                    Cco_MontoTotal = dto.MontoTotal,
                    Cco_MontoPendiente = dto.MontoPendiente,
                    Cco_FechaEmision = dto.FechaEmision,
                    Cco_FechaVencimiento = dto.FechaVencimiento,
                    Epa_Id = dto.EstadoPagoId,
                    Cco_Observaciones = dto.Observaciones,
                    Cco_UsuarioRegistra = dto.UsuarioRegistraId ?? 1
                };
                return entity;
            }

            public static tbCuentasCobrar Edit(object obj)
            {
                dynamic dto = obj;
                tbCuentasCobrar entity = new tbCuentasCobrar
                {
                    Cco_Id = dto.CuentaCobrarId,
                    Alu_Id = dto.AlumnoId,
                    Cpa_Id = dto.ConceptoPagoId,
                    Tar_Id = dto.TarifaId,
                    Cco_MontoOriginal = dto.MontoOriginal,
                    Cco_MontoDescuento = dto.MontoDescuento ?? 0,
                    Cco_MontoMora = dto.MontoMora ?? 0,
                    Cco_MontoTotal = dto.MontoTotal,
                    Cco_MontoPendiente = dto.MontoPendiente,
                    Cco_FechaEmision = dto.FechaEmision,
                    Cco_FechaVencimiento = dto.FechaVencimiento,
                    Epa_Id = dto.EstadoPagoId,
                    Cco_Observaciones = dto.Observaciones,
                    Cco_UsuarioModifica = dto.UsuarioModificaId ?? 1
                };
                return entity;
            }
        }

        #endregion CuentasCobrar

        #region Pagos

        public class PagosConversion
        {
            public static tbPagos Create(object obj)
            {
                dynamic dto = obj;
                tbPagos entity = new tbPagos
                {
                    Alu_Id = dto.AlumnoId,
                    Enc_Id = dto.EncargadoId,
                    Fpa_Id = dto.FormaPagoId,
                    Pag_MontoTotal = dto.MontoTotal,
                    Pag_FechaPago = dto.FechaPago,
                    Pag_NumeroReferencia = dto.NumeroReferencia,
                    Pag_Observaciones = dto.Observaciones,
                    Usu_Id = dto.UsuarioId,
                    Pag_UsuarioRegistra = dto.UsuarioRegistraId ?? 1
                };
                return entity;
            }
        }

        #endregion Pagos
    }
}
