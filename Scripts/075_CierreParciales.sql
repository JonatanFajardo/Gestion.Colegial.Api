/* =============================================================================
   075 · Cierre y publicación de parciales  (espejo de Skuul: exams.active / publish_result
         y ClosureReadinessCheck: "reporta lo pendiente sin cerrar; una persona confirma el cierre")

   - Un período de notas = (año, Sem_Id, Pac_Id). En 2026: 2 semestres × 2 parciales = 4 períodos.
   - app.tbCierresParcial guarda el estado de cada período: abierto | cerrado, si está publicado,
     quién y cuándo lo cerró / publicó y fechas opcionales de carga (inicio y límite, como
     start_date / stop_date de Skuul). SIN FILA = abierto y sin publicar.
   - app.tbCierresParcialHistorial: cada acción (cerrar, reabrir, publicar, despublicar, fechas)
     con motivo, usuario, fecha y la foto del avance al momento (esperadas, cargadas, faltantes).
   - Reglas:
       cerrar      : solo si está abierto. Si faltan notas, pide confirmación explícita y motivo.
       publicar    : solo si está cerrado y sin publicar.
       despublicar : solo si está publicado; motivo obligatorio (queda cerrado).
       reabrir     : solo si está cerrado; motivo obligatorio; quita la publicación.
       fechas      : solo si está abierto; inicio <= límite.
   - Notas esperadas = alumnos activos del año en cada sección × materias de esa sección según
     app.tbHorarios del año. Sección = (Cur_Id, Cun_Id, Sec_Id, Mda_Id), la misma ubicación que trae
     app.tbAlumnos. Si la sección no tiene horario para ese semestre se usan las materias de su
     horario del año (hoy solo hay horarios del primer semestre). Cargadas = esperadas que ya
     tienen una nota viva en el período. Las secciones con alumnos y sin horario se informan aparte.
   - Período cerrado = nadie registra, cambia ni quita notas: los procedimientos que escriben en
     app.tbNotas llaman a app.PR_CierresParcial_ValidarAbierto / _ValidarNota al inicio y estos
     lanzan THROW 50070 con un mensaje claro. Se cambian, con la MISMA firma y el mismo
     comportamiento con el período abierto:
       app.PR_tbNotas_Insert, app.PR_tbNotas_Update, dbo.PR_tbNotas_Delete.
     No se tocan: app.spGraduarAlumno (archiva las notas del alumno graduado: ocurre después del
     cierre), app.PR_Seed_NotasAlumnos y dbo.PR_ActualizarFechas* (herramientas de datos de prueba).
   - Permisos:
       Cierre de parciales          = ver estado, faltantes e historial (admin, director, secretaria)
       Cerrar y publicar parciales  = cerrar, publicar, despublicar, reabrir y fechas (admin, director)
   - Prefijos: Cpa_ (cierre), Cph_ (historial). Errores 50070-50079.
   Idempotente: se puede correr varias veces.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ───────────────────────────── Tablas ───────────────────────────── */

