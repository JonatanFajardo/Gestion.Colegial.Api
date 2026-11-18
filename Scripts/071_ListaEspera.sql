/* =============================================================================
   071 · Lista de espera de admisión  (espejo de Skuul: admission_waitlist_entries)

   - Un aspirante es un niño que quiere entrar al colegio y todavía NO es alumno:
     se guardan sus datos básicos y los del encargado para matricularlo después
     con el wizard de Matrícula sin volver a escribirlos.
   - Estados (código corto en la tabla):
         EE En espera → OF Ofrecido → MA Matriculado
                      ↘ RE Rechazado / DE Desistió  (RE y DE se pueden reactivar → EE)
     Abiertos = EE y OF. Un aspirante cerrado (MA, RE, DE) no se edita.
   - Cola = año + grado, ordenada por prioridad (2 alta, 1 media, 0 normal) y luego por
     posición. Posición = máx + 1 dentro del mismo año + grado (al reactivar o al cambiar
     de grado vuelve al final).
   - Cupo de un grado = SUM(Sea_Cupo) de sus secciones del año (no eliminadas, en estado
     Borrador/Planificada/Activa). Si el grado no tiene secciones o alguna no tiene cupo,
     el cupo queda "sin definir". Ocupados = matriculados activos en esas secciones +
     aspirantes con oferta abierta (una oferta reserva el asiento). Libres = cupo − ocupados.
     Si el aspirante pidió modalidad y esa modalidad tiene cupo definido, también se revisa.
   - "Ofrecer cupo" solo al primero de la cola de su grado y solo con cupo libre o sin definir.
   - Rechazar y Desistió piden motivo; Reactivar también.
   - Cada cambio de estado (y de prioridad) queda en app.tbAspirantesHistorial.
   - Permisos: "Lista de espera" (admin, director, secretaria) para ver;
               "Gestionar lista de espera" (admin, secretaria) para registrar y mover.
   - Solo lee tbAnioLectivo, tbSeccionesAnio y tbMatriculaAnio; no las modifica.

   Crear SIEMPRE con QUOTED_IDENTIFIER ON (índices filtrados).
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ---------------------------------------------------------------- Tablas */
IF OBJECT_ID('app.tbAspirantes') IS NULL
BEGIN
    CREATE TABLE app.tbAspirantes
    (
        Asp_Id                 int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbAspirantes PRIMARY KEY,
        Ani_Id                 int            NOT NULL CONSTRAINT FK_tbAspirantes_tbAnioLectivo REFERENCES app.tbAnioLectivo (Ani_Id),
        -- El niño
        Asp_Nombres            nvarchar(100)  NOT NULL,
        Asp_Apellidos          nvarchar(100)  NOT NULL,
        Asp_Identidad          varchar(13)    NULL,
        Asp_FechaNacimiento    date           NOT NULL,
        Asp_Sexo               char(1)        NOT NULL,
        Asp_EscuelaProcedencia nvarchar(150)  NULL,
        -- El encargado
        Asp_EncargadoNombre    nvarchar(150)  NOT NULL,
        Asp_EncargadoIdentidad varchar(13)    NULL,
        Par_Id                 int            NULL CONSTRAINT FK_tbAspirantes_tbParentescos REFERENCES app.tbParentescos (Par_Id),
        Asp_EncargadoTelefono  varchar(20)    NOT NULL,
        Asp_EncargadoCorreo    nvarchar(150)  NULL,
        -- A qué aspira
        Niv_Id                 int            NOT NULL CONSTRAINT FK_tbAspirantes_tbNivelesEducativos REFERENCES app.tbNivelesEducativos (Niv_Id),
        Cun_Id                 int            NOT NULL CONSTRAINT FK_tbAspirantes_tbCursosNiveles REFERENCES app.tbCursosNiveles (Cun_Id),
        Mda_Id                 int            NULL CONSTRAINT FK_tbAspirantes_tbModalidades REFERENCES app.tbModalidades (Mda_Id),
        Cur_Id                 int            NULL CONSTRAINT FK_tbAspirantes_tbCursos REFERENCES app.tbCursos (Cur_Id),
        -- La cola
        Asp_FechaSolicitud     date           NOT NULL,
        Asp_Estado             varchar(2)     NOT NULL CONSTRAINT DF_tbAspirantes_Estado DEFAULT ('EE'),
        Asp_Prioridad          int            NOT NULL CONSTRAINT DF_tbAspirantes_Prioridad DEFAULT (0),
        Asp_MotivoPrioridad    nvarchar(200)  NULL,
        Asp_Posicion           int            NOT NULL,
        Asp_MotivoDecision     nvarchar(500)  NULL,
        Asp_FechaOferta        datetime       NULL,
        Asp_UsuarioOferta      int            NULL,
        Asp_FechaDecision      datetime       NULL,
        Asp_UsuarioDecision    int            NULL,
        Alu_Id                 int            NULL CONSTRAINT FK_tbAspirantes_tbAlumnos REFERENCES app.tbAlumnos (Alu_Id),
        Asp_Notas              nvarchar(1000) NULL,
        -- Auditoría y borrado lógico
        Asp_EsEliminado        bit            NOT NULL CONSTRAINT DF_tbAspirantes_EsEliminado DEFAULT (0),
        Asp_UsuarioRegistra    int            NULL,
        Asp_FechaRegistra      datetime       NOT NULL CONSTRAINT DF_tbAspirantes_FechaRegistra DEFAULT (GETDATE()),
        Asp_UsuarioModifica    int            NULL,
        Asp_FechaModifica      datetime       NULL,
        CONSTRAINT CK_tbAspirantes_Estado CHECK (Asp_Estado IN ('EE','OF','MA','RE','DE')),
        CONSTRAINT CK_tbAspirantes_Prioridad CHECK (Asp_Prioridad BETWEEN 0 AND 2),
        CONSTRAINT CK_tbAspirantes_Sexo CHECK (Asp_Sexo IN ('M','F'))
    );

    CREATE INDEX IX_tbAspirantes_Cola ON app.tbAspirantes (Ani_Id, Cun_Id, Asp_Estado)
        INCLUDE (Asp_Prioridad, Asp_Posicion, Mda_Id) WHERE Asp_EsEliminado = 0;
    CREATE INDEX IX_tbAspirantes_Identidad ON app.tbAspirantes (Asp_Identidad)
        WHERE Asp_Identidad IS NOT NULL AND Asp_EsEliminado = 0;
END
GO

IF OBJECT_ID('app.tbAspirantesHistorial') IS NULL
BEGIN
    CREATE TABLE app.tbAspirantesHistorial
    (
        Ash_Id             int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbAspirantesHistorial PRIMARY KEY,
        Asp_Id             int           NOT NULL CONSTRAINT FK_tbAspirantesHistorial_tbAspirantes REFERENCES app.tbAspirantes (Asp_Id),
        Ash_EstadoAnterior varchar(2)    NULL,      -- NULL = se registró
        Ash_EstadoNuevo    varchar(2)    NOT NULL,
        Ash_Motivo         nvarchar(500) NULL,
        Ash_Usuario        int           NULL,
        Ash_Fecha          datetime      NOT NULL CONSTRAINT DF_tbAspirantesHistorial_Fecha DEFAULT (GETDATE())
    );
    CREATE INDEX IX_tbAspirantesHistorial_Aspirante ON app.tbAspirantesHistorial (Asp_Id, Ash_Id);
END
GO

/* ---------------------------------------------------------------- Funciones */

