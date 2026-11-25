/* =============================================================================
   088 · Reportes y académico

   1. Rol Consulta (1007) entra al Centro de reportes. El centro solo le muestra los reportes cuya
      pantalla de origen ya tiene ese rol (Listado de alumnos, Listado de cuentas por cobrar,
      Reportes financieros); el resto no aparece ni se puede ejecutar.
   2. Boletín: PR_Boletin_Notas devuelve también el semestre (Sem_Id, Sem_Descripcion) y el nombre
      del parcial (Par_Nombre), para mostrar semestre x parcial sin juntar las notas.
   3. Cinco procedimientos dejan de usar IDENT_CURRENT:
        - PR_tbEmpleados_Insert toma el Id de la persona que devuelve PR_tbPersonas_Insert.
        - PR_tbCursos_tb{CursosNiveles,Materias,Modalidades,Secciones}_Insert reciben un
          @Cur_Id opcional (y, si no viene, el nombre y nivel del curso); sin ninguno usan el curso
          más reciente (como antes). Ya no dependen del contador de identidad.
   4. Dashboard docente: app.PR_DashboardDocente_Hoy leía app.tbHorario (singular, vacía); ahora lee
      app.tbHorarios, que es la que tiene las clases. Mismas columnas y mismos parámetros.
   Idempotente.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ─────────────── 1 · Permiso del Centro de reportes para Consulta ─────────────── */
INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT 1007, p.Pan_Id
FROM seguridad.tbPantallas p
WHERE p.Pan_Descripcion = N'Centro de reportes'
  AND EXISTS (SELECT 1 FROM seguridad.tbRoles r WHERE r.Rol_Id = 1007)
  AND NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas y WHERE y.Rol_Id = 1007 AND y.Pan_Id = p.Pan_Id);
GO

/* ─────────────── 2 · Boletín por semestre y parcial ─────────────── */
CREATE OR ALTER PROCEDURE app.PR_Boletin_Notas
    @Alu_Id int,
    @Anio   int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.Alu_Id,
        LTRIM(RTRIM(CONCAT_WS(' ',
            NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)),  ''),
            NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), ''),
            NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), ''),
            NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), '')))) AS Alu_NombreCompleto,
        LTRIM(RTRIM(REPLACE(REPLACE(c.Cur_Nombre, CHAR(13), ''), CHAR(10), ''))) AS Cur_Nombre,
        s.Sec_Descripcion            AS Sec_Nombre,
        n.Mat_Id,
        m.Mat_Nombre,
        n.Pac_Id                     AS Par_Id,
        pac.Pac_Descripcion          AS Par_Descripcion,
        CAST(n.Not_Nota AS decimal(5,2)) AS Not_Nota,
        YEAR(n.[Not_Año])            AS Anio,
        n.Sem_Id,
        app.FN_CierresParcial_NombreSemestre(n.Sem_Id) AS Sem_Descripcion,
        app.FN_CierresParcial_NombreParcial(n.Pac_Id)  AS Par_Nombre
    FROM app.tbNotas n
    INNER JOIN app.tbMaterias  m   ON m.Mat_Id = n.Mat_Id
    INNER JOIN app.tbParciales pac ON pac.Pac_Id = n.Pac_Id
    INNER JOIN app.tbAlumnos   a   ON a.Alu_Id = n.Alu_Id
    INNER JOIN app.tbPersonas  p   ON p.Per_Id = a.Per_Id
    LEFT  JOIN app.tbCursos    c   ON c.Cur_Id = a.Cur_Id
    LEFT  JOIN app.tbSecciones s   ON s.Sec_Id = a.Sec_Id
    WHERE n.Alu_Id          = @Alu_Id
      AND YEAR(n.[Not_Año])  = @Anio
      AND n.Not_EsActivo     = 1
      AND n.Not_EsEliminado  = 0
    ORDER BY m.Mat_Nombre, n.Sem_Id, n.Pac_Id;
END
GO

/* ─────────────── 3 · Sin IDENT_CURRENT ─────────────── */
-- Alta de empleado: mismo comportamiento; toma el Id de la persona recién creada.
CREATE OR ALTER PROCEDURE [dbo].[PR_tbEmpleados_Insert]
	@Emp_Codigo VARCHAR(50),
	@Tit_Id     INT,
	@Car_Id     INT,
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
		DECLARE @Nueva TABLE (Per_Id DECIMAL(38,0));
		INSERT INTO @Nueva (Per_Id)
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
		SELECT @Per_Id = CONVERT(INT, Per_Id) FROM @Nueva;

          INSERT INTO [app].[tbEmpleados] (Emp_Codigo, Per_Id, Tit_Id, Car_Id)
          VALUES (@Emp_Codigo, @Per_Id, @Tit_Id, @Car_Id)
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	END CATCH
  END
GO

-- Tablas puente del curso: se usa @Cur_Id; si no viene, el curso con ese nombre y nivel (el más reciente);
-- si tampoco, el curso más reciente que existe.
CREATE OR ALTER PROCEDURE [dbo].[PR_tbCursos_tbCursosNiveles_Insert]
	@Cun_Id int,
	@Cur_Id int = NULL,
	@Cur_Nombre nvarchar(50) = NULL,
	@Niv_Id int = NULL
