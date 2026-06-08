-- =====================================================================
-- Script 017: SPs Fase 4 — Alumnos (directorio y pirámide matrícula)
-- Crea/reemplaza:
--   app.PR_Alumnos_Directorio          — lista alumnos con encargado
--   app.PR_Alumnos_PiramideMatricula   — conteo por nivel y género
-- Convención: idempotente (DROP IF EXISTS + CREATE)
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_Alumnos_Directorio
-- Lista de alumnos con datos del encargado principal.
-- Filtros opcionales: por curso (@Cur_Id) y/o sección (@Sec_Id).
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_Alumnos_Directorio]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Alumnos_Directorio];
GO
CREATE PROCEDURE [app].[PR_Alumnos_Directorio]
    @Cur_Id INT = NULL,
    @Sec_Id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.Alu_Id,
        a.AnioCursado,
        -- Datos del alumno
        LTRIM(RTRIM(CONCAT(
            pa.Per_PrimerNombre, ' ',
            ISNULL(pa.Per_SegundoNombre + ' ', ''),
            pa.Per_ApellidoPaterno, ' ',
            ISNULL(pa.Per_ApellidoMaterno, '')
        )))                         AS Alu_NombreCompleto,
        pa.Per_Identidad            AS Alu_Identidad,
        pa.Per_FechaNacimiento      AS Alu_FechaNacimiento,
        pa.Per_Sexo                 AS Alu_Sexo,
        pa.Per_Imagen               AS Alu_Imagen,
        pa.Per_Telefono             AS Alu_Telefono,
        pa.Per_CorreoElectronico    AS Alu_Correo,
        pa.Per_Direccion            AS Alu_Direccion,
        -- Curso y sección
        c.Cur_Id,
        c.Cur_Nombre,
        s.Sec_Id,
        s.Sec_Descripcion,
        cn.Cun_Descripcion,
        niv.Niv_Descripcion,
        -- Encargado principal (primer registro vinculado)
        enc.Enc_Id,
        enc.Enc_Ocupacion,
        LTRIM(RTRIM(CONCAT(
            pe.Per_PrimerNombre, ' ',
            ISNULL(pe.Per_SegundoNombre + ' ', ''),
            pe.Per_ApellidoPaterno, ' ',
            ISNULL(pe.Per_ApellidoMaterno, '')
        )))                         AS Enc_NombreCompleto,
        pe.Per_Telefono             AS Enc_Telefono,
        pe.Per_CorreoElectronico    AS Enc_Correo,
        par.Par_Id,
        par.Par_Descripcion         AS Parentesco
    FROM [app].[tbAlumnos] a
    INNER JOIN [app].[tbPersonas]          pa  ON a.Per_Id  = pa.Per_Id
    INNER JOIN [app].[tbCursos]            c   ON a.Cur_Id  = c.Cur_Id
    LEFT  JOIN [app].[tbSecciones]         s   ON a.Sec_Id  = s.Sec_Id
    LEFT  JOIN [app].[tbCursosNiveles]     cn  ON a.Cun_Id  = cn.Cun_Id
    LEFT  JOIN [app].[tbNivelesEducativos] niv ON a.Niv_Id  = niv.Niv_Id
    -- Encargado: tomamos el primero (menor Enc_Id) vinculado al alumno
    OUTER APPLY (
        SELECT TOP 1
            ea.Enc_Id,
            ea.Par_Id
        FROM [app].[tbEncargados_tbAlumnos] ea
        WHERE ea.Alu_Id = a.Alu_Id
        ORDER BY ea.Enc_Id
    ) rel
    LEFT  JOIN [app].[tbEncargados]  enc ON rel.Enc_Id = enc.Enc_Id
    LEFT  JOIN [app].[tbPersonas]    pe  ON enc.Per_Id = pe.Per_Id
    LEFT  JOIN [app].[tbParentescos] par ON rel.Par_Id = par.Par_Id
    WHERE pa.Per_EsEliminado = 0
      AND (@Cur_Id IS NULL OR a.Cur_Id = @Cur_Id)
      AND (@Sec_Id IS NULL OR a.Sec_Id = @Sec_Id)
    ORDER BY pa.Per_ApellidoPaterno, pa.Per_PrimerNombre;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_Alumnos_PiramideMatricula
-- Conteo de alumnos agrupado por nivel educativo y género para un año.
-- Útil para gráficas de pirámide poblacional escolar.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_Alumnos_PiramideMatricula]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Alumnos_PiramideMatricula];
GO
CREATE PROCEDURE [app].[PR_Alumnos_PiramideMatricula]
    @Anio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());

    -- RS1: Desglose por nivel y género
    SELECT
        niv.Niv_Id,
        niv.Niv_Descripcion,
        c.Cur_Id,
        c.Cur_Nombre,
        SUM(CASE WHEN p.Per_Sexo = 'M' THEN 1 ELSE 0 END) AS TotalMasculino,
        SUM(CASE WHEN p.Per_Sexo = 'F' THEN 1 ELSE 0 END) AS TotalFemenino,
        SUM(CASE WHEN p.Per_Sexo NOT IN ('M','F') OR p.Per_Sexo IS NULL THEN 1 ELSE 0 END) AS TotalOtro,
        COUNT(a.Alu_Id)                                    AS TotalGeneral
    FROM [app].[tbAlumnos] a
    INNER JOIN [app].[tbPersonas]          p   ON a.Per_Id  = p.Per_Id
    INNER JOIN [app].[tbCursos]            c   ON a.Cur_Id  = c.Cur_Id
    LEFT  JOIN [app].[tbNivelesEducativos] niv ON a.Niv_Id  = niv.Niv_Id
    WHERE a.AnioCursado    = @Anio
      AND p.Per_EsEliminado = 0
    GROUP BY niv.Niv_Id, niv.Niv_Descripcion, c.Cur_Id, c.Cur_Nombre
    ORDER BY niv.Niv_Id, c.Cur_Id;

    -- RS2: Totales generales del año
    SELECT
        @Anio                                              AS Anio,
        COUNT(a.Alu_Id)                                    AS TotalAlumnos,
        SUM(CASE WHEN p.Per_Sexo = 'M' THEN 1 ELSE 0 END) AS TotalMasculino,
        SUM(CASE WHEN p.Per_Sexo = 'F' THEN 1 ELSE 0 END) AS TotalFemenino,
        COUNT(DISTINCT a.Cur_Id)                           AS TotalCursos,
        COUNT(DISTINCT a.Niv_Id)                           AS TotalNiveles
    FROM [app].[tbAlumnos] a
    INNER JOIN [app].[tbPersonas] p ON a.Per_Id = p.Per_Id
    WHERE a.AnioCursado    = @Anio
      AND p.Per_EsEliminado = 0;
END
GO

PRINT 'Script 017 completado: SPs Fase 4 (Alumnos directorio + piramide) creados exitosamente.';
GO