-- Cupo de un grado en un año (o de un grado + modalidad si @Mda_Id no es NULL). Una sola fila.
CREATE OR ALTER FUNCTION app.FN_AspirantesCupo (@Ani_Id int, @Cun_Id int, @Mda_Id int)
RETURNS TABLE
AS
RETURN
    SELECT x.Secciones,
           x.SeccionesConCupo,
           x.Cupo,
           x.Matriculados,
           x.Ofertas,
           CAST(CASE WHEN x.Cupo IS NULL THEN 0 ELSE 1 END AS bit)  AS CupoDefinido,
           CASE WHEN x.Cupo IS NULL THEN NULL ELSE x.Cupo - x.Matriculados - x.Ofertas END AS Libres
    FROM (
        SELECT
            (SELECT COUNT(*) FROM app.tbSeccionesAnio s
              WHERE s.Ani_Id = @Ani_Id AND s.Cun_Id = @Cun_Id AND (@Mda_Id IS NULL OR s.Mda_Id = @Mda_Id)
                AND s.Sea_EsEliminado = 0 AND s.Sea_Estado IN (1, 2, 3))                                   AS Secciones,
            (SELECT COUNT(*) FROM app.tbSeccionesAnio s
              WHERE s.Ani_Id = @Ani_Id AND s.Cun_Id = @Cun_Id AND (@Mda_Id IS NULL OR s.Mda_Id = @Mda_Id)
                AND s.Sea_EsEliminado = 0 AND s.Sea_Estado IN (1, 2, 3) AND s.Sea_Cupo > 0)                AS SeccionesConCupo,
            CASE WHEN EXISTS (SELECT 1 FROM app.tbSeccionesAnio s
                               WHERE s.Ani_Id = @Ani_Id AND s.Cun_Id = @Cun_Id AND (@Mda_Id IS NULL OR s.Mda_Id = @Mda_Id)
                                 AND s.Sea_EsEliminado = 0 AND s.Sea_Estado IN (1, 2, 3))
                  AND NOT EXISTS (SELECT 1 FROM app.tbSeccionesAnio s
                               WHERE s.Ani_Id = @Ani_Id AND s.Cun_Id = @Cun_Id AND (@Mda_Id IS NULL OR s.Mda_Id = @Mda_Id)
                                 AND s.Sea_EsEliminado = 0 AND s.Sea_Estado IN (1, 2, 3) AND ISNULL(s.Sea_Cupo, 0) <= 0)
                 THEN (SELECT SUM(s.Sea_Cupo) FROM app.tbSeccionesAnio s
                        WHERE s.Ani_Id = @Ani_Id AND s.Cun_Id = @Cun_Id AND (@Mda_Id IS NULL OR s.Mda_Id = @Mda_Id)
                          AND s.Sea_EsEliminado = 0 AND s.Sea_Estado IN (1, 2, 3))
            END                                                                                            AS Cupo,
            (SELECT COUNT(*) FROM app.tbMatriculaAnio m
               JOIN app.tbSeccionesAnio s ON s.Sea_Id = m.Sea_Id
              WHERE m.Ani_Id = @Ani_Id AND m.Mta_EsEliminado = 0 AND m.Mta_Estado = 1
                AND s.Cun_Id = @Cun_Id AND (@Mda_Id IS NULL OR s.Mda_Id = @Mda_Id)
                AND s.Sea_EsEliminado = 0 AND s.Sea_Estado IN (1, 2, 3))                                   AS Matriculados,
            (SELECT COUNT(*) FROM app.tbAspirantes a
              WHERE a.Ani_Id = @Ani_Id AND a.Cun_Id = @Cun_Id AND (@Mda_Id IS NULL OR a.Mda_Id = @Mda_Id)
                AND a.Asp_Estado = 'OF' AND a.Asp_EsEliminado = 0)                                         AS Ofertas
    ) x;
GO

-- Texto en español de un estado.
CREATE OR ALTER FUNCTION app.FN_AspiranteEstadoTexto (@Estado varchar(2))
RETURNS nvarchar(20)
AS
BEGIN
    RETURN CASE @Estado WHEN 'EE' THEN N'En espera' WHEN 'OF' THEN N'Ofrecido' WHEN 'MA' THEN N'Matriculado'
                        WHEN 'RE' THEN N'Rechazado' WHEN 'DE' THEN N'Desistió' ELSE @Estado END;
END
GO

-- Edad cumplida a una fecha.
CREATE OR ALTER FUNCTION app.FN_EdadA (@Nacimiento date, @Fecha date)
RETURNS int
AS
BEGIN
    IF @Nacimiento IS NULL OR @Fecha IS NULL RETURN NULL;
    RETURN DATEDIFF(YEAR, @Nacimiento, @Fecha)
         - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @Nacimiento, @Fecha), @Nacimiento) > @Fecha THEN 1 ELSE 0 END;
END
GO

/* ---------------------------------------------------------------- Lecturas */

-- Años para el selector. EsPorDefecto: el año activo si sigue abierto; si no, el próximo programado o abierto.
CREATE OR ALTER PROCEDURE app.PR_tbAspirantes_Anios
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Activo int = (SELECT TRY_CAST(Con_Valor AS int) FROM app.tbConfiguracion WHERE Con_Clave = 'anio_lectivo_activo_id');
    DECLARE @AnioActivo int = (SELECT Ani_Anio FROM app.tbAnioLectivo WHERE Ani_Id = @Activo);

    DECLARE @PorDefecto int = (
        SELECT TOP (1) a.Ani_Id FROM app.tbAnioLectivo a
        WHERE a.Ani_EsEliminado = 0 AND a.Ani_Id = @Activo AND a.Ani_Estado BETWEEN 1 AND 3);
    IF @PorDefecto IS NULL
        SET @PorDefecto = (SELECT TOP (1) a.Ani_Id FROM app.tbAnioLectivo a
                           WHERE a.Ani_EsEliminado = 0 AND a.Ani_Estado IN (2, 3) AND a.Ani_Anio > ISNULL(@AnioActivo, 0)
                           ORDER BY a.Ani_Anio);
    IF @PorDefecto IS NULL SET @PorDefecto = @Activo;

    SELECT a.Ani_Id,
           a.Ani_Anio,
           CAST(a.Ani_Nombre AS nvarchar(20))                                    AS Ani_Nombre,
           CAST(a.Ani_Estado AS int)                                             AS Ani_Estado,
           CAST(CASE WHEN a.Ani_Id = @Activo THEN 1 ELSE 0 END AS bit)            AS EsActivo,
           CAST(CASE WHEN a.Ani_Id = @PorDefecto THEN 1 ELSE 0 END AS bit)        AS EsPorDefecto,
           CAST(CASE WHEN a.Ani_Estado BETWEEN 1 AND 3 THEN 1 ELSE 0 END AS bit)  AS AdmiteRegistro,
           (SELECT COUNT(*) FROM app.tbAspirantes x
             WHERE x.Ani_Id = a.Ani_Id AND x.Asp_EsEliminado = 0 AND x.Asp_Estado IN ('EE','OF')) AS Abiertos
    FROM app.tbAnioLectivo a
    WHERE a.Ani_EsEliminado = 0
    ORDER BY a.Ani_Anio;
END
GO