IF OBJECT_ID(N'app.tbCierresParcial', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbCierresParcial
    (
        Cpa_Id               int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbCierresParcial PRIMARY KEY,
        Cpa_Anio             int          NOT NULL,
        Sem_Id               int          NOT NULL CONSTRAINT FK_tbCierresParcial_tbSemestres REFERENCES app.tbSemestres (Sem_Id),
        Pac_Id               int          NOT NULL CONSTRAINT FK_tbCierresParcial_tbParciales REFERENCES app.tbParciales (Pac_Id),
        Cpa_Estado           varchar(10)  NOT NULL CONSTRAINT DF_tbCierresParcial_Estado DEFAULT ('abierto'),
        Cpa_FechaInicio      date         NULL,
        Cpa_FechaLimite      date         NULL,
        Cpa_FechaCierre      datetime     NULL,
        Usu_IdCierre         int          NULL CONSTRAINT FK_tbCierresParcial_UsuarioCierre REFERENCES seguridad.tbUsuarios (Usu_Id),
        Cpa_Publicado        bit          NOT NULL CONSTRAINT DF_tbCierresParcial_Publicado DEFAULT (0),
        Cpa_FechaPublicacion datetime     NULL,
        Usu_IdPublicacion    int          NULL CONSTRAINT FK_tbCierresParcial_UsuarioPublicacion REFERENCES seguridad.tbUsuarios (Usu_Id),
        Cpa_UsuarioRegistra  int          NOT NULL,
        Cpa_FechaRegistra    datetime     NOT NULL CONSTRAINT DF_tbCierresParcial_FechaRegistra DEFAULT (GETDATE()),
        Cpa_UsuarioModifica  int          NULL,
        Cpa_FechaModifica    datetime     NULL,
        CONSTRAINT UQ_tbCierresParcial_Periodo UNIQUE (Cpa_Anio, Sem_Id, Pac_Id),
        CONSTRAINT CK_tbCierresParcial_Estado CHECK (Cpa_Estado IN ('abierto', 'cerrado')),
        CONSTRAINT CK_tbCierresParcial_Publicado CHECK (Cpa_Publicado = 0 OR Cpa_Estado = 'cerrado'),
        CONSTRAINT CK_tbCierresParcial_Fechas CHECK (Cpa_FechaInicio IS NULL OR Cpa_FechaLimite IS NULL OR Cpa_FechaInicio <= Cpa_FechaLimite),
        CONSTRAINT CK_tbCierresParcial_Anio CHECK (Cpa_Anio BETWEEN 2000 AND 2100)
    );
END
GO

IF OBJECT_ID(N'app.tbCierresParcialHistorial', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbCierresParcialHistorial
    (
        Cph_Id         int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbCierresParcialHistorial PRIMARY KEY,
        Cpa_Id         int           NOT NULL CONSTRAINT FK_tbCierresParcialHistorial_Cierre REFERENCES app.tbCierresParcial (Cpa_Id),
        Cph_Accion     varchar(12)   NOT NULL,
        Cph_Motivo     nvarchar(500) NULL,
        Cph_Esperadas  int           NULL,
        Cph_Cargadas   int           NULL,
        Cph_Faltantes  int           NULL,
        Usu_Id         int           NOT NULL CONSTRAINT FK_tbCierresParcialHistorial_Usuario REFERENCES seguridad.tbUsuarios (Usu_Id),
        Cph_Fecha      datetime      NOT NULL CONSTRAINT DF_tbCierresParcialHistorial_Fecha DEFAULT (GETDATE()),
        CONSTRAINT CK_tbCierresParcialHistorial_Accion CHECK (Cph_Accion IN ('cerrar', 'reabrir', 'publicar', 'despublicar', 'fechas'))
    );
    CREATE INDEX IX_tbCierresParcialHistorial_Cierre ON app.tbCierresParcialHistorial (Cpa_Id, Cph_Fecha DESC);
END
GO

/* ───────────────────────────── Funciones ───────────────────────────── */

-- "Primer parcial" a partir del catálogo ("Primero" → "Primer", "Tercero" → "Tercer").
CREATE OR ALTER FUNCTION app.FN_CierresParcial_NombreParcial (@Pac_Id int)
RETURNS nvarchar(80)
AS
BEGIN
    DECLARE @d nvarchar(60) = (SELECT LTRIM(RTRIM(Pac_Descripcion)) FROM app.tbParciales WHERE Pac_Id = @Pac_Id);
    IF @d IS NULL RETURN N'Parcial ' + CAST(@Pac_Id AS nvarchar(10));
    IF @d LIKE N'%parcial%' RETURN @d;
    RETURN CASE @d WHEN N'Primero' THEN N'Primer' WHEN N'Tercero' THEN N'Tercer' ELSE @d END + N' parcial';
END
GO

-- "Primer semestre" a partir del catálogo.
CREATE OR ALTER FUNCTION app.FN_CierresParcial_NombreSemestre (@Sem_Id int)
RETURNS nvarchar(80)
AS
BEGIN
    DECLARE @d nvarchar(60) = (SELECT LTRIM(RTRIM(Sem_Descripcion)) FROM app.tbSemestres WHERE Sem_Id = @Sem_Id);
    IF @d IS NULL RETURN N'Semestre ' + CAST(@Sem_Id AS nvarchar(10));
    IF @d LIKE N'%semestre%' RETURN @d;
    RETURN CASE @d WHEN N'Primero' THEN N'Primer' WHEN N'Tercero' THEN N'Tercer' ELSE @d END + N' semestre';
END
GO

-- Nombre visible de quien hizo la acción: "Nombre del empleado (usuario)". Los usuarios de prueba
-- comparten empleado, por eso va siempre el usuario.
CREATE OR ALTER FUNCTION app.FN_CierresParcial_NombreUsuario (@Usu_Id int)
RETURNS nvarchar(250)
AS
BEGIN
    RETURN (
        SELECT TOP (1)
            CASE WHEN n.Nombre IS NULL OR n.Nombre = u.Usu_Name THEN u.Usu_Name
                 ELSE n.Nombre + N' (' + u.Usu_Name + N')' END
        FROM seguridad.tbUsuarios u
        CROSS APPLY (SELECT NULLIF(app.FN_NombreUsuario(u.Usu_Id), N'') AS Nombre) n
        WHERE u.Usu_Id = @Usu_Id);
END
GO

-- Horarios que cuentan para un semestre: los de ese semestre; si la sección no tiene horario en ese
-- semestre, los de su horario del año (materias anuales).
CREATE OR ALTER FUNCTION app.FN_CierresParcial_Horarios (@Anio int, @Sem_Id int)
RETURNS TABLE
AS
RETURN
    SELECT h.Cur_Id, h.Cun_Id, h.Sec_Id, h.Mda_Id, h.Mat_Id, h.Emp_Id
    FROM app.tbHorarios h
    WHERE h.Hor_Año = @Anio
      AND ISNULL(h.Hor_EsEliminado, 0) = 0
      AND (   h.Sem_Id = @Sem_Id
           OR NOT EXISTS (SELECT 1 FROM app.tbHorarios x
                          WHERE x.Hor_Año = @Anio AND ISNULL(x.Hor_EsEliminado, 0) = 0 AND x.Sem_Id = @Sem_Id
                            AND x.Cur_Id = h.Cur_Id AND x.Cun_Id = h.Cun_Id
                            AND x.Sec_Id = h.Sec_Id AND x.Mda_Id = h.Mda_Id));
GO

-- Alumnos activos del año con su sección.
CREATE OR ALTER FUNCTION app.FN_CierresParcial_Alumnos (@Anio int)
RETURNS TABLE
AS
RETURN
    SELECT a.Alu_Id, a.Cur_Id, a.Cun_Id, a.Sec_Id, a.Mda_Id
    FROM app.tbAlumnos a
    INNER JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id
    WHERE a.AnioCursado = @Anio
      AND ISNULL(a.Est_Id, 1) = 1
      AND ISNULL(p.Per_EsEliminado, 0) = 0;
GO

-- Avance de un período por sección y materia: alumnos (= notas esperadas) y notas ya cargadas.
CREATE OR ALTER FUNCTION app.FN_CierresParcial_Avance (@Anio int, @Sem_Id int, @Pac_Id int)
RETURNS TABLE
AS
RETURN
    WITH m AS (
        SELECT DISTINCT Cur_Id, Cun_Id, Sec_Id, Mda_Id, Mat_Id
        FROM app.FN_CierresParcial_Horarios(@Anio, @Sem_Id)
    ),
    n AS (
        SELECT DISTINCT Alu_Id, Mat_Id
        FROM app.tbNotas
        WHERE Not_Año >= DATEFROMPARTS(@Anio, 1, 1) AND Not_Año < DATEFROMPARTS(@Anio + 1, 1, 1)
          AND Sem_Id = @Sem_Id AND Pac_Id = @Pac_Id
          AND Not_EsEliminado = 0 AND Not_EsActivo = 1
    )
    SELECT m.Cur_Id, m.Cun_Id, m.Sec_Id, m.Mda_Id, m.Mat_Id,
           COUNT(*) AS Alumnos,
           SUM(CASE WHEN n.Alu_Id IS NULL THEN 0 ELSE 1 END) AS Cargadas
    FROM m
    INNER JOIN app.FN_CierresParcial_Alumnos(@Anio) al
            ON al.Cur_Id = m.Cur_Id AND al.Cun_Id = m.Cun_Id AND al.Sec_Id = m.Sec_Id AND al.Mda_Id = m.Mda_Id
    LEFT JOIN n ON n.Alu_Id = al.Alu_Id AND n.Mat_Id = m.Mat_Id
    GROUP BY m.Cur_Id, m.Cun_Id, m.Sec_Id, m.Mda_Id, m.Mat_Id;
GO

/* ───────────────────── Guardas para quien escribe notas ───────────────────── */

-- Rechaza (THROW 50070) si el período está cerrado. Sin datos del período no hace nada.
CREATE OR ALTER PROCEDURE app.PR_CierresParcial_ValidarAbierto
    @Anio   int,
    @Sem_Id int,
    @Pac_Id int
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL OR @Sem_Id IS NULL OR @Pac_Id IS NULL RETURN;

    IF EXISTS (SELECT 1 FROM app.tbCierresParcial
               WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem_Id AND Pac_Id = @Pac_Id AND Cpa_Estado = 'cerrado')
    BEGIN
        DECLARE @Mensaje nvarchar(400) = CONCAT(
            N'El ', LOWER(app.FN_CierresParcial_NombreParcial(@Pac_Id)),
            N' del ', LOWER(app.FN_CierresParcial_NombreSemestre(@Sem_Id)), N' de ', @Anio,
            N' está cerrado: ya no se pueden registrar, cambiar ni quitar notas. ',
            N'Si hace falta una corrección, pida a Dirección que lo reabra.');
        THROW 50070, @Mensaje, 1;
    END
END
GO

-- Igual, a partir de una nota existente (su año, semestre y parcial).
CREATE OR ALTER PROCEDURE app.PR_CierresParcial_ValidarNota
    @Not_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Anio int, @Sem_Id int, @Pac_Id int;
    SELECT @Anio = YEAR(Not_Año), @Sem_Id = Sem_Id, @Pac_Id = Pac_Id
    FROM app.tbNotas
    WHERE Not_Id = @Not_Id;

    EXEC app.PR_CierresParcial_ValidarAbierto @Anio, @Sem_Id, @Pac_Id;
END
GO

/* ─────────── Procedimientos existentes que escriben notas (misma firma) ─────────── */

CREATE OR ALTER PROCEDURE [app].[PR_tbNotas_Insert]
    @Alu_Id              INT,
    @Hor_Id              INT,
    @Par_Id              INT,           -- Pac_Id del parcial
    @Not_Calificacion    INT,           -- Not_Nota es INT en la tabla
    @UsuarioRegistra     INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Resolver datos del horario
    DECLARE @Sec_Id INT, @Mat_Id INT, @Sem_Id INT, @Anio INT, @Aul_Id INT;
    SELECT
        @Sec_Id = Sec_Id,
        @Mat_Id = Mat_Id,
        @Sem_Id = Sem_Id,
        @Anio   = Hor_Año,
        @Aul_Id = Aul_Id
    FROM [app].[tbHorario]
    WHERE Hor_Id = @Hor_Id AND Hor_EsEliminado = 0;

    IF @Sec_Id IS NULL
    BEGIN
        SELECT 0 AS CodeResult, 0 AS Not_Id, 'Horario no encontrado' AS Mensaje;
        RETURN;
    END

    -- 075: parcial cerrado = no se registran ni cambian notas (THROW 50070)
    EXEC app.PR_CierresParcial_ValidarAbierto @Anio, @Sem_Id, @Par_Id;

    DECLARE @FechaAnio DATE = DATEFROMPARTS(@Anio, 1, 1);
    DECLARE @ExistingId INT = NULL;

    SELECT @ExistingId = Not_Id
    FROM [app].[tbNotas]
    WHERE Alu_Id          = @Alu_Id
      AND Sec_Id          = @Sec_Id
      AND Mat_Id          = @Mat_Id
      AND Pac_Id          = @Par_Id
      AND Sem_Id          = @Sem_Id
      AND YEAR(Not_Año)   = @Anio
      AND Not_EsEliminado = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @ExistingId IS NOT NULL
        BEGIN
            -- Actualizar nota existente
            UPDATE [app].[tbNotas]
            SET Not_Nota            = @Not_Calificacion,
                Not_UsuarioModifica = @UsuarioRegistra,
                Not_FechaModifica   = GETDATE()
            WHERE Not_Id = @ExistingId;

            COMMIT TRANSACTION;
            SELECT 1 AS CodeResult, @ExistingId AS Not_Id, 'Nota actualizada' AS Mensaje;
        END
        ELSE
        BEGIN
            -- Insertar nueva nota
            INSERT INTO [app].[tbNotas]
                (Alu_Id, Aul_Id, Sec_Id, Mat_Id, Sem_Id, Pac_Id,
                 Not_Nota, Not_Año, Not_EsActivo, Not_EsEliminado,
                 Not_UsuarioRegistra, Not_FechaRegistra)
            VALUES
                (@Alu_Id, @Aul_Id, @Sec_Id, @Mat_Id, @Sem_Id, @Par_Id,
                 @Not_Calificacion, @FechaAnio, 1, 0,
                 @UsuarioRegistra, GETDATE());

            DECLARE @NewId INT = SCOPE_IDENTITY();
            COMMIT TRANSACTION;
            SELECT 1 AS CodeResult, @NewId AS Not_Id, 'Nota insertada' AS Mensaje;
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS CodeResult, 0 AS Not_Id, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [app].[PR_tbNotas_Update]
    @Not_Id              INT,
    @Not_Calificacion    INT,           -- Not_Nota es INT
    @UsuarioModifica     INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 075: parcial cerrado = no se registran ni cambian notas (THROW 50070)
    EXEC app.PR_CierresParcial_ValidarNota @Not_Id;

    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [app].[tbNotas]
        SET Not_Nota            = @Not_Calificacion,
            Not_UsuarioModifica = @UsuarioModifica,
            Not_FechaModifica   = GETDATE()
        WHERE Not_Id = @Not_Id AND Not_EsEliminado = 0;

        COMMIT TRANSACTION;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS CodeResult;
    END CATCH
END
GO

-----------------> tbNotas
CREATE OR ALTER PROCEDURE [dbo].[PR_tbNotas_Delete]
	@Not_Id INT
AS
  BEGIN
          -- 075: parcial cerrado = no se quitan notas (THROW 50070)
          EXEC app.PR_CierresParcial_ValidarNota @Not_Id;

          UPDATE [app].[tbNotas]
          SET    Not_Eseliminado	= 1
          WHERE  Not_Id 		= @Not_Id
  END
GO

/* ───────────────────────────── Lecturas ───────────────────────────── */

-- Años que se pueden revisar: los que tienen notas, horarios o cierres, más el año lectivo activo.
CREATE OR ALTER PROCEDURE app.PR_CierresParcial_Anios
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Activo int = TRY_CAST((SELECT TOP (1) Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = 'anio_lectivo_actual') AS int);
    IF @Activo IS NULL SET @Activo = YEAR(GETDATE());

    SELECT a.Anio, CAST(CASE WHEN a.Anio = @Activo THEN 1 ELSE 0 END AS bit) AS EsActivo
    FROM (
        SELECT DISTINCT YEAR(Not_Año) AS Anio FROM app.tbNotas WHERE Not_EsEliminado = 0
        UNION SELECT DISTINCT Hor_Año FROM app.tbHorarios WHERE ISNULL(Hor_EsEliminado, 0) = 0
        UNION SELECT DISTINCT Cpa_Anio FROM app.tbCierresParcial
        UNION SELECT @Activo
    ) a
    WHERE a.Anio BETWEEN 2000 AND 2100
    ORDER BY a.Anio DESC;
END
GO

-- Estado de los períodos (semestre × parcial) de un año sin calcular el avance: lo usan el cuaderno
-- de notas (¿se puede escribir?) y el boletín (¿resultados provisionales?). Con @Not_Id se toma el
-- período de esa nota.
CREATE OR ALTER PROCEDURE app.PR_CierresParcial_Periodos
    @Anio   int = NULL,
    @Sem_Id int = NULL,
    @Pac_Id int = NULL,
    @Not_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Not_Id IS NOT NULL
        SELECT @Anio = YEAR(Not_Año), @Sem_Id = Sem_Id, @Pac_Id = Pac_Id FROM app.tbNotas WHERE Not_Id = @Not_Id;
    IF @Anio IS NULL RETURN;

    DECLARE @Desde date = DATEFROMPARTS(@Anio, 1, 1), @Hasta date = DATEFROMPARTS(@Anio + 1, 1, 1);

    SELECT @Anio AS Anio,
           s.Sem_Id, p.Pac_Id,
           app.FN_CierresParcial_NombreParcial(p.Pac_Id)  AS Parcial,
           app.FN_CierresParcial_NombreSemestre(s.Sem_Id) AS Semestre,
           CAST(ISNULL(c.Cpa_Estado, 'abierto') AS varchar(10)) AS Estado,
           CAST(ISNULL(c.Cpa_Publicado, 0) AS bit)       AS Publicado,
           c.Cpa_FechaCierre                              AS FechaCierre,
           app.FN_CierresParcial_NombreUsuario(c.Usu_IdCierre) AS UsuarioCierre,
           c.Cpa_FechaPublicacion                         AS FechaPublicacion,
           ISNULL(t.Notas, 0)                             AS NotasPeriodo
    FROM app.tbSemestres s
    CROSS JOIN app.tbParciales p
    LEFT JOIN app.tbCierresParcial c ON c.Cpa_Anio = @Anio AND c.Sem_Id = s.Sem_Id AND c.Pac_Id = p.Pac_Id
    OUTER APPLY (SELECT COUNT(*) AS Notas FROM app.tbNotas n
                 WHERE n.Not_Año >= @Desde AND n.Not_Año < @Hasta AND n.Sem_Id = s.Sem_Id AND n.Pac_Id = p.Pac_Id
                   AND n.Not_EsEliminado = 0 AND n.Not_EsActivo = 1) t
    WHERE ISNULL(s.Sem_EsEliminado, 0) = 0 AND ISNULL(p.Pac_EsEliminado, 0) = 0
      AND (@Sem_Id IS NULL OR s.Sem_Id = @Sem_Id)
      AND (@Pac_Id IS NULL OR p.Pac_Id = @Pac_Id)
    ORDER BY s.Sem_Id, p.Pac_Id;
END
GO

-- Tablero de "Cierre de parciales": un renglón por semestre × parcial con estado, fechas y avance.
CREATE OR ALTER PROCEDURE app.PR_CierresParcial_Estado
    @Anio int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Desde date = DATEFROMPARTS(@Anio, 1, 1), @Hasta date = DATEFROMPARTS(@Anio + 1, 1, 1);
    DECLARE @Hoy date = CAST(GETDATE() AS date);

    -- Secciones con alumnos activos y sin ningún horario en el año: no se puede saber qué notas esperar.
    DECLARE @SinHorarioSecciones int, @SinHorarioAlumnos int;
    SELECT @SinHorarioSecciones = COUNT(DISTINCT CONCAT(al.Cur_Id, '-', al.Cun_Id, '-', al.Sec_Id, '-', al.Mda_Id)),
           @SinHorarioAlumnos   = COUNT(*)
    FROM app.FN_CierresParcial_Alumnos(@Anio) al
    WHERE NOT EXISTS (SELECT 1 FROM app.tbHorarios h
                      WHERE h.Hor_Año = @Anio AND ISNULL(h.Hor_EsEliminado, 0) = 0
                        AND h.Cur_Id = al.Cur_Id AND h.Cun_Id = al.Cun_Id AND h.Sec_Id = al.Sec_Id AND h.Mda_Id = al.Mda_Id);

    SELECT @Anio AS Anio,
           s.Sem_Id, p.Pac_Id,
           app.FN_CierresParcial_NombreParcial(p.Pac_Id)  AS Parcial,
           app.FN_CierresParcial_NombreSemestre(s.Sem_Id) AS Semestre,
           CAST(ISNULL(c.Cpa_Estado, 'abierto') AS varchar(10)) AS Estado,
           CAST(ISNULL(c.Cpa_Publicado, 0) AS bit)        AS Publicado,
           c.Cpa_FechaInicio                              AS FechaInicio,
           c.Cpa_FechaLimite                              AS FechaLimite,
           CAST(CASE WHEN ISNULL(c.Cpa_Estado, 'abierto') = 'abierto' AND c.Cpa_FechaLimite < @Hoy THEN 1 ELSE 0 END AS bit) AS LimiteVencido,
           c.Cpa_FechaCierre                              AS FechaCierre,
           app.FN_CierresParcial_NombreUsuario(c.Usu_IdCierre)      AS UsuarioCierre,
           c.Cpa_FechaPublicacion                         AS FechaPublicacion,
           app.FN_CierresParcial_NombreUsuario(c.Usu_IdPublicacion) AS UsuarioPublicacion,
           ISNULL(a.Esperadas, 0)                         AS Esperadas,
           ISNULL(a.Cargadas, 0)                          AS Cargadas,
           ISNULL(a.Esperadas, 0) - ISNULL(a.Cargadas, 0) AS Faltantes,
           ISNULL(a.SeccionesConFaltantes, 0)             AS SeccionesConFaltantes,
           ISNULL(a.MateriasConFaltantes, 0)              AS MateriasConFaltantes,
           ISNULL(t.Notas, 0)                             AS NotasPeriodo,
           ISNULL(@SinHorarioSecciones, 0)                AS SeccionesSinHorario,
           ISNULL(@SinHorarioAlumnos, 0)                  AS AlumnosSinHorario
    FROM app.tbSemestres s
    CROSS JOIN app.tbParciales p
    LEFT JOIN app.tbCierresParcial c ON c.Cpa_Anio = @Anio AND c.Sem_Id = s.Sem_Id AND c.Pac_Id = p.Pac_Id
    OUTER APPLY (
        SELECT SUM(v.Alumnos)  AS Esperadas,
               SUM(v.Cargadas) AS Cargadas,
               COUNT(DISTINCT CASE WHEN v.Cargadas < v.Alumnos
                                   THEN CONCAT(v.Cur_Id, '-', v.Cun_Id, '-', v.Sec_Id, '-', v.Mda_Id) END) AS SeccionesConFaltantes,
               SUM(CASE WHEN v.Cargadas < v.Alumnos THEN 1 ELSE 0 END) AS MateriasConFaltantes
        FROM app.FN_CierresParcial_Avance(@Anio, s.Sem_Id, p.Pac_Id) v) a
    OUTER APPLY (SELECT COUNT(*) AS Notas FROM app.tbNotas n
                 WHERE n.Not_Año >= @Desde AND n.Not_Año < @Hasta AND n.Sem_Id = s.Sem_Id AND n.Pac_Id = p.Pac_Id
                   AND n.Not_EsEliminado = 0 AND n.Not_EsActivo = 1) t
    WHERE ISNULL(s.Sem_EsEliminado, 0) = 0 AND ISNULL(p.Pac_EsEliminado, 0) = 0
    ORDER BY s.Sem_Id, p.Pac_Id;
END
GO

-- Notas faltantes de un período por sección, materia y docente (para exigirlas).
CREATE OR ALTER PROCEDURE app.PR_CierresParcial_Faltantes
    @Anio   int,
    @Sem_Id int,
    @Pac_Id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT v.Cur_Id, v.Cun_Id, v.Sec_Id, v.Mda_Id, v.Mat_Id,
           niv.Niv_Descripcion AS Nivel,
           LTRIM(RTRIM(REPLACE(REPLACE(cur.Cur_Nombre, CHAR(13), ''), CHAR(10), ''))) AS Carrera,
           cun.Cun_Descripcion AS Grado,
           ISNULL(cun.Cun_Orden, 0) AS GradoOrden,
           sec.Sec_Descripcion AS Seccion,
           mda.Mda_Descripcion AS Modalidad,
           mat.Mat_Nombre      AS Materia,
           ISNULL(d.Docentes, N'Sin docente en el horario') AS Docentes,
           v.Alumnos,
           v.Cargadas,
           v.Alumnos - v.Cargadas AS Faltan,
           CAST(ROUND(100.0 * v.Cargadas / NULLIF(v.Alumnos, 0), 1) AS decimal(5,1)) AS Porcentaje
    FROM app.FN_CierresParcial_Avance(@Anio, @Sem_Id, @Pac_Id) v
    LEFT JOIN app.tbCursos            cur ON cur.Cur_Id = v.Cur_Id
    LEFT JOIN app.tbNivelesEducativos niv ON niv.Niv_Id = cur.Niv_Id
    LEFT JOIN app.tbCursosNiveles     cun ON cun.Cun_Id = v.Cun_Id
    LEFT JOIN app.tbSecciones         sec ON sec.Sec_Id = v.Sec_Id
    LEFT JOIN app.tbModalidades       mda ON mda.Mda_Id = v.Mda_Id
    LEFT JOIN app.tbMaterias          mat ON mat.Mat_Id = v.Mat_Id
    OUTER APPLY (
        SELECT STRING_AGG(x.Nombre, N', ') WITHIN GROUP (ORDER BY x.Nombre) AS Docentes
        FROM (SELECT DISTINCT LTRIM(RTRIM(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(pe.Per_PrimerNombre)), N''),
                                                         NULLIF(LTRIM(RTRIM(pe.Per_ApellidoPaterno)), N'')))) AS Nombre
              FROM app.FN_CierresParcial_Horarios(@Anio, @Sem_Id) h
              INNER JOIN app.tbEmpleados e  ON e.Emp_Id = h.Emp_Id
              INNER JOIN app.tbPersonas  pe ON pe.Per_Id = e.Per_Id
              WHERE h.Cur_Id = v.Cur_Id AND h.Cun_Id = v.Cun_Id AND h.Sec_Id = v.Sec_Id
                AND h.Mda_Id = v.Mda_Id AND h.Mat_Id = v.Mat_Id) x) d
    WHERE v.Cargadas < v.Alumnos
    ORDER BY ISNULL(cun.Cun_Orden, 0), cun.Cun_Descripcion, sec.Sec_Descripcion, mda.Mda_Descripcion, Carrera, mat.Mat_Nombre;
