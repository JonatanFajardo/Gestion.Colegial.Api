-- =====================================================================
-- Script 030: SPs para Dev Tools — Sincronizador de Fechas paso a paso
--   dbo.PR_ActualizarFechas_Detectar   - calcula delta sin escribir
--   dbo.PR_ActualizarFechas_Paso       - desplaza UNA tabla
--   dbo.PR_DevTools_EstadoBD           - snapshot del estado de la BD
-- =====================================================================

USE [DB_GestionColegial];
GO

IF OBJECT_ID('dbo.PR_ActualizarFechas_Detectar') IS NOT NULL DROP PROCEDURE dbo.PR_ActualizarFechas_Detectar;
GO
IF OBJECT_ID('dbo.PR_ActualizarFechas_Paso')     IS NOT NULL DROP PROCEDURE dbo.PR_ActualizarFechas_Paso;
GO
IF OBJECT_ID('dbo.PR_DevTools_EstadoBD')         IS NOT NULL DROP PROCEDURE dbo.PR_DevTools_EstadoBD;
GO

-- ---------------------------------------------------------------------
-- Devuelve el delta entre el año actual de la data y el objetivo.
-- ---------------------------------------------------------------------
CREATE PROCEDURE dbo.PR_ActualizarFechas_Detectar
    @AnioObjetivo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @AnioObjetivo IS NULL SET @AnioObjetivo = YEAR(GETDATE());

    DECLARE @AnioActual INT = (SELECT MAX(YEAR(Pag_FechaPago)) FROM finanza.tbPagos);
    IF @AnioActual IS NULL SET @AnioActual = (SELECT MAX(AnioCursado) FROM app.tbAlumnos);
    IF @AnioActual IS NULL SET @AnioActual = @AnioObjetivo;

    SELECT
        @AnioActual                                  AS AnioActual,
        @AnioObjetivo                                AS AnioObjetivo,
        (@AnioObjetivo - @AnioActual)                AS Delta,
        CAST(CASE WHEN @AnioObjetivo = @AnioActual THEN 1 ELSE 0 END AS BIT) AS Sincronizado;
END
GO