-- Resumen por grado de un año: lo que mira Dirección para decidir si abre otra sección.
CREATE OR ALTER PROCEDURE app.PR_tbAspirantes_Resumen
    @Ani_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT n.Niv_Id,
           CAST(n.Niv_Descripcion AS nvarchar(100))                       AS Niv_Descripcion,
           g.Cun_Id,
           CAST(g.Cun_Descripcion AS nvarchar(100))                       AS Cun_Descripcion,
           ISNULL(g.Cun_Orden, 0)                                         AS Cun_Orden,
           c.Secciones,
           c.SeccionesConCupo,
           c.Cupo,
           c.Matriculados,
           c.Ofertas,
           c.CupoDefinido,
           c.Libres,
           (SELECT COUNT(*) FROM app.tbAspirantes a WHERE a.Ani_Id = @Ani_Id AND a.Cun_Id = g.Cun_Id AND a.Asp_EsEliminado = 0 AND a.Asp_Estado = 'EE') AS EnEspera,
           (SELECT COUNT(*) FROM app.tbAspirantes a WHERE a.Ani_Id = @Ani_Id AND a.Cun_Id = g.Cun_Id AND a.Asp_EsEliminado = 0 AND a.Asp_Estado = 'MA') AS MatriculadosLista,
           (SELECT COUNT(*) FROM app.tbAspirantes a WHERE a.Ani_Id = @Ani_Id AND a.Cun_Id = g.Cun_Id AND a.Asp_EsEliminado = 0 AND a.Asp_Estado IN ('RE','DE')) AS Cerrados,
           s.Asp_Id                                                       AS SiguienteId,
           s.Nombre                                                       AS SiguienteNombre
    FROM app.tbCursosNiveles g
    JOIN app.tbNivelesEducativos n ON n.Niv_Id = g.Niv_Id
    CROSS APPLY app.FN_AspirantesCupo(@Ani_Id, g.Cun_Id, NULL) c
    OUTER APPLY (
        SELECT TOP (1) a.Asp_Id, CONCAT(a.Asp_Nombres, N' ', a.Asp_Apellidos) AS Nombre
        FROM app.tbAspirantes a
        WHERE a.Ani_Id = @Ani_Id AND a.Cun_Id = g.Cun_Id AND a.Asp_EsEliminado = 0 AND a.Asp_Estado = 'EE'
        ORDER BY a.Asp_Prioridad DESC, a.Asp_Posicion
    ) s
    WHERE g.Cun_EsEliminado = 0 AND n.Niv_EsEliminado = 0
    ORDER BY n.Niv_Id, ISNULL(g.Cun_Orden, 0), g.Cun_Id;
END
GO

-- Aspirantes de un año en el orden de la cola: por grado; dentro, ofertas abiertas, luego la cola
-- (prioridad desc, posición asc) y al final los cerrados (decisión más reciente primero).
CREATE OR ALTER PROCEDURE app.PR_tbAspirantes_List
    @Ani_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);

    ;WITH Cola AS (
        SELECT a.Asp_Id,
               ROW_NUMBER() OVER (PARTITION BY a.Ani_Id, a.Cun_Id ORDER BY a.Asp_Prioridad DESC, a.Asp_Posicion) AS PosicionCola
        FROM app.tbAspirantes a
        WHERE a.Ani_Id = @Ani_Id AND a.Asp_EsEliminado = 0 AND a.Asp_Estado = 'EE'
    )
    SELECT a.Asp_Id,
           a.Ani_Id,
           a.Asp_Nombres,
           a.Asp_Apellidos,
           CONCAT(a.Asp_Nombres, N' ', a.Asp_Apellidos)                                   AS Aspirante,
           a.Asp_Identidad,
           a.Asp_FechaNacimiento,
           app.FN_EdadA(a.Asp_FechaNacimiento, @Hoy)                                       AS Edad,
           a.Asp_Sexo,
           a.Asp_EscuelaProcedencia,
           a.Asp_EncargadoNombre,
           a.Par_Id,
           CAST(p.Par_Descripcion AS nvarchar(100))                                       AS Par_Descripcion,
           a.Asp_EncargadoTelefono,
           a.Asp_EncargadoCorreo,
           a.Niv_Id,
           CAST(n.Niv_Descripcion AS nvarchar(100))                                       AS Niv_Descripcion,
           a.Cun_Id,
           CAST(g.Cun_Descripcion AS nvarchar(100))                                       AS Cun_Descripcion,
           a.Mda_Id,
           CAST(m.Mda_Descripcion AS nvarchar(100))                                       AS Mda_Descripcion,
           a.Cur_Id,
           LTRIM(RTRIM(REPLACE(REPLACE(cu.Cur_Nombre, CHAR(13), N''), CHAR(10), N'')))    AS Cur_Nombre,
           a.Asp_FechaSolicitud,
           a.Asp_Estado,
           a.Asp_Prioridad,
           a.Asp_MotivoPrioridad,
           a.Asp_Posicion,
           cola.PosicionCola,
           CAST(CASE WHEN cola.PosicionCola = 1 THEN 1 ELSE 0 END AS bit)                 AS EsSiguiente,
           cg.CupoDefinido,
           cg.Libres,
           CAST(CASE WHEN cola.PosicionCola = 1
                      AND (cg.CupoDefinido = 0 OR cg.Libres > 0)
                      AND (cm.CupoDefinido IS NULL OR cm.CupoDefinido = 0 OR cm.Libres > 0)
                     THEN 1 ELSE 0 END AS bit)                                            AS PuedeOfrecer,
           a.Asp_FechaOferta,
           a.Asp_FechaDecision,
           a.Asp_MotivoDecision,
           a.Alu_Id,
           ISNULL(g.Cun_Orden, 0)                                                         AS Cun_Orden
    FROM app.tbAspirantes a
    JOIN app.tbNivelesEducativos n ON n.Niv_Id = a.Niv_Id
    JOIN app.tbCursosNiveles g ON g.Cun_Id = a.Cun_Id
    LEFT JOIN app.tbModalidades m ON m.Mda_Id = a.Mda_Id
    LEFT JOIN app.tbCursos cu ON cu.Cur_Id = a.Cur_Id
    LEFT JOIN app.tbParentescos p ON p.Par_Id = a.Par_Id
    LEFT JOIN Cola cola ON cola.Asp_Id = a.Asp_Id
    CROSS APPLY app.FN_AspirantesCupo(a.Ani_Id, a.Cun_Id, NULL) cg
    OUTER APPLY (SELECT * FROM app.FN_AspirantesCupo(a.Ani_Id, a.Cun_Id, a.Mda_Id) WHERE a.Mda_Id IS NOT NULL) cm
    WHERE a.Ani_Id = @Ani_Id AND a.Asp_EsEliminado = 0
    ORDER BY a.Niv_Id, ISNULL(g.Cun_Orden, 0), a.Cun_Id,
             CASE a.Asp_Estado WHEN 'OF' THEN 0 WHEN 'EE' THEN 1 ELSE 2 END,
             CASE WHEN a.Asp_Estado = 'OF' THEN a.Asp_FechaOferta END,
             CASE WHEN a.Asp_Estado = 'EE' THEN cola.PosicionCola END,
             a.Asp_FechaDecision DESC, a.Asp_Id;
END
GO

