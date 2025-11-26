using AutoMapper;
using Gestion.Colegial.Entities.DTOs.finansas;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Mapping;

public class DtoMappingProfile : Profile
{
    public DtoMappingProfile()
    {
        ConfigureTarifas();
        ConfigureConceptosPago();
        ConfigureCuentasCobrar();
        ConfigureDescuentos();
        ConfigureDescuentosAplicados();
        ConfigureEstadosPago();
        ConfigureFormasPago();
        ConfigureMoratorias();
        ConfigurePagos();
        ConfigurePagosDetalle();
        ConfigureRecibos();
        ConfigureEstadoCuenta();
    }

    private void ConfigureTarifas()
    {
        CreateMap<PR_tbTarifas_ListResult, TarifaListDto>()
            .ForMember(dest => dest.TarifaId, opt => opt.MapFrom(src => src.Tar_Id))
            .ForMember(dest => dest.ConceptoPagoId, opt => opt.MapFrom(src => src.Cpa_Id))
            .ForMember(dest => dest.Monto, opt => opt.MapFrom(src => src.Tar_Monto))
            .ForMember(dest => dest.AnioVigencia, opt => opt.MapFrom(src => src.Tar_AnioVigencia));

        CreateMap<PR_tbTarifas_FindResult, TarifaFindDto>()
            .ForMember(dest => dest.TarifaId, opt => opt.MapFrom(src => src.Tar_Id))
            .ForMember(dest => dest.ConceptoPagoId, opt => opt.MapFrom(src => src.Cpa_Id))
            .ForMember(dest => dest.NivelId, opt => opt.MapFrom(src => src.Niv_Id))
            .ForMember(dest => dest.CursoNivelId, opt => opt.MapFrom(src => src.Cun_Id))
            .ForMember(dest => dest.Monto, opt => opt.MapFrom(src => src.Tar_Monto))
            .ForMember(dest => dest.AnioVigencia, opt => opt.MapFrom(src => src.Tar_AnioVigencia));

        CreateMap<PR_tbTarifas_DetailResult, TarifaDetailDto>()
            .ForMember(dest => dest.TarifaId, opt => opt.MapFrom(src => src.Tar_Id))
            .ForMember(dest => dest.ConceptoPagoId, opt => opt.MapFrom(src => src.Cpa_Id))
            .ForMember(dest => dest.NivelId, opt => opt.MapFrom(src => src.Niv_Id))
            .ForMember(dest => dest.CursoNivelId, opt => opt.MapFrom(src => src.Cun_Id))
            .ForMember(dest => dest.Monto, opt => opt.MapFrom(src => src.Tar_Monto))
            .ForMember(dest => dest.AnioVigencia, opt => opt.MapFrom(src => src.Tar_AnioVigencia))
            .ForMember(dest => dest.EsActivo, opt => opt.MapFrom(src => src.Tar_EsActivo))
            .ForMember(dest => dest.Concepto, opt => opt.MapFrom(src => src.Concepto ?? string.Empty))
            .ForMember(dest => dest.EsEliminado, opt => opt.MapFrom(src => src.Tar_EsEliminado))
            .ForMember(dest => dest.UsuarioRegistraId, opt => opt.MapFrom(src => src.Tar_UsuarioRegistra))
            .ForMember(dest => dest.NombreCompletoUsuarioRegistra, opt => opt.MapFrom(src => src.NombreCompletoUsuarioRegistra ?? string.Empty))
            .ForMember(dest => dest.FechaRegistro, opt => opt.MapFrom(src => src.Tar_FechaRegistra))
            .ForMember(dest => dest.UsuarioModificaId, opt => opt.MapFrom(src => src.Tar_UsuarioModifica))
            .ForMember(dest => dest.NombreCompletoUsuarioModifica, opt => opt.MapFrom(src => src.NombreCompletoUsuarioModifica))
            .ForMember(dest => dest.FechaModifica, opt => opt.MapFrom(src => src.Tar_FechaModifica));

        CreateMap<PR_tbTarifas_DropdownResult, TarifaDropdownDto>()
            .ForMember(dest => dest.TarifaId, opt => opt.MapFrom(src => src.Tar_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Texto));

        CreateMap<PR_tbTarifas_ExistResult, TarifaExistDto>()
            .ForMember(dest => dest.Existe, opt => opt.MapFrom(src => src.Exists))
            .ForMember(dest => dest.Mensaje, opt => opt.MapFrom(src => src.Message));

        CreateMap<PR_tbTarifas_GetByConceptoAndNivelResult, TarifaFindDto>()
            .ForMember(dest => dest.TarifaId, opt => opt.MapFrom(src => src.Tar_Id))
            .ForMember(dest => dest.ConceptoPagoId, opt => opt.MapFrom(src => src.Cpa_Id))
            .ForMember(dest => dest.NivelId, opt => opt.MapFrom(src => src.Niv_Id))
            .ForMember(dest => dest.CursoNivelId, opt => opt.MapFrom(src => src.Cun_Id))
            .ForMember(dest => dest.Monto, opt => opt.MapFrom(src => src.Tar_Monto))
            .ForMember(dest => dest.AnioVigencia, opt => opt.MapFrom(src => src.Tar_AnioVigencia));
    }

