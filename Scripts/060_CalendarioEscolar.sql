/* =============================================================================
   060 · Calendario escolar  (espejo de Skuul: calendar_events + calendar_event_audiences)

   - Un "día del calendario" tiene título, tipo, lugar, descripción, todo el día o con hora,
     inicio y fin, y nace como BORRADOR. Un borrador no lo ve el resto del colegio y un
     cierre en borrador NO cierra el colegio.
   - "Para quién": sin nadie = todo el colegio; si no, secciones del año, roles o personas
     (empleados o alumnos).
   - Feriado y Cierre publicados = el colegio cierra: ese día la sección no tiene pase de lista.
   - Eve_ClaveOrigen marca los feriados precargados (p. ej. 'HN-2026-independencia') para
     no duplicarlos si se vuelven a cargar.

   Crear SIEMPRE con QUOTED_IDENTIFIER ON (índices filtrados).
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ---------------------------------------------------------------- Tablas */
IF OBJECT_ID('app.tbEventosCalendario') IS NULL
BEGIN
    CREATE TABLE app.tbEventosCalendario
    (
        Eve_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbEventosCalendario PRIMARY KEY,
        Ani_Id              int            NULL CONSTRAINT FK_tbEventosCalendario_tbAnioLectivo REFERENCES app.tbAnioLectivo (Ani_Id),
        Eve_Titulo          nvarchar(150)  NOT NULL,
        Eve_Descripcion     nvarchar(2000) NULL,
        Eve_Tipo            varchar(20)    NOT NULL CONSTRAINT DF_tbEventosCalendario_Tipo DEFAULT ('otro'),
        Eve_Lugar           nvarchar(150)  NULL,
        Eve_TodoElDia       bit            NOT NULL CONSTRAINT DF_tbEventosCalendario_TodoElDia DEFAULT (1),
        Eve_Inicio          datetime2(0)   NOT NULL,
        Eve_Fin             datetime2(0)   NOT NULL,
        Eve_EsPublicado     bit            NOT NULL CONSTRAINT DF_tbEventosCalendario_EsPublicado DEFAULT (0),
        Eve_ClaveOrigen     varchar(60)    NULL,
        Eve_EsEliminado     bit            NOT NULL CONSTRAINT DF_tbEventosCalendario_EsEliminado DEFAULT (0),
        Eve_UsuarioRegistra int            NULL,
        Eve_FechaRegistra   datetime       NOT NULL CONSTRAINT DF_tbEventosCalendario_FechaRegistra DEFAULT (GETDATE()),
        Eve_UsuarioModifica int            NULL,
        Eve_FechaModifica   datetime       NULL,
        CONSTRAINT CK_tbEventosCalendario_Tipo CHECK (Eve_Tipo IN ('feriado','cierre','dia_especial','acto_civico','actividad','reunion_padres','cita','examen','otro')),
        CONSTRAINT CK_tbEventosCalendario_Rango CHECK (Eve_Fin >= Eve_Inicio)
    );

    CREATE INDEX IX_tbEventosCalendario_Rango
        ON app.tbEventosCalendario (Eve_Inicio, Eve_Fin)
        INCLUDE (Eve_Tipo, Eve_EsPublicado)
        WHERE Eve_EsEliminado = 0;

    CREATE UNIQUE INDEX UX_tbEventosCalendario_ClaveOrigen
        ON app.tbEventosCalendario (Eve_ClaveOrigen)
        WHERE Eve_ClaveOrigen IS NOT NULL AND Eve_EsEliminado = 0;
END
GO

IF OBJECT_ID('app.tbEventosCalendarioAudiencia') IS NULL
BEGIN
    CREATE TABLE app.tbEventosCalendarioAudiencia
    (
        Eva_Id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbEventosCalendarioAudiencia PRIMARY KEY,
        Eve_Id int NOT NULL CONSTRAINT FK_tbEventosCalendarioAudiencia_Evento REFERENCES app.tbEventosCalendario (Eve_Id) ON DELETE CASCADE,
        Sea_Id int NULL     CONSTRAINT FK_tbEventosCalendarioAudiencia_Seccion  REFERENCES app.tbSeccionesAnio (Sea_Id),
        Rol_Id int NULL     CONSTRAINT FK_tbEventosCalendarioAudiencia_Rol      REFERENCES seguridad.tbRoles (Rol_Id),
        Emp_Id int NULL     CONSTRAINT FK_tbEventosCalendarioAudiencia_Empleado REFERENCES app.tbEmpleados (Emp_Id),
        Alu_Id int NULL     CONSTRAINT FK_tbEventosCalendarioAudiencia_Alumno   REFERENCES app.tbAlumnos (Alu_Id),
        CONSTRAINT CK_tbEventosCalendarioAudiencia_UnDestino CHECK (
              CASE WHEN Sea_Id IS NULL THEN 0 ELSE 1 END
            + CASE WHEN Rol_Id IS NULL THEN 0 ELSE 1 END
            + CASE WHEN Emp_Id IS NULL THEN 0 ELSE 1 END
            + CASE WHEN Alu_Id IS NULL THEN 0 ELSE 1 END = 1)
    );

    CREATE INDEX IX_tbEventosCalendarioAudiencia_Evento ON app.tbEventosCalendarioAudiencia (Eve_Id);
    CREATE INDEX IX_tbEventosCalendarioAudiencia_Seccion ON app.tbEventosCalendarioAudiencia (Sea_Id) WHERE Sea_Id IS NOT NULL;
