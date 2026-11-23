/* =============================================================================
   073 · Sustitución de docente  (espejo de Skuul: timetable_substitutions,
         TimetableCoverPanel y CreateTimetableSubstitution)

   - Dirección, cada mañana: ve qué docentes faltan, qué clases quedan sin profesor y asigna
     un suplente libre a esa hora. RRHH consulta las horas que cubrió cada suplente (pago de
     horas). El docente ve las clases que le toca cubrir y quién cubre las suyas.
   - Clases de un día = filas vivas de app.tbHorarios del día de la semana (1 = lunes, como
     app.tbDias), del año lectivo de la fecha (Hor_Año) y del semestre vigente
     (FN_Sustitucion_Ciclo: clave 'semestre_activo' de app.tbConfiguracion si existe; si no, el
     semestre de la fecha —ene-jun = 1, jul-dic = 2— cuando ese semestre tiene horario; si no,
     el último semestre con horario de ese año).
   - Horas: app.tbHoras guarda "01:00" para la 1 de la tarde; el catálogo va en orden, así que
     desde el Hor_Id 10 la hora es p. m. (FN_Sustitucion_Horas la pasa a minutos del día).
   - Ausente (FN_Sustitucion_Ausentes, uno por empleado, en este orden de prioridad):
       1 · vacaciones / permiso / incapacidad APROBADOS en app.tbVacaciones (Vac_Estado = 'A');
       2 · asistencia registrada 'Ausente' o 'Permiso' en app.tbAsistenciaEmpleados;
       3 · ausencia marcada a mano en app.tbAusenciasDocentes (fecha, docente, motivo).
     La sustitución guarda el origen y su referencia (Vac_Id, AsiEmp_Id o Aud_Id).
   - Reglas al asignar (las mismas de Skuul, validadas aquí con bloqueo):
       · la clase existe en el horario de ese día y el colegio no cierra (feriado/cierre publicado);
       · el docente de la clase está ausente ese día; el suplente es otro docente activo;
       · el suplente no está ausente ese día;
       · el suplente no tiene clase propia que se cruce (salvo que esa clase ya la cubra otra
         persona) ni cubre otra clase que se cruce;
       · una clase no tiene dos sustituciones activas el mismo día (índice único filtrado);
       · fechas: desde 7 días atrás (registro tardío) hasta 90 días adelante.
     Se serializa por clase y por suplente con sp_getapplock: dos personas no pueden reservar al
     mismo suplente a la misma hora.
   - Cancelar: solo clases de hoy en adelante, o el mismo día en que se registró (corregir un
     error). Una clase que ya pasó queda en el registro para el pago de horas (como Skuul).
   - Avisos: al suplente (usuarios ligados a su empleado) al asignar y al cancelar, en
     app.tbNotificaciones.
   - Prefijos: Sus_ (sustitución), Aud_ (ausencia marcada a mano).

   Solo agrega objetos nuevos; se puede ejecutar varias veces.
   Crear SIEMPRE con QUOTED_IDENTIFIER ON (índices filtrados).
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ---------------------------------------------------------------- Tablas */
IF OBJECT_ID('app.tbAusenciasDocentes') IS NULL
BEGIN
    CREATE TABLE app.tbAusenciasDocentes
    (
        Aud_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbAusenciasDocentes PRIMARY KEY,
        Emp_Id              int            NOT NULL CONSTRAINT FK_tbAusenciasDocentes_tbEmpleados REFERENCES app.tbEmpleados (Emp_Id),
        Aud_Fecha           date           NOT NULL,
        Aud_Motivo          nvarchar(300)  NOT NULL,
        Aud_EsEliminado     bit            NOT NULL CONSTRAINT DF_tbAusenciasDocentes_EsEliminado DEFAULT (0),
        Aud_UsuarioRegistra int            NULL,
        Aud_FechaRegistra   datetime2(0)   NOT NULL CONSTRAINT DF_tbAusenciasDocentes_FechaRegistra DEFAULT (SYSDATETIME()),
        Aud_UsuarioModifica int            NULL,
        Aud_FechaModifica   datetime2(0)   NULL
    );
    CREATE UNIQUE INDEX UX_tbAusenciasDocentes_EmpFecha ON app.tbAusenciasDocentes (Emp_Id, Aud_Fecha) WHERE Aud_EsEliminado = 0;
    CREATE INDEX IX_tbAusenciasDocentes_Fecha ON app.tbAusenciasDocentes (Aud_Fecha) INCLUDE (Emp_Id, Aud_Motivo) WHERE Aud_EsEliminado = 0;
END
GO

IF OBJECT_ID('app.tbSustituciones') IS NULL
BEGIN
    CREATE TABLE app.tbSustituciones
    (
        Sus_Id                int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbSustituciones PRIMARY KEY,
        Sus_Fecha             date           NOT NULL,
        Hor_Id                int            NOT NULL CONSTRAINT FK_tbSustituciones_tbHorarios REFERENCES app.tbHorarios (Hor_Id),
        Emp_IdAusente         int            NOT NULL CONSTRAINT FK_tbSustituciones_Ausente  REFERENCES app.tbEmpleados (Emp_Id),
        Emp_IdSuplente        int            NOT NULL CONSTRAINT FK_tbSustituciones_Suplente REFERENCES app.tbEmpleados (Emp_Id),
        Sus_Origen            varchar(15)    NOT NULL,
        Sus_OrigenId          int            NULL,
        Sus_Minutos           int            NOT NULL,
        Sus_Estado            varchar(10)    NOT NULL CONSTRAINT DF_tbSustituciones_Estado DEFAULT ('asignada'),
        Sus_Notas             nvarchar(500)  NULL,
        Sus_MotivoCancelacion nvarchar(300)  NULL,
        Sus_UsuarioCancela    int            NULL,
        Sus_FechaCancela      datetime2(0)   NULL,
        Sus_EsEliminado       bit            NOT NULL CONSTRAINT DF_tbSustituciones_EsEliminado DEFAULT (0),
        Sus_UsuarioRegistra   int            NULL,
        Sus_FechaRegistra     datetime2(0)   NOT NULL CONSTRAINT DF_tbSustituciones_FechaRegistra DEFAULT (SYSDATETIME()),
        Sus_UsuarioModifica   int            NULL,
        Sus_FechaModifica     datetime2(0)   NULL,
        CONSTRAINT CK_tbSustituciones_Origen CHECK (Sus_Origen IN ('vacaciones','permiso','incapacidad','asistencia','manual')),
        CONSTRAINT CK_tbSustituciones_Estado CHECK (Sus_Estado IN ('asignada','cancelada')),
        CONSTRAINT CK_tbSustituciones_Personas CHECK (Emp_IdAusente <> Emp_IdSuplente),
        CONSTRAINT CK_tbSustituciones_Minutos CHECK (Sus_Minutos > 0)
    );
    -- Una clase no tiene dos sustituciones activas el mismo día.
    CREATE UNIQUE INDEX UX_tbSustituciones_ClaseDia ON app.tbSustituciones (Hor_Id, Sus_Fecha)
        WHERE Sus_Estado = 'asignada' AND Sus_EsEliminado = 0;
    CREATE INDEX IX_tbSustituciones_Fecha ON app.tbSustituciones (Sus_Fecha)
        INCLUDE (Hor_Id, Emp_IdAusente, Emp_IdSuplente, Sus_Estado, Sus_Minutos) WHERE Sus_EsEliminado = 0;
    CREATE INDEX IX_tbSustituciones_Suplente ON app.tbSustituciones (Emp_IdSuplente, Sus_Fecha)
        INCLUDE (Hor_Id, Sus_Minutos) WHERE Sus_Estado = 'asignada' AND Sus_EsEliminado = 0;