AS
	BEGIN
		BEGIN TRAN
			BEGIN TRY
				SET @Cur_Id = ISNULL(@Cur_Id, (SELECT MAX(Cur_Id) FROM [app].[tbCursos] WHERE Cur_Nombre = @Cur_Nombre AND Niv_Id = @Niv_Id));
				SET @Cur_Id = ISNULL(@Cur_Id, (SELECT MAX(Cur_Id) FROM [app].[tbCursos]));
				INSERT INTO [app].[tbCursos_tbCursosNiveles] (Cur_Id, Cun_Id) VALUES (@Cur_Id, @Cun_Id)
				COMMIT TRAN
			END TRY
			BEGIN CATCH
				SELECT ERROR_MESSAGE();
				IF @@TRANCOUNT > 0 ROLLBACK TRAN
			END CATCH
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[PR_tbCursos_tbMaterias_Insert]
	@Mat_Id int,
	@Cur_Id int = NULL,
	@Cur_Nombre nvarchar(50) = NULL,
	@Niv_Id int = NULL
AS
	BEGIN
		BEGIN TRAN
			BEGIN TRY
				SET @Cur_Id = ISNULL(@Cur_Id, (SELECT MAX(Cur_Id) FROM [app].[tbCursos] WHERE Cur_Nombre = @Cur_Nombre AND Niv_Id = @Niv_Id));
				SET @Cur_Id = ISNULL(@Cur_Id, (SELECT MAX(Cur_Id) FROM [app].[tbCursos]));
				INSERT INTO [app].[tbCursos_tbMaterias] (Cur_Id, Mat_Id) VALUES (@Cur_Id, @Mat_Id)
				COMMIT TRAN
			END TRY
			BEGIN CATCH
				SELECT ERROR_MESSAGE();
				IF @@TRANCOUNT > 0 ROLLBACK TRAN
			END CATCH
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[PR_tbCursos_tbModalidades_Insert]
	@Mda_Id int,
	@Cur_Id int = NULL,
	@Cur_Nombre nvarchar(50) = NULL,
	@Niv_Id int = NULL
AS
	BEGIN
		BEGIN TRAN
			BEGIN TRY
				SET @Cur_Id = ISNULL(@Cur_Id, (SELECT MAX(Cur_Id) FROM [app].[tbCursos] WHERE Cur_Nombre = @Cur_Nombre AND Niv_Id = @Niv_Id));
				SET @Cur_Id = ISNULL(@Cur_Id, (SELECT MAX(Cur_Id) FROM [app].[tbCursos]));
				INSERT INTO [app].[tbCursos_tbModalidades] (Cur_Id, Mda_Id) VALUES (@Cur_Id, @Mda_Id)
				COMMIT TRAN
			END TRY
			BEGIN CATCH
				SELECT ERROR_MESSAGE();
				IF @@TRANCOUNT > 0 ROLLBACK TRAN
			END CATCH
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[PR_tbCursos_tbSecciones_Insert]
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
				INSERT INTO [app].[tbCursos_tbSecciones] (Cur_Id, Sec_Id) VALUES (@Cur_Id, @Sec_Id)
				COMMIT TRAN
			END TRY
			BEGIN CATCH
				SELECT ERROR_MESSAGE();
				IF @@TRANCOUNT > 0 ROLLBACK TRAN
			END CATCH
	END
GO

/* ─────────────── 4 · Dashboard docente: clases desde tbHorarios ─────────────── */
CREATE OR ALTER PROCEDURE [app].[PR_DashboardDocente_Hoy]
    @Emp_Id INT,
    @Dia_Id INT,
    @Anio   INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());

    -- Clases del dia con indicador de asistencia registrada
    SELECT
        h.Hor_Id,
        m.Mat_Nombre,
        a.Aul_Descripcion,
        s.Sec_Descripcion,
        c.Cur_Nombre,
        cn.Cun_Descripcion,
        hi.Hor_Hora AS HoraInicio,
        hf.Hor_Hora AS HoraFin,
        (SELECT COUNT(*) FROM [app].[tbAsistencia] ast
         WHERE ast.Hor_Id = h.Hor_Id
           AND ast.Asi_Fecha = CAST(GETDATE() AS DATE)
           AND ast.Asi_EsEliminado = 0) AS AsistenciaRegistrada
    FROM [app].[tbHorarios] h
    INNER JOIN [app].[tbMaterias]      m  ON h.Mat_Id = m.Mat_Id
    INNER JOIN [app].[tbAulas]         a  ON h.Aul_Id = a.Aul_Id
    INNER JOIN [app].[tbSecciones]     s  ON h.Sec_Id = s.Sec_Id
    INNER JOIN [app].[tbCursos]        c  ON h.Cur_Id = c.Cur_Id
    INNER JOIN [app].[tbCursosNiveles] cn ON h.Cun_Id = cn.Cun_Id
    INNER JOIN [app].[tbHoras]         hi ON h.Hor_HoraInicio   = hi.Hor_Id
    INNER JOIN [app].[tbHoras]         hf ON h.Hor_HoraFinaliza = hf.Hor_Id
    WHERE h.Emp_Id = @Emp_Id
      AND h.Dia_Id = @Dia_Id
      AND h.Hor_Año = @Anio
      AND h.Hor_EsEliminado = 0
    ORDER BY hi.Hor_Hora;

    -- KPIs del docente
    SELECT
        (SELECT COUNT(DISTINCT alm.Alu_Id)
         FROM [app].[tbHorarios] h2
         INNER JOIN [app].[tbAlumnos] alm ON h2.Cur_Id = alm.Cur_Id AND h2.Sec_Id = alm.Sec_Id
         WHERE h2.Emp_Id = @Emp_Id AND h2.Hor_Año = @Anio AND h2.Hor_EsEliminado = 0) AS TotalAlumnos,
        (SELECT COUNT(DISTINCT h3.Mat_Id)
         FROM [app].[tbHorarios] h3
         WHERE h3.Emp_Id = @Emp_Id AND h3.Hor_Año = @Anio AND h3.Hor_EsEliminado = 0) AS TotalMaterias;
END
GO