END
GO

/* ---------------------------------------------------------------- Funciones */

-- Roles con el nombre que se muestra en "Para quién".
CREATE OR ALTER FUNCTION app.FN_RolesAudiencia ()
RETURNS TABLE
AS
RETURN
    SELECT r.Rol_Id,
           CAST(CASE LOWER(LTRIM(RTRIM(r.Rol_Descripcion)))
                    WHEN 'admin'            THEN N'Administración'
                    WHEN 'docente'          THEN N'Docentes'
                    WHEN 'director'         THEN N'Dirección'
                    WHEN 'secretaria'       THEN N'Secretaría'
                    WHEN 'recursos humanos' THEN N'Recursos humanos'
                    WHEN 'cajero'           THEN N'Caja'
                    WHEN 'contador'         THEN N'Contabilidad'
                    WHEN 'consulta'         THEN N'Consulta'
                    ELSE r.Rol_Descripcion
                END AS nvarchar(100)) AS Rol_Etiqueta
    FROM seguridad.tbRoles r
    WHERE r.Rol_EsEliminado = 0;
GO

-- Año lectivo de una fecha: el que la contiene; si ninguno, el año activo.
CREATE OR ALTER FUNCTION app.FN_AnioLectivoDeFecha (@Fecha date)
RETURNS TABLE
AS
RETURN
    SELECT TOP (1) x.Ani_Id
    FROM (
        SELECT a.Ani_Id, 0 AS Prioridad, a.Ani_FechaInicio
        FROM app.tbAnioLectivo a
        WHERE a.Ani_EsEliminado = 0
          AND @Fecha BETWEEN a.Ani_FechaInicio AND a.Ani_FechaFin
        UNION ALL
        SELECT TRY_CAST(c.Con_Valor AS int), 1, NULL
        FROM app.tbConfiguracion c
        WHERE c.Con_Clave = 'anio_lectivo_activo_id'
    ) x
    WHERE x.Ani_Id IS NOT NULL
    ORDER BY x.Prioridad, x.Ani_FechaInicio DESC;
GO

-- "Para quién" de un evento, una fila por destinatario.
CREATE OR ALTER FUNCTION app.FN_tbEventosCalendario_Audiencia (@Eve_Id int)
RETURNS TABLE
AS
RETURN
    SELECT a.Eva_Id,
           a.Eve_Id,
           CAST(CASE WHEN a.Sea_Id IS NOT NULL THEN 'seccion'
                     WHEN a.Rol_Id IS NOT NULL THEN 'rol'
                     WHEN a.Emp_Id IS NOT NULL THEN 'empleado'
                     ELSE 'alumno' END AS varchar(10)) AS Eva_Tipo,
           COALESCE(a.Sea_Id, a.Rol_Id, a.Emp_Id, a.Alu_Id) AS Eva_RefId,
           CAST(COALESCE(
                    sa.Sea_Nombre,
                    ro.Rol_Etiqueta,
                    NULLIF(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(pe.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(pe.Per_ApellidoPaterno)), N'')), N''),
                    NULLIF(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(pa.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(pa.Per_ApellidoPaterno)), N'')), N''),
                    N'Una persona') AS nvarchar(200)) AS Eva_Nombre,
           CAST(CASE WHEN a.Sea_Id IS NOT NULL THEN n.Niv_Descripcion
                     WHEN a.Rol_Id IS NOT NULL THEN N'Rol'
                     WHEN a.Emp_Id IS NOT NULL THEN ISNULL(ca.Car_Descripcion, N'Empleado')
                     ELSE N'Alumno' END AS nvarchar(150)) AS Eva_Detalle,
           CAST(CASE WHEN a.Sea_Id IS NOT NULL THEN 1
                     WHEN a.Rol_Id IS NOT NULL THEN 2
                     WHEN a.Emp_Id IS NOT NULL THEN 3
                     ELSE 4 END AS int) AS Eva_Orden
    FROM app.tbEventosCalendarioAudiencia a
    LEFT JOIN app.tbSeccionesAnio     sa ON sa.Sea_Id = a.Sea_Id
    LEFT JOIN app.tbNivelesEducativos n  ON n.Niv_Id  = sa.Niv_Id
    LEFT JOIN app.FN_RolesAudiencia() ro ON ro.Rol_Id = a.Rol_Id
    LEFT JOIN app.tbEmpleados         e  ON e.Emp_Id  = a.Emp_Id
    LEFT JOIN app.tbPersonas          pe ON pe.Per_Id = e.Per_Id
    LEFT JOIN app.tbCargos            ca ON ca.Car_Id = e.Car_Id
    LEFT JOIN app.tbAlumnos           al ON al.Alu_Id = a.Alu_Id
    LEFT JOIN app.tbPersonas          pa ON pa.Per_Id = al.Per_Id
    WHERE a.Eve_Id = @Eve_Id;
GO

