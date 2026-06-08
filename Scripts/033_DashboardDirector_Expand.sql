-- 033_DashboardDirector_Expand.sql
-- Expande PR_DashboardDirector_KPIs a 7 result sets

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_DashboardDirector_KPIs]') AND type = 'P')
    DROP PROCEDURE [app].[PR_DashboardDirector_KPIs];
GO
CREATE PROCEDURE [app].[PR_DashboardDirector_KPIs]
    @Anio INT = NULL,
    @Mes  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());
    IF @Mes  IS NULL SET @Mes  = MONTH(GETDATE());
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

    -- RS1: KPIs globales (incluye nuevos campos: PromedioGeneral, AlumnosEnRiesgo, AlumnosPresentesHoy, AlumnosAusentesHoy)
    SELECT
        (SELECT COUNT(*) FROM [app].[tbAlumnos] WHERE AnioCursado = @Anio) AS TotalAlumnos,
        (SELECT COUNT(*) FROM [app].[tbEmpleados] e INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0) AS TotalEmpleados,
        (SELECT ISNULL(SUM(Pag_MontoTotal),0) FROM [finanza].[tbPagos] WHERE YEAR(Pag_FechaPago)=@Anio AND MONTH(Pag_FechaPago)=@Mes AND Pag_EsEliminado=0) AS TotalCobradoMes,
        (SELECT ISNULL(SUM(Cco_MontoPendiente),0) FROM [finanza].[tbCuentasCobrar] WHERE Cco_Anio=@Anio AND Cco_EsEliminado=0 AND Cco_MontoPendiente>0) AS TotalDeudaPendiente,
        (SELECT COUNT(*) FROM [finanza].[tbCuentasCobrar] WHERE Cco_FechaVencimiento < GETDATE() AND Cco_MontoPendiente>0 AND Cco_Anio=@Anio AND Cco_EsEliminado=0) AS CuentasVencidas,
        ISNULL((SELECT CAST(AVG(Not_Nota) AS DECIMAL(5,2)) FROM [app].[tbNotas] WHERE YEAR(Not_Año)=@Anio AND Not_EsEliminado=0), 0) AS PromedioGeneral,
        (SELECT COUNT(DISTINCT Alu_Id) FROM [app].[tbNotas] WHERE YEAR(Not_Año)=@Anio AND Not_EsEliminado=0 AND Not_Nota < 60) AS AlumnosEnRiesgo,
        (SELECT COUNT(DISTINCT Alu_Id) FROM [app].[tbAsistencia] WHERE Asi_Fecha=@Hoy AND Asi_Estado='P' AND Asi_EsEliminado=0) AS AlumnosPresentesHoy,
        (SELECT COUNT(DISTINCT Alu_Id) FROM [app].[tbAsistencia] WHERE Asi_Fecha=@Hoy AND Asi_Estado='A' AND Asi_EsEliminado=0) AS AlumnosAusentesHoy;

    -- RS2: Matrícula por curso
    SELECT c.Cur_Nombre, COUNT(a.Alu_Id) AS TotalAlumnos
    FROM [app].[tbCursos] c
    LEFT JOIN [app].[tbAlumnos] a ON c.Cur_Id = a.Cur_Id AND a.AnioCursado = @Anio
    WHERE c.Cur_EsEliminado = 0
    GROUP BY c.Cur_Id, c.Cur_Nombre
    ORDER BY TotalAlumnos DESC;

    -- RS3: Cobrado vs Pendiente por mes (últimos 6 meses, incluye meses sin data)
    ;WITH Meses AS (
        SELECT TOP 6
            DATEADD(MONTH, -1 * (ROW_NUMBER() OVER (ORDER BY (SELECT 1)) - 1),
                    DATEFROMPARTS(@Anio, @Mes, 1)) AS Fecha
        FROM sys.columns
    )
    SELECT
        MONTH(m.Fecha) AS Mes,
        YEAR(m.Fecha)  AS Anio,
        ISNULL((
            SELECT SUM(Pag_MontoTotal)
            FROM [finanza].[tbPagos]
            WHERE YEAR(Pag_FechaPago) = YEAR(m.Fecha)
              AND MONTH(Pag_FechaPago) = MONTH(m.Fecha)
              AND Pag_EsEliminado = 0
        ), 0) AS TotalCobrado,
        ISNULL((
            SELECT SUM(Cco_MontoPendiente)
            FROM [finanza].[tbCuentasCobrar]
            WHERE YEAR(Cco_FechaVencimiento) = YEAR(m.Fecha)
              AND MONTH(Cco_FechaVencimiento) = MONTH(m.Fecha)
              AND Cco_EsEliminado = 0
              AND Cco_MontoPendiente > 0
        ), 0) AS TotalPendiente
    FROM Meses m
    ORDER BY YEAR(m.Fecha), MONTH(m.Fecha);

    -- RS4: Asistencia hoy por curso (desglose)
    SELECT
        c.Cur_Nombre,
        COUNT(DISTINCT CASE WHEN ast.Asi_Estado = 'P' THEN ast.Alu_Id END) AS Presentes,
        COUNT(DISTINCT CASE WHEN ast.Asi_Estado = 'A' THEN ast.Alu_Id END) AS Ausentes,
        COUNT(DISTINCT CASE WHEN ast.Asi_Estado = 'T' THEN ast.Alu_Id END) AS Tardanzas,
        COUNT(DISTINCT a.Alu_Id) AS TotalEsperados
    FROM [app].[tbCursos] c
    INNER JOIN [app].[tbAlumnos] a ON c.Cur_Id = a.Cur_Id AND a.AnioCursado = @Anio
    LEFT JOIN [app].[tbAsistencia] ast ON ast.Alu_Id = a.Alu_Id AND ast.Asi_Fecha = @Hoy AND ast.Asi_EsEliminado = 0
    WHERE c.Cur_EsEliminado = 0
    GROUP BY c.Cur_Id, c.Cur_Nombre
    ORDER BY c.Cur_Nombre;

    -- RS5: Rendimiento académico por curso
    SELECT
        c.Cur_Nombre,
        ISNULL(CAST(AVG(n.Not_Nota) AS DECIMAL(5,2)), 0) AS Promedio,
        COUNT(DISTINCT CASE WHEN n.Not_Nota < 60 THEN n.Alu_Id END) AS EnRiesgo,
        COUNT(DISTINCT n.Alu_Id) AS TotalConNotas
    FROM [app].[tbCursos] c
    INNER JOIN [app].[tbAlumnos] a ON c.Cur_Id = a.Cur_Id AND a.AnioCursado = @Anio
    LEFT JOIN [app].[tbNotas] n ON n.Alu_Id = a.Alu_Id AND YEAR(n.Not_Año) = @Anio AND n.Not_EsEliminado = 0
    WHERE c.Cur_EsEliminado = 0
    GROUP BY c.Cur_Id, c.Cur_Nombre
    ORDER BY Promedio DESC;

    -- RS6: Top 5 cursos con mayor deuda
    SELECT TOP 5
        c.Cur_Nombre,
        COUNT(DISTINCT cc.Alu_Id) AS AlumnosConDeuda,
        ISNULL(SUM(cc.Cco_MontoPendiente), 0) AS MontoTotal
    FROM [app].[tbCursos] c
    INNER JOIN [app].[tbAlumnos] a ON c.Cur_Id = a.Cur_Id AND a.AnioCursado = @Anio
    INNER JOIN [finanza].[tbCuentasCobrar] cc ON cc.Alu_Id = a.Alu_Id AND cc.Cco_Anio = @Anio AND cc.Cco_EsEliminado = 0 AND cc.Cco_MontoPendiente > 0
    WHERE c.Cur_EsEliminado = 0
    GROUP BY c.Cur_Id, c.Cur_Nombre
    ORDER BY MontoTotal DESC;

    -- RS7: Alertas generadas dinámicamente
    SELECT Tipo, Mensaje, Urgencia FROM (
        SELECT 'financiero' AS Tipo,
               CAST((SELECT COUNT(*) FROM [finanza].[tbCuentasCobrar] WHERE Cco_FechaVencimiento < GETDATE() AND Cco_MontoPendiente > 0 AND Cco_Anio = @Anio AND Cco_EsEliminado = 0) AS VARCHAR) + ' cuentas vencidas sin gestionar' AS Mensaje,
               'alta' AS Urgencia, 1 AS Ord
        WHERE (SELECT COUNT(*) FROM [finanza].[tbCuentasCobrar] WHERE Cco_FechaVencimiento < GETDATE() AND Cco_MontoPendiente > 0 AND Cco_Anio = @Anio AND Cco_EsEliminado = 0) > 0
        UNION ALL
        SELECT 'academico',
               CAST((SELECT COUNT(DISTINCT Alu_Id) FROM [app].[tbNotas] WHERE YEAR(Not_Año) = @Anio AND Not_EsEliminado = 0 AND Not_Nota < 60) AS VARCHAR) + ' alumnos en riesgo académico',
               'media', 2
        WHERE (SELECT COUNT(DISTINCT Alu_Id) FROM [app].[tbNotas] WHERE YEAR(Not_Año) = @Anio AND Not_EsEliminado = 0 AND Not_Nota < 60) > 0
        UNION ALL
        SELECT 'asistencia',
               CAST((SELECT COUNT(DISTINCT Alu_Id) FROM [app].[tbAsistencia] WHERE Asi_Fecha = @Hoy AND Asi_Estado = 'A' AND Asi_EsEliminado = 0) AS VARCHAR) + ' alumnos ausentes hoy',
               'baja', 3
        WHERE (SELECT COUNT(DISTINCT Alu_Id) FROM [app].[tbAsistencia] WHERE Asi_Fecha = @Hoy AND Asi_Estado = 'A' AND Asi_EsEliminado = 0) > 0
    ) alertas
    ORDER BY Ord;
END
GO