END
GO

/* ---------------------------------------------------------------- Funciones */

-- Minuto del día de cada hora del catálogo. app.tbHoras guarda "01:00" para la 1 de la tarde;
-- el catálogo va en orden de reloj, por eso desde el Hor_Id 10 (después de "12:00") es p. m.
CREATE OR ALTER FUNCTION app.FN_Sustitucion_Horas ()
RETURNS TABLE
AS
RETURN
    SELECT h.Hor_Id,
           CASE WHEN x.Hh IS NULL OR x.Mm IS NULL THEN NULL
                ELSE (CASE WHEN h.Hor_Id >= 10 AND x.Hh < 12 THEN x.Hh + 12 ELSE x.Hh END) * 60 + x.Mm END AS Minuto
    FROM app.tbHoras h
    CROSS APPLY (SELECT LTRIM(RTRIM(h.Hor_Hora)) AS Texto) t
    CROSS APPLY (SELECT TRY_CAST(LEFT(t.Texto, NULLIF(CHARINDEX(':', t.Texto), 0) - 1) AS int) AS Hh,
                        TRY_CAST(SUBSTRING(t.Texto, NULLIF(CHARINDEX(':', t.Texto), 0) + 1, 2) AS int) AS Mm) x;
GO

-- Una clase del horario con sus textos limpios (algunos nombres traen saltos de línea) y su hora real.
CREATE OR ALTER FUNCTION app.FN_Sustitucion_Clases ()
RETURNS TABLE
AS
RETURN
    SELECT h.Hor_Id, h.Emp_Id, h.Dia_Id, h.Sem_Id, h.Hor_Año AS Anio, h.Hor_EsEliminado,
           h.Mat_Id, h.Cun_Id, h.Sec_Id, h.Mda_Id, h.Cur_Id, h.Aul_Id,
           hi.Minuto AS MinInicio, hf.Minuto AS MinFin,
           CAST(LTRIM(RTRIM(REPLACE(REPLACE(m.Mat_Nombre,       CHAR(13), N''), CHAR(10), N''))) AS nvarchar(150)) AS Materia,
           CAST(LTRIM(RTRIM(REPLACE(REPLACE(cn.Cun_Descripcion, CHAR(13), N''), CHAR(10), N''))) AS nvarchar(100)) AS Grado,
           CAST(LTRIM(RTRIM(REPLACE(REPLACE(s.Sec_Descripcion,  CHAR(13), N''), CHAR(10), N''))) AS nvarchar(50))  AS Seccion,
           CAST(LTRIM(RTRIM(REPLACE(REPLACE(md.Mda_Descripcion, CHAR(13), N''), CHAR(10), N''))) AS nvarchar(100)) AS Modalidad,
           CAST(LTRIM(RTRIM(REPLACE(REPLACE(c.Cur_Nombre,       CHAR(13), N''), CHAR(10), N''))) AS nvarchar(150)) AS Curso,
           CAST(LTRIM(RTRIM(REPLACE(REPLACE(a.Aul_Descripcion,  CHAR(13), N''), CHAR(10), N''))) AS nvarchar(100)) AS Aula
    FROM app.tbHorarios h
    LEFT JOIN app.FN_Sustitucion_Horas() hi ON hi.Hor_Id = h.Hor_HoraInicio
    LEFT JOIN app.FN_Sustitucion_Horas() hf ON hf.Hor_Id = h.Hor_HoraFinaliza
    LEFT JOIN app.tbMaterias m            ON m.Mat_Id  = h.Mat_Id
    LEFT JOIN app.tbCursosNiveles cn      ON cn.Cun_Id = h.Cun_Id
    LEFT JOIN app.tbSecciones s           ON s.Sec_Id  = h.Sec_Id
    LEFT JOIN app.tbModalidades md        ON md.Mda_Id = h.Mda_Id
    LEFT JOIN app.tbCursos c              ON c.Cur_Id  = h.Cur_Id
    LEFT JOIN app.tbAulas a               ON a.Aul_Id  = h.Aul_Id;
GO

-- Día de la semana (1 = lunes, como app.tbDias), año lectivo y semestre del horario que rige en una fecha.
CREATE OR ALTER FUNCTION app.FN_Sustitucion_Ciclo (@Fecha date)
RETURNS TABLE
AS
RETURN
    SELECT DATEDIFF(DAY, '19000101', @Fecha) % 7 + 1 AS Dia_Id,   -- 1900-01-01 fue lunes
           a.Anio, s.Sem_Id
    FROM (SELECT ISNULL((SELECT TOP (1) al.Ani_Anio
                         FROM app.FN_AnioLectivoDeFecha(@Fecha) f
                         JOIN app.tbAnioLectivo al ON al.Ani_Id = f.Ani_Id), YEAR(@Fecha)) AS Anio) a
    OUTER APPLY (
        SELECT TOP (1) x.Sem_Id
        FROM (
            SELECT TRY_CAST(c.Con_Valor AS int) AS Sem_Id, 0 AS Prioridad
            FROM app.tbConfiguracion c
            WHERE c.Con_Clave = 'semestre_activo'
            UNION ALL
            SELECT h.Sem_Id, CASE WHEN h.Sem_Id = CASE WHEN MONTH(@Fecha) <= 6 THEN 1 ELSE 2 END THEN 1 ELSE 2 END
            FROM app.tbHorarios h
            WHERE h.Hor_EsEliminado = 0 AND h.Hor_Año = a.Anio
            GROUP BY h.Sem_Id
        ) x
        WHERE x.Sem_Id IS NOT NULL
        ORDER BY x.Prioridad, x.Sem_Id DESC
    ) s;
GO

