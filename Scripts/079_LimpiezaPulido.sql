/* =============================================================================
   079 · Limpieza y pulido general
   A. Texto con codificación rota (UTF-8 leído como Latin-1: "Ã©" por "é") en las columnas
      de texto de los schemas app y seguridad. Solo toca filas con 'Ã' o 'Â'. Idempotente.
   B. Materias faltantes: Ciencias Naturales y Estudios Sociales.
   C. Configuración de semestres: semestre_activo (0 = automático por fecha, 1 o 2 = fijo),
      fechas de inicio y fin de cada semestre, y app.fn_SemestreActivo().
   D. app.FN_Sustitucion_Ciclo solo toma 'semestre_activo' si vale 1 o 2 (misma firma).
   E. Fotos de perfil con nombre de archivo inexistente (profile-13.jpeg).
   Nota: app.tbMatriculas (vacía, sin pantalla) sigue en uso por spGraduarAlumno y
   seguridad.UDP_tbBitacora_ByAlumno; no se elimina aquí.
   ============================================================================= */
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

/* ---------- A. Codificación rota ---------- */
DECLARE @m TABLE (Ord int IDENTITY(1,1), Mal nvarchar(10), Bien nvarchar(5));
INSERT @m (Mal, Bien) VALUES
 (NCHAR(195)+NCHAR(161), NCHAR(225)),   -- a con tilde
 (NCHAR(195)+NCHAR(169), NCHAR(233)),   -- e con tilde
 (NCHAR(195)+NCHAR(173), NCHAR(237)),   -- i con tilde
 (NCHAR(195)+NCHAR(179), NCHAR(243)),   -- o con tilde
 (NCHAR(195)+NCHAR(186), NCHAR(250)),   -- u con tilde
 (NCHAR(195)+NCHAR(177), NCHAR(241)),   -- enie
 (NCHAR(195)+NCHAR(188), NCHAR(252)),   -- u con dieresis
 (NCHAR(195)+NCHAR(8220), NCHAR(211)),  -- O mayuscula con tilde
 (NCHAR(195)+NCHAR(8240), NCHAR(201)),  -- E mayuscula con tilde
 (NCHAR(195)+NCHAR(353), NCHAR(218)),   -- U mayuscula con tilde
 (NCHAR(195)+NCHAR(8216), NCHAR(209)),  -- Enie mayuscula
 (NCHAR(195)+NCHAR(339), NCHAR(220)),   -- U mayuscula con dieresis
 (NCHAR(195)+NCHAR(129), NCHAR(193)),  -- A mayuscula con tilde (byte 0x81)
 (NCHAR(195)+NCHAR(141), NCHAR(205)),  -- I mayuscula con tilde (byte 0x8D)
 (NCHAR(195)+N'?', NCHAR(193)),         -- A mayuscula con tilde (el byte 0x81 se perdio)
 (NCHAR(194)+NCHAR(176), NCHAR(176)),   -- grado
 (NCHAR(194)+NCHAR(186), NCHAR(186)),   -- o ordinal
 (NCHAR(194)+NCHAR(170), NCHAR(170)),   -- a ordinal
 (NCHAR(194)+NCHAR(191), NCHAR(191)),   -- signo de pregunta de apertura
 (NCHAR(194)+NCHAR(161), NCHAR(161)),   -- signo de exclamacion de apertura
 (NCHAR(194)+NCHAR(183), NCHAR(183));   -- punto medio

DECLARE @cols TABLE (S sysname, T sysname, C sysname);
INSERT @cols
SELECT s.name, t.name, c.name
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE s.name IN ('app','seguridad') AND ty.name IN ('varchar','nvarchar','char','nchar')
  AND c.is_computed = 0 AND c.max_length <> 0
  AND c.name NOT LIKE '%Password%' AND c.name NOT LIKE '%Clave%';

DECLARE @S sysname, @T sysname, @C sysname, @expr nvarchar(max), @sql nvarchar(max), @n int,
        @bin nvarchar(40) = N' COLLATE Latin1_General_BIN2', @cond nvarchar(max);
DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT S, T, C FROM @cols;
OPEN cur;
FETCH NEXT FROM cur INTO @S, @T, @C;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @cond = N'CAST(' + QUOTENAME(@C) + N' AS nvarchar(max))' + @bin + N' LIKE N''%' + NCHAR(195) + N'%'' OR CAST('
              + QUOTENAME(@C) + N' AS nvarchar(max))' + @bin + N' LIKE N''%' + NCHAR(194) + N'%''';
    SET @sql = N'SELECT @n = COUNT(*) FROM ' + QUOTENAME(@S) + N'.' + QUOTENAME(@T) + N' WHERE ' + @cond;
    EXEC sp_executesql @sql, N'@n int OUTPUT', @n = @n OUTPUT;
    IF @n > 0
    BEGIN
        SET @expr = N'CAST(' + QUOTENAME(@C) + N' AS nvarchar(max))' + @bin;
        SELECT @expr = N'REPLACE(' + @expr + N', N''' + REPLACE(Mal, N'''', N'''''') + N''', N''' + Bien + N''')' FROM @m ORDER BY Ord;
        SET @sql = N'UPDATE ' + QUOTENAME(@S) + N'.' + QUOTENAME(@T) + N' SET ' + QUOTENAME(@C) + N' = ' + @expr + N' WHERE ' + @cond;
        EXEC sp_executesql @sql;
        PRINT CONCAT('Texto corregido: ', @S, '.', @T, '.', @C, ' (', @@ROWCOUNT, ' filas)');
    END
    FETCH NEXT FROM cur INTO @S, @T, @C;
END
CLOSE cur; DEALLOCATE cur;
GO

/* ---------- B. Materias faltantes ---------- */
INSERT INTO app.tbMaterias (Mat_Nombre, Dur_Id, Mat_EsActivo, Mat_EsEliminado, Mat_UsuarioRegistra, Mat_FechaRegistra)
SELECT v.Nombre, 2, 1, 0, 1, GETDATE()
FROM (VALUES (N'Ciencias Naturales'), (N'Estudios Sociales')) v (Nombre)
WHERE NOT EXISTS (SELECT 1 FROM app.tbMaterias m WHERE m.Mat_Nombre = v.Nombre AND m.Mat_EsEliminado = 0);
GO

/* ---------- C. Semestres en la configuración ---------- */
DECLARE @Anio int = ISNULL((SELECT TOP (1) al.Ani_Anio FROM app.tbAnioLectivo al
                            WHERE al.Ani_Id = TRY_CAST((SELECT Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = 'anio_lectivo_activo_id') AS int)),
                           YEAR(GETDATE()));
DECLARE @k TABLE (Clave nvarchar(100), Valor nvarchar(500), Descr nvarchar(200), Tipo nvarchar(50));
INSERT @k VALUES
 (N'semestre_activo',   N'0', N'Semestre vigente: 0 = automático según las fechas, 1 o 2 = fijo', N'numero'),
 (N'semestre1_inicio',  CONCAT(@Anio, '-02-01'), N'Inicio del primer semestre', N'fecha'),
 (N'semestre1_fin',     CONCAT(@Anio, '-06-30'), N'Fin del primer semestre', N'fecha'),
 (N'semestre2_inicio',  CONCAT(@Anio, '-07-01'), N'Inicio del segundo semestre', N'fecha'),
 (N'semestre2_fin',     CONCAT(@Anio, '-11-30'), N'Fin del segundo semestre', N'fecha');
INSERT INTO app.tbConfiguracion (Con_Clave, Con_Valor, Con_Descripcion, Con_Grupo, Con_Tipo)
SELECT k.Clave, k.Valor, k.Descr, N'Académico', k.Tipo
FROM @k k WHERE NOT EXISTS (SELECT 1 FROM app.tbConfiguracion c WHERE c.Con_Clave = k.Clave);
GO

-- Semestre vigente (1 o 2): el fijado en la configuración; si es 0, el que cubre la fecha.
CREATE OR ALTER FUNCTION app.fn_SemestreActivo (@Fecha date = NULL)
RETURNS int
AS
BEGIN
    DECLARE @f date = ISNULL(@Fecha, CAST(GETDATE() AS date));
    DECLARE @fijo int = TRY_CAST((SELECT Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = 'semestre_activo') AS int);
    IF @fijo IN (1, 2) RETURN @fijo;
    DECLARE @i2 date = TRY_CAST((SELECT Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = 'semestre2_inicio') AS date);
    IF @i2 IS NULL RETURN CASE WHEN MONTH(@f) <= 6 THEN 1 ELSE 2 END;
    RETURN CASE WHEN @f >= @i2 THEN 2 ELSE 1 END;
END
GO

/* ---------- D. Sustituciones: 'semestre_activo' solo vale si es 1 o 2 ---------- */
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
            WHERE c.Con_Clave = 'semestre_activo' AND TRY_CAST(c.Con_Valor AS int) IN (1, 2)
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

/* ---------- E. Fotos de perfil que apuntaban a un archivo inexistente (profile-13.jpeg) ---------- */
UPDATE app.tbPersonas
SET Per_Imagen = CASE WHEN Per_Sexo = 'F' THEN '/Content/img/profile/profile-14-mujer.jpeg' ELSE '/Content/img/profile/profile-13-hombre.jpeg' END
WHERE Per_Imagen = '/Content/img/profile/profile-13.jpeg';
GO
