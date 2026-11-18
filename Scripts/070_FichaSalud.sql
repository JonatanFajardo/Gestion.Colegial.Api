/* =============================================================================
   070 · Ficha de salud del alumno  (espejo de Skuul: student_health_records;
         de RosarioSIS se toma médico, teléfono del médico y hospital preferido)

   - Una ficha por alumno (1:1 con app.tbAlumnos). Guardar otra vez cambia la misma ficha.
   - Lo que se necesita en una emergencia: alerta crítica (texto corto que ve el docente en el
     pase de lista), tipo de sangre, alergias, condiciones, medicamentos, restricciones
     alimentarias, médico, hospital, seguro y un contacto ADICIONAL a los encargados.
   - "A quién llamar" = encargados del alumno con su teléfono (app.tbEncargados_tbAlumnos)
     + el contacto adicional de la ficha.
   - Bitácora: guarda quién, cuándo y QUÉ CAMPOS cambiaron (nombres en español), nunca los
     valores, para que la bitácora no sea una segunda copia de datos de salud.
   - Control de versión (Fsa_Version): si otra persona guardó la ficha después de que usted
     la abrió, el guardado se rechaza en vez de pisar sus cambios (igual que Skuul).
   - Teléfonos: 8 dígitos con guion (9999-9999); la API los normaliza antes de llegar aquí.
   - Permisos: "Fichas de salud" (ver directorio, ficha y pestaña de la ficha 360) y
     "Editar ficha de salud" (crear y cambiar fichas). La alerta del pase de lista se protege
     con el permiso "Pase de lista".

   Solo agrega objetos nuevos; se puede ejecutar varias veces.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ---------------------------------------------------------------- Tablas */
