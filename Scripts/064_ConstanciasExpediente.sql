/* =============================================================================
   064 · Constancias y expediente   (requiere los scripts 058 y 062)

   - Documentos oficiales de un alumno que quedan CONGELADOS al emitirse: cada emisión guarda una
     copia fija del contenido en JSON (Doc_Contenido), con número de revisión, motivo, fecha y
     quién la emitió. Nunca se edita ni se borra: para corregir se emite una revisión nueva.
   - Tipos: ESTUDIO (constancia de matrícula en un año), BOLETIN (notas de un año, opcionalmente
     de un solo parcial) y EXPEDIENTE (todas las notas de todos los años).
   - Revisión = anterior + 1 para el mismo alumno + tipo + año + parcial. Desde la segunda se
     exige motivo.
   - Referencia: CE-26-000001 / BO-26-000001 / EX-26-000001 (prefijo por tipo, año de emisión en
     2 dígitos y correlativo por tipo de 6 dígitos).
   - Códigos de la emisión (Id negativo):
       -1 no hay notas para lo pedido (BOLETIN / EXPEDIENTE)
       -2 el alumno no está matriculado en ese año (ESTUDIO / BOLETIN)
       -3 datos inválidos (tipo, alumno, año, parcial o usuario)
       -4 ya hay una emisión previa del mismo documento y no viene motivo
   - Permisos: "Constancias y expediente" (admin, director, secretaria) para ver e imprimir y
     "Emitir constancias" (admin, secretaria) para emitir.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('app.tbDocumentosEmitidos') IS NULL
BEGIN
    CREATE TABLE app.tbDocumentosEmitidos
    (
        Doc_Id            int            IDENTITY(1,1) NOT NULL,
        Doc_Tipo          varchar(12)    NOT NULL,
        Doc_Referencia    varchar(30)    NOT NULL,
        Doc_Revision      int            NOT NULL,
        Alu_Id            int            NOT NULL,
        Ani_Id            int            NULL,
        Pac_Id            int            NULL,
        Doc_Promedio      decimal(5,2)   NULL,
        Doc_Contenido     nvarchar(max)  NOT NULL,
        Doc_Motivo        nvarchar(300)  NULL,
        Doc_UsuarioEmite  int            NOT NULL,
        Doc_FechaEmision  datetime       NOT NULL CONSTRAINT DF_tbDocumentosEmitidos_Fecha DEFAULT (GETDATE()),
        CONSTRAINT PK_tbDocumentosEmitidos PRIMARY KEY CLUSTERED (Doc_Id),
        CONSTRAINT UQ_tbDocumentosEmitidos_Referencia UNIQUE (Doc_Referencia),
        CONSTRAINT CK_tbDocumentosEmitidos_Tipo CHECK (Doc_Tipo IN ('ESTUDIO', 'BOLETIN', 'EXPEDIENTE')),
        CONSTRAINT CK_tbDocumentosEmitidos_Revision CHECK (Doc_Revision >= 1),
        CONSTRAINT CK_tbDocumentosEmitidos_Contenido CHECK (ISJSON(Doc_Contenido) = 1),
        CONSTRAINT FK_tbDocumentosEmitidos_Alumno   FOREIGN KEY (Alu_Id) REFERENCES app.tbAlumnos (Alu_Id),
        CONSTRAINT FK_tbDocumentosEmitidos_Anio     FOREIGN KEY (Ani_Id) REFERENCES app.tbAnioLectivo (Ani_Id),
        CONSTRAINT FK_tbDocumentosEmitidos_Parcial  FOREIGN KEY (Pac_Id) REFERENCES app.tbParciales (Pac_Id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tbDocumentosEmitidos_Grupo' AND object_id = OBJECT_ID('app.tbDocumentosEmitidos'))
    CREATE INDEX IX_tbDocumentosEmitidos_Grupo ON app.tbDocumentosEmitidos (Alu_Id, Doc_Tipo, Ani_Id, Pac_Id, Doc_Revision);
GO

-- Un documento emitido es inmutable.
CREATE OR ALTER TRIGGER app.TR_tbDocumentosEmitidos_Inmutable
ON app.tbDocumentosEmitidos
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    THROW 50064, N'Un documento emitido no se puede cambiar ni borrar; emití una revisión nueva.', 1;
END
GO

/* Calcula el contenido de un documento sin guardarlo (los textos se limpian de saltos de línea). Lo usan la vista previa y la emisión.
   @Codigo: 0 bien; -1 sin notas; -2 sin matrícula en el año; -3 datos inválidos. */