END
GO

-- Historial de acciones de un año (lo último primero).
CREATE OR ALTER PROCEDURE app.PR_CierresParcial_Historial
    @Anio int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT h.Cph_Id, c.Cpa_Anio AS Anio, c.Sem_Id, c.Pac_Id,
           app.FN_CierresParcial_NombreParcial(c.Pac_Id)  AS Parcial,
           app.FN_CierresParcial_NombreSemestre(c.Sem_Id) AS Semestre,
           h.Cph_Accion AS Accion, h.Cph_Motivo AS Motivo,
           h.Cph_Esperadas AS Esperadas, h.Cph_Cargadas AS Cargadas, h.Cph_Faltantes AS Faltantes,
           app.FN_CierresParcial_NombreUsuario(h.Usu_Id) AS Usuario,
           h.Cph_Fecha AS Fecha
    FROM app.tbCierresParcialHistorial h
    INNER JOIN app.tbCierresParcial c ON c.Cpa_Id = h.Cpa_Id
    WHERE c.Cpa_Anio = @Anio
    ORDER BY h.Cph_Fecha DESC, h.Cph_Id DESC;
END
GO

/* ───────────────────────────── Escrituras ─────────────────────────────
   Todas reciben quién escribe (@Usuario) y si tiene "Cerrar y publicar parciales" (@PuedeCerrar),
   validan y responden una fila { Cpa_Id, Estado, Publicado }. */