IF OBJECT_ID('app.tbFichasSalud') IS NULL
BEGIN
    CREATE TABLE app.tbFichasSalud
    (
        Fsa_Id                           int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbFichasSalud PRIMARY KEY,
        Alu_Id                           int            NOT NULL CONSTRAINT FK_tbFichasSalud_tbAlumnos REFERENCES app.tbAlumnos (Alu_Id),
        Fsa_TipoSangre                   varchar(3)     NULL,
        Fsa_TieneAlerta                  bit            NOT NULL CONSTRAINT DF_tbFichasSalud_TieneAlerta DEFAULT (0),
        Fsa_Alerta                       nvarchar(150)  NULL,
        Fsa_Alergias                     nvarchar(2000) NULL,
        Fsa_Condiciones                  nvarchar(2000) NULL,
        Fsa_Medicamentos                 nvarchar(2000) NULL,
        Fsa_RestriccionesAlimentarias    nvarchar(2000) NULL,
        Fsa_MedicoNombre                 nvarchar(100)  NULL,
        Fsa_MedicoTelefono               varchar(9)     NULL,
        Fsa_Hospital                     nvarchar(150)  NULL,
        Fsa_Seguro                       nvarchar(100)  NULL,
        Fsa_SeguroPoliza                 nvarchar(50)   NULL,
        Fsa_ContactoEmergenciaNombre     nvarchar(100)  NULL,
        Fsa_ContactoEmergenciaParentesco nvarchar(50)   NULL,
        Fsa_ContactoEmergenciaTelefono   varchar(9)     NULL,
        Fsa_Notas                        nvarchar(4000) NULL,
        Fsa_Version                      int            NOT NULL CONSTRAINT DF_tbFichasSalud_Version DEFAULT (1),
        Fsa_UsuarioRegistra              int            NULL,
        Fsa_FechaRegistra                datetime2(0)   NOT NULL CONSTRAINT DF_tbFichasSalud_FechaRegistra DEFAULT (SYSDATETIME()),
        Fsa_UsuarioModifica              int            NULL,
        Fsa_FechaModifica                datetime2(0)   NULL,
        CONSTRAINT UQ_tbFichasSalud_Alumno UNIQUE (Alu_Id),
        CONSTRAINT CK_tbFichasSalud_TipoSangre CHECK (Fsa_TipoSangre IS NULL OR Fsa_TipoSangre IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
        CONSTRAINT CK_tbFichasSalud_Alerta CHECK (Fsa_TieneAlerta = 0 OR LEN(LTRIM(RTRIM(ISNULL(Fsa_Alerta, N'')))) > 0),
        CONSTRAINT CK_tbFichasSalud_MedicoTelefono CHECK (Fsa_MedicoTelefono IS NULL OR Fsa_MedicoTelefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
        CONSTRAINT CK_tbFichasSalud_ContactoTelefono CHECK (Fsa_ContactoEmergenciaTelefono IS NULL OR Fsa_ContactoEmergenciaTelefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
    );
    CREATE INDEX IX_tbFichasSalud_Alerta ON app.tbFichasSalud (Fsa_TieneAlerta) INCLUDE (Alu_Id, Fsa_Alerta);
END
GO

IF OBJECT_ID('app.tbFichasSaludBitacora') IS NULL
BEGIN
    CREATE TABLE app.tbFichasSaludBitacora
    (
        Fsb_Id      int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbFichasSaludBitacora PRIMARY KEY,
        Fsa_Id      int            NOT NULL CONSTRAINT FK_tbFichasSaludBitacora_Ficha REFERENCES app.tbFichasSalud (Fsa_Id),
        Alu_Id      int            NOT NULL CONSTRAINT FK_tbFichasSaludBitacora_Alumno REFERENCES app.tbAlumnos (Alu_Id),
        Fsb_Accion  varchar(10)    NOT NULL,
        Fsb_Campos  nvarchar(1000) NOT NULL,
        Fsb_Usuario int            NULL,
        Fsb_Fecha   datetime2(0)   NOT NULL CONSTRAINT DF_tbFichasSaludBitacora_Fecha DEFAULT (SYSDATETIME()),
        CONSTRAINT CK_tbFichasSaludBitacora_Accion CHECK (Fsb_Accion IN ('creada','editada'))
    );
    CREATE INDEX IX_tbFichasSaludBitacora_Alumno ON app.tbFichasSaludBitacora (Alu_Id, Fsb_Id DESC);
END
GO

/* ---------------------------------------------------------------- Funciones */

-- ¿Cambió un texto? Compara exacto (mayúsculas y tildes cuentan) y trata NULL como vacío.
CREATE OR ALTER FUNCTION app.FN_FichaSalud_Distinto (@Antes nvarchar(4000), @Despues nvarchar(4000))
RETURNS bit
AS
BEGIN
    RETURN CASE WHEN ISNULL(@Antes, N'') COLLATE Latin1_General_100_BIN2
                   = ISNULL(@Despues, N'') COLLATE Latin1_General_100_BIN2 THEN 0 ELSE 1 END;
END
GO

/* ---------------------------------------------------------------- Directorio */

-- Alumnos activos con el estado de su ficha. Filtros opcionales: nivel, grado, sección, texto
-- (nombre o identidad), solo sin ficha, solo con alerta.
-- Encargado principal = el primero vinculado (mismo criterio que PR_tbEncargados_ByAlumno).
CREATE OR ALTER PROCEDURE app.PR_tbFichasSalud_Directorio
    @Niv_Id        int           = NULL,
    @Cun_Id        int           = NULL,
    @Sec_Id        int           = NULL,
    @Texto         nvarchar(100) = NULL,
    @SoloSinFicha  bit           = 0,
    @SoloConAlerta bit           = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @q nvarchar(400) = NULLIF(LTRIM(RTRIM(@Texto)), N'');
    SET @q = REPLACE(REPLACE(REPLACE(@q, N'[', N'[[]'), N'%', N'[%]'), N'_', N'[_]');
    DECLARE @qIdentidad nvarchar(400) = REPLACE(@q, N'-', N'');

    ;WITH alumnos AS (
        SELECT a.Alu_Id, a.Niv_Id, a.Cun_Id, a.Sec_Id, p.Per_Identidad, p.Per_Imagen,
               p.Per_ApellidoPaterno, p.Per_ApellidoMaterno, p.Per_PrimerNombre,
               CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), N''),
                               NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N'')) AS Alumno
        FROM app.tbAlumnos a
        JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id
        WHERE ISNULL(a.Est_Id, 1) = 1
          AND ISNULL(p.Per_EsEliminado, 0) = 0
          AND (@Niv_Id IS NULL OR a.Niv_Id = @Niv_Id)
          AND (@Cun_Id IS NULL OR a.Cun_Id = @Cun_Id)
          AND (@Sec_Id IS NULL OR a.Sec_Id = @Sec_Id)
    )
    SELECT al.Alu_Id, al.Alumno, al.Per_Identidad AS Identidad, al.Per_Imagen AS Foto,
           al.Niv_Id, n.Niv_Descripcion AS Nivel, al.Cun_Id, cn.Cun_Descripcion AS Grado, al.Sec_Id, s.Sec_Descripcion AS Seccion,
           CAST(CASE WHEN f.Fsa_Id IS NULL THEN 0 ELSE 1 END AS bit) AS TieneFicha,
           CAST(ISNULL(f.Fsa_TieneAlerta, 0) AS bit) AS TieneAlerta,
           CASE WHEN f.Fsa_TieneAlerta = 1 THEN f.Fsa_Alerta END AS Alerta,
           f.Fsa_TipoSangre AS TipoSangre,
           enc.Encargado, NULLIF(LTRIM(RTRIM(enc.Per_Telefono)), '') AS EncargadoTelefono,
           f.Fsa_ContactoEmergenciaNombre AS ContactoNombre, f.Fsa_ContactoEmergenciaTelefono AS ContactoTelefono,
           CAST(CASE WHEN f.Fsa_ContactoEmergenciaTelefono IS NOT NULL
                       OR EXISTS (SELECT 1
                                  FROM app.tbEncargados_tbAlumnos x
                                  JOIN app.tbEncargados xe ON xe.Enc_Id = x.Enc_Id
                                  JOIN app.tbPersonas   xp ON xp.Per_Id = xe.Per_Id
                                  WHERE x.Alu_Id = al.Alu_Id AND NULLIF(LTRIM(RTRIM(xp.Per_Telefono)), '') IS NOT NULL)
                     THEN 1 ELSE 0 END AS bit) AS TieneTelefono,
           COALESCE(f.Fsa_FechaModifica, f.Fsa_FechaRegistra) AS Actualizada
    FROM alumnos al
    LEFT JOIN app.tbNivelesEducativos n  ON n.Niv_Id  = al.Niv_Id
    LEFT JOIN app.tbCursosNiveles     cn ON cn.Cun_Id = al.Cun_Id
    LEFT JOIN app.tbSecciones         s  ON s.Sec_Id  = al.Sec_Id
    LEFT JOIN app.tbFichasSalud       f  ON f.Alu_Id  = al.Alu_Id
    OUTER APPLY (
        SELECT TOP (1)
               CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(pe.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(pe.Per_ApellidoPaterno)), N''),
                               NULLIF(LTRIM(RTRIM(pe.Per_ApellidoMaterno)), N'')) AS Encargado,
               pe.Per_Telefono
        FROM app.tbEncargados_tbAlumnos ea
        JOIN app.tbEncargados e  ON e.Enc_Id  = ea.Enc_Id
        JOIN app.tbPersonas   pe ON pe.Per_Id = e.Per_Id
        WHERE ea.Alu_Id = al.Alu_Id
        ORDER BY ea.Enc_Id
    ) enc
    WHERE (@SoloSinFicha = 0 OR f.Fsa_Id IS NULL)
      AND (@SoloConAlerta = 0 OR f.Fsa_TieneAlerta = 1)
      AND (@q IS NULL
           OR al.Alumno LIKE N'%' + @q + N'%'
           OR al.Per_Identidad LIKE N'%' + @qIdentidad + N'%')
    ORDER BY al.Niv_Id, al.Cun_Id, s.Sec_Descripcion, al.Per_ApellidoPaterno, al.Per_ApellidoMaterno, al.Per_PrimerNombre;