CREATE OR ALTER PROCEDURE app.PR_tbDocumentosEmitidos_Calcular
    @Doc_Tipo   varchar(12),
    @Alu_Id     int,
    @Ani_Id     int = NULL,
    @Pac_Id     int = NULL,
    @Codigo     int            OUTPUT,
    @Contenido  nvarchar(max)  OUTPUT,
    @Promedio   decimal(5,2)   OUTPUT,
    @Revision   int            OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @Codigo = 0, @Contenido = NULL, @Promedio = NULL, @Revision = NULL;
    SET @Doc_Tipo = UPPER(LTRIM(RTRIM(@Doc_Tipo)));

    -- El expediente abarca todos los años: no lleva año.
    IF @Doc_Tipo = 'EXPEDIENTE' SET @Ani_Id = NULL;

    IF @Doc_Tipo IS NULL OR @Doc_Tipo NOT IN ('ESTUDIO', 'BOLETIN', 'EXPEDIENTE')
       OR NOT EXISTS (SELECT 1 FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id)
       OR (@Doc_Tipo IN ('ESTUDIO', 'BOLETIN') AND @Ani_Id IS NULL)
       OR (@Ani_Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id AND Ani_EsEliminado = 0))
       OR (@Pac_Id IS NOT NULL AND @Doc_Tipo <> 'BOLETIN')
       OR (@Pac_Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM app.tbParciales WHERE Pac_Id = @Pac_Id AND Pac_EsEliminado = 0))
    BEGIN
        SET @Codigo = -3;
        RETURN;
    END

    -- Matrícula del año (ESTUDIO exige que no esté retirado).
    DECLARE @Sea_Id int, @Matriculado bit = 0;
    IF @Ani_Id IS NOT NULL
        SELECT TOP (1) @Sea_Id = m.Sea_Id, @Matriculado = 1
        FROM app.tbMatriculaAnio m
        WHERE m.Alu_Id = @Alu_Id AND m.Ani_Id = @Ani_Id AND m.Mta_EsEliminado = 0
          AND (@Doc_Tipo <> 'ESTUDIO' OR m.Mta_Estado <> 4);

    IF @Doc_Tipo IN ('ESTUDIO', 'BOLETIN') AND @Matriculado = 0
    BEGIN
        SET @Codigo = -2;
        RETURN;
    END

    DECLARE @Anio int = (SELECT Ani_Anio FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id);
    DECLARE @Parcial nvarchar(100) = (SELECT Pac_Descripcion FROM app.tbParciales WHERE Pac_Id = @Pac_Id);

    -- Notas incluidas.
    DECLARE @Notas TABLE (Anio int, Grado nvarchar(200), Seccion nvarchar(200), Materia nvarchar(200),
                          Mat_Id int, Sem_Id int, Semestre nvarchar(100), Pac_Id int, Parcial nvarchar(100), Nota int);
    IF @Doc_Tipo IN ('BOLETIN', 'EXPEDIENTE')
        INSERT INTO @Notas
        SELECT YEAR(n.Not_Año), TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM cn.Cun_Descripcion),
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM COALESCE(s1.Sec_Descripcion, s2.Sec_Descripcion)),
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM ma.Mat_Nombre), n.Mat_Id, n.Sem_Id, se.Sem_Descripcion, n.Pac_Id, pa.Pac_Descripcion, n.Not_Nota
        FROM app.tbNotas n
        LEFT JOIN app.tbMaterias ma        ON ma.Mat_Id = n.Mat_Id
        LEFT JOIN app.tbParciales pa       ON pa.Pac_Id = n.Pac_Id
        LEFT JOIN app.tbSemestres se       ON se.Sem_Id = n.Sem_Id
        LEFT JOIN app.tbAnioLectivo an     ON an.Ani_Anio = YEAR(n.Not_Año) AND an.Ani_EsEliminado = 0
        LEFT JOIN app.tbMatriculaAnio m    ON m.Alu_Id = n.Alu_Id AND m.Ani_Id = an.Ani_Id AND m.Mta_EsEliminado = 0
        LEFT JOIN app.tbSeccionesAnio sa   ON sa.Sea_Id = m.Sea_Id
        LEFT JOIN app.tbCursosNiveles cn   ON cn.Cun_Id = sa.Cun_Id
        LEFT JOIN app.tbSecciones s1       ON s1.Sec_Id = sa.Sec_Id
        LEFT JOIN app.tbSecciones s2       ON s2.Sec_Id = n.Sec_Id
        WHERE n.Alu_Id = @Alu_Id
          AND n.Not_EsEliminado = 0 AND n.Not_EsActivo = 1
          AND (@Anio IS NULL OR YEAR(n.Not_Año) = @Anio)
          AND (@Pac_Id IS NULL OR n.Pac_Id = @Pac_Id);

    IF @Doc_Tipo IN ('BOLETIN', 'EXPEDIENTE') AND NOT EXISTS (SELECT 1 FROM @Notas)
    BEGIN
        SET @Codigo = -1;
        RETURN;
    END

    IF @Doc_Tipo <> 'ESTUDIO'
        SET @Promedio = (SELECT CAST(ROUND(AVG(CAST(Nota AS decimal(9,4))), 2) AS decimal(5,2)) FROM @Notas);

    -- Ubicación: la del año pedido; sin año (expediente), la actual del alumno.
    DECLARE @Alumno nvarchar(max) = (
        SELECT al.Alu_Id,
               CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), N''),
                         NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N'')) AS Nombre,
               p.Per_Identidad      AS Identidad,
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM ne.Niv_Descripcion) AS Nivel,
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM cn.Cun_Descripcion) AS Grado,
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM cu.Cur_Nombre) AS Curso,
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM s.Sec_Descripcion) AS Seccion,
               TRIM(NCHAR(13) + NCHAR(10) + NCHAR(9) + N' ' FROM md.Mda_Descripcion) AS Modalidad
        FROM app.tbAlumnos al
        JOIN app.tbPersonas p              ON p.Per_Id = al.Per_Id
        LEFT JOIN app.tbSeccionesAnio sa   ON sa.Sea_Id = @Sea_Id
        LEFT JOIN app.tbNivelesEducativos ne ON ne.Niv_Id = CASE WHEN @Ani_Id IS NULL THEN al.Niv_Id ELSE sa.Niv_Id END
        LEFT JOIN app.tbCursosNiveles cn   ON cn.Cun_Id = CASE WHEN @Ani_Id IS NULL THEN al.Cun_Id ELSE sa.Cun_Id END
        LEFT JOIN app.tbSecciones s        ON s.Sec_Id  = CASE WHEN @Ani_Id IS NULL THEN al.Sec_Id ELSE sa.Sec_Id END
        LEFT JOIN app.tbModalidades md     ON md.Mda_Id = CASE WHEN @Ani_Id IS NULL THEN al.Mda_Id ELSE sa.Mda_Id END
        LEFT JOIN app.tbCursos cu          ON cu.Cur_Id = al.Cur_Id   -- la sección del año no guarda la carrera
        WHERE al.Alu_Id = @Alu_Id
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES);

    DECLARE @ListaNotas nvarchar(max) = (
        SELECT Anio, Grado, Seccion, Materia, Pac_Id, Parcial, Nota, Sem_Id, Semestre
        FROM @Notas
        ORDER BY Anio, Materia, Pac_Id, Sem_Id
        FOR JSON PATH, INCLUDE_NULL_VALUES);

    SET @Contenido = (
        SELECT JSON_QUERY(@Alumno) AS alumno,
               @Anio AS anio,
               @Parcial AS parcial,
               JSON_QUERY(ISNULL(@ListaNotas, N'[]')) AS notas
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES);

    SET @Revision = 1 + ISNULL((
        SELECT MAX(d.Doc_Revision) FROM app.tbDocumentosEmitidos d
        WHERE d.Alu_Id = @Alu_Id AND d.Doc_Tipo = @Doc_Tipo
          AND ISNULL(d.Ani_Id, 0) = ISNULL(@Ani_Id, 0)
          AND ISNULL(d.Pac_Id, 0) = ISNULL(@Pac_Id, 0)), 0);
