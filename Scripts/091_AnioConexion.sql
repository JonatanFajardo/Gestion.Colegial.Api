/* =============================================================================
   091 · Conexión con el Año Lectivo
   1. Cupo de las secciones del año editable (PR_tbSeccionesAnio_Cupos / _ActualizarCupo)
      y permiso "Editar cupos del año" (admin, dirección, secretaría).
   2. Semestres y fechas desde los períodos del año (tbPeriodosAnio, tipo 'semestre'; el
      primero por orden es el semestre 1 y el segundo el 2):
        FN_SemestresAnio · FN_SemestreDeFecha · FN_Temario_InicioEfectivo · fn_SemestreActivo ·
        FN_Sustitucion_Ciclo · Temario (semana esperada e inicio de clases) · Cierre de parciales.
      Si el año no tiene períodos de tipo semestre, todo sigue como antes.
   3. Ubicación histórica: Cierre de parciales (FN_CierresParcial_Alumnos) y PR_Boletin_Notas
      usan la sección que el alumno tuvo en tbMatriculaAnio de ESE año cuando el año no es el
      activo (si no hay matrícula de ese año, la ubicación actual). Las constancias (064) ya
      leían tbMatriculaAnio y no cambian.
   4. Matrícula para el año siguiente: PR_AnioConexion_AniosInscripcion / _VerificarCupo /
      _InscribirAlumno (valida cupo y que el año admita inscripciones) y
      PR_tbAnioLectivo_AplicarUbicacion (al abrir el año como activo, la ubicación actual de
      los inscritos pasa a la sección de ese año; antes de eso no se toca).
   Idempotente. Cambia (misma firma): fn_SemestreActivo, FN_Sustitucion_Ciclo,
   FN_Temario_AvanceGrupos, FN_Temarios_Detalle, PR_tbTemarioTemas_List, PR_tbTemarioAvance_Marcar,
   PR_tbTemarios_Crear / _Editar / _Copiar, FN_CierresParcial_Alumnos, PR_CierresParcial_Estado
   (tres columnas nuevas al final de la fila), PR_Boletin_Notas.
   ============================================================================= */
USE DB_GestionColegial;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/* ───────── Permiso ───────── */
INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
SELECT N'Editar cupos del año', 1, 0, 'Academico'
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas WHERE Pan_Descripcion = N'Editar cupos del año');

INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0 AND r.Rol_Id IN (1, 1002, 1003)
WHERE p.Pan_Descripcion = N'Editar cupos del año'
  AND NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas y WHERE y.Rol_Id = r.Rol_Id AND y.Pan_Id = p.Pan_Id);
GO

/* ───────── Año activo y semestres desde los períodos ───────── */
CREATE OR ALTER FUNCTION app.FN_AnioActivoAnio ()
RETURNS int
AS
BEGIN
    RETURN (SELECT a.Ani_Anio FROM app.tbAnioLectivo a
            WHERE a.Ani_Id = TRY_CAST((SELECT TOP (1) Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = 'anio_lectivo_activo_id') AS int));
END
GO

-- Semestres del año (1 y 2) según sus períodos de tipo 'semestre' con fecha de inicio.
CREATE OR ALTER FUNCTION app.FN_SemestresAnio (@Anio int)
RETURNS TABLE
AS
RETURN
    SELECT x.Sem_Id, x.Nombre, x.Inicio, x.Fin
    FROM (
        SELECT CAST(ROW_NUMBER() OVER (ORDER BY p.Pan_Orden, p.Pan_Id) AS int) AS Sem_Id,
               p.Pan_Nombre AS Nombre, p.Pan_FechaInicio AS Inicio, p.Pan_FechaFin AS Fin
        FROM app.tbPeriodosAnio p
        JOIN app.tbAnioLectivo a ON a.Ani_Id = p.Ani_Id AND a.Ani_EsEliminado = 0 AND a.Ani_Anio = @Anio
        WHERE p.Pan_EsEliminado = 0 AND p.Pan_EsActivo = 1 AND p.Pan_Tipo = 'semestre' AND p.Pan_FechaInicio IS NOT NULL
    ) x
    WHERE x.Sem_Id <= 2;
GO

-- Semestre (1 o 2) que rige en una fecha según los períodos del año; NULL si el año no los tiene.
-- Entre dos semestres (vacaciones) rige el último que ya empezó; antes del primero, el primero.
CREATE OR ALTER FUNCTION app.FN_SemestreDeFecha (@Anio int, @Fecha date)
RETURNS int
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM app.FN_SemestresAnio(@Anio)) RETURN NULL;
    DECLARE @s int = (SELECT TOP (1) Sem_Id FROM app.FN_SemestresAnio(@Anio) WHERE Inicio <= @Fecha ORDER BY Inicio DESC);
    RETURN ISNULL(@s, (SELECT TOP (1) Sem_Id FROM app.FN_SemestresAnio(@Anio) ORDER BY Inicio));
END
GO

-- Inicio de clases de un semestre: el del período del año; si no hay, el respaldo (la fecha guardada).
CREATE OR ALTER FUNCTION app.FN_Temario_InicioEfectivo (@Anio int, @Sem_Id int, @Respaldo date)
RETURNS date
AS
BEGIN
    RETURN ISNULL((SELECT Inicio FROM app.FN_SemestresAnio(@Anio) WHERE Sem_Id = @Sem_Id), @Respaldo);
END
GO

-- Semestre vigente (1 o 2): el fijado en la configuración; si es 0, el de los períodos del año
-- (si los tiene); si no, el que cubre la fecha según 'semestre2_inicio'.
CREATE OR ALTER FUNCTION app.fn_SemestreActivo (@Fecha date = NULL)
RETURNS int
AS
BEGIN
    DECLARE @f date = ISNULL(@Fecha, CAST(GETDATE() AS date));
    DECLARE @fijo int = TRY_CAST((SELECT Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = 'semestre_activo') AS int);
    IF @fijo IN (1, 2) RETURN @fijo;
    DECLARE @anio int = ISNULL((SELECT TOP (1) al.Ani_Anio FROM app.FN_AnioLectivoDeFecha(@f) x
                                JOIN app.tbAnioLectivo al ON al.Ani_Id = x.Ani_Id), YEAR(@f));
    DECLARE @p int = app.FN_SemestreDeFecha(@anio, @f);
    IF @p IS NOT NULL RETURN @p;
    DECLARE @i2 date = TRY_CAST((SELECT Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = 'semestre2_inicio') AS date);
    IF @i2 IS NULL RETURN CASE WHEN MONTH(@f) <= 6 THEN 1 ELSE 2 END;
    RETURN CASE WHEN @f >= @i2 THEN 2 ELSE 1 END;
END
GO