-- Un aspirante con su lugar en la cola y el cupo de su grado. Sin fila si no existe.
CREATE OR ALTER PROCEDURE app.PR_tbAspirantes_Find
    @Asp_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    DECLARE @Activo int = (SELECT TRY_CAST(Con_Valor AS int) FROM app.tbConfiguracion WHERE Con_Clave = 'anio_lectivo_activo_id');

    SELECT a.Asp_Id,
           a.Ani_Id,
           CAST(an.Ani_Nombre AS nvarchar(20))                                            AS Ani_Nombre,
           CAST(CASE WHEN a.Ani_Id = @Activo THEN 1 ELSE 0 END AS bit)                     AS EsAnioActivo,
           a.Asp_Nombres,
           a.Asp_Apellidos,
           CONCAT(a.Asp_Nombres, N' ', a.Asp_Apellidos)                                   AS Aspirante,
           a.Asp_Identidad,
           a.Asp_FechaNacimiento,
           app.FN_EdadA(a.Asp_FechaNacimiento, @Hoy)                                       AS Edad,
           a.Asp_Sexo,
           a.Asp_EscuelaProcedencia,
           a.Asp_EncargadoNombre,
           a.Asp_EncargadoIdentidad,
           a.Par_Id,
           CAST(p.Par_Descripcion AS nvarchar(100))                                       AS Par_Descripcion,
           a.Asp_EncargadoTelefono,
           a.Asp_EncargadoCorreo,
           a.Niv_Id,
           CAST(n.Niv_Descripcion AS nvarchar(100))                                       AS Niv_Descripcion,
           a.Cun_Id,
           CAST(g.Cun_Descripcion AS nvarchar(100))                                       AS Cun_Descripcion,
           a.Mda_Id,
           CAST(m.Mda_Descripcion AS nvarchar(100))                                       AS Mda_Descripcion,
           a.Cur_Id,
           LTRIM(RTRIM(REPLACE(REPLACE(cu.Cur_Nombre, CHAR(13), N''), CHAR(10), N'')))    AS Cur_Nombre,
           a.Asp_FechaSolicitud,
           a.Asp_Estado,
           a.Asp_Prioridad,
           a.Asp_MotivoPrioridad,
           a.Asp_Posicion,
           cola.PosicionCola,
           (SELECT COUNT(*) FROM app.tbAspirantes x
             WHERE x.Ani_Id = a.Ani_Id AND x.Cun_Id = a.Cun_Id AND x.Asp_EsEliminado = 0 AND x.Asp_Estado = 'EE') AS EnCola,
           sig.Asp_Id                                                                     AS SiguienteId,
           sig.Nombre                                                                     AS SiguienteNombre,
           cg.Secciones,
           cg.SeccionesConCupo,
           cg.Cupo,
           cg.Matriculados,
           cg.Ofertas,
           cg.CupoDefinido,
           cg.Libres,
           cm.CupoDefinido                                                                AS CupoModalidadDefinido,
           cm.Libres                                                                      AS LibresModalidad,
           CAST(CASE WHEN a.Asp_Estado = 'EE' AND cola.PosicionCola = 1
                      AND (cg.CupoDefinido = 0 OR cg.Libres > 0)
                      AND (cm.CupoDefinido IS NULL OR cm.CupoDefinido = 0 OR cm.Libres > 0)
                     THEN 1 ELSE 0 END AS bit)                                            AS PuedeOfrecer,
           a.Asp_MotivoDecision,
           a.Asp_FechaOferta,
           app.FN_NombreUsuario(a.Asp_UsuarioOferta)                                      AS UsuarioOferta,
           a.Asp_FechaDecision,
           app.FN_NombreUsuario(a.Asp_UsuarioDecision)                                    AS UsuarioDecision,
           a.Alu_Id,
           a.Asp_Notas,
           a.Asp_FechaRegistra,
           app.FN_NombreUsuario(a.Asp_UsuarioRegistra)                                    AS UsuarioRegistra,
           a.Asp_FechaModifica
    FROM app.tbAspirantes a
    JOIN app.tbAnioLectivo an ON an.Ani_Id = a.Ani_Id
    JOIN app.tbNivelesEducativos n ON n.Niv_Id = a.Niv_Id
    JOIN app.tbCursosNiveles g ON g.Cun_Id = a.Cun_Id
    LEFT JOIN app.tbModalidades m ON m.Mda_Id = a.Mda_Id
    LEFT JOIN app.tbCursos cu ON cu.Cur_Id = a.Cur_Id
    LEFT JOIN app.tbParentescos p ON p.Par_Id = a.Par_Id
    OUTER APPLY (
        SELECT r.PosicionCola FROM (
            SELECT x.Asp_Id, ROW_NUMBER() OVER (ORDER BY x.Asp_Prioridad DESC, x.Asp_Posicion) AS PosicionCola
            FROM app.tbAspirantes x
            WHERE x.Ani_Id = a.Ani_Id AND x.Cun_Id = a.Cun_Id AND x.Asp_EsEliminado = 0 AND x.Asp_Estado = 'EE'
        ) r WHERE r.Asp_Id = a.Asp_Id
    ) cola
    OUTER APPLY (
        SELECT TOP (1) x.Asp_Id, CONCAT(x.Asp_Nombres, N' ', x.Asp_Apellidos) AS Nombre
        FROM app.tbAspirantes x
        WHERE x.Ani_Id = a.Ani_Id AND x.Cun_Id = a.Cun_Id AND x.Asp_EsEliminado = 0 AND x.Asp_Estado = 'EE'
        ORDER BY x.Asp_Prioridad DESC, x.Asp_Posicion
    ) sig
    CROSS APPLY app.FN_AspirantesCupo(a.Ani_Id, a.Cun_Id, NULL) cg
    OUTER APPLY (SELECT * FROM app.FN_AspirantesCupo(a.Ani_Id, a.Cun_Id, a.Mda_Id) WHERE a.Mda_Id IS NOT NULL) cm
    WHERE a.Asp_Id = @Asp_Id AND a.Asp_EsEliminado = 0;
END
GO

-- Línea de tiempo de un aspirante (más antiguo primero).
CREATE OR ALTER PROCEDURE app.PR_tbAspirantesHistorial_List
    @Asp_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT h.Ash_Id,
           h.Asp_Id,
           h.Ash_EstadoAnterior,
           h.Ash_EstadoNuevo,
           h.Ash_Motivo,
           h.Ash_Usuario,
           app.FN_NombreUsuario(h.Ash_Usuario) AS Usuario,
           h.Ash_Fecha
    FROM app.tbAspirantesHistorial h
    WHERE h.Asp_Id = @Asp_Id
    ORDER BY h.Ash_Fecha, h.Ash_Id;
END
GO