-- Empleados ausentes en una fecha y por qué (uno por empleado): manda lo aprobado en
-- vacaciones/permisos, luego la asistencia registrada, luego la ausencia marcada a mano.
CREATE OR ALTER FUNCTION app.FN_Sustitucion_Ausentes (@Fecha date)
RETURNS TABLE
AS
RETURN
    SELECT x.Emp_Id, x.Origen, x.OrigenId, x.Detalle
    FROM (
        SELECT y.Emp_Id, y.Origen, y.OrigenId, y.Detalle,
               ROW_NUMBER() OVER (PARTITION BY y.Emp_Id ORDER BY y.Prioridad, y.OrigenId DESC) AS Fila
        FROM (
            SELECT v.Emp_Id,
                   CAST(CASE v.Vac_Tipo WHEN 'V' THEN 'vacaciones' WHEN 'I' THEN 'incapacidad' ELSE 'permiso' END AS varchar(15)) AS Origen,
                   v.Vac_Id AS OrigenId,
                   CAST(NULLIF(LTRIM(RTRIM(v.Vac_Motivo)), '') AS nvarchar(300)) AS Detalle,
                   1 AS Prioridad
            FROM app.tbVacaciones v
            WHERE ISNULL(v.Vac_EsEliminado, 0) = 0 AND v.Vac_Estado = 'A'
              AND @Fecha BETWEEN v.Vac_FechaInicio AND ISNULL(v.Vac_FechaFin, v.Vac_FechaInicio)
            UNION ALL
            SELECT a.Emp_Id, 'asistencia', a.AsiEmp_Id,
                   CAST(CONCAT_WS(N': ', a.AsiEmp_Tipo, NULLIF(LTRIM(RTRIM(a.AsiEmp_Observacion)), '')) AS nvarchar(300)),
                   2
            FROM app.tbAsistenciaEmpleados a
            WHERE ISNULL(a.AsiEmp_EsEliminado, 0) = 0 AND a.AsiEmp_Fecha = @Fecha
              AND a.AsiEmp_Tipo IN ('Ausente', 'Permiso')
            UNION ALL
            SELECT d.Emp_Id, 'manual', d.Aud_Id, d.Aud_Motivo, 3
            FROM app.tbAusenciasDocentes d
            WHERE d.Aud_EsEliminado = 0 AND d.Aud_Fecha = @Fecha
        ) y
    ) x
    WHERE x.Fila = 1;
GO

-- Docentes que pueden cubrir una clase: persona activa, del cargo Docencia o con clases en el horario del año.
CREATE OR ALTER FUNCTION app.FN_Sustitucion_Docentes (@Anio int)
RETURNS TABLE
AS
RETURN
    SELECT e.Emp_Id,
           CAST(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''),
                                NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N'')) AS nvarchar(200)) AS Nombre,
           p.Per_Imagen AS Foto
    FROM app.tbEmpleados e
    JOIN app.tbPersonas p    ON p.Per_Id = e.Per_Id
    LEFT JOIN app.tbCargos c ON c.Car_Id = e.Car_Id
    WHERE ISNULL(p.Per_EsActivo, 1) = 1 AND ISNULL(p.Per_EsEliminado, 0) = 0
      AND (   c.Car_Descripcion LIKE N'Docen%'
           OR EXISTS (SELECT 1 FROM app.tbHorarios h
                      WHERE h.Emp_Id = e.Emp_Id AND h.Hor_EsEliminado = 0 AND (h.Hor_Año = @Anio OR h.Hor_Año IS NULL)));
GO

-- Nombre corto de un empleado aunque ya no esté activo (para el historial).
CREATE OR ALTER FUNCTION app.FN_Sustitucion_Nombre (@Emp_Id int)
RETURNS nvarchar(200)
AS
BEGIN
    RETURN (
        SELECT TOP (1) CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''),
                                       NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N''))
        FROM app.tbEmpleados e
        JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id
        WHERE e.Emp_Id = @Emp_Id);
END
GO

-- Clases vivas del horario en una fecha (día de la semana + año + semestre vigente).
CREATE OR ALTER FUNCTION app.FN_Sustitucion_ClasesDelDia (@Fecha date)
RETURNS TABLE
AS
RETURN
    SELECT c.*
    FROM app.FN_Sustitucion_Ciclo(@Fecha) k
    JOIN app.FN_Sustitucion_Clases() c
      ON c.Dia_Id = k.Dia_Id AND c.Sem_Id = k.Sem_Id AND (c.Anio = k.Anio OR c.Anio IS NULL) AND c.Hor_EsEliminado = 0;
GO

-- Lo que tiene ocupado cada docente en una fecha: sus clases (salvo las que ya cubre otra persona)
-- y las clases que cubre. Sirve para decir si está libre a una hora.
CREATE OR ALTER FUNCTION app.FN_Sustitucion_Ocupacion (@Fecha date)
RETURNS TABLE
AS
RETURN
    SELECT c.Emp_Id, c.Hor_Id, c.MinInicio, c.MinFin, CAST('clase' AS varchar(10)) AS Tipo, c.Materia, c.Grado, c.Seccion
    FROM app.FN_Sustitucion_ClasesDelDia(@Fecha) c
    WHERE NOT EXISTS (SELECT 1 FROM app.tbSustituciones s
                      WHERE s.Hor_Id = c.Hor_Id AND s.Sus_Fecha = @Fecha AND s.Sus_Estado = 'asignada' AND s.Sus_EsEliminado = 0)
    UNION ALL
    SELECT s.Emp_IdSuplente, s.Hor_Id, c.MinInicio, c.MinFin, 'cobertura', c.Materia, c.Grado, c.Seccion
    FROM app.tbSustituciones s
    JOIN app.FN_Sustitucion_Clases() c ON c.Hor_Id = s.Hor_Id
    WHERE s.Sus_Fecha = @Fecha AND s.Sus_Estado = 'asignada' AND s.Sus_EsEliminado = 0;
GO

-- Texto del origen de una ausencia.
CREATE OR ALTER FUNCTION app.FN_Sustitucion_OrigenTexto (@Origen varchar(15))
RETURNS nvarchar(40)
AS
BEGIN
    RETURN CASE @Origen
        WHEN 'vacaciones'  THEN N'vacaciones'
        WHEN 'permiso'     THEN N'permiso'
        WHEN 'incapacidad' THEN N'incapacidad'
        WHEN 'asistencia'  THEN N'ausencia registrada'
        WHEN 'manual'      THEN N'ausencia marcada'
        ELSE N'ausencia' END;
END
GO

/* ---------------------------------------------------------------- Lecturas */