/* ───────── 2 · Sustituciones: el semestre sale de los períodos del año ───────── */
CREATE OR ALTER FUNCTION app.FN_Sustitucion_Ciclo (@Fecha date)
RETURNS TABLE
AS
RETURN
    SELECT DATEDIFF(DAY, '19000101', @Fecha) % 7 + 1 AS Dia_Id,   -- 1900-01-01 fue lunes
           a.Anio, s.Sem_Id
    FROM (SELECT ISNULL((SELECT TOP (1) al.Ani_Anio
                         FROM app.FN_AnioLectivoDeFecha(@Fecha) f
                         JOIN app.tbAnioLectivo al ON al.Ani_Id = f.Ani_Id), YEAR(@Fecha)) AS Anio) a
    OUTER APPLY (
        SELECT TOP (1) x.Sem_Id
        FROM (
            SELECT TRY_CAST(c.Con_Valor AS int) AS Sem_Id, 0 AS Prioridad
            FROM app.tbConfiguracion c
            WHERE c.Con_Clave = 'semestre_activo' AND TRY_CAST(c.Con_Valor AS int) IN (1, 2)
            UNION ALL
            SELECT h.Sem_Id, CASE WHEN h.Sem_Id = ISNULL(app.FN_SemestreDeFecha(a.Anio, @Fecha), CASE WHEN MONTH(@Fecha) <= 6 THEN 1 ELSE 2 END) THEN 1 ELSE 2 END
            FROM app.tbHorarios h
            WHERE h.Hor_EsEliminado = 0 AND h.Hor_Año = a.Anio
            GROUP BY h.Sem_Id
        ) x
        WHERE x.Sem_Id IS NOT NULL
        ORDER BY x.Prioridad, x.Sem_Id DESC
    ) s;
GO

/* ───────── 2 · Temario: inicio de clases desde el período del semestre ───────── */

CREATE OR ALTER FUNCTION app.FN_Temario_AvanceGrupos (@Tem_Id int, @Hoy date)
RETURNS TABLE
AS
RETURN
    WITH temas AS (
        SELECT Tet_Id, Tet_Semana FROM app.tbTemarioTemas WHERE Tem_Id = @Tem_Id AND Tet_EsEliminado = 0
    ),
    sem AS (
        SELECT app.FN_Temario_Semana(app.FN_Temario_InicioEfectivo(Tem_Anio, Sem_Id, Tem_FechaInicio), @Hoy) AS Semana FROM app.tbTemarios WHERE Tem_Id = @Tem_Id
    )
    SELECT g.Cur_Id, g.Sec_Id, g.Mda_Id,
           (SELECT COUNT(*) FROM temas) AS Total,
           ISNULL(a.Dados, 0) AS Dados, ISNULL(a.Parciales, 0) AS Parciales, ISNULL(a.Omitidos, 0) AS Omitidos,
           ISNULL(e.Esperados, 0) AS Esperados, ISNULL(e.Esperados, 0) - ISNULL(z.Saldados, 0) AS Atrasados,
           sem.Semana AS SemanaActual
    FROM app.FN_Temario_Grupos(@Tem_Id) g
    CROSS JOIN sem
    OUTER APPLY (SELECT SUM(CASE WHEN av.Tav_Estado = 'dado' THEN 1 ELSE 0 END) AS Dados,
                        SUM(CASE WHEN av.Tav_Estado = 'parcial' THEN 1 ELSE 0 END) AS Parciales,
                        SUM(CASE WHEN av.Tav_Estado = 'omitido' THEN 1 ELSE 0 END) AS Omitidos
                 FROM app.tbTemarioAvance av
                 JOIN temas t ON t.Tet_Id = av.Tet_Id
                 WHERE av.Cur_Id = g.Cur_Id AND av.Sec_Id = g.Sec_Id AND av.Mda_Id = g.Mda_Id) a
    -- Esperados = temas de semanas anteriores a la actual; saldados = de esos, los dados u omitidos.
    OUTER APPLY (SELECT COUNT(*) AS Esperados
                 FROM temas t
                 WHERE sem.Semana IS NOT NULL AND t.Tet_Semana < sem.Semana) e
    OUTER APPLY (SELECT COUNT(*) AS Saldados
                 FROM temas t
                 JOIN app.tbTemarioAvance av
                   ON av.Tet_Id = t.Tet_Id AND av.Cur_Id = g.Cur_Id AND av.Sec_Id = g.Sec_Id AND av.Mda_Id = g.Mda_Id
                  AND av.Tav_Estado IN ('dado', 'omitido')
                 WHERE sem.Semana IS NOT NULL AND t.Tet_Semana < sem.Semana) z;
GO

CREATE OR ALTER FUNCTION app.FN_Temarios_Detalle (@Usu_Id int, @Hoy date)
RETURNS TABLE
AS
RETURN
    SELECT t.Tem_Id, t.Mat_Id, app.FN_Temario_Texto(m.Mat_Nombre) AS Materia,
           cn.Niv_Id, app.FN_Temario_Texto(n.Niv_Descripcion) AS Nivel,
           t.Cun_Id, app.FN_Temario_Texto(cn.Cun_Descripcion) AS Grado, ISNULL(cn.Cun_Orden, cn.Cun_Id) AS Cun_Orden,
           t.Cur_Id, app.FN_Temario_Texto(c.Cur_Nombre) AS Curso,
           t.Sem_Id, CONCAT(app.FN_Temario_Texto(s.Sem_Descripcion), N' semestre') AS Semestre,
           t.Tem_Anio, t.Tem_Nombre, t.Tem_Descripcion, app.FN_Temario_InicioEfectivo(t.Tem_Anio, t.Sem_Id, t.Tem_FechaInicio) AS Tem_FechaInicio,
           app.FN_Temario_Semana(app.FN_Temario_InicioEfectivo(t.Tem_Anio, t.Sem_Id, t.Tem_FechaInicio), @Hoy) AS SemanaActual,
           ISNULL(tc.Temas, 0) AS Temas, ISNULL(tc.Semanas, 0) AS Semanas,
           ISNULL(ag.Secciones, 0) AS Secciones, ISNULL(ag.AvancePct, 0) AS AvancePct,
           ISNULL(ag.Atrasadas, 0) AS SeccionesAtrasadas,
           v.EsMio, v.PuedeEditar, v.PuedeSupervisar,
           t.Tem_IdOrigen, o.Tem_Nombre AS Origen, o.Tem_Anio AS OrigenAnio,
           app.FN_Temario_NombreUsuario(t.Tem_UsuarioRegistra) AS Registra,
           t.Tem_FechaRegistra, t.Tem_FechaModifica
    FROM app.FN_Temarios_Visibles(@Usu_Id) v
    JOIN app.tbTemarios t ON t.Tem_Id = v.Tem_Id
    JOIN app.tbMaterias m ON m.Mat_Id = t.Mat_Id
    JOIN app.tbCursosNiveles cn ON cn.Cun_Id = t.Cun_Id
    LEFT JOIN app.tbNivelesEducativos n ON n.Niv_Id = cn.Niv_Id
    LEFT JOIN app.tbCursos c ON c.Cur_Id = t.Cur_Id
    LEFT JOIN app.tbSemestres s ON s.Sem_Id = t.Sem_Id
    LEFT JOIN app.tbTemarios o ON o.Tem_Id = t.Tem_IdOrigen
    OUTER APPLY (SELECT COUNT(*) AS Temas, MAX(x.Tet_Semana) AS Semanas
                 FROM app.tbTemarioTemas x WHERE x.Tem_Id = t.Tem_Id AND x.Tet_EsEliminado = 0) tc
    OUTER APPLY (SELECT COUNT(*) AS Secciones,
                        CAST(ROUND(AVG(CASE WHEN g.Total = 0 THEN 0.0 ELSE g.Dados * 100.0 / g.Total END), 0) AS int) AS AvancePct,
                        SUM(CASE WHEN g.Atrasados > 0 THEN 1 ELSE 0 END) AS Atrasadas
                 FROM app.FN_Temario_AvanceGrupos(t.Tem_Id, @Hoy) g) ag;
GO

