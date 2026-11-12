/* =============================================================================
   061 · Pase de lista + calendario escolar   (requiere el script 060)

   - Un día en que el colegio cierra (feriado o cierre PUBLICADO, para todo el colegio o para la
     sección del horario) no admite asistencia: el procedimiento la rechaza aunque la petición no
     pase por la pantalla. Al editar se usa la fecha y el horario del registro guardado.
   - Arreglo: el repositorio de la API mide "filas afectadas". Con SET NOCOUNT ON siempre recibía -1
     y respondía error aunque la asistencia sí se guardaba. Ahora la instrucción final cuenta.
   - Arreglo: tbAsistencia apuntaba (llave foránea) a tbHorario, la tabla de horarios vieja de 1 fila,
     así que no se podía guardar asistencia de ningún horario real (tbHorarios). Ahora apunta a tbHorarios.
   - Arreglo: la lista solo traía asistencias ya guardadas (nunca había ninguna). Ahora trae los alumnos
     de la sección del año del horario (de su misma carrera), con su asistencia de ese día si existe.
   - Arreglo: el historial por alumno también usaba tbHorario.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE app.PR_tbAsistencia_Insert
    @Hor_Id              INT,
    @Alu_Id              INT,
    @Asi_Fecha           DATE,
    @Asi_Estado          CHAR(1),
    @Asi_Observacion     VARCHAR(200) = NULL,
    @Asi_UsuarioRegistra INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Sea_Id int = (SELECT Sea_Id FROM app.FN_SeccionAnioDeHorario(@Hor_Id, @Asi_Fecha));
    DECLARE @Cierre nvarchar(150) = (SELECT Eve_Titulo FROM app.FN_CierreDelDia(@Asi_Fecha, @Sea_Id));
    IF @Cierre IS NOT NULL
    BEGIN
        DECLARE @Mensaje nvarchar(400) = CONCAT(N'El colegio cierra ese día (', @Cierre, N'): no hay pase de lista.');
        THROW 50030, @Mensaje, 1;
    END

    SET NOCOUNT OFF;  -- la API cuenta las filas afectadas
    IF EXISTS (SELECT 1 FROM [app].[tbAsistencia] WHERE Hor_Id = @Hor_Id AND Alu_Id = @Alu_Id AND Asi_Fecha = @Asi_Fecha AND Asi_EsEliminado = 0)
        UPDATE [app].[tbAsistencia]
        SET    Asi_Estado = @Asi_Estado, Asi_Observacion = @Asi_Observacion,
               Asi_UsuarioModifica = @Asi_UsuarioRegistra, Asi_FechaModifica = GETDATE()
        WHERE  Hor_Id = @Hor_Id AND Alu_Id = @Alu_Id AND Asi_Fecha = @Asi_Fecha AND Asi_EsEliminado = 0;
    ELSE
        INSERT INTO [app].[tbAsistencia] (Hor_Id, Alu_Id, Asi_Fecha, Asi_Estado, Asi_Observacion, Asi_UsuarioRegistra)
        VALUES (@Hor_Id, @Alu_Id, @Asi_Fecha, @Asi_Estado, @Asi_Observacion, @Asi_UsuarioRegistra);
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbAsistencia_Update
    @Asi_Id              INT,
    @Asi_Estado          CHAR(1),
    @Asi_Observacion     VARCHAR(200) = NULL,
    @Asi_UsuarioModifica INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Hor_Id int, @Fecha date;
    SELECT @Hor_Id = Hor_Id, @Fecha = Asi_Fecha
    FROM [app].[tbAsistencia]
    WHERE Asi_Id = @Asi_Id AND Asi_EsEliminado = 0;

    IF @Hor_Id IS NOT NULL
    BEGIN
        DECLARE @Sea_Id int = (SELECT Sea_Id FROM app.FN_SeccionAnioDeHorario(@Hor_Id, @Fecha));
        DECLARE @Cierre nvarchar(150) = (SELECT Eve_Titulo FROM app.FN_CierreDelDia(@Fecha, @Sea_Id));
        IF @Cierre IS NOT NULL
        BEGIN
            DECLARE @Mensaje nvarchar(400) = CONCAT(N'El colegio cierra ese día (', @Cierre, N'): no hay pase de lista.');
            THROW 50030, @Mensaje, 1;
        END
    END

    SET NOCOUNT OFF;  -- la API cuenta las filas afectadas
    UPDATE [app].[tbAsistencia]
    SET    Asi_Estado = @Asi_Estado, Asi_Observacion = @Asi_Observacion,
           Asi_UsuarioModifica = @Asi_UsuarioModifica, Asi_FechaModifica = GETDATE()
    WHERE  Asi_Id = @Asi_Id AND Asi_EsEliminado = 0;
END
GO

-- Llave foránea hacia la tabla de horarios viva (la tabla de asistencia está vacía: no hay datos que migrar).
IF EXISTS (SELECT 1 FROM sys.foreign_keys
           WHERE name = 'FK_Asistencia_Horario'
             AND parent_object_id = OBJECT_ID('app.tbAsistencia')
             AND referenced_object_id = OBJECT_ID('app.tbHorario'))
    ALTER TABLE app.tbAsistencia DROP CONSTRAINT FK_Asistencia_Horario;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_tbAsistencia_tbHorarios')
    ALTER TABLE app.tbAsistencia WITH CHECK
        ADD CONSTRAINT FK_tbAsistencia_tbHorarios FOREIGN KEY (Hor_Id) REFERENCES app.tbHorarios (Hor_Id);
GO

-- Pase de lista de un horario en una fecha: los alumnos de la sección del año (sin retirados y de la
-- misma carrera que el horario) con su asistencia de ese día. Sin sección del año, usa la ubicación del
-- alumno. También trae a quien ya tenga asistencia guardada ese día aunque ya no esté en la lista.
CREATE OR ALTER PROCEDURE app.PR_tbAsistencia_List
    @Hor_Id INT,
    @Fecha  DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Sea_Id int = (SELECT Sea_Id FROM app.FN_SeccionAnioDeHorario(@Hor_Id, @Fecha));
    DECLARE @Cur_Id int, @Cun_Id int, @Sec_Id int, @Mda_Id int;
    SELECT @Cur_Id = Cur_Id, @Cun_Id = Cun_Id, @Sec_Id = Sec_Id, @Mda_Id = Mda_Id
    FROM app.tbHorarios
    WHERE Hor_Id = @Hor_Id;

    ;WITH lista AS (
        SELECT m.Alu_Id
        FROM app.tbMatriculaAnio m
        JOIN app.tbAlumnos al ON al.Alu_Id = m.Alu_Id
        WHERE @Sea_Id IS NOT NULL
          AND m.Sea_Id = @Sea_Id
          AND m.Mta_EsEliminado = 0
          AND m.Mta_Estado <> 4
          AND (@Cur_Id IS NULL OR al.Cur_Id IS NULL OR al.Cur_Id = @Cur_Id)
        UNION
        SELECT al.Alu_Id
        FROM app.tbAlumnos al
        WHERE @Sea_Id IS NULL
          AND al.Cun_Id = @Cun_Id
          AND al.Sec_Id = @Sec_Id
          AND ISNULL(al.Mda_Id, 0) = ISNULL(@Mda_Id, 0)
          AND (@Cur_Id IS NULL OR al.Cur_Id IS NULL OR al.Cur_Id = @Cur_Id)
          AND ISNULL(al.Est_Id, 1) = 1
        UNION
        SELECT asi.Alu_Id
        FROM app.tbAsistencia asi
        WHERE asi.Hor_Id = @Hor_Id AND asi.Asi_Fecha = @Fecha AND asi.Asi_EsEliminado = 0
    )
    SELECT asi.Asi_Id, l.Alu_Id, asi.Asi_Estado, asi.Asi_Observacion, asi.Asi_Fecha,
           CONCAT_WS(' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), ''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), ''),
                          NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), ''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), '')) AS NombreAlumno,
           p.Per_Imagen
    FROM lista l
    JOIN app.tbAlumnos  al ON al.Alu_Id = l.Alu_Id
    JOIN app.tbPersonas p  ON p.Per_Id  = al.Per_Id
    LEFT JOIN app.tbAsistencia asi
           ON asi.Alu_Id = l.Alu_Id AND asi.Hor_Id = @Hor_Id AND asi.Asi_Fecha = @Fecha AND asi.Asi_EsEliminado = 0
    ORDER BY p.Per_ApellidoPaterno, p.Per_ApellidoMaterno, p.Per_PrimerNombre;
END
GO

-- Historial de asistencia de un alumno en un año (usa la tabla de horarios viva).
CREATE OR ALTER PROCEDURE app.PR_tbAsistencia_ByAlumno
    @Alu_Id INT,
    @Anio   INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());
    SELECT asi.Asi_Id, asi.Asi_Fecha, asi.Asi_Estado, asi.Asi_Observacion,
           m.Mat_Nombre, d.Dia_Descripcion, hi.Hor_Hora AS HoraInicio
    FROM app.tbAsistencia asi
    INNER JOIN app.tbHorarios h  ON asi.Hor_Id = h.Hor_Id
    INNER JOIN app.tbMaterias m  ON h.Mat_Id   = m.Mat_Id
    INNER JOIN app.tbDias     d  ON h.Dia_Id   = d.Dia_Id
    LEFT  JOIN app.tbHoras    hi ON h.Hor_HoraInicio = hi.Hor_Id
    WHERE asi.Alu_Id = @Alu_Id AND YEAR(asi.Asi_Fecha) = @Anio AND asi.Asi_EsEliminado = 0
    ORDER BY asi.Asi_Fecha DESC, hi.Hor_Hora;
END
GO