END
GO

/* ---------------------------------------------------------------- Ficha */

-- El alumno y su ficha (columnas Fsa_* en NULL si todavía no tiene). Sin fila si el alumno no existe.
CREATE OR ALTER PROCEDURE app.PR_tbFichasSalud_Find
    @Alu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT a.Alu_Id,
           CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), N''),
                           NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N'')) AS Alumno,
           p.Per_PrimerNombre AS PrimerNombre, p.Per_ApellidoPaterno AS ApellidoPaterno,
           p.Per_Identidad AS Identidad, p.Per_Imagen AS Foto, p.Per_Sexo AS Sexo, p.Per_FechaNacimiento AS FechaNacimiento,
           n.Niv_Descripcion AS Nivel, cn.Cun_Descripcion AS Grado, s.Sec_Descripcion AS Seccion,
           NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(c.Cur_Nombre, CHAR(13), N''), CHAR(10), N''))), N'') AS Curso,
           est.Est_Descripcion AS Estado,
           f.Fsa_Id, f.Fsa_TipoSangre, CAST(ISNULL(f.Fsa_TieneAlerta, 0) AS bit) AS Fsa_TieneAlerta, f.Fsa_Alerta,
           f.Fsa_Alergias, f.Fsa_Condiciones, f.Fsa_Medicamentos, f.Fsa_RestriccionesAlimentarias,
           f.Fsa_MedicoNombre, f.Fsa_MedicoTelefono, f.Fsa_Hospital, f.Fsa_Seguro, f.Fsa_SeguroPoliza,
           f.Fsa_ContactoEmergenciaNombre, f.Fsa_ContactoEmergenciaParentesco, f.Fsa_ContactoEmergenciaTelefono,
           f.Fsa_Notas, f.Fsa_Version, f.Fsa_FechaRegistra,
           COALESCE(f.Fsa_FechaModifica, f.Fsa_FechaRegistra) AS Actualizada,
           app.FN_NombreUsuario(COALESCE(f.Fsa_UsuarioModifica, f.Fsa_UsuarioRegistra)) AS ActualizadaPor
    FROM app.tbAlumnos a
    JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id
    LEFT JOIN app.tbNivelesEducativos n   ON n.Niv_Id   = a.Niv_Id
    LEFT JOIN app.tbCursosNiveles     cn  ON cn.Cun_Id  = a.Cun_Id
    LEFT JOIN app.tbSecciones         s   ON s.Sec_Id   = a.Sec_Id
    LEFT JOIN app.tbCursos            c   ON c.Cur_Id   = a.Cur_Id
    LEFT JOIN app.tbEstados           est ON est.Est_Id = a.Est_Id
    LEFT JOIN app.tbFichasSalud       f   ON f.Alu_Id   = a.Alu_Id
    WHERE a.Alu_Id = @Alu_Id
      AND ISNULL(p.Per_EsEliminado, 0) = 0;
