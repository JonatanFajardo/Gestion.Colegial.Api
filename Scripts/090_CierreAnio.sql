/* =============================================================================
   090 · Cierre del año escolar   (requiere 052-059, 065, 075 y 089)
   Espejo de Skuul (AcademicPeriodStatus + ChangeAcademicPeriodStatus + ClosureReadinessCheck:
   "Abierto → Cerrando → Cerrado → Archivado", el cierre guarda la revisión que se hizo y reabrir
   pide motivo) y de RosarioSIS (calificación final del año y "siguiente grado / repetir / no
   inscribir" por alumno antes del rollover).

   Flujo (asistente de Dirección, pantalla "Cierre del año"):
     1. Revisión      : qué falta antes de cerrar (parciales sin cerrar o sin publicar, notas
                        faltantes, secciones sin docente guía, alumnos sin inscripción del año...).
                        "Iniciar el cierre" pasa el año a Cerrando (4).
     2. Resultados    : por alumno y materia, promedio anual de los parciales PUBLICADOS. La nota
                        final es ese promedio redondeado al entero. Aprueba con la nota mínima del
                        nivel; quien reprueba hasta el máximo de materias del nivel va a
                        recuperación (si aprueba la recuperación, la nota final es la de la
                        recuperación); con más materias reprobadas, repite. Reglas por año y nivel
                        (app.tbCierreAnioReglas). Valor inicial de la nota mínima: el inicio del
                        primer rango que aprueba en la Escala de notas (hoy 70, el mínimo que usa
                        Honduras); si no hay escala, 70. Máximo inicial de materias en
                        recuperación: 2. Se pueden cambiar mientras el año no esté cerrado.
     3. Decisiones    : por alumno, propuesta automática (promovido / repite / se gradúa si cursa
                        el último grado de su nivel / pendiente de recuperación) que Dirección
                        cambia con motivo. Al confirmar una sección: la matrícula del año
                        (app.tbMatriculaAnio) queda Promovido / Repite / Graduado y, si existe el
                        año siguiente, se inscribe al alumno con app.PR_tbMatriculaAnio_Enroll en la
                        sección equivalente del grado que le toca (o sin sección si no existe). Los
                        resultados de los alumnos confirmados quedan congelados. La pantalla de
                        Graduación toma la decisión confirmada (app.vCandidatosGraduacion).
     4. Cerrar        : el año pasa a Cerrado (5). Si la revisión tiene algo que bloquea, solo se
                        cierra con "cerrar de todos modos" y motivo; la revisión queda guardada en
                        el historial. Opcional: el año de trabajo pasa al siguiente; eso lo hace el
                        ADM con la activación normal de Años lectivos (API AniosLectivos/SetActivoAsync),
                        no este script.
   Año Cerrado o Archivado = solo lectura en el servidor:
     - notas y actividades del cuaderno: app.PR_CierresParcial_ValidarAbierto (script 075, la llaman
       todos los que escriben notas) ahora también rechaza años cerrados (THROW 50070, el número que esos
       procedimientos ya devuelven como "cerrado");
     - acciones de Cierre de parciales del año: app.PR_CierresParcial_ValidarAccion;
     - el cuaderno de actividades se muestra cerrado: app.FN_Evaluacion_Cerrado (script 089);
     - pase de lista, tareas y entregas: disparadores sobre app.tbAsistencia, app.tbTareas y
       app.tbEntregasTarea (insertar o cambiar; el borrado del archivo de graduados sigue igual).
   Reabrir (Cerrado → Cerrando) solo con el permiso "Reabrir el año escolar" y motivo. Archivado:
   solo lectura y fuera de los selectores de año del ADM; no vuelve atrás.
   Historial de cada paso: app.tbAnioLectivoHistorial (acción, estados, motivo, usuario, revisión).

   Objetos existentes que se cambian (misma firma; fuera de lo dicho, el mismo comportamiento):
     app.PR_CierresParcial_ValidarAbierto, app.PR_CierresParcial_ValidarAccion (075),
     app.FN_Evaluacion_Cerrado (089),
     app.PR_tbAnioLectivo_Update   : no cambia el estado de un año en cierre, cerrado o archivado
                                     ni lleva un año a esos estados (eso lo hace este asistente),
     app.PR_tbAnioLectivo_SetActivo: un año archivado no puede ser el año de trabajo,
     app.PR_tbAnioLectivo_Delete   : no da de baja un año en cierre, cerrado o archivado,
     app.vCandidatosGraduacion     : con decisión confirmada en el cierre, la decisión manda sobre
                                     el promedio de notas (sin decisión, igual que antes),
     app.spGraduarAlumno           : archiva y quita la matrícula por año (app.tbMatriculaAnio) en
                                     vez de la tabla vacía app.tbMatriculas.
   Permisos:
     Cierre del año          = ver el asistente, resultados, decisiones e historial (admin, director, secretaria)
     Cerrar el año           = iniciar el cierre, calcular, recuperaciones, decidir, confirmar,
                               cerrar y archivar (admin, director)
     Reabrir el año escolar  = reabrir un año cerrado (solo admin; se asigna a otro rol a propósito)
   Prefijos: Alh_ (historial), Cnr_ (reglas), Rea_ (resultados), Pra_ (decisiones). Errores 50090-50099.
   Idempotente: se puede correr varias veces.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ───────────────────────────── Tablas ───────────────────────────── */