-- Revisión en vivo del formulario: ¿ya hay un aspirante abierto igual en ese año? ¿la identidad es de un alumno?
CREATE OR ALTER PROCEDURE app.PR_tbAspirantes_Duplicado
    @Ani_Id              int,
    @Asp_Identidad       varchar(13)   = NULL,
    @Asp_Nombres         nvarchar(100) = NULL,
    @Asp_Apellidos       nvarchar(100) = NULL,
    @Asp_FechaNacimiento date          = NULL,
    @Asp_Id              int           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Asp_Identidad = NULLIF(LTRIM(RTRIM(@Asp_Identidad)), '');
    SET @Asp_Nombres   = NULLIF(LTRIM(RTRIM(@Asp_Nombres)), N'');
    SET @Asp_Apellidos = NULLIF(LTRIM(RTRIM(@Asp_Apellidos)), N'');

    DECLARE @DupId int, @DupNombre nvarchar(210), @DupEstado varchar(2), @DupGrado nvarchar(100);
    SELECT TOP (1) @DupId = a.Asp_Id, @DupNombre = CONCAT(a.Asp_Nombres, N' ', a.Asp_Apellidos),
                   @DupEstado = a.Asp_Estado, @DupGrado = CAST(g.Cun_Descripcion AS nvarchar(100))
    FROM app.tbAspirantes a
    JOIN app.tbCursosNiveles g ON g.Cun_Id = a.Cun_Id
    WHERE a.Ani_Id = @Ani_Id AND a.Asp_EsEliminado = 0 AND a.Asp_Estado IN ('EE','OF')
      AND a.Asp_Id <> ISNULL(@Asp_Id, 0)
      AND (   (@Asp_Identidad IS NOT NULL AND a.Asp_Identidad = @Asp_Identidad)
           OR (@Asp_Nombres IS NOT NULL AND @Asp_Apellidos IS NOT NULL AND @Asp_FechaNacimiento IS NOT NULL
               AND a.Asp_FechaNacimiento = @Asp_FechaNacimiento
               AND LTRIM(RTRIM(a.Asp_Nombres))   COLLATE Latin1_General_CI_AI = @Asp_Nombres   COLLATE Latin1_General_CI_AI
               AND LTRIM(RTRIM(a.Asp_Apellidos)) COLLATE Latin1_General_CI_AI = @Asp_Apellidos COLLATE Latin1_General_CI_AI))
    ORDER BY a.Asp_Id;

    DECLARE @AluId int, @AluNombre nvarchar(210), @AluEnAnio bit = 0;
    IF @Asp_Identidad IS NOT NULL
        SELECT TOP (1) @AluId = al.Alu_Id,
                       @AluNombre = CONCAT_WS(N' ', NULLIF(pe.Per_PrimerNombre, N''), NULLIF(pe.Per_ApellidoPaterno, N''), NULLIF(pe.Per_ApellidoMaterno, N'')),
                       @AluEnAnio = CAST(CASE WHEN EXISTS (SELECT 1 FROM app.tbMatriculaAnio mt
                                                            WHERE mt.Alu_Id = al.Alu_Id AND mt.Ani_Id = @Ani_Id
                                                              AND mt.Mta_EsEliminado = 0 AND mt.Mta_Estado = 1) THEN 1 ELSE 0 END AS bit)
        FROM app.tbAlumnos al
        JOIN app.tbPersonas pe ON pe.Per_Id = al.Per_Id
        WHERE pe.Per_Identidad = @Asp_Identidad AND pe.Per_EsEliminado = 0
        ORDER BY al.Alu_Id DESC;

    SELECT @DupId AS AspiranteId, @DupNombre AS AspiranteNombre, @DupEstado AS AspiranteEstado, @DupGrado AS AspiranteGrado,
           @AluId AS AlumnoId, @AluNombre AS AlumnoNombre, ISNULL(@AluEnAnio, CAST(0 AS bit)) AS AlumnoMatriculadoEnAnio;
END
GO

-- Cursos (carrera / plan) que se imparten en un grado, para la cascada "Aspira a".
-- El dropdown general de cursos filtra por modalidad y trae todos; aquí se filtra por el grado.
CREATE OR ALTER PROCEDURE app.PR_tbAspirantes_Cursos
    @Cun_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.Cur_Id,
           LTRIM(RTRIM(REPLACE(REPLACE(c.Cur_Nombre, CHAR(13), N''), CHAR(10), N''))) AS Cur_Nombre
    FROM app.tbCursos c
    JOIN app.tbCursos_tbCursosNiveles cc ON cc.Cur_Id = c.Cur_Id
    WHERE cc.Cun_Id = @Cun_Id AND c.Cur_EsEliminado = 0
    ORDER BY c.Cur_Id;
END
GO

/* ---------------------------------------------------------------- Escrituras */

