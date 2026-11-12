/* =============================================================================
   SP: app.spGraduarAlumno
   Proyecto: Archivado de Graduados
   Rama API: feature/graduacion-alumnos
   ----------------------------------------------------------------------------
   Parámetros:
     @Alu_Id     int   -> Id del alumno a graduar.
     @UsuarioId  int   -> Usuario que ejecuta la operación (auditoría).

   ----------------------------------------------------------------------------
   LISTA CANÓNICA DE TABLAS A PURGAR (verdad única — debe coincidir con 00_README.md)
     Descubierta vía: SELECT ... FROM sys.columns WHERE name='Alu_Id'.
     Resultado: 9 tablas tienen Alu_Id en DB_GestionColegial.

     | # | Tabla                          | Política        | Orden |
     |---|--------------------------------|-----------------|-------|
     | 1 | app.tbAsistencia               | DELETE          |   3   |
     | 2 | app.tbDocumentosAlumno         | DELETE          |   5   |
     | 3 | app.tbEncargados_tbAlumnos     | MIGRATE+DELETE  |   6   |
     | 4 | app.tbMatriculas               | DELETE          |   7   |
     | 5 | app.tbMensajes                 | DELETE          |   4   |
     | 6 | app.tbNotas                    | AGGREGATE+DELETE|   2   |
     | 7 | finanza.tbCuentasCobrar        | DELETE (después)|  10   |
     | 8 | finanza.tbPagos                | AGGREGATE+DELETE|   9   |
     | 9 | app.tbAlumnos (padre)          | DELETE final    |  11   |

     Tablas dependientes adicionales (sin Alu_Id pero con FK que bloquea borrado):
       - finanza.tbMoratorias        -> FK a tbCuentasCobrar    -> borrar ANTES (orden 1a)
       - finanza.tbDescuentosAplicados -> FK a tbCuentasCobrar  -> borrar ANTES (orden 1b)
       - finanza.tbPagosDetalle      -> FK a tbPagos            -> borrar ANTES (orden 8)

     Tablas EXCLUIDAS:
       - bitacoras.tbAlumnosHistorial / tbHorarioAlumnosHistorial: SKIP (histórico).
       - app.tbHorarioAlumnos: NO tiene Alu_Id (validado) → no aplica.
       - app.tbPersonas: NO se borra (compartida con encargados / docentes).

   ----------------------------------------------------------------------------
   ESQUEMA DESTINO (confirmado contra DDL 01/02/03):

     app.tbAlumnosGraduados:
       AluGrad_Id (PK identity),
       AluGrad_Identidad, AluGrad_NombreCompleto, AluGrad_FechaNacimiento,
       AluGrad_Sexo, AluGrad_Correo, AluGrad_Telefono,
       AluGrad_NivelEducativo, AluGrad_TituloObtenido,
       AluGrad_AnioIngreso, AluGrad_AnioGraduacion,
       AluGrad_TotalPagado, AluGrad_EncargadosJson, AluGrad_AluIdOriginal,
       AluGrad_FechaArchivo (DEFAULT GETDATE), AluGrad_UsuarioArchivo.

     app.tbBoletinesGraduados:
       BolGrad_Id, AluGrad_Id, BolGrad_Anio,
       BolGrad_NivelEducativo, BolGrad_Grado, BolGrad_Seccion, BolGrad_Materia,
       BolGrad_NotaParcial1..4, BolGrad_NotaFinal, BolGrad_Observaciones,
       BolGrad_FechaArchivo.

     app.tbArchivoGraduadoLog:
       LogArc_Id, LogArc_AluGrad_Id, LogArc_AluIdOriginal,
       LogArc_TablaAfectada, LogArc_Accion (DELETE|MIGRATE|AGGREGATE|SKIP),
       LogArc_RegistrosAfectados, LogArc_Detalle,
       LogArc_FechaEvento, LogArc_UsuarioId.

   ----------------------------------------------------------------------------
   CONFIGURACIÓN:
     -- Nota mínima de aprobación: configurable vía
        app.tbConfiguracion (Con_Clave = 'nota_minima_aprobacion').
        El parámetro @NotaMinimaAprobacion ahora tiene default NULL.
        Si llega NULL, el SP lee el valor desde la tabla de configuración.
        Si la fila tampoco existe, usa el fallback final = 70.
        Esto permite que la API o un job pase un override explícito.

     -- DECISIÓN REQUERIDA: Identificación del "último curso" del nivel.
        Hoy se infiere como MAX(Cun_Orden) por Niv_Id (vía vista
        vCandidatosGraduacion). Si esta heurística no es confiable se debe:
          (a) Agregar bit Cun_EsUltimo en app.tbCursosNiveles, o
          (b) Niv_CursoFinalCun_Id en app.tbNivelesEducativos.

   TODO:
     -- TODO: app.tbAlumnos no expone "AnioIngreso"; hoy se envía NULL.
              Si se quiere capturar, agregar columna en tbAlumnos o derivarla
              del primer YEAR(Not_Año) histórico (caro).
     -- TODO: AluGrad_TituloObtenido no tiene fuente directa en tbAlumnos.
              Hoy se llena con Niv_Descripcion + ' - ' + Cun_Descripcion
              como aproximación. Validar con negocio.
     -- TODO: BolGrad_NotaParcial1..4 requiere mapeo Pac_Id → Parcial 1..4.
              Hoy se hace PIVOT asumiendo que Pac_Id 1..4 corresponden a los
              4 parciales. Confirmar con app.tbParciales.
   ============================================================================= */

