/* =============================================================================
   083 · Público destino de los anuncios (Centro de anuncios)

   Cada anuncio dice a quién va dirigido:
     todos     = Todo el colegio (personal y familias)
     personal  = Solo personal
     familias  = Familias: todas, o las de un nivel, un grado o una sección
                 (cascada Nivel > Grado > Sección: Anu_NivId, Anu_CunId, Anu_SecId)
   - Los anuncios que ya existían quedan como "Todo el colegio": son avisos generales
     (bienvenida, reunión de padres, boletines, suspensión de clases, inscripciones).
     Esto solo se aplica la primera vez que se agregan las columnas.
   - Nuevo app.PR_Portal_Anuncios: devuelve solo los anuncios vigentes para familias que apliquen
     a algún hijo ligado al encargado del usuario (por su nivel, grado y sección actuales).
   - app.PR_CentroAnuncios_List / _Insert llevan el público; PR_CentroAnuncios_Opciones alimenta
     los desplegables en cascada del formulario.
   - Errores 50083 y 50084 (público inválido / cascada inconsistente).
   Idempotente: se puede correr varias veces.
   ============================================================================= */
SET NOCOUNT ON;
GO

IF COL_LENGTH('app.tbAnuncios', 'Anu_Publico') IS NULL
BEGIN
    EXEC('ALTER TABLE app.tbAnuncios ADD
            Anu_Publico VARCHAR(10) NOT NULL CONSTRAINT DF_tbAnuncios_Publico DEFAULT (''personal''),
            Anu_NivId   INT NULL,
            Anu_CunId   INT NULL,
            Anu_SecId   INT NULL');
    -- Los anuncios anteriores son avisos generales del colegio
    EXEC('UPDATE app.tbAnuncios SET Anu_Publico = ''todos''');
END
GO

-- Lista del Centro de anuncios (quien publica ve todo, con su público)
CREATE OR ALTER PROCEDURE app.PR_CentroAnuncios_List
    @SoloActivos BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

    SELECT a.Anu_Id, a.Anu_Titulo, a.Anu_Contenido, a.Anu_FechaPublicacion, a.Anu_FechaExpiracion, a.Anu_Activo,
           CASE WHEN a.Anu_Activo = 1 AND (a.Anu_FechaExpiracion IS NULL OR a.Anu_FechaExpiracion >= @Hoy)
                THEN 1 ELSE 0 END AS EsVigente,
           a.Anu_FechaRegistra,
           u.Usu_Name            AS PublicadoPor,
           a.Anu_Publico, a.Anu_NivId, a.Anu_CunId, a.Anu_SecId,
           CASE a.Anu_Publico
                WHEN 'todos'    THEN N'Todo el colegio'
                WHEN 'personal' THEN N'Solo personal'
                ELSE N'Familias: ' + CASE
                        WHEN a.Anu_SecId IS NOT NULL THEN ISNULL(cun.Cun_Descripcion, N'') + N' sección ' + ISNULL(s.Sec_Descripcion, N'')
                        WHEN a.Anu_CunId IS NOT NULL THEN ISNULL(cun.Cun_Descripcion, N'')
                        WHEN a.Anu_NivId IS NOT NULL THEN ISNULL(niv.Niv_Descripcion, N'')
                        ELSE N'todas' END
           END AS PublicoTexto
    FROM app.tbAnuncios a
    LEFT JOIN seguridad.tbUsuarios u       ON u.Usu_Id = a.Anu_UsuarioRegistra
    LEFT JOIN app.tbNivelesEducativos niv  ON niv.Niv_Id = a.Anu_NivId
    LEFT JOIN app.tbCursosNiveles cun      ON cun.Cun_Id = a.Anu_CunId
    LEFT JOIN app.tbSecciones s            ON s.Sec_Id = a.Anu_SecId
    WHERE a.Anu_EsEliminado = 0
      AND (@SoloActivos = 0
           OR (a.Anu_Activo = 1 AND (a.Anu_FechaExpiracion IS NULL OR a.Anu_FechaExpiracion >= @Hoy)))
    ORDER BY a.Anu_FechaPublicacion DESC, a.Anu_Id DESC;
END
GO

-- Alta: valida el público y la cascada en el servidor
CREATE OR ALTER PROCEDURE app.PR_CentroAnuncios_Insert
    @Anu_Titulo           NVARCHAR(200),
    @Anu_Contenido        NVARCHAR(MAX),
    @Anu_FechaPublicacion DATE        = NULL,
    @Anu_FechaExpiracion  DATE        = NULL,
    @Anu_UsuarioRegistra  INT,
    @Anu_Publico          VARCHAR(10) = 'personal',
    @Anu_NivId            INT         = NULL,
    @Anu_CunId            INT         = NULL,
    @Anu_SecId            INT         = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Anu_Publico NOT IN ('todos', 'personal', 'familias')
        THROW 50083, 'El público del anuncio no es válido.', 1;

    IF @Anu_Publico <> 'familias'
        SELECT @Anu_NivId = NULL, @Anu_CunId = NULL, @Anu_SecId = NULL;
    ELSE
    BEGIN
        -- Cascada: no puede quedar un hijo sin su padre
        IF @Anu_SecId IS NOT NULL AND @Anu_CunId IS NULL
            THROW 50084, 'Para elegir una sección hay que elegir primero el grado.', 1;
        IF @Anu_CunId IS NOT NULL AND @Anu_NivId IS NULL
            THROW 50084, 'Para elegir un grado hay que elegir primero el nivel.', 1;
        IF @Anu_NivId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM app.tbNivelesEducativos WHERE Niv_Id = @Anu_NivId AND Niv_EsEliminado = 0)
            THROW 50084, 'El nivel elegido no existe.', 1;
        IF @Anu_CunId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM app.tbCursosNiveles WHERE Cun_Id = @Anu_CunId AND Niv_Id = @Anu_NivId AND Cun_EsEliminado = 0)
            THROW 50084, 'El grado elegido no pertenece a ese nivel.', 1;
        IF @Anu_SecId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM app.tbSecciones WHERE Sec_Id = @Anu_SecId AND Sec_EsEliminado = 0)
            THROW 50084, 'La sección elegida no existe.', 1;
    END

    IF @Anu_FechaPublicacion IS NULL SET @Anu_FechaPublicacion = CAST(GETDATE() AS DATE);

    INSERT INTO app.tbAnuncios
        (Anu_Titulo, Anu_Contenido, Anu_FechaPublicacion, Anu_FechaExpiracion, Anu_Activo, Anu_EsEliminado,
         Anu_UsuarioRegistra, Anu_FechaRegistra, Anu_Publico, Anu_NivId, Anu_CunId, Anu_SecId)
    VALUES
        (@Anu_Titulo, @Anu_Contenido, @Anu_FechaPublicacion, @Anu_FechaExpiracion, 1, 0,
         @Anu_UsuarioRegistra, GETDATE(), @Anu_Publico, @Anu_NivId, @Anu_CunId, @Anu_SecId);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Anu_Id;