-- Registrar (Asp_Id NULL/0) o editar un aspirante abierto. Devuelve Asp_Id, posición y lugar en la cola.
CREATE OR ALTER PROCEDURE app.PR_tbAspirantes_Guardar
    @Asp_Id                 int            = NULL,
    @Ani_Id                 int,
    @Asp_Nombres            nvarchar(100),
    @Asp_Apellidos          nvarchar(100),
    @Asp_Identidad          varchar(13)    = NULL,
    @Asp_FechaNacimiento    date,
    @Asp_Sexo               char(1),
    @Asp_EscuelaProcedencia nvarchar(150)  = NULL,
    @Asp_EncargadoNombre    nvarchar(150),
    @Asp_EncargadoIdentidad varchar(13)    = NULL,
    @Par_Id                 int            = NULL,
    @Asp_EncargadoTelefono  varchar(20),
    @Asp_EncargadoCorreo    nvarchar(150)  = NULL,
    @Niv_Id                 int,
    @Cun_Id                 int,
    @Mda_Id                 int            = NULL,
    @Cur_Id                 int            = NULL,
    @Asp_FechaSolicitud     date           = NULL,
    @Asp_Prioridad          int            = 0,
    @Asp_MotivoPrioridad    nvarchar(200)  = NULL,
    @Asp_Notas              nvarchar(1000) = NULL,
    @Usuario                int            = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Ahora datetime = app.FN_AhoraHonduras();
    DECLARE @Hoy date = CAST(@Ahora AS date);

    SET @Asp_Id                 = NULLIF(@Asp_Id, 0);
    SET @Asp_Nombres            = LTRIM(RTRIM(ISNULL(@Asp_Nombres, N'')));
    SET @Asp_Apellidos          = LTRIM(RTRIM(ISNULL(@Asp_Apellidos, N'')));
    SET @Asp_Identidad          = NULLIF(LTRIM(RTRIM(@Asp_Identidad)), '');
    SET @Asp_EscuelaProcedencia = NULLIF(LTRIM(RTRIM(@Asp_EscuelaProcedencia)), N'');
    SET @Asp_EncargadoNombre    = LTRIM(RTRIM(ISNULL(@Asp_EncargadoNombre, N'')));
    SET @Asp_EncargadoIdentidad = NULLIF(LTRIM(RTRIM(@Asp_EncargadoIdentidad)), '');
    SET @Asp_EncargadoTelefono  = LTRIM(RTRIM(ISNULL(@Asp_EncargadoTelefono, '')));
    SET @Asp_EncargadoCorreo    = NULLIF(LTRIM(RTRIM(@Asp_EncargadoCorreo)), N'');
    SET @Asp_MotivoPrioridad    = NULLIF(LTRIM(RTRIM(@Asp_MotivoPrioridad)), N'');
    SET @Asp_Notas              = NULLIF(LTRIM(RTRIM(@Asp_Notas)), N'');
    SET @Mda_Id                 = NULLIF(@Mda_Id, 0);
    SET @Cur_Id                 = NULLIF(@Cur_Id, 0);
    SET @Par_Id                 = NULLIF(@Par_Id, 0);
    SET @Asp_FechaSolicitud     = ISNULL(@Asp_FechaSolicitud, @Hoy);
    SET @Asp_Prioridad          = ISNULL(@Asp_Prioridad, 0);
    IF @Asp_Prioridad = 0 SET @Asp_MotivoPrioridad = NULL;

    IF @Asp_Nombres = N'' OR @Asp_Apellidos = N''
        THROW 50071, N'Escriba los nombres y los apellidos del aspirante.', 1;
    IF @Asp_FechaNacimiento IS NULL OR @Asp_FechaNacimiento > @Hoy OR YEAR(@Asp_FechaNacimiento) < 1990
        THROW 50072, N'Revise la fecha de nacimiento.', 1;
    IF @Asp_Sexo IS NULL OR @Asp_Sexo NOT IN ('M','F')
        THROW 50073, N'Elija el sexo del aspirante.', 1;
    IF @Asp_Identidad IS NOT NULL AND (LEN(@Asp_Identidad) <> 13 OR @Asp_Identidad LIKE '%[^0-9]%')
        THROW 50074, N'La identidad lleva 13 números (o déjela vacía).', 1;
    IF @Asp_EncargadoIdentidad IS NOT NULL AND (LEN(@Asp_EncargadoIdentidad) <> 13 OR @Asp_EncargadoIdentidad LIKE '%[^0-9]%')
        THROW 50074, N'La identidad del encargado lleva 13 números (o déjela vacía).', 1;
    IF @Asp_EncargadoNombre = N''
        THROW 50075, N'Escriba el nombre del encargado.', 1;
    IF @Asp_EncargadoTelefono = '' OR @Asp_EncargadoTelefono LIKE '%[^0-9 +-]%' OR LEN(REPLACE(REPLACE(REPLACE(@Asp_EncargadoTelefono, ' ', ''), '-', ''), '+', '')) < 8
        THROW 50076, N'Escriba un teléfono del encargado de al menos 8 números.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id AND Ani_EsEliminado = 0 AND Ani_Estado BETWEEN 1 AND 3)
        THROW 50077, N'Ese año lectivo ya no admite aspirantes.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbCursosNiveles WHERE Cun_Id = @Cun_Id AND Niv_Id = @Niv_Id AND Cun_EsEliminado = 0)
        THROW 50078, N'Elija un grado del nivel seleccionado.', 1;
    IF @Mda_Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM app.tbModalidades WHERE Mda_Id = @Mda_Id AND Mda_EsEliminado = 0)
        THROW 50078, N'La modalidad elegida ya no existe.', 1;
    IF @Cur_Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM app.tbCursos c
                                           JOIN app.tbCursos_tbCursosNiveles cc ON cc.Cur_Id = c.Cur_Id
                                           WHERE c.Cur_Id = @Cur_Id AND cc.Cun_Id = @Cun_Id AND c.Cur_EsEliminado = 0)
        THROW 50079, N'Elija un curso que se imparta en ese grado.', 1;
    IF @Cur_Id IS NOT NULL AND @Mda_Id IS NULL
        THROW 50079, N'Para elegir el curso primero elija la modalidad.', 1;
    IF @Asp_Prioridad NOT BETWEEN 0 AND 2
        THROW 50080, N'Elija la prioridad.', 1;
    IF @Asp_Prioridad > 0 AND @Asp_MotivoPrioridad IS NULL
        THROW 50081, N'Diga por qué tiene prioridad (por ejemplo: hermano en el colegio, hijo de empleado).', 1;
    IF @Asp_FechaSolicitud > @Hoy
        THROW 50086, N'La fecha de solicitud no puede ser futura.', 1;
    IF @Par_Id IS NULL OR NOT EXISTS (SELECT 1 FROM app.tbParentescos WHERE Par_Id = @Par_Id AND Par_EsEliminado = 0)
        THROW 50087, N'Elija el parentesco del encargado.', 1;

    DECLARE @Recurso nvarchar(100) = CONCAT(N'aspirantes-', @Ani_Id, N'-', @Cun_Id);
    DECLARE @Posicion int, @Nuevo bit = CASE WHEN @Asp_Id IS NULL THEN 1 ELSE 0 END;

    BEGIN TRY
        BEGIN TRANSACTION;
        -- Una sola escritura a la vez por cola: la posición máx + 1 no se repite.
        EXEC sp_getapplock @Resource = @Recurso, @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = 10000;

        -- Duplicado abierto en el mismo año (misma identidad, o mismo nombre + fecha de nacimiento).
        DECLARE @Dup nvarchar(300) = (
            SELECT TOP (1) CONCAT(a.Asp_Nombres, N' ', a.Asp_Apellidos, N' (', app.FN_AspiranteEstadoTexto(a.Asp_Estado), N', ',
                                  CAST(g.Cun_Descripcion AS nvarchar(100)), N')')
            FROM app.tbAspirantes a
            JOIN app.tbCursosNiveles g ON g.Cun_Id = a.Cun_Id
            WHERE a.Ani_Id = @Ani_Id AND a.Asp_EsEliminado = 0 AND a.Asp_Estado IN ('EE','OF')
              AND a.Asp_Id <> ISNULL(@Asp_Id, 0)
              AND (   (@Asp_Identidad IS NOT NULL AND a.Asp_Identidad = @Asp_Identidad)
                   OR (a.Asp_FechaNacimiento = @Asp_FechaNacimiento
                       AND LTRIM(RTRIM(a.Asp_Nombres))   COLLATE Latin1_General_CI_AI = @Asp_Nombres   COLLATE Latin1_General_CI_AI
                       AND LTRIM(RTRIM(a.Asp_Apellidos)) COLLATE Latin1_General_CI_AI = @Asp_Apellidos COLLATE Latin1_General_CI_AI))
            ORDER BY a.Asp_Id);
        IF @Dup IS NOT NULL
        BEGIN
            DECLARE @MsgDup nvarchar(400) = CONCAT(N'Ya está en la lista de este año: ', @Dup, N'.');
            THROW 50082, @MsgDup, 1;
        END

        IF @Nuevo = 1
        BEGIN
            SET @Posicion = ISNULL((SELECT MAX(Asp_Posicion) FROM app.tbAspirantes WITH (UPDLOCK, HOLDLOCK)
                                     WHERE Ani_Id = @Ani_Id AND Cun_Id = @Cun_Id AND Asp_EsEliminado = 0), 0) + 1;

            INSERT INTO app.tbAspirantes
                (Ani_Id, Asp_Nombres, Asp_Apellidos, Asp_Identidad, Asp_FechaNacimiento, Asp_Sexo, Asp_EscuelaProcedencia,
                 Asp_EncargadoNombre, Asp_EncargadoIdentidad, Par_Id, Asp_EncargadoTelefono, Asp_EncargadoCorreo,
                 Niv_Id, Cun_Id, Mda_Id, Cur_Id, Asp_FechaSolicitud, Asp_Estado, Asp_Prioridad, Asp_MotivoPrioridad,
                 Asp_Posicion, Asp_Notas, Asp_EsEliminado, Asp_UsuarioRegistra, Asp_FechaRegistra)
            VALUES
                (@Ani_Id, @Asp_Nombres, @Asp_Apellidos, @Asp_Identidad, @Asp_FechaNacimiento, @Asp_Sexo, @Asp_EscuelaProcedencia,
                 @Asp_EncargadoNombre, @Asp_EncargadoIdentidad, @Par_Id, @Asp_EncargadoTelefono, @Asp_EncargadoCorreo,
                 @Niv_Id, @Cun_Id, @Mda_Id, @Cur_Id, @Asp_FechaSolicitud, 'EE', @Asp_Prioridad, @Asp_MotivoPrioridad,
                 @Posicion, @Asp_Notas, 0, @Usuario, @Ahora);
            SET @Asp_Id = SCOPE_IDENTITY();

            INSERT INTO app.tbAspirantesHistorial (Asp_Id, Ash_EstadoAnterior, Ash_EstadoNuevo, Ash_Motivo, Ash_Usuario, Ash_Fecha)
            VALUES (@Asp_Id, NULL, 'EE',
                    CASE WHEN @Asp_Prioridad > 0
                         THEN CONCAT(N'Se registró con prioridad ', CASE @Asp_Prioridad WHEN 2 THEN N'alta' ELSE N'media' END, N': ', @Asp_MotivoPrioridad)
                         ELSE N'Se registró en la lista de espera.' END,
                    @Usuario, @Ahora);
        END
        ELSE
        BEGIN
            DECLARE @Estado varchar(2), @AniAntes int, @CunAntes int, @PrioridadAntes int;
            SELECT @Estado = Asp_Estado, @AniAntes = Ani_Id, @CunAntes = Cun_Id, @PrioridadAntes = Asp_Prioridad, @Posicion = Asp_Posicion
            FROM app.tbAspirantes WITH (UPDLOCK, HOLDLOCK)
            WHERE Asp_Id = @Asp_Id AND Asp_EsEliminado = 0;

            IF @Estado IS NULL
                THROW 50083, N'El aspirante ya no existe.', 1;
            IF @Estado NOT IN ('EE','OF')
                THROW 50084, N'Un aspirante matriculado, rechazado o que desistió ya no se edita. Reactívelo primero si vuelve a la lista.', 1;
            IF @Estado = 'OF' AND (@AniAntes <> @Ani_Id OR @CunAntes <> @Cun_Id)
                THROW 50085, N'Tiene una oferta abierta en su grado: no se puede cambiar el año ni el grado.', 1;

            -- Cambia de cola: queda al final de la nueva.
            IF @AniAntes <> @Ani_Id OR @CunAntes <> @Cun_Id
            BEGIN
                DECLARE @Recurso2 nvarchar(100) = CONCAT(N'aspirantes-', @AniAntes, N'-', @CunAntes);
                EXEC sp_getapplock @Resource = @Recurso2, @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = 10000;
                SET @Posicion = ISNULL((SELECT MAX(Asp_Posicion) FROM app.tbAspirantes WITH (UPDLOCK, HOLDLOCK)
                                         WHERE Ani_Id = @Ani_Id AND Cun_Id = @Cun_Id AND Asp_EsEliminado = 0 AND Asp_Id <> @Asp_Id), 0) + 1;
            END

            UPDATE app.tbAspirantes
            SET Ani_Id = @Ani_Id, Asp_Nombres = @Asp_Nombres, Asp_Apellidos = @Asp_Apellidos, Asp_Identidad = @Asp_Identidad,
                Asp_FechaNacimiento = @Asp_FechaNacimiento, Asp_Sexo = @Asp_Sexo, Asp_EscuelaProcedencia = @Asp_EscuelaProcedencia,
                Asp_EncargadoNombre = @Asp_EncargadoNombre, Asp_EncargadoIdentidad = @Asp_EncargadoIdentidad, Par_Id = @Par_Id,
                Asp_EncargadoTelefono = @Asp_EncargadoTelefono, Asp_EncargadoCorreo = @Asp_EncargadoCorreo,
                Niv_Id = @Niv_Id, Cun_Id = @Cun_Id, Mda_Id = @Mda_Id, Cur_Id = @Cur_Id, Asp_FechaSolicitud = @Asp_FechaSolicitud,
                Asp_Prioridad = @Asp_Prioridad, Asp_MotivoPrioridad = @Asp_MotivoPrioridad, Asp_Posicion = @Posicion,
                Asp_Notas = @Asp_Notas, Asp_UsuarioModifica = @Usuario, Asp_FechaModifica = @Ahora
            WHERE Asp_Id = @Asp_Id;

            IF @PrioridadAntes <> @Asp_Prioridad
                INSERT INTO app.tbAspirantesHistorial (Asp_Id, Ash_EstadoAnterior, Ash_EstadoNuevo, Ash_Motivo, Ash_Usuario, Ash_Fecha)
                VALUES (@Asp_Id, @Estado, @Estado,
                        CONCAT(N'Prioridad: ', CASE @PrioridadAntes WHEN 2 THEN N'alta' WHEN 1 THEN N'media' ELSE N'normal' END, N' → ',
                               CASE @Asp_Prioridad WHEN 2 THEN N'alta' WHEN 1 THEN N'media' ELSE N'normal' END,
                               CASE WHEN @Asp_MotivoPrioridad IS NULL THEN N'' ELSE CONCAT(N'. ', @Asp_MotivoPrioridad) END),
                        @Usuario, @Ahora);
            IF @AniAntes <> @Ani_Id OR @CunAntes <> @Cun_Id
                INSERT INTO app.tbAspirantesHistorial (Asp_Id, Ash_EstadoAnterior, Ash_EstadoNuevo, Ash_Motivo, Ash_Usuario, Ash_Fecha)
                VALUES (@Asp_Id, @Estado, @Estado, N'Cambió de grado o de año: pasó al final de la nueva cola.', @Usuario, @Ahora);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    -- Aviso (no bloquea): la identidad ya es de un alumno matriculado ese año.
    DECLARE @Aviso nvarchar(300) = NULL;
    IF @Asp_Identidad IS NOT NULL
        SELECT TOP (1) @Aviso = CONCAT(N'La identidad es del alumno ',
                                       CONCAT_WS(N' ', NULLIF(pe.Per_PrimerNombre, N''), NULLIF(pe.Per_ApellidoPaterno, N'')),
                                       N', que ya está matriculado este año.')
        FROM app.tbAlumnos al
        JOIN app.tbPersonas pe ON pe.Per_Id = al.Per_Id
        JOIN app.tbMatriculaAnio mt ON mt.Alu_Id = al.Alu_Id AND mt.Ani_Id = @Ani_Id AND mt.Mta_EsEliminado = 0 AND mt.Mta_Estado = 1
        WHERE pe.Per_Identidad = @Asp_Identidad AND pe.Per_EsEliminado = 0;

    SELECT a.Asp_Id,
           a.Asp_Posicion,
           a.Asp_Estado,
           (SELECT r.PosicionCola FROM (
                SELECT x.Asp_Id, ROW_NUMBER() OVER (ORDER BY x.Asp_Prioridad DESC, x.Asp_Posicion) AS PosicionCola
                FROM app.tbAspirantes x
                WHERE x.Ani_Id = a.Ani_Id AND x.Cun_Id = a.Cun_Id AND x.Asp_EsEliminado = 0 AND x.Asp_Estado = 'EE'
            ) r WHERE r.Asp_Id = a.Asp_Id) AS PosicionCola,
           (SELECT COUNT(*) FROM app.tbAspirantes x
             WHERE x.Ani_Id = a.Ani_Id AND x.Cun_Id = a.Cun_Id AND x.Asp_EsEliminado = 0 AND x.Asp_Estado = 'EE') AS EnCola,
           CAST(g.Cun_Descripcion AS nvarchar(100)) AS Cun_Descripcion,
           @Aviso AS Aviso
    FROM app.tbAspirantes a
    JOIN app.tbCursosNiveles g ON g.Cun_Id = a.Cun_Id
    WHERE a.Asp_Id = @Asp_Id;
