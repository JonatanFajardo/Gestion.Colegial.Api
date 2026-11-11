-- =====================================================================
-- Script 057: Rollover (RollForward) de estructura del año lectivo
-- Contexto: arrastra la ESTRUCTURA de un año origen a un año destino
--           como BORRADOR, sin alumnos ni docentes. Espejo del
--           "RollForward" de Skuul.
-- Copia (origen -> destino) saltando lo que ya exista en destino:
--   app.tbPeriodosAnio   (Pan_)  — clave natural: Pan_Nombre
--   app.tbSeccionesAnio  (Sea_)  — clave natural: Niv_Id, Cun_Id, Sec_Id, ISNULL(Mda_Id,0)
--   app.tbOfertasAnio    (Ofa_)  — clave natural: Mat_Id, ISNULL(Cun_Id,0)
-- Reglas:
--   - Las filas nuevas nacen Estado=1 (Borrador), EsEliminado=0, usuario=1.
--   - Fechas desplazadas (@Ani_Destino - @Ani_Origen) años con DATEADD.
--   - Sin docentes: Emp_Id = NULL (secciones y ofertas).
--   - Ofertas: se anulan Sea_Id y Pan_Id (apuntan a filas del año origen).
--   - Re-ejecutable: salta lo que ya exista en destino por su clave natural.
--   - Todo en una transacción (rollback ante error).
-- Parámetros: @Ani_Origen / @Ani_Destino = el AÑO (Ani_Anio), no el Id.
-- Devuelve: SELECT periodos_copiados, secciones_copiadas, ofertas_copiadas.
-- Convención: idempotente (IF EXISTS + DROP/CREATE).
-- =====================================================================

USE [DB_GestionColegial]
GO

IF OBJECT_ID('[app].[PR_tbAnioLectivo_RollForward]') IS NOT NULL
    DROP PROCEDURE [app].[PR_tbAnioLectivo_RollForward]