-- ¿Es para esta persona? Devuelve una fila si el evento es de todo el colegio, o nombra a la
-- persona, o a su rol, o a una sección del año que ella guía o da en el horario de ese año.
CREATE OR ALTER FUNCTION app.FN_tbEventosCalendario_EsParaPersona (@Eve_Id int, @Emp_Id int, @Rol_Id int)
RETURNS TABLE
AS
RETURN
    SELECT 1 AS EsPara
    WHERE NOT EXISTS (SELECT 1 FROM app.tbEventosCalendarioAudiencia a WHERE a.Eve_Id = @Eve_Id)
       OR EXISTS (
            SELECT 1
            FROM app.tbEventosCalendarioAudiencia a
            WHERE a.Eve_Id = @Eve_Id
              AND (   (@Emp_Id IS NOT NULL AND a.Emp_Id = @Emp_Id)
                   OR (@Rol_Id IS NOT NULL AND a.Rol_Id = @Rol_Id)
                   OR (@Emp_Id IS NOT NULL AND a.Sea_Id IS NOT NULL AND EXISTS (
                        SELECT 1
                        FROM app.tbSeccionesAnio sa
                        JOIN app.tbAnioLectivo an ON an.Ani_Id = sa.Ani_Id
                        WHERE sa.Sea_Id = a.Sea_Id
                          AND (   sa.Emp_Id = @Emp_Id
                               OR EXISTS (SELECT 1 FROM app.tbHorarios h
                                          WHERE h.Emp_Id = @Emp_Id
                                            AND h.Hor_EsEliminado = 0
                                            AND h.Hor_Año = an.Ani_Anio
                                            AND h.Cun_Id = sa.Cun_Id
                                            AND h.Sec_Id = sa.Sec_Id
                                            AND ISNULL(h.Mda_Id, 0) = ISNULL(sa.Mda_Id, 0)))))));
GO

-- Sección del año a la que pertenece un horario en una fecha (año + grado + sección + modalidad).
CREATE OR ALTER FUNCTION app.FN_SeccionAnioDeHorario (@Hor_Id int, @Fecha date)
RETURNS TABLE
AS
RETURN
    SELECT TOP (1) sa.Sea_Id
    FROM app.tbHorarios h
    JOIN app.tbSeccionesAnio sa
      ON sa.Ani_Id = (SELECT Ani_Id FROM app.FN_AnioLectivoDeFecha(@Fecha))
     AND sa.Cun_Id = h.Cun_Id
     AND sa.Sec_Id = h.Sec_Id
     AND ISNULL(sa.Mda_Id, 0) = ISNULL(h.Mda_Id, 0)
     AND sa.Sea_EsEliminado = 0
    WHERE h.Hor_Id = @Hor_Id
    ORDER BY sa.Sea_Id;
GO

-- Feriado o cierre PUBLICADO que cierra el colegio ese día para la sección (o para todos).
-- Feriado y cierre son siempre de día completo.
CREATE OR ALTER FUNCTION app.FN_CierreDelDia (@Fecha date, @Sea_Id int)
RETURNS TABLE
AS
RETURN
    SELECT TOP (1) e.Eve_Id, e.Eve_Titulo, e.Eve_Tipo, e.Eve_Inicio, e.Eve_Fin
    FROM app.tbEventosCalendario e
    WHERE e.Eve_EsEliminado = 0
      AND e.Eve_EsPublicado = 1
      AND e.Eve_Tipo IN ('feriado','cierre')
      AND e.Eve_Inicio <  DATEADD(DAY, 1, CAST(@Fecha AS datetime2(0)))
      AND e.Eve_Fin    >= CAST(@Fecha AS datetime2(0))
      AND (    NOT EXISTS (SELECT 1 FROM app.tbEventosCalendarioAudiencia a WHERE a.Eve_Id = e.Eve_Id)
           OR (@Sea_Id IS NOT NULL AND EXISTS (SELECT 1 FROM app.tbEventosCalendarioAudiencia a
                                               WHERE a.Eve_Id = e.Eve_Id AND a.Sea_Id = @Sea_Id)))
    ORDER BY e.Eve_Inicio, e.Eve_Id;
GO

/* ---------------------------------------------------------------- Lectura */

