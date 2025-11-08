using AutoMapper;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.DTOs.dbo;
using Gestion.Colegial.Entities.Entities;
using Gestion.Colegial.Entities.Entities.dbo;
using DiferenciaDashboardDto = Gestion.Colegial.Entities.DTOs.DiferenciaEntreCantidadAlumnosAnioPasadoDashboardDto;
using DiferenciaDashboardDtoDbo = Gestion.Colegial.Entities.DTOs.dbo.DiferenciaEntreCantidadAlumnosAnioPasadoDashboardDto;

namespace Gestion.Colegial.Business.Mapping
{
    public class DtoMappingProfile : Profile
    {
        public DtoMappingProfile()
        {
            CreateMap<PR_tbAlumnos_DetailResult, AlumnoDetailDto>()
                .ForMember(dest => dest.AlumnoId, opt => opt.MapFrom(src => src.Alu_Id))
                .ForMember(dest => dest.NumeroIdentidad, opt => opt.MapFrom(src => src.Per_Identidad))
                .ForMember(dest => dest.PrimerNombre, opt => opt.MapFrom(src => src.Per_PrimerNombre))
                .ForMember(dest => dest.SegundoNombre, opt => opt.MapFrom(src => src.Per_SegundoNombre))
                .ForMember(dest => dest.ApellidoPaterno, opt => opt.MapFrom(src => src.Per_ApellidoPaterno))
                .ForMember(dest => dest.ApellidoMaterno, opt => opt.MapFrom(src => src.Per_ApellidoMaterno))
                .ForMember(dest => dest.FechaNacimiento, opt => opt.MapFrom(src => src.Per_FechaNacimiento))
                .ForMember(dest => dest.CorreoElectronico, opt => opt.MapFrom(src => src.Per_CorreoElectronico))
                .ForMember(dest => dest.Telefono, opt => opt.MapFrom(src => src.Per_Telefono))
                .ForMember(dest => dest.Direccion, opt => opt.MapFrom(src => src.Per_Direccion))
                .ForMember(dest => dest.Sexo, opt => opt.MapFrom(src => src.Per_Sexo))
                .ForMember(dest => dest.NombreCurso, opt => opt.MapFrom(src => src.Cur_Nombre))
                .ForMember(dest => dest.DescripcionEstado, opt => opt.MapFrom(src => src.Est_Descripcion))
                .ForMember(dest => dest.DescripcionNivel, opt => opt.MapFrom(src => src.Niv_Descripcion))
                .ForMember(dest => dest.DescripcionModalidad, opt => opt.MapFrom(src => src.Mda_Descripcion))
                .ForMember(dest => dest.DescripcionCursoNivel, opt => opt.MapFrom(src => src.Cun_Descripcion))
                .ForMember(dest => dest.DescripcionSeccion, opt => opt.MapFrom(src => src.Sec_Descripcion))
                .ForMember(dest => dest.EsActivoPersona, opt => opt.MapFrom(src => src.Per_EsActivo))
                .ForMember(dest => dest.NombreUsuarioRegistraAlumno, opt => opt.MapFrom(src => src.Alu_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroPersona, opt => opt.MapFrom(src => src.Per_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaAlumno, opt => opt.MapFrom(src => src.Alu_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionPersona, opt => opt.MapFrom(src => src.Per_FechaModifica))
                ;

            CreateMap<PR_tbAlumnos_FindResult, AlumnoFindDto>()
                .ForMember(dest => dest.NivelId, opt => opt.MapFrom(src => src.Niv_Id))
                .ForMember(dest => dest.DescripcionNivel, opt => opt.MapFrom(src => src.Niv_Descripcion))
                .ForMember(dest => dest.CursoNivelId, opt => opt.MapFrom(src => src.Cun_Id))
                .ForMember(dest => dest.DescripcionCursoNivel, opt => opt.MapFrom(src => src.Cun_Descripcion))
                .ForMember(dest => dest.ModalidadId, opt => opt.MapFrom(src => src.Mda_Id))
                .ForMember(dest => dest.DescripcionModalidad, opt => opt.MapFrom(src => src.Mda_Descripcion))
                .ForMember(dest => dest.CursoId, opt => opt.MapFrom(src => src.Cur_Id))
                .ForMember(dest => dest.NombreCurso, opt => opt.MapFrom(src => src.Cur_Nombre))
                .ForMember(dest => dest.SeccionId, opt => opt.MapFrom(src => src.Sec_Id))
                .ForMember(dest => dest.DescripcionSeccion, opt => opt.MapFrom(src => src.Sec_Descripcion))
                .ForMember(dest => dest.EstadoId, opt => opt.MapFrom(src => src.Est_Id))
                .ForMember(dest => dest.DescripcionEstado, opt => opt.MapFrom(src => src.Est_Descripcion))
                .ForMember(dest => dest.AlumnoId, opt => opt.MapFrom(src => src.Alu_Id))
                .ForMember(dest => dest.NumeroIdentidad, opt => opt.MapFrom(src => src.Per_Identidad))
                .ForMember(dest => dest.PrimerNombre, opt => opt.MapFrom(src => src.Per_PrimerNombre))
                .ForMember(dest => dest.SegundoNombre, opt => opt.MapFrom(src => src.Per_SegundoNombre))
                .ForMember(dest => dest.ApellidoPaterno, opt => opt.MapFrom(src => src.Per_ApellidoPaterno))
                .ForMember(dest => dest.ApellidoMaterno, opt => opt.MapFrom(src => src.Per_ApellidoMaterno))
                .ForMember(dest => dest.FechaNacimiento, opt => opt.MapFrom(src => src.Per_FechaNacimiento))
                .ForMember(dest => dest.CorreoElectronico, opt => opt.MapFrom(src => src.Per_CorreoElectronico))
                .ForMember(dest => dest.Telefono, opt => opt.MapFrom(src => src.Per_Telefono))
                .ForMember(dest => dest.Direccion, opt => opt.MapFrom(src => src.Per_Direccion))
                .ForMember(dest => dest.Sexo, opt => opt.MapFrom(src => src.Per_Sexo))
                .ForMember(dest => dest.EsEliminadoPersona, opt => opt.MapFrom(src => src.Per_EsEliminado))
                ;

            CreateMap<PR_tbAlumnos_InsertResult, AlumnoInsertDto>()
                .ForMember(dest => dest.ScopeIdentity, opt => opt.MapFrom(src => src.SCOPE_IDENTITY))
                ;

            CreateMap<PR_tbAlumnos_ListResult, AlumnoListDto>()
                .ForMember(dest => dest.AlumnoId, opt => opt.MapFrom(src => src.Alu_Id))
                .ForMember(dest => dest.ImagenPersona, opt => opt.MapFrom(src => src.Per_Imagen))
                .ForMember(dest => dest.NumeroIdentidad, opt => opt.MapFrom(src => src.Per_Identidad))
                .ForMember(dest => dest.NombreAlumno, opt => opt.MapFrom(src => src.Alu_Nombre))
                .ForMember(dest => dest.NombreCurso, opt => opt.MapFrom(src => src.Cno_Descripcion))
                .ForMember(dest => dest.DescripcionModalidad, opt => opt.MapFrom(src => src.Mda_Descripcion))
                .ForMember(dest => dest.DescripcionSeccion, opt => opt.MapFrom(src => src.Sec_Descripcion))
                .ForMember(dest => dest.DescripcionNivel, opt => opt.MapFrom(src => src.Niv_Descripcion))
                .ForMember(dest => dest.DescripcionEstado, opt => opt.MapFrom(src => src.Est_Descripcion))
                ;

            CreateMap<PR_tbAulas_DetailResult, AulaDetailDto>()
                .ForMember(dest => dest.AulaId, opt => opt.MapFrom(src => src.Aul_Id))
                .ForMember(dest => dest.DescripcionAula, opt => opt.MapFrom(src => src.Aul_Descripcion))
                .ForMember(dest => dest.NombreUsuarioRegistraAula, opt => opt.MapFrom(src => src.Aul_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroAula, opt => opt.MapFrom(src => src.Aul_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaAula, opt => opt.MapFrom(src => src.Aul_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionAula, opt => opt.MapFrom(src => src.Aul_FechaModifica))
                ;

            CreateMap<PR_tbAulas_DropdownResult, AulaDropdownDto>()
                .ForMember(dest => dest.AulaId, opt => opt.MapFrom(src => src.Aul_Id))
                .ForMember(dest => dest.DescripcionAula, opt => opt.MapFrom(src => src.Aul_Descripcion))
                ;

            CreateMap<PR_tbAulas_ExistResult, AulaExistDto>()
                .ForMember(dest => dest.AulaId, opt => opt.MapFrom(src => src.Aul_Id))
                .ForMember(dest => dest.DescripcionAula, opt => opt.MapFrom(src => src.Aul_Descripcion))
                ;

            CreateMap<PR_tbAulas_FindResult, AulaFindDto>()
                .ForMember(dest => dest.AulaId, opt => opt.MapFrom(src => src.Aul_Id))
                .ForMember(dest => dest.DescripcionAula, opt => opt.MapFrom(src => src.Aul_Descripcion))
                ;

            CreateMap<PR_tbAulas_ListResult, AulaListDto>()
                .ForMember(dest => dest.AulaId, opt => opt.MapFrom(src => src.Aul_Id))
                .ForMember(dest => dest.DescripcionAula, opt => opt.MapFrom(src => src.Aul_Descripcion))
                ;

            CreateMap<PR_CardsInHome_DashboardResult, CardsInHomeDashboardDto>()
                ;

            CreateMap<PR_tbCargos_DetailResult, CargoDetailDto>()
                .ForMember(dest => dest.CargoId, opt => opt.MapFrom(src => src.Car_Id))
                .ForMember(dest => dest.DescripcionCargo, opt => opt.MapFrom(src => src.Car_Descripcion))
                .ForMember(dest => dest.NombreUsuarioRegistraCargo, opt => opt.MapFrom(src => src.Car_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroCargo, opt => opt.MapFrom(src => src.Car_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaCargo, opt => opt.MapFrom(src => src.Car_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionCargo, opt => opt.MapFrom(src => src.Car_FechaModifica))
                ;

            CreateMap<PR_tbCargos_DropdownResult, CargoDropdownDto>()
                .ForMember(dest => dest.CargoId, opt => opt.MapFrom(src => src.Car_Id))
                .ForMember(dest => dest.DescripcionCargo, opt => opt.MapFrom(src => src.Car_Descripcion))
                ;

            CreateMap<PR_tbCargos_ExistResult, CargoExistDto>()
                .ForMember(dest => dest.CargoId, opt => opt.MapFrom(src => src.Car_Id))
                .ForMember(dest => dest.DescripcionCargo, opt => opt.MapFrom(src => src.Car_Descripcion))
                ;

            CreateMap<PR_tbCargos_FindResult, CargoFindDto>()
                .ForMember(dest => dest.CargoId, opt => opt.MapFrom(src => src.Car_Id))
                .ForMember(dest => dest.DescripcionCargo, opt => opt.MapFrom(src => src.Car_Descripcion))
                ;

            CreateMap<PR_tbCargos_ListResult, CargoListDto>()
                .ForMember(dest => dest.CargoId, opt => opt.MapFrom(src => src.Car_Id))
                .ForMember(dest => dest.DescripcionCargo, opt => opt.MapFrom(src => src.Car_Descripcion))
                ;

            CreateMap<PR_tbCursos_DetailResult, CursoDetailDto>()
                .ForMember(dest => dest.CursoId, opt => opt.MapFrom(src => src.Cur_Id))
                .ForMember(dest => dest.NombreCurso, opt => opt.MapFrom(src => src.Cur_Nombre))
                .ForMember(dest => dest.DescripcionAula, opt => opt.MapFrom(src => src.Aul_Descripcion))
                .ForMember(dest => dest.DescripcionSeccion, opt => opt.MapFrom(src => src.Sec_Descripcion))
                .ForMember(dest => dest.DescripcionNivel, opt => opt.MapFrom(src => src.Niv_Descripcion))
                .ForMember(dest => dest.DescripcionModalidad, opt => opt.MapFrom(src => src.Mda_Descripcion))
                .ForMember(dest => dest.EsActivoCurso, opt => opt.MapFrom(src => src.Cur_EsActivo))
                .ForMember(dest => dest.NombreUsuarioRegistraCurso, opt => opt.MapFrom(src => src.Cur_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroCurso, opt => opt.MapFrom(src => src.Cur_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaCurso, opt => opt.MapFrom(src => src.Cur_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionCurso, opt => opt.MapFrom(src => src.Cur_FechaModifica))
                ;

            CreateMap<tbCursosDetalles, CursoDetalleDto>()
                .ForMember(dest => dest.NivelId, opt => opt.MapFrom(src => src.Niv_Id))
                .ForMember(dest => dest.CursoNivelId, opt => opt.MapFrom(src => src.Cun_Id))
                .ForMember(dest => dest.ModalidadId, opt => opt.MapFrom(src => src.Mda_Id))
                .ForMember(dest => dest.CursoId, opt => opt.MapFrom(src => src.Cur_Id))
                .ForMember(dest => dest.SeccionId, opt => opt.MapFrom(src => src.Sec_Id))
                ;

            CreateMap<PR_tbCursos_DropdownResult, CursoDropdownDto>()
                .ForMember(dest => dest.CursoId, opt => opt.MapFrom(src => src.Cur_Id))
                .ForMember(dest => dest.NombreCurso, opt => opt.MapFrom(src => src.Cur_Nombre))
                ;

            CreateMap<PR_tbCursos_FindResult, CursoFindDto>()
                .ForMember(dest => dest.CursoId, opt => opt.MapFrom(src => src.Cur_Id))
                .ForMember(dest => dest.NombreCurso, opt => opt.MapFrom(src => src.Cur_Nombre))
                .ForMember(dest => dest.NivelId, opt => opt.MapFrom(src => src.Niv_Id))
                .ForMember(dest => dest.DescripcionNivel, opt => opt.MapFrom(src => src.Niv_Descripcion))
                .ForMember(dest => dest.EsActivoCurso, opt => opt.MapFrom(src => src.Cur_EsActivo))
                ;

            CreateMap<PR_tbCursos_ListResult, CursoListDto>()
                .ForMember(dest => dest.CursoId, opt => opt.MapFrom(src => src.Cur_Id))
                .ForMember(dest => dest.NombreCurso, opt => opt.MapFrom(src => src.Cur_Nombre))
                .ForMember(dest => dest.DescripcionNivel, opt => opt.MapFrom(src => src.Niv_Descripcion))
                ;

            CreateMap<PR_tbCursos_tbMaterias_FindResult, CursoMateriaFindDto>()
                .ForMember(dest => dest.MateriaId, opt => opt.MapFrom(src => src.Mat_Id))
                .ForMember(dest => dest.NombreMateria, opt => opt.MapFrom(src => src.Mat_Nombre))
                ;

            CreateMap<PR_tbCursos_tbMaterias_InsertResult, CursoMateriaInsertDto>()
                ;

            CreateMap<PR_tbCursos_tbMaterias_UpdateResult, CursoMateriaUpdateDto>()
                ;

            CreateMap<PR_tbCursos_tbModalidades_FindResult, CursoModalidadFindDto>()
                .ForMember(dest => dest.ModalidadId, opt => opt.MapFrom(src => src.Mda_Id))
                .ForMember(dest => dest.DescripcionModalidad, opt => opt.MapFrom(src => src.Mda_Descripcion))
                ;

            CreateMap<PR_tbCursos_tbModalidades_InsertResult, CursoModalidadInsertDto>()
                ;

            CreateMap<PR_tbCursos_tbModalidades_UpdateResult, CursoModalidadUpdateDto>()
                ;

            CreateMap<PR_tbCursosNiveles_DetailResult, CursoNivelDetailDto>()
                .ForMember(dest => dest.CursoNivelId, opt => opt.MapFrom(src => src.Cun_Id))
                .ForMember(dest => dest.DescripcionCursoNivel, opt => opt.MapFrom(src => src.Cun_Descripcion))
                .ForMember(dest => dest.NombreUsuarioRegistraCursoNivel, opt => opt.MapFrom(src => src.Cun_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroCursoNivel, opt => opt.MapFrom(src => src.Cun_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaCursoNivel, opt => opt.MapFrom(src => src.Cun_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionCursoNivel, opt => opt.MapFrom(src => src.Cun_FechaModifica))
                ;

            CreateMap<PR_tbCursosNiveles_DropdownResult, CursoNivelDropdownDto>()
                .ForMember(dest => dest.CursoNivelId, opt => opt.MapFrom(src => src.Cun_Id))
                .ForMember(dest => dest.DescripcionCursoNivel, opt => opt.MapFrom(src => src.Cun_Descripcion))
                ;

            CreateMap<PR_tbCursosNiveles_ExistResult, CursoNivelExistDto>()
                .ForMember(dest => dest.CursoNivelId, opt => opt.MapFrom(src => src.Cun_Id))
                .ForMember(dest => dest.DescripcionCursoNivel, opt => opt.MapFrom(src => src.Cun_Descripcion))
                ;

            CreateMap<PR_tbCursosNiveles_FindResult, CursoNivelFindDto>()
                .ForMember(dest => dest.CursoNivelId, opt => opt.MapFrom(src => src.Cun_Id))
                .ForMember(dest => dest.DescripcionCursoNivel, opt => opt.MapFrom(src => src.Cun_Descripcion))
                ;

            CreateMap<PR_tbCursosNiveles_ListResult, CursoNivelListDto>()
                .ForMember(dest => dest.CursoNivelId, opt => opt.MapFrom(src => src.Cun_Id))
                .ForMember(dest => dest.DescripcionCursoNivel, opt => opt.MapFrom(src => src.Cun_Descripcion))
                ;

            CreateMap<PR_tbCursos_tbCursosNiveles_FindResult, CursoNivelPorCursoFindDto>()
                .ForMember(dest => dest.CursoNivelId, opt => opt.MapFrom(src => src.Cun_Id))
                .ForMember(dest => dest.DescripcionCursoNivel, opt => opt.MapFrom(src => src.Cun_Descripcion))
                ;

            CreateMap<PR_tbCursos_tbCursosNiveles_InsertResult, CursoNivelPorCursoInsertDto>()
                ;

            CreateMap<PR_tbCursos_tbCursosNiveles_UpdateResult, CursoNivelPorCursoUpdateDto>()
                ;

            CreateMap<PR_tbCursosNiveles_By_tbNivelesEducativos_DropdownResult, CursoNivelPorNivelEducativoDropdownDto>()
                .ForMember(dest => dest.CursoNivelId, opt => opt.MapFrom(src => src.Cun_Id))
                .ForMember(dest => dest.DescripcionCursoNivel, opt => opt.MapFrom(src => src.Cun_Descripcion))
                ;

            CreateMap<PR_tbCursos_By_tbModalidades_DropdownResult, CursoPorModalidadDropdownDto>()
                .ForMember(dest => dest.CursoId, opt => opt.MapFrom(src => src.Cur_Id))
                .ForMember(dest => dest.NombreCurso, opt => opt.MapFrom(src => src.Cur_Nombre))
                ;

            CreateMap<PR_tbCursos_tbSecciones_FindResult, CursoSeccionFindDto>()
                .ForMember(dest => dest.SeccionId, opt => opt.MapFrom(src => src.Sec_Id))
                .ForMember(dest => dest.DescripcionSeccion, opt => opt.MapFrom(src => src.Sec_Descripcion))
                ;

            CreateMap<PR_tbCursos_tbSecciones_InsertResult, CursoSeccionInsertDto>()
                ;

            CreateMap<PR_tbCursos_tbSecciones_UpdateResult, CursoSeccionUpdateDto>()
                ;

            CreateMap<PR_tbDias_DetailResult, DiaDetailDto>()
                .ForMember(dest => dest.DiaId, opt => opt.MapFrom(src => src.Dia_Id))
                .ForMember(dest => dest.DescripcionDia, opt => opt.MapFrom(src => src.Dia_Descripcion))
                .ForMember(dest => dest.NombreUsuarioRegistraDia, opt => opt.MapFrom(src => src.Dia_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroDia, opt => opt.MapFrom(src => src.Dia_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaDia, opt => opt.MapFrom(src => src.Dia_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionDia, opt => opt.MapFrom(src => src.Dia_FechaModifica))
                ;

            CreateMap<PR_tbDias_DropdownResult, DiaDropdownDto>()
                .ForMember(dest => dest.DiaId, opt => opt.MapFrom(src => src.Dia_Id))
                .ForMember(dest => dest.DescripcionDia, opt => opt.MapFrom(src => src.Dia_Descripcion))
                ;

            CreateMap<PR_tbDias_ExistResult, DiaExistDto>()
                .ForMember(dest => dest.DiaId, opt => opt.MapFrom(src => src.Dia_Id))
                .ForMember(dest => dest.DescripcionDia, opt => opt.MapFrom(src => src.Dia_Descripcion))
                ;

            CreateMap<PR_tbDias_FindResult, DiaFindDto>()
                .ForMember(dest => dest.DiaId, opt => opt.MapFrom(src => src.Dia_Id))
                .ForMember(dest => dest.DescripcionDia, opt => opt.MapFrom(src => src.Dia_Descripcion))
                ;

            CreateMap<PR_tbDias_ListResult, DiaListDto>()
                .ForMember(dest => dest.DiaId, opt => opt.MapFrom(src => src.Dia_Id))
                .ForMember(dest => dest.DescripcionDia, opt => opt.MapFrom(src => src.Dia_Descripcion))
                ;

            CreateMap<DiferenciaEntreCantidadAlumnosAnioPasado_DashboardResult, DiferenciaDashboardDtoDbo>()
                ;

            CreateMap<PR_DiferenciaEntreCantidadAlumnosAnioPasado_DashboardResult, DiferenciaDashboardDto>()
                ;

            CreateMap<PR_tbDuraciones_DetailResult, DuracionDetailDto>()
                .ForMember(dest => dest.DuracionId, opt => opt.MapFrom(src => src.Dur_Id))
                .ForMember(dest => dest.DescripcionDuracion, opt => opt.MapFrom(src => src.Dur_Descripcion))
                .ForMember(dest => dest.NombreUsuarioRegistraDuracion, opt => opt.MapFrom(src => src.Dur_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroDuracion, opt => opt.MapFrom(src => src.Dur_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaDuracion, opt => opt.MapFrom(src => src.Dur_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionDuracion, opt => opt.MapFrom(src => src.Dur_FechaModifica))
                ;

            CreateMap<PR_tbDuraciones_DropdownResult, DuracionDropdownDto>()
                .ForMember(dest => dest.DuracionId, opt => opt.MapFrom(src => src.Dur_Id))
                .ForMember(dest => dest.DescripcionDuracion, opt => opt.MapFrom(src => src.Dur_Descripcion))
                ;

            CreateMap<PR_tbDuraciones_ExistResult, DuracionExistDto>()
                .ForMember(dest => dest.DuracionId, opt => opt.MapFrom(src => src.Dur_Id))
                .ForMember(dest => dest.DescripcionDuracion, opt => opt.MapFrom(src => src.Dur_Descripcion))
                ;

            CreateMap<PR_tbDuraciones_FindResult, DuracionFindDto>()
                .ForMember(dest => dest.DuracionId, opt => opt.MapFrom(src => src.Dur_Id))
                .ForMember(dest => dest.DescripcionDuracion, opt => opt.MapFrom(src => src.Dur_Descripcion))
                ;

            CreateMap<PR_tbDuraciones_ListResult, DuracionListDto>()
                .ForMember(dest => dest.DuracionId, opt => opt.MapFrom(src => src.Dur_Id))
                .ForMember(dest => dest.DescripcionDuracion, opt => opt.MapFrom(src => src.Dur_Descripcion))
                ;

            CreateMap<PR_tbEmpleados_DetailResult, EmpleadoDetailDto>()
                .ForMember(dest => dest.EmpleadoId, opt => opt.MapFrom(src => src.Emp_Id))
                .ForMember(dest => dest.CodigoEmpleado, opt => opt.MapFrom(src => src.Emp_Codigo))
                .ForMember(dest => dest.NumeroIdentidad, opt => opt.MapFrom(src => src.Per_Identidad))
                .ForMember(dest => dest.PrimerNombre, opt => opt.MapFrom(src => src.Per_PrimerNombre))
                .ForMember(dest => dest.SegundoNombre, opt => opt.MapFrom(src => src.Per_SegundoNombre))
                .ForMember(dest => dest.ApellidoPaterno, opt => opt.MapFrom(src => src.Per_ApellidoPaterno))
                .ForMember(dest => dest.ApellidoMaterno, opt => opt.MapFrom(src => src.Per_ApellidoMaterno))
                .ForMember(dest => dest.FechaNacimiento, opt => opt.MapFrom(src => src.Per_FechaNacimiento))
                .ForMember(dest => dest.CorreoElectronico, opt => opt.MapFrom(src => src.Per_CorreoElectronico))
                .ForMember(dest => dest.Telefono, opt => opt.MapFrom(src => src.Per_Telefono))
                .ForMember(dest => dest.Direccion, opt => opt.MapFrom(src => src.Per_Direccion))
                .ForMember(dest => dest.Sexo, opt => opt.MapFrom(src => src.Per_Sexo))
                .ForMember(dest => dest.NombreUsuarioRegistraEmpleado, opt => opt.MapFrom(src => src.Emp_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroPersona, opt => opt.MapFrom(src => src.Per_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaEmpleado, opt => opt.MapFrom(src => src.Emp_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionPersona, opt => opt.MapFrom(src => src.Per_FechaModifica))
                .ForMember(dest => dest.DescripcionTitulo, opt => opt.MapFrom(src => src.Tit_Descripcion))
                .ForMember(dest => dest.DescripcionCargo, opt => opt.MapFrom(src => src.Car_Descripcion))
                ;

            CreateMap<PR_tbEmpleados_FindResult, EmpleadoFindDto>()
                .ForMember(dest => dest.EmpleadoId, opt => opt.MapFrom(src => src.Emp_Id))
                .ForMember(dest => dest.CodigoEmpleado, opt => opt.MapFrom(src => src.Emp_Codigo))
                .ForMember(dest => dest.PersonaId, opt => opt.MapFrom(src => src.Per_Id))
                .ForMember(dest => dest.NumeroIdentidad, opt => opt.MapFrom(src => src.Per_Identidad))
                .ForMember(dest => dest.PrimerNombre, opt => opt.MapFrom(src => src.Per_PrimerNombre))
                .ForMember(dest => dest.SegundoNombre, opt => opt.MapFrom(src => src.Per_SegundoNombre))
                .ForMember(dest => dest.ApellidoPaterno, opt => opt.MapFrom(src => src.Per_ApellidoPaterno))
                .ForMember(dest => dest.ApellidoMaterno, opt => opt.MapFrom(src => src.Per_ApellidoMaterno))
                .ForMember(dest => dest.FechaNacimiento, opt => opt.MapFrom(src => src.Per_FechaNacimiento))
                .ForMember(dest => dest.CorreoElectronico, opt => opt.MapFrom(src => src.Per_CorreoElectronico))
                .ForMember(dest => dest.Telefono, opt => opt.MapFrom(src => src.Per_Telefono))
                .ForMember(dest => dest.Direccion, opt => opt.MapFrom(src => src.Per_Direccion))
                .ForMember(dest => dest.Sexo, opt => opt.MapFrom(src => src.Per_Sexo))
                .ForMember(dest => dest.CargoId, opt => opt.MapFrom(src => src.Car_Id))
                .ForMember(dest => dest.DescripcionCargo, opt => opt.MapFrom(src => src.Car_Descripcion))
                .ForMember(dest => dest.EsActivo, opt => opt.MapFrom(src => src.Per_EsActivo))
                .ForMember(dest => dest.TituloId, opt => opt.MapFrom(src => src.Tit_Id))
                .ForMember(dest => dest.DescripcionTitulo, opt => opt.MapFrom(src => src.Tit_Descripcion))
                ;

            CreateMap<PR_tbEmpleados_InsertResult, EmpleadoInsertDto>()
                .ForMember(dest => dest.ScopeIdentity, opt => opt.MapFrom(src => src.SCOPE_IDENTITY))
                ;

            CreateMap<PR_tbEmpleados_ListResult, EmpleadoListDto>()
                .ForMember(dest => dest.EmpleadoId, opt => opt.MapFrom(src => src.Emp_Id))
                .ForMember(dest => dest.CodigoEmpleado, opt => opt.MapFrom(src => src.Emp_Codigo))
                .ForMember(dest => dest.NombreEmpleado, opt => opt.MapFrom(src => src.Emp_Nombre))
                .ForMember(dest => dest.DescripcionTitulo, opt => opt.MapFrom(src => src.Tit_Descripcion))
                .ForMember(dest => dest.DescripcionCargo, opt => opt.MapFrom(src => src.Car_Descripcion))
                ;

            CreateMap<PR_tbEmpleados_tbMaterias_FindResult, EmpleadoMateriaFindDto>()
                .ForMember(dest => dest.EmpleadoId, opt => opt.MapFrom(src => src.Emp_Id))
                ;

            CreateMap<PR_tbEmpleados_UpdateResult, EmpleadoUpdateDto>()
                ;

            CreateMap<PR_tbEncargados_DetailResult, EncargadoDetailDto>()
                .ForMember(dest => dest.EncargadoId, opt => opt.MapFrom(src => src.Enc_Id))
                .ForMember(dest => dest.NumeroIdentidad, opt => opt.MapFrom(src => src.Per_Identidad))
                .ForMember(dest => dest.PrimerNombre, opt => opt.MapFrom(src => src.Per_PrimerNombre))
                .ForMember(dest => dest.SegundoNombre, opt => opt.MapFrom(src => src.Per_SegundoNombre))
                .ForMember(dest => dest.ApellidoPaterno, opt => opt.MapFrom(src => src.Per_ApellidoPaterno))
                .ForMember(dest => dest.ApellidoMaterno, opt => opt.MapFrom(src => src.Per_ApellidoMaterno))
                .ForMember(dest => dest.FechaNacimiento, opt => opt.MapFrom(src => src.Per_FechaNacimiento))
                .ForMember(dest => dest.CorreoElectronico, opt => opt.MapFrom(src => src.Per_CorreoElectronico))
                .ForMember(dest => dest.Telefono, opt => opt.MapFrom(src => src.Per_Telefono))
                .ForMember(dest => dest.Direccion, opt => opt.MapFrom(src => src.Per_Direccion))
                .ForMember(dest => dest.Sexo, opt => opt.MapFrom(src => src.Per_Sexo))
                .ForMember(dest => dest.EsActivoPersona, opt => opt.MapFrom(src => src.Per_EsActivo))
                .ForMember(dest => dest.NombreUsuarioRegistraEncargado, opt => opt.MapFrom(src => src.Enc_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroPersona, opt => opt.MapFrom(src => src.Per_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaEncargado, opt => opt.MapFrom(src => src.Enc_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionPersona, opt => opt.MapFrom(src => src.Per_FechaModifica))
                .ForMember(dest => dest.OcupacionEncargado, opt => opt.MapFrom(src => src.Enc_Ocupacion))
                ;

            CreateMap<PR_tbEncargados_FindResult, EncargadoFindDto>()
                .ForMember(dest => dest.EncargadoId, opt => opt.MapFrom(src => src.Enc_Id))
                .ForMember(dest => dest.PersonaId, opt => opt.MapFrom(src => src.Per_Id))
                .ForMember(dest => dest.NumeroIdentidad, opt => opt.MapFrom(src => src.Per_Identidad))
                .ForMember(dest => dest.PrimerNombre, opt => opt.MapFrom(src => src.Per_PrimerNombre))
                .ForMember(dest => dest.SegundoNombre, opt => opt.MapFrom(src => src.Per_SegundoNombre))
                .ForMember(dest => dest.ApellidoPaterno, opt => opt.MapFrom(src => src.Per_ApellidoPaterno))
                .ForMember(dest => dest.ApellidoMaterno, opt => opt.MapFrom(src => src.Per_ApellidoMaterno))
                .ForMember(dest => dest.FechaNacimiento, opt => opt.MapFrom(src => src.Per_FechaNacimiento))
                .ForMember(dest => dest.CorreoElectronico, opt => opt.MapFrom(src => src.Per_CorreoElectronico))
                .ForMember(dest => dest.Telefono, opt => opt.MapFrom(src => src.Per_Telefono))
                .ForMember(dest => dest.Direccion, opt => opt.MapFrom(src => src.Per_Direccion))
                .ForMember(dest => dest.Sexo, opt => opt.MapFrom(src => src.Per_Sexo))
                .ForMember(dest => dest.EsActivoPersona, opt => opt.MapFrom(src => src.Per_EsActivo))
                .ForMember(dest => dest.OcupacionEncargado, opt => opt.MapFrom(src => src.Enc_Ocupacion))
                ;

            CreateMap<PR_tbEncargados_InsertResult, EncargadoInsertDto>()
                .ForMember(dest => dest.ScopeIdentity, opt => opt.MapFrom(src => src.SCOPE_IDENTITY))
                ;

            CreateMap<PR_tbEncargados_ListResult, EncargadoListDto>()
                .ForMember(dest => dest.EncargadoId, opt => opt.MapFrom(src => src.Enc_Id))
                .ForMember(dest => dest.NumeroIdentidad, opt => opt.MapFrom(src => src.Per_Identidad))
                .ForMember(dest => dest.NombreEncargado, opt => opt.MapFrom(src => src.Enc_Nombre))
                .ForMember(dest => dest.Telefono, opt => opt.MapFrom(src => src.Per_Telefono))
                .ForMember(dest => dest.OcupacionEncargado, opt => opt.MapFrom(src => src.Enc_Ocupacion))
                ;

            CreateMap<PR_tbEncargados_UpdateResult, EncargadoUpdateDto>()
                ;

            CreateMap<PR_tbEstados_DetailResult, EstadoDetailDto>()
                .ForMember(dest => dest.EstadoId, opt => opt.MapFrom(src => src.Est_Id))
                .ForMember(dest => dest.DescripcionEstado, opt => opt.MapFrom(src => src.Est_Descripcion))
                .ForMember(dest => dest.NombreUsuarioRegistraEstado, opt => opt.MapFrom(src => src.Est_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroEstado, opt => opt.MapFrom(src => src.Est_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaEstado, opt => opt.MapFrom(src => src.Est_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionEstado, opt => opt.MapFrom(src => src.Est_FechaModifica))
                ;

            CreateMap<PR_tbEstados_DropdownResult, EstadoDropdownDto>()
                .ForMember(dest => dest.EstadoId, opt => opt.MapFrom(src => src.Est_Id))
                .ForMember(dest => dest.DescripcionEstado, opt => opt.MapFrom(src => src.Est_Descripcion))
                ;

            CreateMap<PR_tbEstados_ExistResult, EstadoExistDto>()
                .ForMember(dest => dest.EstadoId, opt => opt.MapFrom(src => src.Est_Id))
                .ForMember(dest => dest.DescripcionEstado, opt => opt.MapFrom(src => src.Est_Descripcion))
                ;

            CreateMap<PR_tbEstados_FindResult, EstadoFindDto>()
                .ForMember(dest => dest.EstadoId, opt => opt.MapFrom(src => src.Est_Id))
                .ForMember(dest => dest.DescripcionEstado, opt => opt.MapFrom(src => src.Est_Descripcion))
                ;

            CreateMap<PR_tbEstados_ListResult, EstadoListDto>()
                .ForMember(dest => dest.EstadoId, opt => opt.MapFrom(src => src.Est_Id))
                .ForMember(dest => dest.DescripcionEstado, opt => opt.MapFrom(src => src.Est_Descripcion))
                ;

            CreateMap<tbEventoError, EventoErrorDto>()
                .ForMember(dest => dest.ErrorId, opt => opt.MapFrom(src => src.Err_Id))
                .ForMember(dest => dest.NombreArchivoError, opt => opt.MapFrom(src => src.Err_NombreArchivo))
                .ForMember(dest => dest.FechaError, opt => opt.MapFrom(src => src.Err_Fecha))
                .ForMember(dest => dest.RutaError, opt => opt.MapFrom(src => src.Err_Ruta))
                .ForMember(dest => dest.MensajeError, opt => opt.MapFrom(src => src.Err_Message))
                .ForMember(dest => dest.InnerExceptionError, opt => opt.MapFrom(src => src.Err_InnerException))
                ;

            CreateMap<PR_tbHoras_DetailResult, HoraDetailDto>()
                .ForMember(dest => dest.HorarioId, opt => opt.MapFrom(src => src.Hor_Id))
                .ForMember(dest => dest.Hora, opt => opt.MapFrom(src => src.Hor_Hora))
                .ForMember(dest => dest.NombreUsuarioRegistraHorario, opt => opt.MapFrom(src => src.Hor_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroHorario, opt => opt.MapFrom(src => src.Hor_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaHorario, opt => opt.MapFrom(src => src.Hor_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionHorario, opt => opt.MapFrom(src => src.Hor_FechaModifica))
                ;

            CreateMap<PR_tbHoras_DropdownResult, HoraDropdownDto>()
                .ForMember(dest => dest.HorarioId, opt => opt.MapFrom(src => src.Hor_Id))
                .ForMember(dest => dest.Hora, opt => opt.MapFrom(src => src.Hor_Hora))
                ;

            CreateMap<PR_tbHoras_ExistResult, HoraExistDto>()
                .ForMember(dest => dest.HorarioId, opt => opt.MapFrom(src => src.Hor_Id))
                .ForMember(dest => dest.Hora, opt => opt.MapFrom(src => src.Hor_Hora))
                ;

            CreateMap<PR_tbHoras_FindResult, HoraFindDto>()
                .ForMember(dest => dest.HorarioId, opt => opt.MapFrom(src => src.Hor_Id))
                .ForMember(dest => dest.Hora, opt => opt.MapFrom(src => src.Hor_Hora))
                ;

            CreateMap<PR_tbHoras_ListResult, HoraListDto>()
                .ForMember(dest => dest.HorarioId, opt => opt.MapFrom(src => src.Hor_Id))
                .ForMember(dest => dest.Hora, opt => opt.MapFrom(src => src.Hor_Hora))
                ;

            CreateMap<PR_tbMaterias_DetailResult, MateriaDetailDto>()
                .ForMember(dest => dest.MateriaId, opt => opt.MapFrom(src => src.Mat_Id))
                .ForMember(dest => dest.NombreMateria, opt => opt.MapFrom(src => src.Mat_Nombre))
                .ForMember(dest => dest.DescripcionDuracion, opt => opt.MapFrom(src => src.Dur_Descripcion))
                .ForMember(dest => dest.EsActivoMateria, opt => opt.MapFrom(src => src.Mat_EsActivo))
                .ForMember(dest => dest.NombreUsuarioRegistraMateria, opt => opt.MapFrom(src => src.Mat_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroMateria, opt => opt.MapFrom(src => src.Mat_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaMateria, opt => opt.MapFrom(src => src.Mat_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionMateria, opt => opt.MapFrom(src => src.Mat_FechaModifica))
                ;

            CreateMap<PR_tbMaterias_DropdownResult, MateriaDropdownDto>()
                .ForMember(dest => dest.MateriaId, opt => opt.MapFrom(src => src.Mat_Id))
                .ForMember(dest => dest.NombreMateria, opt => opt.MapFrom(src => src.Mat_Nombre))
                ;

            CreateMap<PR_tbMaterias_ExistResult, MateriaExistDto>()
                .ForMember(dest => dest.MateriaId, opt => opt.MapFrom(src => src.Mat_Id))
                .ForMember(dest => dest.NombreMateria, opt => opt.MapFrom(src => src.Mat_Nombre))
                ;

            CreateMap<PR_tbMaterias_FindResult, MateriaFindDto>()
                .ForMember(dest => dest.MateriaId, opt => opt.MapFrom(src => src.Mat_Id))
                .ForMember(dest => dest.NombreMateria, opt => opt.MapFrom(src => src.Mat_Nombre))
                .ForMember(dest => dest.DescripcionDuracion, opt => opt.MapFrom(src => src.Dur_Descripcion))
                .ForMember(dest => dest.EsActivoMateria, opt => opt.MapFrom(src => src.Mat_EsActivo))
                ;

            CreateMap<PR_tbMaterias_ListResult, MateriaListDto>()
                .ForMember(dest => dest.MateriaId, opt => opt.MapFrom(src => src.Mat_Id))
                .ForMember(dest => dest.NombreMateria, opt => opt.MapFrom(src => src.Mat_Nombre))
                .ForMember(dest => dest.DescripcionDuracion, opt => opt.MapFrom(src => src.Dur_Descripcion))
                ;

            CreateMap<PR_tbModalidades_DetailResult, ModalidadDetailDto>()
                .ForMember(dest => dest.ModalidadId, opt => opt.MapFrom(src => src.Mda_Id))
                .ForMember(dest => dest.DescripcionModalidad, opt => opt.MapFrom(src => src.Mda_Descripcion))
                .ForMember(dest => dest.NombreUsuarioRegistraModalidad, opt => opt.MapFrom(src => src.Mda_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroModalidad, opt => opt.MapFrom(src => src.Mda_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaModalidad, opt => opt.MapFrom(src => src.Mda_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionModalidad, opt => opt.MapFrom(src => src.Mda_FechaModifica))
                ;

            CreateMap<PR_tbModalidades_DropdownResult, ModalidadDropdownDto>()
                .ForMember(dest => dest.ModalidadId, opt => opt.MapFrom(src => src.Mda_Id))
                .ForMember(dest => dest.DescripcionModalidad, opt => opt.MapFrom(src => src.Mda_Descripcion))
                ;

            CreateMap<PR_tbModalidades_ExistResult, ModalidadExistDto>()
                .ForMember(dest => dest.ModalidadId, opt => opt.MapFrom(src => src.Mda_Id))
                .ForMember(dest => dest.DescripcionModalidad, opt => opt.MapFrom(src => src.Mda_Descripcion))
                ;

            CreateMap<PR_tbModalidades_FindResult, ModalidadFindDto>()
                .ForMember(dest => dest.ModalidadId, opt => opt.MapFrom(src => src.Mda_Id))
                .ForMember(dest => dest.DescripcionModalidad, opt => opt.MapFrom(src => src.Mda_Descripcion))
                ;

            CreateMap<PR_tbModalidades_ListResult, ModalidadListDto>()
                .ForMember(dest => dest.ModalidadId, opt => opt.MapFrom(src => src.Mda_Id))
                .ForMember(dest => dest.DescripcionModalidad, opt => opt.MapFrom(src => src.Mda_Descripcion))
                ;

            CreateMap<PR_tbModalidades_By_tbCursosNiveles_DropdownResult, ModalidadPorCursoNivelDropdownDto>()
                .ForMember(dest => dest.ModalidadId, opt => opt.MapFrom(src => src.Mda_Id))
                .ForMember(dest => dest.DescripcionModalidad, opt => opt.MapFrom(src => src.Mda_Descripcion))
                ;

            CreateMap<PR_tbModalidades_ValidacionUniqueResult, ModalidadValidacionUnicaDto>()
                .ForMember(dest => dest.ModalidadId, opt => opt.MapFrom(src => src.Mda_Id))
                .ForMember(dest => dest.DescripcionModalidad, opt => opt.MapFrom(src => src.Mda_Descripcion))
                ;

            CreateMap<PR_tbNivelesEducativos_DetailResult, NivelEducativoDetailDto>()
                .ForMember(dest => dest.NivelId, opt => opt.MapFrom(src => src.Niv_Id))
                .ForMember(dest => dest.DescripcionNivel, opt => opt.MapFrom(src => src.Niv_Descripcion))
                .ForMember(dest => dest.EsActivoNivel, opt => opt.MapFrom(src => src.Niv_EsActivo))
                .ForMember(dest => dest.NombreUsuarioRegistraNivel, opt => opt.MapFrom(src => src.Niv_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroNivel, opt => opt.MapFrom(src => src.Niv_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaNivel, opt => opt.MapFrom(src => src.Niv_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionNivel, opt => opt.MapFrom(src => src.Niv_FechaModifica))
                ;

            CreateMap<PR_tbNivelesEducativos_DropdownResult, NivelEducativoDropdownDto>()
                .ForMember(dest => dest.NivelId, opt => opt.MapFrom(src => src.Niv_Id))
                .ForMember(dest => dest.DescripcionNivel, opt => opt.MapFrom(src => src.Niv_Descripcion))
                ;

            CreateMap<PR_tbNivelesEducativos_ExistResult, NivelEducativoExistDto>()
                .ForMember(dest => dest.NivelId, opt => opt.MapFrom(src => src.Niv_Id))
                .ForMember(dest => dest.DescripcionNivel, opt => opt.MapFrom(src => src.Niv_Descripcion))
                ;

            CreateMap<PR_tbNivelesEducativos_FindResult, NivelEducativoFindDto>()
                .ForMember(dest => dest.NivelId, opt => opt.MapFrom(src => src.Niv_Id))
                .ForMember(dest => dest.DescripcionNivel, opt => opt.MapFrom(src => src.Niv_Descripcion))
                .ForMember(dest => dest.EsActivoNivel, opt => opt.MapFrom(src => src.Niv_EsActivo))
                ;

            CreateMap<PR_tbNivelesEducativos_ListResult, NivelEducativoListDto>()
                .ForMember(dest => dest.NivelId, opt => opt.MapFrom(src => src.Niv_Id))
                .ForMember(dest => dest.DescripcionNivel, opt => opt.MapFrom(src => src.Niv_Descripcion))
                ;

            CreateMap<PR_tbNotas_DetailResult, NotaDetailDto>()
                .ForMember(dest => dest.NotaId, opt => opt.MapFrom(src => src.Not_Id))
                .ForMember(dest => dest.ValorNota, opt => opt.MapFrom(src => src.Not_Nota))
                .ForMember(dest => dest.NombreMateria, opt => opt.MapFrom(src => src.Mat_Nombre))
                .ForMember(dest => dest.DescripcionSemestre, opt => opt.MapFrom(src => src.Sem_Descripcion))
                .ForMember(dest => dest.DescripcionParcial, opt => opt.MapFrom(src => src.Pac_Descripcion))
                .ForMember(dest => dest.AnioNota, opt => opt.MapFrom(src => src.Not_Año))
                .ForMember(dest => dest.NombreUsuarioRegistraNota, opt => opt.MapFrom(src => src.Not_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroNota, opt => opt.MapFrom(src => src.Not_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaNota, opt => opt.MapFrom(src => src.Not_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionNota, opt => opt.MapFrom(src => src.Not_FechaModifica))
                ;

            CreateMap<PR_tbNotas_FindResult, NotaFindDto>()
                .ForMember(dest => dest.NotaId, opt => opt.MapFrom(src => src.Not_Id))
                .ForMember(dest => dest.ValorNota, opt => opt.MapFrom(src => src.Not_Nota))
                .ForMember(dest => dest.NombreMateria, opt => opt.MapFrom(src => src.Mat_Nombre))
                .ForMember(dest => dest.DescripcionSemestre, opt => opt.MapFrom(src => src.Sem_Descripcion))
                .ForMember(dest => dest.DescripcionParcial, opt => opt.MapFrom(src => src.Pac_Descripcion))
                .ForMember(dest => dest.AnioNota, opt => opt.MapFrom(src => src.Not_Año))
                .ForMember(dest => dest.EsActivoNota, opt => opt.MapFrom(src => src.Not_EsActivo))
                ;

            CreateMap<PR_tbNotas_ListResult, NotaListDto>()
                .ForMember(dest => dest.NotaId, opt => opt.MapFrom(src => src.Not_Id))
                .ForMember(dest => dest.ValorNota, opt => opt.MapFrom(src => src.Not_Nota))
                .ForMember(dest => dest.NombreMateria, opt => opt.MapFrom(src => src.Mat_Nombre))
                .ForMember(dest => dest.DescripcionSemestre, opt => opt.MapFrom(src => src.Sem_Descripcion))
                .ForMember(dest => dest.DescripcionParcial, opt => opt.MapFrom(src => src.Pac_Descripcion))
                .ForMember(dest => dest.AnioNota, opt => opt.MapFrom(src => src.Not_Año))
                ;

            CreateMap<ObtenerCantidadAlumnosResult, ObtenerCantidadAlumnosDto>()
                ;

            CreateMap<PR_ObtenerCantidadAlumnosPorCurso_DashboardResult, ObtenerCantidadAlumnosPorCursoDashboardDto>()
                .ForMember(dest => dest.NombreCurso, opt => opt.MapFrom(src => src.Cur_Nombre))
                ;

            CreateMap<PR_ObtenerPromedioCursoUltimosAnios_DashboardResult, ObtenerPromedioCursoUltimosAniosDashboardDto>()
                ;

            CreateMap<PR_tbParciales_DetailResult, ParcialDetailDto>()
                .ForMember(dest => dest.ParcialId, opt => opt.MapFrom(src => src.Pac_Id))
                .ForMember(dest => dest.DescripcionParcial, opt => opt.MapFrom(src => src.Pac_Descripcion))
                .ForMember(dest => dest.NombreUsuarioRegistraParcial, opt => opt.MapFrom(src => src.Pac_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroParcial, opt => opt.MapFrom(src => src.Pac_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaParcial, opt => opt.MapFrom(src => src.Pac_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionParcial, opt => opt.MapFrom(src => src.Pac_FechaModifica))
                ;

            CreateMap<PR_tbParciales_DropdownResult, ParcialDropdownDto>()
                .ForMember(dest => dest.ParcialId, opt => opt.MapFrom(src => src.Pac_Id))
                .ForMember(dest => dest.DescripcionParcial, opt => opt.MapFrom(src => src.Pac_Descripcion))
                ;

            CreateMap<PR_tbParciales_ExistResult, ParcialExistDto>()
                .ForMember(dest => dest.ParcialId, opt => opt.MapFrom(src => src.Pac_Id))
                .ForMember(dest => dest.DescripcionParcial, opt => opt.MapFrom(src => src.Pac_Descripcion))
                ;

            CreateMap<PR_tbParciales_FindResult, ParcialFindDto>()
                .ForMember(dest => dest.ParcialId, opt => opt.MapFrom(src => src.Pac_Id))
                .ForMember(dest => dest.DescripcionParcial, opt => opt.MapFrom(src => src.Pac_Descripcion))
                ;

            CreateMap<PR_tbParciales_ListResult, ParcialListDto>()
                .ForMember(dest => dest.ParcialId, opt => opt.MapFrom(src => src.Pac_Id))
                .ForMember(dest => dest.DescripcionParcial, opt => opt.MapFrom(src => src.Pac_Descripcion))
                ;

            CreateMap<PR_tbParentescos_DetailResult, ParentescoDetailDto>()
                .ForMember(dest => dest.ParentescoId, opt => opt.MapFrom(src => src.Par_Id))
                .ForMember(dest => dest.DescripcionParentesco, opt => opt.MapFrom(src => src.Par_Descripcion))
                .ForMember(dest => dest.NombreUsuarioRegistraParentesco, opt => opt.MapFrom(src => src.Par_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroParentesco, opt => opt.MapFrom(src => src.Par_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaParentesco, opt => opt.MapFrom(src => src.Par_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionParentesco, opt => opt.MapFrom(src => src.Par_FechaModifica))
                ;

            CreateMap<PR_tbParentescos_DropdownResult, ParentescoDropdownDto>()
                .ForMember(dest => dest.ParentescoId, opt => opt.MapFrom(src => src.Par_Id))
                .ForMember(dest => dest.DescripcionParentesco, opt => opt.MapFrom(src => src.Par_Descripcion))
                ;

            CreateMap<PR_tbParentescos_ExistResult, ParentescoExistDto>()
                .ForMember(dest => dest.ParentescoId, opt => opt.MapFrom(src => src.Par_Id))
                .ForMember(dest => dest.DescripcionParentesco, opt => opt.MapFrom(src => src.Par_Descripcion))
                ;

            CreateMap<PR_tbParentescos_FindResult, ParentescoFindDto>()
                .ForMember(dest => dest.ParentescoId, opt => opt.MapFrom(src => src.Par_Id))
                .ForMember(dest => dest.DescripcionParentesco, opt => opt.MapFrom(src => src.Par_Descripcion))
                ;

            CreateMap<PR_tbParentescos_ListResult, ParentescoListDto>()
                .ForMember(dest => dest.ParentescoId, opt => opt.MapFrom(src => src.Par_Id))
                .ForMember(dest => dest.DescripcionParentesco, opt => opt.MapFrom(src => src.Par_Descripcion))
                ;

            CreateMap<PR_tbPersonas_InsertResult, PersonaInsertDto>()
                .ForMember(dest => dest.ScopeIdentity, opt => opt.MapFrom(src => src.SCOPE_IDENTITY))
                ;

            CreateMap<ObtenerPromedioCursoUltimosAnios, PromedioCursoUltimosAniosDto>()
                ;

            CreateMap<PR_tbSecciones_DetailResult, SeccionDetailDto>()
                .ForMember(dest => dest.SeccionId, opt => opt.MapFrom(src => src.Sec_Id))
                .ForMember(dest => dest.DescripcionSeccion, opt => opt.MapFrom(src => src.Sec_Descripcion))
                .ForMember(dest => dest.NombreUsuarioRegistraSeccion, opt => opt.MapFrom(src => src.Sec_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroSeccion, opt => opt.MapFrom(src => src.Sec_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaSeccion, opt => opt.MapFrom(src => src.Sec_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionSeccion, opt => opt.MapFrom(src => src.Sec_FechaModifica))
                ;

            CreateMap<PR_tbSecciones_DropdownResult, SeccionDropdownDto>()
                .ForMember(dest => dest.SeccionId, opt => opt.MapFrom(src => src.Sec_Id))
                .ForMember(dest => dest.DescripcionSeccion, opt => opt.MapFrom(src => src.Sec_Descripcion))
                ;

            CreateMap<PR_tbSecciones_ExistResult, SeccionExistDto>()
                .ForMember(dest => dest.SeccionId, opt => opt.MapFrom(src => src.Sec_Id))
                .ForMember(dest => dest.DescripcionSeccion, opt => opt.MapFrom(src => src.Sec_Descripcion))
                ;

            CreateMap<PR_tbSecciones_FindResult, SeccionFindDto>()
                .ForMember(dest => dest.SeccionId, opt => opt.MapFrom(src => src.Sec_Id))
                .ForMember(dest => dest.DescripcionSeccion, opt => opt.MapFrom(src => src.Sec_Descripcion))
                ;

            CreateMap<PR_tbSecciones_ListResult, SeccionListDto>()
                .ForMember(dest => dest.SeccionId, opt => opt.MapFrom(src => src.Sec_Id))
                .ForMember(dest => dest.DescripcionSeccion, opt => opt.MapFrom(src => src.Sec_Descripcion))
                ;

            CreateMap<PR_tbSecciones_By_tbCursos_DropdownResult, SeccionPorCursoDropdownDto>()
                .ForMember(dest => dest.SeccionId, opt => opt.MapFrom(src => src.Sec_Id))
                .ForMember(dest => dest.DescripcionSeccion, opt => opt.MapFrom(src => src.Sec_Descripcion))
                ;

            CreateMap<PR_tbSemestres_DetailResult, SemestreDetailDto>()
                .ForMember(dest => dest.SemestreId, opt => opt.MapFrom(src => src.Sem_Id))
                .ForMember(dest => dest.DescripcionSemestre, opt => opt.MapFrom(src => src.Sem_Descripcion))
                .ForMember(dest => dest.EsActivoSemestre, opt => opt.MapFrom(src => src.Sem_EsActivo))
                .ForMember(dest => dest.NombreUsuarioRegistraSemestre, opt => opt.MapFrom(src => src.Sem_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroSemestre, opt => opt.MapFrom(src => src.Sem_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaSemestre, opt => opt.MapFrom(src => src.Sem_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionSemestre, opt => opt.MapFrom(src => src.Sem_FechaModifica))
                ;

            CreateMap<PR_tbSemestres_DropdownResult, SemestreDropdownDto>()
                .ForMember(dest => dest.SemestreId, opt => opt.MapFrom(src => src.Sem_Id))
                .ForMember(dest => dest.DescripcionSemestre, opt => opt.MapFrom(src => src.Sem_Descripcion))
                ;

            CreateMap<PR_tbSemestres_ExistResult, SemestreExistDto>()
                .ForMember(dest => dest.SemestreId, opt => opt.MapFrom(src => src.Sem_Id))
                .ForMember(dest => dest.DescripcionSemestre, opt => opt.MapFrom(src => src.Sem_Descripcion))
                ;

            CreateMap<PR_tbSemestres_FindResult, SemestreFindDto>()
                .ForMember(dest => dest.SemestreId, opt => opt.MapFrom(src => src.Sem_Id))
                .ForMember(dest => dest.DescripcionSemestre, opt => opt.MapFrom(src => src.Sem_Descripcion))
                .ForMember(dest => dest.EsActivoSemestre, opt => opt.MapFrom(src => src.Sem_EsActivo))
                ;

            CreateMap<PR_tbSemestres_ListResult, SemestreListDto>()
                .ForMember(dest => dest.SemestreId, opt => opt.MapFrom(src => src.Sem_Id))
                .ForMember(dest => dest.DescripcionSemestre, opt => opt.MapFrom(src => src.Sem_Descripcion))
                ;

            CreateMap<PR_tbTitulos_DetailResult, TituloDetailDto>()
                .ForMember(dest => dest.TituloId, opt => opt.MapFrom(src => src.Tit_Id))
                .ForMember(dest => dest.DescripcionTitulo, opt => opt.MapFrom(src => src.Tit_Descripcion))
                .ForMember(dest => dest.NombreUsuarioRegistraTitulo, opt => opt.MapFrom(src => src.Tit_UsuarioRegistraNombre))
                .ForMember(dest => dest.FechaRegistroTitulo, opt => opt.MapFrom(src => src.Tit_FechaRegistra))
                .ForMember(dest => dest.NombreUsuarioModificaTitulo, opt => opt.MapFrom(src => src.Tit_UsuarioModificaNombre))
                .ForMember(dest => dest.FechaModificacionTitulo, opt => opt.MapFrom(src => src.Tit_FechaModifica))
                ;

            CreateMap<PR_tbTitulos_DropdownResult, TituloDropdownDto>()
                .ForMember(dest => dest.TituloId, opt => opt.MapFrom(src => src.Tit_Id))
                .ForMember(dest => dest.DescripcionTitulo, opt => opt.MapFrom(src => src.Tit_Descripcion))
                ;

            CreateMap<PR_tbTitulos_ExistResult, TituloExistDto>()
                .ForMember(dest => dest.TituloId, opt => opt.MapFrom(src => src.Tit_Id))
                .ForMember(dest => dest.DescripcionTitulo, opt => opt.MapFrom(src => src.Tit_Descripcion))
                ;

            CreateMap<PR_tbTitulos_FindResult, TituloFindDto>()
                .ForMember(dest => dest.TituloId, opt => opt.MapFrom(src => src.Tit_Id))
                .ForMember(dest => dest.DescripcionTitulo, opt => opt.MapFrom(src => src.Tit_Descripcion))
                ;

            CreateMap<PR_tbTitulos_ListResult, TituloListDto>()
                .ForMember(dest => dest.TituloId, opt => opt.MapFrom(src => src.Tit_Id))
                .ForMember(dest => dest.DescripcionTitulo, opt => opt.MapFrom(src => src.Tit_Descripcion))
                ;

            CreateMap<PR_tbUsuarios_Autentication_SegurityResult, UsuarioAutenticacionSeguridadDto>()
                ;

            CreateMap<PR_tbUsuarios_Exist_SegurityResult, UsuarioExistSeguridadDto>()
                ;

            CreateMap<PR_tbUsuarios_List_SegurityResult, UsuarioListSeguridadDto>()
                .ForMember(dest => dest.UsuarioId, opt => opt.MapFrom(src => src.Usu_Id))
                .ForMember(dest => dest.NombresPersona, opt => opt.MapFrom(src => src.Per_Nombres))
                .ForMember(dest => dest.NombreUsuario, opt => opt.MapFrom(src => src.Usu_Name))
                .ForMember(dest => dest.DescripcionRol, opt => opt.MapFrom(src => src.Rol_Descripcion))
                ;
        }
    }
}