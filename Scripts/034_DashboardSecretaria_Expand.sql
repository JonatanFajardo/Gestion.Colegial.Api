-- 034_DashboardSecretaria_Expand.sql
-- Expande PR_DashboardSecretaria_Resumen a 8 result sets

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[PR_DashboardSecretaria_Resumen]') AND type = 'P')
    DROP PROCEDURE [app].[PR_DashboardSecretaria_Resumen];
GO
CREATE PROCEDURE [app].[PR_DashboardSecretaria_Resumen]
    @Anio INT = NULL,
    @Mes  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());
    IF @Mes  IS NULL SET @Mes  = MONTH(GETDATE());
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    DECLARE @InicioSemana DATE = DATEADD(DAY, 1 - DATEPART(WEEKDAY, @Hoy), @Hoy);
    DECLARE @FinSemana    DATE = DATEADD(DAY, 6, @InicioSemana);

    -- RS1: KPIs
    SELECT
        (SELECT COUNT(*) FROM [app].[tbAlumnos] WHERE AnioCursado = @Anio) AS TotalMatriculados,

        (SELECT COUNT(*) FROM [app].[tbAlumnos] a
         INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
         WHERE a.AnioCursado = @Anio
           AND YEAR(p.Per_FechaRegistra) = @Anio
           AND MONTH(p.Per_FechaRegistra) = @Mes) AS NuevasMatriculasMes,

        (SELECT COUNT(DISTINCT da.Alu_Id)
         FROM [app].[tbDocumentosAlumno] da
         INNER JOIN [app].[tbTiposDocumento] td ON da.TDoc_Id = td.TDoc_Id
         INNER JOIN [app].[tbAlumnos] a ON da.Alu_Id = a.Alu_Id
         WHERE da.Doa_EsEntregado = 0 AND da.Doa_EsEliminado = 0
           AND td.TDoc_EsObligatorio = 1
           AND a.AnioCursado = @Anio) AS DocumentosPendientes,

        (SELECT COUNT(*) FROM [app].[tbAlumnos] a
         INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
         WHERE a.AnioCursado = @Anio
           AND (p.Per_Imagen IS NULL OR LTRIM(RTRIM(p.Per_Imagen)) = '')) AS AlumnosSinFoto,

        (SELECT COUNT(*) FROM [app].[tbEncargados] e
         INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
         WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0
           AND (p.Per_Telefono IS NULL OR LTRIM(RTRIM(p.Per_Telefono)) = ''
             OR p.Per_CorreoElectronico IS NULL OR LTRIM(RTRIM(p.Per_CorreoElectronico)) = '')) AS EncargadosIncompletos,

        (SELECT COUNT(*) FROM [app].[tbAlumnos] a
         INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
         WHERE a.AnioCursado = @Anio
           AND MONTH(p.Per_FechaNacimiento) = MONTH(@Hoy)
           AND DAY(p.Per_FechaNacimiento) BETWEEN DAY(@InicioSemana) AND DAY(@FinSemana)) AS CumpleanosSemana;

    -- RS2: Matrícula por sección (ya existía — mantengo formato)
    SELECT
        LTRIM(RTRIM(REPLACE(REPLACE(c.Cur_Nombre, CHAR(13), ''), CHAR(10), ''))) AS Cur_Nombre,
        s.Sec_Descripcion,
        COUNT(a.Alu_Id) AS TotalAlumnos
    FROM [app].[tbCursos] c
    INNER JOIN [app].[tbSecciones] s ON 1 = 1
    LEFT JOIN [app].[tbAlumnos] a ON a.Cur_Id = c.Cur_Id AND a.Sec_Id = s.Sec_Id AND a.AnioCursado = @Anio
    WHERE c.Cur_EsEliminado = 0 AND s.Sec_EsEliminado = 0
    GROUP BY c.Cur_Id, c.Cur_Nombre, s.Sec_Id, s.Sec_Descripcion
    HAVING COUNT(a.Alu_Id) > 0
    ORDER BY c.Cur_Nombre, s.Sec_Descripcion;

    -- RS3: Trámites de hoy (derivado de múltiples fuentes)
    SELECT TOP 15 Tipo, Alumno, Detalle, Urgencia, Orden FROM (
        -- Cumpleaños hoy
        SELECT
            'cumple' AS Tipo,
            LTRIM(RTRIM(p.Per_PrimerNombre + ' ' + ISNULL(p.Per_ApellidoPaterno,''))) AS Alumno,
            ('Cumpleaños hoy · ' + CAST(DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) AS VARCHAR) + ' años') AS Detalle,
            'baja' AS Urgencia,
            3 AS Orden
        FROM [app].[tbAlumnos] a
        INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
        WHERE a.AnioCursado = @Anio
          AND MONTH(p.Per_FechaNacimiento) = MONTH(@Hoy)
          AND DAY(p.Per_FechaNacimiento) = DAY(@Hoy)

        UNION ALL

        -- Alumnos con 3+ documentos pendientes (urgente)
        SELECT TOP 5
            'documento',
            LTRIM(RTRIM(p.Per_PrimerNombre + ' ' + ISNULL(p.Per_ApellidoPaterno,''))),
            (CAST(COUNT(*) AS VARCHAR) + ' documentos obligatorios pendientes'),
            'alta',
            1
        FROM [app].[tbDocumentosAlumno] da
        INNER JOIN [app].[tbTiposDocumento] td ON da.TDoc_Id = td.TDoc_Id
        INNER JOIN [app].[tbAlumnos] a ON da.Alu_Id = a.Alu_Id
        INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
        WHERE da.Doa_EsEntregado = 0 AND da.Doa_EsEliminado = 0
          AND td.TDoc_EsObligatorio = 1 AND a.AnioCursado = @Anio
        GROUP BY a.Alu_Id, p.Per_PrimerNombre, p.Per_ApellidoPaterno
        HAVING COUNT(*) >= 3
        ORDER BY COUNT(*) DESC

        UNION ALL

        -- Alumnos sin foto (para carnet)
        SELECT TOP 5
            'foto',
            LTRIM(RTRIM(p.Per_PrimerNombre + ' ' + ISNULL(p.Per_ApellidoPaterno,''))),
            'Sin foto · pendiente para carnet',
            'media',
            2
        FROM [app].[tbAlumnos] a
        INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
        WHERE a.AnioCursado = @Anio
          AND (p.Per_Imagen IS NULL OR LTRIM(RTRIM(p.Per_Imagen)) = '')
        ORDER BY p.Per_ApellidoPaterno
    ) tramites
    ORDER BY Orden, Alumno;

    -- RS4: Matrícula por mes (año actual vs anterior, últimos 6 meses)
    ;WITH Meses AS (
        SELECT TOP 6
            DATEADD(MONTH, -1 * (ROW_NUMBER() OVER (ORDER BY (SELECT 1)) - 1),
                    DATEFROMPARTS(@Anio, @Mes, 1)) AS Fecha
        FROM sys.columns
    )
    SELECT
        MONTH(m.Fecha) AS Mes,
        YEAR(m.Fecha)  AS Anio,
        (SELECT COUNT(*) FROM [app].[tbAlumnos] a
         INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
         WHERE YEAR(p.Per_FechaRegistra) = YEAR(m.Fecha)
           AND MONTH(p.Per_FechaRegistra) = MONTH(m.Fecha)) AS NuevasActual,
        (SELECT COUNT(*) FROM [app].[tbAlumnos] a
         INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
         WHERE YEAR(p.Per_FechaRegistra) = YEAR(m.Fecha) - 1
           AND MONTH(p.Per_FechaRegistra) = MONTH(m.Fecha)) AS NuevasAnterior
    FROM Meses m
    ORDER BY YEAR(m.Fecha), MONTH(m.Fecha);

    -- RS5: Documentos pendientes por tipo
    SELECT
        td.TDoc_Descripcion AS TipoDocumento,
        COUNT(*) AS Pendientes
    FROM [app].[tbDocumentosAlumno] da
    INNER JOIN [app].[tbTiposDocumento] td ON da.TDoc_Id = td.TDoc_Id
    INNER JOIN [app].[tbAlumnos] a ON da.Alu_Id = a.Alu_Id
    WHERE da.Doa_EsEntregado = 0 AND da.Doa_EsEliminado = 0
      AND td.TDoc_EsObligatorio = 1
      AND a.AnioCursado = @Anio
    GROUP BY td.TDoc_Id, td.TDoc_Descripcion
    ORDER BY Pendientes DESC;

    -- RS6: Top 10 alumnos con más documentos pendientes
    SELECT TOP 10
        a.Alu_Id,
        LTRIM(RTRIM(p.Per_PrimerNombre + ' ' + ISNULL(p.Per_ApellidoPaterno,''))) AS Alumno,
        LTRIM(RTRIM(REPLACE(REPLACE(c.Cur_Nombre, CHAR(13), ''), CHAR(10), '')))
            + ' ' + s.Sec_Descripcion AS Curso,
        COUNT(*) AS DocsPendientes
    FROM [app].[tbDocumentosAlumno] da
    INNER JOIN [app].[tbTiposDocumento] td ON da.TDoc_Id = td.TDoc_Id
    INNER JOIN [app].[tbAlumnos] a ON da.Alu_Id = a.Alu_Id
    INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
    INNER JOIN [app].[tbCursos]   c ON a.Cur_Id = c.Cur_Id
    INNER JOIN [app].[tbSecciones] s ON a.Sec_Id = s.Sec_Id
    WHERE da.Doa_EsEntregado = 0 AND da.Doa_EsEliminado = 0
      AND td.TDoc_EsObligatorio = 1
      AND a.AnioCursado = @Anio
    GROUP BY a.Alu_Id, p.Per_PrimerNombre, p.Per_ApellidoPaterno, c.Cur_Nombre, s.Sec_Descripcion
    ORDER BY COUNT(*) DESC;

    -- RS7: Encargados con datos incompletos
    SELECT TOP 10
        e.Enc_Id,
        LTRIM(RTRIM(p.Per_PrimerNombre + ' ' + ISNULL(p.Per_ApellidoPaterno,''))) AS Nombre,
        CASE
            WHEN (p.Per_Telefono IS NULL OR LTRIM(RTRIM(p.Per_Telefono)) = '')
                AND (p.Per_CorreoElectronico IS NULL OR LTRIM(RTRIM(p.Per_CorreoElectronico)) = '')
                THEN 'Sin teléfono ni correo'
            WHEN (p.Per_Telefono IS NULL OR LTRIM(RTRIM(p.Per_Telefono)) = '')
                THEN 'Sin teléfono'
            ELSE 'Sin correo'
        END AS Faltante,
        (SELECT COUNT(*) FROM [app].[tbEncargados_tbAlumnos] ea
         INNER JOIN [app].[tbAlumnos] a ON ea.Alu_Id = a.Alu_Id
         WHERE ea.Enc_Id = e.Enc_Id AND a.AnioCursado = @Anio) AS AlumnosACargo
    FROM [app].[tbEncargados] e
    INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
    WHERE p.Per_EsActivo = 1 AND p.Per_EsEliminado = 0
      AND (p.Per_Telefono IS NULL OR LTRIM(RTRIM(p.Per_Telefono)) = ''
        OR p.Per_CorreoElectronico IS NULL OR LTRIM(RTRIM(p.Per_CorreoElectronico)) = '')
    ORDER BY AlumnosACargo DESC;

    -- RS8: Cumpleaños de la semana
    SELECT
        a.Alu_Id,
        LTRIM(RTRIM(p.Per_PrimerNombre + ' ' + ISNULL(p.Per_ApellidoPaterno,''))) AS Alumno,
        LTRIM(RTRIM(REPLACE(REPLACE(c.Cur_Nombre, CHAR(13), ''), CHAR(10), '')))
            + ' ' + s.Sec_Descripcion AS Curso,
        DATEFROMPARTS(YEAR(@Hoy), MONTH(p.Per_FechaNacimiento), DAY(p.Per_FechaNacimiento)) AS Fecha,
        DATEDIFF(YEAR, p.Per_FechaNacimiento, @Hoy) AS Edad
    FROM [app].[tbAlumnos] a
    INNER JOIN [app].[tbPersonas]  p ON a.Per_Id = p.Per_Id
    INNER JOIN [app].[tbCursos]    c ON a.Cur_Id = c.Cur_Id
    INNER JOIN [app].[tbSecciones] s ON a.Sec_Id = s.Sec_Id
    WHERE a.AnioCursado = @Anio
      AND MONTH(p.Per_FechaNacimiento) = MONTH(@Hoy)
      AND DAY(p.Per_FechaNacimiento) BETWEEN DAY(@InicioSemana) AND DAY(@FinSemana)
    ORDER BY DAY(p.Per_FechaNacimiento);
END
GO