CREATE OR ALTER PROCEDURE app.PR_tbTemarioTemas_List
    @Tem_Id int,
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    DECLARE @Semana int = (SELECT app.FN_Temario_Semana(app.FN_Temario_InicioEfectivo(Tem_Anio, Sem_Id, Tem_FechaInicio), @Hoy) FROM app.tbTemarios WHERE Tem_Id = @Tem_Id);

    SELECT x.Tet_Id, x.Tem_Id, x.Tet_Semana, x.Tet_Orden, x.Tet_Titulo, x.Tet_Objetivos, x.Tet_Contenido, x.Tet_Recursos,
           CAST(CASE WHEN @Semana IS NOT NULL AND x.Tet_Semana < @Semana THEN 1 ELSE 0 END AS bit) AS Esperado,
           (SELECT COUNT(*) FROM app.tbTemarioAvance av
            JOIN app.FN_Temario_Grupos(@Tem_Id) g ON g.Cur_Id = av.Cur_Id AND g.Sec_Id = av.Sec_Id AND g.Mda_Id = av.Mda_Id
            WHERE av.Tet_Id = x.Tet_Id AND av.Tav_Estado = 'dado') AS SeccionesDado,
           (SELECT COUNT(*) FROM app.tbTemarioAvance av WHERE av.Tet_Id = x.Tet_Id) AS Marcas
    FROM app.tbTemarioTemas x
    WHERE x.Tem_Id = @Tem_Id AND x.Tet_EsEliminado = 0
      AND EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usu_Id) v WHERE v.Tem_Id = @Tem_Id)
    ORDER BY x.Tet_Semana, x.Tet_Orden, x.Tet_Id;
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbTemarioAvance_Marcar
    @Tet_Id     int,
    @Cur_Id     int,
    @Sec_Id     int,
    @Mda_Id     int,
    @Tav_Estado varchar(10),
    @Tav_Fecha  date = NULL,
    @Tav_Nota   nvarchar(max) = NULL,
    @Usuario    int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Tav_Nota = NULLIF(LTRIM(RTRIM(@Tav_Nota)), N'');
    DECLARE @Ahora datetime2(0) = app.FN_AhoraHonduras(), @Tem_Id int, @Inicio date, @Anio int, @Tav_Id int;
    SELECT @Tem_Id = t.Tem_Id, @Inicio = app.FN_Temario_InicioEfectivo(t.Tem_Anio, t.Sem_Id, t.Tem_FechaInicio), @Anio = t.Tem_Anio
    FROM app.tbTemarioTemas x JOIN app.tbTemarios t ON t.Tem_Id = x.Tem_Id AND t.Tem_EsEliminado = 0
    WHERE x.Tet_Id = @Tet_Id AND x.Tet_EsEliminado = 0;

    IF @Tem_Id IS NULL OR NOT EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usuario) WHERE Tem_Id = @Tem_Id)
        THROW 50061, N'Ese tema ya no existe o no tiene acceso a su temario.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.FN_Temario_Grupos(@Tem_Id) WHERE Cur_Id = @Cur_Id AND Sec_Id = @Sec_Id AND Mda_Id = @Mda_Id)
        THROW 50062, N'Esa sección no lleva esta materia en el horario del año.', 1;
    IF app.FN_Temario_PuedeMarcar(@Usuario, @Tem_Id, @Cur_Id, @Sec_Id, @Mda_Id) = 0
        THROW 50063, N'Solo puede marcar el avance de las secciones a las que da esta materia.', 1;
    IF @Tav_Estado IS NULL OR @Tav_Estado NOT IN ('dado', 'parcial', 'omitido')
        THROW 50064, N'Elija si el tema se dio, se dio en parte o se omitió.', 1;
    IF @Tav_Estado = 'omitido'
        SET @Tav_Fecha = NULL;
    ELSE
    BEGIN
        IF @Tav_Fecha IS NULL
            THROW 50065, N'Indique la fecha en que se dio el tema.', 1;
        IF @Tav_Fecha > CAST(@Ahora AS date)
            THROW 50065, N'La fecha no puede ser futura.', 1;
        IF @Tav_Fecha < @Inicio
            THROW 50065, N'La fecha no puede ser antes del inicio de clases del temario.', 1;
        IF YEAR(@Tav_Fecha) <> @Anio
            THROW 50065, N'La fecha debe ser del año del temario.', 1;
    END
    IF LEN(@Tav_Nota) > 1000
        THROW 50066, N'La nota de clase admite hasta 1000 caracteres.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        SELECT @Tav_Id = Tav_Id FROM app.tbTemarioAvance WITH (UPDLOCK, HOLDLOCK)
        WHERE Tet_Id = @Tet_Id AND Cur_Id = @Cur_Id AND Sec_Id = @Sec_Id AND Mda_Id = @Mda_Id;

        IF @Tav_Id IS NULL
        BEGIN
            INSERT INTO app.tbTemarioAvance (Tet_Id, Cur_Id, Sec_Id, Mda_Id, Tav_Estado, Tav_Fecha, Tav_Nota, Tav_UsuarioRegistra, Tav_FechaRegistra)
            VALUES (@Tet_Id, @Cur_Id, @Sec_Id, @Mda_Id, @Tav_Estado, @Tav_Fecha, @Tav_Nota, @Usuario, @Ahora);
            SET @Tav_Id = CAST(SCOPE_IDENTITY() AS int);
        END
        ELSE
            UPDATE app.tbTemarioAvance
            SET Tav_Estado = @Tav_Estado, Tav_Fecha = @Tav_Fecha, Tav_Nota = @Tav_Nota,
                Tav_UsuarioModifica = @Usuario, Tav_FechaModifica = @Ahora
            WHERE Tav_Id = @Tav_Id;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Tav_Id AS Id, @Tem_Id AS Tem_Id, 1 AS Cantidad;
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbTemarios_Crear
    @Mat_Id          int,
    @Cun_Id          int,
    @Cur_Id          int = NULL,
    @Sem_Id          int,
    @Tem_Anio        int,
    @Tem_Nombre      nvarchar(150),
    @Tem_Descripcion nvarchar(max) = NULL,
    @Tem_FechaInicio date,
    @Usuario         int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Tem_Nombre = LTRIM(RTRIM(ISNULL(@Tem_Nombre, N'')));
    SET @Tem_FechaInicio = app.FN_Temario_InicioEfectivo(@Tem_Anio, @Sem_Id, @Tem_FechaInicio);
    SET @Tem_Descripcion = NULLIF(LTRIM(RTRIM(@Tem_Descripcion)), N'');
    DECLARE @Ahora datetime2(0) = app.FN_AhoraHonduras(), @Tem_Id int;

    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC app.PR_tbTemarios_Validar @Mat_Id, @Cun_Id, @Cur_Id, @Sem_Id, @Tem_Anio, @Tem_Nombre, @Tem_Descripcion, @Tem_FechaInicio, @Usuario;

        INSERT INTO app.tbTemarios (Mat_Id, Cun_Id, Cur_Id, Sem_Id, Tem_Anio, Tem_Nombre, Tem_Descripcion, Tem_FechaInicio,
                                    Tem_UsuarioRegistra, Tem_FechaRegistra)
        VALUES (@Mat_Id, @Cun_Id, @Cur_Id, @Sem_Id, @Tem_Anio, @Tem_Nombre, @Tem_Descripcion, @Tem_FechaInicio, @Usuario, @Ahora);
        SET @Tem_Id = CAST(SCOPE_IDENTITY() AS int);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Tem_Id AS Id, @Tem_Id AS Tem_Id, 0 AS Cantidad;
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbTemarios_Editar
    @Tem_Id          int,
    @Tem_Nombre      nvarchar(150),
    @Tem_Descripcion nvarchar(max) = NULL,
    @Tem_FechaInicio date,
    @Usuario         int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Tem_Nombre = LTRIM(RTRIM(ISNULL(@Tem_Nombre, N'')));
    SET @Tem_Descripcion = NULLIF(LTRIM(RTRIM(@Tem_Descripcion)), N'');
    SELECT @Tem_FechaInicio = app.FN_Temario_InicioEfectivo(Tem_Anio, Sem_Id, @Tem_FechaInicio) FROM app.tbTemarios WHERE Tem_Id = @Tem_Id;

    IF NOT EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usuario) WHERE Tem_Id = @Tem_Id AND PuedeEditar = 1)
        THROW 50051, N'No puede editar este temario: solo los de las materias que imparte.', 1;
    IF @Tem_Nombre = N''
        THROW 50046, N'Escriba el nombre del temario.', 1;
    IF LEN(@Tem_Nombre) > 150
        THROW 50046, N'El nombre admite hasta 150 caracteres.', 1;
    IF LEN(@Tem_Descripcion) > 2000
        THROW 50047, N'La descripción admite hasta 2000 caracteres.', 1;
    IF @Tem_FechaInicio IS NULL
        THROW 50048, N'Indique cuándo empiezan las clases del semestre.', 1;
    IF YEAR(@Tem_FechaInicio) <> (SELECT Tem_Anio FROM app.tbTemarios WHERE Tem_Id = @Tem_Id)
        THROW 50048, N'El inicio de clases debe ser una fecha del mismo año del temario.', 1;

    UPDATE app.tbTemarios
    SET Tem_Nombre = @Tem_Nombre, Tem_Descripcion = @Tem_Descripcion, Tem_FechaInicio = @Tem_FechaInicio,
        Tem_UsuarioModifica = @Usuario, Tem_FechaModifica = app.FN_AhoraHonduras()
    WHERE Tem_Id = @Tem_Id AND Tem_EsEliminado = 0;

    SELECT @Tem_Id AS Id, @Tem_Id AS Tem_Id, 0 AS Cantidad;