END
GO

-- A quién llamar: los encargados del alumno con su teléfono (el principal primero).
CREATE OR ALTER PROCEDURE app.PR_tbFichasSalud_Contactos
    @Alu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ea.Enc_Id,
           CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(pe.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(pe.Per_SegundoNombre)), N''),
                           NULLIF(LTRIM(RTRIM(pe.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(pe.Per_ApellidoMaterno)), N'')) AS Nombre,
           par.Par_Descripcion AS Parentesco,
           NULLIF(LTRIM(RTRIM(pe.Per_Telefono)), '') AS Telefono,
           NULLIF(LTRIM(RTRIM(pe.Per_CorreoElectronico)), '') AS Correo,
           CAST(CASE WHEN ROW_NUMBER() OVER (ORDER BY ea.Enc_Id) = 1 THEN 1 ELSE 0 END AS bit) AS EsPrincipal
    FROM app.tbEncargados_tbAlumnos ea
    JOIN app.tbEncargados e  ON e.Enc_Id  = ea.Enc_Id
    JOIN app.tbPersonas   pe ON pe.Per_Id = e.Per_Id
    LEFT JOIN app.tbParentescos par ON par.Par_Id = ea.Par_Id
    WHERE ea.Alu_Id = @Alu_Id
      AND ISNULL(pe.Per_EsEliminado, 0) = 0
    ORDER BY ea.Enc_Id;
END
GO

/* ---------------------------------------------------------------- Guardar (crear o cambiar) */