-- Eventos que tocan un rango de fechas (vista de mes). Audiencia NULL = todo el colegio.
-- @VerTodo = 1 (quien edita): todo. Si no: lo de todo el colegio + lo que es para la persona.
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_ListRango
    @Desde             date,
    @Hasta             date,
    @IncluirBorradores bit = 1,
    @VerTodo           bit = 1,
    @Emp_Id            int = NULL,
    @Rol_Id            int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @D datetime2(0) = CAST(@Desde AS datetime2(0));
    DECLARE @H datetime2(0) = DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(@Hasta AS datetime2(0))));

    SELECT e.Eve_Id, e.Ani_Id, e.Eve_Titulo, e.Eve_Descripcion, e.Eve_Tipo, e.Eve_Lugar,
           e.Eve_TodoElDia, e.Eve_Inicio, e.Eve_Fin, e.Eve_EsPublicado, e.Eve_ClaveOrigen,
           CAST(CASE WHEN e.Eve_Tipo IN ('feriado','cierre') THEN 1 ELSE 0 END AS bit) AS Eve_CierraColegio,
           au.Audiencia,
           ISNULL(au.AudienciaCantidad, 0) AS AudienciaCantidad
    FROM app.tbEventosCalendario e
    OUTER APPLY (
        SELECT STRING_AGG(CAST(CASE WHEN f.Eva_Tipo = 'alumno' THEN f.Eva_Nombre + N' (alumno)' ELSE f.Eva_Nombre END AS nvarchar(max)), N', ')
                   WITHIN GROUP (ORDER BY f.Eva_Orden, f.Eva_Nombre) AS Audiencia,
               COUNT(*) AS AudienciaCantidad
        FROM app.FN_tbEventosCalendario_Audiencia(e.Eve_Id) f
    ) au
    WHERE e.Eve_EsEliminado = 0
      AND e.Eve_Inicio <= @H
      AND e.Eve_Fin    >= @D
      AND (@IncluirBorradores = 1 OR e.Eve_EsPublicado = 1)
      AND (@VerTodo = 1 OR EXISTS (SELECT 1 FROM app.FN_tbEventosCalendario_EsParaPersona(e.Eve_Id, @Emp_Id, @Rol_Id)))
    ORDER BY e.Eve_Inicio, e.Eve_Id;
END
GO

-- Un evento. Quien edita (@VerTodo = 1) lo ve aunque sea borrador; el resto, solo si está
-- publicado y es para él.
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_Find
    @Eve_Id  int,
    @VerTodo bit = 1,
    @Emp_Id  int = NULL,
    @Rol_Id  int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.Eve_Id, e.Ani_Id, e.Eve_Titulo, e.Eve_Descripcion, e.Eve_Tipo, e.Eve_Lugar,
           e.Eve_TodoElDia, e.Eve_Inicio, e.Eve_Fin, e.Eve_EsPublicado, e.Eve_ClaveOrigen,
           CAST(CASE WHEN e.Eve_Tipo IN ('feriado','cierre') THEN 1 ELSE 0 END AS bit) AS Eve_CierraColegio,
           au.Audiencia,
           ISNULL(au.AudienciaCantidad, 0) AS AudienciaCantidad
    FROM app.tbEventosCalendario e
    OUTER APPLY (
        SELECT STRING_AGG(CAST(CASE WHEN f.Eva_Tipo = 'alumno' THEN f.Eva_Nombre + N' (alumno)' ELSE f.Eva_Nombre END AS nvarchar(max)), N', ')
                   WITHIN GROUP (ORDER BY f.Eva_Orden, f.Eva_Nombre) AS Audiencia,
               COUNT(*) AS AudienciaCantidad
        FROM app.FN_tbEventosCalendario_Audiencia(e.Eve_Id) f
    ) au
    WHERE e.Eve_Id = @Eve_Id
      AND e.Eve_EsEliminado = 0
      AND (   @VerTodo = 1
           OR (e.Eve_EsPublicado = 1
               AND EXISTS (SELECT 1 FROM app.FN_tbEventosCalendario_EsParaPersona(e.Eve_Id, @Emp_Id, @Rol_Id))));
END
GO

-- Destinatarios de un evento.
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendarioAudiencia_List
    @Eve_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT f.Eva_Id, f.Eve_Id, f.Eva_Tipo, f.Eva_RefId, f.Eva_Nombre, f.Eva_Detalle, f.Eva_Orden
    FROM app.FN_tbEventosCalendario_Audiencia(@Eve_Id) f
    ORDER BY f.Eva_Orden, f.Eva_Nombre;
END
GO

-- Borradores por mes (aviso "N días siguen en borrador", con enlace a cada mes).
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_Borradores
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CONVERT(char(7), Eve_Inicio, 126) AS Mes,
           COUNT(*) AS Borradores
    FROM app.tbEventosCalendario
    WHERE Eve_EsEliminado = 0
      AND Eve_EsPublicado = 0
    GROUP BY CONVERT(char(7), Eve_Inicio, 126)
    ORDER BY Mes;
END
GO

-- ¿El colegio cierra ese día para esa sección? Siempre devuelve UNA fila (Cerrado 0/1).
-- Acepta la sección del año (@Sea_Id) o un horario (@Hor_Id), del que deduce la sección del año.
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_CierreEnFecha
    @Fecha  date,
    @Sea_Id int = NULL,
    @Hor_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Sea_Id IS NULL AND @Hor_Id IS NOT NULL
        SET @Sea_Id = (SELECT Sea_Id FROM app.FN_SeccionAnioDeHorario(@Hor_Id, @Fecha));

    SELECT CAST(CASE WHEN c.Eve_Id IS NULL THEN 0 ELSE 1 END AS bit) AS Cerrado,
           c.Eve_Id, c.Eve_Titulo, c.Eve_Tipo, c.Eve_Inicio, c.Eve_Fin,
           @Sea_Id AS Sea_Id,
           @Fecha  AS Fecha
    FROM (SELECT 1 AS Uno) d
    OUTER APPLY app.FN_CierreDelDia(@Fecha, @Sea_Id) c;
END
GO