END
GO

-- Opciones de la cascada del formulario: nivel > grado (del nivel) > sección (de ese grado, según sus alumnos)
CREATE OR ALTER PROCEDURE app.PR_CentroAnuncios_Opciones
    @Tipo   VARCHAR(10),
    @Padre  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Tipo = 'nivel'
        SELECT Niv_Id AS Id, Niv_Descripcion AS Texto FROM app.tbNivelesEducativos
        WHERE Niv_EsEliminado = 0 ORDER BY Niv_Id;
    ELSE IF @Tipo = 'grado'
        SELECT Cun_Id AS Id, Cun_Descripcion AS Texto FROM app.tbCursosNiveles
        WHERE Cun_EsEliminado = 0 AND Niv_Id = @Padre ORDER BY Cun_Orden;
    ELSE IF @Tipo = 'seccion'
        SELECT s.Sec_Id AS Id, s.Sec_Descripcion AS Texto FROM app.tbSecciones s
        WHERE s.Sec_EsEliminado = 0
          AND EXISTS (SELECT 1 FROM app.tbAlumnos a WHERE a.Cun_Id = @Padre AND a.Sec_Id = s.Sec_Id)
        ORDER BY s.Sec_Descripcion;
    ELSE
        SELECT CAST(NULL AS INT) AS Id, CAST(NULL AS NVARCHAR(100)) AS Texto WHERE 1 = 0;
END
GO

-- Anuncios para una familia: solo los dirigidos a familias (o a todo el colegio) que apliquen a algún hijo
CREATE OR ALTER PROCEDURE app.PR_Portal_Anuncios
    @Usu_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Enc_Id INT = app.FN_Portal_Encargado(@Usu_Id);
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

    SELECT a.Anu_Id, a.Anu_Titulo, a.Anu_Contenido, a.Anu_FechaPublicacion, a.Anu_FechaExpiracion, a.Anu_Activo,
           CAST(1 AS INT) AS EsVigente, a.Anu_FechaRegistra, CAST(NULL AS NVARCHAR(100)) AS PublicadoPor
    FROM app.tbAnuncios a
    WHERE @Enc_Id IS NOT NULL
      AND a.Anu_EsEliminado = 0 AND a.Anu_Activo = 1
      AND (a.Anu_FechaExpiracion IS NULL OR a.Anu_FechaExpiracion >= @Hoy)
      AND (a.Anu_Publico = 'todos'
           OR (a.Anu_Publico = 'familias'
               AND (a.Anu_NivId IS NULL
                    OR EXISTS (SELECT 1
                               FROM app.tbEncargados_tbAlumnos ea
                               INNER JOIN app.tbAlumnos al ON al.Alu_Id = ea.Alu_Id
                               WHERE ea.Enc_Id = @Enc_Id
                                 AND al.Niv_Id = a.Anu_NivId
                                 AND (a.Anu_CunId IS NULL OR al.Cun_Id = a.Anu_CunId)
                                 AND (a.Anu_SecId IS NULL OR al.Sec_Id = a.Anu_SecId)))))
    ORDER BY a.Anu_FechaPublicacion DESC, a.Anu_Id DESC;
END
GO

-- Baja lógica: sin SET NOCOUNT ON para que la API reciba las filas afectadas (antes avisaba error aunque borraba)
CREATE OR ALTER PROCEDURE app.PR_CentroAnuncios_Delete
    @Anu_Id              INT,
    @Anu_UsuarioModifica INT
AS
BEGIN
    UPDATE app.tbAnuncios
    SET    Anu_EsEliminado     = 1,
           Anu_Activo          = 0,
           Anu_UsuarioModifica = @Anu_UsuarioModifica,
           Anu_FechaModifica   = GETDATE()
    WHERE  Anu_Id = @Anu_Id
      AND  Anu_EsEliminado = 0;
END
GO