-- Docentes ausentes en una fecha con sus clases de ese día y quién las cubre (una fila por clase;
-- un ausente sin clases ese día sale con Hor_Id NULL). @Emp_Id = solo ese docente (vista del docente).
-- También sale el titular de una clase cubierta aunque ya no figure ausente (se anuló su permiso).
CREATE OR ALTER PROCEDURE app.PR_tbSustituciones_Dia
    @Fecha  date,
    @Emp_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    DECLARE @Anio int = (SELECT Anio FROM app.FN_Sustitucion_Ciclo(@Fecha));

    SELECT a.Emp_Id, a.Origen, a.OrigenId, a.Detalle
    INTO #aus
    FROM app.FN_Sustitucion_Ausentes(@Fecha) a;

    INSERT INTO #aus (Emp_Id, Origen, OrigenId, Detalle)
    SELECT s.Emp_IdAusente, MIN(s.Sus_Origen), MIN(s.Sus_OrigenId), NULL
    FROM app.tbSustituciones s
    WHERE s.Sus_Fecha = @Fecha AND s.Sus_Estado = 'asignada' AND s.Sus_EsEliminado = 0
      AND NOT EXISTS (SELECT 1 FROM #aus x WHERE x.Emp_Id = s.Emp_IdAusente)
    GROUP BY s.Emp_IdAusente;

    SELECT c.*
    INTO #clases
    FROM app.FN_Sustitucion_ClasesDelDia(@Fecha) c
    WHERE c.Emp_Id IN (SELECT Emp_Id FROM #aus);

    -- Clases cubiertas que ya no están en el horario vivo (se rehízo el horario después).
    INSERT INTO #clases
    SELECT c.*
    FROM app.tbSustituciones s
    JOIN app.FN_Sustitucion_Clases() c ON c.Hor_Id = s.Hor_Id
    WHERE s.Sus_Fecha = @Fecha AND s.Sus_Estado = 'asignada' AND s.Sus_EsEliminado = 0
      AND NOT EXISTS (SELECT 1 FROM #clases x WHERE x.Hor_Id = s.Hor_Id);

    SELECT a.Emp_Id AS Emp_IdAusente,
           ISNULL(d.Nombre, app.FN_Sustitucion_Nombre(a.Emp_Id)) AS Ausente,
           d.Foto,
           a.Origen, a.OrigenId, a.Detalle,
           c.Hor_Id, c.MinInicio, c.MinFin, c.Materia, c.Grado, c.Seccion, c.Modalidad, c.Curso, c.Aula,
           ci.Eve_Titulo AS Cierre,
           s.Sus_Id, s.Emp_IdSuplente, app.FN_Sustitucion_Nombre(s.Emp_IdSuplente) AS Suplente, s.Sus_Notas,
           CAST(CASE WHEN s.Sus_Id IS NOT NULL AND (@Fecha >= @Hoy OR CAST(s.Sus_FechaRegistra AS date) = @Hoy) THEN 1 ELSE 0 END AS bit) AS PuedeCancelar
    FROM #aus a
    LEFT JOIN app.FN_Sustitucion_Docentes(@Anio) d ON d.Emp_Id = a.Emp_Id
    LEFT JOIN #clases c ON c.Emp_Id = a.Emp_Id
    OUTER APPLY (SELECT TOP (1) sa.Sea_Id FROM app.FN_SeccionAnioDeHorario(c.Hor_Id, @Fecha) sa) sa
    OUTER APPLY (SELECT TOP (1) x.Eve_Titulo FROM app.FN_CierreDelDia(@Fecha, sa.Sea_Id) x WHERE c.Hor_Id IS NOT NULL) ci
    LEFT JOIN app.tbSustituciones s
           ON s.Hor_Id = c.Hor_Id AND s.Sus_Fecha = @Fecha AND s.Sus_Estado = 'asignada' AND s.Sus_EsEliminado = 0
    WHERE (d.Emp_Id IS NOT NULL OR EXISTS (SELECT 1 FROM #clases y WHERE y.Emp_Id = a.Emp_Id))   -- solo docentes
      AND (@Emp_Id IS NULL OR a.Emp_Id = @Emp_Id)
    ORDER BY ISNULL(d.Nombre, app.FN_Sustitucion_Nombre(a.Emp_Id)), a.Emp_Id, c.MinInicio, c.Hor_Id;
END
GO

-- Indicadores del mes de la fecha: clases y minutos cubiertos (con @Emp_Id: los que cubrió ese docente),
-- y clases que ese docente cubre ese día.
CREATE OR ALTER PROCEDURE app.PR_tbSustituciones_Mes
    @Fecha  date,
    @Emp_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Desde date = DATEFROMPARTS(YEAR(@Fecha), MONTH(@Fecha), 1), @Hasta date = EOMONTH(@Fecha);

    SELECT COUNT(*) AS ClasesMes,
           ISNULL(SUM(s.Sus_Minutos), 0) AS MinutosMes,
           COUNT(DISTINCT s.Emp_IdSuplente) AS SuplentesMes,
           ISNULL(SUM(CASE WHEN s.Sus_Fecha = @Fecha THEN 1 ELSE 0 END), 0) AS ClasesDia
    FROM app.tbSustituciones s
    WHERE s.Sus_EsEliminado = 0 AND s.Sus_Estado = 'asignada'
      AND s.Sus_Fecha BETWEEN @Desde AND @Hasta
      AND (@Emp_Id IS NULL OR s.Emp_IdSuplente = @Emp_Id);
END
GO

-- Suplentes posibles para una clase en una fecha: docentes activos, no ausentes y libres a esa hora.
-- Orden (como lo pide Dirección): primero quien sabe la materia, luego quien da clases en el mismo
-- grado (y al mismo grupo), luego quien lleva menos sustituciones en el mes y menos clases ese día.
CREATE OR ALTER PROCEDURE app.PR_tbSustituciones_Sugerencias
    @Hor_Id int,
    @Fecha  date
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Anio int, @Sem int;
    SELECT @Anio = Anio, @Sem = Sem_Id FROM app.FN_Sustitucion_Ciclo(@Fecha);

    DECLARE @Titular int, @Ini int, @Fin int, @Mat int, @Cun int, @Sec int;
    SELECT @Titular = c.Emp_Id, @Ini = c.MinInicio, @Fin = c.MinFin, @Mat = c.Mat_Id, @Cun = c.Cun_Id, @Sec = c.Sec_Id
    FROM app.FN_Sustitucion_Clases() c
    WHERE c.Hor_Id = @Hor_Id;

    DECLARE @Desde date = DATEFROMPARTS(YEAR(@Fecha), MONTH(@Fecha), 1), @Hasta date = EOMONTH(@Fecha);

    SELECT o.Emp_Id, o.MinInicio, o.MinFin INTO #ocup FROM app.FN_Sustitucion_Ocupacion(@Fecha) o;
    SELECT a.Emp_Id INTO #aus FROM app.FN_Sustitucion_Ausentes(@Fecha) a;

    ;WITH cand AS (
        SELECT d.Emp_Id, d.Nombre, d.Foto,
               CAST(CASE WHEN EXISTS (SELECT 1 FROM app.tbEmpleados_tbMaterias em WHERE em.Emp_Id = d.Emp_Id AND em.Mat_Id = @Mat)
                         THEN 1 ELSE 0 END AS bit) AS SabeMateria,
               CAST(CASE WHEN EXISTS (SELECT 1 FROM app.tbHorarios h
                                      WHERE h.Emp_Id = d.Emp_Id AND h.Hor_EsEliminado = 0 AND h.Cun_Id = @Cun
                                        AND h.Sem_Id = @Sem AND (h.Hor_Año = @Anio OR h.Hor_Año IS NULL))
                         THEN 1 ELSE 0 END AS bit) AS MismoGrado,
               CAST(CASE WHEN EXISTS (SELECT 1 FROM app.tbHorarios h
                                      WHERE h.Emp_Id = d.Emp_Id AND h.Hor_EsEliminado = 0 AND h.Cun_Id = @Cun AND h.Sec_Id = @Sec
                                        AND h.Sem_Id = @Sem AND (h.Hor_Año = @Anio OR h.Hor_Año IS NULL))
                         THEN 1 ELSE 0 END AS bit) AS MismoGrupo,
               (SELECT COUNT(*) FROM app.tbSustituciones s
                WHERE s.Emp_IdSuplente = d.Emp_Id AND s.Sus_Estado = 'asignada' AND s.Sus_EsEliminado = 0
                  AND s.Sus_Fecha BETWEEN @Desde AND @Hasta) AS SustitucionesMes,
               (SELECT COUNT(*) FROM #ocup o WHERE o.Emp_Id = d.Emp_Id) AS ClasesDia
        FROM app.FN_Sustitucion_Docentes(@Anio) d
        WHERE @Titular IS NOT NULL AND @Ini IS NOT NULL AND @Fin IS NOT NULL
          AND d.Emp_Id <> @Titular
          AND NOT EXISTS (SELECT 1 FROM #aus a WHERE a.Emp_Id = d.Emp_Id)
          AND NOT EXISTS (SELECT 1 FROM #ocup o WHERE o.Emp_Id = d.Emp_Id AND o.MinInicio < @Fin AND o.MinFin > @Ini)
    )
    SELECT cand.*,
           CAST(ROW_NUMBER() OVER (ORDER BY cand.SabeMateria DESC, cand.MismoGrado DESC, cand.MismoGrupo DESC,
                                            cand.SustitucionesMes, cand.ClasesDia, cand.Nombre) AS int) AS Orden
    FROM cand
    ORDER BY Orden;
END
GO

-- Docentes para "Marcar docente ausente": cuántas clases tienen ese día y si ya figuran ausentes.
CREATE OR ALTER PROCEDURE app.PR_tbSustituciones_Docentes
    @Fecha date
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Anio int = (SELECT Anio FROM app.FN_Sustitucion_Ciclo(@Fecha));

    SELECT c.Emp_Id, COUNT(*) AS Clases INTO #n FROM app.FN_Sustitucion_ClasesDelDia(@Fecha) c GROUP BY c.Emp_Id;
    SELECT a.Emp_Id, a.Origen INTO #aus FROM app.FN_Sustitucion_Ausentes(@Fecha) a;

    SELECT d.Emp_Id, d.Nombre, d.Foto,
           ISNULL(n.Clases, 0) AS ClasesDia,
           a.Origen AS AusenteOrigen
    FROM app.FN_Sustitucion_Docentes(@Anio) d
    LEFT JOIN #n n   ON n.Emp_Id = d.Emp_Id
    LEFT JOIN #aus a ON a.Emp_Id = d.Emp_Id
    ORDER BY d.Nombre;
END
GO

-- Sustituciones de un rango (hasta 400 días). @Emp_Id = solo donde ese docente es el ausente o el suplente.
CREATE OR ALTER PROCEDURE app.PR_tbSustituciones_Historial
    @Desde  date,
    @Hasta  date,
    @Emp_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Desde IS NULL OR @Hasta IS NULL OR @Hasta < @Desde OR DATEDIFF(DAY, @Desde, @Hasta) > 400
        SELECT @Desde = NULL, @Hasta = NULL;   -- rango no válido: lista vacía

    SELECT s.Sus_Id, s.Sus_Fecha, s.Hor_Id, c.MinInicio, c.MinFin, s.Sus_Minutos,
           c.Materia, c.Grado, c.Seccion, c.Modalidad, c.Curso, c.Aula,
           s.Emp_IdAusente, app.FN_Sustitucion_Nombre(s.Emp_IdAusente) AS Ausente,
           s.Emp_IdSuplente, app.FN_Sustitucion_Nombre(s.Emp_IdSuplente) AS Suplente,
           s.Sus_Origen, s.Sus_OrigenId,
           CAST(COALESCE(ad.Aud_Motivo, v.Vac_Motivo, ae.AsiEmp_Tipo) AS nvarchar(300)) AS OrigenDetalle,
           s.Sus_Estado, s.Sus_Notas, s.Sus_MotivoCancelacion,
           app.FN_NombreUsuario(s.Sus_UsuarioRegistra) AS RegistradoPor, s.Sus_FechaRegistra,
           app.FN_NombreUsuario(s.Sus_UsuarioCancela) AS CanceladoPor, s.Sus_FechaCancela
    FROM app.tbSustituciones s
    JOIN app.FN_Sustitucion_Clases() c ON c.Hor_Id = s.Hor_Id
    LEFT JOIN app.tbAusenciasDocentes ad   ON s.Sus_Origen = 'manual' AND ad.Aud_Id = s.Sus_OrigenId
    LEFT JOIN app.tbVacaciones v           ON s.Sus_Origen IN ('vacaciones','permiso','incapacidad') AND v.Vac_Id = s.Sus_OrigenId
    LEFT JOIN app.tbAsistenciaEmpleados ae ON s.Sus_Origen = 'asistencia' AND ae.AsiEmp_Id = s.Sus_OrigenId
    WHERE s.Sus_EsEliminado = 0
      AND s.Sus_Fecha BETWEEN @Desde AND @Hasta
      AND (@Emp_Id IS NULL OR s.Emp_IdAusente = @Emp_Id OR s.Emp_IdSuplente = @Emp_Id)
    ORDER BY s.Sus_Fecha DESC, c.MinInicio, s.Sus_Id;
END
GO

/* ---------------------------------------------------------------- Escrituras */

-- Avisar a los usuarios ligados a un empleado (varios usuarios pueden compartir empleado).
CREATE OR ALTER PROCEDURE app.PR_tbSustituciones_Avisar
    @Emp_Id  int,
    @Titulo  nvarchar(150),
    @Mensaje nvarchar(500),
    @Url     varchar(300),
    @Usuario int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Ahora datetime2(0) = app.FN_AhoraHonduras();
    INSERT INTO app.tbNotificaciones (Usu_Id, Not_Titulo, Not_Mensaje, Not_Tipo, Not_EsLeida, Not_UrlDestino,
                                      Not_FechaEnvio, Not_EsEliminado, Not_UsuarioRegistra, Not_FechaRegistra)
    SELECT u.Usu_Id, @Titulo, LEFT(@Mensaje, 500), 'I', 0, @Url, @Ahora, 0, ISNULL(@Usuario, u.Usu_Id), @Ahora
    FROM seguridad.tbUsuarios u
    WHERE u.Emp_Id = @Emp_Id AND ISNULL(u.Usu_EsActivo, 1) = 1 AND ISNULL(u.Usu_EsEliminado, 0) = 0
      AND u.Usu_Id <> ISNULL(@Usuario, 0);
END
GO

-- Asignar un suplente a una clase en una fecha (ver reglas en el encabezado).
CREATE OR ALTER PROCEDURE app.PR_tbSustituciones_Asignar
    @Hor_Id         int,
    @Sus_Fecha      date,
    @Emp_IdSuplente int,
    @Sus_Notas      nvarchar(500) = NULL,
    @Usuario        int = NULL,
    @PuedeAsignar   bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Sus_Notas = NULLIF(LTRIM(RTRIM(@Sus_Notas)), N'');

    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    DECLARE @Msj nvarchar(2048);

    IF ISNULL(@PuedeAsignar, 0) = 0
        THROW 50060, N'No tiene permiso para asignar sustituciones.', 1;
    IF @Sus_Fecha IS NULL OR YEAR(@Sus_Fecha) NOT BETWEEN 2000 AND 2100
        THROW 50061, N'Indique la fecha de la clase.', 1;
    IF @Sus_Fecha < DATEADD(DAY, -7, @Hoy)
        THROW 50061, N'Solo se registran sustituciones de los últimos 7 días en adelante.', 1;
    IF @Sus_Fecha > DATEADD(DAY, 90, @Hoy)
        THROW 50061, N'Solo se planifican sustituciones hasta 90 días adelante.', 1;
    IF LEN(@Sus_Notas) > 500
        THROW 50062, N'Las notas admiten hasta 500 caracteres.', 1;

    DECLARE @Anio int = (SELECT Anio FROM app.FN_Sustitucion_Ciclo(@Sus_Fecha));
    DECLARE @Titular int, @Ini int, @Fin int, @Clase nvarchar(300);
    SELECT @Titular = c.Emp_Id, @Ini = c.MinInicio, @Fin = c.MinFin,
           @Clase = CONCAT(c.Materia, N' de ', CONCAT_WS(N' ', c.Grado, c.Seccion))
    FROM app.FN_Sustitucion_ClasesDelDia(@Sus_Fecha) c
    WHERE c.Hor_Id = @Hor_Id;

    IF @Titular IS NULL
        THROW 50063, N'Esa clase no está en el horario de ese día. Elija una clase del horario vigente.', 1;
    IF @Ini IS NULL OR @Fin IS NULL OR @Fin <= @Ini
        THROW 50063, N'La clase no tiene una hora válida en el horario.', 1;

    DECLARE @Sea_Id int = (SELECT TOP (1) Sea_Id FROM app.FN_SeccionAnioDeHorario(@Hor_Id, @Sus_Fecha));
    DECLARE @Cierre nvarchar(200) = (SELECT TOP (1) Eve_Titulo FROM app.FN_CierreDelDia(@Sus_Fecha, @Sea_Id));
    IF @Cierre IS NOT NULL
    BEGIN
        SET @Msj = CONCAT(N'El colegio cierra ese día por ', @Cierre, N': la clase no necesita suplente.');
        THROW 50064, @Msj, 1;
    END

    IF @Emp_IdSuplente IS NULL OR @Emp_IdSuplente <= 0
        THROW 50066, N'Elija al suplente.', 1;
    IF @Emp_IdSuplente = @Titular
        THROW 50066, N'El suplente no puede ser el mismo docente de la clase.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.FN_Sustitucion_Docentes(@Anio) d WHERE d.Emp_Id = @Emp_IdSuplente)
        THROW 50067, N'Elija como suplente a un docente activo.', 1;

    DECLARE @Suplente nvarchar(200) = app.FN_Sustitucion_Nombre(@Emp_IdSuplente);
    DECLARE @Ausente  nvarchar(200) = app.FN_Sustitucion_Nombre(@Titular);
    DECLARE @RecursoClase nvarchar(255) = CONCAT(N'sustitucion-clase-', @Hor_Id, N'-', CONVERT(char(8), @Sus_Fecha, 112));
    DECLARE @RecursoSuplente nvarchar(255) = CONCAT(N'sustitucion-docente-', @Emp_IdSuplente, N'-', CONVERT(char(8), @Sus_Fecha, 112));
    DECLARE @Origen varchar(15), @OrigenId int, @Sus_Id int, @Ocupado nvarchar(400), @Lock int;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Siempre primero la clase y después el suplente (mismo orden en todas las escrituras).
        EXEC @Lock = sp_getapplock @Resource = @RecursoClase, @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = 10000;
        IF @Lock < 0 THROW 50068, N'Otra persona está asignando esta clase. Intente de nuevo.', 1;
        EXEC @Lock = sp_getapplock @Resource = @RecursoSuplente, @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = 10000;
        IF @Lock < 0 THROW 50068, N'Otra persona está asignando a este docente. Intente de nuevo.', 1;

        SELECT @Origen = a.Origen, @OrigenId = a.OrigenId
        FROM app.FN_Sustitucion_Ausentes(@Sus_Fecha) a
        WHERE a.Emp_Id = @Titular;
        IF @Origen IS NULL
        BEGIN
            SET @Msj = CONCAT(@Ausente, N' no figura ausente ese día. Márquelo ausente antes de asignarle suplente.');
            THROW 50065, @Msj, 1;
        END

        DECLARE @Actual nvarchar(200) = (
            SELECT TOP (1) app.FN_Sustitucion_Nombre(s.Emp_IdSuplente)
            FROM app.tbSustituciones s WITH (UPDLOCK, HOLDLOCK)
            WHERE s.Hor_Id = @Hor_Id AND s.Sus_Fecha = @Sus_Fecha AND s.Sus_Estado = 'asignada' AND s.Sus_EsEliminado = 0);
        IF @Actual IS NOT NULL
        BEGIN
            SET @Msj = CONCAT(N'Esa clase ya la cubre ', @Actual, N' ese día. Cancele esa sustitución si quiere cambiar de suplente.');
            THROW 50068, @Msj, 1;
        END

        DECLARE @SupOrigen varchar(15) = (SELECT a.Origen FROM app.FN_Sustitucion_Ausentes(@Sus_Fecha) a WHERE a.Emp_Id = @Emp_IdSuplente);
        IF @SupOrigen IS NOT NULL
        BEGIN
            SET @Msj = CONCAT(@Suplente, N' está ausente ese día (', app.FN_Sustitucion_OrigenTexto(@SupOrigen), N').');
            THROW 50069, @Msj, 1;
        END

        SELECT TOP (1) @Ocupado = CASE o.Tipo
                   WHEN 'clase' THEN CONCAT(@Suplente, N' tiene clase de ', o.Materia, N' (', CONCAT_WS(N' ', o.Grado, o.Seccion), N') a esa hora.')
                   ELSE CONCAT(@Suplente, N' ya cubre ', o.Materia, N' (', CONCAT_WS(N' ', o.Grado, o.Seccion), N') a esa hora.') END
        FROM app.FN_Sustitucion_Ocupacion(@Sus_Fecha) o
        WHERE o.Emp_Id = @Emp_IdSuplente AND o.MinInicio < @Fin AND o.MinFin > @Ini
        ORDER BY o.MinInicio;
        IF @Ocupado IS NOT NULL
            THROW 50070, @Ocupado, 1;

        INSERT INTO app.tbSustituciones
            (Sus_Fecha, Hor_Id, Emp_IdAusente, Emp_IdSuplente, Sus_Origen, Sus_OrigenId, Sus_Minutos, Sus_Estado,
             Sus_Notas, Sus_UsuarioRegistra, Sus_FechaRegistra)
        VALUES
            (@Sus_Fecha, @Hor_Id, @Titular, @Emp_IdSuplente, @Origen, @OrigenId, @Fin - @Ini, 'asignada',
             @Sus_Notas, @Usuario, app.FN_AhoraHonduras());
        SET @Sus_Id = CAST(SCOPE_IDENTITY() AS int);

        SET @Msj = CONCAT(N'Cubre ', @Clase, N' el ', CONVERT(varchar(10), @Sus_Fecha, 103), N' de ',
                          RIGHT(CONCAT('0', @Ini / 60), 2), N':', RIGHT(CONCAT('0', @Ini % 60), 2), N' a ',
                          RIGHT(CONCAT('0', @Fin / 60), 2), N':', RIGHT(CONCAT('0', @Fin % 60), 2),
                          N', en lugar de ', @Ausente, N'.');
        DECLARE @Url varchar(300) = CONCAT('/Sustituciones?fecha=', CONVERT(char(10), @Sus_Fecha, 23));
        EXEC app.PR_tbSustituciones_Avisar @Emp_IdSuplente, N'Le toca cubrir una clase', @Msj, @Url, @Usuario;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50068, N'Esa clase ya tiene suplente ese día.', 1;
        THROW;
    END CATCH;

    SELECT @Sus_Id AS Id, CAST('asignada' AS varchar(15)) AS Estado;
END
GO

-- Cancelar una sustitución: de hoy en adelante, o el mismo día en que se registró (corregir un error).
CREATE OR ALTER PROCEDURE app.PR_tbSustituciones_Cancelar
    @Sus_Id       int,
    @Motivo       nvarchar(300) = NULL,
    @Usuario      int = NULL,
    @PuedeAsignar bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');
    IF ISNULL(@PuedeAsignar, 0) = 0
        THROW 50060, N'No tiene permiso para cancelar sustituciones.', 1;
    IF LEN(@Motivo) > 300
        THROW 50071, N'El motivo admite hasta 300 caracteres.', 1;

    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    DECLARE @Estado varchar(10), @Fecha date, @Registro date, @Hor_Id int, @Suplente int, @Msj nvarchar(2048);

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @Estado = s.Sus_Estado, @Fecha = s.Sus_Fecha, @Registro = CAST(s.Sus_FechaRegistra AS date),
               @Hor_Id = s.Hor_Id, @Suplente = s.Emp_IdSuplente
        FROM app.tbSustituciones s WITH (UPDLOCK, HOLDLOCK)
        WHERE s.Sus_Id = @Sus_Id AND s.Sus_EsEliminado = 0;

        IF @Estado IS NULL
            THROW 50072, N'Esa sustitución ya no existe.', 1;
        IF @Estado <> 'asignada'
            THROW 50072, N'Esa sustitución ya estaba cancelada.', 1;
        IF @Fecha < @Hoy AND @Registro <> @Hoy
            THROW 50073, N'Esa clase ya pasó: su sustitución queda en el registro para el pago de horas.', 1;

        UPDATE app.tbSustituciones
        SET Sus_Estado = 'cancelada', Sus_MotivoCancelacion = @Motivo,
            Sus_UsuarioCancela = @Usuario, Sus_FechaCancela = app.FN_AhoraHonduras(),
            Sus_UsuarioModifica = @Usuario, Sus_FechaModifica = app.FN_AhoraHonduras()
        WHERE Sus_Id = @Sus_Id;

        SELECT @Msj = CONCAT(N'Ya no cubre ', c.Materia, N' de ', CONCAT_WS(N' ', c.Grado, c.Seccion), N' el ',
                             CONVERT(varchar(10), @Fecha, 103), N'.', CASE WHEN @Motivo IS NOT NULL THEN CONCAT(N' Motivo: ', @Motivo) END)
        FROM app.FN_Sustitucion_Clases() c WHERE c.Hor_Id = @Hor_Id;
        DECLARE @Url varchar(300) = CONCAT('/Sustituciones?fecha=', CONVERT(char(10), @Fecha, 23));
        EXEC app.PR_tbSustituciones_Avisar @Suplente, N'Se canceló una clase que iba a cubrir', @Msj, @Url, @Usuario;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Sus_Id AS Id, CAST('cancelada' AS varchar(15)) AS Estado;
END
GO

-- Marcar a mano que un docente falta un día (cuando no está en vacaciones/permisos ni en la asistencia).
CREATE OR ALTER PROCEDURE app.PR_tbAusenciasDocentes_Marcar
    @Emp_Id       int,
    @Aud_Fecha    date,
    @Aud_Motivo   nvarchar(300),
    @Usuario      int = NULL,
    @PuedeAsignar bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Aud_Motivo = LTRIM(RTRIM(ISNULL(@Aud_Motivo, N'')));

    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    DECLARE @Msj nvarchar(2048);

    IF ISNULL(@PuedeAsignar, 0) = 0
        THROW 50060, N'No tiene permiso para marcar ausencias de docentes.', 1;
    IF @Aud_Fecha IS NULL OR YEAR(@Aud_Fecha) NOT BETWEEN 2000 AND 2100
        THROW 50074, N'Indique la fecha de la ausencia.', 1;
    IF @Aud_Fecha < DATEADD(DAY, -7, @Hoy)
        THROW 50074, N'Solo se marcan ausencias de los últimos 7 días en adelante.', 1;
    IF @Aud_Fecha > DATEADD(DAY, 90, @Hoy)
        THROW 50074, N'Solo se marcan ausencias hasta 90 días adelante.', 1;
    IF @Aud_Motivo = N''
        THROW 50075, N'Escriba el motivo de la ausencia.', 1;
    IF LEN(@Aud_Motivo) > 300
        THROW 50075, N'El motivo admite hasta 300 caracteres.', 1;

    DECLARE @Anio int = (SELECT Anio FROM app.FN_Sustitucion_Ciclo(@Aud_Fecha));
    IF NOT EXISTS (SELECT 1 FROM app.FN_Sustitucion_Docentes(@Anio) d WHERE d.Emp_Id = @Emp_Id)
        THROW 50076, N'Elija a un docente activo.', 1;

    DECLARE @Nombre nvarchar(200) = app.FN_Sustitucion_Nombre(@Emp_Id);
    DECLARE @Recurso nvarchar(255) = CONCAT(N'sustitucion-docente-', @Emp_Id, N'-', CONVERT(char(8), @Aud_Fecha, 112));
    DECLARE @Aud_Id int, @Lock int;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC @Lock = sp_getapplock @Resource = @Recurso, @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = 10000;
        IF @Lock < 0 THROW 50077, N'Otra persona está cambiando a este docente. Intente de nuevo.', 1;

        DECLARE @Origen varchar(15) = (SELECT a.Origen FROM app.FN_Sustitucion_Ausentes(@Aud_Fecha) a WHERE a.Emp_Id = @Emp_Id);
        IF @Origen IS NOT NULL
        BEGIN
            SET @Msj = CONCAT(@Nombre, N' ya figura ausente ese día (', app.FN_Sustitucion_OrigenTexto(@Origen), N').');
            THROW 50077, @Msj, 1;
        END

        IF EXISTS (SELECT 1 FROM app.tbSustituciones s
                   WHERE s.Emp_IdSuplente = @Emp_Id AND s.Sus_Fecha = @Aud_Fecha AND s.Sus_Estado = 'asignada' AND s.Sus_EsEliminado = 0)
        BEGIN
            SET @Msj = CONCAT(@Nombre, N' cubre clases ese día. Cancele esas sustituciones antes de marcarlo ausente.');
            THROW 50078, @Msj, 1;
        END

        INSERT INTO app.tbAusenciasDocentes (Emp_Id, Aud_Fecha, Aud_Motivo, Aud_UsuarioRegistra, Aud_FechaRegistra)
        VALUES (@Emp_Id, @Aud_Fecha, @Aud_Motivo, @Usuario, app.FN_AhoraHonduras());
        SET @Aud_Id = CAST(SCOPE_IDENTITY() AS int);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50077, N'Ese docente ya está marcado ausente ese día.', 1;
        THROW;
    END CATCH;

    SELECT @Aud_Id AS Id, CAST('ausente' AS varchar(15)) AS Estado;
END
GO

-- Quitar una ausencia marcada a mano (error al marcarla). No se quita si alguna clase ya tiene suplente.
CREATE OR ALTER PROCEDURE app.PR_tbAusenciasDocentes_Quitar
    @Aud_Id       int,
    @Usuario      int = NULL,
    @PuedeAsignar bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF ISNULL(@PuedeAsignar, 0) = 0
        THROW 50060, N'No tiene permiso para quitar ausencias de docentes.', 1;

    DECLARE @Emp_Id int, @Fecha date, @Lock int, @Msj nvarchar(2048);
    SELECT @Emp_Id = d.Emp_Id, @Fecha = d.Aud_Fecha
    FROM app.tbAusenciasDocentes d
    WHERE d.Aud_Id = @Aud_Id AND d.Aud_EsEliminado = 0;
    IF @Emp_Id IS NULL
        THROW 50079, N'Esa ausencia ya no existe.', 1;

    DECLARE @Recurso nvarchar(255) = CONCAT(N'sustitucion-docente-', @Emp_Id, N'-', CONVERT(char(8), @Fecha, 112));

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC @Lock = sp_getapplock @Resource = @Recurso, @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = 10000;
        IF @Lock < 0 THROW 50079, N'Otra persona está cambiando a este docente. Intente de nuevo.', 1;

        IF NOT EXISTS (SELECT 1 FROM app.tbAusenciasDocentes d WITH (UPDLOCK, HOLDLOCK) WHERE d.Aud_Id = @Aud_Id AND d.Aud_EsEliminado = 0)
            THROW 50079, N'Esa ausencia ya no existe.', 1;

        DECLARE @Cubiertas int = (SELECT COUNT(*) FROM app.tbSustituciones s
                                  WHERE s.Emp_IdAusente = @Emp_Id AND s.Sus_Fecha = @Fecha
                                    AND s.Sus_Estado = 'asignada' AND s.Sus_EsEliminado = 0);
        IF @Cubiertas > 0
        BEGIN
            SET @Msj = CONCAT(N'Ese día ', @Cubiertas, CASE WHEN @Cubiertas = 1 THEN N' clase ya tiene' ELSE N' clases ya tienen' END,
                              N' suplente. Cancele esas sustituciones antes de quitar la ausencia.');
            THROW 50079, @Msj, 1;
        END

        UPDATE app.tbAusenciasDocentes
        SET Aud_EsEliminado = 1, Aud_UsuarioModifica = @Usuario, Aud_FechaModifica = app.FN_AhoraHonduras()
        WHERE Aud_Id = @Aud_Id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Aud_Id AS Id, CAST('quitada' AS varchar(15)) AS Estado;
END
GO

/* ---------------------------------------------------------------- Pantallas y permisos */
--   Sustituciones de docentes     = la pantalla (admin, director, secretaria, RRHH, Docente). Sin
--                                   "Ver todas" el docente solo ve lo suyo: las clases que cubre y
--                                   sus propias ausencias, sin acciones.
--   Ver todas las sustituciones   = todos los docentes ausentes, todas las clases y el historial
--                                   completo con horas por suplente (admin, director, secretaria, RRHH)
--   Asignar sustituciones         = marcar/quitar ausencias, asignar y cancelar suplentes (admin, director)
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES
    (N'Sustituciones de docentes',   N'|admin|director|secretaria|recursos humanos|docente|'),
    (N'Ver todas las sustituciones', N'|admin|director|secretaria|recursos humanos|'),
    (N'Asignar sustituciones',       N'|admin|director|');

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