END
GO

CREATE OR ALTER PROCEDURE app.PR_tbTemarios_Copiar
    @Tem_IdOrigen    int,
    @Tem_IdDestino   int = NULL,
    @Sem_Id          int = NULL,
    @Tem_Anio        int = NULL,
    @Tem_Nombre      nvarchar(150) = NULL,
    @Tem_FechaInicio date = NULL,
    @Usuario         int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Tem_Nombre = LTRIM(RTRIM(ISNULL(@Tem_Nombre, N'')));
    IF @Tem_IdDestino IS NULL SET @Tem_FechaInicio = app.FN_Temario_InicioEfectivo(@Tem_Anio, @Sem_Id, @Tem_FechaInicio);
    DECLARE @Ahora datetime2(0) = app.FN_AhoraHonduras(), @Copiados int = 0, @Base int = 0;
    DECLARE @Mat_Id int, @Cun_Id int, @Cur_Id int, @Descripcion nvarchar(2000);

    IF NOT EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usuario) WHERE Tem_Id = @Tem_IdOrigen)
        THROW 50052, N'No encontramos el temario que quiere copiar.', 1;
    SELECT @Mat_Id = Mat_Id, @Cun_Id = Cun_Id, @Cur_Id = Cur_Id, @Descripcion = Tem_Descripcion
    FROM app.tbTemarios WHERE Tem_Id = @Tem_IdOrigen;
    IF NOT EXISTS (SELECT 1 FROM app.tbTemarioTemas WHERE Tem_Id = @Tem_IdOrigen AND Tet_EsEliminado = 0)
        THROW 50053, N'El temario de origen todavía no tiene temas para copiar.', 1;

    IF @Tem_IdDestino IS NOT NULL
    BEGIN
        IF @Tem_IdDestino = @Tem_IdOrigen
            THROW 50054, N'Elija un temario distinto para traer los temas.', 1;
        IF NOT EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usuario) WHERE Tem_Id = @Tem_IdDestino AND PuedeEditar = 1)
            THROW 50051, N'No puede editar este temario: solo los de las materias que imparte.', 1;
        IF NOT EXISTS (SELECT 1 FROM app.tbTemarios WHERE Tem_Id = @Tem_IdDestino AND Mat_Id = @Mat_Id)
            THROW 50054, N'Solo se pueden traer temas de un temario de la misma materia.', 1;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Tem_IdDestino IS NULL
        BEGIN
            IF @Tem_Nombre = N''
                SELECT @Tem_Nombre = LEFT(CONCAT(app.FN_Temario_Texto(m.Mat_Nombre), N' · ', app.FN_Temario_Texto(cn.Cun_Descripcion), N' · ',
                                                 app.FN_Temario_Texto(s.Sem_Descripcion), N' semestre ', @Tem_Anio), 150)
                FROM app.tbMaterias m, app.tbCursosNiveles cn, app.tbSemestres s
                WHERE m.Mat_Id = @Mat_Id AND cn.Cun_Id = @Cun_Id AND s.Sem_Id = @Sem_Id;

            EXEC app.PR_tbTemarios_Validar @Mat_Id, @Cun_Id, @Cur_Id, @Sem_Id, @Tem_Anio, @Tem_Nombre, @Descripcion, @Tem_FechaInicio, @Usuario;

            INSERT INTO app.tbTemarios (Mat_Id, Cun_Id, Cur_Id, Sem_Id, Tem_Anio, Tem_Nombre, Tem_Descripcion, Tem_FechaInicio,
                                        Tem_IdOrigen, Tem_UsuarioRegistra, Tem_FechaRegistra)
            VALUES (@Mat_Id, @Cun_Id, @Cur_Id, @Sem_Id, @Tem_Anio, @Tem_Nombre, @Descripcion, @Tem_FechaInicio,
                    @Tem_IdOrigen, @Usuario, @Ahora);
            SET @Tem_IdDestino = CAST(SCOPE_IDENTITY() AS int);
        END
        ELSE
            SELECT @Base = ISNULL(MAX(Tet_Orden), 0) FROM app.tbTemarioTemas WITH (UPDLOCK, HOLDLOCK) WHERE Tem_Id = @Tem_IdDestino;

        IF (SELECT COUNT(*) FROM app.tbTemarioTemas WHERE Tem_Id = @Tem_IdDestino AND Tet_EsEliminado = 0)
           + (SELECT COUNT(*) FROM app.tbTemarioTemas WHERE Tem_Id = @Tem_IdOrigen AND Tet_EsEliminado = 0) > 300
            THROW 50055, N'Un temario admite hasta 300 temas.', 1;

        INSERT INTO app.tbTemarioTemas (Tem_Id, Tet_Semana, Tet_Orden, Tet_Titulo, Tet_Objetivos, Tet_Contenido, Tet_Recursos,
                                        Tet_IdOrigen, Tet_UsuarioRegistra, Tet_FechaRegistra)
        SELECT @Tem_IdDestino, x.Tet_Semana, @Base + ROW_NUMBER() OVER (ORDER BY x.Tet_Semana, x.Tet_Orden, x.Tet_Id),
               x.Tet_Titulo, x.Tet_Objetivos, x.Tet_Contenido, x.Tet_Recursos, x.Tet_Id, @Usuario, @Ahora
        FROM app.tbTemarioTemas x
        WHERE x.Tem_Id = @Tem_IdOrigen AND x.Tet_EsEliminado = 0;
        SET @Copiados = @@ROWCOUNT;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Tem_IdDestino AS Id, @Tem_IdDestino AS Tem_Id, @Copiados AS Cantidad;