END
GO

-- Vista previa: el documento tal como quedaría, sin guardarlo.
CREATE OR ALTER PROCEDURE app.PR_tbDocumentosEmitidos_VistaPrevia
    @Doc_Tipo varchar(12),
    @Alu_Id   int,
    @Ani_Id   int = NULL,
    @Pac_Id   int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Codigo int, @Contenido nvarchar(max), @Promedio decimal(5,2), @Revision int;
    EXEC app.PR_tbDocumentosEmitidos_Calcular @Doc_Tipo, @Alu_Id, @Ani_Id, @Pac_Id,
         @Codigo OUTPUT, @Contenido OUTPUT, @Promedio OUTPUT, @Revision OUTPUT;
    SELECT @Codigo AS Codigo, @Contenido AS Doc_Contenido, @Promedio AS Doc_Promedio,
           ISNULL(@Revision, 0) AS RevisionSiguiente;
END
GO

-- Emisión: congela el contenido. Devuelve NewId (>0) o el código negativo.
CREATE OR ALTER PROCEDURE app.PR_tbDocumentosEmitidos_Emitir
    @Doc_Tipo         varchar(12),
    @Alu_Id           int,
    @Ani_Id           int = NULL,
    @Pac_Id           int = NULL,
    @Doc_Motivo       nvarchar(300) = NULL,
    @Doc_UsuarioEmite int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Doc_Tipo = UPPER(LTRIM(RTRIM(@Doc_Tipo)));
    SET @Doc_Motivo = NULLIF(LTRIM(RTRIM(@Doc_Motivo)), N'');
    IF @Doc_Tipo = 'EXPEDIENTE' SET @Ani_Id = NULL;

    IF @Doc_UsuarioEmite IS NULL
    BEGIN
        SELECT -3 AS NewId;
        RETURN;
    END

    DECLARE @Codigo int, @Contenido nvarchar(max), @Promedio decimal(5,2), @Revision int, @NewId int;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Una emisión a la vez: la revisión y el correlativo no se pueden repetir.
        EXEC sp_getapplock @Resource = 'app.tbDocumentosEmitidos', @LockMode = 'Exclusive',
             @LockOwner = 'Transaction', @LockTimeout = 15000;

        EXEC app.PR_tbDocumentosEmitidos_Calcular @Doc_Tipo, @Alu_Id, @Ani_Id, @Pac_Id,
             @Codigo OUTPUT, @Contenido OUTPUT, @Promedio OUTPUT, @Revision OUTPUT;

        IF @Codigo = 0 AND @Revision > 1 AND @Doc_Motivo IS NULL
            SET @Codigo = -4;

        IF @Codigo <> 0
        BEGIN
            COMMIT TRANSACTION;
            SELECT @Codigo AS NewId;
            RETURN;
        END

        DECLARE @Ahora datetime = app.FN_AhoraHonduras();
        DECLARE @Prefijo varchar(2) = CASE @Doc_Tipo WHEN 'ESTUDIO' THEN 'CE' WHEN 'BOLETIN' THEN 'BO' ELSE 'EX' END;
        DECLARE @Correlativo int = 1 + ISNULL((
            SELECT MAX(CAST(RIGHT(Doc_Referencia, 6) AS int))
            FROM app.tbDocumentosEmitidos WHERE Doc_Tipo = @Doc_Tipo), 0);
        DECLARE @Referencia varchar(30) = @Prefijo + '-' + RIGHT(CONVERT(char(4), YEAR(@Ahora)), 2) + '-'
                                        + RIGHT('000000' + CONVERT(varchar(10), @Correlativo), 6);

        INSERT INTO app.tbDocumentosEmitidos
            (Doc_Tipo, Doc_Referencia, Doc_Revision, Alu_Id, Ani_Id, Pac_Id, Doc_Promedio,
             Doc_Contenido, Doc_Motivo, Doc_UsuarioEmite, Doc_FechaEmision)
        VALUES
            (@Doc_Tipo, @Referencia, @Revision, @Alu_Id, @Ani_Id, @Pac_Id, @Promedio,
             @Contenido, @Doc_Motivo, @Doc_UsuarioEmite, @Ahora);
        SET @NewId = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @NewId AS NewId;