-- Hoy + próximos días para una persona (tarjeta de los dashboards).
-- @VerTodo = 1: todo lo publicado. Si no: lo de todo el colegio + lo que es para la persona
-- (su nombre, su rol y las secciones del año que guía o da en el horario).
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_Proximos
    @Hoy     date = NULL,
    @Dias    int  = 7,
    @VerTodo bit  = 0,
    @Emp_Id  int  = NULL,
    @Rol_Id  int  = NULL,
    @Limite  int  = 5
AS
BEGIN
    SET NOCOUNT ON;
    SET @Hoy = ISNULL(@Hoy, CAST(GETDATE() AS date));
    DECLARE @D        datetime2(0) = CAST(@Hoy AS datetime2(0));
    DECLARE @FinHoy   datetime2(0) = DATEADD(SECOND, -1, DATEADD(DAY, 1, @D));
    DECLARE @FinRango datetime2(0) = DATEADD(SECOND, -1, DATEADD(DAY, @Dias + 1, @D));

    ;WITH visibles AS (
        SELECT e.Eve_Id, e.Eve_Titulo, e.Eve_Tipo, e.Eve_Lugar, e.Eve_TodoElDia, e.Eve_Inicio, e.Eve_Fin,
               CAST(CASE WHEN e.Eve_Tipo IN ('feriado','cierre') THEN 1 ELSE 0 END AS bit) AS Eve_CierraColegio
        FROM app.tbEventosCalendario e
        WHERE e.Eve_EsEliminado = 0
          AND e.Eve_EsPublicado = 1
          AND e.Eve_Inicio <= @FinRango
          AND e.Eve_Fin    >= @D
          AND (@VerTodo = 1 OR EXISTS (SELECT 1 FROM app.FN_tbEventosCalendario_EsParaPersona(e.Eve_Id, @Emp_Id, @Rol_Id)))
    )
    SELECT x.EsHoy, x.Eve_Id, x.Eve_Titulo, x.Eve_Tipo, x.Eve_Lugar, x.Eve_TodoElDia, x.Eve_Inicio, x.Eve_Fin, x.Eve_CierraColegio
    FROM (
        SELECT * FROM (
            SELECT TOP (@Limite) CAST(1 AS bit) AS EsHoy, v.*
            FROM visibles v
            WHERE v.Eve_Inicio <= @FinHoy
            ORDER BY v.Eve_TodoElDia DESC, v.Eve_Inicio, v.Eve_Id
        ) hoy
        UNION ALL
        SELECT * FROM (
            SELECT TOP (@Limite) CAST(0 AS bit) AS EsHoy, v.*
            FROM visibles v
            WHERE v.Eve_Inicio > @FinHoy
            ORDER BY v.Eve_Inicio, v.Eve_Id
        ) despues
    ) x
    ORDER BY x.EsHoy DESC, CASE WHEN x.EsHoy = 1 THEN CAST(x.Eve_TodoElDia AS int) ELSE 0 END DESC, x.Eve_Inicio, x.Eve_Id;
END
GO

-- Calendario de un alumno (para el portal de padres): todo el colegio + su sección del año + él con nombre.
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_ParaAlumno
    @Alu_Id int,
    @Desde  date,
    @Hasta  date
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @D datetime2(0) = CAST(@Desde AS datetime2(0));
    DECLARE @H datetime2(0) = DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(@Hasta AS datetime2(0))));

    SELECT e.Eve_Id, e.Ani_Id, e.Eve_Titulo, e.Eve_Descripcion, e.Eve_Tipo, e.Eve_Lugar,
           e.Eve_TodoElDia, e.Eve_Inicio, e.Eve_Fin, e.Eve_EsPublicado, e.Eve_ClaveOrigen,
           CAST(CASE WHEN e.Eve_Tipo IN ('feriado','cierre') THEN 1 ELSE 0 END AS bit) AS Eve_CierraColegio,
           CAST(NULL AS nvarchar(max)) AS Audiencia,
           0 AS AudienciaCantidad
    FROM app.tbEventosCalendario e
    WHERE e.Eve_EsEliminado = 0
      AND e.Eve_EsPublicado = 1
      AND e.Eve_Inicio <= @H
      AND e.Eve_Fin    >= @D
      AND (   NOT EXISTS (SELECT 1 FROM app.tbEventosCalendarioAudiencia a WHERE a.Eve_Id = e.Eve_Id)
           OR EXISTS (SELECT 1 FROM app.tbEventosCalendarioAudiencia a
                      WHERE a.Eve_Id = e.Eve_Id
                        AND (   a.Alu_Id = @Alu_Id
                             OR a.Sea_Id IN (SELECT m.Sea_Id FROM app.tbMatriculaAnio m
                                             WHERE m.Alu_Id = @Alu_Id AND m.Mta_EsEliminado = 0 AND m.Sea_Id IS NOT NULL))))
    ORDER BY e.Eve_Inicio, e.Eve_Id;
END
GO