-- Crea la ficha si no existe o la cambia si existe, y anota en la bitácora los campos que cambiaron.
-- @Fsa_Version = versión que leyó quien guarda (NULL si la ficha era nueva). Si no coincide con la
-- actual, otra persona guardó antes: se rechaza para no pisar sus cambios.
-- Devuelve Fsa_Id, Fsa_Version, Accion (creada | editada | sin_cambios) y Campos.
CREATE OR ALTER PROCEDURE app.PR_tbFichasSalud_Guardar
    @Alu_Id                           int,
    @Fsa_TipoSangre                   varchar(3)     = NULL,
    @Fsa_TieneAlerta                  bit            = 0,
    @Fsa_Alerta                       nvarchar(150)  = NULL,
    @Fsa_Alergias                     nvarchar(2000) = NULL,
    @Fsa_Condiciones                  nvarchar(2000) = NULL,
    @Fsa_Medicamentos                 nvarchar(2000) = NULL,
    @Fsa_RestriccionesAlimentarias    nvarchar(2000) = NULL,
    @Fsa_MedicoNombre                 nvarchar(100)  = NULL,
    @Fsa_MedicoTelefono               varchar(9)     = NULL,
    @Fsa_Hospital                     nvarchar(150)  = NULL,
    @Fsa_Seguro                       nvarchar(100)  = NULL,
    @Fsa_SeguroPoliza                 nvarchar(50)   = NULL,
    @Fsa_ContactoEmergenciaNombre     nvarchar(100)  = NULL,
    @Fsa_ContactoEmergenciaParentesco nvarchar(50)   = NULL,
    @Fsa_ContactoEmergenciaTelefono   varchar(9)     = NULL,
    @Fsa_Notas                        nvarchar(4000) = NULL,
    @Fsa_Version                      int            = NULL,
    @Usuario                          int            = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Vacío = sin dato.
    SET @Fsa_TipoSangre                   = NULLIF(UPPER(LTRIM(RTRIM(@Fsa_TipoSangre))), '');
    SET @Fsa_TieneAlerta                  = ISNULL(@Fsa_TieneAlerta, 0);
    SET @Fsa_Alerta                       = CASE WHEN @Fsa_TieneAlerta = 1 THEN NULLIF(LTRIM(RTRIM(@Fsa_Alerta)), N'') END;
    SET @Fsa_Alergias                     = NULLIF(LTRIM(RTRIM(@Fsa_Alergias)), N'');
    SET @Fsa_Condiciones                  = NULLIF(LTRIM(RTRIM(@Fsa_Condiciones)), N'');
    SET @Fsa_Medicamentos                 = NULLIF(LTRIM(RTRIM(@Fsa_Medicamentos)), N'');
    SET @Fsa_RestriccionesAlimentarias    = NULLIF(LTRIM(RTRIM(@Fsa_RestriccionesAlimentarias)), N'');
    SET @Fsa_MedicoNombre                 = NULLIF(LTRIM(RTRIM(@Fsa_MedicoNombre)), N'');
    SET @Fsa_MedicoTelefono               = NULLIF(LTRIM(RTRIM(@Fsa_MedicoTelefono)), '');
    SET @Fsa_Hospital                     = NULLIF(LTRIM(RTRIM(@Fsa_Hospital)), N'');
    SET @Fsa_Seguro                       = NULLIF(LTRIM(RTRIM(@Fsa_Seguro)), N'');
    SET @Fsa_SeguroPoliza                 = NULLIF(LTRIM(RTRIM(@Fsa_SeguroPoliza)), N'');
    SET @Fsa_ContactoEmergenciaNombre     = NULLIF(LTRIM(RTRIM(@Fsa_ContactoEmergenciaNombre)), N'');
    SET @Fsa_ContactoEmergenciaParentesco = NULLIF(LTRIM(RTRIM(@Fsa_ContactoEmergenciaParentesco)), N'');
    SET @Fsa_ContactoEmergenciaTelefono   = NULLIF(LTRIM(RTRIM(@Fsa_ContactoEmergenciaTelefono)), '');
    SET @Fsa_Notas                        = NULLIF(LTRIM(RTRIM(@Fsa_Notas)), N'');

    IF NOT EXISTS (SELECT 1 FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id)
        THROW 50070, N'El alumno ya no existe.', 1;
    IF @Fsa_TipoSangre IS NOT NULL AND @Fsa_TipoSangre NOT IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')
        THROW 50071, N'Elija un tipo de sangre de la lista.', 1;
    IF @Fsa_TieneAlerta = 1 AND @Fsa_Alerta IS NULL
        THROW 50072, N'Escriba la alerta que verá el docente (ej. "Alergia grave al maní, lleva epinefrina").', 1;
    IF @Fsa_MedicoTelefono IS NOT NULL AND @Fsa_MedicoTelefono NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
        THROW 50073, N'El teléfono del médico debe tener 8 dígitos (ej. 9999-9999).', 1;
    IF @Fsa_ContactoEmergenciaTelefono IS NOT NULL AND @Fsa_ContactoEmergenciaTelefono NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
        THROW 50074, N'El teléfono del contacto adicional debe tener 8 dígitos (ej. 9999-9999).', 1;
    IF @Fsa_ContactoEmergenciaTelefono IS NULL AND (@Fsa_ContactoEmergenciaNombre IS NOT NULL OR @Fsa_ContactoEmergenciaParentesco IS NOT NULL)
        THROW 50076, N'Escriba el teléfono del contacto adicional.', 1;
    IF @Fsa_ContactoEmergenciaNombre IS NULL AND @Fsa_ContactoEmergenciaTelefono IS NOT NULL
        THROW 50077, N'Escriba el nombre del contacto adicional.', 1;

    DECLARE @Ahora datetime2(0) = app.FN_AhoraHonduras();

    BEGIN TRAN;

    -- Lo que hay hoy (bloqueado: dos guardados a la vez no crean dos fichas ni se pisan).
    DECLARE @Fsa_Id int, @VersionActual int,
            @a_TipoSangre varchar(3), @a_TieneAlerta bit = 0, @a_Alerta nvarchar(150),
            @a_Alergias nvarchar(2000), @a_Condiciones nvarchar(2000), @a_Medicamentos nvarchar(2000),
            @a_Restricciones nvarchar(2000), @a_MedicoNombre nvarchar(100), @a_MedicoTelefono varchar(9),
            @a_Hospital nvarchar(150), @a_Seguro nvarchar(100), @a_SeguroPoliza nvarchar(50),
            @a_ContactoNombre nvarchar(100), @a_ContactoParentesco nvarchar(50), @a_ContactoTelefono varchar(9),
            @a_Notas nvarchar(4000);

    SELECT @Fsa_Id = Fsa_Id, @VersionActual = Fsa_Version,
           @a_TipoSangre = Fsa_TipoSangre, @a_TieneAlerta = Fsa_TieneAlerta, @a_Alerta = Fsa_Alerta,
           @a_Alergias = Fsa_Alergias, @a_Condiciones = Fsa_Condiciones, @a_Medicamentos = Fsa_Medicamentos,
           @a_Restricciones = Fsa_RestriccionesAlimentarias, @a_MedicoNombre = Fsa_MedicoNombre,
           @a_MedicoTelefono = Fsa_MedicoTelefono, @a_Hospital = Fsa_Hospital, @a_Seguro = Fsa_Seguro,
           @a_SeguroPoliza = Fsa_SeguroPoliza, @a_ContactoNombre = Fsa_ContactoEmergenciaNombre,
           @a_ContactoParentesco = Fsa_ContactoEmergenciaParentesco, @a_ContactoTelefono = Fsa_ContactoEmergenciaTelefono,
           @a_Notas = Fsa_Notas
    FROM app.tbFichasSalud WITH (UPDLOCK, HOLDLOCK)
    WHERE Alu_Id = @Alu_Id;

    IF @Fsa_Id IS NOT NULL AND (@Fsa_Version IS NULL OR @Fsa_Version <> @VersionActual)
        THROW 50075, N'Otra persona guardó cambios en esta ficha mientras usted la editaba. Recargue la página para ver la versión actual y vuelva a hacer sus cambios.', 1;

    -- Qué campos cambian (nombres en español, sin valores).
    DECLARE @Campos nvarchar(1000) = (
        SELECT STRING_AGG(v.Campo, N', ') WITHIN GROUP (ORDER BY v.Orden)
        FROM (VALUES
            ( 1, N'Alerta crítica',             CASE WHEN @a_TieneAlerta <> @Fsa_TieneAlerta OR app.FN_FichaSalud_Distinto(@a_Alerta, @Fsa_Alerta) = 1 THEN 1 ELSE 0 END),
            ( 2, N'Tipo de sangre',             app.FN_FichaSalud_Distinto(@a_TipoSangre, @Fsa_TipoSangre)),
            ( 3, N'Alergias',                   app.FN_FichaSalud_Distinto(@a_Alergias, @Fsa_Alergias)),
            ( 4, N'Condiciones',                app.FN_FichaSalud_Distinto(@a_Condiciones, @Fsa_Condiciones)),
            ( 5, N'Medicamentos',               app.FN_FichaSalud_Distinto(@a_Medicamentos, @Fsa_Medicamentos)),
            ( 6, N'Restricciones alimentarias', app.FN_FichaSalud_Distinto(@a_Restricciones, @Fsa_RestriccionesAlimentarias)),
            ( 7, N'Médico',                     app.FN_FichaSalud_Distinto(@a_MedicoNombre, @Fsa_MedicoNombre)),
            ( 8, N'Teléfono del médico',        app.FN_FichaSalud_Distinto(@a_MedicoTelefono, @Fsa_MedicoTelefono)),
            ( 9, N'Hospital o clínica',         app.FN_FichaSalud_Distinto(@a_Hospital, @Fsa_Hospital)),
            (10, N'Seguro',                     app.FN_FichaSalud_Distinto(@a_Seguro, @Fsa_Seguro)),
            (11, N'Póliza',                     app.FN_FichaSalud_Distinto(@a_SeguroPoliza, @Fsa_SeguroPoliza)),
            (12, N'Contacto adicional',         app.FN_FichaSalud_Distinto(@a_ContactoNombre, @Fsa_ContactoEmergenciaNombre)),
            (13, N'Parentesco del contacto',    app.FN_FichaSalud_Distinto(@a_ContactoParentesco, @Fsa_ContactoEmergenciaParentesco)),
            (14, N'Teléfono del contacto',      app.FN_FichaSalud_Distinto(@a_ContactoTelefono, @Fsa_ContactoEmergenciaTelefono)),
            (15, N'Notas',                      app.FN_FichaSalud_Distinto(@a_Notas, @Fsa_Notas))
        ) v (Orden, Campo, Cambio)
        WHERE v.Cambio = 1);

    IF @Fsa_Id IS NULL
    BEGIN
        INSERT INTO app.tbFichasSalud
            (Alu_Id, Fsa_TipoSangre, Fsa_TieneAlerta, Fsa_Alerta, Fsa_Alergias, Fsa_Condiciones, Fsa_Medicamentos,
             Fsa_RestriccionesAlimentarias, Fsa_MedicoNombre, Fsa_MedicoTelefono, Fsa_Hospital, Fsa_Seguro, Fsa_SeguroPoliza,
             Fsa_ContactoEmergenciaNombre, Fsa_ContactoEmergenciaParentesco, Fsa_ContactoEmergenciaTelefono, Fsa_Notas,
             Fsa_Version, Fsa_UsuarioRegistra, Fsa_FechaRegistra)
        VALUES
            (@Alu_Id, @Fsa_TipoSangre, @Fsa_TieneAlerta, @Fsa_Alerta, @Fsa_Alergias, @Fsa_Condiciones, @Fsa_Medicamentos,
             @Fsa_RestriccionesAlimentarias, @Fsa_MedicoNombre, @Fsa_MedicoTelefono, @Fsa_Hospital, @Fsa_Seguro, @Fsa_SeguroPoliza,
             @Fsa_ContactoEmergenciaNombre, @Fsa_ContactoEmergenciaParentesco, @Fsa_ContactoEmergenciaTelefono, @Fsa_Notas,
             1, @Usuario, @Ahora);
        SET @Fsa_Id = CAST(SCOPE_IDENTITY() AS int);

        INSERT INTO app.tbFichasSaludBitacora (Fsa_Id, Alu_Id, Fsb_Accion, Fsb_Campos, Fsb_Usuario, Fsb_Fecha)
        VALUES (@Fsa_Id, @Alu_Id, 'creada', ISNULL(@Campos, N'Ficha sin datos'), @Usuario, @Ahora);

        COMMIT;
        SELECT @Fsa_Id AS Fsa_Id, 1 AS Fsa_Version, CAST('creada' AS varchar(12)) AS Accion, @Campos AS Campos;
        RETURN;
    END

    IF @Campos IS NULL
    BEGIN
        COMMIT;
        SELECT @Fsa_Id AS Fsa_Id, @VersionActual AS Fsa_Version, CAST('sin_cambios' AS varchar(12)) AS Accion, CAST(NULL AS nvarchar(1000)) AS Campos;
        RETURN;
    END

    UPDATE app.tbFichasSalud
    SET Fsa_TipoSangre                   = @Fsa_TipoSangre,
        Fsa_TieneAlerta                  = @Fsa_TieneAlerta,
        Fsa_Alerta                       = @Fsa_Alerta,
        Fsa_Alergias                     = @Fsa_Alergias,
        Fsa_Condiciones                  = @Fsa_Condiciones,
        Fsa_Medicamentos                 = @Fsa_Medicamentos,
        Fsa_RestriccionesAlimentarias    = @Fsa_RestriccionesAlimentarias,
        Fsa_MedicoNombre                 = @Fsa_MedicoNombre,
        Fsa_MedicoTelefono               = @Fsa_MedicoTelefono,
        Fsa_Hospital                     = @Fsa_Hospital,
        Fsa_Seguro                       = @Fsa_Seguro,
        Fsa_SeguroPoliza                 = @Fsa_SeguroPoliza,
        Fsa_ContactoEmergenciaNombre     = @Fsa_ContactoEmergenciaNombre,
        Fsa_ContactoEmergenciaParentesco = @Fsa_ContactoEmergenciaParentesco,
        Fsa_ContactoEmergenciaTelefono   = @Fsa_ContactoEmergenciaTelefono,
        Fsa_Notas                        = @Fsa_Notas,
        Fsa_Version                      = Fsa_Version + 1,
        Fsa_UsuarioModifica              = @Usuario,
        Fsa_FechaModifica                = @Ahora
    WHERE Fsa_Id = @Fsa_Id;

    INSERT INTO app.tbFichasSaludBitacora (Fsa_Id, Alu_Id, Fsb_Accion, Fsb_Campos, Fsb_Usuario, Fsb_Fecha)
    VALUES (@Fsa_Id, @Alu_Id, 'editada', @Campos, @Usuario, @Ahora);

    COMMIT;
    SELECT @Fsa_Id AS Fsa_Id, @VersionActual + 1 AS Fsa_Version, CAST('editada' AS varchar(12)) AS Accion, @Campos AS Campos;