    private void ConfigureConceptosPago()
    {
        CreateMap<PR_tbConceptosPago_ListResult, ConceptoPagoListDto>()
            .ForMember(dest => dest.ConceptoPagoId, opt => opt.MapFrom(src => src.Cpa_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Cpa_Descripcion))
            .ForMember(dest => dest.EsRecurrente, opt => opt.MapFrom(src => src.Cpa_EsRecurrente))
            .ForMember(dest => dest.EsObligatorio, opt => opt.MapFrom(src => src.Cpa_EsObligatorio))
            .ForMember(dest => dest.EsActivo, opt => opt.MapFrom(src => src.Cpa_EsActivo));

        CreateMap<PR_tbConceptosPago_FindResult, ConceptoPagoFindDto>()
            .ForMember(dest => dest.ConceptoPagoId, opt => opt.MapFrom(src => src.Cpa_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Cpa_Descripcion))
            .ForMember(dest => dest.EsRecurrente, opt => opt.MapFrom(src => src.Cpa_EsRecurrente))
            .ForMember(dest => dest.EsObligatorio, opt => opt.MapFrom(src => src.Cpa_EsObligatorio))
            .ForMember(dest => dest.EsActivo, opt => opt.MapFrom(src => src.Cpa_EsActivo));

        CreateMap<PR_tbConceptosPago_DetailResult, ConceptoPagoDetailDto>()
            .ForMember(dest => dest.ConceptoPagoId, opt => opt.MapFrom(src => src.Cpa_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Cpa_Descripcion ?? string.Empty))
            .ForMember(dest => dest.EsRecurrente, opt => opt.MapFrom(src => src.Cpa_EsRecurrente))
            .ForMember(dest => dest.EsObligatorio, opt => opt.MapFrom(src => src.Cpa_EsObligatorio))
            .ForMember(dest => dest.EsActivo, opt => opt.MapFrom(src => src.Cpa_EsActivo))
            .ForMember(dest => dest.CantTarifas, opt => opt.MapFrom(src => src.CantTarifas ?? 0))
            .ForMember(dest => dest.EsEliminado, opt => opt.MapFrom(src => src.Cpa_EsEliminado))
            .ForMember(dest => dest.UsuarioRegistraId, opt => opt.MapFrom(src => src.Cpa_UsuarioRegistra))
            .ForMember(dest => dest.NombreCompletoUsuarioRegistra, opt => opt.MapFrom(src => src.NombreCompletoUsuarioRegistra ?? string.Empty))
            .ForMember(dest => dest.FechaRegistro, opt => opt.MapFrom(src => src.Cpa_FechaRegistra))
            .ForMember(dest => dest.UsuarioModificaId, opt => opt.MapFrom(src => src.Cpa_UsuarioModifica))
            .ForMember(dest => dest.NombreCompletoUsuarioModifica, opt => opt.MapFrom(src => src.NombreCompletoUsuarioModifica))
            .ForMember(dest => dest.FechaModifica, opt => opt.MapFrom(src => src.Cpa_FechaModifica));

        CreateMap<PR_tbConceptosPago_DropdownResult, ConceptoPagoDropdownDto>()
            .ForMember(dest => dest.ConceptoPagoId, opt => opt.MapFrom(src => src.Cpa_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Cpa_Descripcion));

        CreateMap<PR_tbConceptosPago_ExistResult, ConceptoPagoExistDto>()
            .ForMember(dest => dest.Existe, opt => opt.MapFrom(src => src.Exists))
            .ForMember(dest => dest.Mensaje, opt => opt.MapFrom(src => src.Message));
    }

    private void ConfigureCuentasCobrar()
    {
        CreateMap<PR_tbCuentasCobrar_ListResult, CuentaCobrarListDto>()
            .ForMember(dest => dest.Fila, opt => opt.MapFrom(src => src.Fila))
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.Concepto, opt => opt.MapFrom(src => src.Concepto))
            .ForMember(dest => dest.Alumno, opt => opt.MapFrom(src => src.Alumno))
            .ForMember(dest => dest.Pendiente, opt => opt.MapFrom(src => src.Pendiente))
            .ForMember(dest => dest.FechaVence, opt => opt.MapFrom(src => src.FechaVence))
            .ForMember(dest => dest.EstadoPago, opt => opt.MapFrom(src => src.EstadoPago));

