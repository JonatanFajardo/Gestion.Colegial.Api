/* 085 · Portal de padres con el formato nuevo de contraseñas (084).
   La activación guarda la contraseña con Contrasenas.Crear y borra cualquier clave en formato anterior
   de la cuenta. Va después de 084 porque usa la columna Usu_ContrasenaLegado. Se puede correr varias veces. */
USE DB_GestionColegial;
GO

-- Aceptar la invitación: crea la cuenta Encargado (o le pone contraseña nueva si ya existe) y
-- marca el enlace como usado. @Contrasena llega ya en el formato del login (Contrasenas.Crear: PBKDF2 con sal).
-- Responde { Usu_Id, Usu_Name }.
CREATE OR ALTER PROCEDURE app.PR_Portal_Invitaciones_Aceptar
    @TokenHash  char(64),
    @Usu_Name   nvarchar(50),
    @Contrasena varchar(255)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Inv_Id int, @Enc_Id int, @Estado varchar(10), @Vence datetime, @Usu_Id int, @Rol_Id int;
    SET @Usu_Name = NULLIF(LTRIM(RTRIM(@Usu_Name)), N'');

    SELECT TOP (1) @Rol_Id = Rol_Id FROM seguridad.tbRoles
    WHERE LOWER(LTRIM(RTRIM(Rol_Descripcion))) = N'encargado' AND Rol_EsEliminado = 0 ORDER BY Rol_Id;
    IF @Rol_Id IS NULL
        THROW 50089, N'El portal de padres no está configurado (falta el rol Encargado).', 1;
    -- Intercalación binaria: con la de la base, [a-z] también deja pasar letras con tilde o la ñ
    -- (un "jóna" que se confunde con "jona").
    IF @Usu_Name IS NULL OR LEN(@Usu_Name) < 4 OR @Usu_Name COLLATE Latin1_General_BIN2 LIKE N'%[^-a-zA-Z0-9._]%'
        THROW 50089, N'El usuario debe tener al menos 4 caracteres: letras, números, punto, guion o guion bajo, sin espacios.', 1;

    BEGIN TRAN;
        SELECT @Inv_Id = Inv_Id, @Enc_Id = Enc_Id, @Estado = Inv_Estado, @Vence = Inv_Vence
        FROM app.tbInvitacionesPortal WITH (UPDLOCK, HOLDLOCK)
        WHERE Inv_TokenHash = LOWER(@TokenHash);

        IF @Inv_Id IS NULL OR @Estado <> 'pendiente' OR @Vence < GETDATE()
            THROW 50089, N'Este enlace de invitación ya no es válido. Pida uno nuevo al colegio.', 1;

        SELECT @Usu_Id = Usu_Id FROM seguridad.tbUsuariosEncargados WITH (UPDLOCK, HOLDLOCK) WHERE Enc_Id = @Enc_Id;

        IF EXISTS (SELECT 1 FROM seguridad.tbUsuarios WITH (UPDLOCK, HOLDLOCK)
                   WHERE Usu_Name = @Usu_Name AND (@Usu_Id IS NULL OR Usu_Id <> @Usu_Id))
            THROW 50089, N'Ese nombre de usuario ya está en uso. Elija otro.', 1;

        IF @Usu_Id IS NULL
        BEGIN
            INSERT INTO seguridad.tbUsuarios (Emp_Id, Usu_Name, [Usu_Contraseña], Rol_Id, Usu_EsActivo, Usu_Suspendido, Usu_EsEliminado, Usu_FechaCreacion)
            VALUES (0, @Usu_Name, @Contrasena, @Rol_Id, 1, 0, 0, GETDATE());
            SET @Usu_Id = SCOPE_IDENTITY();
            INSERT INTO seguridad.tbUsuariosEncargados (Usu_Id, Enc_Id) VALUES (@Usu_Id, @Enc_Id);
        END
        ELSE
            UPDATE seguridad.tbUsuarios
            SET Usu_Name = @Usu_Name, [Usu_Contraseña] = @Contrasena, Usu_ContrasenaLegado = NULL, Rol_Id = @Rol_Id,
                Usu_EsActivo = 1, Usu_EsEliminado = 0, Usu_fechaModificacion = GETDATE()
            WHERE Usu_Id = @Usu_Id;

        UPDATE app.tbInvitacionesPortal
        SET Inv_Estado = 'aceptada', Inv_FechaAceptada = GETDATE(), Usu_IdCuenta = @Usu_Id
        WHERE Inv_Id = @Inv_Id;
    COMMIT;

    SELECT @Usu_Id AS Usu_Id, @Usu_Name AS Usu_Name;
END
GO