IF OBJECT_ID(N'app.tbAnioLectivoHistorial', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbAnioLectivoHistorial
    (
        Alh_Id             int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbAnioLectivoHistorial PRIMARY KEY,
        Ani_Id             int           NOT NULL CONSTRAINT FK_tbAnioLectivoHistorial_Anio REFERENCES app.tbAnioLectivo (Ani_Id),
        Alh_Accion         varchar(20)   NOT NULL,
        Alh_EstadoAnterior tinyint       NULL,
        Alh_EstadoNuevo    tinyint       NULL,
        Alh_Motivo         nvarchar(500) NULL,
        Alh_Detalle        nvarchar(300) NULL,
        Alh_Forzado        bit           NOT NULL CONSTRAINT DF_tbAnioLectivoHistorial_Forzado DEFAULT (0),
        Alh_Revision       nvarchar(max) NULL,
        Usu_Id             int           NULL,
        Alh_Fecha          datetime      NOT NULL CONSTRAINT DF_tbAnioLectivoHistorial_Fecha DEFAULT (GETDATE())
    );
    CREATE INDEX IX_tbAnioLectivoHistorial_Anio ON app.tbAnioLectivoHistorial (Ani_Id, Alh_Fecha DESC);
END
GO

IF OBJECT_ID(N'app.tbCierreAnioReglas', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbCierreAnioReglas
    (
        Cnr_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbCierreAnioReglas PRIMARY KEY,
        Ani_Id              int          NOT NULL CONSTRAINT FK_tbCierreAnioReglas_Anio REFERENCES app.tbAnioLectivo (Ani_Id),
        Niv_Id              int          NOT NULL CONSTRAINT FK_tbCierreAnioReglas_Nivel REFERENCES app.tbNivelesEducativos (Niv_Id),
        Cnr_NotaMinima      decimal(5,2) NOT NULL,
        Cnr_MaxRecuperacion tinyint      NOT NULL,
        Cnr_UsuarioModifica int          NULL,
        Cnr_FechaModifica   datetime     NOT NULL CONSTRAINT DF_tbCierreAnioReglas_Fecha DEFAULT (GETDATE()),
        CONSTRAINT UQ_tbCierreAnioReglas UNIQUE (Ani_Id, Niv_Id),
        CONSTRAINT CK_tbCierreAnioReglas_Nota CHECK (Cnr_NotaMinima BETWEEN 1 AND 100),
        CONSTRAINT CK_tbCierreAnioReglas_Max CHECK (Cnr_MaxRecuperacion BETWEEN 0 AND 20)
    );
END
GO

-- Resultados finales por alumno y materia. Sin llave hacia app.tbAlumnos a propósito: es la foto del año
-- (con nombre, sección y materia guardados) y sobrevive al archivo de graduados.
IF OBJECT_ID(N'app.tbResultadosAnio', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbResultadosAnio
    (
        Rea_Id                 int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbResultadosAnio PRIMARY KEY,
        Ani_Id                 int           NOT NULL CONSTRAINT FK_tbResultadosAnio_Anio REFERENCES app.tbAnioLectivo (Ani_Id),
        Alu_Id                 int           NOT NULL,
        Mat_Id                 int           NOT NULL,
        Sea_Id                 int           NULL,
        Niv_Id                 int           NULL,
        Cun_Id                 int           NULL,
        Sec_Id                 int           NULL,
        Mda_Id                 int           NULL,
        Cur_Id                 int           NULL,
        Rea_Alumno             nvarchar(200) NULL,
        Rea_Identidad          varchar(30)   NULL,
        Rea_Materia            nvarchar(150) NULL,
        Rea_Seccion            varchar(100)  NULL,
        Rea_Grado              varchar(100)  NULL,
        Rea_PeriodosEsperados  tinyint       NOT NULL CONSTRAINT DF_tbResultadosAnio_PerEsp DEFAULT (0),
        Rea_PeriodosConNota    tinyint       NOT NULL CONSTRAINT DF_tbResultadosAnio_PerNota DEFAULT (0),
        Rea_Promedio           decimal(5,2)  NULL,
        Rea_NotaRecuperacion   decimal(5,2)  NULL,
        Rea_NotaFinal          decimal(5,2)  NULL,
        Rea_Resultado          varchar(12)   NOT NULL CONSTRAINT DF_tbResultadosAnio_Resultado DEFAULT ('sin_notas'),
        Rea_AproboRecuperacion bit           NULL,
        Rea_Concepto           nvarchar(40)  NULL,
        Rea_UsuarioRecuperacion int          NULL,
        Rea_FechaRecuperacion  datetime      NULL,
        Rea_EsEliminado        bit           NOT NULL CONSTRAINT DF_tbResultadosAnio_EsEliminado DEFAULT (0),
        Rea_UsuarioCalculo     int           NULL,
        Rea_FechaCalculo       datetime      NOT NULL CONSTRAINT DF_tbResultadosAnio_FechaCalculo DEFAULT (GETDATE()),
        CONSTRAINT UQ_tbResultadosAnio UNIQUE (Ani_Id, Alu_Id, Mat_Id),
        CONSTRAINT CK_tbResultadosAnio_Resultado CHECK (Rea_Resultado IN ('aprobado', 'recuperacion', 'reprobado', 'sin_notas')),
        CONSTRAINT CK_tbResultadosAnio_Recuperacion CHECK (Rea_NotaRecuperacion IS NULL OR Rea_NotaRecuperacion BETWEEN 0 AND 100)
    );
    CREATE INDEX IX_tbResultadosAnio_Seccion ON app.tbResultadosAnio (Ani_Id, Sea_Id, Alu_Id);
END
GO

-- Decisión de promoción por alumno y año (propuesta automática + decisión de Dirección con motivo).
IF OBJECT_ID(N'app.tbPromocionesAnio', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbPromocionesAnio
    (
        Pra_Id                int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbPromocionesAnio PRIMARY KEY,
        Ani_Id                int           NOT NULL CONSTRAINT FK_tbPromocionesAnio_Anio REFERENCES app.tbAnioLectivo (Ani_Id),
        Alu_Id                int           NOT NULL,
        Sea_Id                int           NULL,
        Niv_Id                int           NULL,
        Cun_Id                int           NULL,
        Sec_Id                int           NULL,
        Mda_Id                int           NULL,
        Pra_Alumno            nvarchar(200) NULL,
        Pra_Identidad         varchar(30)   NULL,
        Pra_Materias          int           NOT NULL CONSTRAINT DF_tbPromocionesAnio_Materias DEFAULT (0),
        Pra_Aprobadas         int           NOT NULL CONSTRAINT DF_tbPromocionesAnio_Aprobadas DEFAULT (0),
        Pra_EnRecuperacion    int           NOT NULL CONSTRAINT DF_tbPromocionesAnio_Recuperacion DEFAULT (0),
        Pra_Reprobadas        int           NOT NULL CONSTRAINT DF_tbPromocionesAnio_Reprobadas DEFAULT (0),
        Pra_SinNotas          int           NOT NULL CONSTRAINT DF_tbPromocionesAnio_SinNotas DEFAULT (0),
        Pra_Promedio          decimal(5,2)  NULL,
        Pra_EsUltimoGrado     bit           NOT NULL CONSTRAINT DF_tbPromocionesAnio_Ultimo DEFAULT (0),
        Pra_Propuesta         varchar(12)   NOT NULL,
        Pra_Decision          varchar(12)   NULL,
        Pra_Motivo            nvarchar(300) NULL,
        Pra_Confirmada        bit           NOT NULL CONSTRAINT DF_tbPromocionesAnio_Confirmada DEFAULT (0),
        Pra_FechaConfirmacion datetime      NULL,
        Usu_IdConfirma        int           NULL,
        Pra_AniDestino        int           NULL,
        Pra_MtaDestino        int           NULL,
        Pra_CreoDestino       bit           NOT NULL CONSTRAINT DF_tbPromocionesAnio_CreoDestino DEFAULT (0),
        Pra_EsEliminado       bit           NOT NULL CONSTRAINT DF_tbPromocionesAnio_EsEliminado DEFAULT (0),
        Pra_UsuarioModifica   int           NULL,
        Pra_FechaModifica     datetime      NULL,
        CONSTRAINT UQ_tbPromocionesAnio UNIQUE (Ani_Id, Alu_Id),
        CONSTRAINT CK_tbPromocionesAnio_Propuesta CHECK (Pra_Propuesta IN ('promovido', 'repite', 'gradua', 'pendiente')),
        CONSTRAINT CK_tbPromocionesAnio_Decision CHECK (Pra_Decision IS NULL OR Pra_Decision IN ('promovido', 'repite', 'gradua'))
    );
    CREATE INDEX IX_tbPromocionesAnio_Seccion ON app.tbPromocionesAnio (Ani_Id, Sea_Id);
END
GO

/* ───────────────────── Año de solo lectura (guardas) ───────────────────── */

-- 1 si el año (número, ej. 2030) está Cerrado (5) o Archivado (6).
CREATE OR ALTER FUNCTION app.FN_AnioLectivo_SoloLectura (@Anio int)
RETURNS bit
AS
BEGIN
    RETURN CASE WHEN EXISTS (SELECT 1 FROM app.tbAnioLectivo
                             WHERE Ani_Anio = @Anio AND Ani_EsEliminado = 0 AND Ani_Estado IN (5, 6))
                THEN 1 ELSE 0 END;
END
GO

-- Rechaza (THROW 50090) cualquier escritura de un año cerrado o archivado. Quien escribe notas lo pide
-- con @Numero = 50070 (el mismo número de "parcial cerrado"), que esos procedimientos ya dejan pasar.
CREATE OR ALTER PROCEDURE app.PR_AnioLectivo_ValidarEditable
    @Anio   int,
    @Numero int = 50090
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL RETURN;
    -- HOLDLOCK: dentro de la transacción de quien escribe, un cierre simultáneo espera a que termine.
    IF EXISTS (SELECT 1 FROM app.tbAnioLectivo WITH (HOLDLOCK)
               WHERE Ani_Anio = @Anio AND Ani_EsEliminado = 0 AND Ani_Estado IN (5, 6))
    BEGIN
        DECLARE @Mensaje nvarchar(400) = CONCAT(
            N'El año lectivo ', @Anio, N' está cerrado: ya no se pueden registrar, cambiar ni quitar sus notas, ',
            N'actividades, asistencia ni tareas. Si hace falta una corrección, Dirección debe reabrirlo con un motivo.');
        IF @Numero IS NULL OR @Numero NOT BETWEEN 50000 AND 50099 SET @Numero = 50090;
        THROW @Numero, @Mensaje, 1;
    END
END
GO

-- Notas y actividades del cuaderno (075): además del parcial cerrado, el año cerrado.
CREATE OR ALTER PROCEDURE app.PR_CierresParcial_ValidarAbierto
    @Anio   int,
    @Sem_Id int,
    @Pac_Id int
AS
BEGIN
    SET NOCOUNT ON;
    -- Año cerrado o archivado (script 090): nada de ese año se escribe (mismo número que parcial cerrado).
    EXEC app.PR_AnioLectivo_ValidarEditable @Anio, 50070;

    IF @Anio IS NULL OR @Sem_Id IS NULL OR @Pac_Id IS NULL RETURN;

    -- HOLDLOCK: dentro de la transacción de quien escribe la nota, el candado queda tomado hasta el
    -- COMMIT, así un cierre simultáneo (UPDLOCK en PR_CierresParcial_Cerrar) espera a que termine.
    IF EXISTS (SELECT 1 FROM app.tbCierresParcial WITH (HOLDLOCK)
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

-- Acciones de Cierre de parciales (075): un año cerrado no se toca hasta reabrirlo.
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
    EXEC app.PR_AnioLectivo_ValidarEditable @Anio;
END
GO

-- Cuaderno de actividades (089): el parcial de un año cerrado se ve y se trata como cerrado.
CREATE OR ALTER FUNCTION app.FN_Evaluacion_Cerrado (@Anio int, @Sem_Id int, @Pac_Id int)
RETURNS bit
AS
BEGIN
    RETURN CASE WHEN EXISTS (SELECT 1 FROM app.tbCierresParcial
                             WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem_Id AND Pac_Id = @Pac_Id AND Cpa_Estado = 'cerrado')
                  OR app.FN_AnioLectivo_SoloLectura(@Anio) = 1
                THEN 1 ELSE 0 END;
END
GO

-- Pase de lista, tareas y entregas: rechazan insertar o cambiar filas de un año cerrado (el año es el
-- del horario). El borrado físico (archivo de graduados) no se bloquea.
CREATE OR ALTER TRIGGER app.TR_tbAsistencia_AnioCerrado ON app.tbAsistencia
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Anio int = (SELECT TOP (1) h.Hor_Año
                         FROM inserted i
                         INNER JOIN app.tbHorarios h ON h.Hor_Id = i.Hor_Id
                         INNER JOIN app.tbAnioLectivo a ON a.Ani_Anio = h.Hor_Año AND a.Ani_EsEliminado = 0 AND a.Ani_Estado IN (5, 6));
    IF @Anio IS NOT NULL EXEC app.PR_AnioLectivo_ValidarEditable @Anio;
END
GO

CREATE OR ALTER TRIGGER app.TR_tbTareas_AnioCerrado ON app.tbTareas
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Anio int = (SELECT TOP (1) h.Hor_Año
                         FROM inserted i
                         INNER JOIN app.tbHorarios h ON h.Hor_Id = i.Hor_Id
                         INNER JOIN app.tbAnioLectivo a ON a.Ani_Anio = h.Hor_Año AND a.Ani_EsEliminado = 0 AND a.Ani_Estado IN (5, 6));
    IF @Anio IS NOT NULL EXEC app.PR_AnioLectivo_ValidarEditable @Anio;
END
GO

CREATE OR ALTER TRIGGER app.TR_tbEntregasTarea_AnioCerrado ON app.tbEntregasTarea
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Anio int = (SELECT TOP (1) h.Hor_Año
                         FROM inserted i
                         INNER JOIN app.tbTareas t ON t.Tar_Id = i.Tar_Id
                         INNER JOIN app.tbHorarios h ON h.Hor_Id = t.Hor_Id
                         INNER JOIN app.tbAnioLectivo a ON a.Ani_Anio = h.Hor_Año AND a.Ani_EsEliminado = 0 AND a.Ani_Estado IN (5, 6));
    IF @Anio IS NOT NULL EXEC app.PR_AnioLectivo_ValidarEditable @Anio;
END
GO

/* ─────────────── Años lectivos (052): el estado de cierre lo maneja solo el asistente ─────────────── */

CREATE OR ALTER PROCEDURE [app].[PR_tbAnioLectivo_Update]
    @Ani_Id               INT,
    @Ani_Anio             INT,
    @Ani_Nombre           VARCHAR(20),
    @Ani_FechaInicio      DATE = NULL,
    @Ani_FechaFin         DATE = NULL,
    @Ani_Estado           TINYINT,
    @Ani_UsuarioModifica  INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cerrando (4), Cerrado (5) y Archivado (6) solo se alcanzan o se dejan con el asistente de cierre
    -- (script 090): aquí se conserva el estado actual.
    DECLARE @Actual tinyint = (SELECT Ani_Estado FROM [app].[tbAnioLectivo] WHERE Ani_Id = @Ani_Id);
    IF @Actual IN (4, 5, 6) OR @Ani_Estado IN (4, 5, 6)
        SET @Ani_Estado = ISNULL(@Actual, 1);

    UPDATE  [app].[tbAnioLectivo]
    SET     Ani_Anio             = @Ani_Anio,
            Ani_Nombre           = @Ani_Nombre,
            Ani_FechaInicio      = @Ani_FechaInicio,
            Ani_FechaFin         = @Ani_FechaFin,
            Ani_Estado           = @Ani_Estado,
            Ani_UsuarioModifica  = @Ani_UsuarioModifica,
            Ani_FechaModifica    = GETDATE()
    WHERE   Ani_Id = @Ani_Id;
END
GO

CREATE OR ALTER PROCEDURE [app].[PR_tbAnioLectivo_SetActivo]
    @Ani_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [app].[tbAnioLectivo] WHERE Ani_Id = @Ani_Id AND Ani_EsEliminado = 0)
    BEGIN
        RAISERROR('El año lectivo no existe o está eliminado.', 16, 1);
        RETURN;
    END

    -- Un año archivado (script 090) es solo historia: no puede ser el año de trabajo.
    IF EXISTS (SELECT 1 FROM [app].[tbAnioLectivo] WHERE Ani_Id = @Ani_Id AND Ani_Estado = 6)
    BEGIN
        RAISERROR('Un año archivado no puede ser el año de trabajo.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [app].[tbConfiguracion] WHERE Con_Clave = 'anio_lectivo_activo_id')
        UPDATE [app].[tbConfiguracion] SET Con_Valor = CAST(@Ani_Id AS VARCHAR(10)), FechaModifica = GETDATE()
        WHERE Con_Clave = 'anio_lectivo_activo_id';
    ELSE
        INSERT INTO [app].[tbConfiguracion] (Con_Clave, Con_Valor, Con_Descripcion, Con_Grupo, Con_Tipo)
        VALUES ('anio_lectivo_activo_id', CAST(@Ani_Id AS VARCHAR(10)), 'Id del año lectivo de trabajo activo', 'Académico', 'numero');

    -- Sincroniza también la clave legacy para compatibilidad.
    UPDATE [app].[tbConfiguracion]
    SET    Con_Valor = CAST((SELECT Ani_Anio FROM [app].[tbAnioLectivo] WHERE Ani_Id = @Ani_Id) AS VARCHAR(10)),
           FechaModifica = GETDATE()
    WHERE  Con_Clave = 'anio_lectivo_actual';

    SELECT @Ani_Id AS Ani_Id;
END
GO

CREATE OR ALTER PROCEDURE [app].[PR_tbAnioLectivo_Delete]
    @Ani_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Un año en cierre, cerrado o archivado (script 090) guarda resultados e historial: no se da de baja.
    IF EXISTS (SELECT 1 FROM [app].[tbAnioLectivo] WHERE Ani_Id = @Ani_Id AND Ani_Estado IN (4, 5, 6))
    BEGIN
        RAISERROR('Un año en cierre, cerrado o archivado no se puede eliminar.', 16, 1);
        RETURN;
    END

    UPDATE  [app].[tbAnioLectivo]
    SET     Ani_EsEliminado = 1
    WHERE   Ani_Id = @Ani_Id;
END
GO

/* ───────────────────────────── Funciones del cierre ───────────────────────────── */

CREATE OR ALTER FUNCTION app.FN_CierreAnio_EstadoTexto (@Estado int)
RETURNS varchar(20)
AS
BEGIN
    RETURN CASE @Estado WHEN 1 THEN 'Borrador' WHEN 2 THEN 'Programado' WHEN 3 THEN 'Abierto'
                        WHEN 4 THEN 'Cerrando' WHEN 5 THEN 'Cerrado' WHEN 6 THEN 'Archivado' ELSE 'Desconocido' END;
END
GO

-- Alumnos inscritos en el año (no retirados) con su ubicación del año y nombre.
CREATE OR ALTER FUNCTION app.FN_CierreAnio_Inscritos (@Ani_Id int)
RETURNS TABLE
AS
RETURN
    SELECT m.Mta_Id, m.Alu_Id, m.Sea_Id, m.Mta_Estado,
           COALESCE(s.Niv_Id, a.Niv_Id) AS Niv_Id,
           COALESCE(s.Cun_Id, a.Cun_Id) AS Cun_Id,
           COALESCE(s.Sec_Id, a.Sec_Id) AS Sec_Id,
           COALESCE(s.Mda_Id, a.Mda_Id) AS Mda_Id,
           a.Cur_Id,
           CAST(CONCAT_WS(N' ', NULLIF(p.Per_PrimerNombre, ''), NULLIF(p.Per_SegundoNombre, ''),
                          NULLIF(p.Per_ApellidoPaterno, ''), NULLIF(p.Per_ApellidoMaterno, '')) AS nvarchar(200)) AS Alumno,
           CAST(p.Per_Identidad AS varchar(30)) AS Identidad,
           CAST(s.Sea_Nombre AS varchar(100)) AS Seccion,
           CAST(cn.Cun_Descripcion AS varchar(100)) AS Grado,
           cn.Cun_Orden,
           CAST(CASE WHEN cn.Cun_Id IS NOT NULL AND NOT EXISTS (
                         SELECT 1 FROM app.tbCursosNiveles c2
                         WHERE c2.Niv_Id = cn.Niv_Id AND c2.Cun_EsEliminado = 0 AND c2.Cun_Orden > cn.Cun_Orden)
                     THEN 1 ELSE 0 END AS bit) AS EsUltimoGrado
    FROM app.tbMatriculaAnio m
    INNER JOIN app.tbAlumnos a ON a.Alu_Id = m.Alu_Id
    INNER JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id
    LEFT JOIN app.tbSeccionesAnio s ON s.Sea_Id = m.Sea_Id
    LEFT JOIN app.tbCursosNiveles cn ON cn.Cun_Id = COALESCE(s.Cun_Id, a.Cun_Id)
    WHERE m.Ani_Id = @Ani_Id AND m.Mta_EsEliminado = 0 AND m.Mta_Estado <> 4;
GO

-- Reglas por nivel del año: lo guardado, o lo del año anterior, o el valor inicial (escala / 70 y 2).
CREATE OR ALTER FUNCTION app.FN_CierreAnio_Reglas (@Ani_Id int)
RETURNS TABLE
AS
RETURN
    SELECT n.Niv_Id,
           CAST(n.Niv_Descripcion AS varchar(100)) AS Niv_Descripcion,
           CAST(COALESCE(r.Cnr_NotaMinima, pr.Cnr_NotaMinima, d.NotaMinima) AS decimal(5,2)) AS NotaMinima,
           CAST(COALESCE(r.Cnr_MaxRecuperacion, pr.Cnr_MaxRecuperacion, 2) AS int) AS MaxRecuperacion,
           CAST(CASE WHEN r.Cnr_Id IS NULL THEN 1 ELSE 0 END AS bit) AS EsValorInicial,
           CAST(CASE WHEN r.Cnr_Id IS NOT NULL THEN 'guardada'
                     WHEN pr.Cnr_Id IS NOT NULL THEN 'anio_anterior'
                     WHEN d.DeEscala = 1 THEN 'escala' ELSE 'honduras' END AS varchar(15)) AS Origen
    FROM app.tbNivelesEducativos n
    CROSS JOIN (SELECT CAST(ISNULL(MIN(Esc_NotaDesde), 70) AS decimal(5,2)) AS NotaMinima,
                       CAST(CASE WHEN MIN(Esc_NotaDesde) IS NULL THEN 0 ELSE 1 END AS bit) AS DeEscala
                FROM app.tbEscalaNotas WHERE Esc_EsEliminado = 0 AND Esc_Aprueba = 1 AND Esc_NotaDesde > 0) d
    LEFT JOIN app.tbCierreAnioReglas r ON r.Ani_Id = @Ani_Id AND r.Niv_Id = n.Niv_Id
    OUTER APPLY (SELECT TOP (1) x.Cnr_Id, x.Cnr_NotaMinima, x.Cnr_MaxRecuperacion
                 FROM app.tbCierreAnioReglas x
                 INNER JOIN app.tbAnioLectivo ax ON ax.Ani_Id = x.Ani_Id
                 WHERE x.Niv_Id = n.Niv_Id
                   AND ax.Ani_Anio < (SELECT a0.Ani_Anio FROM app.tbAnioLectivo a0 WHERE a0.Ani_Id = @Ani_Id)
                 ORDER BY ax.Ani_Anio DESC) pr
    WHERE ISNULL(n.Niv_EsEliminado, 0) = 0;
GO

-- Revisión antes de cerrar (espejo de ClosureReadinessCheck): una fila por punto, con nivel
-- 'ok' | 'aviso' (se informa) | 'bloquea' (solo se cierra forzando, con motivo).
-- Grupo 'antes' = lo que conviene arreglar antes de empezar; 'cierre' = lo que hace el asistente.
CREATE OR ALTER FUNCTION app.FN_CierreAnio_Revision (@Ani_Id int)
RETURNS TABLE
AS
RETURN
    WITH an AS (
        SELECT Ani_Id, Ani_Anio, Ani_Estado FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id AND Ani_EsEliminado = 0
    ),
    per AS (
        SELECT s.Sem_Id, p.Pac_Id, c.Cpa_Estado, c.Cpa_Publicado
        FROM an
        CROSS JOIN app.tbSemestres s
        CROSS JOIN app.tbParciales p
        LEFT JOIN app.tbCierresParcial c ON c.Cpa_Anio = an.Ani_Anio AND c.Sem_Id = s.Sem_Id AND c.Pac_Id = p.Pac_Id
        WHERE ISNULL(s.Sem_EsEliminado, 0) = 0 AND ISNULL(p.Pac_EsEliminado, 0) = 0
    ),
    sig AS (
        SELECT TOP (1) x.Ani_Id, x.Ani_Anio, x.Ani_Estado
        FROM app.tbAnioLectivo x CROSS JOIN an
        WHERE x.Ani_EsEliminado = 0 AND x.Ani_Anio = an.Ani_Anio + 1
    ),
    c AS (
        SELECT
            (SELECT Ani_Anio FROM an) AS Anio,
            (SELECT COUNT(*) FROM per) AS ParcialesTotal,
            (SELECT COUNT(*) FROM per WHERE ISNULL(Cpa_Estado, 'abierto') <> 'cerrado') AS ParcialesAbiertos,
            (SELECT COUNT(*) FROM per WHERE Cpa_Estado = 'cerrado' AND ISNULL(Cpa_Publicado, 0) = 0) AS ParcialesSinPublicar,
            (SELECT COUNT(*) FROM per WHERE Cpa_Estado = 'cerrado' AND Cpa_Publicado = 1) AS ParcialesPublicados,
            (SELECT ISNULL(SUM(v.Alumnos - v.Cargadas), 0)
             FROM an CROSS JOIN per CROSS APPLY app.FN_CierresParcial_Avance(an.Ani_Anio, per.Sem_Id, per.Pac_Id) v) AS NotasFaltantes,
            (SELECT COUNT(*) FROM app.tbSeccionesAnio s
             WHERE s.Ani_Id = @Ani_Id AND s.Sea_EsEliminado = 0 AND s.Emp_Id IS NULL) AS SeccionesSinDocente,
            (SELECT COUNT(*) FROM app.tbSeccionesAnio s
             WHERE s.Ani_Id = @Ani_Id AND s.Sea_EsEliminado = 0) AS Secciones,
            (SELECT COUNT(*) FROM app.tbAlumnos a CROSS JOIN an
             WHERE a.AnioCursado = an.Ani_Anio AND ISNULL(a.Est_Id, 1) = 1
               AND NOT EXISTS (SELECT 1 FROM app.tbMatriculaAnio m
                               WHERE m.Alu_Id = a.Alu_Id AND m.Ani_Id = @Ani_Id AND m.Mta_EsEliminado = 0)) AS AlumnosSinInscripcion,
            (SELECT COUNT(*) FROM app.FN_CierreAnio_Inscritos(@Ani_Id)) AS Inscritos,
            (SELECT COUNT(*) FROM app.FN_CierreAnio_Inscritos(@Ani_Id) WHERE Sea_Id IS NULL) AS InscritosSinSeccion,
            (SELECT COUNT(*) FROM app.tbResultadosAnio r WHERE r.Ani_Id = @Ani_Id AND r.Rea_EsEliminado = 0) AS Resultados,
            (SELECT COUNT(*) FROM app.tbResultadosAnio r
             WHERE r.Ani_Id = @Ani_Id AND r.Rea_EsEliminado = 0 AND r.Rea_Resultado = 'recuperacion') AS RecuperacionesPendientes,
            (SELECT COUNT(*) FROM app.tbResultadosAnio r
             WHERE r.Ani_Id = @Ani_Id AND r.Rea_EsEliminado = 0 AND r.Rea_Resultado = 'sin_notas') AS MateriasSinNotas,
            (SELECT COUNT(*) FROM app.FN_CierreAnio_Inscritos(@Ani_Id) i
             WHERE NOT EXISTS (SELECT 1 FROM app.tbPromocionesAnio pr
                               WHERE pr.Ani_Id = @Ani_Id AND pr.Alu_Id = i.Alu_Id AND pr.Pra_EsEliminado = 0 AND pr.Pra_Confirmada = 1)) AS DecisionesPendientes,
            (SELECT Ani_Anio FROM sig) AS SiguienteAnio,
            (SELECT Ani_Estado FROM sig) AS SiguienteEstado
    )
    SELECT v.Orden, CAST(v.Grupo AS varchar(10)) AS Grupo, CAST(v.Clave AS varchar(30)) AS Clave,
           CAST(v.Titulo AS nvarchar(100)) AS Titulo, CAST(v.Detalle AS nvarchar(400)) AS Detalle,
           v.Cantidad, CAST(v.Nivel AS varchar(10)) AS Nivel, CAST(v.Enlace AS varchar(20)) AS Enlace
    FROM c
    CROSS APPLY (VALUES
        (1, 'antes', 'parciales_abiertos', N'Parciales cerrados', c.ParcialesAbiertos,
            CASE WHEN c.ParcialesAbiertos > 0 THEN 'bloquea' ELSE 'ok' END,
            CASE WHEN c.ParcialesTotal = 0 THEN N'No hay parciales definidos.'
                 WHEN c.ParcialesAbiertos > 0 THEN CONCAT(c.ParcialesAbiertos, N' de ', c.ParcialesTotal, N' parciales siguen abiertos. Ciérrelos en Cierre de parciales.')
                 ELSE CONCAT(N'Los ', c.ParcialesTotal, N' parciales del año están cerrados.') END, 'parciales'),
        (2, 'antes', 'parciales_sin_publicar', N'Resultados publicados', c.ParcialesTotal - c.ParcialesPublicados,
            CASE WHEN c.ParcialesSinPublicar > 0 OR c.ParcialesAbiertos > 0 THEN 'bloquea' ELSE 'ok' END,
            CASE WHEN c.ParcialesSinPublicar > 0 THEN CONCAT(c.ParcialesSinPublicar, N' parciales cerrados todavía no están publicados. El promedio anual solo usa parciales publicados.')
                 WHEN c.ParcialesAbiertos > 0 THEN N'Publique cada parcial al cerrarlo: el promedio anual solo usa parciales publicados.'
                 ELSE N'Todos los parciales cerrados están publicados.' END, 'parciales'),
        (3, 'antes', 'notas_faltantes', N'Notas faltantes', c.NotasFaltantes,
            CASE WHEN c.NotasFaltantes > 0 THEN 'aviso' ELSE 'ok' END,
            CASE WHEN c.NotasFaltantes > 0 THEN CONCAT(c.NotasFaltantes, N' notas esperadas sin registrar en los parciales del año (alumno × materia × parcial). El detalle por sección y docente está en Cierre de parciales.')
                 ELSE N'No faltan notas en los parciales del año.' END, 'parciales'),
        (4, 'antes', 'secciones_sin_docente', N'Secciones con docente guía', c.SeccionesSinDocente,
            CASE WHEN c.SeccionesSinDocente > 0 THEN 'aviso' ELSE 'ok' END,
            CASE WHEN c.Secciones = 0 THEN N'El año no tiene secciones.'
                 WHEN c.SeccionesSinDocente > 0 THEN CONCAT(c.SeccionesSinDocente, N' de ', c.Secciones, N' secciones no tienen docente guía asignado.')
                 ELSE CONCAT(N'Las ', c.Secciones, N' secciones tienen docente guía.') END, 'secciones'),
        (5, 'antes', 'alumnos_sin_inscripcion', N'Alumnos inscritos en el año', c.AlumnosSinInscripcion,
            CASE WHEN c.AlumnosSinInscripcion > 0 THEN 'aviso' ELSE 'ok' END,
            CASE WHEN c.AlumnosSinInscripcion > 0 THEN CONCAT(c.AlumnosSinInscripcion, N' alumnos activos de ', c.Anio, N' no tienen inscripción del año: quedan fuera de los resultados y de las promociones.')
                 ELSE CONCAT(c.Inscritos, N' alumnos inscritos en el año.') END, 'inscripcion'),
        (6, 'antes', 'inscritos_sin_seccion', N'Inscritos con sección', c.InscritosSinSeccion,
            CASE WHEN c.InscritosSinSeccion > 0 THEN 'aviso' ELSE 'ok' END,
            CASE WHEN c.InscritosSinSeccion > 0 THEN CONCAT(c.InscritosSinSeccion, N' alumnos inscritos no tienen sección del año.')
                 ELSE N'Todos los inscritos tienen sección.' END, 'inscripcion'),
        (7, 'antes', 'anio_siguiente', N'Año siguiente', CASE WHEN c.SiguienteAnio IS NULL THEN 1 ELSE 0 END,
            CASE WHEN c.SiguienteAnio IS NULL THEN 'aviso' ELSE 'ok' END,
            CASE WHEN c.SiguienteAnio IS NULL THEN CONCAT(N'No existe el año ', c.Anio + 1, N': créelo para que los promovidos y los que repiten queden inscritos al confirmar.')
                 ELSE CONCAT(N'El año ', c.SiguienteAnio, N' existe (', app.FN_CierreAnio_EstadoTexto(c.SiguienteEstado), N'): ahí se inscribe a los promovidos y a los que repiten.') END, 'anios'),
        (8, 'cierre', 'resultados', N'Resultados finales calculados', c.Resultados,
            CASE WHEN c.Resultados = 0 THEN 'bloquea' WHEN c.MateriasSinNotas > 0 THEN 'aviso' ELSE 'ok' END,
            CASE WHEN c.Resultados = 0 THEN N'Todavía no se calcularon los resultados del año (paso 2).'
                 WHEN c.MateriasSinNotas > 0 THEN CONCAT(c.Resultados, N' resultados calculados; ', c.MateriasSinNotas, N' materias sin ninguna nota publicada.')
                 ELSE CONCAT(c.Resultados, N' resultados calculados (alumno × materia).') END, 'resultados'),
        (9, 'cierre', 'recuperaciones', N'Recuperaciones registradas', c.RecuperacionesPendientes,
            CASE WHEN c.RecuperacionesPendientes > 0 THEN 'aviso' ELSE 'ok' END,
            CASE WHEN c.RecuperacionesPendientes > 0 THEN CONCAT(c.RecuperacionesPendientes, N' materias en recuperación sin nota registrada.')
                 ELSE N'No hay recuperaciones pendientes.' END, 'resultados'),
        (10, 'cierre', 'decisiones', N'Decisiones de promoción confirmadas', c.DecisionesPendientes,
            CASE WHEN c.DecisionesPendientes > 0 THEN 'bloquea' ELSE 'ok' END,
            CASE WHEN c.Inscritos = 0 THEN N'No hay alumnos inscritos en el año.'
                 WHEN c.DecisionesPendientes > 0 THEN CONCAT(c.DecisionesPendientes, N' de ', c.Inscritos, N' alumnos sin decisión confirmada (paso 3).')
                 ELSE CONCAT(N'Los ', c.Inscritos, N' alumnos tienen su decisión confirmada.') END, 'decisiones')
    ) v (Orden, Grupo, Clave, Titulo, Cantidad, Nivel, Detalle, Enlace);
GO

/* ───────────────────────────── Validación de quien escribe ───────────────────────────── */

-- Permiso, año y estado requerido (4 = Cerrando, o 34 = Abierto o Cerrando).
CREATE OR ALTER PROCEDURE app.PR_CierreAnio_Validar
    @Ani_Id      int,
    @Usuario     int,
    @PuedeCerrar bit,
    @Estado      int
AS
BEGIN
    SET NOCOUNT ON;
    IF ISNULL(@PuedeCerrar, 0) = 0
       OR NOT EXISTS (SELECT 1 FROM seguridad.tbUsuarios WHERE Usu_Id = @Usuario AND ISNULL(Usu_EsEliminado, 0) = 0)
        THROW 50091, N'No tiene permiso para cerrar el año escolar.', 1;

    DECLARE @Actual int, @Anio int;
    SELECT @Actual = Ani_Estado, @Anio = Ani_Anio FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id AND Ani_EsEliminado = 0;
    IF @Actual IS NULL
        THROW 50092, N'El año lectivo no existe.', 1;

    DECLARE @Mensaje nvarchar(400);
    IF @Estado = 4 AND @Actual <> 4
    BEGIN
        SET @Mensaje = CASE WHEN @Actual IN (5, 6)
                            THEN CONCAT(N'El año ', @Anio, N' está ', LOWER(app.FN_CierreAnio_EstadoTexto(@Actual)), N': sus resultados y decisiones ya no se cambian.')
                            ELSE CONCAT(N'Primero inicie el cierre del año ', @Anio, N' (paso 1).') END;
        THROW 50092, @Mensaje, 1;
    END
    IF @Estado = 34 AND @Actual NOT IN (3, 4)
    BEGIN
        SET @Mensaje = CONCAT(N'El año ', @Anio, N' está ', LOWER(app.FN_CierreAnio_EstadoTexto(@Actual)), N': ya no se cambia.');
        THROW 50092, @Mensaje, 1;
    END
END
GO

/* ───────────────────────────── Clasificación (reglas) ───────────────────────────── */

-- Aplica las reglas del nivel a los resultados (todos o los de un alumno) y rehace la propuesta de
-- promoción. Los alumnos con decisión confirmada no se tocan (su foto quedó congelada).
CREATE OR ALTER PROCEDURE app.PR_CierreAnio_Clasificar
    @Ani_Id int,
    @Alu_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Conf TABLE (Alu_Id int PRIMARY KEY);
    INSERT INTO @Conf (Alu_Id)
    SELECT Alu_Id FROM app.tbPromocionesAnio WHERE Ani_Id = @Ani_Id AND Pra_Confirmada = 1 AND Pra_EsEliminado = 0;

    -- 1) Resultado base de cada materia: nota final = promedio anual redondeado al entero.
    UPDATE x
    SET Rea_NotaFinal = CASE WHEN x.Rea_PeriodosConNota = 0 THEN NULL ELSE ROUND(x.Rea_Promedio, 0) END,
        Rea_Resultado = CASE WHEN x.Rea_PeriodosConNota = 0 THEN 'sin_notas'
                             WHEN ROUND(x.Rea_Promedio, 0) >= rg.NotaMinima THEN 'aprobado'
                             ELSE 'reprobado' END,
        Rea_AproboRecuperacion = NULL
    FROM app.tbResultadosAnio x
    INNER JOIN app.FN_CierreAnio_Reglas(@Ani_Id) rg ON rg.Niv_Id = x.Niv_Id
    WHERE x.Ani_Id = @Ani_Id AND x.Rea_EsEliminado = 0
      AND (@Alu_Id IS NULL OR x.Alu_Id = @Alu_Id)
      AND NOT EXISTS (SELECT 1 FROM @Conf c WHERE c.Alu_Id = x.Alu_Id);

    -- 2) Quien reprueba hasta el máximo del nivel va a recuperación; con nota de recuperación se resuelve.
    ;WITH f AS (
        SELECT Alu_Id, COUNT(*) AS N
        FROM app.tbResultadosAnio
        WHERE Ani_Id = @Ani_Id AND Rea_EsEliminado = 0 AND Rea_Resultado = 'reprobado'
          AND (@Alu_Id IS NULL OR Alu_Id = @Alu_Id)
        GROUP BY Alu_Id
    )
    UPDATE x
    SET Rea_Resultado = CASE WHEN x.Rea_NotaRecuperacion IS NULL THEN 'recuperacion'
                             WHEN x.Rea_NotaRecuperacion >= rg.NotaMinima THEN 'aprobado'
                             ELSE 'reprobado' END,
        Rea_AproboRecuperacion = CASE WHEN x.Rea_NotaRecuperacion IS NULL THEN NULL
                                      WHEN x.Rea_NotaRecuperacion >= rg.NotaMinima THEN 1 ELSE 0 END,
        Rea_NotaFinal = CASE WHEN x.Rea_NotaRecuperacion >= rg.NotaMinima THEN x.Rea_NotaRecuperacion ELSE x.Rea_NotaFinal END
    FROM app.tbResultadosAnio x
    INNER JOIN f ON f.Alu_Id = x.Alu_Id
    INNER JOIN app.FN_CierreAnio_Reglas(@Ani_Id) rg ON rg.Niv_Id = x.Niv_Id
    WHERE x.Ani_Id = @Ani_Id AND x.Rea_EsEliminado = 0 AND x.Rea_Resultado = 'reprobado'
      AND f.N <= rg.MaxRecuperacion
      AND NOT EXISTS (SELECT 1 FROM @Conf c WHERE c.Alu_Id = x.Alu_Id);

    UPDATE x SET Rea_Concepto = app.FN_EscalaConcepto(x.Rea_NotaFinal)
    FROM app.tbResultadosAnio x
    WHERE x.Ani_Id = @Ani_Id AND x.Rea_EsEliminado = 0
      AND (@Alu_Id IS NULL OR x.Alu_Id = @Alu_Id)
      AND NOT EXISTS (SELECT 1 FROM @Conf c WHERE c.Alu_Id = x.Alu_Id);

    -- 3) Propuesta por alumno inscrito.
    ;WITH s AS (
        SELECT x.Alu_Id,
               COUNT(*) AS Materias,
               SUM(CASE WHEN x.Rea_Resultado = 'aprobado'     THEN 1 ELSE 0 END) AS Aprobadas,
               SUM(CASE WHEN x.Rea_Resultado = 'recuperacion' THEN 1 ELSE 0 END) AS EnRecuperacion,
               SUM(CASE WHEN x.Rea_Resultado = 'reprobado'    THEN 1 ELSE 0 END) AS Reprobadas,
               SUM(CASE WHEN x.Rea_Resultado = 'sin_notas'    THEN 1 ELSE 0 END) AS SinNotas,
               CAST(ROUND(AVG(x.Rea_NotaFinal), 2) AS decimal(5,2)) AS Promedio
        FROM app.tbResultadosAnio x
        WHERE x.Ani_Id = @Ani_Id AND x.Rea_EsEliminado = 0 AND (@Alu_Id IS NULL OR x.Alu_Id = @Alu_Id)
        GROUP BY x.Alu_Id
    ),
    src AS (
        SELECT i.Alu_Id, i.Sea_Id, i.Niv_Id, i.Cun_Id, i.Sec_Id, i.Mda_Id, i.Alumno, i.Identidad, i.EsUltimoGrado,
               ISNULL(s.Materias, 0) AS Materias, ISNULL(s.Aprobadas, 0) AS Aprobadas,
               ISNULL(s.EnRecuperacion, 0) AS EnRecuperacion, ISNULL(s.Reprobadas, 0) AS Reprobadas,
               ISNULL(s.SinNotas, 0) AS SinNotas, s.Promedio,
               CAST(CASE WHEN ISNULL(s.Materias, 0) = 0 OR s.SinNotas > 0 OR s.EnRecuperacion > 0 THEN 'pendiente'
                         WHEN s.Reprobadas > 0 THEN 'repite'
                         WHEN i.EsUltimoGrado = 1 THEN 'gradua'
                         ELSE 'promovido' END AS varchar(12)) AS Propuesta
        FROM app.FN_CierreAnio_Inscritos(@Ani_Id) i
        LEFT JOIN s ON s.Alu_Id = i.Alu_Id
        WHERE (@Alu_Id IS NULL OR i.Alu_Id = @Alu_Id)
          AND NOT EXISTS (SELECT 1 FROM @Conf c WHERE c.Alu_Id = i.Alu_Id)
    )
    MERGE app.tbPromocionesAnio AS t
    USING src ON t.Ani_Id = @Ani_Id AND t.Alu_Id = src.Alu_Id
    WHEN MATCHED THEN UPDATE SET
        Sea_Id = src.Sea_Id, Niv_Id = src.Niv_Id, Cun_Id = src.Cun_Id, Sec_Id = src.Sec_Id, Mda_Id = src.Mda_Id,
        Pra_Alumno = src.Alumno, Pra_Identidad = src.Identidad, Pra_EsUltimoGrado = src.EsUltimoGrado,
        Pra_Materias = src.Materias, Pra_Aprobadas = src.Aprobadas, Pra_EnRecuperacion = src.EnRecuperacion,
        Pra_Reprobadas = src.Reprobadas, Pra_SinNotas = src.SinNotas, Pra_Promedio = src.Promedio,
        Pra_Propuesta = src.Propuesta,
        -- Si la propuesta nueva coincide con lo que Dirección eligió, ya no es un cambio.
        Pra_Decision = CASE WHEN t.Pra_Decision = src.Propuesta THEN NULL ELSE t.Pra_Decision END,
        Pra_Motivo   = CASE WHEN t.Pra_Decision = src.Propuesta THEN NULL ELSE t.Pra_Motivo END,
        Pra_EsEliminado = 0
    WHEN NOT MATCHED THEN INSERT
        (Ani_Id, Alu_Id, Sea_Id, Niv_Id, Cun_Id, Sec_Id, Mda_Id, Pra_Alumno, Pra_Identidad, Pra_EsUltimoGrado,
         Pra_Materias, Pra_Aprobadas, Pra_EnRecuperacion, Pra_Reprobadas, Pra_SinNotas, Pra_Promedio, Pra_Propuesta)
        VALUES (@Ani_Id, src.Alu_Id, src.Sea_Id, src.Niv_Id, src.Cun_Id, src.Sec_Id, src.Mda_Id, src.Alumno, src.Identidad,
                src.EsUltimoGrado, src.Materias, src.Aprobadas, src.EnRecuperacion, src.Reprobadas, src.SinNotas,
                src.Promedio, src.Propuesta);

    -- Decisiones sin confirmar de alumnos que ya no están inscritos (retirados o quitados).
    IF @Alu_Id IS NULL
        UPDATE t SET Pra_EsEliminado = 1
        FROM app.tbPromocionesAnio t
        WHERE t.Ani_Id = @Ani_Id AND t.Pra_Confirmada = 0 AND t.Pra_EsEliminado = 0
          AND NOT EXISTS (SELECT 1 FROM app.FN_CierreAnio_Inscritos(@Ani_Id) i WHERE i.Alu_Id = t.Alu_Id);
END
GO

/* ───────────────────────────── Lecturas ───────────────────────────── */

CREATE OR ALTER PROCEDURE app.PR_CierreAnio_Resumen
    @Ani_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Activo int = TRY_CONVERT(int, (SELECT TOP (1) Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = 'anio_lectivo_activo_id'));

    SELECT a.Ani_Id, a.Ani_Anio, a.Ani_Nombre, CAST(a.Ani_Estado AS int) AS Ani_Estado,
           app.FN_CierreAnio_EstadoTexto(a.Ani_Estado) AS EstadoTexto,
           CAST(CASE WHEN a.Ani_Id = @Activo THEN 1 ELSE 0 END AS bit) AS EsActivo,
           (SELECT COUNT(*) FROM app.FN_CierreAnio_Inscritos(a.Ani_Id)) AS Inscritos,
           (SELECT COUNT(*) FROM app.tbSeccionesAnio s WHERE s.Ani_Id = a.Ani_Id AND s.Sea_EsEliminado = 0) AS Secciones,
           (SELECT COUNT(*) FROM app.tbCierresParcial c WHERE c.Cpa_Anio = a.Ani_Anio AND c.Cpa_Estado = 'cerrado' AND c.Cpa_Publicado = 1) AS ParcialesPublicados,
           (SELECT COUNT(*) FROM app.tbSemestres s CROSS JOIN app.tbParciales p
            WHERE ISNULL(s.Sem_EsEliminado, 0) = 0 AND ISNULL(p.Pac_EsEliminado, 0) = 0) AS ParcialesTotal,
           (SELECT COUNT(*) FROM app.tbResultadosAnio r WHERE r.Ani_Id = a.Ani_Id AND r.Rea_EsEliminado = 0) AS Resultados,
           (SELECT MAX(r.Rea_FechaCalculo) FROM app.tbResultadosAnio r WHERE r.Ani_Id = a.Ani_Id AND r.Rea_EsEliminado = 0) AS FechaCalculo,
           (SELECT COUNT(*) FROM app.tbPromocionesAnio p WHERE p.Ani_Id = a.Ani_Id AND p.Pra_EsEliminado = 0 AND p.Pra_Confirmada = 1) AS Confirmados,
           sg.Ani_Id AS SiguienteId, sg.Ani_Anio AS SiguienteAnio, sg.Ani_Nombre AS SiguienteNombre,
           CAST(sg.Ani_Estado AS int) AS SiguienteEstado,
           app.FN_CierreAnio_EstadoTexto(sg.Ani_Estado) AS SiguienteEstadoTexto,
           h.Alh_Fecha AS FechaCierre, app.FN_NombreUsuario(h.Usu_Id) AS UsuarioCierre
    FROM app.tbAnioLectivo a
    OUTER APPLY (SELECT TOP (1) x.Ani_Id, x.Ani_Anio, x.Ani_Nombre, x.Ani_Estado FROM app.tbAnioLectivo x
                 WHERE x.Ani_EsEliminado = 0 AND x.Ani_Anio = a.Ani_Anio + 1) sg
    OUTER APPLY (SELECT TOP (1) y.Alh_Fecha, y.Usu_Id FROM app.tbAnioLectivoHistorial y
                 WHERE y.Ani_Id = a.Ani_Id AND y.Alh_Accion = 'cerrar' ORDER BY y.Alh_Fecha DESC, y.Alh_Id DESC) h
    WHERE a.Ani_Id = @Ani_Id AND a.Ani_EsEliminado = 0;
END
GO

CREATE OR ALTER PROCEDURE app.PR_CierreAnio_Revision
    @Ani_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Orden, Grupo, Clave, Titulo, Detalle, Cantidad, Nivel, Enlace
    FROM app.FN_CierreAnio_Revision(@Ani_Id)
    ORDER BY Orden;
END
GO

CREATE OR ALTER PROCEDURE app.PR_CierreAnio_Reglas
    @Ani_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Niv_Id, Niv_Descripcion, NotaMinima, MaxRecuperacion, EsValorInicial, Origen
    FROM app.FN_CierreAnio_Reglas(@Ani_Id)
    ORDER BY Niv_Id;
END
GO

-- Secciones del año con su avance de resultados y decisiones (Sea_Id 0 = inscritos sin sección).
CREATE OR ALTER PROCEDURE app.PR_CierreAnio_Secciones
    @Ani_Id int
AS
BEGIN
    SET NOCOUNT ON;
    ;WITH ins AS (SELECT ISNULL(Sea_Id, 0) AS Sea_Id, COUNT(*) AS Alumnos FROM app.FN_CierreAnio_Inscritos(@Ani_Id) GROUP BY ISNULL(Sea_Id, 0)),
    pr AS (
        SELECT ISNULL(p.Sea_Id, 0) AS Sea_Id,
               COUNT(*) AS ConDecision,
               SUM(CASE WHEN p.Pra_Confirmada = 1 THEN 1 ELSE 0 END) AS Confirmados,
               SUM(CASE WHEN ISNULL(p.Pra_Decision, p.Pra_Propuesta) = 'promovido' THEN 1 ELSE 0 END) AS Promovidos,
               SUM(CASE WHEN ISNULL(p.Pra_Decision, p.Pra_Propuesta) = 'repite'    THEN 1 ELSE 0 END) AS Repiten,
               SUM(CASE WHEN ISNULL(p.Pra_Decision, p.Pra_Propuesta) = 'gradua'    THEN 1 ELSE 0 END) AS Graduan,
               SUM(CASE WHEN ISNULL(p.Pra_Decision, p.Pra_Propuesta) = 'pendiente' THEN 1 ELSE 0 END) AS Pendientes,
               SUM(CASE WHEN p.Pra_EnRecuperacion > 0 THEN 1 ELSE 0 END) AS EnRecuperacion,
               SUM(CASE WHEN p.Pra_Decision IS NOT NULL THEN 1 ELSE 0 END) AS Cambiadas
        FROM app.tbPromocionesAnio p
        WHERE p.Ani_Id = @Ani_Id AND p.Pra_EsEliminado = 0
        GROUP BY ISNULL(p.Sea_Id, 0)
    )
    SELECT s.Sea_Id, CAST(s.Sea_Nombre AS varchar(100)) AS Sea_Nombre,
           s.Niv_Id, CAST(n.Niv_Descripcion AS varchar(100)) AS Niv_Descripcion,
           s.Cun_Id, CAST(cn.Cun_Descripcion AS varchar(100)) AS Cun_Descripcion, ISNULL(cn.Cun_Orden, 0) AS Cun_Orden,
           s.Sec_Id, CAST(sc.Sec_Descripcion AS varchar(50)) AS Sec_Descripcion,
           ISNULL(ins.Alumnos, 0) AS Alumnos,
           ISNULL(pr.ConDecision, 0) AS ConDecision, ISNULL(pr.Confirmados, 0) AS Confirmados,
           ISNULL(pr.Promovidos, 0) AS Promovidos, ISNULL(pr.Repiten, 0) AS Repiten, ISNULL(pr.Graduan, 0) AS Graduan,
           ISNULL(pr.Pendientes, 0) AS Pendientes, ISNULL(pr.EnRecuperacion, 0) AS EnRecuperacion,
           ISNULL(pr.Cambiadas, 0) AS Cambiadas
    FROM app.tbSeccionesAnio s
    LEFT JOIN app.tbNivelesEducativos n ON n.Niv_Id = s.Niv_Id
    LEFT JOIN app.tbCursosNiveles cn ON cn.Cun_Id = s.Cun_Id
    LEFT JOIN app.tbSecciones sc ON sc.Sec_Id = s.Sec_Id
    LEFT JOIN ins ON ins.Sea_Id = s.Sea_Id
    LEFT JOIN pr ON pr.Sea_Id = s.Sea_Id
    WHERE s.Ani_Id = @Ani_Id AND s.Sea_EsEliminado = 0
    UNION ALL
    SELECT 0, 'Sin sección', NULL, N'', NULL, N'', 999, NULL, N'',
           ISNULL(ins.Alumnos, 0), ISNULL(pr.ConDecision, 0), ISNULL(pr.Confirmados, 0),
           ISNULL(pr.Promovidos, 0), ISNULL(pr.Repiten, 0), ISNULL(pr.Graduan, 0),
           ISNULL(pr.Pendientes, 0), ISNULL(pr.EnRecuperacion, 0), ISNULL(pr.Cambiadas, 0)
    FROM (SELECT 0 AS Sea_Id) z
    LEFT JOIN ins ON ins.Sea_Id = 0
    LEFT JOIN pr ON pr.Sea_Id = 0
    WHERE ISNULL(ins.Alumnos, 0) > 0 OR ISNULL(pr.ConDecision, 0) > 0
    ORDER BY 7, 9, 2;
END
GO

-- Resultados de una sección (Sea_Id 0 = sin sección): una fila por alumno y materia.
CREATE OR ALTER PROCEDURE app.PR_CierreAnio_Resultados
    @Ani_Id int,
    @Sea_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.Rea_Id, r.Alu_Id, r.Rea_Alumno AS Alumno, r.Rea_Identidad AS Identidad,
           r.Mat_Id, r.Rea_Materia AS Materia,
           CAST(r.Rea_PeriodosConNota AS int) AS PeriodosConNota, CAST(r.Rea_PeriodosEsperados AS int) AS PeriodosEsperados,
           r.Rea_Promedio AS Promedio, r.Rea_NotaRecuperacion AS NotaRecuperacion, r.Rea_NotaFinal AS NotaFinal,
           r.Rea_Resultado AS Resultado, r.Rea_AproboRecuperacion AS AproboRecuperacion, r.Rea_Concepto AS Concepto,
           rg.NotaMinima,
           CAST(CASE WHEN r.Rea_Resultado = 'recuperacion' OR r.Rea_AproboRecuperacion IS NOT NULL THEN 1 ELSE 0 END AS bit) AS EnRecuperacion,
           CAST(ISNULL(p.Pra_Confirmada, 0) AS bit) AS Confirmada
    FROM app.tbResultadosAnio r
    LEFT JOIN app.FN_CierreAnio_Reglas(@Ani_Id) rg ON rg.Niv_Id = r.Niv_Id
    LEFT JOIN app.tbPromocionesAnio p ON p.Ani_Id = r.Ani_Id AND p.Alu_Id = r.Alu_Id AND p.Pra_EsEliminado = 0
    WHERE r.Ani_Id = @Ani_Id AND r.Rea_EsEliminado = 0
      AND ((@Sea_Id = 0 AND r.Sea_Id IS NULL) OR r.Sea_Id = @Sea_Id)
    ORDER BY r.Rea_Alumno, r.Alu_Id, r.Rea_Materia;
END
GO

-- Decisiones de una sección (Sea_Id 0 = sin sección).
CREATE OR ALTER PROCEDURE app.PR_CierreAnio_Decisiones
    @Ani_Id int,
    @Sea_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Pra_Id, p.Alu_Id, p.Pra_Alumno AS Alumno, p.Pra_Identidad AS Identidad,
           p.Pra_Materias AS Materias, p.Pra_Aprobadas AS Aprobadas, p.Pra_EnRecuperacion AS EnRecuperacion,
           p.Pra_Reprobadas AS Reprobadas, p.Pra_SinNotas AS SinNotas, p.Pra_Promedio AS Promedio,
           p.Pra_Propuesta AS Propuesta, p.Pra_Decision AS Decision,
           CAST(ISNULL(p.Pra_Decision, p.Pra_Propuesta) AS varchar(12)) AS Efectiva,
           p.Pra_Motivo AS Motivo, p.Pra_Confirmada AS Confirmada, p.Pra_FechaConfirmacion AS FechaConfirmacion,
           app.FN_NombreUsuario(p.Usu_IdConfirma) AS UsuarioConfirma,
           p.Pra_EsUltimoGrado AS EsUltimoGrado,
           CAST(CASE WHEN EXISTS (SELECT 1 FROM app.tbCursosNiveles c2 INNER JOIN app.tbCursosNiveles c1 ON c1.Cun_Id = p.Cun_Id
                                  WHERE c2.Cun_EsEliminado = 0 AND c2.Cun_Orden > c1.Cun_Orden) THEN 1 ELSE 0 END AS bit) AS HaySiguienteGrado,
           CAST(CASE WHEN p.Pra_MtaDestino IS NULL THEN NULL ELSE ISNULL(sd.Sea_Nombre, 'Sin sección') END AS varchar(100)) AS Destino,
           ad.Ani_Anio AS AnioDestino,
           CAST(CASE WHEN EXISTS (SELECT 1 FROM app.tbAlumnos a WHERE a.Alu_Id = p.Alu_Id) THEN 0 ELSE 1 END AS bit) AS Archivado
    FROM app.tbPromocionesAnio p
    LEFT JOIN app.tbMatriculaAnio md ON md.Mta_Id = p.Pra_MtaDestino
    LEFT JOIN app.tbSeccionesAnio sd ON sd.Sea_Id = md.Sea_Id
    LEFT JOIN app.tbAnioLectivo ad ON ad.Ani_Id = p.Pra_AniDestino
    WHERE p.Ani_Id = @Ani_Id AND p.Pra_EsEliminado = 0
      AND ((@Sea_Id = 0 AND p.Sea_Id IS NULL) OR p.Sea_Id = @Sea_Id)
    ORDER BY p.Pra_Alumno, p.Alu_Id;
END
GO

CREATE OR ALTER PROCEDURE app.PR_CierreAnio_Historial
    @Ani_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT h.Alh_Id, h.Alh_Fecha AS Fecha, h.Alh_Accion AS Accion,
           CAST(CASE h.Alh_Accion WHEN 'iniciar' THEN N'Inició el cierre' WHEN 'cancelar' THEN N'Canceló el cierre'
                                  WHEN 'cerrar' THEN N'Cerró el año' WHEN 'reabrir' THEN N'Reabrió el año'
                                  WHEN 'archivar' THEN N'Archivó el año' WHEN 'calcular' THEN N'Calculó los resultados'
                                  WHEN 'confirmar' THEN N'Confirmó decisiones' WHEN 'deshacer' THEN N'Deshizo una confirmación'
                                  WHEN 'reglas' THEN N'Cambió las reglas' WHEN 'activo' THEN N'Cambió el año de trabajo'
                                  ELSE h.Alh_Accion END AS nvarchar(60)) AS AccionTexto,
           CAST(h.Alh_EstadoAnterior AS int) AS EstadoAnterior, CAST(h.Alh_EstadoNuevo AS int) AS EstadoNuevo,
           app.FN_CierreAnio_EstadoTexto(h.Alh_EstadoAnterior) AS EstadoAnteriorTexto,
           app.FN_CierreAnio_EstadoTexto(h.Alh_EstadoNuevo) AS EstadoNuevoTexto,
           h.Alh_Motivo AS Motivo, h.Alh_Detalle AS Detalle, h.Alh_Forzado AS Forzado,
           app.FN_NombreUsuario(h.Usu_Id) AS Usuario
    FROM app.tbAnioLectivoHistorial h
    WHERE h.Ani_Id = @Ani_Id
    ORDER BY h.Alh_Fecha DESC, h.Alh_Id DESC;
END
GO

/* ───────────────────────────── Escrituras ─────────────────────────────
   Todas reciben quién escribe (@Usuario) y si tiene "Cerrar el año" (@PuedeCerrar); responden una
   fila. Errores de validación: THROW 50090-50099 (la API los muestra tal cual). */

-- Cambia el estado del año: iniciar (3→4), cancelar (4→3), cerrar (4→5), reabrir (5→4), archivar (5→6).
CREATE OR ALTER PROCEDURE app.PR_CierreAnio_CambiarEstado
    @Ani_Id       int,
    @Accion       varchar(20),
    @Motivo       nvarchar(500) = NULL,
    @Forzar       bit = 0,
    @Usuario      int,
    @PuedeCerrar  bit,
    @PuedeReabrir bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');
    SET @Accion = LOWER(LTRIM(RTRIM(@Accion)));

    IF NOT EXISTS (SELECT 1 FROM seguridad.tbUsuarios WHERE Usu_Id = @Usuario AND ISNULL(Usu_EsEliminado, 0) = 0)
       OR (@Accion = 'reabrir' AND ISNULL(@PuedeReabrir, 0) = 0)
       OR (@Accion <> 'reabrir' AND ISNULL(@PuedeCerrar, 0) = 0)
    BEGIN
        IF @Accion = 'reabrir' THROW 50091, N'Reabrir un año cerrado requiere el permiso especial «Reabrir el año escolar».', 1;
        THROW 50091, N'No tiene permiso para cerrar el año escolar.', 1;
    END

    DECLARE @Mensaje nvarchar(1000), @Anio int, @Actual int, @Nuevo int, @Revision nvarchar(max) = NULL, @Bloqueos nvarchar(800) = NULL;

    BEGIN TRANSACTION;

    SELECT @Anio = Ani_Anio, @Actual = Ani_Estado
    FROM app.tbAnioLectivo WITH (UPDLOCK, HOLDLOCK)
    WHERE Ani_Id = @Ani_Id AND Ani_EsEliminado = 0;
    IF @Actual IS NULL
        THROW 50092, N'El año lectivo no existe.', 1;

    SET @Nuevo = CASE
        WHEN @Accion = 'iniciar'  AND @Actual = 3 THEN 4
        WHEN @Accion = 'cancelar' AND @Actual = 4 THEN 3
        WHEN @Accion = 'cerrar'   AND @Actual = 4 THEN 5
        WHEN @Accion = 'reabrir'  AND @Actual = 5 THEN 4
        WHEN @Accion = 'archivar' AND @Actual = 5 THEN 6
        ELSE NULL END;
    IF @Nuevo IS NULL
    BEGIN
        SET @Mensaje = CASE
            WHEN @Accion NOT IN ('iniciar', 'cancelar', 'cerrar', 'reabrir', 'archivar') THEN N'Acción desconocida.'
            ELSE CONCAT(N'El año ', @Anio, N' está ', LOWER(app.FN_CierreAnio_EstadoTexto(@Actual)), N': no se puede ',
                        CASE @Accion WHEN 'iniciar' THEN N'iniciar su cierre (debe estar abierto).'
                                     WHEN 'cancelar' THEN N'cancelar su cierre.'
                                     WHEN 'cerrar' THEN N'cerrar (primero inicie el cierre).'
                                     WHEN 'reabrir' THEN N'reabrir (debe estar cerrado).'
                                     ELSE N'archivar (debe estar cerrado).' END) END;
        THROW 50092, @Mensaje, 1;
    END

    IF @Accion = 'cancelar' AND EXISTS (SELECT 1 FROM app.tbPromocionesAnio WHERE Ani_Id = @Ani_Id AND Pra_Confirmada = 1 AND Pra_EsEliminado = 0)
        THROW 50097, N'Hay secciones con decisiones confirmadas: deshaga esas confirmaciones antes de cancelar el cierre.', 1;

    IF @Accion = 'reabrir' AND @Motivo IS NULL
        THROW 50092, N'Escriba el motivo para reabrir el año (qué corrección se autorizó).', 1;

    IF @Accion = 'archivar' AND EXISTS (SELECT 1 FROM app.tbConfiguracion
                                        WHERE Con_Clave = 'anio_lectivo_activo_id' AND Con_Valor = CAST(@Ani_Id AS varchar(10)))
    BEGIN
        SET @Mensaje = CONCAT(N'El año ', @Anio, N' es el año de trabajo: cambie el año activo antes de archivarlo.');
        THROW 50098, @Mensaje, 1;
    END

    IF @Accion = 'cerrar'
    BEGIN
        SET @Revision = (SELECT Clave, Nivel, Cantidad, Detalle FROM app.FN_CierreAnio_Revision(@Ani_Id) ORDER BY Orden FOR JSON PATH);
        SET @Bloqueos = (SELECT STRING_AGG(CAST(Detalle AS nvarchar(400)), N' ') WITHIN GROUP (ORDER BY Orden)
                         FROM app.FN_CierreAnio_Revision(@Ani_Id) WHERE Nivel = 'bloquea');
        IF @Bloqueos IS NOT NULL AND ISNULL(@Forzar, 0) = 0
        BEGIN
            SET @Mensaje = CONCAT(N'El año todavía no está listo para cerrar. ', @Bloqueos);
            THROW 50096, @Mensaje, 1;
        END
        IF @Bloqueos IS NOT NULL AND @Motivo IS NULL
            THROW 50096, N'Para cerrar con puntos pendientes escriba el motivo.', 1;
    END

    UPDATE app.tbAnioLectivo
    SET Ani_Estado = @Nuevo, Ani_UsuarioModifica = @Usuario, Ani_FechaModifica = GETDATE()
    WHERE Ani_Id = @Ani_Id;

    INSERT INTO app.tbAnioLectivoHistorial (Ani_Id, Alh_Accion, Alh_EstadoAnterior, Alh_EstadoNuevo, Alh_Motivo, Alh_Forzado, Alh_Revision, Usu_Id)
    VALUES (@Ani_Id, @Accion, @Actual, @Nuevo, @Motivo,
            CASE WHEN @Accion = 'cerrar' AND @Bloqueos IS NOT NULL THEN 1 ELSE 0 END, @Revision, @Usuario);

    COMMIT TRANSACTION;

    SELECT @Ani_Id AS Ani_Id, @Nuevo AS Estado, app.FN_CierreAnio_EstadoTexto(@Nuevo) AS EstadoTexto,
           CAST(CASE WHEN @Bloqueos IS NOT NULL AND @Accion = 'cerrar' THEN 1 ELSE 0 END AS bit) AS Forzado;
END
GO

-- Calcula (o recalcula) los resultados del año desde los parciales publicados. Conserva las notas de
-- recuperación ya registradas y no toca a los alumnos con decisión confirmada.
CREATE OR ALTER PROCEDURE app.PR_CierreAnio_Calcular
    @Ani_Id      int,
    @Usuario     int,
    @PuedeCerrar bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    EXEC app.PR_CierreAnio_Validar @Ani_Id, @Usuario, @PuedeCerrar, 4;

    DECLARE @Anio int = (SELECT Ani_Anio FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id);
    DECLARE @Desde date = DATEFROMPARTS(@Anio, 1, 1), @Hasta date = DATEFROMPARTS(@Anio + 1, 1, 1);
    DECLARE @Mensaje nvarchar(400);

    DECLARE @Per TABLE (Sem_Id int, Pac_Id int, PRIMARY KEY (Sem_Id, Pac_Id));
    INSERT INTO @Per (Sem_Id, Pac_Id)
    SELECT Sem_Id, Pac_Id FROM app.tbCierresParcial
    WHERE Cpa_Anio = @Anio AND Cpa_Estado = 'cerrado' AND Cpa_Publicado = 1;
    DECLARE @P int = (SELECT COUNT(*) FROM @Per);
    IF @P = 0
    BEGIN
        SET @Mensaje = CONCAT(N'Todavía no hay parciales publicados de ', @Anio,
                              N': ciérrelos y publíquelos en Cierre de parciales antes de calcular los resultados.');
        THROW 50093, @Mensaje, 1;
    END

    CREATE TABLE #alu (Alu_Id int PRIMARY KEY, Sea_Id int NULL, Niv_Id int NULL, Cun_Id int NULL, Sec_Id int NULL,
                       Mda_Id int NULL, Cur_Id int NULL, Alumno nvarchar(200) NULL, Identidad varchar(30) NULL,
                       Seccion varchar(100) NULL, Grado varchar(100) NULL);
    INSERT INTO #alu
    SELECT i.Alu_Id, i.Sea_Id, i.Niv_Id, i.Cun_Id, i.Sec_Id, i.Mda_Id, i.Cur_Id, i.Alumno, i.Identidad, i.Seccion, i.Grado
    FROM app.FN_CierreAnio_Inscritos(@Ani_Id) i
    WHERE NOT EXISTS (SELECT 1 FROM app.tbPromocionesAnio p
                      WHERE p.Ani_Id = @Ani_Id AND p.Alu_Id = i.Alu_Id AND p.Pra_Confirmada = 1 AND p.Pra_EsEliminado = 0);

    -- Nota de cada parcial publicado (si hubiera más de una nota viva en el parcial, su promedio).
    CREATE TABLE #np (Alu_Id int, Mat_Id int, Sem_Id int, Pac_Id int, Nota decimal(9,4), PRIMARY KEY (Alu_Id, Mat_Id, Sem_Id, Pac_Id));
    INSERT INTO #np
    SELECT n.Alu_Id, n.Mat_Id, n.Sem_Id, n.Pac_Id, AVG(CAST(n.Not_Nota AS decimal(9,4)))
    FROM app.tbNotas n
    INNER JOIN #alu a ON a.Alu_Id = n.Alu_Id
    INNER JOIN @Per pe ON pe.Sem_Id = n.Sem_Id AND pe.Pac_Id = n.Pac_Id
    WHERE n.Not_Año >= @Desde AND n.Not_Año < @Hasta AND n.Not_EsEliminado = 0 AND n.Not_EsActivo = 1
    GROUP BY n.Alu_Id, n.Mat_Id, n.Sem_Id, n.Pac_Id;

    -- Materias del alumno: las que tienen nota publicada y las de su horario del año.
    CREATE TABLE #mat (Alu_Id int, Mat_Id int, PRIMARY KEY (Alu_Id, Mat_Id));
    INSERT INTO #mat SELECT DISTINCT Alu_Id, Mat_Id FROM #np;
    INSERT INTO #mat
    SELECT DISTINCT a.Alu_Id, h.Mat_Id
    FROM #alu a
    INNER JOIN app.tbHorarios h ON h.Hor_Año = @Anio AND ISNULL(h.Hor_EsEliminado, 0) = 0
                               AND h.Cun_Id = a.Cun_Id AND h.Sec_Id = a.Sec_Id
                               AND ISNULL(h.Mda_Id, 0) = ISNULL(a.Mda_Id, 0) AND h.Cur_Id = a.Cur_Id
    WHERE h.Mat_Id IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM #np x WHERE x.Alu_Id = a.Alu_Id AND x.Mat_Id = h.Mat_Id);

    CREATE TABLE #res (Alu_Id int, Mat_Id int, Periodos int, Promedio decimal(5,2) NULL, PRIMARY KEY (Alu_Id, Mat_Id));
    INSERT INTO #res
    SELECT m.Alu_Id, m.Mat_Id, COUNT(np.Nota), CAST(ROUND(AVG(np.Nota), 2) AS decimal(5,2))
    FROM #mat m
    LEFT JOIN #np np ON np.Alu_Id = m.Alu_Id AND np.Mat_Id = m.Mat_Id
    GROUP BY m.Alu_Id, m.Mat_Id;

    BEGIN TRANSACTION;

    -- Ya no aplican (alumno retirado, materia sin notas ni horario).
    UPDATE r SET Rea_EsEliminado = 1, Rea_UsuarioCalculo = @Usuario, Rea_FechaCalculo = GETDATE()
    FROM app.tbResultadosAnio r
    WHERE r.Ani_Id = @Ani_Id AND r.Rea_EsEliminado = 0
      AND NOT EXISTS (SELECT 1 FROM #res x WHERE x.Alu_Id = r.Alu_Id AND x.Mat_Id = r.Mat_Id)
      AND NOT EXISTS (SELECT 1 FROM app.tbPromocionesAnio p
                      WHERE p.Ani_Id = @Ani_Id AND p.Alu_Id = r.Alu_Id AND p.Pra_Confirmada = 1 AND p.Pra_EsEliminado = 0);

    UPDATE r
    SET Sea_Id = a.Sea_Id, Niv_Id = a.Niv_Id, Cun_Id = a.Cun_Id, Sec_Id = a.Sec_Id, Mda_Id = a.Mda_Id, Cur_Id = a.Cur_Id,
        Rea_Alumno = a.Alumno, Rea_Identidad = a.Identidad, Rea_Seccion = a.Seccion, Rea_Grado = a.Grado,
        Rea_Materia = CAST(m.Mat_Nombre AS nvarchar(150)),
        Rea_PeriodosEsperados = @P, Rea_PeriodosConNota = x.Periodos, Rea_Promedio = x.Promedio,
        Rea_EsEliminado = 0, Rea_UsuarioCalculo = @Usuario, Rea_FechaCalculo = GETDATE()
    FROM app.tbResultadosAnio r
    INNER JOIN #res x ON x.Alu_Id = r.Alu_Id AND x.Mat_Id = r.Mat_Id
    INNER JOIN #alu a ON a.Alu_Id = r.Alu_Id
    LEFT JOIN app.tbMaterias m ON m.Mat_Id = r.Mat_Id
    WHERE r.Ani_Id = @Ani_Id;

    INSERT INTO app.tbResultadosAnio
        (Ani_Id, Alu_Id, Mat_Id, Sea_Id, Niv_Id, Cun_Id, Sec_Id, Mda_Id, Cur_Id, Rea_Alumno, Rea_Identidad, Rea_Materia,
         Rea_Seccion, Rea_Grado, Rea_PeriodosEsperados, Rea_PeriodosConNota, Rea_Promedio, Rea_UsuarioCalculo)
    SELECT @Ani_Id, x.Alu_Id, x.Mat_Id, a.Sea_Id, a.Niv_Id, a.Cun_Id, a.Sec_Id, a.Mda_Id, a.Cur_Id, a.Alumno, a.Identidad,
           CAST(m.Mat_Nombre AS nvarchar(150)), a.Seccion, a.Grado, @P, x.Periodos, x.Promedio, @Usuario
    FROM #res x
    INNER JOIN #alu a ON a.Alu_Id = x.Alu_Id
    LEFT JOIN app.tbMaterias m ON m.Mat_Id = x.Mat_Id
    WHERE NOT EXISTS (SELECT 1 FROM app.tbResultadosAnio r WHERE r.Ani_Id = @Ani_Id AND r.Alu_Id = x.Alu_Id AND r.Mat_Id = x.Mat_Id);

    EXEC app.PR_CierreAnio_Clasificar @Ani_Id, NULL;

    INSERT INTO app.tbAnioLectivoHistorial (Ani_Id, Alh_Accion, Alh_Detalle, Usu_Id)
    VALUES (@Ani_Id, 'calcular', CONCAT((SELECT COUNT(*) FROM #alu), N' alumnos, ', (SELECT COUNT(*) FROM #res), N' materias, con ', @P, N' parciales publicados.'), @Usuario);

    COMMIT TRANSACTION;

    SELECT (SELECT COUNT(*) FROM #alu) AS Alumnos,
           (SELECT COUNT(*) FROM #res) AS Materias,
           @P AS Parciales,
           (SELECT COUNT(*) FROM app.tbResultadosAnio WHERE Ani_Id = @Ani_Id AND Rea_EsEliminado = 0 AND Rea_Resultado = 'aprobado') AS Aprobadas,
           (SELECT COUNT(*) FROM app.tbResultadosAnio WHERE Ani_Id = @Ani_Id AND Rea_EsEliminado = 0 AND Rea_Resultado = 'recuperacion') AS EnRecuperacion,
           (SELECT COUNT(*) FROM app.tbResultadosAnio WHERE Ani_Id = @Ani_Id AND Rea_EsEliminado = 0 AND Rea_Resultado = 'reprobado') AS Reprobadas,
           (SELECT COUNT(*) FROM app.tbResultadosAnio WHERE Ani_Id = @Ani_Id AND Rea_EsEliminado = 0 AND Rea_Resultado = 'sin_notas') AS SinNotas;
END
GO

-- Guarda la regla de un nivel (nota mínima y máximo de materias en recuperación) y reclasifica.
CREATE OR ALTER PROCEDURE app.PR_CierreAnio_GuardarRegla
    @Ani_Id          int,
    @Niv_Id          int,
    @NotaMinima      decimal(5,2),
    @MaxRecuperacion int,
    @Usuario         int,
    @PuedeCerrar     bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    EXEC app.PR_CierreAnio_Validar @Ani_Id, @Usuario, @PuedeCerrar, 34;
    IF NOT EXISTS (SELECT 1 FROM app.tbNivelesEducativos WHERE Niv_Id = @Niv_Id AND ISNULL(Niv_EsEliminado, 0) = 0)
        THROW 50092, N'Elija un nivel válido.', 1;
    IF @NotaMinima IS NULL OR @NotaMinima < 1 OR @NotaMinima > 100
        THROW 50092, N'La nota mínima de aprobación debe estar entre 1 y 100.', 1;
    IF @MaxRecuperacion IS NULL OR @MaxRecuperacion < 0 OR @MaxRecuperacion > 20
        THROW 50092, N'El máximo de materias en recuperación debe estar entre 0 y 20.', 1;

    BEGIN TRANSACTION;
    IF EXISTS (SELECT 1 FROM app.tbCierreAnioReglas WHERE Ani_Id = @Ani_Id AND Niv_Id = @Niv_Id)
        UPDATE app.tbCierreAnioReglas
        SET Cnr_NotaMinima = @NotaMinima, Cnr_MaxRecuperacion = @MaxRecuperacion,
            Cnr_UsuarioModifica = @Usuario, Cnr_FechaModifica = GETDATE()
        WHERE Ani_Id = @Ani_Id AND Niv_Id = @Niv_Id;
    ELSE
        INSERT INTO app.tbCierreAnioReglas (Ani_Id, Niv_Id, Cnr_NotaMinima, Cnr_MaxRecuperacion, Cnr_UsuarioModifica)
        VALUES (@Ani_Id, @Niv_Id, @NotaMinima, @MaxRecuperacion, @Usuario);

    EXEC app.PR_CierreAnio_Clasificar @Ani_Id, NULL;

    INSERT INTO app.tbAnioLectivoHistorial (Ani_Id, Alh_Accion, Alh_Detalle, Usu_Id)
    VALUES (@Ani_Id, 'reglas',
            CONCAT((SELECT Niv_Descripcion FROM app.tbNivelesEducativos WHERE Niv_Id = @Niv_Id),
                   N': aprueba con ', CAST(@NotaMinima AS decimal(5,0)), N', hasta ', @MaxRecuperacion, N' materias en recuperación.'),
            @Usuario);
    COMMIT TRANSACTION;

    SELECT @Niv_Id AS Niv_Id, @NotaMinima AS NotaMinima, @MaxRecuperacion AS MaxRecuperacion;
END
GO

-- Registra (o quita, con @Nota NULL) la nota de recuperación de una materia y reclasifica al alumno.
CREATE OR ALTER PROCEDURE app.PR_CierreAnio_Recuperacion
    @Rea_Id      int,
    @Nota        decimal(5,2) = NULL,
    @Usuario     int,
    @PuedeCerrar bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Ani_Id int, @Alu_Id int, @Resultado varchar(12), @Aprobo bit;
    SELECT @Ani_Id = Ani_Id, @Alu_Id = Alu_Id, @Resultado = Rea_Resultado, @Aprobo = Rea_AproboRecuperacion
    FROM app.tbResultadosAnio WHERE Rea_Id = @Rea_Id AND Rea_EsEliminado = 0;
    IF @Ani_Id IS NULL
        THROW 50094, N'No se encontró el resultado.', 1;
    EXEC app.PR_CierreAnio_Validar @Ani_Id, @Usuario, @PuedeCerrar, 4;

    IF EXISTS (SELECT 1 FROM app.tbPromocionesAnio WHERE Ani_Id = @Ani_Id AND Alu_Id = @Alu_Id AND Pra_Confirmada = 1 AND Pra_EsEliminado = 0)
        THROW 50097, N'La decisión de este alumno ya está confirmada: deshaga la confirmación de su sección para cambiar notas de recuperación.', 1;
    IF @Resultado <> 'recuperacion' AND @Aprobo IS NULL
        THROW 50094, N'Esta materia no está en recuperación.', 1;
    IF @Nota IS NOT NULL AND (@Nota < 0 OR @Nota > 100 OR @Nota <> ROUND(@Nota, 0))
        THROW 50094, N'La nota de recuperación debe ser un número entero entre 0 y 100.', 1;

    BEGIN TRANSACTION;
    UPDATE app.tbResultadosAnio
    SET Rea_NotaRecuperacion = @Nota, Rea_UsuarioRecuperacion = @Usuario, Rea_FechaRecuperacion = GETDATE()
    WHERE Rea_Id = @Rea_Id;
    EXEC app.PR_CierreAnio_Clasificar @Ani_Id, @Alu_Id;
    COMMIT TRANSACTION;

    SELECT r.Rea_Id, r.Rea_Resultado AS Resultado, r.Rea_NotaFinal AS NotaFinal, r.Rea_AproboRecuperacion AS AproboRecuperacion,
           p.Pra_Propuesta AS Propuesta
    FROM app.tbResultadosAnio r
    LEFT JOIN app.tbPromocionesAnio p ON p.Ani_Id = r.Ani_Id AND p.Alu_Id = r.Alu_Id AND p.Pra_EsEliminado = 0
    WHERE r.Rea_Id = @Rea_Id;
END
GO

-- Dirección cambia la decisión de un alumno (con motivo) o la regresa a la propuesta.
CREATE OR ALTER PROCEDURE app.PR_CierreAnio_Decidir
    @Pra_Id      int,
    @Decision    varchar(12),
    @Motivo      nvarchar(300) = NULL,
    @Usuario     int,
    @PuedeCerrar bit
AS
BEGIN
    SET NOCOUNT ON;
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');
    SET @Decision = LOWER(LTRIM(RTRIM(@Decision)));
    DECLARE @Ani_Id int, @Propuesta varchar(12), @Confirmada bit, @Ultimo bit, @Cun int;
    SELECT @Ani_Id = Ani_Id, @Propuesta = Pra_Propuesta, @Confirmada = Pra_Confirmada, @Ultimo = Pra_EsUltimoGrado, @Cun = Cun_Id
    FROM app.tbPromocionesAnio WHERE Pra_Id = @Pra_Id AND Pra_EsEliminado = 0;
    IF @Ani_Id IS NULL
        THROW 50092, N'No se encontró la decisión del alumno.', 1;
    EXEC app.PR_CierreAnio_Validar @Ani_Id, @Usuario, @PuedeCerrar, 4;

    IF @Confirmada = 1
        THROW 50097, N'La sección ya está confirmada: deshaga la confirmación para cambiar decisiones.', 1;
    IF @Decision IS NULL OR @Decision NOT IN ('promovido', 'repite', 'gradua')
        THROW 50092, N'Elija Promovido, Repite o Se gradúa.', 1;
    IF @Decision = 'gradua' AND ISNULL(@Ultimo, 0) = 0
        THROW 50092, N'Solo se gradúa quien cursa el último grado de su nivel.', 1;
    IF @Decision = 'promovido' AND NOT EXISTS (SELECT 1 FROM app.tbCursosNiveles c2 INNER JOIN app.tbCursosNiveles c1 ON c1.Cun_Id = @Cun
                                               WHERE c2.Cun_EsEliminado = 0 AND c2.Cun_Orden > c1.Cun_Orden)
        THROW 50092, N'Es el último grado del colegio: elija «Se gradúa» o «Repite».', 1;
    IF @Decision <> @Propuesta AND (@Motivo IS NULL OR LEN(@Motivo) < 5)
        THROW 50092, N'Escriba el motivo del cambio (al menos 5 letras).', 1;
    IF LEN(@Motivo) > 300
        THROW 50092, N'El motivo admite hasta 300 caracteres.', 1;

    UPDATE app.tbPromocionesAnio
    SET Pra_Decision = CASE WHEN @Decision = @Propuesta THEN NULL ELSE @Decision END,
        Pra_Motivo   = CASE WHEN @Decision = @Propuesta THEN NULL ELSE @Motivo END,
        Pra_UsuarioModifica = @Usuario, Pra_FechaModifica = GETDATE()
    WHERE Pra_Id = @Pra_Id;

    SELECT Pra_Id, Pra_Propuesta AS Propuesta, Pra_Decision AS Decision,
           CAST(ISNULL(Pra_Decision, Pra_Propuesta) AS varchar(12)) AS Efectiva
    FROM app.tbPromocionesAnio WHERE Pra_Id = @Pra_Id;
END
GO

-- Confirma las decisiones de una sección (Sea_Id 0 = sin sección): la matrícula del año queda
-- Promovido (2) / Repite (3) / Graduado (5) y, si existe el año siguiente, se inscribe a promovidos y
-- repitentes con app.PR_tbMatriculaAnio_Enroll en la sección equivalente (mismo nombre de sección y
-- jornada del grado que les toca); si no hay sección equivalente quedan inscritos sin sección.
CREATE OR ALTER PROCEDURE app.PR_CierreAnio_ConfirmarSeccion
    @Ani_Id      int,
    @Sea_Id      int,
    @Usuario     int,
    @PuedeCerrar bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    EXEC app.PR_CierreAnio_Validar @Ani_Id, @Usuario, @PuedeCerrar, 4;
    SET @Sea_Id = ISNULL(@Sea_Id, 0);
    IF @Sea_Id <> 0 AND NOT EXISTS (SELECT 1 FROM app.tbSeccionesAnio WHERE Sea_Id = @Sea_Id AND Ani_Id = @Ani_Id AND Sea_EsEliminado = 0)
        THROW 50092, N'La sección no es de este año.', 1;

    DECLARE @Mensaje nvarchar(400), @Anio int = (SELECT Ani_Anio FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id);
    DECLARE @Destino int = (SELECT TOP (1) Ani_Id FROM app.tbAnioLectivo
                            WHERE Ani_EsEliminado = 0 AND Ani_Anio = @Anio + 1 AND Ani_Estado BETWEEN 1 AND 4);

    DECLARE @Lista TABLE (Pra_Id int PRIMARY KEY, Alu_Id int, Decision varchar(12), Cun_Id int, Sec_Id int, Mda_Id int);
    INSERT INTO @Lista
    SELECT p.Pra_Id, p.Alu_Id, ISNULL(p.Pra_Decision, p.Pra_Propuesta), p.Cun_Id, p.Sec_Id, p.Mda_Id
    FROM app.tbPromocionesAnio p
    WHERE p.Ani_Id = @Ani_Id AND p.Pra_EsEliminado = 0 AND p.Pra_Confirmada = 0
      AND ((@Sea_Id = 0 AND p.Sea_Id IS NULL) OR p.Sea_Id = @Sea_Id);

    IF NOT EXISTS (SELECT 1 FROM @Lista)
        THROW 50092, N'No hay decisiones por confirmar en esta sección. Calcule los resultados (paso 2) si todavía no lo hizo.', 1;
    DECLARE @Pend int = (SELECT COUNT(*) FROM @Lista WHERE Decision = 'pendiente');
    IF @Pend > 0
    BEGIN
        SET @Mensaje = CONCAT(@Pend, N' alumno(s) de esta sección siguen pendientes (recuperación sin nota o materias sin notas): ',
                              N'registre la recuperación o decida con motivo antes de confirmar.');
        THROW 50095, @Mensaje, 1;
    END
    IF EXISTS (SELECT 1 FROM @Lista l WHERE NOT EXISTS (SELECT 1 FROM app.tbMatriculaAnio m
                                                       WHERE m.Ani_Id = @Ani_Id AND m.Alu_Id = l.Alu_Id AND m.Mta_EsEliminado = 0))
        THROW 50092, N'Hay alumnos de esta sección que ya no están inscritos en el año: vuelva a calcular los resultados.', 1;

    DECLARE @Pra int, @Alu int, @Dec varchar(12), @Cun int, @Sec int, @Mda int, @CunDest int, @SeaDest int, @MtaDest int, @Creo bit;
    DECLARE @Nuevo TABLE (NewId int);
    DECLARE @Inscritos int = 0, @SinSeccion int = 0;

    BEGIN TRANSACTION;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT Pra_Id, Alu_Id, Decision, Cun_Id, Sec_Id, Mda_Id FROM @Lista ORDER BY Pra_Id;
    OPEN cur;
    FETCH NEXT FROM cur INTO @Pra, @Alu, @Dec, @Cun, @Sec, @Mda;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE app.tbMatriculaAnio
        SET Mta_Estado = CASE @Dec WHEN 'promovido' THEN 2 WHEN 'repite' THEN 3 ELSE 5 END,
            Mta_UsuarioModifica = @Usuario, Mta_FechaModifica = GETDATE()
        WHERE Ani_Id = @Ani_Id AND Alu_Id = @Alu AND Mta_EsEliminado = 0;

        SELECT @MtaDest = NULL, @Creo = 0, @SeaDest = NULL, @CunDest = NULL;
        IF @Dec IN ('promovido', 'repite') AND @Destino IS NOT NULL
        BEGIN
            SET @CunDest = CASE WHEN @Dec = 'repite' THEN @Cun
                                ELSE (SELECT TOP (1) c2.Cun_Id FROM app.tbCursosNiveles c2
                                      INNER JOIN app.tbCursosNiveles c1 ON c1.Cun_Id = @Cun
                                      WHERE c2.Cun_EsEliminado = 0 AND c2.Cun_Orden > c1.Cun_Orden
                                      ORDER BY c2.Cun_Orden) END;
            SET @SeaDest = (SELECT TOP (1) s.Sea_Id FROM app.tbSeccionesAnio s
                            WHERE s.Ani_Id = @Destino AND s.Sea_EsEliminado = 0 AND s.Cun_Id = @CunDest
                              AND s.Sec_Id = @Sec AND ISNULL(s.Mda_Id, 0) = ISNULL(@Mda, 0)
                            ORDER BY s.Sea_Id);
            SET @MtaDest = (SELECT TOP (1) Mta_Id FROM app.tbMatriculaAnio
                            WHERE Alu_Id = @Alu AND Ani_Id = @Destino AND Mta_EsEliminado = 0);
            IF @MtaDest IS NULL
            BEGIN
                DELETE FROM @Nuevo;
                INSERT INTO @Nuevo EXEC app.PR_tbMatriculaAnio_Enroll @Alu, @Destino, @SeaDest, @Usuario;
                SET @MtaDest = (SELECT TOP (1) NewId FROM @Nuevo);
                SET @Creo = 1;
                SET @Inscritos += 1;
                IF @SeaDest IS NULL SET @SinSeccion += 1;
            END
        END

        UPDATE app.tbPromocionesAnio
        SET Pra_Confirmada = 1, Pra_FechaConfirmacion = GETDATE(), Usu_IdConfirma = @Usuario,
            Pra_AniDestino = CASE WHEN @MtaDest IS NULL THEN NULL ELSE @Destino END,
            Pra_MtaDestino = @MtaDest, Pra_CreoDestino = @Creo,
            Pra_UsuarioModifica = @Usuario, Pra_FechaModifica = GETDATE()
        WHERE Pra_Id = @Pra;

        FETCH NEXT FROM cur INTO @Pra, @Alu, @Dec, @Cun, @Sec, @Mda;
    END
    CLOSE cur;
    DEALLOCATE cur;

    DECLARE @Nombre varchar(100) = ISNULL((SELECT Sea_Nombre FROM app.tbSeccionesAnio WHERE Sea_Id = @Sea_Id), 'Sin sección');
    INSERT INTO app.tbAnioLectivoHistorial (Ani_Id, Alh_Accion, Alh_Detalle, Usu_Id)
    SELECT @Ani_Id, 'confirmar',
           CONCAT(@Nombre, N': ', SUM(CASE WHEN Decision = 'promovido' THEN 1 ELSE 0 END), N' promovidos, ',
                  SUM(CASE WHEN Decision = 'repite' THEN 1 ELSE 0 END), N' repiten, ',
                  SUM(CASE WHEN Decision = 'gradua' THEN 1 ELSE 0 END), N' se gradúan.'), @Usuario
    FROM @Lista;

    COMMIT TRANSACTION;

    SELECT (SELECT COUNT(*) FROM @Lista) AS Confirmados,
           (SELECT COUNT(*) FROM @Lista WHERE Decision = 'promovido') AS Promovidos,
           (SELECT COUNT(*) FROM @Lista WHERE Decision = 'repite') AS Repiten,
           (SELECT COUNT(*) FROM @Lista WHERE Decision = 'gradua') AS Graduan,
           @Inscritos AS Inscritos, @SinSeccion AS SinSeccion,
           (SELECT Ani_Anio FROM app.tbAnioLectivo WHERE Ani_Id = @Destino) AS AnioDestino;
END
GO

-- Deshace la confirmación de una sección (con motivo): la matrícula del año vuelve a Activa y se quita
-- la inscripción del año siguiente que hizo la confirmación si sigue como la dejó (activa).
CREATE OR ALTER PROCEDURE app.PR_CierreAnio_DeshacerSeccion
    @Ani_Id      int,
    @Sea_Id      int,
    @Motivo      nvarchar(500) = NULL,
    @Usuario     int,
    @PuedeCerrar bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');
    EXEC app.PR_CierreAnio_Validar @Ani_Id, @Usuario, @PuedeCerrar, 4;
    SET @Sea_Id = ISNULL(@Sea_Id, 0);
    IF @Motivo IS NULL
        THROW 50092, N'Escriba el motivo para deshacer la confirmación.', 1;

    DECLARE @Lista TABLE (Pra_Id int PRIMARY KEY, Alu_Id int, MtaDestino int NULL, Creo bit);
    INSERT INTO @Lista
    SELECT p.Pra_Id, p.Alu_Id, p.Pra_MtaDestino, p.Pra_CreoDestino
    FROM app.tbPromocionesAnio p
    WHERE p.Ani_Id = @Ani_Id AND p.Pra_EsEliminado = 0 AND p.Pra_Confirmada = 1
      AND ((@Sea_Id = 0 AND p.Sea_Id IS NULL) OR p.Sea_Id = @Sea_Id);
    IF NOT EXISTS (SELECT 1 FROM @Lista)
        THROW 50092, N'Esta sección no tiene decisiones confirmadas.', 1;

    DECLARE @Mensaje nvarchar(400);
    DECLARE @Archivados int = (SELECT COUNT(*) FROM @Lista l WHERE NOT EXISTS (SELECT 1 FROM app.tbAlumnos a WHERE a.Alu_Id = l.Alu_Id));
    IF @Archivados > 0
    BEGIN
        SET @Mensaje = CONCAT(@Archivados, N' alumno(s) de esta sección ya se graduaron y fueron archivados en Graduación: la confirmación ya no se puede deshacer.');
        THROW 50097, @Mensaje, 1;
    END

    BEGIN TRANSACTION;
    UPDATE d SET Mta_EsEliminado = 1, Mta_UsuarioModifica = @Usuario, Mta_FechaModifica = GETDATE()
    FROM app.tbMatriculaAnio d
    INNER JOIN @Lista l ON l.MtaDestino = d.Mta_Id AND l.Creo = 1
    WHERE d.Mta_Estado = 1 AND d.Mta_EsEliminado = 0;

    UPDATE o SET Mta_Estado = 1, Mta_UsuarioModifica = @Usuario, Mta_FechaModifica = GETDATE()
    FROM app.tbMatriculaAnio o
    INNER JOIN @Lista l ON l.Alu_Id = o.Alu_Id
    WHERE o.Ani_Id = @Ani_Id AND o.Mta_EsEliminado = 0 AND o.Mta_Estado IN (2, 3, 5);

    UPDATE p SET Pra_Confirmada = 0, Pra_FechaConfirmacion = NULL, Usu_IdConfirma = NULL,
                 Pra_AniDestino = NULL, Pra_MtaDestino = NULL, Pra_CreoDestino = 0,
                 Pra_UsuarioModifica = @Usuario, Pra_FechaModifica = GETDATE()
    FROM app.tbPromocionesAnio p
    INNER JOIN @Lista l ON l.Pra_Id = p.Pra_Id;

    DECLARE @Nombre varchar(100) = ISNULL((SELECT Sea_Nombre FROM app.tbSeccionesAnio WHERE Sea_Id = @Sea_Id), 'Sin sección');
    INSERT INTO app.tbAnioLectivoHistorial (Ani_Id, Alh_Accion, Alh_Motivo, Alh_Detalle, Usu_Id)
    VALUES (@Ani_Id, 'deshacer', @Motivo, CONCAT(@Nombre, N': ', (SELECT COUNT(*) FROM @Lista), N' decisiones vuelven a revisión.'), @Usuario);

    -- Con la confirmación deshecha, sus resultados vuelven a seguir las reglas.
    EXEC app.PR_CierreAnio_Clasificar @Ani_Id, NULL;
    COMMIT TRANSACTION;

    SELECT (SELECT COUNT(*) FROM @Lista) AS Deshechos;
END
GO

/* ───────────────────────────── Graduación ─────────────────────────────
   app.vCandidatosGraduacion: si el alumno tiene una decisión CONFIRMADA en el cierre de un año
   (en cierre, cerrado o archivado), esa decisión manda sobre el promedio de notas: «se gradúa» deja
   las notas en regla; otra decisión (repite / pasa al grado siguiente) las bloquea con el motivo.
   Sin decisión, se calcula igual que antes. */
CREATE OR ALTER VIEW app.vCandidatosGraduacion
AS
WITH ConfigNota AS
(
    -- Nota mínima de aprobación configurable. Fallback = 70 si no existe la fila.
    SELECT ISNULL(
              (SELECT TOP 1 TRY_CAST(Con_Valor AS DECIMAL(5,2))
               FROM   app.tbConfiguracion
               WHERE  Con_Clave = 'nota_minima_aprobacion'),
              70
           ) AS NotaMinima
),
UltimosCursos AS
(
    -- Identifica el Cun_Id "último" por nivel educativo.
    SELECT  cn.Niv_Id,
            cn.Cun_Id,
            cn.Cun_Descripcion,
            cn.Cun_Orden,
            ROW_NUMBER() OVER (PARTITION BY cn.Niv_Id ORDER BY cn.Cun_Orden DESC) AS rn
    FROM    app.tbCursosNiveles AS cn
    WHERE   cn.Cun_EsEliminado = 0
),
NotasAlumno AS
(
    -- Promedio simple de notas no eliminadas por alumno (todas las materias y parciales).
    SELECT  n.Alu_Id,
            AVG(CAST(n.Not_Nota AS DECIMAL(9,2))) AS PromedioCalculado,
            MIN(CAST(n.Not_Nota AS DECIMAL(9,2))) AS NotaMinima
    FROM    app.tbNotas AS n
    WHERE   n.Not_EsEliminado = 0
      AND   n.Not_EsActivo    = 1
    GROUP BY n.Alu_Id
),
DeudaAlumno AS
(
    SELECT  cc.Alu_Id,
            SUM(ISNULL(cc.Cco_MontoPendiente, 0)) AS DeudaPendiente
    FROM    finanza.tbCuentasCobrar AS cc
    WHERE   cc.Cco_EsEliminado = 0
    GROUP BY cc.Alu_Id
),
DecisionCierre AS
(
    -- Decisión confirmada más reciente del cierre del año (script 090).
    SELECT  pr.Alu_Id,
            ISNULL(pr.Pra_Decision, pr.Pra_Propuesta) AS Decision,
            ROW_NUMBER() OVER (PARTITION BY pr.Alu_Id ORDER BY an.Ani_Anio DESC) AS rn
    FROM    app.tbPromocionesAnio AS pr
    INNER JOIN app.tbAnioLectivo AS an ON an.Ani_Id = pr.Ani_Id
    WHERE   pr.Pra_Confirmada = 1 AND pr.Pra_EsEliminado = 0
      AND   an.Ani_EsEliminado = 0 AND an.Ani_Estado IN (4, 5, 6)
)
SELECT
    a.Alu_Id,
    LTRIM(RTRIM(
        ISNULL(p.Per_PrimerNombre,'')   + ' ' +
        ISNULL(p.Per_SegundoNombre,'')  + ' ' +
        ISNULL(p.Per_ApellidoPaterno,'')+ ' ' +
        ISNULL(p.Per_ApellidoMaterno,'')
    ))                                                    AS NombreCompleto,
    n.Niv_Descripcion,
    uc.Cun_Descripcion                                    AS Cur_Descripcion, -- nombre del último curso
    s.Sec_Descripcion,

    -- Validación de notas (umbral configurable vía app.tbConfiguracion o decisión del cierre del año)
    nt.Ok                                                 AS NotasOk,

    -- Deuda
    ISNULL(da.DeudaPendiente, 0)                          AS DeudaPendiente,
    CASE WHEN ISNULL(da.DeudaPendiente, 0) = 0
         THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END      AS DeudaOk,

    -- Estado de validación consolidado
    CASE
        WHEN nt.Ok = 1 AND ISNULL(da.DeudaPendiente,0) = 0 THEN 'Cumple'
        WHEN nt.Ok = 0 AND ISNULL(da.DeudaPendiente,0) > 0 THEN 'Múltiples motivos'
        WHEN nt.Ok = 0                                     THEN 'Notas pendientes'
        WHEN ISNULL(da.DeudaPendiente,0) > 0               THEN 'Deuda pendiente'
        ELSE 'Cumple'
    END                                                   AS EstadoValidacion,

    -- Texto descriptivo con los motivos
    LTRIM(
        CASE WHEN dc.Decision = 'repite'    THEN 'Repite el grado (decisión del cierre del año); '
             WHEN dc.Decision = 'promovido' THEN 'Pasa al grado siguiente (decisión del cierre del año); '
             WHEN nt.Ok = 0                 THEN 'Notas reprobadas; ' ELSE '' END
      + CASE WHEN ISNULL(da.DeudaPendiente,0) > 0
             THEN 'Saldo pendiente: ' + CONVERT(VARCHAR(30), CAST(da.DeudaPendiente AS DECIMAL(18,2))) + '; '
             ELSE '' END
    )                                                     AS MotivosBloqueo

FROM        app.tbAlumnos          AS a
CROSS JOIN  ConfigNota             AS cfg
INNER JOIN  app.tbPersonas         AS p   ON p.Per_Id = a.Per_Id
INNER JOIN  app.tbNivelesEducativos AS n  ON n.Niv_Id = a.Niv_Id
INNER JOIN  UltimosCursos          AS uc  ON uc.Niv_Id = a.Niv_Id
                                         AND uc.Cun_Id = a.Cun_Id
                                         AND uc.rn = 1
LEFT  JOIN  app.tbSecciones        AS s   ON s.Sec_Id = a.Sec_Id
LEFT  JOIN  NotasAlumno            AS na  ON na.Alu_Id = a.Alu_Id
LEFT  JOIN  DeudaAlumno            AS da  ON da.Alu_Id = a.Alu_Id
LEFT  JOIN  DecisionCierre         AS dc  ON dc.Alu_Id = a.Alu_Id AND dc.rn = 1
CROSS APPLY (SELECT CAST(CASE WHEN dc.Decision = 'gradua' THEN 1
                              WHEN dc.Decision IS NOT NULL THEN 0
                              WHEN ISNULL(na.PromedioCalculado, 0) >= cfg.NotaMinima
                                   AND ISNULL(na.NotaMinima, 0)     >= cfg.NotaMinima THEN 1
                              ELSE 0 END AS BIT) AS Ok) AS nt
WHERE   a.Est_Id = 1   -- Activo
;
GO

/* app.spGraduarAlumno: igual que antes, salvo el paso 5.9, que ahora archiva y quita la matrícula por
   año (app.tbMatriculaAnio) en vez de la tabla vacía app.tbMatriculas. Sin esto, la llave de
   app.tbMatriculaAnio hacia app.tbAlumnos impedía graduar a cualquier alumno inscrito por año. */
CREATE OR ALTER PROCEDURE app.spGraduarAlumno
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
    DECLARE @DetalleMatricula  NVARCHAR(MAX);

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

        -- 5.9 Matrícula por año (app.tbMatriculaAnio, script 058; antes la tabla vacía app.tbMatriculas):
        --     los años, secciones y estados quedan en el detalle del registro (JSON) y se quita la matrícula.
        SET @DetalleMatricula = (
            SELECT  an.Ani_Anio AS anio, se.Sea_Nombre AS seccion, mt.Mta_Estado AS estado
            FROM    app.tbMatriculaAnio mt
            INNER JOIN app.tbAnioLectivo   an ON an.Ani_Id = mt.Ani_Id
            LEFT  JOIN app.tbSeccionesAnio se ON se.Sea_Id = mt.Sea_Id
            WHERE   mt.Alu_Id = @Alu_Id
            ORDER BY an.Ani_Anio
            FOR JSON PATH
        );
        DELETE FROM app.tbMatriculaAnio WHERE Alu_Id = @Alu_Id;
        SET @Filas = @@ROWCOUNT;
        INSERT INTO app.tbArchivoGraduadoLog
            (LogArc_AluGrad_Id, LogArc_AluIdOriginal, LogArc_TablaAfectada,
             LogArc_Accion, LogArc_RegistrosAfectados, LogArc_Detalle, LogArc_UsuarioId)
        VALUES (@AluGrad_Id, @Alu_Id, 'app.tbMatriculaAnio', 'MIGRATE', @Filas, @DetalleMatricula, @UsuarioId);

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

/* ───────────────────────────── Permisos ─────────────────────────────
   Cierre del año          = ver el asistente, la revisión, resultados, decisiones e historial (admin, director, secretaria)
   Cerrar el año           = iniciar o cancelar el cierre, calcular, reglas, recuperaciones, decidir,
                             confirmar o deshacer secciones, cerrar y archivar (admin, director)
   Reabrir el año escolar  = reabrir un año cerrado (solo admin; se asigna a otro rol a propósito)
   El docente no ve la pantalla: en su cuaderno el año cerrado aparece cerrado y el servidor rechaza
   cambios de notas, actividades, asistencia y tareas de ese año. */
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES
    (N'Cierre del año',         N'|admin|director|secretaria|'),
    (N'Cerrar el año',          N'|admin|director|'),
    (N'Reabrir el año escolar', N'|admin|');

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
