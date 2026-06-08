-- =====================================================================
-- Script 029: Renombra dbo.ACTUALIZARDATOS → dbo.PR_ActualizarFechas
--             y unifica todo el desplazamiento de fechas en un solo SP.
-- Idempotente: si el año de la data ya coincide con el objetivo, no hace nada.
-- =====================================================================

USE [DB_GestionColegial];
GO

IF OBJECT_ID('dbo.ACTUALIZARDATOS') IS NOT NULL
    DROP PROCEDURE dbo.ACTUALIZARDATOS;
GO

IF OBJECT_ID('dbo.PR_ActualizarFechas') IS NOT NULL
    DROP PROCEDURE dbo.PR_ActualizarFechas;
GO

-- ---------------------------------------------------------------------
-- dbo.PR_ActualizarFechas
-- Desplaza TODAS las fechas operativas del sistema en N años para que
-- la data luzca "actual" en cualquier momento del futuro.
--
-- @AnioObjetivo:
--   NULL   = año actual del servidor (YEAR(GETDATE()))
--   <int>  = año específico (útil para regresar a un punto en el pasado)
--
-- Detección del año fuente: MAX(YEAR) de finanza.tbPagos (fuente más fiable).
-- Si delta = 0, no hace nada.
-- ---------------------------------------------------------------------
CREATE PROCEDURE dbo.PR_ActualizarFechas
    @AnioObjetivo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @AnioObjetivo IS NULL
        SET @AnioObjetivo = YEAR(GETDATE());

    -- Año de referencia tomado de tbPagos (la tabla con más data temporal)
    DECLARE @AnioActual INT = (SELECT MAX(YEAR(Pag_FechaPago)) FROM finanza.tbPagos);
    IF @AnioActual IS NULL
        SET @AnioActual = (SELECT MAX(AnioCursado) FROM app.tbAlumnos);
    IF @AnioActual IS NULL
    BEGIN
        PRINT 'Sin datos para inferir año actual. Abortando.';
        RETURN;
    END

    DECLARE @Delta INT = @AnioObjetivo - @AnioActual;

    IF @Delta = 0
    BEGIN
        PRINT 'La data ya está en ' + CAST(@AnioObjetivo AS VARCHAR) + '. Nada que hacer.';
        RETURN;
    END

    PRINT 'Desplazando data ' + CAST(@Delta AS VARCHAR) + ' año(s): ' +
          CAST(@AnioActual AS VARCHAR) + ' -> ' + CAST(@AnioObjetivo AS VARCHAR);

    -- ===== Finanza =====
    UPDATE finanza.tbPagos              SET Pag_FechaPago        = DATEADD(YEAR, @Delta, Pag_FechaPago);
    UPDATE finanza.tbCuentasCobrar      SET Cco_FechaEmision     = DATEADD(YEAR, @Delta, Cco_FechaEmision),
                                            Cco_FechaVencimiento = DATEADD(YEAR, @Delta, Cco_FechaVencimiento);
    UPDATE finanza.tbArqueosCaja        SET Arq_Fecha            = DATEADD(YEAR, @Delta, Arq_Fecha);
    UPDATE finanza.tbMoratorias         SET Mor_FechaCalculo     = DATEADD(YEAR, @Delta, Mor_FechaCalculo);
    UPDATE finanza.tbRecibos            SET Rec_FechaEmision     = DATEADD(YEAR, @Delta, Rec_FechaEmision);
    UPDATE finanza.tbCuentasCobrarHistorial SET Cgh_Fecha        = DATEADD(YEAR, @Delta, Cgh_Fecha);
    UPDATE finanza.tbPagosHistorial     SET Pgh_Fecha            = DATEADD(YEAR, @Delta, Pgh_Fecha);

    -- ===== Académico / Operativo =====
    UPDATE app.tbAsistencia             SET Asi_Fecha            = DATEADD(YEAR, @Delta, Asi_Fecha);
    UPDATE app.tbAsistenciaEmpleados    SET AsiEmp_Fecha         = DATEADD(YEAR, @Delta, AsiEmp_Fecha);
    UPDATE app.tbNotas                  SET Not_Año              = DATEADD(YEAR, @Delta, Not_Año);
    UPDATE app.tbTareas                 SET Tar_FechaEntrega     = DATEADD(YEAR, @Delta, Tar_FechaEntrega);
    UPDATE app.tbDocumentosAlumno       SET Doa_FechaEntrega     = DATEADD(YEAR, @Delta, Doa_FechaEntrega);
    UPDATE app.tbVacaciones             SET Vac_FechaInicio      = DATEADD(YEAR, @Delta, Vac_FechaInicio),
                                            Vac_FechaFin         = DATEADD(YEAR, @Delta, Vac_FechaFin);
    UPDATE app.tbAnuncios               SET Anu_FechaPublicacion = DATEADD(YEAR, @Delta, Anu_FechaPublicacion),
                                            Anu_FechaExpiracion  = DATEADD(YEAR, @Delta, Anu_FechaExpiracion);
    UPDATE app.tbMensajes               SET Msg_FechaEnvio       = DATEADD(YEAR, @Delta, Msg_FechaEnvio);
    UPDATE app.tbNotificaciones         SET Not_FechaEnvio       = DATEADD(YEAR, @Delta, Not_FechaEnvio),
                                            Not_FechaLectura     = DATEADD(YEAR, @Delta, Not_FechaLectura);

    -- ===== Historial alumnos =====
    -- Desplaza cada año por @Delta para que coincida con tbAlumnos
    UPDATE bitacoras.tbAlumnosHistorial SET AnioCursado          = AnioCursado + @Delta;

    -- ===== Año académico de alumnos =====
    UPDATE app.tbAlumnos                SET AnioCursado          = @AnioObjetivo;

    PRINT 'Desplazamiento completado.';
END
GO

PRINT 'Script 029 OK: dbo.PR_ActualizarFechas creado (reemplaza ACTUALIZARDATOS).';
GO