END
GO

/* ---------------------------------------------------------------- Bitácora */

-- Historial de cambios de la ficha de un alumno (lo más reciente primero).
CREATE OR ALTER PROCEDURE app.PR_tbFichasSaludBitacora_List
    @Alu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT b.Fsb_Id, b.Fsb_Accion, b.Fsb_Campos, b.Fsb_Fecha, b.Fsb_Usuario,
           app.FN_NombreUsuario(b.Fsb_Usuario) AS Usuario
    FROM app.tbFichasSaludBitacora b
    WHERE b.Alu_Id = @Alu_Id
    ORDER BY b.Fsb_Id DESC;
END
GO

/* ---------------------------------------------------------------- Alertas del pase de lista */

-- Alertas críticas de la sección de un horario: los mismos alumnos del pase de lista
-- (PR_tbAsistencia_List). Solo Alu_Id y el texto corto de la alerta: el docente no ve el resto.
CREATE OR ALTER PROCEDURE app.PR_tbFichasSalud_AlertasSeccion
    @Hor_Id int,
    @Fecha  date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Fecha = ISNULL(@Fecha, CAST(app.FN_AhoraHonduras() AS date));

    DECLARE @Sea_Id int = (SELECT Sea_Id FROM app.FN_SeccionAnioDeHorario(@Hor_Id, @Fecha));
    DECLARE @Cur_Id int, @Cun_Id int, @Sec_Id int, @Mda_Id int;
    SELECT @Cur_Id = Cur_Id, @Cun_Id = Cun_Id, @Sec_Id = Sec_Id, @Mda_Id = Mda_Id
    FROM app.tbHorarios
    WHERE Hor_Id = @Hor_Id;

    ;WITH lista AS (
        SELECT m.Alu_Id
        FROM app.tbMatriculaAnio m
        JOIN app.tbAlumnos al ON al.Alu_Id = m.Alu_Id
        WHERE @Sea_Id IS NOT NULL
          AND m.Sea_Id = @Sea_Id
          AND m.Mta_EsEliminado = 0
          AND m.Mta_Estado <> 4
          AND (@Cur_Id IS NULL OR al.Cur_Id IS NULL OR al.Cur_Id = @Cur_Id)
        UNION
        SELECT al.Alu_Id
        FROM app.tbAlumnos al
        WHERE @Sea_Id IS NULL
          AND al.Cun_Id = @Cun_Id
          AND al.Sec_Id = @Sec_Id
          AND ISNULL(al.Mda_Id, 0) = ISNULL(@Mda_Id, 0)
          AND (@Cur_Id IS NULL OR al.Cur_Id IS NULL OR al.Cur_Id = @Cur_Id)
          AND ISNULL(al.Est_Id, 1) = 1
        UNION
        SELECT asi.Alu_Id
        FROM app.tbAsistencia asi
        WHERE asi.Hor_Id = @Hor_Id AND asi.Asi_Fecha = @Fecha AND asi.Asi_EsEliminado = 0
    )
    SELECT f.Alu_Id, f.Fsa_Alerta
    FROM lista l
    JOIN app.tbFichasSalud f ON f.Alu_Id = l.Alu_Id
    WHERE f.Fsa_TieneAlerta = 1
      AND f.Fsa_Alerta IS NOT NULL;
END
GO

/* ---------------------------------------------------------------- Pantallas y permisos */
--   Fichas de salud       = directorio, ficha del alumno y pestaña "Salud" de la ficha 360
--                           (admin, director, secretaria)
--   Editar ficha de salud = crear y cambiar fichas (admin, secretaria)
-- La alerta del pase de lista no necesita estos permisos: la protege "Pase de lista".
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES
    (N'Fichas de salud',       N'|admin|director|secretaria|'),
    (N'Editar ficha de salud', N'|admin|secretaria|');

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