-- ---------------------------------------------------------------------
-- Ejecuta el UPDATE de UNA tabla por delta. Devuelve filas afectadas y duración (ms).
-- @Tabla: identificador lógico (no nombre real) — se valida con CASE.
-- ---------------------------------------------------------------------
CREATE PROCEDURE dbo.PR_ActualizarFechas_Paso
    @Tabla NVARCHAR(100),
    @Delta INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @start  DATETIME2 = SYSDATETIME();
    DECLARE @rows   INT       = 0;

    IF @Delta = 0
    BEGIN
        SELECT @Tabla AS Tabla, 0 AS RowsAffected, 0 AS DurationMs, CAST(1 AS BIT) AS Skipped;
        RETURN;
    END

    IF @Tabla = 'finanza.tbPagos'
    BEGIN
        UPDATE finanza.tbPagos SET Pag_FechaPago = DATEADD(YEAR, @Delta, Pag_FechaPago);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'finanza.tbCuentasCobrar'
    BEGIN
        UPDATE finanza.tbCuentasCobrar
        SET Cco_FechaEmision = DATEADD(YEAR, @Delta, Cco_FechaEmision),
            Cco_FechaVencimiento = DATEADD(YEAR, @Delta, Cco_FechaVencimiento);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'finanza.tbArqueosCaja'
    BEGIN
        UPDATE finanza.tbArqueosCaja SET Arq_Fecha = DATEADD(YEAR, @Delta, Arq_Fecha);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'finanza.tbMoratorias'
    BEGIN
        UPDATE finanza.tbMoratorias SET Mor_FechaCalculo = DATEADD(YEAR, @Delta, Mor_FechaCalculo);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'finanza.tbRecibos'
    BEGIN
        UPDATE finanza.tbRecibos SET Rec_FechaEmision = DATEADD(YEAR, @Delta, Rec_FechaEmision);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'finanza.tbCuentasCobrarHistorial'
    BEGIN
        UPDATE finanza.tbCuentasCobrarHistorial SET Cgh_Fecha = DATEADD(YEAR, @Delta, Cgh_Fecha);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'finanza.tbPagosHistorial'
    BEGIN
        UPDATE finanza.tbPagosHistorial SET Pgh_Fecha = DATEADD(YEAR, @Delta, Pgh_Fecha);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'app.tbAsistencia'
    BEGIN
        UPDATE app.tbAsistencia SET Asi_Fecha = DATEADD(YEAR, @Delta, Asi_Fecha);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'app.tbAsistenciaEmpleados'
    BEGIN
        UPDATE app.tbAsistenciaEmpleados SET AsiEmp_Fecha = DATEADD(YEAR, @Delta, AsiEmp_Fecha);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'app.tbNotas'
    BEGIN
        UPDATE app.tbNotas SET Not_Año = DATEADD(YEAR, @Delta, Not_Año);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'app.tbTareas'
    BEGIN
        UPDATE app.tbTareas SET Tar_FechaEntrega = DATEADD(YEAR, @Delta, Tar_FechaEntrega);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'app.tbDocumentosAlumno'
    BEGIN
        UPDATE app.tbDocumentosAlumno SET Doa_FechaEntrega = DATEADD(YEAR, @Delta, Doa_FechaEntrega);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'app.tbVacaciones'
    BEGIN
        UPDATE app.tbVacaciones
        SET Vac_FechaInicio = DATEADD(YEAR, @Delta, Vac_FechaInicio),
            Vac_FechaFin = DATEADD(YEAR, @Delta, Vac_FechaFin);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'app.tbAnuncios'
    BEGIN
        UPDATE app.tbAnuncios
        SET Anu_FechaPublicacion = DATEADD(YEAR, @Delta, Anu_FechaPublicacion),
            Anu_FechaExpiracion = DATEADD(YEAR, @Delta, Anu_FechaExpiracion);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'app.tbMensajes'
    BEGIN
        UPDATE app.tbMensajes SET Msg_FechaEnvio = DATEADD(YEAR, @Delta, Msg_FechaEnvio);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'app.tbNotificaciones'
    BEGIN
        UPDATE app.tbNotificaciones
        SET Not_FechaEnvio = DATEADD(YEAR, @Delta, Not_FechaEnvio),
            Not_FechaLectura = DATEADD(YEAR, @Delta, Not_FechaLectura);
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'bitacoras.tbAlumnosHistorial'
    BEGIN
        UPDATE bitacoras.tbAlumnosHistorial SET AnioCursado = AnioCursado + @Delta;
        SET @rows = @@ROWCOUNT;
    END
    ELSE IF @Tabla = 'app.tbAlumnos'
    BEGIN
        UPDATE app.tbAlumnos SET AnioCursado = AnioCursado + @Delta;
        SET @rows = @@ROWCOUNT;
    END
    ELSE
    BEGIN
        RAISERROR('Tabla no soportada: %s', 16, 1, @Tabla);
        RETURN;
    END

    SELECT
        @Tabla                                       AS Tabla,
        @rows                                        AS RowsAffected,
        DATEDIFF(MILLISECOND, @start, SYSDATETIME()) AS DurationMs,
        CAST(0 AS BIT)                               AS Skipped;
END
GO

-- ---------------------------------------------------------------------
-- Snapshot del estado actual de la BD (para la card "Estado BD").
-- Devuelve métricas en una sola fila.
-- ---------------------------------------------------------------------
CREATE PROCEDURE dbo.PR_DevTools_EstadoBD
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT COUNT(*) FROM app.tbAlumnos)                              AS TotalAlumnos,
        (SELECT COUNT(*) FROM app.tbEmpleados)                            AS TotalEmpleados,
        (SELECT COUNT(*) FROM Seguridad.tbUsuarios WHERE Usu_EsEliminado = 0) AS TotalUsuarios,
        (SELECT COUNT(*) FROM Seguridad.tbRoles WHERE Rol_EsEliminado = 0)    AS TotalRoles,
        (SELECT COUNT(*) FROM Seguridad.tbPantallas WHERE Pan_EsEliminado = 0) AS TotalPantallas,
        (SELECT COUNT(*) FROM Seguridad.tbSesiones WHERE Ses_FechaCierre IS NULL) AS SesionesActivas,
        (SELECT COUNT(*) FROM finanza.tbPagos)                            AS TotalPagos,
        (SELECT ISNULL(SUM(Pag_MontoTotal), 0) FROM finanza.tbPagos
            WHERE YEAR(Pag_FechaPago) = YEAR(GETDATE()))                  AS MontoPagadoAnioActual,
        (SELECT COUNT(*) FROM finanza.tbCuentasCobrar
            WHERE Cco_MontoPendiente > 0)                                 AS CuentasPendientes,
        (SELECT MAX(AnioCursado) FROM app.tbAlumnos)                      AS AnioActualData,
        YEAR(GETDATE())                                                   AS AnioActualSistema;
END
GO

PRINT 'Script 030 OK: SPs Dev Tools creados.';
GO
