/* =============================================================================
   Vista: app.vCandidatosGraduacion
   Proyecto: Archivado de Graduados
   Rama API: feature/graduacion-alumnos
   ----------------------------------------------------------------------------
   PROPÓSITO
     Lista alumnos activos que están cursando el último curso de su nivel
     educativo y evalúa si cumplen los requisitos para ser graduados:
       - Notas aprobadas (>= nota mínima en promedio y mínima por parcial).
       - Sin deuda pendiente en cuentas por cobrar.

   ----------------------------------------------------------------------------
   ESQUEMA REAL VALIDADO (DB_GestionColegial):
     - Schema real es `app` (no `academico`). Finanzas viven en `finanza`.
     - app.tbEstados:  Est_Id 1 = 'Activo', Est_Id 3 = 'Graduado'.
     - app.tbCursosNiveles tiene Cun_Orden (int) y Niv_Id. El "último curso"
       de un nivel se identifica con MAX(Cun_Orden) por Niv_Id.
     - NO existe app.tbBoletines. La consolidación de notas se hace sobre
       app.tbNotas (Not_Nota int, Not_Año date, Mat_Id, Sem_Id, Pac_Id).
     - app.tbAlumnos almacena el curso actual en Cun_Id.

   ----------------------------------------------------------------------------
   CONFIGURACIÓN:
     -- Nota mínima de aprobación: configurable vía
        app.tbConfiguracion (Con_Clave = 'nota_minima_aprobacion').
        Default de fallback si la fila no existe: 70.
        La vista lee el valor cada vez que se consulta, así un cambio en
        configuración se refleja en el siguiente refresh sin recompilar.

   DECISIONES REQUERIDAS (pendientes de negocio):
     -- DECISIÓN REQUERIDA: Identificación del "último curso" del nivel.
        Hoy se infiere como MAX(Cun_Orden) por Niv_Id. Esto asume que el
        orden refleja secuencia académica. Alternativas si no es confiable:
          (a) Agregar columna bit Cun_EsUltimo a app.tbCursosNiveles.
          (b) Agregar columna Niv_CursoFinalCun_Id en app.tbNivelesEducativos.
          (c) Mantener tabla de configuración de "currículo" por nivel.

   TODO (a validar con el equipo funcional):
     -- TODO: Confirmar si la regla de notas debe usar PromedioAnual de
              tbAlumnos o un cálculo histórico por materia desde tbNotas.
     -- TODO: Considerar año académico vigente (filtro por YEAR(Not_Año)) si
              se quiere evaluar solo el ciclo lectivo actual.
   ============================================================================= */

IF OBJECT_ID('app.vCandidatosGraduacion', 'V') IS NOT NULL
    DROP VIEW app.vCandidatosGraduacion;
GO

