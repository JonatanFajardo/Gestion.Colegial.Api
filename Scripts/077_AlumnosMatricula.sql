/* =============================================================================
   077 · Alumnos y matrícula
   - Vínculo encargado–alumno con parentesco: PR_tbEncargados_Vincular / _Desvincular.
   - PR_tbAlumnos_Find: devuelve Per_Id y Per_EsActivo (la edición no actualizaba nada sin ellos).
   - PR_tbAlumnos_Insert: deja de tragarse los errores (antes quedaba "guardado" sin crear al alumno).
   - Catálogo de parentescos: quita "Primer/Segundo Grado" y deja Padre, Madre, Abuelo(a), Tío(a),
     Hermano(a), Tutor(a) legal y Otro. Los Id 1 y 2 se renombran (Madre / Padre); los aspirantes
     de la lista de espera que apuntaban a ellos se reubican por el nombre del encargado.
   - Cupo de secciones del año sin cupo: 35, o los matriculados si son más.
   Idempotente.
   ============================================================================= */
USE DB_GestionColegial;
GO

CREATE OR ALTER PROCEDURE dbo.PR_tbEncargados_Vincular
    @Enc_Id INT, @Alu_Id INT, @Par_Id INT
AS
BEGIN
    SET NOCOUNT OFF;
    IF NOT EXISTS (SELECT 1 FROM app.tbEncargados WHERE Enc_Id = @Enc_Id)
        THROW 50101, 'El encargado no existe.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id)
        THROW 50102, 'El alumno no existe.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbParentescos WHERE Par_Id = @Par_Id AND Par_EsEliminado = 0)
        THROW 50103, 'El parentesco no existe.', 1;

    IF EXISTS (SELECT 1 FROM app.tbEncargados_tbAlumnos WHERE Enc_Id = @Enc_Id AND Alu_Id = @Alu_Id)
        UPDATE app.tbEncargados_tbAlumnos SET Par_Id = @Par_Id WHERE Enc_Id = @Enc_Id AND Alu_Id = @Alu_Id;
    ELSE
        INSERT INTO app.tbEncargados_tbAlumnos (Enc_Id, Alu_Id, Par_Id) VALUES (@Enc_Id, @Alu_Id, @Par_Id);
END
GO

CREATE OR ALTER PROCEDURE dbo.PR_tbEncargados_Desvincular
    @Enc_Id INT, @Alu_Id INT
AS
BEGIN
    SET NOCOUNT OFF;
    IF NOT EXISTS (SELECT 1 FROM app.tbEncargados_tbAlumnos WHERE Enc_Id = @Enc_Id AND Alu_Id = @Alu_Id)
        THROW 50104, 'Ese encargado no está ligado al alumno.', 1;
    DELETE FROM app.tbEncargados_tbAlumnos WHERE Enc_Id = @Enc_Id AND Alu_Id = @Alu_Id;
END
GO

/* Mismo comportamiento; solo vuelve a lanzar el error en vez de callarlo. */
CREATE OR ALTER PROCEDURE [dbo].[PR_tbAlumnos_Insert]
	@Niv_Id int,
	@Cun_Id int,
	@Mda_Id int,
	@Cur_Id int,
	@Sec_Id int,
	@Est_Id int,
	@Per_Identidad	varchar(13),
	@Per_PrimerNombre	nvarchar(50),
	@Per_SegundoNombre	nvarchar(50),
	@Per_ApellidoPaterno	nvarchar(50),
	@Per_ApellidoMaterno	nvarchar(50),
	@Per_FechaNacimiento	date,
	@Per_CorreoElectronico	varchar(150),
	@Per_Telefono	varchar(9),
	@Per_Direccion	varchar(150),
	@Per_Sexo	char(1),
	@Per_UsuarioRegistra	int
AS
  BEGIN
	BEGIN TRANSACTION
		BEGIN TRY
		 EXEC [PR_tbPersonas_Insert]
			 @Per_Identidad,
			 @Per_PrimerNombre,
			 @Per_SegundoNombre,
			 @Per_ApellidoPaterno,
			 @Per_ApellidoMaterno,
			 @Per_FechaNacimiento,
			 @Per_CorreoElectronico,
			 @Per_Telefono,
			 @Per_Direccion,
			 @Per_Sexo,
			 @Per_UsuarioRegistra

		DECLARE @Per_Id INT;
		SET @Per_Id = IDENT_CURRENT('[app].[tbPersonas]');

          INSERT INTO [app].[tbAlumnos]
					(Per_Id, Niv_Id, Cun_Id, Mda_Id, Cur_Id, Sec_Id, Est_Id, AnioCursado)
          VALUES
		  			(@Per_Id, @Niv_Id, @Cun_Id, @Mda_Id, @Cur_Id, @Sec_Id, @Est_Id, DATEPART(YEAR, GETDATE()))
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		THROW;
	END CATCH
  END
