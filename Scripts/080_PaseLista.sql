/* =============================================================================
   080 · Pase de lista: dirección, suplentes y alertas de salud   (requiere 061, 070 y 073)

   - Quién puede pasar lista de un horario en una fecha (app.FN_PaseLista_Puede):
       · dirección (rol 1 admin y 1002 director): cualquier horario;
       · docente: los horarios donde es el titular, y las clases que cubre como suplente ese día
         (app.tbSustituciones asignada, no cancelada, en esa fecha exacta).
   - app.PR_Asistencia_Horarios: los horarios que ve el usuario en el selector, del año lectivo de la
     fecha. Dirección: todos, con filtros Nivel / Grado / Sección. Docente: los suyos y los que cubre.
   - El pase de lista (Insert / Update) rechaza a quien no puede pasar lista de ese horario y fecha,
     aunque la petición no pase por la pantalla.
   - Las alertas de salud por sección solo se devuelven a quien puede pasar lista de ese horario
     (nuevo parámetro @Usu_Id; sin él no devuelve nada).
   Se puede ejecutar varias veces.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER FUNCTION app.FN_PaseLista_Puede (@Usu_Id int, @Hor_Id int, @Fecha date)
RETURNS bit
AS
BEGIN
    DECLARE @Rol int, @Emp int, @Ok bit = 0;
    SELECT @Rol = u.Rol_Id, @Emp = u.Emp_Id
    FROM seguridad.tbUsuarios u
    WHERE u.Usu_Id = @Usu_Id AND u.Usu_EsEliminado = 0 AND ISNULL(u.Usu_EsActivo, 1) = 1;

    IF @Rol IS NULL OR @Fecha IS NULL RETURN 0;

    IF EXISTS (SELECT 1 FROM app.tbHorarios h WHERE h.Hor_Id = @Hor_Id AND h.Hor_EsEliminado = 0)
    BEGIN
        IF @Rol IN (1, 1002) SET @Ok = 1;
        ELSE IF @Emp IS NOT NULL AND (
               EXISTS (SELECT 1 FROM app.tbHorarios h WHERE h.Hor_Id = @Hor_Id AND h.Emp_Id = @Emp)
            OR EXISTS (SELECT 1 FROM app.tbSustituciones s
                       WHERE s.Hor_Id = @Hor_Id AND s.Sus_Fecha = @Fecha AND s.Emp_IdSuplente = @Emp
                         AND s.Sus_Estado = 'asignada' AND s.Sus_EsEliminado = 0))
            SET @Ok = 1;
    END
    RETURN @Ok;
END
GO

CREATE OR ALTER PROCEDURE app.PR_Asistencia_Horarios
    @Usu_Id int,
    @Fecha  date,
    @Niv_Id int = NULL,
    @Cun_Id int = NULL,
    @Sec_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Rol int, @Emp int;
    SELECT @Rol = u.Rol_Id, @Emp = u.Emp_Id
    FROM seguridad.tbUsuarios u
    WHERE u.Usu_Id = @Usu_Id AND u.Usu_EsEliminado = 0 AND ISNULL(u.Usu_EsActivo, 1) = 1;
    DECLARE @Anio int = (SELECT Anio FROM app.FN_Sustitucion_Ciclo(@Fecha));

    ;WITH vis AS (
        SELECT h.Hor_Id, CAST(0 AS bit) AS EsSustitucion, CAST(NULL AS int) AS Emp_IdTitular
        FROM app.tbHorarios h
        WHERE @Rol IN (1, 1002) AND h.Hor_EsEliminado = 0 AND h.Hor_Año = @Anio
        UNION ALL
        SELECT h.Hor_Id, CAST(0 AS bit), NULL
        FROM app.tbHorarios h
        WHERE @Rol IS NOT NULL AND @Rol NOT IN (1, 1002) AND @Emp IS NOT NULL
          AND h.Emp_Id = @Emp AND h.Hor_EsEliminado = 0 AND h.Hor_Año = @Anio
        UNION ALL
        SELECT s.Hor_Id, CAST(1 AS bit), s.Emp_IdAusente
        FROM app.tbSustituciones s
        WHERE @Rol IS NOT NULL AND @Rol NOT IN (1, 1002) AND @Emp IS NOT NULL
          AND s.Emp_IdSuplente = @Emp AND s.Sus_Fecha = @Fecha
          AND s.Sus_Estado = 'asignada' AND s.Sus_EsEliminado = 0
    )
    SELECT c.Hor_Id, c.Dia_Id, d.Dia_Descripcion AS Dia, hi.Hor_Hora AS Hora,
           c.Materia, c.Seccion, c.Grado, c.Cun_Id, c.Sec_Id, cn.Niv_Id, nv.Niv_Descripcion AS Nivel,
           v.EsSustitucion,
           CASE WHEN v.EsSustitucion = 1 THEN app.FN_Sustitucion_Nombre(v.Emp_IdTitular) END AS Titular
    FROM vis v
    JOIN app.FN_Sustitucion_Clases() c ON c.Hor_Id = v.Hor_Id
    JOIN app.tbHorarios h ON h.Hor_Id = c.Hor_Id
    LEFT JOIN app.tbCursosNiveles cn ON cn.Cun_Id = c.Cun_Id
    LEFT JOIN app.tbNivelesEducativos nv ON nv.Niv_Id = cn.Niv_Id
    LEFT JOIN app.tbDias d ON d.Dia_Id = c.Dia_Id
    LEFT JOIN app.tbHoras hi ON hi.Hor_Id = h.Hor_HoraInicio
    WHERE (@Niv_Id IS NULL OR cn.Niv_Id = @Niv_Id)
      AND (@Cun_Id IS NULL OR c.Cun_Id = @Cun_Id)
      AND (@Sec_Id IS NULL OR c.Sec_Id = @Sec_Id)
    ORDER BY v.EsSustitucion DESC, c.Dia_Id, c.MinInicio, c.Hor_Id;
END
GO

CREATE OR ALTER PROCEDURE app.PR_Asistencia_Puede
    @Usu_Id int,
    @Hor_Id int,
    @Fecha  date
AS
BEGIN
    SET NOCOUNT ON;
    SELECT app.FN_PaseLista_Puede(@Usu_Id, @Hor_Id, @Fecha) AS Puede;
END
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

    IF app.FN_PaseLista_Puede(@Asi_UsuarioRegistra, @Hor_Id, @Asi_Fecha) = 0
        THROW 50031, N'No puede pasar lista de este horario en esa fecha.', 1;

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
        IF app.FN_PaseLista_Puede(@Asi_UsuarioModifica, @Hor_Id, @Fecha) = 0
            THROW 50031, N'No puede pasar lista de este horario en esa fecha.', 1;

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

CREATE OR ALTER PROCEDURE app.PR_tbFichasSalud_AlertasSeccion
    @Hor_Id int,
    @Fecha  date = NULL,
    @Usu_Id int  = NULL   -- quien pide las alertas: sin él, o sin acceso a ese horario ese día, no devuelve nada
AS
BEGIN
    SET NOCOUNT ON;
    SET @Fecha = ISNULL(@Fecha, CAST(app.FN_AhoraHonduras() AS date));
    DECLARE @Puede bit = app.FN_PaseLista_Puede(@Usu_Id, @Hor_Id, @Fecha);

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
    SELECT f.Alu_Id, f.Fsa_Alerta
    FROM lista l
    JOIN app.tbFichasSalud f ON f.Alu_Id = l.Alu_Id
    WHERE @Puede = 1
      AND f.Fsa_TieneAlerta = 1
      AND f.Fsa_Alerta IS NOT NULL;
END
GO