-- Validaciones comunes del período y de quién escribe.
CREATE OR ALTER PROCEDURE app.PR_CierresParcial_ValidarAccion
    @Anio        int,
    @Sem_Id      int,
    @Pac_Id      int,
    @Usuario     int,
    @PuedeCerrar bit
AS
BEGIN
    SET NOCOUNT ON;
    IF ISNULL(@PuedeCerrar, 0) = 0
       OR NOT EXISTS (SELECT 1 FROM seguridad.tbUsuarios WHERE Usu_Id = @Usuario)
        THROW 50071, N'No tiene permiso para cerrar ni publicar parciales.', 1;
    IF @Anio IS NULL OR @Anio NOT BETWEEN 2000 AND 2100
        THROW 50072, N'Elija un año válido.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbSemestres WHERE Sem_Id = @Sem_Id AND ISNULL(Sem_EsEliminado, 0) = 0)
       OR NOT EXISTS (SELECT 1 FROM app.tbParciales WHERE Pac_Id = @Pac_Id AND ISNULL(Pac_EsEliminado, 0) = 0)
        THROW 50072, N'Elija un semestre y un parcial válidos.', 1;
END
GO

CREATE OR ALTER PROCEDURE app.PR_CierresParcial_Cerrar
    @Anio               int,
    @Sem_Id             int,
    @Pac_Id             int,
    @Motivo             nvarchar(600) = NULL,
    @ConfirmarFaltantes bit = 0,
    @Usuario            int,
    @PuedeCerrar        bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');
    EXEC app.PR_CierresParcial_ValidarAccion @Anio, @Sem_Id, @Pac_Id, @Usuario, @PuedeCerrar;
    IF LEN(@Motivo) > 500
        THROW 50073, N'El motivo admite hasta 500 caracteres.', 1;

    -- Foto del avance al cerrar (Skuul guarda el resultado de la revisión en el registro del cierre).
    DECLARE @Esperadas int, @Cargadas int, @Faltantes int;
    SELECT @Esperadas = ISNULL(SUM(Alumnos), 0), @Cargadas = ISNULL(SUM(Cargadas), 0)
    FROM app.FN_CierresParcial_Avance(@Anio, @Sem_Id, @Pac_Id);
    SET @Faltantes = @Esperadas - @Cargadas;

    IF @Faltantes > 0 AND (ISNULL(@ConfirmarFaltantes, 0) = 0 OR @Motivo IS NULL)
    BEGIN
        DECLARE @Aviso nvarchar(300) = CONCAT(N'Faltan ', @Faltantes, N' notas por cargar en este parcial. ',
                                              N'Para cerrarlo igual, confirme que lo cierra con notas faltantes y escriba el motivo.');
        THROW 50074, @Aviso, 1;
    END

    BEGIN TRANSACTION;
        DECLARE @Cpa_Id int, @Estado varchar(10);
        SELECT @Cpa_Id = Cpa_Id, @Estado = Cpa_Estado
        FROM app.tbCierresParcial WITH (UPDLOCK, HOLDLOCK)
        WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem_Id AND Pac_Id = @Pac_Id;

        IF @Estado = 'cerrado'
            THROW 50075, N'Este parcial ya está cerrado. Recargue la página para ver su estado.', 1;

        IF @Cpa_Id IS NULL
        BEGIN
            INSERT INTO app.tbCierresParcial (Cpa_Anio, Sem_Id, Pac_Id, Cpa_Estado, Cpa_FechaCierre, Usu_IdCierre, Cpa_UsuarioRegistra)
            VALUES (@Anio, @Sem_Id, @Pac_Id, 'cerrado', GETDATE(), @Usuario, @Usuario);
            SET @Cpa_Id = SCOPE_IDENTITY();
        END
        ELSE
            UPDATE app.tbCierresParcial
            SET Cpa_Estado = 'cerrado', Cpa_FechaCierre = GETDATE(), Usu_IdCierre = @Usuario,
                Cpa_Publicado = 0, Cpa_FechaPublicacion = NULL, Usu_IdPublicacion = NULL,
                Cpa_UsuarioModifica = @Usuario, Cpa_FechaModifica = GETDATE()
            WHERE Cpa_Id = @Cpa_Id;

        INSERT INTO app.tbCierresParcialHistorial (Cpa_Id, Cph_Accion, Cph_Motivo, Cph_Esperadas, Cph_Cargadas, Cph_Faltantes, Usu_Id)
        VALUES (@Cpa_Id, 'cerrar', @Motivo, @Esperadas, @Cargadas, @Faltantes, @Usuario);
    COMMIT TRANSACTION;

    SELECT @Cpa_Id AS Cpa_Id, CAST('cerrado' AS varchar(10)) AS Estado, CAST(0 AS bit) AS Publicado;