CREATE VIEW app.vCandidatosGraduacion
AS
WITH ConfigNota AS
(
    -- Nota mínima de aprobación configurable. Fallback = 70 si no existe la fila.
    SELECT ISNULL(
              (SELECT TOP 1 TRY_CAST(Con_Valor AS DECIMAL(5,2))
               FROM   app.tbConfiguracion
               WHERE  Con_Clave = 'nota_minima_aprobacion'),
              70
           ) AS NotaMinima
),
UltimosCursos AS
(
    -- Identifica el Cun_Id "último" por nivel educativo.
    SELECT  cn.Niv_Id,
            cn.Cun_Id,
            cn.Cun_Descripcion,
            cn.Cun_Orden,
            ROW_NUMBER() OVER (PARTITION BY cn.Niv_Id ORDER BY cn.Cun_Orden DESC) AS rn
    FROM    app.tbCursosNiveles AS cn
    WHERE   cn.Cun_EsEliminado = 0
),
NotasAlumno AS
(
    -- Promedio simple de notas no eliminadas por alumno (todas las materias y parciales).
    SELECT  n.Alu_Id,
            AVG(CAST(n.Not_Nota AS DECIMAL(9,2))) AS PromedioCalculado,
            MIN(CAST(n.Not_Nota AS DECIMAL(9,2))) AS NotaMinima
    FROM    app.tbNotas AS n
    WHERE   n.Not_EsEliminado = 0
      AND   n.Not_EsActivo    = 1
    GROUP BY n.Alu_Id
),
DeudaAlumno AS
(
    SELECT  cc.Alu_Id,
            SUM(ISNULL(cc.Cco_MontoPendiente, 0)) AS DeudaPendiente
    FROM    finanza.tbCuentasCobrar AS cc
    WHERE   cc.Cco_EsEliminado = 0
    GROUP BY cc.Alu_Id
)
SELECT
    a.Alu_Id,
    LTRIM(RTRIM(
        ISNULL(p.Per_PrimerNombre,'')   + ' ' +
        ISNULL(p.Per_SegundoNombre,'')  + ' ' +
        ISNULL(p.Per_ApellidoPaterno,'')+ ' ' +
        ISNULL(p.Per_ApellidoMaterno,'')
    ))                                                    AS NombreCompleto,
    n.Niv_Descripcion,
    uc.Cun_Descripcion                                    AS Cur_Descripcion, -- nombre del último curso
    s.Sec_Descripcion,

    -- Validación de notas (umbral configurable vía app.tbConfiguracion)
    CASE WHEN ISNULL(na.PromedioCalculado, 0) >= cfg.NotaMinima
              AND ISNULL(na.NotaMinima, 0)     >= cfg.NotaMinima
         THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END      AS NotasOk,

    -- Deuda
    ISNULL(da.DeudaPendiente, 0)                          AS DeudaPendiente,
    CASE WHEN ISNULL(da.DeudaPendiente, 0) = 0
         THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END      AS DeudaOk,

    -- Estado de validación consolidado
    CASE
        WHEN ISNULL(na.PromedioCalculado,0) >= cfg.NotaMinima AND ISNULL(na.NotaMinima,0) >= cfg.NotaMinima
             AND ISNULL(da.DeudaPendiente,0) = 0
             THEN 'Cumple'
        WHEN (ISNULL(na.PromedioCalculado,0) < cfg.NotaMinima OR ISNULL(na.NotaMinima,0) < cfg.NotaMinima)
             AND ISNULL(da.DeudaPendiente,0) > 0
             THEN 'Múltiples motivos'
        WHEN ISNULL(na.PromedioCalculado,0) < cfg.NotaMinima OR ISNULL(na.NotaMinima,0) < cfg.NotaMinima
             THEN 'Notas pendientes'
        WHEN ISNULL(da.DeudaPendiente,0) > 0
             THEN 'Deuda pendiente'
        ELSE 'Cumple'
    END                                                   AS EstadoValidacion,

    -- Texto descriptivo con los motivos
    LTRIM(
        CASE WHEN ISNULL(na.PromedioCalculado,0) < cfg.NotaMinima OR ISNULL(na.NotaMinima,0) < cfg.NotaMinima
             THEN 'Notas reprobadas; ' ELSE '' END
      + CASE WHEN ISNULL(da.DeudaPendiente,0) > 0
             THEN 'Saldo pendiente: ' + CONVERT(VARCHAR(30), CAST(da.DeudaPendiente AS DECIMAL(18,2))) + '; '
             ELSE '' END
    )                                                     AS MotivosBloqueo

FROM        app.tbAlumnos          AS a
CROSS JOIN  ConfigNota             AS cfg
INNER JOIN  app.tbPersonas         AS p   ON p.Per_Id = a.Per_Id
INNER JOIN  app.tbNivelesEducativos AS n  ON n.Niv_Id = a.Niv_Id
INNER JOIN  UltimosCursos          AS uc  ON uc.Niv_Id = a.Niv_Id
                                         AND uc.Cun_Id = a.Cun_Id
                                         AND uc.rn = 1
LEFT  JOIN  app.tbSecciones        AS s   ON s.Sec_Id = a.Sec_Id
LEFT  JOIN  NotasAlumno            AS na  ON na.Alu_Id = a.Alu_Id
LEFT  JOIN  DeudaAlumno            AS da  ON da.Alu_Id = a.Alu_Id
WHERE   a.Est_Id = 1   -- Activo
;
GO