-- Secciones del año para "Para quién" (año de @Fecha o el activo) + las que ya tenga el evento.
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_SeccionesAudiencia
    @Fecha  date = NULL,
    @Eve_Id int  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Ani_Id int = (SELECT Ani_Id FROM app.FN_AnioLectivoDeFecha(ISNULL(@Fecha, CAST(GETDATE() AS date))));

    SELECT sa.Sea_Id, sa.Sea_Nombre, sa.Ani_Id, a.Ani_Anio, sa.Niv_Id, n.Niv_Descripcion,
           CAST(sa.Sea_Estado AS int) AS Sea_Estado,
           CAST(ISNULL(cn.Cun_Orden, 0) AS int) AS Cun_Orden
    FROM app.tbSeccionesAnio sa
    JOIN app.tbAnioLectivo a             ON a.Ani_Id  = sa.Ani_Id
    LEFT JOIN app.tbNivelesEducativos n  ON n.Niv_Id  = sa.Niv_Id
    LEFT JOIN app.tbCursosNiveles     cn ON cn.Cun_Id = sa.Cun_Id
    WHERE sa.Sea_EsEliminado = 0
      AND (   sa.Ani_Id = @Ani_Id
           OR sa.Sea_Id IN (SELECT x.Sea_Id FROM app.tbEventosCalendarioAudiencia x
                            WHERE x.Eve_Id = @Eve_Id AND x.Sea_Id IS NOT NULL))
    ORDER BY sa.Niv_Id, ISNULL(cn.Cun_Orden, 0), sa.Sea_Nombre;
END
GO

-- Roles para "Para quién".
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_RolesAudiencia
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.Rol_Id, r.Rol_Etiqueta
    FROM app.FN_RolesAudiencia() r
    ORDER BY r.Rol_Etiqueta;
END
GO

-- Buscar una persona (empleado o alumno activo) por nombre o identidad.
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_BuscarPersonas
    @Texto  nvarchar(100),
    @Limite int = 8
AS
BEGIN
    SET NOCOUNT ON;
    SET @Texto = LTRIM(RTRIM(ISNULL(@Texto, N'')));
    DECLARE @Patron nvarchar(400) =
        N'%' + REPLACE(REPLACE(REPLACE(@Texto, N'[', N'[[]'), N'%', N'[%]'), N'_', N'[_]') + N'%';

    SELECT TOP (CASE WHEN LEN(@Texto) < 2 THEN 0 ELSE @Limite END)
           x.Tipo, x.Id, x.Nombre, x.Detalle
    FROM (
        SELECT CAST('empleado' AS varchar(10)) AS Tipo,
               e.Emp_Id AS Id,
               CAST(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N'')) AS nvarchar(200)) AS Nombre,
               CAST(ISNULL(c.Car_Descripcion, N'Empleado') AS nvarchar(150)) AS Detalle,
               CONCAT_WS(N' ', p.Per_PrimerNombre, p.Per_SegundoNombre, p.Per_ApellidoPaterno, p.Per_ApellidoMaterno) AS Completo,
               p.Per_Identidad
        FROM app.tbEmpleados e
        JOIN app.tbPersonas p    ON p.Per_Id = e.Per_Id
        LEFT JOIN app.tbCargos c ON c.Car_Id = e.Car_Id
        WHERE p.Per_EsEliminado = 0
        UNION ALL
        SELECT CAST('alumno' AS varchar(10)),
               al.Alu_Id,
               CAST(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N'')) AS nvarchar(200)),
               CAST(ISNULL(NULLIF(CONCAT_WS(N' ', cn.Cun_Descripcion, s.Sec_Descripcion), N''), N'Alumno') AS nvarchar(150)),
               CONCAT_WS(N' ', p.Per_PrimerNombre, p.Per_SegundoNombre, p.Per_ApellidoPaterno, p.Per_ApellidoMaterno),
               p.Per_Identidad
        FROM app.tbAlumnos al
        JOIN app.tbPersonas p            ON p.Per_Id  = al.Per_Id
        LEFT JOIN app.tbCursosNiveles cn ON cn.Cun_Id = al.Cun_Id
        LEFT JOIN app.tbSecciones     s  ON s.Sec_Id  = al.Sec_Id
        WHERE p.Per_EsEliminado = 0
          AND ISNULL(al.Est_Id, 1) IN (1, 2)
    ) x
    WHERE x.Completo LIKE @Patron OR x.Per_Identidad LIKE @Patron
    ORDER BY x.Nombre, x.Tipo;
END
GO

-- Feriados ya cargados (por prefijo de clave, p. ej. 'HN-2026-').
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_ClavesOrigen
    @Prefijo varchar(40)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.Eve_Id, e.Eve_ClaveOrigen, e.Eve_EsPublicado
    FROM app.tbEventosCalendario e
    WHERE e.Eve_EsEliminado = 0
      AND e.Eve_ClaveOrigen LIKE @Prefijo + '%';
END
GO

/* ---------------------------------------------------------------- Escritura */