END
GO

/* ───────── 2 y 3 · Cierre de parciales: semestre vigente y ubicación histórica ───────── */

CREATE OR ALTER FUNCTION app.FN_CierresParcial_Alumnos (@Anio int)
RETURNS TABLE
AS
RETURN
    -- Año activo (o año sin matrículas): la ubicación actual del alumno.
    SELECT a.Alu_Id, a.Cur_Id, a.Cun_Id, a.Sec_Id, a.Mda_Id
    FROM app.tbAlumnos a
    INNER JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id
    CROSS JOIN (SELECT CAST(CASE WHEN @Anio <> ISNULL(app.FN_AnioActivoAnio(), @Anio)
                                  AND EXISTS (SELECT 1 FROM app.tbMatriculaAnio m JOIN app.tbAnioLectivo an ON an.Ani_Id = m.Ani_Id
                                              WHERE an.Ani_Anio = @Anio AND an.Ani_EsEliminado = 0 AND m.Mta_EsEliminado = 0)
                                 THEN 1 ELSE 0 END AS bit) AS Historico) f
    WHERE f.Historico = 0
      AND a.AnioCursado = @Anio
      AND ISNULL(a.Est_Id, 1) = 1
      AND ISNULL(p.Per_EsEliminado, 0) = 0
    UNION ALL
    -- Otro año con matrículas: la sección que el alumno tuvo ese año (sin retirados).
    SELECT a.Alu_Id, a.Cur_Id, sa.Cun_Id, sa.Sec_Id, ISNULL(sa.Mda_Id, a.Mda_Id)
    FROM app.tbMatriculaAnio m
    INNER JOIN app.tbAnioLectivo an ON an.Ani_Id = m.Ani_Id AND an.Ani_Anio = @Anio AND an.Ani_EsEliminado = 0
    INNER JOIN app.tbSeccionesAnio sa ON sa.Sea_Id = m.Sea_Id
    INNER JOIN app.tbAlumnos a ON a.Alu_Id = m.Alu_Id
    INNER JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id
    CROSS JOIN (SELECT CAST(CASE WHEN @Anio <> ISNULL(app.FN_AnioActivoAnio(), @Anio) THEN 1 ELSE 0 END AS bit) AS Historico) f
    WHERE f.Historico = 1
      AND m.Mta_EsEliminado = 0 AND m.Mta_Estado <> 4
      AND ISNULL(p.Per_EsEliminado, 0) = 0;
GO

CREATE OR ALTER PROCEDURE app.PR_CierresParcial_Estado
    @Anio int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Desde date = DATEFROMPARTS(@Anio, 1, 1), @Hasta date = DATEFROMPARTS(@Anio + 1, 1, 1);
    DECLARE @Hoy date = CAST(GETDATE() AS date);

    -- Secciones con alumnos activos y sin ningún horario en el año: no se puede saber qué notas esperar.
    DECLARE @SinHorarioSecciones int, @SinHorarioAlumnos int;
    SELECT @SinHorarioSecciones = COUNT(DISTINCT CONCAT(al.Cur_Id, '-', al.Cun_Id, '-', al.Sec_Id, '-', al.Mda_Id)),
           @SinHorarioAlumnos   = COUNT(*)
    FROM app.FN_CierresParcial_Alumnos(@Anio) al
    WHERE NOT EXISTS (SELECT 1 FROM app.tbHorarios h
                      WHERE h.Hor_Año = @Anio AND ISNULL(h.Hor_EsEliminado, 0) = 0
                        AND h.Cur_Id = al.Cur_Id AND h.Cun_Id = al.Cun_Id AND h.Sec_Id = al.Sec_Id AND h.Mda_Id = al.Mda_Id);

    SELECT @Anio AS Anio,
           s.Sem_Id, p.Pac_Id,
           app.FN_CierresParcial_NombreParcial(p.Pac_Id)  AS Parcial,
           app.FN_CierresParcial_NombreSemestre(s.Sem_Id) AS Semestre,
           CAST(ISNULL(c.Cpa_Estado, 'abierto') AS varchar(10)) AS Estado,
           CAST(ISNULL(c.Cpa_Publicado, 0) AS bit)        AS Publicado,
           c.Cpa_FechaInicio                              AS FechaInicio,
           c.Cpa_FechaLimite                              AS FechaLimite,
           sm.Inicio                                      AS SemestreInicio,
           sm.Fin                                         AS SemestreFin,
           CAST(CASE WHEN s.Sem_Id = ISNULL(app.FN_SemestreDeFecha(@Anio, @Hoy),
                                            CASE WHEN @Anio = YEAR(@Hoy) THEN app.fn_SemestreActivo(@Hoy) END) THEN 1 ELSE 0 END AS bit) AS SemestreVigente,
           CAST(CASE WHEN ISNULL(c.Cpa_Estado, 'abierto') = 'abierto' AND c.Cpa_FechaLimite < @Hoy THEN 1 ELSE 0 END AS bit) AS LimiteVencido,
           c.Cpa_FechaCierre                              AS FechaCierre,
           app.FN_CierresParcial_NombreUsuario(c.Usu_IdCierre)      AS UsuarioCierre,
           c.Cpa_FechaPublicacion                         AS FechaPublicacion,
           app.FN_CierresParcial_NombreUsuario(c.Usu_IdPublicacion) AS UsuarioPublicacion,
           ISNULL(a.Esperadas, 0)                         AS Esperadas,
           ISNULL(a.Cargadas, 0)                          AS Cargadas,
           ISNULL(a.Esperadas, 0) - ISNULL(a.Cargadas, 0) AS Faltantes,
           ISNULL(a.SeccionesConFaltantes, 0)             AS SeccionesConFaltantes,
           ISNULL(a.MateriasConFaltantes, 0)              AS MateriasConFaltantes,
           ISNULL(t.Notas, 0)                             AS NotasPeriodo,
           ISNULL(@SinHorarioSecciones, 0)                AS SeccionesSinHorario,
           ISNULL(@SinHorarioAlumnos, 0)                  AS AlumnosSinHorario
    FROM app.tbSemestres s
    CROSS JOIN app.tbParciales p
    LEFT JOIN app.tbCierresParcial c ON c.Cpa_Anio = @Anio AND c.Sem_Id = s.Sem_Id AND c.Pac_Id = p.Pac_Id
    OUTER APPLY (
        SELECT SUM(v.Alumnos)  AS Esperadas,
               SUM(v.Cargadas) AS Cargadas,
               COUNT(DISTINCT CASE WHEN v.Cargadas < v.Alumnos
                                   THEN CONCAT(v.Cur_Id, '-', v.Cun_Id, '-', v.Sec_Id, '-', v.Mda_Id) END) AS SeccionesConFaltantes,
               SUM(CASE WHEN v.Cargadas < v.Alumnos THEN 1 ELSE 0 END) AS MateriasConFaltantes
        FROM app.FN_CierresParcial_Avance(@Anio, s.Sem_Id, p.Pac_Id) v) a
    OUTER APPLY (SELECT COUNT(*) AS Notas FROM app.tbNotas n
                 WHERE n.Not_Año >= @Desde AND n.Not_Año < @Hasta AND n.Sem_Id = s.Sem_Id AND n.Pac_Id = p.Pac_Id
                   AND n.Not_EsEliminado = 0 AND n.Not_EsActivo = 1) t
    OUTER APPLY (SELECT x.Inicio, x.Fin FROM app.FN_SemestresAnio(@Anio) x WHERE x.Sem_Id = s.Sem_Id) sm
    WHERE ISNULL(s.Sem_EsEliminado, 0) = 0 AND ISNULL(p.Pac_EsEliminado, 0) = 0
    ORDER BY s.Sem_Id, p.Pac_Id;