END
GO

-- Mover de estado: ofrecer | rechazar | desistio | reactivar | matricular.
-- Bloquea la cola del grado (applock): dos ofertas a la vez no se llevan el mismo asiento.
CREATE OR ALTER PROCEDURE app.PR_tbAspirantes_CambiarEstado
    @Asp_Id  int,
    @Accion  varchar(20),
    @Motivo  nvarchar(500) = NULL,
    @Alu_Id  int           = NULL,
    @Usuario int           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');
    SET @Accion = LOWER(LTRIM(RTRIM(ISNULL(@Accion, ''))));
    DECLARE @Ahora datetime = app.FN_AhoraHonduras();

    IF @Accion NOT IN ('ofrecer','rechazar','desistio','reactivar','matricular')
        THROW 50096, N'Acción desconocida.', 1;

    DECLARE @Ani_Id int, @Cun_Id int;
    SELECT @Ani_Id = Ani_Id, @Cun_Id = Cun_Id FROM app.tbAspirantes WHERE Asp_Id = @Asp_Id AND Asp_EsEliminado = 0;
    IF @Ani_Id IS NULL
        THROW 50083, N'El aspirante ya no existe.', 1;

    DECLARE @Recurso nvarchar(100) = CONCAT(N'aspirantes-', @Ani_Id, N'-', @Cun_Id);
    DECLARE @Aviso nvarchar(300) = NULL, @Nuevo varchar(2);

    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC sp_getapplock @Resource = @Recurso, @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = 10000;

        DECLARE @Estado varchar(2), @Mda_Id int, @Grado nvarchar(100);
        SELECT @Estado = a.Asp_Estado, @Mda_Id = a.Mda_Id, @Grado = CAST(g.Cun_Descripcion AS nvarchar(100))
        FROM app.tbAspirantes a WITH (UPDLOCK, HOLDLOCK)
        JOIN app.tbCursosNiveles g ON g.Cun_Id = a.Cun_Id
        WHERE a.Asp_Id = @Asp_Id AND a.Asp_EsEliminado = 0;

        IF @Accion = 'ofrecer'
        BEGIN
            IF @Estado <> 'EE'
                THROW 50088, N'Solo se ofrece cupo a un aspirante en espera.', 1;

            DECLARE @Siguiente int, @SiguienteNombre nvarchar(210);
            SELECT TOP (1) @Siguiente = x.Asp_Id, @SiguienteNombre = CONCAT(x.Asp_Nombres, N' ', x.Asp_Apellidos)
            FROM app.tbAspirantes x
            WHERE x.Ani_Id = @Ani_Id AND x.Cun_Id = @Cun_Id AND x.Asp_EsEliminado = 0 AND x.Asp_Estado = 'EE'
            ORDER BY x.Asp_Prioridad DESC, x.Asp_Posicion;
            IF @Siguiente <> @Asp_Id
            BEGIN
                DECLARE @MsgSig nvarchar(400) = CONCAT(N'El cupo se ofrece al siguiente de la cola de ', @Grado, N': ', @SiguienteNombre, N'.');
                THROW 50089, @MsgSig, 1;
            END

            DECLARE @CupoDef bit, @Libres int;
            SELECT @CupoDef = CupoDefinido, @Libres = Libres FROM app.FN_AspirantesCupo(@Ani_Id, @Cun_Id, NULL);
            IF @CupoDef = 1 AND @Libres <= 0
            BEGIN
                DECLARE @MsgCupo nvarchar(400) = CONCAT(N'No hay cupo libre en ', @Grado, N': el cupo ya está ocupado por matriculados y ofertas abiertas.');
                THROW 50090, @MsgCupo, 1;
            END
            IF @Mda_Id IS NOT NULL
            BEGIN
                DECLARE @CupoDefM bit, @LibresM int;
                SELECT @CupoDefM = CupoDefinido, @LibresM = Libres FROM app.FN_AspirantesCupo(@Ani_Id, @Cun_Id, @Mda_Id);
                IF @CupoDefM = 1 AND @LibresM <= 0
                    THROW 50090, N'No hay cupo libre en la modalidad que pidió el aspirante.', 1;
            END
            IF @CupoDef = 0
                SET @Aviso = CONCAT(N'El cupo de ', @Grado, N' no está definido: se ofreció sin control de asientos.');

            SET @Nuevo = 'OF';
            UPDATE app.tbAspirantes
            SET Asp_Estado = 'OF', Asp_FechaOferta = @Ahora, Asp_UsuarioOferta = @Usuario,
                Asp_UsuarioModifica = @Usuario, Asp_FechaModifica = @Ahora
            WHERE Asp_Id = @Asp_Id;
        END
        ELSE IF @Accion IN ('rechazar','desistio')
        BEGIN
            IF @Estado NOT IN ('EE','OF')
                THROW 50092, N'Solo un aspirante en espera o con oferta se puede rechazar o marcar como desistido.', 1;
            IF @Motivo IS NULL
                THROW 50091, N'Escriba el motivo.', 1;

            SET @Nuevo = CASE @Accion WHEN 'rechazar' THEN 'RE' ELSE 'DE' END;
            UPDATE app.tbAspirantes
            SET Asp_Estado = @Nuevo, Asp_MotivoDecision = @Motivo, Asp_FechaDecision = @Ahora, Asp_UsuarioDecision = @Usuario,
                Asp_UsuarioModifica = @Usuario, Asp_FechaModifica = @Ahora
            WHERE Asp_Id = @Asp_Id;
        END
        ELSE IF @Accion = 'reactivar'
        BEGIN
            IF @Estado NOT IN ('RE','DE')
                THROW 50093, N'Solo se reactiva un aspirante rechazado o que desistió.', 1;
            IF @Motivo IS NULL
                THROW 50091, N'Escriba el motivo.', 1;

            DECLARE @Posicion int = ISNULL((SELECT MAX(Asp_Posicion) FROM app.tbAspirantes
                                            WHERE Ani_Id = @Ani_Id AND Cun_Id = @Cun_Id AND Asp_EsEliminado = 0), 0) + 1;
            SET @Nuevo = 'EE';
            UPDATE app.tbAspirantes
            SET Asp_Estado = 'EE', Asp_Posicion = @Posicion, Asp_MotivoDecision = NULL,
                Asp_FechaOferta = NULL, Asp_UsuarioOferta = NULL, Asp_FechaDecision = NULL, Asp_UsuarioDecision = NULL,
                Asp_UsuarioModifica = @Usuario, Asp_FechaModifica = @Ahora
            WHERE Asp_Id = @Asp_Id;
        END
        ELSE -- matricular
        BEGIN
            IF @Estado <> 'OF'
                THROW 50094, N'Solo se matricula a un aspirante con cupo ofrecido.', 1;
            IF @Alu_Id IS NULL OR NOT EXISTS (SELECT 1 FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id)
                THROW 50095, N'No se encontró el alumno recién creado.', 1;

            SET @Nuevo = 'MA';
            UPDATE app.tbAspirantes
            SET Asp_Estado = 'MA', Alu_Id = @Alu_Id, Asp_FechaDecision = @Ahora, Asp_UsuarioDecision = @Usuario,
                Asp_MotivoDecision = @Motivo, Asp_UsuarioModifica = @Usuario, Asp_FechaModifica = @Ahora
            WHERE Asp_Id = @Asp_Id;
        END

        INSERT INTO app.tbAspirantesHistorial (Asp_Id, Ash_EstadoAnterior, Ash_EstadoNuevo, Ash_Motivo, Ash_Usuario, Ash_Fecha)
        VALUES (@Asp_Id, @Estado, @Nuevo,
                CASE WHEN @Accion = 'ofrecer' THEN ISNULL(@Motivo, @Aviso)
                     WHEN @Accion = 'matricular' THEN ISNULL(@Motivo, N'Matriculado con el wizard de matrícula.')
                     ELSE @Motivo END,
                @Usuario, @Ahora);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT a.Asp_Id, a.Asp_Estado, a.Asp_Posicion, a.Alu_Id, @Aviso AS Aviso
    FROM app.tbAspirantes a
    WHERE a.Asp_Id = @Asp_Id;
END
GO

/* ---------------------------------------------------------------- Pantallas y permisos */
--   Lista de espera            = ver la lista, el detalle y el resumen por grado (admin, director, secretaria)
--   Gestionar lista de espera  = registrar, editar, ofrecer, rechazar, desistió, reactivar (admin, secretaria)
--   Matricular desde la lista  = "Gestionar lista de espera" + "Matrícula nueva" (la que ya usa el wizard)
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES (N'Lista de espera',           N'|admin|director|secretaria|'),
                              (N'Gestionar lista de espera', N'|admin|secretaria|');

INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
SELECT x.Nombre, 1, 0, 'Alumnos'
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