-- Crea (Eve_Id NULL/0) o cambia un evento y reemplaza su "Para quién".
-- Listas separadas por coma. Devuelve Eve_Id y si se creó (Creado = 0 si era un feriado ya cargado).
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_Guardar
    @Eve_Id          int            = NULL,
    @Eve_Titulo      nvarchar(150),
    @Eve_Descripcion nvarchar(2000) = NULL,
    @Eve_Tipo        varchar(20),
    @Eve_Lugar       nvarchar(150)  = NULL,
    @Eve_TodoElDia   bit            = 1,
    @Eve_Inicio      datetime2(0),
    @Eve_Fin         datetime2(0),
    @Secciones       varchar(max)   = NULL,
    @Roles           varchar(max)   = NULL,
    @Empleados       varchar(max)   = NULL,
    @Alumnos         varchar(max)   = NULL,
    @Eve_ClaveOrigen varchar(60)    = NULL,
    @Publicar        bit            = NULL,
    @Usuario         int            = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Eve_Titulo      = LTRIM(RTRIM(ISNULL(@Eve_Titulo, N'')));
    SET @Eve_Descripcion = NULLIF(LTRIM(RTRIM(@Eve_Descripcion)), N'');
    SET @Eve_Lugar       = NULLIF(LTRIM(RTRIM(@Eve_Lugar)), N'');
    SET @Eve_ClaveOrigen = NULLIF(LTRIM(RTRIM(@Eve_ClaveOrigen)), '');
    SET @Secciones       = NULLIF(LTRIM(RTRIM(@Secciones)), '');
    SET @Roles           = NULLIF(LTRIM(RTRIM(@Roles)), '');
    SET @Empleados       = NULLIF(LTRIM(RTRIM(@Empleados)), '');
    SET @Alumnos         = NULLIF(LTRIM(RTRIM(@Alumnos)), '');

    -- Feriado y cierre cierran el día completo y solo para todo el colegio o para secciones.
    IF @Eve_Tipo IN ('feriado','cierre')
    BEGIN
        SET @Eve_TodoElDia = 1;
        IF @Roles IS NOT NULL OR @Empleados IS NOT NULL OR @Alumnos IS NOT NULL
            THROW 50017, N'Un feriado o cierre es para todo el colegio o para secciones: quite los roles y las personas.', 1;
    END

    IF YEAR(@Eve_Inicio) NOT BETWEEN 2000 AND 2100 OR YEAR(@Eve_Fin) NOT BETWEEN 2000 AND 2100
        THROW 50016, N'Revise el año de las fechas.', 1;

    IF @Eve_TodoElDia = 1
    BEGIN
        SET @Eve_Inicio = CAST(CAST(@Eve_Inicio AS date) AS datetime2(0));
        SET @Eve_Fin    = DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(CAST(@Eve_Fin AS date) AS datetime2(0))));
    END

    IF @Eve_Titulo = N''
        THROW 50010, N'Escriba un título.', 1;
    IF @Eve_Tipo NOT IN ('feriado','cierre','dia_especial','acto_civico','actividad','reunion_padres','cita','examen','otro')
        THROW 50011, N'Ese tipo de día no existe.', 1;
    IF @Eve_Inicio IS NULL OR @Eve_Fin IS NULL
        THROW 50012, N'Indique cuándo empieza y cuándo termina.', 1;
    IF @Eve_Fin < @Eve_Inicio
        THROW 50013, N'Un día del calendario no puede terminar antes de empezar.', 1;
    IF DATEADD(YEAR, 1, @Eve_Inicio) < @Eve_Fin
        THROW 50014, N'Un día del calendario no puede durar más de un año. Revise el año.', 1;

    IF ISNULL(@Eve_Id, 0) = 0 AND @Eve_ClaveOrigen IS NOT NULL
    BEGIN
        DECLARE @Existente int = (SELECT TOP (1) Eve_Id FROM app.tbEventosCalendario
                                  WHERE Eve_ClaveOrigen = @Eve_ClaveOrigen AND Eve_EsEliminado = 0);
        IF @Existente IS NOT NULL
        BEGIN
            SELECT @Existente AS Eve_Id, CAST(0 AS bit) AS Creado;
            RETURN;
        END
    END

    DECLARE @Ani_Id int    = (SELECT Ani_Id FROM app.FN_AnioLectivoDeFecha(CAST(@Eve_Inicio AS date)));
    DECLARE @Creado bit    = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF ISNULL(@Eve_Id, 0) = 0
        BEGIN
            INSERT INTO app.tbEventosCalendario
                (Ani_Id, Eve_Titulo, Eve_Descripcion, Eve_Tipo, Eve_Lugar, Eve_TodoElDia, Eve_Inicio, Eve_Fin,
                 Eve_EsPublicado, Eve_ClaveOrigen, Eve_UsuarioRegistra, Eve_FechaRegistra)
            VALUES
                (@Ani_Id, @Eve_Titulo, @Eve_Descripcion, @Eve_Tipo, @Eve_Lugar, @Eve_TodoElDia, @Eve_Inicio, @Eve_Fin,
                 ISNULL(@Publicar, 0), @Eve_ClaveOrigen, @Usuario, GETDATE());
            SET @Eve_Id = CAST(SCOPE_IDENTITY() AS int);
            SET @Creado = 1;
        END
        ELSE
        BEGIN
            UPDATE app.tbEventosCalendario
            SET    Ani_Id              = @Ani_Id,
                   Eve_Titulo          = @Eve_Titulo,
                   Eve_Descripcion     = @Eve_Descripcion,
                   Eve_Tipo            = @Eve_Tipo,
                   Eve_Lugar           = @Eve_Lugar,
                   Eve_TodoElDia       = @Eve_TodoElDia,
                   Eve_Inicio          = @Eve_Inicio,
                   Eve_Fin             = @Eve_Fin,
                   Eve_UsuarioModifica = @Usuario,
                   Eve_FechaModifica   = GETDATE()
            WHERE  Eve_Id = @Eve_Id
              AND  Eve_EsEliminado = 0;

            IF @@ROWCOUNT = 0
                THROW 50015, N'Ese día ya no está en el calendario.', 1;

            DELETE FROM app.tbEventosCalendarioAudiencia WHERE Eve_Id = @Eve_Id;
        END

        INSERT INTO app.tbEventosCalendarioAudiencia (Eve_Id, Sea_Id)
        SELECT DISTINCT @Eve_Id, sa.Sea_Id
        FROM STRING_SPLIT(@Secciones, ',') v
        JOIN app.tbSeccionesAnio sa ON sa.Sea_Id = TRY_CAST(LTRIM(RTRIM(v.value)) AS int);

        INSERT INTO app.tbEventosCalendarioAudiencia (Eve_Id, Rol_Id)
        SELECT DISTINCT @Eve_Id, r.Rol_Id
        FROM STRING_SPLIT(@Roles, ',') v
        JOIN seguridad.tbRoles r ON r.Rol_Id = TRY_CAST(LTRIM(RTRIM(v.value)) AS int) AND r.Rol_EsEliminado = 0;

        INSERT INTO app.tbEventosCalendarioAudiencia (Eve_Id, Emp_Id)
        SELECT DISTINCT @Eve_Id, e.Emp_Id
        FROM STRING_SPLIT(@Empleados, ',') v
        JOIN app.tbEmpleados e ON e.Emp_Id = TRY_CAST(LTRIM(RTRIM(v.value)) AS int);

        INSERT INTO app.tbEventosCalendarioAudiencia (Eve_Id, Alu_Id)
        SELECT DISTINCT @Eve_Id, a.Alu_Id
        FROM STRING_SPLIT(@Alumnos, ',') v
        JOIN app.tbAlumnos a ON a.Alu_Id = TRY_CAST(LTRIM(RTRIM(v.value)) AS int);

        -- Si se pidió "para quién" y ninguno existe ya, no se convierte en silencio en "todo el colegio".
        IF (@Secciones IS NOT NULL OR @Roles IS NOT NULL OR @Empleados IS NOT NULL OR @Alumnos IS NOT NULL)
           AND NOT EXISTS (SELECT 1 FROM app.tbEventosCalendarioAudiencia WHERE Eve_Id = @Eve_Id)
            THROW 50018, N'Las secciones, roles o personas elegidos ya no existen. Elija de nuevo para quién es.', 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Eve_Id AS Eve_Id, @Creado AS Creado;