IF OBJECT_ID('app.spGraduarAlumno', 'P') IS NOT NULL
    DROP PROCEDURE app.spGraduarAlumno;
GO

CREATE PROCEDURE app.spGraduarAlumno
    @Alu_Id               INT,
    @UsuarioId            INT,
    @NotaMinimaAprobacion DECIMAL(5,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Nota mínima de aprobación: si no se pasa, leer de configuración.
    -- Fallback final = 70 si tampoco existe la fila en app.tbConfiguracion.
    IF @NotaMinimaAprobacion IS NULL
        SELECT @NotaMinimaAprobacion = TRY_CAST(Con_Valor AS DECIMAL(5,2))
        FROM   app.tbConfiguracion
        WHERE  Con_Clave = 'nota_minima_aprobacion';

    IF @NotaMinimaAprobacion IS NULL
        SET @NotaMinimaAprobacion = 70;

    DECLARE @AluGrad_Id        INT;
    DECLARE @Per_Id            INT;
    DECLARE @Per_Identidad     VARCHAR(20);
    DECLARE @NombreCompleto    NVARCHAR(200);
    DECLARE @FechaNac          DATE;
    DECLARE @Sexo              CHAR(1);
    DECLARE @Correo            NVARCHAR(150);
    DECLARE @Telefono          NVARCHAR(20);
    DECLARE @Niv_Id            INT;
    DECLARE @Niv_Descripcion   NVARCHAR(100);
    DECLARE @Cun_Id            INT;
    DECLARE @Cun_Descripcion   NVARCHAR(100);
    DECLARE @Sec_Id            INT;
    DECLARE @Sec_Descripcion   NVARCHAR(50);
    DECLARE @TituloObtenido    NVARCHAR(150);
    DECLARE @AnioIngreso       INT = NULL;            -- TODO: ver TODO arriba
    DECLARE @AnioGrad          INT = YEAR(GETDATE());
    DECLARE @TotalPagado       DECIMAL(18,2);
    DECLARE @EncargadosJson    NVARCHAR(MAX);
    DECLARE @MotivosBloqueo    NVARCHAR(500);
    DECLARE @EstadoValid       NVARCHAR(50);
    DECLARE @Filas             INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        ----------------------------------------------------------------------
        -- 1. VALIDACIONES
        ----------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1 FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id)
        BEGIN
            RAISERROR('El alumno con Id %d no existe.', 16, 1, @Alu_Id);
        END

        IF NOT EXISTS (SELECT 1 FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id AND Est_Id = 1)
        BEGIN
            RAISERROR('El alumno %d no se encuentra Activo y no puede graduarse.', 16, 1, @Alu_Id);
        END

        SELECT  @EstadoValid    = v.EstadoValidacion,
                @MotivosBloqueo = v.MotivosBloqueo
        FROM    app.vCandidatosGraduacion v
        WHERE   v.Alu_Id = @Alu_Id;

        IF @EstadoValid IS NULL
        BEGIN
            RAISERROR('El alumno %d no figura como candidato (no cursa el último curso de su nivel).', 16, 1, @Alu_Id);
        END

        IF @EstadoValid <> N'Cumple'
        BEGIN
            DECLARE @msg NVARCHAR(600) =
                CONCAT('El alumno ', @Alu_Id, ' no cumple los requisitos: ', @MotivosBloqueo);
            RAISERROR(@msg, 16, 1);
        END

        ----------------------------------------------------------------------
        -- 2. CONSTRUIR SNAPSHOT (alumno + persona)
        ----------------------------------------------------------------------
        SELECT
            @Per_Id          = a.Per_Id,
            @Per_Identidad   = p.Per_Identidad,
            @NombreCompleto  = LTRIM(RTRIM(
                                  ISNULL(p.Per_PrimerNombre,'')   + ' ' +
                                  ISNULL(p.Per_SegundoNombre,'')  + ' ' +
                                  ISNULL(p.Per_ApellidoPaterno,'')+ ' ' +
                                  ISNULL(p.Per_ApellidoMaterno,'')
                               )),
            @FechaNac        = p.Per_FechaNacimiento,
            @Sexo            = p.Per_Sexo,
            @Correo          = p.Per_CorreoElectronico,
            @Telefono        = p.Per_Telefono,
            @Niv_Id          = a.Niv_Id,
            @Niv_Descripcion = n.Niv_Descripcion,
            @Cun_Id          = a.Cun_Id,
            @Cun_Descripcion = cn.Cun_Descripcion,
            @Sec_Id          = a.Sec_Id,
            @Sec_Descripcion = s.Sec_Descripcion
        FROM   app.tbAlumnos            a
        INNER JOIN app.tbPersonas       p  ON p.Per_Id  = a.Per_Id
        INNER JOIN app.tbNivelesEducativos n ON n.Niv_Id = a.Niv_Id
        INNER JOIN app.tbCursosNiveles  cn ON cn.Cun_Id = a.Cun_Id
        LEFT  JOIN app.tbSecciones      s  ON s.Sec_Id  = a.Sec_Id
        WHERE  a.Alu_Id = @Alu_Id;

        -- TODO: AluGrad_TituloObtenido: aproximación temporal.
        SET @TituloObtenido = LTRIM(RTRIM(
                                ISNULL(@Niv_Descripcion,'') + ' - ' +
                                ISNULL(@Cun_Descripcion,'')
                              ));

        -- AGGREGATE: total pagado por el alumno (pagos no eliminados).
        SELECT @TotalPagado = ISNULL(SUM(pg.Pag_MontoTotal), 0)
        FROM   finanza.tbPagos pg
        WHERE  pg.Alu_Id = @Alu_Id AND pg.Pag_EsEliminado = 0;

        -- MIGRATE: encargados serializados como JSON.
        SET @EncargadosJson = (
            SELECT  ea.Enc_Id           AS encargadoId,
                    e.Per_Id            AS personaId,
                    pe.Per_Identidad    AS identidad,
                    LTRIM(RTRIM(
                        ISNULL(pe.Per_PrimerNombre,'')   + ' ' +
                        ISNULL(pe.Per_ApellidoPaterno,'')
                    ))                  AS nombre,
                    pe.Per_Telefono     AS telefono,
                    pe.Per_CorreoElectronico AS correo,
                    par.Par_Descripcion AS parentesco
            FROM    app.tbEncargados_tbAlumnos ea
            INNER JOIN app.tbEncargados        e   ON e.Enc_Id  = ea.Enc_Id
            INNER JOIN app.tbPersonas          pe  ON pe.Per_Id = e.Per_Id
            LEFT  JOIN app.tbParentescos       par ON par.Par_Id = ea.Par_Id
            WHERE   ea.Alu_Id = @Alu_Id
            FOR JSON PATH
        );

        ----------------------------------------------------------------------
        -- 3. INSERT EN app.tbAlumnosGraduados (snapshot)
        ----------------------------------------------------------------------
        INSERT INTO app.tbAlumnosGraduados
            (AluGrad_Identidad, AluGrad_NombreCompleto, AluGrad_FechaNacimiento,
             AluGrad_Sexo, AluGrad_Correo, AluGrad_Telefono,
             AluGrad_NivelEducativo, AluGrad_TituloObtenido,
             AluGrad_AnioIngreso, AluGrad_AnioGraduacion,
             AluGrad_TotalPagado, AluGrad_EncargadosJson,
             AluGrad_AluIdOriginal, AluGrad_UsuarioArchivo)
        VALUES
            (@Per_Identidad, @NombreCompleto, @FechaNac,
             @Sexo, @Correo, @Telefono,
             @Niv_Descripcion, @TituloObtenido,
             @AnioIngreso, @AnioGrad,
             @TotalPagado, @EncargadosJson,
             @Alu_Id, @UsuarioId);

        SET @AluGrad_Id = SCOPE_IDENTITY();

        ----------------------------------------------------------------------
        -- 4. AGGREGATE: consolidar notas en app.tbBoletinesGraduados
        --    PIVOT por (Mat_Id, YEAR(Not_Año)) sobre Pac_Id 1..4.
        --    TODO: confirmar que Pac_Id 1..4 son los parciales reales.
        ----------------------------------------------------------------------
        ;WITH NotasPivot AS
        (
            SELECT  n.Mat_Id,
                    YEAR(n.Not_Año) AS Anio,
                    n.Pac_Id,
                    AVG(CAST(n.Not_Nota AS DECIMAL(5,2))) AS Nota
            FROM    app.tbNotas n
            WHERE   n.Alu_Id = @Alu_Id
              AND   n.Not_EsEliminado = 0
            GROUP BY n.Mat_Id, YEAR(n.Not_Año), n.Pac_Id
        )
        INSERT INTO app.tbBoletinesGraduados
            (AluGrad_Id, BolGrad_Anio, BolGrad_NivelEducativo,
             BolGrad_Grado, BolGrad_Seccion, BolGrad_Materia,
             BolGrad_NotaParcial1, BolGrad_NotaParcial2,
             BolGrad_NotaParcial3, BolGrad_NotaParcial4,
             BolGrad_NotaFinal, BolGrad_Observaciones)
        SELECT
            @AluGrad_Id,
            piv.Anio,
            @Niv_Descripcion,
            @Cun_Descripcion,
            @Sec_Descripcion,
            m.Mat_Nombre,
            MAX(CASE WHEN piv.Pac_Id = 1 THEN piv.Nota END) AS P1,
            MAX(CASE WHEN piv.Pac_Id = 2 THEN piv.Nota END) AS P2,
            MAX(CASE WHEN piv.Pac_Id = 3 THEN piv.Nota END) AS P3,
            MAX(CASE WHEN piv.Pac_Id = 4 THEN piv.Nota END) AS P4,
            AVG(piv.Nota) AS NotaFinal,
            NULL
        FROM   NotasPivot piv
        LEFT  JOIN app.tbMaterias m ON m.Mat_Id = piv.Mat_Id
        GROUP BY piv.Mat_Id, piv.Anio, m.Mat_Nombre;

        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_Detalle, LogArc_UsuarioId)
        VALUES
            (@AluGrad_Id, @Alu_Id, 'app.tbBoletinesGraduados',
             'AGGREGATE', @Filas, N'Consolidación de notas por materia/año/parcial.', @UsuarioId);

        ----------------------------------------------------------------------
        -- 5. PURGA DE DEPENDENCIAS (orden por FKs)
        ----------------------------------------------------------------------

        -- 5.1 Finanzas - hijas de tbCuentasCobrar y tbPagos (cascade-aware).
        DELETE m
        FROM   finanza.tbMoratorias m
        INNER JOIN finanza.tbCuentasCobrar cc ON cc.Cco_Id = m.Cco_Id
        WHERE  cc.Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'finanza.tbMoratorias', 'DELETE', @Filas, @UsuarioId);

        DELETE da
        FROM   finanza.tbDescuentosAplicados da
        INNER JOIN finanza.tbCuentasCobrar cc ON cc.Cco_Id = da.Cco_Id
        WHERE  cc.Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'finanza.tbDescuentosAplicados', 'DELETE', @Filas, @UsuarioId);

        DELETE pd
        FROM   finanza.tbPagosDetalle pd
        INNER JOIN finanza.tbPagos pg ON pg.Pag_Id = pd.Pag_Id
        WHERE  pg.Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'finanza.tbPagosDetalle', 'DELETE', @Filas, @UsuarioId);

        -- 5.2 Pagos (ya agregados a AluGrad_TotalPagado).
        DELETE FROM finanza.tbPagos WHERE Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_Detalle, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'finanza.tbPagos', 'AGGREGATE', @Filas,
                CONCAT(N'Total agregado a AluGrad_TotalPagado=', @TotalPagado), @UsuarioId);

        -- 5.3 Cuentas por cobrar (saldo ya validado en 0).
        DELETE FROM finanza.tbCuentasCobrar WHERE Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'finanza.tbCuentasCobrar', 'DELETE', @Filas, @UsuarioId);

        -- 5.4 Notas (ya consolidadas en tbBoletinesGraduados).
        DELETE FROM app.tbNotas WHERE Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'app.tbNotas', 'DELETE', @Filas, @UsuarioId);

        -- 5.5 Asistencia.
        DELETE FROM app.tbAsistencia WHERE Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'app.tbAsistencia', 'DELETE', @Filas, @UsuarioId);

        -- 5.6 Mensajes.
        DELETE FROM app.tbMensajes WHERE Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'app.tbMensajes', 'DELETE', @Filas, @UsuarioId);

        -- 5.7 Documentos del alumno.
        DELETE FROM app.tbDocumentosAlumno WHERE Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'app.tbDocumentosAlumno', 'DELETE', @Filas, @UsuarioId);

        -- 5.8 Encargados-Alumno (ya migrados a EncargadosJson).
        DELETE FROM app.tbEncargados_tbAlumnos WHERE Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'app.tbEncargados_tbAlumnos', 'MIGRATE', @Filas, @UsuarioId);

        -- 5.9 Matrículas.
        DELETE FROM app.tbMatriculas WHERE Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'app.tbMatriculas', 'DELETE', @Filas, @UsuarioId);

        -- 5.10 Alumno (padre).
        DELETE FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'app.tbAlumnos', 'DELETE', @Filas, @UsuarioId);

        -- NOTA: app.tbPersonas NO se elimina (compartida con encargados/docentes).
        -- NOTA: bitacoras.tbAlumnosHistorial / tbHorarioAlumnosHistorial: SKIP.

        COMMIT TRANSACTION;

        SELECT @AluGrad_Id AS AluGrad_Id, 'OK' AS Resultado;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;

        -- Log de error best-effort (fuera de la transacción que ya rodó back).
        BEGIN TRY
            INSERT INTO app.tbArchivoGraduadoLog
                (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
                 LogArc_Accion, LogArc_RegistrosAfectados, LogArc_Detalle, LogArc_UsuarioId)
            VALUES
                (NULL, @Alu_Id, '(error)', 'SKIP', 0,
                 CONCAT(N'ERROR: ', ERROR_MESSAGE()), @UsuarioId);
        END TRY
        BEGIN CATCH
            -- Si el log también falla, lo ignoramos para no enmascarar el error original.
        END CATCH;

        THROW;
    END CATCH;
END;
GO
