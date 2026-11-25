/* =============================================================================
   092 · Correcciones: secciones del curso y encargados sin vínculo

   1) PR_tbCursos_tbSecciones_Insert / _Update: la tabla app.tbCursos_tbSecciones exige Aul_Id
      (NOT NULL, FK a tbAulas) y los procedimientos no lo llenaban: crear o editar un curso con
      secciones fallaba. Ahora se asigna el primer aula que ningún curso-sección usa todavía (si
      todas están usadas, la de menor Id). Mismas firmas; @Aul_Id del Update pasa a ser opcional.
   2) PR_tbEncargados_SinVinculo: alumnos activos sin ningún encargado ligado y encargados sin
      ningún hijo ligado (pantalla "Vínculos familiares").
   Idempotente.
   ============================================================================= */
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.PR_tbCursos_tbSecciones_Insert
	@Sec_Id INT,
	@Cur_Id int = NULL,
	@Cur_Nombre nvarchar(50) = NULL,
	@Niv_Id int = NULL
AS
	BEGIN
		BEGIN TRAN
			BEGIN TRY
				SET @Cur_Id = ISNULL(@Cur_Id, (SELECT MAX(Cur_Id) FROM [app].[tbCursos] WHERE Cur_Nombre = @Cur_Nombre AND Niv_Id = @Niv_Id));
				SET @Cur_Id = ISNULL(@Cur_Id, (SELECT MAX(Cur_Id) FROM [app].[tbCursos]));

				-- Aula: la primera sin curso-sección; si todas están usadas, la de menor Id.
				DECLARE @Aul_Id INT = (SELECT TOP 1 a.Aul_Id FROM [app].[tbAulas] a
					WHERE a.Aul_EsEliminado = 0
					  AND NOT EXISTS (SELECT 1 FROM [app].[tbCursos_tbSecciones] x WHERE x.Aul_Id = a.Aul_Id)
					ORDER BY a.Aul_Id);
				SET @Aul_Id = ISNULL(@Aul_Id, (SELECT MIN(Aul_Id) FROM [app].[tbAulas] WHERE Aul_EsEliminado = 0));

				IF NOT EXISTS (SELECT 1 FROM [app].[tbCursos_tbSecciones] WHERE Cur_Id = @Cur_Id AND Sec_Id = @Sec_Id)
					INSERT INTO [app].[tbCursos_tbSecciones] (Cur_Id, Sec_Id, Aul_Id) VALUES (@Cur_Id, @Sec_Id, @Aul_Id)
				COMMIT TRAN
			END TRY
			BEGIN CATCH
				SELECT ERROR_MESSAGE();
				IF @@TRANCOUNT > 0 ROLLBACK TRAN
			END CATCH
	END
GO

CREATE OR ALTER PROCEDURE dbo.PR_tbCursos_tbSecciones_Update
	@Cur_Id INT,
	@Sec_Id INT,
	@Aul_Id INT = NULL
AS
	BEGIN
		BEGIN TRAN
			BEGIN TRY
				IF @Aul_Id IS NULL
				BEGIN
					SET @Aul_Id = (SELECT TOP 1 a.Aul_Id FROM [app].[tbAulas] a
						WHERE a.Aul_EsEliminado = 0
						  AND NOT EXISTS (SELECT 1 FROM [app].[tbCursos_tbSecciones] x WHERE x.Aul_Id = a.Aul_Id)
						ORDER BY a.Aul_Id);
					SET @Aul_Id = ISNULL(@Aul_Id, (SELECT MIN(Aul_Id) FROM [app].[tbAulas] WHERE Aul_EsEliminado = 0));
				END

				IF NOT EXISTS (SELECT 1 FROM [app].[tbCursos_tbSecciones] WHERE Cur_Id = @Cur_Id AND Sec_Id = @Sec_Id)
					INSERT INTO [app].[tbCursos_tbSecciones] (Cur_Id, Sec_Id, Aul_Id) VALUES (@Cur_Id, @Sec_Id, @Aul_Id)
				COMMIT TRAN
			END TRY
			BEGIN CATCH
				SELECT ERROR_MESSAGE();
				IF @@TRANCOUNT > 0 ROLLBACK TRAN
			END CATCH
	END
GO

/* Alumnos activos sin encargado (@Tipo = 'alumnos') o encargados sin hijos (@Tipo = 'encargados').
   Misma forma para los dos: Id, Nombre, Identidad, Telefono y Detalle (grado y sección del alumno,
   u ocupación del encargado). */
CREATE OR ALTER PROCEDURE dbo.PR_tbEncargados_SinVinculo
	@Tipo VARCHAR(12)
AS
BEGIN
	SET NOCOUNT ON;
	IF @Tipo = 'alumnos'
		SELECT a.Alu_Id AS Id,
		       CONCAT_WS(' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), ''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), ''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), ''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), '')) AS Nombre,
		       p.Per_Identidad AS Identidad,
		       p.Per_Telefono AS Telefono,
		       CONCAT_WS(' ', g.Cun_Descripcion, s.Sec_Descripcion) AS Detalle
		FROM app.tbAlumnos a
		     INNER JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id
		     LEFT JOIN app.tbCursosNiveles g ON g.Cun_Id = a.Cun_Id
		     LEFT JOIN app.tbSecciones s ON s.Sec_Id = a.Sec_Id
		WHERE p.Per_EsEliminado = 0 AND p.Per_EsActivo = 1
		  AND NOT EXISTS (SELECT 1 FROM app.tbEncargados_tbAlumnos v WHERE v.Alu_Id = a.Alu_Id)
		ORDER BY p.Per_ApellidoPaterno, p.Per_PrimerNombre;
	ELSE
		SELECT e.Enc_Id AS Id,
		       CONCAT_WS(' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), ''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), ''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), ''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), '')) AS Nombre,
		       p.Per_Identidad AS Identidad,
		       p.Per_Telefono AS Telefono,
		       e.Enc_Ocupacion AS Detalle
		FROM app.tbEncargados e
		     INNER JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id
		WHERE p.Per_EsEliminado = 0
		  AND NOT EXISTS (SELECT 1 FROM app.tbEncargados_tbAlumnos v WHERE v.Enc_Id = e.Enc_Id)
		ORDER BY p.Per_ApellidoPaterno, p.Per_PrimerNombre;
END
GO