END
GO

CREATE OR ALTER PROCEDURE app.PR_CierresParcial_Publicar
    @Anio        int,
    @Sem_Id      int,
    @Pac_Id      int,
    @Usuario     int,
    @PuedeCerrar bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    EXEC app.PR_CierresParcial_ValidarAccion @Anio, @Sem_Id, @Pac_Id, @Usuario, @PuedeCerrar;

    BEGIN TRANSACTION;
        DECLARE @Cpa_Id int, @Estado varchar(10), @Publicado bit;
        SELECT @Cpa_Id = Cpa_Id, @Estado = Cpa_Estado, @Publicado = Cpa_Publicado
        FROM app.tbCierresParcial WITH (UPDLOCK, HOLDLOCK)
        WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem_Id AND Pac_Id = @Pac_Id;

        IF ISNULL(@Estado, 'abierto') <> 'cerrado'
            THROW 50076, N'Solo se publican los resultados de un parcial cerrado. Ciérrelo primero.', 1;
        IF @Publicado = 1
            THROW 50076, N'Los resultados de este parcial ya están publicados.', 1;

        UPDATE app.tbCierresParcial
        SET Cpa_Publicado = 1, Cpa_FechaPublicacion = GETDATE(), Usu_IdPublicacion = @Usuario,
            Cpa_UsuarioModifica = @Usuario, Cpa_FechaModifica = GETDATE()
        WHERE Cpa_Id = @Cpa_Id;

        INSERT INTO app.tbCierresParcialHistorial (Cpa_Id, Cph_Accion, Usu_Id)
        VALUES (@Cpa_Id, 'publicar', @Usuario);
    COMMIT TRANSACTION;

    SELECT @Cpa_Id AS Cpa_Id, CAST('cerrado' AS varchar(10)) AS Estado, CAST(1 AS bit) AS Publicado;