END
GO

/* ───────── 3 · Boletín: sección del año pedido ───────── */

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
    OUTER APPLY (SELECT TOP (1) sa.Sec_Id FROM app.tbMatriculaAnio mt
                 INNER JOIN app.tbAnioLectivo an ON an.Ani_Id = mt.Ani_Id AND an.Ani_EsEliminado = 0 AND an.Ani_Anio = @Anio
                 INNER JOIN app.tbSeccionesAnio sa ON sa.Sea_Id = mt.Sea_Id
                 WHERE mt.Alu_Id = a.Alu_Id AND mt.Mta_EsEliminado = 0
                   AND @Anio <> ISNULL(app.FN_AnioActivoAnio(), @Anio)) h
    LEFT  JOIN app.tbSecciones s   ON s.Sec_Id = COALESCE(h.Sec_Id, a.Sec_Id)
    WHERE n.Alu_Id          = @Alu_Id
      AND YEAR(n.[Not_Año])  = @Anio
      AND n.Not_EsActivo     = 1
      AND n.Not_EsEliminado  = 0
    ORDER BY m.Mat_Nombre, n.Sem_Id, n.Pac_Id;
END
GO


/* ───────── 1 · Cupos de las secciones del año ───────── */
CREATE OR ALTER PROCEDURE app.PR_tbSeccionesAnio_Cupos
    @Ani_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT s.Sea_Id,
           s.Ani_Id,
           ISNULL(NULLIF(LTRIM(RTRIM(s.Sea_Nombre)), N''), LTRIM(RTRIM(CONCAT(c.Cun_Descripcion, N' ', sc.Sec_Descripcion)))) AS Sea_Nombre,
           ne.Niv_Descripcion, LTRIM(RTRIM(c.Cun_Descripcion)) AS Cun_Descripcion,
           LTRIM(RTRIM(sc.Sec_Descripcion)) AS Sec_Descripcion, md.Mda_Descripcion,
           s.Sea_Cupo,
           i.Inscritos,
           CASE WHEN s.Sea_Cupo IS NULL THEN NULL ELSE s.Sea_Cupo - i.Inscritos END AS Libres
    FROM app.tbSeccionesAnio s
    LEFT JOIN app.tbNivelesEducativos ne ON ne.Niv_Id = s.Niv_Id
    LEFT JOIN app.tbCursosNiveles c      ON c.Cun_Id  = s.Cun_Id
    LEFT JOIN app.tbSecciones sc         ON sc.Sec_Id = s.Sec_Id
    LEFT JOIN app.tbModalidades md       ON md.Mda_Id = s.Mda_Id
    OUTER APPLY (SELECT COUNT(*) AS Inscritos FROM app.tbMatriculaAnio m
                 WHERE m.Sea_Id = s.Sea_Id AND m.Mta_EsEliminado = 0 AND m.Mta_Estado = 1) i
    WHERE s.Ani_Id = @Ani_Id AND s.Sea_EsEliminado = 0
    ORDER BY s.Niv_Id, c.Cun_Orden, c.Cun_Descripcion, sc.Sec_Descripcion, md.Mda_Descripcion;
END
GO

-- Cambia solo el cupo. Reglas (errores 50091-50094 llegan tal cual al usuario).
CREATE OR ALTER PROCEDURE app.PR_tbSeccionesAnio_ActualizarCupo
    @Sea_Id int,
    @Sea_Cupo int,
    @Usuario int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Ani_Id int, @Estado tinyint, @Nombre nvarchar(120), @Inscritos int;

    BEGIN TRY
        BEGIN TRANSACTION;
        SELECT @Ani_Id = s.Ani_Id, @Nombre = ISNULL(s.Sea_Nombre, N'la sección')
        FROM app.tbSeccionesAnio s WITH (UPDLOCK, HOLDLOCK)
        WHERE s.Sea_Id = @Sea_Id AND s.Sea_EsEliminado = 0;
        IF @Ani_Id IS NULL
            THROW 50091, N'La sección ya no existe.', 1;
        SELECT @Estado = Ani_Estado FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id;
        IF @Estado IN (5, 6)
            THROW 50092, N'El año está cerrado: ya no se cambian los cupos de sus secciones.', 1;
        IF @Sea_Cupo IS NULL OR @Sea_Cupo < 1 OR @Sea_Cupo > 200
            THROW 50093, N'El cupo debe ser un número entre 1 y 200.', 1;
        SELECT @Inscritos = COUNT(*) FROM app.tbMatriculaAnio
        WHERE Sea_Id = @Sea_Id AND Mta_EsEliminado = 0 AND Mta_Estado = 1;
        IF @Sea_Cupo < @Inscritos
        BEGIN
            DECLARE @m nvarchar(300) = CONCAT(@Nombre, N' ya tiene ', @Inscritos, N' alumnos inscritos: el cupo no puede ser menor.');
            THROW 50094, @m, 1;
        END

        UPDATE app.tbSeccionesAnio
        SET Sea_Cupo = @Sea_Cupo, Sea_UsuarioModifica = @Usuario, Sea_FechaModifica = GETDATE()
        WHERE Sea_Id = @Sea_Id;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Sea_Id AS Sea_Id, @Sea_Cupo AS Sea_Cupo, @Inscritos AS Inscritos, @Sea_Cupo - @Inscritos AS Libres;
END
GO

/* ───────── 4 · Matrícula para el año siguiente ───────── */

-- Años donde se puede inscribir: el activo y los siguientes (Borrador, Programado o Abierto)
-- que ya tienen al menos una sección.
CREATE OR ALTER PROCEDURE app.PR_AnioConexion_AniosInscripcion
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Activo int = TRY_CAST((SELECT TOP (1) Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = 'anio_lectivo_activo_id') AS int);
    DECLARE @AnioActivo int = app.FN_AnioActivoAnio();

    SELECT a.Ani_Id, a.Ani_Anio, CAST(a.Ani_Nombre AS nvarchar(20)) AS Ani_Nombre, CAST(a.Ani_Estado AS int) AS Ani_Estado,
           CASE a.Ani_Estado WHEN 1 THEN N'Borrador' WHEN 2 THEN N'Programado' WHEN 3 THEN N'Abierto'
                             WHEN 4 THEN N'Cerrando' WHEN 5 THEN N'Cerrado' ELSE N'Archivado' END AS Ani_EstadoTexto,
           CAST(CASE WHEN a.Ani_Id = @Activo THEN 1 ELSE 0 END AS bit) AS EsActivo,
           s.Secciones, ISNULL(s.SeccionesConCupo, 0) AS SeccionesConCupo, s.Cupo, ISNULL(i.Inscritos, 0) AS Inscritos
    FROM app.tbAnioLectivo a
    OUTER APPLY (SELECT COUNT(*) AS Secciones,
                        SUM(CASE WHEN x.Sea_Cupo > 0 THEN 1 ELSE 0 END) AS SeccionesConCupo,
                        SUM(x.Sea_Cupo) AS Cupo
                 FROM app.tbSeccionesAnio x WHERE x.Ani_Id = a.Ani_Id AND x.Sea_EsEliminado = 0) s
    OUTER APPLY (SELECT COUNT(*) AS Inscritos FROM app.tbMatriculaAnio m
                 WHERE m.Ani_Id = a.Ani_Id AND m.Mta_EsEliminado = 0 AND m.Mta_Estado = 1) i
    WHERE a.Ani_EsEliminado = 0
      AND a.Ani_Estado BETWEEN 1 AND 3
      AND s.Secciones > 0
      AND (a.Ani_Id = @Activo OR a.Ani_Anio > ISNULL(@AnioActivo, 0))
    ORDER BY a.Ani_Anio;