END
GO

-- Listado (más reciente primero). Filtros opcionales.
CREATE OR ALTER PROCEDURE app.PR_tbDocumentosEmitidos_List
    @Doc_Tipo varchar(12) = NULL,
    @Alu_Id   int = NULL,
    @Ani_Id   int = NULL,
    @Doc_Id   int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.Doc_Id, d.Doc_Tipo, d.Doc_Referencia, d.Doc_Revision, d.Alu_Id,
           CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), N''),
                     NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N'')) AS Alu_Nombre,
           p.Per_Identidad AS Alu_Identidad,
           d.Ani_Id, an.Ani_Nombre, d.Pac_Id, pa.Pac_Descripcion, d.Doc_Promedio, d.Doc_Motivo, d.Doc_FechaEmision,
           app.FN_NombreUsuario(d.Doc_UsuarioEmite) AS Doc_EmitidoPor,
           CAST(CASE WHEN EXISTS (SELECT 1 FROM app.tbDocumentosEmitidos x
                                  WHERE x.Alu_Id = d.Alu_Id AND x.Doc_Tipo = d.Doc_Tipo
                                    AND ISNULL(x.Ani_Id, 0) = ISNULL(d.Ani_Id, 0)
                                    AND ISNULL(x.Pac_Id, 0) = ISNULL(d.Pac_Id, 0)
                                    AND x.Doc_Revision > d.Doc_Revision)
                     THEN 0 ELSE 1 END AS bit) AS Doc_EsUltima,
           CASE WHEN @Doc_Id IS NULL THEN NULL ELSE d.Doc_Contenido END AS Doc_Contenido
    FROM app.tbDocumentosEmitidos d
    JOIN app.tbAlumnos al          ON al.Alu_Id = d.Alu_Id
    JOIN app.tbPersonas p          ON p.Per_Id  = al.Per_Id
    LEFT JOIN app.tbAnioLectivo an ON an.Ani_Id = d.Ani_Id
    LEFT JOIN app.tbParciales pa   ON pa.Pac_Id = d.Pac_Id
    WHERE (@Doc_Id IS NULL OR d.Doc_Id = @Doc_Id)
      AND (@Doc_Tipo IS NULL OR d.Doc_Tipo = @Doc_Tipo)
      AND (@Alu_Id IS NULL OR d.Alu_Id = @Alu_Id)
      AND (@Ani_Id IS NULL OR d.Ani_Id = @Ani_Id)
    ORDER BY d.Doc_FechaEmision DESC, d.Doc_Id DESC;
END
GO

-- Detalle: el documento con su contenido congelado.
CREATE OR ALTER PROCEDURE app.PR_tbDocumentosEmitidos_Find
    @Doc_Id int
AS
BEGIN
    SET NOCOUNT ON;
    EXEC app.PR_tbDocumentosEmitidos_List @Doc_Id = @Doc_Id;
END
GO

-- Permisos.
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES
    (N'Constancias y expediente', N'|1|1002|1003|'),
    (N'Emitir constancias',       N'|1|1003|');

INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
SELECT x.Nombre, 1, 0, 'Academico'
FROM @Pantallas x
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas p WHERE p.Pan_Descripcion = x.Nombre);

INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN @Pantallas x ON x.Nombre = p.Pan_Descripcion
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0
                        AND x.Roles LIKE N'%|' + CONVERT(nvarchar(10), r.Rol_Id) + N'|%'
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas y WHERE y.Rol_Id = r.Rol_Id AND y.Pan_Id = p.Pan_Id);
GO