END
GO

CREATE OR ALTER PROCEDURE app.PR_CierresParcial_Despublicar
    @Anio        int,
    @Sem_Id      int,
    @Pac_Id      int,
    @Motivo      nvarchar(600),
    @Usuario     int,
    @PuedeCerrar bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');
    EXEC app.PR_CierresParcial_ValidarAccion @Anio, @Sem_Id, @Pac_Id, @Usuario, @PuedeCerrar;
    IF @Motivo IS NULL
        THROW 50073, N'Escriba el motivo para retirar la publicación.', 1;
    IF LEN(@Motivo) > 500
        THROW 50073, N'El motivo admite hasta 500 caracteres.', 1;

    BEGIN TRANSACTION;
        DECLARE @Cpa_Id int, @Publicado bit;
        SELECT @Cpa_Id = Cpa_Id, @Publicado = Cpa_Publicado
        FROM app.tbCierresParcial WITH (UPDLOCK, HOLDLOCK)
        WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem_Id AND Pac_Id = @Pac_Id;

        IF ISNULL(@Publicado, 0) = 0
            THROW 50077, N'Los resultados de este parcial no están publicados.', 1;

        UPDATE app.tbCierresParcial
        SET Cpa_Publicado = 0, Cpa_FechaPublicacion = NULL, Usu_IdPublicacion = NULL,
            Cpa_UsuarioModifica = @Usuario, Cpa_FechaModifica = GETDATE()
        WHERE Cpa_Id = @Cpa_Id;

        INSERT INTO app.tbCierresParcialHistorial (Cpa_Id, Cph_Accion, Cph_Motivo, Usu_Id)
        VALUES (@Cpa_Id, 'despublicar', @Motivo, @Usuario);
    COMMIT TRANSACTION;

    SELECT @Cpa_Id AS Cpa_Id, CAST('cerrado' AS varchar(10)) AS Estado, CAST(0 AS bit) AS Publicado;
