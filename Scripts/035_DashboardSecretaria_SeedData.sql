-- 035_DashboardSecretaria_SeedData.sql
-- Seed realista para que el Dashboard Secretaria muestre data útil.
-- Idempotente: limpia antes de insertar.

SET NOCOUNT ON;

DECLARE @Anio INT = 2026;
DECLARE @MesActual INT = MONTH(GETDATE());

-- ───────────────────────────────────────────────────────────────────────
-- 1) ALUMNOS SIN FOTO: vaciar Per_Imagen a ~20 alumnos aleatorios
-- ───────────────────────────────────────────────────────────────────────
UPDATE p
   SET Per_Imagen = NULL
FROM app.tbPersonas p
INNER JOIN app.tbAlumnos a ON p.Per_Id = a.Per_Id
WHERE a.AnioCursado = @Anio
  AND a.Alu_Id IN (
      SELECT TOP 20 Alu_Id FROM app.tbAlumnos
      WHERE AnioCursado = @Anio
      ORDER BY NEWID()
  );
PRINT CONCAT('Alumnos sin foto: ', @@ROWCOUNT);

-- ───────────────────────────────────────────────────────────────────────
-- 2) ENCARGADOS INCOMPLETOS: vaciar tel a 5 y correo a 5 (10 total)
-- ───────────────────────────────────────────────────────────────────────
UPDATE p
   SET Per_Telefono = NULL
FROM app.tbPersonas p
INNER JOIN app.tbEncargados e ON p.Per_Id = e.Per_Id
WHERE e.Enc_Id IN (
    SELECT TOP 5 Enc_Id FROM app.tbEncargados ORDER BY NEWID()
);
PRINT CONCAT('Encargados sin tel: ', @@ROWCOUNT);

UPDATE p
   SET Per_CorreoElectronico = NULL
FROM app.tbPersonas p
INNER JOIN app.tbEncargados e ON p.Per_Id = e.Per_Id
WHERE p.Per_Telefono IS NOT NULL  -- no afectar los que ya quedaron sin tel
  AND e.Enc_Id IN (
      SELECT TOP 5 Enc_Id FROM app.tbEncargados
      WHERE Enc_Id NOT IN (SELECT TOP 5 Enc_Id FROM app.tbEncargados ORDER BY NEWID())
      ORDER BY NEWID()
  );
PRINT CONCAT('Encargados sin correo: ', @@ROWCOUNT);

-- ───────────────────────────────────────────────────────────────────────
-- 3) NUEVAS MATRÍCULAS POR MES: distribuir Per_FechaRegistra entre los
--    últimos 6 meses del año actual y los mismos del año anterior
-- ───────────────────────────────────────────────────────────────────────
;WITH AlumnosRandom AS (
    SELECT a.Alu_Id, p.Per_Id,
           NTILE(12) OVER (ORDER BY NEWID()) AS Bucket
    FROM app.tbAlumnos a
    INNER JOIN app.tbPersonas p ON a.Per_Id = p.Per_Id
    WHERE a.AnioCursado = @Anio
)
UPDATE p
   SET Per_FechaRegistra = CASE ar.Bucket
        -- Año actual (buckets 1-6)
        WHEN 1 THEN DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 28, DATEFROMPARTS(@Anio, @MesActual, 1))
        WHEN 2 THEN DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 28, DATEFROMPARTS(@Anio, CASE WHEN @MesActual = 1 THEN 12 ELSE @MesActual - 1 END, 1))
        WHEN 3 THEN DATEADD(MONTH, -2, DATEFROMPARTS(@Anio, @MesActual, 1))
        WHEN 4 THEN DATEADD(MONTH, -3, DATEFROMPARTS(@Anio, @MesActual, 1))
        WHEN 5 THEN DATEADD(MONTH, -4, DATEFROMPARTS(@Anio, @MesActual, 1))
        WHEN 6 THEN DATEADD(MONTH, -5, DATEFROMPARTS(@Anio, @MesActual, 1))
        -- Año anterior (buckets 7-12) en los mismos meses
        WHEN 7  THEN DATEADD(YEAR, -1, DATEFROMPARTS(@Anio, @MesActual, 1))
        WHEN 8  THEN DATEADD(YEAR, -1, DATEADD(MONTH, -1, DATEFROMPARTS(@Anio, @MesActual, 1)))
        WHEN 9  THEN DATEADD(YEAR, -1, DATEADD(MONTH, -2, DATEFROMPARTS(@Anio, @MesActual, 1)))
        WHEN 10 THEN DATEADD(YEAR, -1, DATEADD(MONTH, -3, DATEFROMPARTS(@Anio, @MesActual, 1)))
        WHEN 11 THEN DATEADD(YEAR, -1, DATEADD(MONTH, -4, DATEFROMPARTS(@Anio, @MesActual, 1)))
        WHEN 12 THEN DATEADD(YEAR, -1, DATEADD(MONTH, -5, DATEFROMPARTS(@Anio, @MesActual, 1)))
   END