GO
-- Requerido: tbSeccionesAnio tiene un índice sobre la columna computada
-- Sea_MdaKey, por lo que el SP debe crearse con estas SET options en ON.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [app].[PR_tbAnioLectivo_RollForward]
    @Ani_Origen  INT,   -- Año origen (Ani_Anio), de donde se copia la estructura.
    @Ani_Destino INT    -- Año destino (Ani_Anio), donde se crea el borrador.
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idOrigen  INT = (SELECT TOP 1 Ani_Id FROM [app].[tbAnioLectivo] WHERE Ani_Anio = @Ani_Origen  AND Ani_EsEliminado = 0);
    DECLARE @idDestino INT = (SELECT TOP 1 Ani_Id FROM [app].[tbAnioLectivo] WHERE Ani_Anio = @Ani_Destino AND Ani_EsEliminado = 0);

    IF @idOrigen IS NULL
    BEGIN
        RAISERROR('El año origen (%d) no existe o está eliminado.', 16, 1, @Ani_Origen);
        RETURN;
    END
    IF @idDestino IS NULL
    BEGIN
        RAISERROR('El año destino (%d) no existe o está eliminado.', 16, 1, @Ani_Destino);
        RETURN;
    END
    IF @idOrigen = @idDestino
    BEGIN
        RAISERROR('El año origen y el año destino no pueden ser el mismo.', 16, 1);
        RETURN;
    END

    DECLARE @shift INT = @Ani_Destino - @Ani_Origen;   -- desplazamiento de fechas (años)
    DECLARE @periodos  INT = 0;
    DECLARE @secciones INT = 0;
    DECLARE @ofertas   INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ── Períodos ────────────────────────────────────────────────────
        INSERT INTO [app].[tbPeriodosAnio]
            (Ani_Id, Pan_Nombre, Pan_Tipo, Pan_Orden, Pan_FechaInicio, Pan_FechaFin,
             Pan_Estado, Pan_EsActivo, Pan_EsEliminado, Pan_UsuarioRegistra, Pan_FechaRegistra)
        SELECT
            @idDestino, p.Pan_Nombre, p.Pan_Tipo, p.Pan_Orden,
            CASE WHEN p.Pan_FechaInicio IS NULL THEN NULL ELSE DATEADD(YEAR, @shift, p.Pan_FechaInicio) END,
            CASE WHEN p.Pan_FechaFin    IS NULL THEN NULL ELSE DATEADD(YEAR, @shift, p.Pan_FechaFin)    END,
            1 /*Borrador*/, 1, 0, 1, GETDATE()
        FROM   [app].[tbPeriodosAnio] p
        WHERE  p.Ani_Id = @idOrigen
          AND  p.Pan_EsEliminado = 0
          AND  NOT EXISTS (
                   SELECT 1 FROM [app].[tbPeriodosAnio] d
                   WHERE  d.Ani_Id = @idDestino
                     AND  d.Pan_Nombre = p.Pan_Nombre);
        SET @periodos = @@ROWCOUNT;

        -- ── Secciones (Sea_MdaKey es computada: NO se inserta) ──────────
        INSERT INTO [app].[tbSeccionesAnio]
            (Ani_Id, Niv_Id, Cun_Id, Sec_Id, Mda_Id, Emp_Id, Sea_Nombre, Sea_Cupo,
             Sea_Estado, Sea_EsEliminado, Sea_UsuarioRegistra, Sea_FechaRegistra)
        SELECT
            @idDestino, s.Niv_Id, s.Cun_Id, s.Sec_Id, s.Mda_Id,
            NULL /*sin docente*/, s.Sea_Nombre, s.Sea_Cupo,
            1 /*Borrador*/, 0, 1, GETDATE()
        FROM   [app].[tbSeccionesAnio] s
        WHERE  s.Ani_Id = @idOrigen
          AND  s.Sea_EsEliminado = 0
          AND  NOT EXISTS (
                   SELECT 1 FROM [app].[tbSeccionesAnio] d
                   WHERE  d.Ani_Id = @idDestino
                     AND  d.Niv_Id = s.Niv_Id
                     AND  d.Cun_Id = s.Cun_Id
                     AND  d.Sec_Id = s.Sec_Id
                     AND  ISNULL(d.Mda_Id, 0) = ISNULL(s.Mda_Id, 0));
        SET @secciones = @@ROWCOUNT;

        -- ── Ofertas (dedup por (Mat_Id, ISNULL(Cun_Id,0)); sin docente/sección/período) ──
        ;WITH origen AS (
            SELECT o.Mat_Id, o.Cun_Id, o.Ofa_HorasSemana,
                   ROW_NUMBER() OVER (
                       PARTITION BY o.Mat_Id, ISNULL(o.Cun_Id, 0)
                       ORDER BY o.Ofa_Id) AS rn
            FROM   [app].[tbOfertasAnio] o
            WHERE  o.Ani_Id = @idOrigen
              AND  o.Ofa_EsEliminado = 0
        )
        INSERT INTO [app].[tbOfertasAnio]
            (Ani_Id, Mat_Id, Cun_Id, Sea_Id, Emp_Id, Pan_Id, Ofa_HorasSemana,
             Ofa_Estado, Ofa_EsEliminado, Ofa_UsuarioRegistra, Ofa_FechaRegistra)
        SELECT
            @idDestino, x.Mat_Id, x.Cun_Id,
            NULL /*sin sección*/, NULL /*sin docente*/, NULL /*sin período*/,
            x.Ofa_HorasSemana,
            1 /*Borrador*/, 0, 1, GETDATE()
        FROM   origen x
        WHERE  x.rn = 1
          AND  NOT EXISTS (
                   SELECT 1 FROM [app].[tbOfertasAnio] d
                   WHERE  d.Ani_Id = @idDestino
                     AND  d.Mat_Id = x.Mat_Id
                     AND  ISNULL(d.Cun_Id, 0) = ISNULL(x.Cun_Id, 0));
        SET @ofertas = @@ROWCOUNT;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @msg NVARCHAR(2048) = ERROR_MESSAGE();
        RAISERROR('Error en RollForward: %s', 16, 1, @msg);
        RETURN;
    END CATCH

    SELECT
        @periodos  AS periodos_copiados,
        @secciones AS secciones_copiadas,
        @ofertas   AS ofertas_copiadas;
END
GO