GO

/* PR_tbAlumnos_Find ahora devuelve también Per_Id y Per_EsActivo: sin ellos, el formulario de edición
   no sabía a qué persona actualizar y guardaba sin cambiar nada. Mismas columnas de antes + esas dos. */
CREATE OR ALTER PROCEDURE [dbo].[PR_tbAlumnos_Find]
@Alu_Id	INT
AS
BEGIN
SELECT		alumnos.Niv_Id,
			niveleseducativos.Niv_Descripcion,
			alumnos.Cun_Id,
			cursosniveles.Cun_Descripcion,
			alumnos.Mda_Id,
			modalidades.Mda_Descripcion,
			alumnos.Cur_Id,
			cursos.Cur_Nombre,
			alumnos.Sec_Id,
			secciones.Sec_Descripcion,
			alumnos.Est_Id,
			estados.Est_Descripcion,
			alumnos.Alu_Id,
			personas.Per_Identidad,
			personas.Per_PrimerNombre,
			personas.Per_SegundoNombre,
			personas.Per_ApellidoPaterno,
			personas.Per_ApellidoMaterno,
			personas.Per_FechaNacimiento,
			personas.Per_CorreoElectronico,
			personas.Per_Telefono,
			personas.Per_Direccion,
			personas.Per_Sexo,
			personas.Per_EsEliminado AS Per_EsEliminado,
			alumnos.Per_Id,
			personas.Per_EsActivo
FROM 		[app].[tbAlumnos] AS alumnos
INNER JOIN 	[app].[tbPersonas] AS personas
ON 			alumnos.Per_Id = personas.Per_Id
INNER JOIN  [app].[tbCursos] AS cursos
ON			alumnos.Cur_Id = cursos.Cur_Id
INNER JOIN	[app].[tbEstados] AS estados
ON			alumnos.Est_Id = estados.Est_Id
INNER JOIN	[app].[tbModalidades] AS modalidades
ON			modalidades.Mda_Id = alumnos.Mda_Id
INNER JOIN	[app].[tbCursosNiveles] AS cursosniveles
ON			cursosniveles.Cun_Id = alumnos.Cun_Id
INNER JOIN	[app].[tbSecciones] AS secciones
ON			secciones.Sec_Id = alumnos.Sec_Id
INNER JOIN	[app].[tbNivelesEducativos] AS niveleseducativos
ON			niveleseducativos.Niv_Id = alumnos.Niv_Id
WHERE  		personas.Per_EsEliminado != 1
AND	 		Alu_Id = @Alu_Id
END
GO

/* ---- Parentescos ---- */
-- Los aspirantes con encargado hombre (hoy todos apuntan a "Primer Grado") pasan a Padre (Id 2);
-- el resto de los que apuntaban al Id 1 queda en Madre (Id 1). Se hace antes de renombrar.
IF EXISTS (SELECT 1 FROM app.tbParentescos WHERE Par_Id = 1 AND Par_Descripcion = 'Primer Grado')
BEGIN
    UPDATE app.tbAspirantes SET Par_Id = 2
    WHERE Par_Id = 1 AND Asp_Id IN (3, 6, 10, 12);   -- José Luis, Héctor Manuel, Wilmer, Marcos
    UPDATE app.tbParentescos SET Par_Descripcion = 'Madre', Par_FechaModifica = GETDATE(), Par_UsuarioModifica = 1 WHERE Par_Id = 1;
END
IF EXISTS (SELECT 1 FROM app.tbParentescos WHERE Par_Id = 2 AND Par_Descripcion = 'Segundo Grado')
    UPDATE app.tbParentescos SET Par_Descripcion = 'Padre', Par_FechaModifica = GETDATE(), Par_UsuarioModifica = 1 WHERE Par_Id = 2;

INSERT INTO app.tbParentescos (Par_Descripcion, Par_EsEliminado, Par_UsuarioRegistra, Par_FechaRegistra)
SELECT v.d, 0, 1, GETDATE()
FROM (VALUES ('Abuelo(a)'), ('Tío(a)'), ('Hermano(a)'), ('Tutor(a) legal'), ('Otro')) v(d)
WHERE NOT EXISTS (SELECT 1 FROM app.tbParentescos p WHERE p.Par_Descripcion = v.d);
GO

/* ---- Cupo de secciones sin cupo ---- */
UPDATE s SET Sea_Cupo = CASE WHEN m.n > 35 THEN m.n ELSE 35 END
FROM app.tbSeccionesAnio s
OUTER APPLY (SELECT COUNT(*) AS n FROM app.tbMatriculaAnio x
             WHERE x.Sea_Id = s.Sea_Id AND x.Mta_EsEliminado = 0) m
WHERE s.Sea_Cupo IS NULL AND s.Sea_EsEliminado = 0;
GO