END
GO

-- ¿Se puede inscribir en la sección que corresponde a esa ubicación, en ese año?
CREATE OR ALTER PROCEDURE app.PR_AnioConexion_VerificarCupo
    @Ani_Id int = NULL,
    @Niv_Id int,
    @Cun_Id int,
    @Mda_Id int = NULL,
    @Sec_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Activo int = TRY_CAST((SELECT TOP (1) Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = 'anio_lectivo_activo_id') AS int);
    IF @Ani_Id IS NULL SET @Ani_Id = @Activo;

    DECLARE @Nombre nvarchar(20), @Estado tinyint, @Sea_Id int, @SeaNombre nvarchar(120), @Cupo int, @Inscritos int = 0;
    SELECT @Nombre = CAST(Ani_Nombre AS nvarchar(20)), @Estado = Ani_Estado
    FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id AND Ani_EsEliminado = 0;

    SELECT TOP (1) @Sea_Id = s.Sea_Id, @SeaNombre = ISNULL(s.Sea_Nombre, N'la sección'), @Cupo = s.Sea_Cupo
    FROM app.tbSeccionesAnio s
    WHERE s.Ani_Id = @Ani_Id AND s.Sea_EsEliminado = 0 AND s.Sea_Estado IN (1, 2, 3)
      AND s.Niv_Id = @Niv_Id AND s.Cun_Id = @Cun_Id AND s.Sec_Id = @Sec_Id AND s.Sea_MdaKey = ISNULL(@Mda_Id, 0)
    ORDER BY s.Sea_Id;
    IF @Sea_Id IS NOT NULL
        SELECT @Inscritos = COUNT(*) FROM app.tbMatriculaAnio WHERE Sea_Id = @Sea_Id AND Mta_EsEliminado = 0 AND Mta_Estado = 1;

    DECLARE @Descripcion nvarchar(200) = (SELECT LTRIM(RTRIM(CONCAT(c.Cun_Descripcion, N' ', s.Sec_Descripcion)))
                                          FROM app.tbCursosNiveles c, app.tbSecciones s WHERE c.Cun_Id = @Cun_Id AND s.Sec_Id = @Sec_Id);
    DECLARE @Permitido bit = 0, @Mensaje nvarchar(300);

    IF @Nombre IS NULL
        SET @Mensaje = N'El año lectivo no existe.';
    ELSE IF @Estado NOT BETWEEN 1 AND 3
        SET @Mensaje = CONCAT(N'El año ', @Nombre, N' ya no admite inscripciones.');
    ELSE IF @Sea_Id IS NULL AND @Ani_Id = @Activo
        SELECT @Permitido = 1, @Mensaje = N'Esa sección todavía no existe en el año activo: se creará al inscribir.';
    ELSE IF @Sea_Id IS NULL
        SET @Mensaje = CONCAT(N'El año ', @Nombre, N' no tiene la sección ', @Descripcion, N'. Créela en Año Lectivo › Clases y profesores.');
    ELSE IF @Cupo IS NULL
        SELECT @Permitido = 1, @Mensaje = N'La sección no tiene cupo definido: se inscribe sin límite.';
    ELSE IF @Cupo - @Inscritos <= 0
        SET @Mensaje = CONCAT(@SeaNombre, N' ya no tiene cupo (', @Inscritos, N' de ', @Cupo, N'). Pida a Dirección ampliar el cupo o elija otra sección.');
    ELSE
        SELECT @Permitido = 1, @Mensaje = CONCAT(N'Cupo en ', @SeaNombre, N': ', @Cupo - @Inscritos, N' libres de ', @Cupo, N'.');

    SELECT @Ani_Id AS Ani_Id, @Nombre AS Ani_Nombre, CAST(CASE WHEN @Ani_Id = @Activo THEN 1 ELSE 0 END AS bit) AS EsActivo,
           @Sea_Id AS Sea_Id, @SeaNombre AS Sea_Nombre, @Cupo AS Cupo, @Inscritos AS Inscritos,
           CASE WHEN @Cupo IS NULL THEN NULL ELSE @Cupo - @Inscritos END AS Libres,
           @Permitido AS Permitido, @Mensaje AS Mensaje;
END
GO