        CreateMap<PR_tbCuentasCobrar_FindResult, CuentaCobrarFindDto>()
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.AlumnoId, opt => opt.MapFrom(src => src.Alu_Id))
            .ForMember(dest => dest.ConceptoPagoId, opt => opt.MapFrom(src => src.Cpa_Id))
            .ForMember(dest => dest.TarifaId, opt => opt.MapFrom(src => src.Tar_Id))
            .ForMember(dest => dest.MontoOriginal, opt => opt.MapFrom(src => src.Cco_MontoOriginal))
            .ForMember(dest => dest.MontoDescuento, opt => opt.MapFrom(src => src.Cco_MontoDescuento))
            .ForMember(dest => dest.MontoMora, opt => opt.MapFrom(src => src.Cco_MontoMora))
            .ForMember(dest => dest.MontoTotal, opt => opt.MapFrom(src => src.Cco_MontoTotal))
            .ForMember(dest => dest.MontoPendiente, opt => opt.MapFrom(src => src.Cco_MontoPendiente))
            .ForMember(dest => dest.FechaEmision, opt => opt.MapFrom(src => src.Cco_FechaEmision))
            .ForMember(dest => dest.FechaVencimiento, opt => opt.MapFrom(src => src.Cco_FechaVencimiento))
            .ForMember(dest => dest.EstadoPagoId, opt => opt.MapFrom(src => src.Epa_Id))
            .ForMember(dest => dest.Observaciones, opt => opt.MapFrom(src => src.Cco_Observaciones ?? string.Empty));

        CreateMap<PR_tbCuentasCobrar_DetailResult, CuentaCobrarDetailDto>()
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.AlumnoId, opt => opt.MapFrom(src => src.Alu_Id))
            .ForMember(dest => dest.ConceptoPagoId, opt => opt.MapFrom(src => src.Cpa_Id))
            .ForMember(dest => dest.TarifaId, opt => opt.MapFrom(src => src.Tar_Id))
            .ForMember(dest => dest.MontoOriginal, opt => opt.MapFrom(src => src.Cco_MontoOriginal))
            .ForMember(dest => dest.MontoDescuento, opt => opt.MapFrom(src => src.Cco_MontoDescuento))
            .ForMember(dest => dest.MontoMora, opt => opt.MapFrom(src => src.Cco_MontoMora))
            .ForMember(dest => dest.MontoTotal, opt => opt.MapFrom(src => src.Cco_MontoTotal))
            .ForMember(dest => dest.MontoPendiente, opt => opt.MapFrom(src => src.Cco_MontoPendiente))
            .ForMember(dest => dest.FechaEmision, opt => opt.MapFrom(src => src.Cco_FechaEmision))
            .ForMember(dest => dest.FechaVencimiento, opt => opt.MapFrom(src => src.Cco_FechaVencimiento))
            .ForMember(dest => dest.EstadoPagoId, opt => opt.MapFrom(src => src.Epa_Id))
            .ForMember(dest => dest.Observaciones, opt => opt.MapFrom(src => src.Cco_Observaciones ?? string.Empty))
            .ForMember(dest => dest.ConceptoDescripcion, opt => opt.MapFrom(src => src.Cpa_Descripcion ?? string.Empty))
            .ForMember(dest => dest.EstadoPagoDescripcion, opt => opt.MapFrom(src => src.Epa_Descripcion ?? string.Empty))
            .ForMember(dest => dest.TotalPagado, opt => opt.MapFrom(src => src.TotalPagado))
            .ForMember(dest => dest.EsEliminado, opt => opt.MapFrom(src => src.Cco_EsEliminado))
            .ForMember(dest => dest.UsuarioRegistraId, opt => opt.MapFrom(src => src.Cco_UsuarioRegistra))
            .ForMember(dest => dest.NombreCompletoUsuarioRegistra, opt => opt.MapFrom(src => src.NombreCompletoUsuarioRegistra ?? string.Empty))
            .ForMember(dest => dest.FechaRegistro, opt => opt.MapFrom(src => src.Cco_FechaRegistra))
            .ForMember(dest => dest.UsuarioModificaId, opt => opt.MapFrom(src => src.Cco_UsuarioModifica))
            .ForMember(dest => dest.NombreCompletoUsuarioModifica, opt => opt.MapFrom(src => src.NombreCompletoUsuarioModifica))
            .ForMember(dest => dest.FechaModifica, opt => opt.MapFrom(src => src.Cco_FechaModifica));

        CreateMap<PR_tbCuentasCobrar_DropdownResult, CuentaCobrarDropdownDto>()
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Texto));

        CreateMap<PR_tbCuentasCobrar_ExistResult, CuentaCobrarExistDto>()
            .ForMember(dest => dest.Existe, opt => opt.MapFrom(src => src.Exists))
            .ForMember(dest => dest.Mensaje, opt => opt.MapFrom(src => src.Message));

        // Mapeos para nuevos procedimientos de mensualidades
        CreateMap<PR_GenerarMensualidadResult, GenerarMensualidadResponseDto>();

        CreateMap<PR_GenerarMensualidadesRangoResult, GenerarMensualidadesRangoResponseDto>();

        CreateMap<PR_MesesPendientesPorAlumnoResult, MesPendienteDto>()
            .ForMember(dest => dest.FechaVencimiento, opt => opt.MapFrom(src => src.Cco_FechaVencimiento));
    }

    private void ConfigureDescuentos()
    {
        CreateMap<PR_tbDescuentos_ListResult, DescuentoListDto>()
            .ForMember(dest => dest.DescuentoId, opt => opt.MapFrom(src => src.Des_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Des_Descripcion))
            .ForMember(dest => dest.TipoDescuento, opt => opt.MapFrom(src => src.Des_TipoDescuento))
            .ForMember(dest => dest.Valor, opt => opt.MapFrom(src => src.Des_Valor))
            .ForMember(dest => dest.EsActivo, opt => opt.MapFrom(src => src.Des_EsActivo));

        CreateMap<PR_tbDescuentos_FindResult, DescuentoFindDto>()
            .ForMember(dest => dest.DescuentoId, opt => opt.MapFrom(src => src.Des_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Des_Descripcion))
            .ForMember(dest => dest.TipoDescuento, opt => opt.MapFrom(src => src.Des_TipoDescuento))
            .ForMember(dest => dest.Valor, opt => opt.MapFrom(src => src.Des_Valor))
            .ForMember(dest => dest.EsActivo, opt => opt.MapFrom(src => src.Des_EsActivo));

        CreateMap<PR_tbDescuentos_DetailResult, DescuentoDetailDto>()
            .ForMember(dest => dest.DescuentoId, opt => opt.MapFrom(src => src.Des_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Des_Descripcion ?? string.Empty))
            .ForMember(dest => dest.TipoDescuento, opt => opt.MapFrom(src => src.Des_TipoDescuento ?? string.Empty))
            .ForMember(dest => dest.Valor, opt => opt.MapFrom(src => src.Des_Valor))
            .ForMember(dest => dest.EsActivo, opt => opt.MapFrom(src => src.Des_EsActivo))
            .ForMember(dest => dest.CantidadAplicaciones, opt => opt.MapFrom(src => src.CantidadAplicaciones ?? 0))
            .ForMember(dest => dest.EsEliminado, opt => opt.MapFrom(src => src.Des_EsEliminado))
            .ForMember(dest => dest.UsuarioRegistraId, opt => opt.MapFrom(src => src.Des_UsuarioRegistra))
            .ForMember(dest => dest.NombreCompletoUsuarioRegistra, opt => opt.MapFrom(src => src.NombreCompletoUsuarioRegistra ?? string.Empty))
            .ForMember(dest => dest.FechaRegistro, opt => opt.MapFrom(src => src.Des_FechaRegistra))
            .ForMember(dest => dest.UsuarioModificaId, opt => opt.MapFrom(src => src.Des_UsuarioModifica))
            .ForMember(dest => dest.NombreCompletoUsuarioModifica, opt => opt.MapFrom(src => src.NombreCompletoUsuarioModifica))
            .ForMember(dest => dest.FechaModifica, opt => opt.MapFrom(src => src.Des_FechaModifica));

        CreateMap<PR_tbDescuentos_DropdownResult, DescuentoDropdownDto>()
            .ForMember(dest => dest.DescuentoId, opt => opt.MapFrom(src => src.Des_Id));

        CreateMap<PR_tbDescuentos_ExistResult, DescuentoExistDto>()
            .ForMember(dest => dest.Existe, opt => opt.MapFrom(src => src.Exists))
            .ForMember(dest => dest.Mensaje, opt => opt.MapFrom(src => src.Message));
    }

    private void ConfigureDescuentosAplicados()
    {
        CreateMap<PR_tbDescuentosAplicados_ListResult, DescuentoAplicadoListDto>()
            .ForMember(dest => dest.DescuentoAplicadoId, opt => opt.MapFrom(src => src.Dap_Id))
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.DescuentoId, opt => opt.MapFrom(src => src.Des_Id))
            .ForMember(dest => dest.MontoAplicado, opt => opt.MapFrom(src => src.Dap_MontoAplicado));

        CreateMap<PR_tbDescuentosAplicados_FindResult, DescuentoAplicadoFindDto>()
            .ForMember(dest => dest.DescuentoAplicadoId, opt => opt.MapFrom(src => src.Dap_Id))
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.DescuentoId, opt => opt.MapFrom(src => src.Des_Id))
            .ForMember(dest => dest.MontoAplicado, opt => opt.MapFrom(src => src.Dap_MontoAplicado))
            .ForMember(dest => dest.Justificacion, opt => opt.MapFrom(src => src.Dap_Justificacion ?? string.Empty));

        CreateMap<PR_tbDescuentosAplicados_DetailResult, DescuentoAplicadoDetailDto>()
            .ForMember(dest => dest.DescuentoAplicadoId, opt => opt.MapFrom(src => src.Dap_Id))
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.DescuentoId, opt => opt.MapFrom(src => src.Des_Id))
            .ForMember(dest => dest.MontoAplicado, opt => opt.MapFrom(src => src.Dap_MontoAplicado))
            .ForMember(dest => dest.Justificacion, opt => opt.MapFrom(src => src.Dap_Justificacion ?? string.Empty))
            .ForMember(dest => dest.DescuentoDescripcion, opt => opt.MapFrom(src => src.Des_Descripcion ?? string.Empty))
            .ForMember(dest => dest.TipoDescuento, opt => opt.MapFrom(src => src.Des_TipoDescuento ?? string.Empty))
            .ForMember(dest => dest.Valor, opt => opt.MapFrom(src => src.Des_Valor))
            .ForMember(dest => dest.MontoOriginal, opt => opt.MapFrom(src => src.Cco_MontoOriginal))
            .ForMember(dest => dest.MontoTotal, opt => opt.MapFrom(src => src.Cco_MontoTotal))
            .ForMember(dest => dest.EsEliminado, opt => opt.MapFrom(src => src.Dap_EsEliminado))
            .ForMember(dest => dest.UsuarioRegistraId, opt => opt.MapFrom(src => src.Dap_UsuarioRegistra))
            .ForMember(dest => dest.NombreCompletoUsuarioRegistra, opt => opt.MapFrom(src => src.NombreCompletoUsuarioRegistra ?? string.Empty))
            .ForMember(dest => dest.FechaRegistro, opt => opt.MapFrom(src => src.Dap_FechaRegistra))
            .ForMember(dest => dest.UsuarioModificaId, opt => opt.MapFrom(src => src.Dap_UsuarioModifica))
            .ForMember(dest => dest.NombreCompletoUsuarioModifica, opt => opt.MapFrom(src => src.NombreCompletoUsuarioModifica))
            .ForMember(dest => dest.FechaModifica, opt => opt.MapFrom(src => src.Dap_FechaModifica));

        CreateMap<PR_tbDescuentosAplicados_DropdownResult, DescuentoAplicadoDropdownDto>()
            .ForMember(dest => dest.DescuentoAplicadoId, opt => opt.MapFrom(src => src.Dap_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Texto));

        CreateMap<PR_tbDescuentosAplicados_ExistResult, DescuentoAplicadoExistDto>()
            .ForMember(dest => dest.Existe, opt => opt.MapFrom(src => src.Exists))
            .ForMember(dest => dest.Mensaje, opt => opt.MapFrom(src => src.Message));
    }

    private void ConfigureEstadosPago()
    {
        CreateMap<PR_tbEstadosPago_ListResult, EstadoPagoListDto>()
            .ForMember(dest => dest.EstadoPagoId, opt => opt.MapFrom(src => src.Epa_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Epa_Descripcion));

        CreateMap<PR_tbEstadosPago_FindResult, EstadoPagoFindDto>()
            .ForMember(dest => dest.EstadoPagoId, opt => opt.MapFrom(src => src.Epa_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Epa_Descripcion));

        CreateMap<PR_tbEstadosPago_DetailResult, EstadoPagoDetailDto>()
            .ForMember(dest => dest.EstadoPagoId, opt => opt.MapFrom(src => src.Epa_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Epa_Descripcion ?? string.Empty))
            .ForMember(dest => dest.EsActivo, opt => opt.MapFrom(src => src.Epa_EsActivo))
            .ForMember(dest => dest.CantidadCuentas, opt => opt.MapFrom(src => src.CantidadCuentas ?? 0))
            .ForMember(dest => dest.EsEliminado, opt => opt.MapFrom(src => src.Epa_EsEliminado))
            .ForMember(dest => dest.UsuarioRegistraId, opt => opt.MapFrom(src => src.Epa_UsuarioRegistra))
            .ForMember(dest => dest.NombreCompletoUsuarioRegistra, opt => opt.MapFrom(src => src.NombreCompletoUsuarioRegistra ?? string.Empty))
            .ForMember(dest => dest.FechaRegistro, opt => opt.MapFrom(src => src.Epa_FechaRegistra))
            .ForMember(dest => dest.UsuarioModificaId, opt => opt.MapFrom(src => src.Epa_UsuarioModifica))
            .ForMember(dest => dest.NombreCompletoUsuarioModifica, opt => opt.MapFrom(src => src.NombreCompletoUsuarioModifica))
            .ForMember(dest => dest.FechaModifica, opt => opt.MapFrom(src => src.Epa_FechaModifica));

        CreateMap<PR_tbEstadosPago_DropdownResult, EstadoPagoDropdownDto>()
            .ForMember(dest => dest.EstadoPagoId, opt => opt.MapFrom(src => src.Epa_Id));

        CreateMap<PR_tbEstadosPago_ExistResult, EstadoPagoExistDto>()
            .ForMember(dest => dest.Existe, opt => opt.MapFrom(src => src.Exists))
            .ForMember(dest => dest.Mensaje, opt => opt.MapFrom(src => src.Message));
    }

    private void ConfigureFormasPago()
    {
        CreateMap<PR_tbFormasPago_ListResult, FormaPagoListDto>()
            .ForMember(dest => dest.FormaPagoId, opt => opt.MapFrom(src => src.Fpa_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Fpa_Descripcion))
            .ForMember(dest => dest.EsActivo, opt => opt.MapFrom(src => src.Fpa_EsActivo));

        CreateMap<PR_tbFormasPago_FindResult, FormaPagoFindDto>()
            .ForMember(dest => dest.FormaPagoId, opt => opt.MapFrom(src => src.Fpa_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Fpa_Descripcion))
            .ForMember(dest => dest.EsActivo, opt => opt.MapFrom(src => src.Fpa_EsActivo));

        CreateMap<PR_tbFormasPago_DetailResult, FormaPagoDetailDto>()
            .ForMember(dest => dest.FormaPagoId, opt => opt.MapFrom(src => src.Fpa_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Fpa_Descripcion ?? string.Empty))
            .ForMember(dest => dest.EsActivo, opt => opt.MapFrom(src => src.Fpa_EsActivo))
            .ForMember(dest => dest.CantidadPagos, opt => opt.MapFrom(src => src.CantidadPagos ?? 0))
            .ForMember(dest => dest.EsEliminado, opt => opt.MapFrom(src => src.Fpa_EsEliminado))
            .ForMember(dest => dest.UsuarioRegistraId, opt => opt.MapFrom(src => src.Fpa_UsuarioRegistra))
            .ForMember(dest => dest.NombreCompletoUsuarioRegistra, opt => opt.MapFrom(src => src.NombreCompletoUsuarioRegistra ?? string.Empty))
            .ForMember(dest => dest.FechaRegistro, opt => opt.MapFrom(src => src.Fpa_FechaRegistra))
            .ForMember(dest => dest.UsuarioModificaId, opt => opt.MapFrom(src => src.Fpa_UsuarioModifica))
            .ForMember(dest => dest.NombreCompletoUsuarioModifica, opt => opt.MapFrom(src => src.NombreCompletoUsuarioModifica))
            .ForMember(dest => dest.FechaModifica, opt => opt.MapFrom(src => src.Fpa_FechaModifica));

        CreateMap<PR_tbFormasPago_DropdownResult, FormaPagoDropdownDto>()
            .ForMember(dest => dest.FormaPagoId, opt => opt.MapFrom(src => src.Fpa_Id));

        CreateMap<PR_tbFormasPago_ExistResult, FormaPagoExistDto>()
            .ForMember(dest => dest.Existe, opt => opt.MapFrom(src => src.Exists))
            .ForMember(dest => dest.Mensaje, opt => opt.MapFrom(src => src.Message));
    }

    private void ConfigureMoratorias()
    {
        CreateMap<PR_tbMoratorias_ListResult, MoratoriaListDto>()
            .ForMember(dest => dest.MoratoriaId, opt => opt.MapFrom(src => src.Mor_Id))
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.DiasAtraso, opt => opt.MapFrom(src => src.Mor_DiasAtraso))
            .ForMember(dest => dest.Porcentaje, opt => opt.MapFrom(src => src.Mor_Porcentaje))
            .ForMember(dest => dest.MontoMora, opt => opt.MapFrom(src => src.Mor_MontoMora))
            .ForMember(dest => dest.FechaCalculo, opt => opt.MapFrom(src => src.Mor_FechaCalculo));

        CreateMap<PR_tbMoratorias_FindResult, MoratoriaFindDto>()
            .ForMember(dest => dest.MoratoriaId, opt => opt.MapFrom(src => src.Mor_Id))
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.DiasAtraso, opt => opt.MapFrom(src => src.Mor_DiasAtraso))
            .ForMember(dest => dest.Porcentaje, opt => opt.MapFrom(src => src.Mor_Porcentaje))
            .ForMember(dest => dest.MontoMora, opt => opt.MapFrom(src => src.Mor_MontoMora))
            .ForMember(dest => dest.FechaCalculo, opt => opt.MapFrom(src => src.Mor_FechaCalculo));

        CreateMap<PR_tbMoratorias_DetailResult, MoratoriaDetailDto>()
            .ForMember(dest => dest.MoratoriaId, opt => opt.MapFrom(src => src.Mor_Id))
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.DiasAtraso, opt => opt.MapFrom(src => src.Mor_DiasAtraso))
            .ForMember(dest => dest.Porcentaje, opt => opt.MapFrom(src => src.Mor_Porcentaje))
            .ForMember(dest => dest.MontoMora, opt => opt.MapFrom(src => src.Mor_MontoMora))
            .ForMember(dest => dest.FechaCalculo, opt => opt.MapFrom(src => src.Mor_FechaCalculo))
            .ForMember(dest => dest.MontoOriginal, opt => opt.MapFrom(src => src.Cco_MontoOriginal))
            .ForMember(dest => dest.MontoTotal, opt => opt.MapFrom(src => src.Cco_MontoTotal))
            .ForMember(dest => dest.FechaVencimiento, opt => opt.MapFrom(src => src.Cco_FechaVencimiento))
            .ForMember(dest => dest.EsEliminado, opt => opt.MapFrom(src => src.Mor_EsEliminado))
            .ForMember(dest => dest.UsuarioRegistraId, opt => opt.MapFrom(src => src.Mor_UsuarioRegistra))
            .ForMember(dest => dest.NombreCompletoUsuarioRegistra, opt => opt.MapFrom(src => src.NombreCompletoUsuarioRegistra ?? string.Empty))
            .ForMember(dest => dest.FechaRegistro, opt => opt.MapFrom(src => src.Mor_FechaRegistra))
            .ForMember(dest => dest.UsuarioModificaId, opt => opt.MapFrom(src => src.Mor_UsuarioModifica))
            .ForMember(dest => dest.NombreCompletoUsuarioModifica, opt => opt.MapFrom(src => src.NombreCompletoUsuarioModifica))
            .ForMember(dest => dest.FechaModifica, opt => opt.MapFrom(src => src.Mor_FechaModifica));

        CreateMap<PR_tbMoratorias_DropdownResult, MoratoriaDropdownDto>()
            .ForMember(dest => dest.MoratoriaId, opt => opt.MapFrom(src => src.Mor_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Texto));

        CreateMap<PR_tbMoratorias_ExistResult, MoratoriaExistDto>()
            .ForMember(dest => dest.Existe, opt => opt.MapFrom(src => src.Exists))
            .ForMember(dest => dest.Mensaje, opt => opt.MapFrom(src => src.Message));
    }

    private void ConfigurePagos()
    {
        CreateMap<PR_tbPagos_ListResult, PagoListDto>()
            .ForMember(dest => dest.Fila, opt => opt.MapFrom(src => src.Fila))
            .ForMember(dest => dest.PagoId, opt => opt.MapFrom(src => src.Pag_Id))
            .ForMember(dest => dest.MontoTotal, opt => opt.MapFrom(src => src.Pag_MontoTotal))
            .ForMember(dest => dest.FechaPago, opt => opt.MapFrom(src => src.Pag_FechaPago))
            .ForMember(dest => dest.NumeroReferencia, opt => opt.MapFrom(src => src.Pag_NumeroReferencia ?? string.Empty))
            .ForMember(dest => dest.Observaciones, opt => opt.MapFrom(src => src.Pag_Observaciones ?? string.Empty))
            .ForMember(dest => dest.FormaPago, opt => opt.MapFrom(src => src.FormaPago ?? string.Empty))
            .ForMember(dest => dest.Alumno, opt => opt.MapFrom(src => src.Alumno ?? string.Empty))
            .ForMember(dest => dest.Encargado, opt => opt.MapFrom(src => src.Encargado ?? string.Empty))
            .ForMember(dest => dest.Usuario, opt => opt.MapFrom(src => src.Usuario ?? string.Empty))
            .ForMember(dest => dest.NumeroRecibo, opt => opt.MapFrom(src => src.Rec_NumeroRecibo ?? string.Empty))
            .ForMember(dest => dest.FechaEmisionRecibo, opt => opt.MapFrom(src => src.Rec_FechaEmision));

        CreateMap<PR_tbPagos_FindResult, PagoFindDto>()
            .ForMember(dest => dest.PagoId, opt => opt.MapFrom(src => src.Pag_Id))
            .ForMember(dest => dest.AlumnoId, opt => opt.MapFrom(src => src.Alu_Id))
            .ForMember(dest => dest.EncargadoId, opt => opt.MapFrom(src => src.Enc_Id))
            .ForMember(dest => dest.FormaPagoId, opt => opt.MapFrom(src => src.Fpa_Id))
            .ForMember(dest => dest.MontoTotal, opt => opt.MapFrom(src => src.Pag_MontoTotal))
            .ForMember(dest => dest.FechaPago, opt => opt.MapFrom(src => src.Pag_FechaPago))
            .ForMember(dest => dest.NumeroReferencia, opt => opt.MapFrom(src => src.Pag_NumeroReferencia ?? string.Empty))
            .ForMember(dest => dest.Observaciones, opt => opt.MapFrom(src => src.Pag_Observaciones ?? string.Empty))
            .ForMember(dest => dest.UsuarioId, opt => opt.MapFrom(src => src.Usu_Id));

        CreateMap<PR_tbPagos_DetailResult, PagoDetailDto>()
            .ForMember(dest => dest.PagoId, opt => opt.MapFrom(src => src.Pag_Id))
            .ForMember(dest => dest.AlumnoId, opt => opt.MapFrom(src => src.Alu_Id))
            .ForMember(dest => dest.EncargadoId, opt => opt.MapFrom(src => src.Enc_Id))
            .ForMember(dest => dest.FormaPagoId, opt => opt.MapFrom(src => src.Fpa_Id))
            .ForMember(dest => dest.MontoTotal, opt => opt.MapFrom(src => src.Pag_MontoTotal))
            .ForMember(dest => dest.FechaPago, opt => opt.MapFrom(src => src.Pag_FechaPago))
            .ForMember(dest => dest.NumeroReferencia, opt => opt.MapFrom(src => src.Pag_NumeroReferencia ?? string.Empty))
            .ForMember(dest => dest.Observaciones, opt => opt.MapFrom(src => src.Pag_Observaciones ?? string.Empty))
            .ForMember(dest => dest.UsuarioId, opt => opt.MapFrom(src => src.Usu_Id))
            .ForMember(dest => dest.FormaPagoDescripcion, opt => opt.MapFrom(src => src.Fpa_Descripcion ?? string.Empty))
            .ForMember(dest => dest.TotalDistribuido, opt => opt.MapFrom(src => src.TotalDistribuido ?? 0))
            .ForMember(dest => dest.EsEliminado, opt => opt.MapFrom(src => src.Pag_EsEliminado))
            .ForMember(dest => dest.UsuarioRegistraId, opt => opt.MapFrom(src => src.Pag_UsuarioRegistra))
            .ForMember(dest => dest.NombreCompletoUsuarioRegistra, opt => opt.MapFrom(src => src.NombreCompletoUsuarioRegistra ?? string.Empty))
            .ForMember(dest => dest.FechaRegistro, opt => opt.MapFrom(src => src.Pag_FechaRegistra))
            .ForMember(dest => dest.UsuarioModificaId, opt => opt.MapFrom(src => src.Pag_UsuarioModifica))
            .ForMember(dest => dest.NombreCompletoUsuarioModifica, opt => opt.MapFrom(src => src.NombreCompletoUsuarioModifica))
            .ForMember(dest => dest.FechaModifica, opt => opt.MapFrom(src => src.Pag_FechaModifica));

        CreateMap<PR_tbPagos_DropdownResult, PagoDropdownDto>()
            .ForMember(dest => dest.PagoId, opt => opt.MapFrom(src => src.Pag_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Texto));

        CreateMap<PR_tbPagos_ExistResult, PagoExistDto>()
            .ForMember(dest => dest.Existe, opt => opt.MapFrom(src => src.Exists))
            .ForMember(dest => dest.Mensaje, opt => opt.MapFrom(src => src.Message));
    }

    private void ConfigurePagosDetalle()
    {
        CreateMap<PR_tbPagosDetalle_ListResult, PagoDetalleListDto>()
            .ForMember(dest => dest.PagoDetalleId, opt => opt.MapFrom(src => src.Pde_Id))
            .ForMember(dest => dest.PagoId, opt => opt.MapFrom(src => src.Pag_Id))
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.MontoAplicado, opt => opt.MapFrom(src => src.Pde_MontoAplicado));

        CreateMap<PR_tbPagosDetalle_FindResult, PagoDetalleFindDto>()
            .ForMember(dest => dest.PagoDetalleId, opt => opt.MapFrom(src => src.Pde_Id))
            .ForMember(dest => dest.PagoId, opt => opt.MapFrom(src => src.Pag_Id))
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.MontoAplicado, opt => opt.MapFrom(src => src.Pde_MontoAplicado));

        CreateMap<PR_tbPagosDetalle_DetailResult, PagoDetalleDetailDto>()
            .ForMember(dest => dest.PagoDetalleId, opt => opt.MapFrom(src => src.Pde_Id))
            .ForMember(dest => dest.PagoId, opt => opt.MapFrom(src => src.Pag_Id))
            .ForMember(dest => dest.CuentaCobrarId, opt => opt.MapFrom(src => src.Cco_Id))
            .ForMember(dest => dest.MontoAplicado, opt => opt.MapFrom(src => src.Pde_MontoAplicado));

        CreateMap<PR_tbPagosDetalle_DropdownResult, PagoDetalleDropdownDto>()
            .ForMember(dest => dest.PagoDetalleId, opt => opt.MapFrom(src => src.Pde_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Texto));

        CreateMap<PR_tbPagosDetalle_ExistResult, PagoDetalleExistDto>()
            .ForMember(dest => dest.Existe, opt => opt.MapFrom(src => src.Exists))
            .ForMember(dest => dest.Mensaje, opt => opt.MapFrom(src => src.Message));
    }

    private void ConfigureRecibos()
    {
        CreateMap<PR_tbRecibos_ListResult, ReciboListDto>()
            .ForMember(dest => dest.ReciboId, opt => opt.MapFrom(src => src.Rec_Id))
            .ForMember(dest => dest.PagoId, opt => opt.MapFrom(src => src.Pag_Id))
            .ForMember(dest => dest.NumeroRecibo, opt => opt.MapFrom(src => src.Rec_NumeroRecibo))
            .ForMember(dest => dest.FechaEmision, opt => opt.MapFrom(src => src.Rec_FechaEmision));

        CreateMap<PR_tbRecibos_FindResult, ReciboFindDto>()
            .ForMember(dest => dest.ReciboId, opt => opt.MapFrom(src => src.Rec_Id))
            .ForMember(dest => dest.PagoId, opt => opt.MapFrom(src => src.Pag_Id))
            .ForMember(dest => dest.NumeroRecibo, opt => opt.MapFrom(src => src.Rec_NumeroRecibo))
            .ForMember(dest => dest.FechaEmision, opt => opt.MapFrom(src => src.Rec_FechaEmision))
            .ForMember(dest => dest.RutaArchivo, opt => opt.MapFrom(src => src.Rec_RutaArchivo ?? string.Empty));

        CreateMap<PR_tbRecibos_DetailResult, ReciboDetailDto>()
            .ForMember(dest => dest.ReciboId, opt => opt.MapFrom(src => src.Rec_Id))
            .ForMember(dest => dest.PagoId, opt => opt.MapFrom(src => src.Pag_Id))
            .ForMember(dest => dest.NumeroRecibo, opt => opt.MapFrom(src => src.Rec_NumeroRecibo))
            .ForMember(dest => dest.FechaEmision, opt => opt.MapFrom(src => src.Rec_FechaEmision))
            .ForMember(dest => dest.RutaArchivo, opt => opt.MapFrom(src => src.Rec_RutaArchivo ?? string.Empty));

        CreateMap<PR_tbRecibos_DropdownResult, ReciboDropdownDto>()
            .ForMember(dest => dest.ReciboId, opt => opt.MapFrom(src => src.Rec_Id))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Texto));

        CreateMap<PR_tbRecibos_ExistResult, ReciboExistDto>()
            .ForMember(dest => dest.Existe, opt => opt.MapFrom(src => src.Exists))
            .ForMember(dest => dest.Mensaje, opt => opt.MapFrom(src => src.Message));
    }

    private void ConfigureEstadoCuenta()
    {
        CreateMap<PR_ObtenerCargosPendientesResult, CargoPendienteDto>();
        CreateMap<PR_ObtenerResumenFinancieroResult, ResumenFinancieroDto>();
        CreateMap<PR_ObtenerHistoricoPagosResult, HistoricoPagoDto>()
            .ForMember(dest => dest.pagoId, opt => opt.MapFrom(src => src.Pag_Id))
            .ForMember(dest => dest.fechaPago, opt => opt.MapFrom(src => src.Pag_FechaPago))
            .ForMember(dest => dest.montoTotal, opt => opt.MapFrom(src => src.Pag_MontoTotal))
            .ForMember(dest => dest.formaPago, opt => opt.MapFrom(src => src.Fpa_Descripcion))
            .ForMember(dest => dest.numeroReferencia, opt => opt.MapFrom(src => src.Pag_NumeroReferencia))
            .ForMember(dest => dest.numeroRecibo, opt => opt.MapFrom(src => src.numeroRecibo))
            .ForMember(dest => dest.usuario, opt => opt.MapFrom(src => src.Alumno))
            .ForMember(dest => dest.observaciones, opt => opt.MapFrom(src => src.Pag_Observaciones));
    }
}
