/* =============================================================================
   063 · Reporte de asistencia de alumnos   (requiere los scripts 060, 061 y 062)

   - La asistencia se pasa por clase (un registro por horario). Para el reporte, cada alumno tiene
     un estado por día: T si llegó tarde a alguna clase, P si estuvo en alguna, A si faltó y J si
     todas sus faltas del día están justificadas.
   - % de asistencia = (P + T) / (P + T + A + J) sobre los días con pase de lista.
   - En riesgo = menos de 90 % de asistencia o 3 o más ausencias sin justificar en el rango.
   - Días de clase = lunes a viernes del rango (hasta hoy) sin feriados ni cierres publicados.
   - Permisos: "Reporte de asistencia de alumnos" (admin, director, docente) y
     "Ver asistencia de todas las secciones" (admin, director). Sin el segundo, el docente
     solo ve las secciones donde da clase.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Estado de cada alumno por día, a partir de sus registros por clase.
CREATE OR ALTER FUNCTION app.FN_AsistenciaDiaria (@Desde date, @Hasta date)
RETURNS TABLE
AS
RETURN
    SELECT x.Alu_Id, x.Fecha,
           CAST(CASE WHEN x.nT > 0 THEN 'T'
                     WHEN x.nP > 0 THEN 'P'
                     WHEN x.nA > 0 THEN 'A'
                     ELSE 'J' END AS char(1)) AS Estado
    FROM (
        SELECT a.Alu_Id, a.Asi_Fecha AS Fecha,
               SUM(CASE WHEN a.Asi_Estado = 'P' THEN 1 ELSE 0 END) AS nP,
               SUM(CASE WHEN a.Asi_Estado = 'T' THEN 1 ELSE 0 END) AS nT,
               SUM(CASE WHEN a.Asi_Estado = 'A' THEN 1 ELSE 0 END) AS nA
        FROM app.tbAsistencia a
        WHERE a.Asi_EsEliminado = 0
          AND a.Asi_Fecha BETWEEN @Desde AND @Hasta
          AND a.Asi_Estado IN ('P', 'T', 'A', 'J')
        GROUP BY a.Alu_Id, a.Asi_Fecha
    ) x;
GO

-- Lunes a viernes del rango, con el feriado o cierre que aplique a la sección.
CREATE OR ALTER FUNCTION app.FN_DiasHabilesSeccion (@Sea_Id int, @Desde date, @Hasta date)
RETURNS TABLE
AS
RETURN
    WITH n AS (
        SELECT TOP (CASE WHEN @Hasta < @Desde THEN 0 ELSE DATEDIFF(DAY, @Desde, @Hasta) + 1 END)
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS i
        FROM sys.all_objects a CROSS JOIN sys.all_objects b
    ), d AS (
        SELECT DATEADD(DAY, i, @Desde) AS Fecha FROM n
    )
    SELECT d.Fecha,
           CAST(CASE WHEN c.Eve_Id IS NULL THEN 0 ELSE 1 END AS bit) AS EsCierre,
           c.Eve_Titulo AS Motivo
    FROM d
    OUTER APPLY app.FN_CierreDelDia(d.Fecha, @Sea_Id) c
    WHERE DATEDIFF(DAY, '19000101', d.Fecha) % 7 < 5;   -- 1900-01-01 fue lunes
GO

-- Secciones del año que puede ver la persona (con @Emp_Id: solo donde da clase).
CREATE OR ALTER FUNCTION app.FN_SeccionesAsistencia (@Ani_Id int, @Emp_Id int)
RETURNS TABLE
AS
RETURN
    SELECT sa.Sea_Id, sa.Ani_Id, sa.Niv_Id, sa.Cun_Id, sa.Sec_Id, sa.Mda_Id, sa.Emp_Id,
           COALESCE(NULLIF(LTRIM(RTRIM(sa.Sea_Nombre)), N''), CONCAT_WS(N' ', cn.Cun_Descripcion, s.Sec_Descripcion)) AS Seccion,
           ne.Niv_Descripcion AS Nivel,
           cn.Cun_Descripcion AS Grado
    FROM app.tbSeccionesAnio sa
    JOIN app.tbAnioLectivo an             ON an.Ani_Id = sa.Ani_Id
    LEFT JOIN app.tbNivelesEducativos ne  ON ne.Niv_Id = sa.Niv_Id
    LEFT JOIN app.tbCursosNiveles cn      ON cn.Cun_Id = sa.Cun_Id
    LEFT JOIN app.tbSecciones s           ON s.Sec_Id  = sa.Sec_Id
    WHERE sa.Ani_Id = @Ani_Id
      AND sa.Sea_EsEliminado = 0
      AND (@Emp_Id IS NULL
           OR sa.Emp_Id = @Emp_Id
           OR EXISTS (SELECT 1 FROM app.tbHorarios h
                      WHERE h.Emp_Id = @Emp_Id AND h.Hor_EsEliminado = 0
                        AND h.Cun_Id = sa.Cun_Id AND h.Sec_Id = sa.Sec_Id
                        AND (h.Mda_Id IS NULL OR sa.Mda_Id IS NULL OR h.Mda_Id = sa.Mda_Id)
                        AND (h.Hor_Año IS NULL OR h.Hor_Año = an.Ani_Anio)));
GO

-- Año lectivo de una fecha; si no hay, el más reciente que ya empezó.
CREATE OR ALTER PROCEDURE app.PR_ReporteAsistencia_Anio
    @Fecha date
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Ani_Id int = (SELECT Ani_Id FROM app.FN_AnioLectivoDeFecha(@Fecha));
    IF @Ani_Id IS NULL
        SET @Ani_Id = (SELECT TOP (1) Ani_Id FROM app.tbAnioLectivo
                       WHERE Ani_EsEliminado = 0 AND Ani_FechaInicio <= @Fecha
                       ORDER BY Ani_FechaInicio DESC);
    SELECT Ani_Id, Ani_Nombre, Ani_FechaInicio, Ani_FechaFin
    FROM app.tbAnioLectivo
    WHERE Ani_Id = @Ani_Id;
END
GO

CREATE OR ALTER PROCEDURE app.PR_ReporteAsistencia_Periodos
    @Ani_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Pan_Id, Pan_Nombre, Pan_FechaInicio, Pan_FechaFin
    FROM app.tbPeriodosAnio
    WHERE Ani_Id = @Ani_Id AND Pan_EsEliminado = 0
    ORDER BY Pan_Orden, Pan_FechaInicio;
END
GO

-- Opciones de los filtros en cascada (Nivel → Grado → Sección).
CREATE OR ALTER PROCEDURE app.PR_ReporteAsistencia_Filtros
    @Ani_Id int,
    @Emp_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Sea_Id, Seccion, Niv_Id, Nivel, Cun_Id, Grado
    FROM app.FN_SeccionesAsistencia(@Ani_Id, @Emp_Id)
    ORDER BY Niv_Id, Cun_Id, Seccion;
END
GO

-- Resumen por sección en un rango.
CREATE OR ALTER PROCEDURE app.PR_ReporteAsistencia_Secciones
    @Ani_Id int,
    @Desde  date,
    @Hasta  date,
    @Niv_Id int = NULL,
    @Cun_Id int = NULL,
    @Sea_Id int = NULL,
    @Emp_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    IF @Hasta > @Hoy SET @Hasta = @Hoy;

    ;WITH sec AS (
        SELECT * FROM app.FN_SeccionesAsistencia(@Ani_Id, @Emp_Id)
        WHERE (@Niv_Id IS NULL OR Niv_Id = @Niv_Id)
          AND (@Cun_Id IS NULL OR Cun_Id = @Cun_Id)
          AND (@Sea_Id IS NULL OR Sea_Id = @Sea_Id)
    ), alu AS (
        SELECT DISTINCT m.Sea_Id, m.Alu_Id
        FROM app.tbMatriculaAnio m
        JOIN sec ON sec.Sea_Id = m.Sea_Id
        WHERE m.Mta_EsEliminado = 0 AND m.Mta_Estado <> 4
    ), dia AS (
        SELECT alu.Sea_Id, alu.Alu_Id, d.Fecha, d.Estado
        FROM alu
        JOIN app.FN_AsistenciaDiaria(@Desde, @Hasta) d ON d.Alu_Id = alu.Alu_Id
    ), porAlumno AS (
        SELECT Sea_Id, Alu_Id,
               SUM(CASE WHEN Estado IN ('P', 'T') THEN 1 ELSE 0 END) AS Asistio,
               SUM(CASE WHEN Estado = 'A' THEN 1 ELSE 0 END) AS Ausente,
               COUNT(*) AS Dias
        FROM dia
        GROUP BY Sea_Id, Alu_Id
    )
    SELECT sec.Sea_Id, sec.Seccion, sec.Nivel, sec.Grado,
           (SELECT COUNT(*) FROM alu WHERE alu.Sea_Id = sec.Sea_Id) AS Alumnos,
           (SELECT COUNT(*) FROM app.FN_DiasHabilesSeccion(sec.Sea_Id, @Desde, @Hasta) h WHERE h.EsCierre = 0) AS DiasClase,
           (SELECT COUNT(DISTINCT Fecha) FROM dia WHERE dia.Sea_Id = sec.Sea_Id) AS DiasConRegistro,
           ISNULL(t.Presentes, 0)    AS Presentes,
           ISNULL(t.Tardanzas, 0)    AS Tardanzas,
           ISNULL(t.Ausentes, 0)     AS Ausentes,
           ISNULL(t.Justificados, 0) AS Justificados,
           CAST(CASE WHEN ISNULL(t.Total, 0) = 0 THEN NULL
                     ELSE 100.0 * (t.Presentes + t.Tardanzas) / t.Total END AS decimal(5, 1)) AS PorcAsistencia,
           (SELECT COUNT(*) FROM porAlumno pa
            WHERE pa.Sea_Id = sec.Sea_Id
              AND (pa.Ausente >= 3 OR 100.0 * pa.Asistio / pa.Dias < 90)) AS AlumnosEnRiesgo
    FROM sec
    OUTER APPLY (
        SELECT SUM(CASE WHEN Estado = 'P' THEN 1 ELSE 0 END) AS Presentes,
               SUM(CASE WHEN Estado = 'T' THEN 1 ELSE 0 END) AS Tardanzas,
               SUM(CASE WHEN Estado = 'A' THEN 1 ELSE 0 END) AS Ausentes,
               SUM(CASE WHEN Estado = 'J' THEN 1 ELSE 0 END) AS Justificados,
               COUNT(*) AS Total
        FROM dia WHERE dia.Sea_Id = sec.Sea_Id
    ) t
    ORDER BY sec.Niv_Id, sec.Cun_Id, sec.Seccion;
END
GO

CREATE OR ALTER PROCEDURE app.PR_ReporteAsistencia_SeccionInfo
    @Sea_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Ani_Id int = (SELECT Ani_Id FROM app.tbSeccionesAnio WHERE Sea_Id = @Sea_Id AND Sea_EsEliminado = 0);
    SELECT s.Sea_Id, s.Ani_Id, s.Seccion, s.Nivel, s.Grado,
           CASE WHEN s.Emp_Id IS NULL THEN NULL ELSE app.FN_NombreEmpleado(s.Emp_Id) END AS Guia
    FROM app.FN_SeccionesAsistencia(@Ani_Id, NULL) s
    WHERE s.Sea_Id = @Sea_Id;
END
GO

-- Un renglón por alumno de la sección.
CREATE OR ALTER PROCEDURE app.PR_ReporteAsistencia_Alumnos
    @Sea_Id int,
    @Desde  date,
    @Hasta  date
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    IF @Hasta > @Hoy SET @Hasta = @Hoy;

    ;WITH alu AS (
        SELECT DISTINCT m.Alu_Id
        FROM app.tbMatriculaAnio m
        WHERE m.Sea_Id = @Sea_Id AND m.Mta_EsEliminado = 0 AND m.Mta_Estado <> 4
    ), t AS (
        SELECT d.Alu_Id,
               SUM(CASE WHEN d.Estado = 'P' THEN 1 ELSE 0 END) AS Presentes,
               SUM(CASE WHEN d.Estado = 'T' THEN 1 ELSE 0 END) AS Tardanzas,
               SUM(CASE WHEN d.Estado = 'A' THEN 1 ELSE 0 END) AS Ausentes,
               SUM(CASE WHEN d.Estado = 'J' THEN 1 ELSE 0 END) AS Justificados,
               COUNT(*) AS Dias,
               MAX(CASE WHEN d.Estado = 'A' THEN d.Fecha END) AS UltimaAusencia
        FROM app.FN_AsistenciaDiaria(@Desde, @Hasta) d
        JOIN alu ON alu.Alu_Id = d.Alu_Id
        GROUP BY d.Alu_Id
    )
    SELECT alu.Alu_Id,
           CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), N''),
                     NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N'')) AS NombreAlumno,
           p.Per_Identidad AS Identidad,
           ISNULL(t.Presentes, 0)    AS Presentes,
           ISNULL(t.Tardanzas, 0)    AS Tardanzas,
           ISNULL(t.Ausentes, 0)     AS Ausentes,
           ISNULL(t.Justificados, 0) AS Justificados,
           ISNULL(t.Dias, 0)         AS DiasRegistrados,
           CAST(CASE WHEN ISNULL(t.Dias, 0) = 0 THEN NULL
                     ELSE 100.0 * (t.Presentes + t.Tardanzas) / t.Dias END AS decimal(5, 1)) AS PorcAsistencia,
           CAST(CASE WHEN ISNULL(t.Dias, 0) > 0
                      AND (t.Ausentes >= 3 OR 100.0 * (t.Presentes + t.Tardanzas) / t.Dias < 90) THEN 1 ELSE 0 END AS bit) AS EnRiesgo,
           t.UltimaAusencia
    FROM alu
    JOIN app.tbAlumnos al  ON al.Alu_Id = alu.Alu_Id
    JOIN app.tbPersonas p  ON p.Per_Id  = al.Per_Id
    LEFT JOIN t            ON t.Alu_Id  = alu.Alu_Id
    ORDER BY p.Per_ApellidoPaterno, p.Per_ApellidoMaterno, p.Per_PrimerNombre;
END
GO

-- Columnas de la planilla: lunes a viernes del rango (hasta hoy).
CREATE OR ALTER PROCEDURE app.PR_ReporteAsistencia_Dias
    @Sea_Id int,
    @Desde  date,
    @Hasta  date
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    IF @Hasta > @Hoy SET @Hasta = @Hoy;

    SELECT h.Fecha, h.EsCierre, h.Motivo,
           CAST(CASE WHEN EXISTS (
                    SELECT 1 FROM app.tbAsistencia a
                    JOIN app.tbMatriculaAnio m ON m.Alu_Id = a.Alu_Id AND m.Sea_Id = @Sea_Id
                                              AND m.Mta_EsEliminado = 0 AND m.Mta_Estado <> 4
                    WHERE a.Asi_Fecha = h.Fecha AND a.Asi_EsEliminado = 0) THEN 1 ELSE 0 END AS bit) AS ConRegistro
    FROM app.FN_DiasHabilesSeccion(@Sea_Id, @Desde, @Hasta) h
    ORDER BY h.Fecha;
END
GO

-- Celdas de la planilla: estado de cada alumno por día.
CREATE OR ALTER PROCEDURE app.PR_ReporteAsistencia_Planilla
    @Sea_Id int,
    @Desde  date,
    @Hasta  date
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    IF @Hasta > @Hoy SET @Hasta = @Hoy;

    SELECT d.Alu_Id, d.Fecha, d.Estado
    FROM app.FN_AsistenciaDiaria(@Desde, @Hasta) d
    WHERE EXISTS (SELECT 1 FROM app.tbMatriculaAnio m
                  WHERE m.Alu_Id = d.Alu_Id AND m.Sea_Id = @Sea_Id
                    AND m.Mta_EsEliminado = 0 AND m.Mta_Estado <> 4)
    ORDER BY d.Alu_Id, d.Fecha;
END
GO

-- Permisos.
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES
    (N'Reporte de asistencia de alumnos',      N'|admin|director|docente|'),
    (N'Ver asistencia de todas las secciones', N'|admin|director|');

INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
SELECT x.Nombre, 1, 0, 'Academico'
FROM @Pantallas x
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas p WHERE p.Pan_Descripcion = x.Nombre);

INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN @Pantallas x ON x.Nombre = p.Pan_Descripcion
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0
                        AND x.Roles LIKE N'%|' + LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) + N'|%'
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas y WHERE y.Rol_Id = r.Rol_Id AND y.Pan_Id = p.Pan_Id);
GO