FROM app.tbPersonas p
INNER JOIN AlumnosRandom ar ON p.Per_Id = ar.Per_Id;
PRINT CONCAT('Alumnos con Per_FechaRegistra distribuida: ', @@ROWCOUNT);

-- ───────────────────────────────────────────────────────────────────────
-- 4) DOCUMENTOS PENDIENTES: limpiar tabla y poblar con registros
--    pendientes para ~40 alumnos × 1-3 documentos obligatorios c/u
-- ───────────────────────────────────────────────────────────────────────
DELETE FROM app.tbDocumentosAlumno;

INSERT INTO app.tbDocumentosAlumno (Alu_Id, TDoc_Id, Doa_EsEntregado, Doa_FechaEntrega, Doa_EsEliminado, Doa_UsuarioRegistra, Doa_FechaRegistra)
SELECT
    a.Alu_Id,
    td.TDoc_Id,
    0 AS Doa_EsEntregado,
    NULL AS Doa_FechaEntrega,
    0 AS Doa_EsEliminado,
    1 AS Doa_UsuarioRegistra,
    GETDATE() AS Doa_FechaRegistra
FROM (
    -- 40 alumnos aleatorios del año actual
    SELECT TOP 40 Alu_Id FROM app.tbAlumnos WHERE AnioCursado = @Anio ORDER BY NEWID()
) a
CROSS JOIN app.tbTiposDocumento td
WHERE td.TDoc_EsObligatorio = 1 AND td.TDoc_EsEliminado = 0
  -- Cada alumno tiene aleatoriamente 1-3 docs pendientes
  AND ABS(CHECKSUM(NEWID(), td.TDoc_Id)) % 2 = 0;
PRINT CONCAT('Documentos pendientes insertados: ', @@ROWCOUNT);

-- También insertamos algunos como entregados para que la métrica no sea 100% pendiente
INSERT INTO app.tbDocumentosAlumno (Alu_Id, TDoc_Id, Doa_EsEntregado, Doa_FechaEntrega, Doa_EsEliminado, Doa_UsuarioRegistra, Doa_FechaRegistra)
SELECT TOP 60
    a.Alu_Id,
    td.TDoc_Id,
    1 AS Doa_EsEntregado,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 60, GETDATE()) AS Doa_FechaEntrega,
    0,
    1,
    GETDATE()
FROM app.tbAlumnos a
CROSS JOIN app.tbTiposDocumento td
WHERE a.AnioCursado = @Anio
  AND td.TDoc_EsObligatorio = 1
  AND NOT EXISTS (
      SELECT 1 FROM app.tbDocumentosAlumno x WHERE x.Alu_Id = a.Alu_Id AND x.TDoc_Id = td.TDoc_Id
  )
ORDER BY NEWID();
PRINT CONCAT('Documentos entregados insertados: ', @@ROWCOUNT);

-- ───────────────────────────────────────────────────────────────────────
-- Verificación final
-- ───────────────────────────────────────────────────────────────────────
EXEC app.PR_DashboardSecretaria_Resumen @Anio = @Anio;