END
GO

CREATE OR ALTER PROCEDURE app.PR_CierresParcial_Reabrir
    @Anio        int,
    @Sem_Id      int,
    @Pac_Id      int,
    @Motivo      nvarchar(600),
    @Usuario     int,
    @PuedeCerrar bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');
    EXEC app.PR_CierresParcial_ValidarAccion @Anio, @Sem_Id, @Pac_Id, @Usuario, @PuedeCerrar;
    IF @Motivo IS NULL
        THROW 50073, N'Escriba el motivo para reabrir el parcial (qué corrección se autorizó).', 1;
    IF LEN(@Motivo) > 500
        THROW 50073, N'El motivo admite hasta 500 caracteres.', 1;

    BEGIN TRANSACTION;
        DECLARE @Cpa_Id int, @Estado varchar(10), @Publicado bit;
        SELECT @Cpa_Id = Cpa_Id, @Estado = Cpa_Estado, @Publicado = Cpa_Publicado
        FROM app.tbCierresParcial WITH (UPDLOCK, HOLDLOCK)
        WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem_Id AND Pac_Id = @Pac_Id;

        IF ISNULL(@Estado, 'abierto') <> 'cerrado'
            THROW 50078, N'Este parcial ya está abierto. Recargue la página para ver su estado.', 1;

        UPDATE app.tbCierresParcial
        SET Cpa_Estado = 'abierto', Cpa_Publicado = 0, Cpa_FechaPublicacion = NULL, Usu_IdPublicacion = NULL,
            Cpa_UsuarioModifica = @Usuario, Cpa_FechaModifica = GETDATE()
        WHERE Cpa_Id = @Cpa_Id;

        -- Reabrir un parcial publicado también retira la publicación: queda anotado aparte.
        IF @Publicado = 1
            INSERT INTO app.tbCierresParcialHistorial (Cpa_Id, Cph_Accion, Cph_Motivo, Usu_Id)
            VALUES (@Cpa_Id, 'despublicar', N'Al reabrir: ' + LEFT(@Motivo, 487), @Usuario);

        INSERT INTO app.tbCierresParcialHistorial (Cpa_Id, Cph_Accion, Cph_Motivo, Usu_Id)
        VALUES (@Cpa_Id, 'reabrir', @Motivo, @Usuario);
    COMMIT TRANSACTION;

    SELECT @Cpa_Id AS Cpa_Id, CAST('abierto' AS varchar(10)) AS Estado, CAST(0 AS bit) AS Publicado;