-- Inscribe a un alumno ya creado en un año (por defecto el activo), en la sección de ese año que
-- corresponde a su ubicación. No cambia su ubicación actual (eso pasa al abrir el año):
-- solo un alumno nuevo, sin otra inscripción, queda con su año de cursado en el año elegido
-- para que no aparezca en las listas del año activo. Errores 50091-50095 llegan tal cual.
CREATE OR ALTER PROCEDURE app.PR_AnioConexion_InscribirAlumno
    @Alu_Id int,
    @Ani_Id int = NULL,
    @Usuario int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Activo int = TRY_CAST((SELECT TOP (1) Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = 'anio_lectivo_activo_id') AS int);
    DECLARE @AnioActivo int = app.FN_AnioActivoAnio();
    IF @Ani_Id IS NULL SET @Ani_Id = @Activo;

    DECLARE @anio int, @estado tinyint, @nombre nvarchar(20);
    SELECT @anio = Ani_Anio, @estado = Ani_Estado, @nombre = CAST(Ani_Nombre AS nvarchar(20))
    FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id AND Ani_EsEliminado = 0;
    IF @anio IS NULL THROW 50091, N'El año lectivo no existe.', 1;
    IF @estado NOT BETWEEN 1 AND 3
        THROW 50092, N'Ese año ya no admite inscripciones.', 1;
    IF @Ani_Id <> @Activo AND @anio < ISNULL(@AnioActivo, 0)
        THROW 50092, N'No se inscribe en un año anterior al activo.', 1;

    DECLARE @Niv int, @Cun int, @Mda int, @Sec int, @AnioCursado int, @Existe bit = 0;
    SELECT @Niv = Niv_Id, @Cun = Cun_Id, @Mda = Mda_Id, @Sec = Sec_Id, @AnioCursado = AnioCursado, @Existe = 1
    FROM app.tbAlumnos WHERE Alu_Id = @Alu_Id;
    IF @Existe = 0 THROW 50093, N'El alumno no existe.', 1;

    DECLARE @Sea_Id int;
    SELECT TOP (1) @Sea_Id = s.Sea_Id FROM app.tbSeccionesAnio s
    WHERE s.Ani_Id = @Ani_Id AND s.Sea_EsEliminado = 0 AND s.Sea_Estado IN (1, 2, 3)
      AND s.Niv_Id = @Niv AND s.Cun_Id = @Cun AND s.Sec_Id = @Sec AND s.Sea_MdaKey = ISNULL(@Mda, 0)
    ORDER BY s.Sea_Id;

    IF @Sea_Id IS NULL
    BEGIN
        IF @Ani_Id <> @Activo
            THROW 50094, N'Ese año no tiene la sección del alumno. Créela en Año Lectivo › Clases y profesores.', 1;
        -- Año activo: se crea la sección que falta (como hasta ahora) y se inscribe.
        CREATE TABLE #r (SeccionesCreadas int, Inscritos int, Reactivados int, YaInscritos int, SinSeccion int, Activados int);
        INSERT INTO #r EXEC app.PR_tbMatriculaAnio_InscribirDesdeUbicacion @Ani_Id, @Alu_Id, 1, 1, @Usuario;
        SELECT TOP (1) @Sea_Id = Sea_Id FROM app.tbMatriculaAnio WHERE Alu_Id = @Alu_Id AND Ani_Id = @Ani_Id AND Mta_EsEliminado = 0;
        IF @Sea_Id IS NULL THROW 50094, N'No se pudo inscribir al alumno en el año activo.', 1;
    END
    ELSE
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;
            DECLARE @cupo int, @sn nvarchar(120), @ins int;
            SELECT @cupo = Sea_Cupo, @sn = ISNULL(Sea_Nombre, N'la sección')
            FROM app.tbSeccionesAnio WITH (UPDLOCK, HOLDLOCK) WHERE Sea_Id = @Sea_Id;
            SELECT @ins = COUNT(*) FROM app.tbMatriculaAnio
            WHERE Sea_Id = @Sea_Id AND Mta_EsEliminado = 0 AND Mta_Estado = 1 AND Alu_Id <> @Alu_Id;
            IF @cupo IS NOT NULL AND @ins >= @cupo
            BEGIN
                DECLARE @m nvarchar(300) = CONCAT(@sn, N' ya no tiene cupo (', @ins, N' de ', @cupo, N').');
                THROW 50095, @m, 1;
            END

            DECLARE @Mta_Id int = (SELECT TOP (1) Mta_Id FROM app.tbMatriculaAnio WHERE Alu_Id = @Alu_Id AND Ani_Id = @Ani_Id);
            IF @Mta_Id IS NULL
                INSERT INTO app.tbMatriculaAnio (Alu_Id, Ani_Id, Sea_Id, Mta_Estado, Mta_EsEliminado, Mta_UsuarioRegistra, Mta_FechaRegistra)
                VALUES (@Alu_Id, @Ani_Id, @Sea_Id, 1, 0, @Usuario, GETDATE());
            ELSE
                UPDATE app.tbMatriculaAnio
                SET Sea_Id = @Sea_Id, Mta_Estado = 1, Mta_EsEliminado = 0, Mta_UsuarioModifica = @Usuario, Mta_FechaModifica = GETDATE()
                WHERE Mta_Id = @Mta_Id;
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END

    -- Alumno nuevo (sin otra inscripción) que entra a un año posterior: su año de cursado es ese año.
    IF @Ani_Id <> @Activo AND ISNULL(@AnioCursado, 0) < @anio
       AND NOT EXISTS (SELECT 1 FROM app.tbMatriculaAnio WHERE Alu_Id = @Alu_Id AND Ani_Id <> @Ani_Id AND Mta_EsEliminado = 0)
        UPDATE app.tbAlumnos SET AnioCursado = @anio WHERE Alu_Id = @Alu_Id;

    SELECT m.Mta_Id, m.Sea_Id, ISNULL(s.Sea_Nombre, N'') AS Sea_Nombre, @nombre AS Ani_Nombre, s.Sea_Cupo AS Cupo,
           (SELECT COUNT(*) FROM app.tbMatriculaAnio x WHERE x.Sea_Id = m.Sea_Id AND x.Mta_EsEliminado = 0 AND x.Mta_Estado = 1) AS Inscritos
    FROM app.tbMatriculaAnio m JOIN app.tbSeccionesAnio s ON s.Sea_Id = m.Sea_Id
    WHERE m.Alu_Id = @Alu_Id AND m.Ani_Id = @Ani_Id;
END
GO

-- Al abrir un año como activo: la ubicación actual de los alumnos inscritos en él pasa a su
-- sección de ese año (y su año de cursado). Solo mueve a quien todavía está en un año anterior,
-- así que repetirlo no cambia nada. El curso (carrera) solo cambia si el nivel cambia y el
-- nivel nuevo tiene un único curso; si no, se deja y se cuenta en CursoPorRevisar.
CREATE OR ALTER PROCEDURE app.PR_tbAnioLectivo_AplicarUbicacion
    @Ani_Id int,
    @Usuario int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @aplicados int = 0, @revisar int = 0;

    IF NOT EXISTS (SELECT 1 FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id AND Ani_EsEliminado = 0)
        THROW 50091, N'El año lectivo no existe.', 1;

    SELECT a.Alu_Id,
           sa.Niv_Id, sa.Cun_Id, ISNULL(sa.Mda_Id, a.Mda_Id) AS Mda_Id, sa.Sec_Id, an.Ani_Anio,
           CASE WHEN a.Niv_Id = sa.Niv_Id THEN a.Cur_Id ELSE ISNULL(cc.Cur_Id, a.Cur_Id) END AS Cur_Id,
           CAST(CASE WHEN a.Niv_Id <> sa.Niv_Id AND cc.Cur_Id IS NULL THEN 1 ELSE 0 END AS int) AS Revisar
    INTO #mover
    FROM app.tbAlumnos a
    JOIN app.tbMatriculaAnio m ON m.Alu_Id = a.Alu_Id AND m.Ani_Id = @Ani_Id AND m.Mta_EsEliminado = 0 AND m.Mta_Estado = 1
    JOIN app.tbSeccionesAnio sa ON sa.Sea_Id = m.Sea_Id
    JOIN app.tbAnioLectivo an ON an.Ani_Id = m.Ani_Id
    OUTER APPLY (SELECT MIN(c.Cur_Id) AS Cur_Id FROM app.tbCursos c
                 WHERE c.Niv_Id = sa.Niv_Id AND ISNULL(c.Cur_EsEliminado, 0) = 0 HAVING COUNT(*) = 1) cc
    WHERE ISNULL(a.AnioCursado, 0) < an.Ani_Anio;

    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE a
        SET Niv_Id = x.Niv_Id, Cun_Id = x.Cun_Id, Mda_Id = x.Mda_Id, Sec_Id = x.Sec_Id, Cur_Id = x.Cur_Id, AnioCursado = x.Ani_Anio
        FROM app.tbAlumnos a JOIN #mover x ON x.Alu_Id = a.Alu_Id;
        SET @aplicados = @@ROWCOUNT;
        SELECT @revisar = ISNULL(SUM(Revisar), 0) FROM #mover;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @aplicados AS Aplicados, @revisar AS CursoPorRevisar;
END
GO

-- Semestres del año según sus períodos (vacío si el año no tiene períodos de tipo semestre).
CREATE OR ALTER PROCEDURE app.PR_AnioConexion_Semestres
    @Anio int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Sem_Id, Nombre, Inicio, Fin FROM app.FN_SemestresAnio(@Anio) ORDER BY Sem_Id;
END
GO