END
GO

-- Publicar (1) o volver a borrador (0).
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_Publicar
    @Eve_Id   int,
    @Publicar bit,
    @Usuario  int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE app.tbEventosCalendario
    SET    Eve_EsPublicado     = @Publicar,
           Eve_UsuarioModifica = @Usuario,
           Eve_FechaModifica   = GETDATE()
    WHERE  Eve_Id = @Eve_Id
      AND  Eve_EsEliminado = 0;

    SELECT Eve_Id, Eve_EsPublicado
    FROM app.tbEventosCalendario
    WHERE Eve_Id = @Eve_Id
      AND Eve_EsEliminado = 0;
END
GO

-- Quitar del calendario (baja lógica). Devuelve el mes para volver a él.
CREATE OR ALTER PROCEDURE app.PR_tbEventosCalendario_Eliminar
    @Eve_Id  int,
    @Usuario int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE app.tbEventosCalendario
    SET    Eve_EsEliminado     = 1,
           Eve_UsuarioModifica = @Usuario,
           Eve_FechaModifica   = GETDATE()
    WHERE  Eve_Id = @Eve_Id
      AND  Eve_EsEliminado = 0;

    SELECT Eve_Id, CONVERT(char(7), Eve_Inicio, 126) AS Mes
    FROM app.tbEventosCalendario
    WHERE Eve_Id = @Eve_Id;
END
GO

/* ---------------------------------------------------------------- Pantallas y permisos */
-- Ver el calendario: todos los roles.  Editar (crear, publicar, quitar): admin, director, secretaría.
IF NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas WHERE Pan_Descripcion = N'Calendario escolar')
    INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
    VALUES (N'Calendario escolar', 1, 0, 'Academico');
GO
IF NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas WHERE Pan_Descripcion = N'Editar calendario escolar')
    INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
    VALUES (N'Editar calendario escolar', 1, 0, 'Academico');
GO
INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0
WHERE p.Pan_Descripcion = N'Calendario escolar'
  AND NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas x WHERE x.Rol_Id = r.Rol_Id AND x.Pan_Id = p.Pan_Id);
GO
INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0
                        AND LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) IN ('admin', 'director', 'secretaria')
WHERE p.Pan_Descripcion = N'Editar calendario escolar'
  AND NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas x WHERE x.Rol_Id = r.Rol_Id AND x.Pan_Id = p.Pan_Id);
GO
