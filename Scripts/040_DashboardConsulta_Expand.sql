-- 040_DashboardConsulta_Expand.sql
-- Expande app.PR_DashboardConsulta_KPIs a 10 result sets (vista ejecutiva read-only).
-- Tablas usadas: app.tbAlumnos, app.tbEmpleados, app.tbPersonas, app.tbCursos,
--                app.tbNivelesEducativos, app.tbModalidades, app.tbHorario,
--                app.tbCargos, app.tbDepartamentoEmpleados, app.tbEstados,
--                finanza.tbCuentasCobrar.

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_DashboardConsulta_KPIs]') AND type = 'P')
    DROP PROCEDURE [app].[PR_DashboardConsulta_KPIs];
GO
CREATE PROCEDURE [app].[PR_DashboardConsulta_KPIs]
    @Anio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

    -- ── RS1: KPIs Institucionales ───────────────────────────────────────
    DECLARE @TotalAlumnos       INT = (SELECT COUNT(*) FROM [app].[tbAlumnos] WHERE AnioCursado = @Anio);
    DECLARE @TotalAlumnosActivos INT = (SELECT COUNT(*) FROM [app].[tbAlumnos] a
                                         INNER JOIN [app].[tbEstados] e ON a.Est_Id = e.Est_Id
                                         WHERE a.AnioCursado = @Anio
                                           AND e.Est_Descripcion IN (N'Activo', N'Graduado'));
    DECLARE @TotalEmpleados INT = (SELECT COUNT(*)
                                   FROM [app].[tbEmpleados] e
                                   INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
                                   WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0);
    DECLARE @TotalDocentes INT = (SELECT COUNT(DISTINCT h.Emp_Id)
                                  FROM [app].[tbHorario] h
                                  WHERE h.Hor_Año = @Anio AND h.Hor_EsEliminado = 0);
    DECLARE @TotalCursos INT = (SELECT COUNT(*) FROM [app].[tbCursos]
                                WHERE Cur_EsEliminado = 0 AND Cur_EsActivo = 1);
    DECLARE @TotalClasesHorario INT = (SELECT COUNT(*) FROM [app].[tbHorario]
                                       WHERE Hor_Año = @Anio AND Hor_EsEliminado = 0);
    DECLARE @TotalNiveles INT = (SELECT COUNT(*) FROM [app].[tbNivelesEducativos]
                                 WHERE Niv_EsEliminado = 0 AND Niv_EsActivo = 1);
    DECLARE @TotalJornadas INT = (SELECT COUNT(*) FROM [app].[tbModalidades]
                                  WHERE Mda_EsEliminado = 0);
    DECLARE @MontoTotal DECIMAL(18,2) = ISNULL((SELECT SUM(Cco_MontoTotal) FROM [finanza].[tbCuentasCobrar]
                                                WHERE Cco_Anio = @Anio AND Cco_EsEliminado = 0), 0);
    DECLARE @MontoPendiente DECIMAL(18,2) = ISNULL((SELECT SUM(Cco_MontoPendiente) FROM [finanza].[tbCuentasCobrar]
                                                    WHERE Cco_Anio = @Anio AND Cco_EsEliminado = 0), 0);
    DECLARE @PorcentajeCobrado DECIMAL(9,2) =
        CASE WHEN @MontoTotal > 0
             THEN CAST(((@MontoTotal - @MontoPendiente) / @MontoTotal) * 100 AS DECIMAL(9,2))
             ELSE 0 END;
    DECLARE @AlumnosPorEmpleado DECIMAL(9,2) =
        CASE WHEN @TotalEmpleados > 0
             THEN CAST(@TotalAlumnos * 1.0 / @TotalEmpleados AS DECIMAL(9,2))
             ELSE 0 END;

    SELECT
        @TotalAlumnos        AS TotalAlumnos,
        @TotalAlumnosActivos AS TotalAlumnosActivos,
        @TotalEmpleados      AS TotalEmpleados,
        @TotalDocentes       AS TotalDocentes,
        @TotalCursos         AS TotalCursos,
        @TotalClasesHorario  AS TotalClasesHorario,
        @TotalNiveles        AS TotalNiveles,
        @TotalJornadas       AS TotalJornadas,
        @PorcentajeCobrado   AS PorcentajeCobrado,
        @AlumnosPorEmpleado  AS AlumnosPorEmpleado;

    -- ── RS2: Evolución Matrícula (últimos 5 años) ───────────────────────
    ;WITH Anios AS (
        SELECT TOP 5
            @Anio - (ROW_NUMBER() OVER (ORDER BY (SELECT 1)) - 1) AS Anio
        FROM sys.columns
    )
    SELECT
        a.Anio,
        ISNULL((SELECT COUNT(*) FROM [app].[tbAlumnos]
                WHERE AnioCursado = a.Anio), 0) AS TotalAlumnos
    FROM Anios a
    ORDER BY a.Anio;

    -- ── RS3: Matrícula por Nivel (doughnut) ─────────────────────────────
    SELECT
        n.Niv_Id,
        n.Niv_Descripcion AS NivelNombre,
        COUNT(a.Alu_Id)   AS TotalAlumnos
    FROM [app].[tbNivelesEducativos] n
    LEFT JOIN [app].[tbAlumnos] a ON a.Niv_Id = n.Niv_Id AND a.AnioCursado = @Anio
    WHERE n.Niv_EsEliminado = 0
    GROUP BY n.Niv_Id, n.Niv_Descripcion
    HAVING COUNT(a.Alu_Id) > 0
    ORDER BY TotalAlumnos DESC;

    -- ── RS4: Matrícula por Jornada / Modalidad (pie) ────────────────────
    SELECT
        m.Mda_Id          AS Jor_Id,
        m.Mda_Descripcion AS JornadaNombre,
        COUNT(a.Alu_Id)   AS TotalAlumnos
    FROM [app].[tbModalidades] m
    LEFT JOIN [app].[tbAlumnos] a ON a.Mda_Id = m.Mda_Id AND a.AnioCursado = @Anio
    WHERE m.Mda_EsEliminado = 0
    GROUP BY m.Mda_Id, m.Mda_Descripcion
    HAVING COUNT(a.Alu_Id) > 0
    ORDER BY TotalAlumnos DESC;

    -- ── RS5: Matrícula por Curso (top 10, horizontal bar) ───────────────
    SELECT TOP 10
        c.Cur_Id,
        c.Cur_Nombre      AS CursoNombre,
        n.Niv_Descripcion AS NivelNombre,
        COUNT(a.Alu_Id)   AS TotalAlumnos
    FROM [app].[tbCursos] c
    LEFT JOIN [app].[tbNivelesEducativos] n ON c.Niv_Id = n.Niv_Id
    LEFT JOIN [app].[tbAlumnos] a ON a.Cur_Id = c.Cur_Id AND a.AnioCursado = @Anio
    WHERE c.Cur_EsEliminado = 0
    GROUP BY c.Cur_Id, c.Cur_Nombre, n.Niv_Descripcion
    HAVING COUNT(a.Alu_Id) > 0
    ORDER BY TotalAlumnos DESC;

    -- ── RS6: Alumnos por Género (pie) ───────────────────────────────────
    SELECT
        CASE p.Per_Sexo
             WHEN 'M' THEN N'Masculino'
             WHEN 'F' THEN N'Femenino'
             ELSE N'No especificado'
        END AS Genero,
        COUNT(*) AS Total
    FROM [app].[tbAlumnos] a
    INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
    WHERE a.AnioCursado = @Anio AND p.Per_EsEliminado = 0
    GROUP BY p.Per_Sexo
    ORDER BY Total DESC;

    -- ── RS7: Alumnos por Rango de Edad (bar chart) ──────────────────────
    ;WITH Edades AS (
        SELECT
            CASE
                WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 5  AND 7  THEN N'5-7'
                WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 8  AND 10 THEN N'8-10'
                WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 11 AND 13 THEN N'11-13'
                WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 14 AND 16 THEN N'14-16'
                WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) >= 17           THEN N'17+'
                ELSE N'< 5'
            END AS RangoEdad,
            CASE
                WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 5  AND 7  THEN 1
                WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 8  AND 10 THEN 2
                WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 11 AND 13 THEN 3
                WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) BETWEEN 14 AND 16 THEN 4
                WHEN DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) >= 17           THEN 5
                ELSE 0
            END AS Orden
        FROM [app].[tbAlumnos] a
        INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
        WHERE a.AnioCursado = @Anio
          AND p.Per_FechaNacimiento IS NOT NULL
          AND p.Per_EsEliminado = 0
    )
    SELECT RangoEdad, COUNT(*) AS Total, Orden
    FROM Edades
    GROUP BY RangoEdad, Orden
    ORDER BY Orden;

    -- ── RS8: Empleados por Departamento (horizontal bar) ────────────────
    SELECT
        d.Dep_Id,
        d.Nombre         AS DepartamentoNombre,
        COUNT(e.Emp_Id)  AS TotalEmpleados
    FROM [app].[tbDepartamentoEmpleados] d
    LEFT JOIN [app].[tbEmpleados] e ON e.Dep_Id = d.Dep_Id
    LEFT JOIN [app].[tbPersonas]  p ON e.Per_Id = p.Per_Id
                                    AND p.Per_EsActivo = 1
                                    AND p.Per_EsEliminado = 0
    GROUP BY d.Dep_Id, d.Nombre
    ORDER BY TotalEmpleados DESC;

    -- ── RS9: Empleados por Cargo (top 8) ────────────────────────────────
    SELECT TOP 8
        c.Car_Id,
        c.Car_Descripcion AS CargoNombre,
        COUNT(e.Emp_Id)   AS TotalEmpleados
    FROM [app].[tbCargos] c
    LEFT JOIN [app].[tbEmpleados] e ON e.Car_Id = c.Car_Id
    LEFT JOIN [app].[tbPersonas]  p ON e.Per_Id = p.Per_Id
                                    AND p.Per_EsActivo = 1
                                    AND p.Per_EsEliminado = 0
    WHERE c.Car_EsEliminado = 0
    GROUP BY c.Car_Id, c.Car_Descripcion
    HAVING COUNT(e.Emp_Id) > 0
    ORDER BY TotalEmpleados DESC;

    -- ── RS10: Indicadores Institucionales (lista de tarjetas) ───────────
    DECLARE @AlumnosAnioAnt INT = (SELECT COUNT(*) FROM [app].[tbAlumnos] WHERE AnioCursado = @Anio - 1);
    DECLARE @Crecimiento DECIMAL(9,2) =
        CASE WHEN @AlumnosAnioAnt > 0
             THEN CAST(((@TotalAlumnos - @AlumnosAnioAnt) * 100.0) / @AlumnosAnioAnt AS DECIMAL(9,2))
             ELSE 0 END;
    DECLARE @Retencion DECIMAL(9,2) =
        CASE WHEN @TotalAlumnos > 0
             THEN CAST((@TotalAlumnosActivos * 100.0) / @TotalAlumnos AS DECIMAL(9,2))
             ELSE 0 END;
    DECLARE @PromAlumnosCurso DECIMAL(9,2) =
        CASE WHEN @TotalCursos > 0
             THEN CAST(@TotalAlumnos * 1.0 / @TotalCursos AS DECIMAL(9,2))
             ELSE 0 END;
    DECLARE @CuentasAlDia INT = (SELECT COUNT(*) FROM [finanza].[tbCuentasCobrar]
                                 WHERE Cco_Anio = @Anio AND Cco_EsEliminado = 0
                                   AND Cco_MontoPendiente <= 0);
    DECLARE @TotalCuentas INT = (SELECT COUNT(*) FROM [finanza].[tbCuentasCobrar]
                                 WHERE Cco_Anio = @Anio AND Cco_EsEliminado = 0);
    DECLARE @PctAlDia DECIMAL(9,2) =
        CASE WHEN @TotalCuentas > 0
             THEN CAST((@CuentasAlDia * 100.0) / @TotalCuentas AS DECIMAL(9,2))
             ELSE 0 END;
    DECLARE @DocentesActivos INT = @TotalDocentes;
    DECLARE @PctDocentes DECIMAL(9,2) =
        CASE WHEN @TotalEmpleados > 0
             THEN CAST((@DocentesActivos * 100.0) / @TotalEmpleados AS DECIMAL(9,2))
             ELSE 0 END;
    DECLARE @PromClasesDocente DECIMAL(9,2) =
        CASE WHEN @TotalDocentes > 0
             THEN CAST(@TotalClasesHorario * 1.0 / @TotalDocentes AS DECIMAL(9,2))
             ELSE 0 END;

    SELECT Indicador, Valor, Tipo, Icono, Orden FROM (
        SELECT N'Crecimiento vs Año Anterior'  AS Indicador,
               CASE WHEN @Crecimiento >= 0 THEN N'+' + CAST(@Crecimiento AS NVARCHAR(20)) + N'%'
                    ELSE CAST(@Crecimiento AS NVARCHAR(20)) + N'%' END AS Valor,
               CASE WHEN @Crecimiento > 0 THEN N'positive'
                    WHEN @Crecimiento < 0 THEN N'negative'
                    ELSE N'neutral' END AS Tipo,
               N'fa-arrow-trend-up' AS Icono, 1 AS Orden
        UNION ALL
        SELECT N'Retención Estudiantil',
               CAST(@Retencion AS NVARCHAR(20)) + N'%',
               CASE WHEN @Retencion >= 90 THEN N'positive'
                    WHEN @Retencion >= 75 THEN N'neutral'
                    ELSE N'negative' END,
               N'fa-user-graduate', 2
        UNION ALL
        SELECT N'Cuentas al Día',
               CAST(@PctAlDia AS NVARCHAR(20)) + N'%',
               CASE WHEN @PctAlDia >= 80 THEN N'positive'
                    WHEN @PctAlDia >= 60 THEN N'neutral'
                    ELSE N'negative' END,
               N'fa-circle-check', 3
        UNION ALL
        SELECT N'Promedio Alumnos por Curso',
               CAST(@PromAlumnosCurso AS NVARCHAR(20)),
               N'neutral', N'fa-chalkboard-user', 4
        UNION ALL
        SELECT N'% Personal Docente',
               CAST(@PctDocentes AS NVARCHAR(20)) + N'%',
               N'neutral', N'fa-person-chalkboard', 5
        UNION ALL
        SELECT N'Promedio Clases por Docente',
               CAST(@PromClasesDocente AS NVARCHAR(20)),
               N'neutral', N'fa-calendar-week', 6
        UNION ALL
        SELECT N'Alumnos por Empleado',
               CAST(@AlumnosPorEmpleado AS NVARCHAR(20)),
               N'neutral', N'fa-users-rays', 7
        UNION ALL
        SELECT N'Eficiencia de Cobro',
               CAST(@PorcentajeCobrado AS NVARCHAR(20)) + N'%',
               CASE WHEN @PorcentajeCobrado >= 80 THEN N'positive'
                    WHEN @PorcentajeCobrado >= 60 THEN N'neutral'
                    ELSE N'negative' END,
               N'fa-hand-holding-dollar', 8
    ) ind
    ORDER BY Orden;

END
GO

PRINT N'PR_DashboardConsulta_KPIs actualizado a 10 result sets.';