END
GO

-- Fechas opcionales de carga de notas (como start_date / stop_date de Skuul). Solo con el parcial abierto.
CREATE OR ALTER PROCEDURE app.PR_CierresParcial_Fechas
    @Anio        int,
    @Sem_Id      int,
    @Pac_Id      int,
    @FechaInicio date = NULL,
    @FechaLimite date = NULL,
    @Usuario     int,
    @PuedeCerrar bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    EXEC app.PR_CierresParcial_ValidarAccion @Anio, @Sem_Id, @Pac_Id, @Usuario, @PuedeCerrar;
    IF @FechaInicio IS NOT NULL AND @FechaLimite IS NOT NULL AND @FechaInicio > @FechaLimite
        THROW 50079, N'La fecha de inicio no puede ser posterior a la fecha límite.', 1;
    IF (@FechaInicio IS NOT NULL AND YEAR(@FechaInicio) NOT BETWEEN @Anio - 1 AND @Anio + 1)
       OR (@FechaLimite IS NOT NULL AND YEAR(@FechaLimite) NOT BETWEEN @Anio - 1 AND @Anio + 1)
        THROW 50079, N'Las fechas deben caer cerca del año del parcial. Revise el año.', 1;

    BEGIN TRANSACTION;
        DECLARE @Cpa_Id int, @Estado varchar(10), @Publicado bit;
        SELECT @Cpa_Id = Cpa_Id, @Estado = Cpa_Estado, @Publicado = Cpa_Publicado
        FROM app.tbCierresParcial WITH (UPDLOCK, HOLDLOCK)
        WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem_Id AND Pac_Id = @Pac_Id;

        IF @Estado = 'cerrado'
            THROW 50079, N'El parcial está cerrado. Reábralo para cambiar sus fechas de carga.', 1;

        IF @Cpa_Id IS NULL
        BEGIN
            INSERT INTO app.tbCierresParcial (Cpa_Anio, Sem_Id, Pac_Id, Cpa_Estado, Cpa_FechaInicio, Cpa_FechaLimite, Cpa_UsuarioRegistra)
            VALUES (@Anio, @Sem_Id, @Pac_Id, 'abierto', @FechaInicio, @FechaLimite, @Usuario);
            SET @Cpa_Id = SCOPE_IDENTITY();
        END
        ELSE
            UPDATE app.tbCierresParcial
            SET Cpa_FechaInicio = @FechaInicio, Cpa_FechaLimite = @FechaLimite,
                Cpa_UsuarioModifica = @Usuario, Cpa_FechaModifica = GETDATE()
            WHERE Cpa_Id = @Cpa_Id;

        INSERT INTO app.tbCierresParcialHistorial (Cpa_Id, Cph_Accion, Cph_Motivo, Usu_Id)
        VALUES (@Cpa_Id, 'fechas',
                CONCAT(N'Carga de notas: ',
                       CASE WHEN @FechaInicio IS NULL THEN N'sin inicio' ELSE N'desde ' + CONVERT(nvarchar(10), @FechaInicio, 103) END,
                       N' · ',
                       CASE WHEN @FechaLimite IS NULL THEN N'sin fecha límite' ELSE N'hasta ' + CONVERT(nvarchar(10), @FechaLimite, 103) END),
                @Usuario);
    COMMIT TRANSACTION;

    SELECT @Cpa_Id AS Cpa_Id, CAST('abierto' AS varchar(10)) AS Estado, CAST(0 AS bit) AS Publicado;
END
GO

/* ───────────────────────────── Permisos ─────────────────────────────
   Cierre de parciales          = ver estado, notas faltantes e historial (admin, director, secretaria)
   Cerrar y publicar parciales  = cerrar, publicar, retirar publicación, reabrir y fechas (admin, director)
   El docente no ve la pantalla: ve el aviso "Cerrado" en su cuaderno de notas. */
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES
    (N'Cierre de parciales',         N'|admin|director|secretaria|'),
    (N'Cerrar y publicar parciales', N'|admin|director|');

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
