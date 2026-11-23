/* =============================================================================
   074 · Temario y avance del programa  (espejo de Skuul: syllabi, syllabus_topics,
         syllabus_topic_coverages y la biblioteca para copiar temarios)

   - El TEMARIO es el programa de una materia para un grado (y opcionalmente un curso o
     carrera), un semestre y un año: temas por semana con objetivos, contenido y recursos.
     Lo comparten todas las secciones del grado que llevan la materia. No es el "Plan de
     clases" (app.tbPlanClases), que es lo que cada docente planifica para su horario.
   - Un solo temario activo por materia + grado (+ curso) + semestre + año. Un temario sin
     curso vale para todos los cursos del grado: no puede convivir con uno de curso.
   - AVANCE: por cada tema y cada sección (grupo curso + sección + jornada que lleva la
     materia según app.tbHorarios del año) se marca dado / parcial / omitido, con la fecha
     en que se dio y una nota de clase. Si el horario del año no tiene cargado el semestre
     del temario, se usan las secciones de todo el año.
   - Semana esperada: semana de clases contada desde Tem_FechaInicio (no hay períodos de
     semestre usables en app.tbPeriodosAnio, por eso la fecha vive en el temario). Igual
     que Skuul, un tema de una semana ANTERIOR a la actual ya se esperaba; está atrasado
     si no está dado ni omitido. Semáforo: al_dia (0 atrasados), leve (1-2), atrasada (3+),
     sin_inicio (antes del inicio de clases) y sin_temas.
   - Permisos (se calculan aquí con el usuario, no se confía en lo que mande el ADM):
       Temario y avance     ver los temarios de las materias que imparte (horario del año
                            del temario o del año en curso) y marcar el avance de SUS
                            secciones (horario del año del temario).
       Editar temarios      crear, editar, copiar y quitar temas de los temarios que ve.
       Supervisar temarios  ver todos, editar todos (con "Editar temarios"), marcar el avance
                            de cualquier sección y ver el resumen de Dirección.
     El rol admin pasa todo.
   - Prefijos: Tem_ (temario), Tet_ (temas), Tav_ (avance).

   Solo agrega objetos nuevos; se puede ejecutar varias veces.
   Crear SIEMPRE con QUOTED_IDENTIFIER ON (índices filtrados).
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ---------------------------------------------------------------- Tablas */
IF OBJECT_ID('app.tbTemarios') IS NULL
BEGIN
    CREATE TABLE app.tbTemarios
    (
        Tem_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbTemarios PRIMARY KEY,
        Mat_Id              int            NOT NULL CONSTRAINT FK_tbTemarios_tbMaterias REFERENCES app.tbMaterias (Mat_Id),
        Cun_Id              int            NOT NULL CONSTRAINT FK_tbTemarios_tbCursosNiveles REFERENCES app.tbCursosNiveles (Cun_Id),
        Cur_Id              int            NULL     CONSTRAINT FK_tbTemarios_tbCursos REFERENCES app.tbCursos (Cur_Id),
        Sem_Id              int            NOT NULL CONSTRAINT FK_tbTemarios_tbSemestres REFERENCES app.tbSemestres (Sem_Id),
        Tem_Anio            int            NOT NULL,
        Tem_Nombre          nvarchar(150)  NOT NULL,
        Tem_Descripcion     nvarchar(2000) NULL,
        Tem_FechaInicio     date           NOT NULL,
        Tem_IdOrigen        int            NULL     CONSTRAINT FK_tbTemarios_Origen REFERENCES app.tbTemarios (Tem_Id),
        Tem_CurClave        AS ISNULL(Cur_Id, 0) PERSISTED,
        Tem_EsEliminado     bit            NOT NULL CONSTRAINT DF_tbTemarios_EsEliminado DEFAULT (0),
        Tem_UsuarioRegistra int            NULL,
        Tem_FechaRegistra   datetime2(0)   NOT NULL CONSTRAINT DF_tbTemarios_FechaRegistra DEFAULT (SYSDATETIME()),
        Tem_UsuarioModifica int            NULL,
        Tem_FechaModifica   datetime2(0)   NULL,
        CONSTRAINT CK_tbTemarios_Anio CHECK (Tem_Anio BETWEEN 2000 AND 2100)
    );
    CREATE UNIQUE INDEX UX_tbTemarios_Activo ON app.tbTemarios (Mat_Id, Cun_Id, Tem_CurClave, Sem_Id, Tem_Anio) WHERE Tem_EsEliminado = 0;
END
GO

IF OBJECT_ID('app.tbTemarioTemas') IS NULL
BEGIN
    CREATE TABLE app.tbTemarioTemas
    (
        Tet_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbTemarioTemas PRIMARY KEY,
        Tem_Id              int            NOT NULL CONSTRAINT FK_tbTemarioTemas_tbTemarios REFERENCES app.tbTemarios (Tem_Id),
        Tet_Semana          int            NOT NULL,
        Tet_Orden           int            NOT NULL,
        Tet_Titulo          nvarchar(200)  NOT NULL,
        Tet_Objetivos       nvarchar(2000) NULL,
        Tet_Contenido       nvarchar(4000) NULL,
        Tet_Recursos        nvarchar(1000) NULL,
        Tet_IdOrigen        int            NULL,
        Tet_EsEliminado     bit            NOT NULL CONSTRAINT DF_tbTemarioTemas_EsEliminado DEFAULT (0),
        Tet_UsuarioRegistra int            NULL,
        Tet_FechaRegistra   datetime2(0)   NOT NULL CONSTRAINT DF_tbTemarioTemas_FechaRegistra DEFAULT (SYSDATETIME()),
        Tet_UsuarioModifica int            NULL,
        Tet_FechaModifica   datetime2(0)   NULL,
        CONSTRAINT CK_tbTemarioTemas_Semana CHECK (Tet_Semana BETWEEN 1 AND 30)
    );
    CREATE INDEX IX_tbTemarioTemas_Temario ON app.tbTemarioTemas (Tem_Id, Tet_Semana, Tet_Orden) WHERE Tet_EsEliminado = 0;
END
GO

IF OBJECT_ID('app.tbTemarioAvance') IS NULL
BEGIN
    CREATE TABLE app.tbTemarioAvance
    (
        Tav_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbTemarioAvance PRIMARY KEY,
        Tet_Id              int            NOT NULL CONSTRAINT FK_tbTemarioAvance_tbTemarioTemas REFERENCES app.tbTemarioTemas (Tet_Id),
        Cur_Id              int            NOT NULL CONSTRAINT FK_tbTemarioAvance_tbCursos REFERENCES app.tbCursos (Cur_Id),
        Sec_Id              int            NOT NULL CONSTRAINT FK_tbTemarioAvance_tbSecciones REFERENCES app.tbSecciones (Sec_Id),
        Mda_Id              int            NOT NULL CONSTRAINT FK_tbTemarioAvance_tbModalidades REFERENCES app.tbModalidades (Mda_Id),
        Tav_Estado          varchar(10)    NOT NULL CONSTRAINT DF_tbTemarioAvance_Estado DEFAULT ('dado'),
        Tav_Fecha           date           NULL,
        Tav_Nota            nvarchar(1000) NULL,
        Tav_UsuarioRegistra int            NOT NULL CONSTRAINT FK_tbTemarioAvance_Usuario REFERENCES seguridad.tbUsuarios (Usu_Id),
        Tav_FechaRegistra   datetime2(0)   NOT NULL CONSTRAINT DF_tbTemarioAvance_FechaRegistra DEFAULT (SYSDATETIME()),
        Tav_UsuarioModifica int            NULL,
        Tav_FechaModifica   datetime2(0)   NULL,
        CONSTRAINT UQ_tbTemarioAvance_TemaSeccion UNIQUE (Tet_Id, Cur_Id, Sec_Id, Mda_Id),
        CONSTRAINT CK_tbTemarioAvance_Estado CHECK (Tav_Estado IN ('dado','parcial','omitido')),
        CONSTRAINT CK_tbTemarioAvance_Fecha CHECK (Tav_Estado = 'omitido' OR Tav_Fecha IS NOT NULL)
    );
END
GO

/* ---------------------------------------------------------------- Funciones */

-- Año lectivo en curso (app.tbConfiguracion «anio_lectivo_actual»; si no hay, el año de hoy en Honduras).
CREATE OR ALTER FUNCTION app.FN_Temario_AnioActual ()
RETURNS int
AS
BEGIN
    DECLARE @Anio int = (SELECT TOP (1) TRY_CAST(Con_Valor AS int) FROM app.tbConfiguracion WHERE Con_Clave = 'anio_lectivo_actual');
    RETURN ISNULL(@Anio, YEAR(app.FN_AhoraHonduras()));
END
GO

-- Texto de catálogo limpio (algunos nombres traen saltos de línea al final).
CREATE OR ALTER FUNCTION app.FN_Temario_Texto (@Texto nvarchar(400))
RETURNS nvarchar(400)
AS
BEGIN
    RETURN NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(@Texto, CHAR(13), N''), CHAR(10), N''), CHAR(9), N' '))), N'');
END
GO

-- Permisos del usuario sobre temarios (admin pasa todo). Sin fila si el usuario no existe o está inactivo.
CREATE OR ALTER FUNCTION app.FN_Temario_Permisos (@Usu_Id int)
RETURNS TABLE
AS
RETURN
    SELECT u.Usu_Id, u.Emp_Id,
           CAST(CASE WHEN a.EsAdmin = 1 OR EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas rp JOIN seguridad.tbPantallas p ON p.Pan_Id = rp.Pan_Id
                                                   WHERE rp.Rol_Id = u.Rol_Id AND p.Pan_Descripcion = N'Temario y avance' AND ISNULL(p.Pan_EsEliminado, 0) = 0)
                     THEN 1 ELSE 0 END AS bit) AS Ver,
           CAST(CASE WHEN a.EsAdmin = 1 OR EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas rp JOIN seguridad.tbPantallas p ON p.Pan_Id = rp.Pan_Id
                                                   WHERE rp.Rol_Id = u.Rol_Id AND p.Pan_Descripcion = N'Editar temarios' AND ISNULL(p.Pan_EsEliminado, 0) = 0)
                     THEN 1 ELSE 0 END AS bit) AS Editar,
           CAST(CASE WHEN a.EsAdmin = 1 OR EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas rp JOIN seguridad.tbPantallas p ON p.Pan_Id = rp.Pan_Id
                                                   WHERE rp.Rol_Id = u.Rol_Id AND p.Pan_Descripcion = N'Supervisar temarios' AND ISNULL(p.Pan_EsEliminado, 0) = 0)
                     THEN 1 ELSE 0 END AS bit) AS Supervisar
    FROM seguridad.tbUsuarios u
    JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
    CROSS APPLY (SELECT CAST(CASE WHEN LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) = 'admin' THEN 1 ELSE 0 END AS bit) AS EsAdmin) a
    WHERE u.Usu_Id = @Usu_Id
      AND ISNULL(u.Usu_EsEliminado, 0) = 0
      AND ISNULL(u.Usu_EsActivo, 1) = 1
      AND ISNULL(u.Usu_Suspendido, 0) = 0;
GO

-- ¿El empleado da la materia en el grado (y curso, si el temario tiene) en el año del temario o en el año en curso?
CREATE OR ALTER FUNCTION app.FN_Temario_Imparte (@Emp_Id int, @Mat_Id int, @Cun_Id int, @Cur_Id int, @Anio int)
RETURNS bit
AS
BEGIN
    IF @Emp_Id IS NULL RETURN 0;
    DECLARE @Actual int = app.FN_Temario_AnioActual();
    RETURN CASE WHEN EXISTS (SELECT 1 FROM app.tbHorarios h
                             WHERE h.Emp_Id = @Emp_Id AND h.Mat_Id = @Mat_Id AND h.Cun_Id = @Cun_Id
                               AND (@Cur_Id IS NULL OR h.Cur_Id = @Cur_Id)
                               AND h.Hor_Año IN (@Anio, @Actual)
                               AND ISNULL(h.Hor_EsEliminado, 0) = 0)
                THEN 1 ELSE 0 END;
END
GO

-- Semana de clases en una fecha (1 = la semana que empieza en la fecha de inicio); NULL antes del inicio.
CREATE OR ALTER FUNCTION app.FN_Temario_Semana (@Inicio date, @Fecha date)
RETURNS int
AS
BEGIN
    IF @Inicio IS NULL OR @Fecha IS NULL OR @Fecha < @Inicio RETURN NULL;
    RETURN DATEDIFF(day, @Inicio, @Fecha) / 7 + 1;
END
GO

-- Temarios que el usuario puede leer, con lo que puede hacer en cada uno.
CREATE OR ALTER FUNCTION app.FN_Temarios_Visibles (@Usu_Id int)
RETURNS TABLE
AS
RETURN
    SELECT t.Tem_Id, x.EsMio, p.Supervisar AS PuedeSupervisar,
           CAST(CASE WHEN p.Editar = 1 AND (p.Supervisar = 1 OR x.EsMio = 1) THEN 1 ELSE 0 END AS bit) AS PuedeEditar
    FROM app.tbTemarios t
    CROSS JOIN app.FN_Temario_Permisos(@Usu_Id) p
    CROSS APPLY (SELECT app.FN_Temario_Imparte(p.Emp_Id, t.Mat_Id, t.Cun_Id, t.Cur_Id, t.Tem_Anio) AS EsMio) x
    WHERE t.Tem_EsEliminado = 0
      AND (p.Ver = 1 OR p.Supervisar = 1)
      AND (p.Supervisar = 1 OR x.EsMio = 1);
GO

-- Secciones (curso + sección + jornada) que llevan la materia del temario según el horario de su año.
-- Si el horario del año no tiene el semestre del temario, se usan las secciones de todo el año.
CREATE OR ALTER FUNCTION app.FN_Temario_Grupos (@Tem_Id int)
RETURNS TABLE
AS
RETURN
    WITH h AS (
        SELECT DISTINCT h.Cur_Id, h.Sec_Id, h.Mda_Id, h.Sem_Id, t.Sem_Id AS SemTemario
        FROM app.tbTemarios t
        JOIN app.tbHorarios h
          ON h.Mat_Id = t.Mat_Id AND h.Cun_Id = t.Cun_Id AND h.Hor_Año = t.Tem_Anio
         AND (t.Cur_Id IS NULL OR h.Cur_Id = t.Cur_Id)
         AND ISNULL(h.Hor_EsEliminado, 0) = 0
         AND h.Cur_Id IS NOT NULL AND h.Sec_Id IS NOT NULL AND h.Mda_Id IS NOT NULL
        WHERE t.Tem_Id = @Tem_Id
    )
    SELECT DISTINCT h.Cur_Id, h.Sec_Id, h.Mda_Id
    FROM h
    WHERE h.Sem_Id = h.SemTemario
       OR NOT EXISTS (SELECT 1 FROM h x WHERE x.Sem_Id = x.SemTemario);
GO

-- ¿El usuario puede marcar el avance de esta sección en este temario?
CREATE OR ALTER FUNCTION app.FN_Temario_PuedeMarcar (@Usu_Id int, @Tem_Id int, @Cur_Id int, @Sec_Id int, @Mda_Id int)
RETURNS bit
AS
BEGIN
    RETURN CASE WHEN EXISTS (
        SELECT 1
        FROM app.FN_Temarios_Visibles(@Usu_Id) v
        JOIN app.tbTemarios t ON t.Tem_Id = v.Tem_Id
        CROSS JOIN app.FN_Temario_Permisos(@Usu_Id) p
        WHERE v.Tem_Id = @Tem_Id
          AND (p.Supervisar = 1
               OR EXISTS (SELECT 1 FROM app.tbHorarios h
                          WHERE h.Emp_Id = p.Emp_Id AND h.Mat_Id = t.Mat_Id AND h.Cun_Id = t.Cun_Id
                            AND h.Cur_Id = @Cur_Id AND h.Sec_Id = @Sec_Id AND h.Mda_Id = @Mda_Id
                            AND h.Hor_Año = t.Tem_Anio AND ISNULL(h.Hor_EsEliminado, 0) = 0))
    ) THEN 1 ELSE 0 END;
END
GO

-- Avance de cada sección del temario en una fecha: temas dados, parciales, omitidos, esperados y atrasados.
CREATE OR ALTER FUNCTION app.FN_Temario_AvanceGrupos (@Tem_Id int, @Hoy date)
RETURNS TABLE
AS
RETURN
    WITH temas AS (
        SELECT Tet_Id, Tet_Semana FROM app.tbTemarioTemas WHERE Tem_Id = @Tem_Id AND Tet_EsEliminado = 0
    ),
    sem AS (
        SELECT app.FN_Temario_Semana(Tem_FechaInicio, @Hoy) AS Semana FROM app.tbTemarios WHERE Tem_Id = @Tem_Id
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

-- Semáforo de una sección: sin_temas · sin_inicio · al_dia · leve (1-2 atrasados) · atrasada (3 o más).
CREATE OR ALTER FUNCTION app.FN_Temario_Semaforo (@Total int, @SemanaActual int, @Atrasados int)
RETURNS varchar(12)
AS
BEGIN
    RETURN CASE WHEN ISNULL(@Total, 0) = 0 THEN 'sin_temas'
                WHEN @SemanaActual IS NULL THEN 'sin_inicio'
                WHEN ISNULL(@Atrasados, 0) = 0 THEN 'al_dia'
                WHEN @Atrasados <= 2 THEN 'leve'
                ELSE 'atrasada' END;
END
GO

-- Nombre visible de un usuario: "Nombre del empleado (usuario)".
CREATE OR ALTER FUNCTION app.FN_Temario_NombreUsuario (@Usu_Id int)
RETURNS nvarchar(200)
AS
BEGIN
    RETURN (SELECT TOP (1) CASE WHEN p.Per_Id IS NULL THEN u.Usu_Name
                                ELSE CONCAT(CONCAT_WS(N' ', p.Per_PrimerNombre, p.Per_ApellidoPaterno), N' (', u.Usu_Name, N')') END
            FROM seguridad.tbUsuarios u
            LEFT JOIN app.tbEmpleados e ON e.Emp_Id = u.Emp_Id
            LEFT JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id
            WHERE u.Usu_Id = @Usu_Id);
END
GO

-- Datos de cada temario legible (lo usan el listado y la ficha).
CREATE OR ALTER FUNCTION app.FN_Temarios_Detalle (@Usu_Id int, @Hoy date)
RETURNS TABLE
AS
RETURN
    SELECT t.Tem_Id, t.Mat_Id, app.FN_Temario_Texto(m.Mat_Nombre) AS Materia,
           cn.Niv_Id, app.FN_Temario_Texto(n.Niv_Descripcion) AS Nivel,
           t.Cun_Id, app.FN_Temario_Texto(cn.Cun_Descripcion) AS Grado, ISNULL(cn.Cun_Orden, cn.Cun_Id) AS Cun_Orden,
           t.Cur_Id, app.FN_Temario_Texto(c.Cur_Nombre) AS Curso,
           t.Sem_Id, CONCAT(app.FN_Temario_Texto(s.Sem_Descripcion), N' semestre') AS Semestre,
           t.Tem_Anio, t.Tem_Nombre, t.Tem_Descripcion, t.Tem_FechaInicio,
           app.FN_Temario_Semana(t.Tem_FechaInicio, @Hoy) AS SemanaActual,
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

/* ---------------------------------------------------------------- Lecturas */

-- Biblioteca: todos los temarios que la persona puede leer (el docente, los de sus materias).
CREATE OR ALTER PROCEDURE app.PR_tbTemarios_List
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    SELECT *
    FROM app.FN_Temarios_Detalle(@Usu_Id, @Hoy)
    ORDER BY Tem_Anio DESC, Sem_Id DESC, Niv_Id, Cun_Orden, Materia;
END
GO

-- Un temario. Sin fila si no existe, está eliminado o la persona no lo puede leer.
CREATE OR ALTER PROCEDURE app.PR_tbTemarios_Find
    @Tem_Id int,
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    SELECT * FROM app.FN_Temarios_Detalle(@Usu_Id, @Hoy) WHERE Tem_Id = @Tem_Id;
END
GO

-- Temas de un temario legible, por semana y orden, con cuántas secciones ya lo dieron.
CREATE OR ALTER PROCEDURE app.PR_tbTemarioTemas_List
    @Tem_Id int,
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    DECLARE @Semana int = (SELECT app.FN_Temario_Semana(Tem_FechaInicio, @Hoy) FROM app.tbTemarios WHERE Tem_Id = @Tem_Id);

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

-- Secciones que llevan la materia del temario, con su avance, semáforo, docentes y si la persona puede marcar.
CREATE OR ALTER PROCEDURE app.PR_tbTemarios_Grupos
    @Tem_Id int,
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    IF NOT EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usu_Id) v WHERE v.Tem_Id = @Tem_Id) RETURN;

    DECLARE @Mat_Id int, @Cun_Id int, @Anio int;
    SELECT @Mat_Id = Mat_Id, @Cun_Id = Cun_Id, @Anio = Tem_Anio FROM app.tbTemarios WHERE Tem_Id = @Tem_Id;

    SELECT g.Cur_Id, app.FN_Temario_Texto(c.Cur_Nombre) AS Curso,
           g.Sec_Id, app.FN_Temario_Texto(s.Sec_Descripcion) AS Seccion,
           g.Mda_Id, app.FN_Temario_Texto(md.Mda_Descripcion) AS Jornada,
           ISNULL(d.Docentes, N'') AS Docentes, ISNULL(d.CantidadDocentes, 0) AS CantidadDocentes,
           app.FN_Temario_PuedeMarcar(@Usu_Id, @Tem_Id, g.Cur_Id, g.Sec_Id, g.Mda_Id) AS PuedeMarcar,
           g.Total, g.Dados, g.Parciales, g.Omitidos, g.Esperados, g.Atrasados, g.SemanaActual,
           CASE WHEN g.Total = 0 THEN 0 ELSE CAST(ROUND(g.Dados * 100.0 / g.Total, 0) AS int) END AS Pct,
           app.FN_Temario_Semaforo(g.Total, g.SemanaActual, g.Atrasados) AS Semaforo
    FROM app.FN_Temario_AvanceGrupos(@Tem_Id, @Hoy) g
    LEFT JOIN app.tbCursos c ON c.Cur_Id = g.Cur_Id
    LEFT JOIN app.tbSecciones s ON s.Sec_Id = g.Sec_Id
    LEFT JOIN app.tbModalidades md ON md.Mda_Id = g.Mda_Id
    OUTER APPLY (SELECT STRING_AGG(z.Nombre, N', ') WITHIN GROUP (ORDER BY z.Nombre) AS Docentes, COUNT(*) AS CantidadDocentes
                 FROM (SELECT DISTINCT CONCAT_WS(N' ', p.Per_PrimerNombre, p.Per_ApellidoPaterno) AS Nombre
                       FROM app.tbHorarios h
                       JOIN app.tbEmpleados e ON e.Emp_Id = h.Emp_Id
                       JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id
                       WHERE h.Mat_Id = @Mat_Id AND h.Cun_Id = @Cun_Id AND h.Hor_Año = @Anio
                         AND h.Cur_Id = g.Cur_Id AND h.Sec_Id = g.Sec_Id AND h.Mda_Id = g.Mda_Id
                         AND ISNULL(h.Hor_EsEliminado, 0) = 0) z) d
    ORDER BY app.FN_Temario_Texto(c.Cur_Nombre), app.FN_Temario_Texto(s.Sec_Descripcion), g.Mda_Id;
END
GO

-- Marcas de avance de un temario legible (solo de las secciones que llevan la materia).
CREATE OR ALTER PROCEDURE app.PR_tbTemarioAvance_List
    @Tem_Id int,
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usu_Id) v WHERE v.Tem_Id = @Tem_Id) RETURN;

    SELECT av.Tav_Id, av.Tet_Id, av.Cur_Id, av.Sec_Id, av.Mda_Id, av.Tav_Estado, av.Tav_Fecha, av.Tav_Nota,
           app.FN_Temario_NombreUsuario(ISNULL(av.Tav_UsuarioModifica, av.Tav_UsuarioRegistra)) AS Usuario,
           ISNULL(av.Tav_FechaModifica, av.Tav_FechaRegistra) AS FechaRegistro
    FROM app.tbTemarioAvance av
    JOIN app.tbTemarioTemas x ON x.Tet_Id = av.Tet_Id AND x.Tet_EsEliminado = 0
    JOIN app.FN_Temario_Grupos(@Tem_Id) g ON g.Cur_Id = av.Cur_Id AND g.Sec_Id = av.Sec_Id AND g.Mda_Id = av.Mda_Id
    WHERE x.Tem_Id = @Tem_Id;
END
GO

-- Resumen de Dirección: cada sección de cada temario del año y semestre, la más atrasada primero.
-- Solo con "Supervisar temarios" (sin el permiso devuelve vacío).
CREATE OR ALTER PROCEDURE app.PR_tbTemarios_Resumen
    @Usu_Id int,
    @Anio   int = NULL,
    @Sem_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    IF NOT EXISTS (SELECT 1 FROM app.FN_Temario_Permisos(@Usu_Id) WHERE Supervisar = 1) RETURN;
    SET @Anio = ISNULL(@Anio, app.FN_Temario_AnioActual());

    SELECT t.Tem_Id, t.Tem_Nombre, t.Mat_Id, app.FN_Temario_Texto(m.Mat_Nombre) AS Materia,
           cn.Niv_Id, app.FN_Temario_Texto(n.Niv_Descripcion) AS Nivel,
           t.Cun_Id, app.FN_Temario_Texto(cn.Cun_Descripcion) AS Grado, ISNULL(cn.Cun_Orden, cn.Cun_Id) AS Cun_Orden,
           g.Cur_Id, app.FN_Temario_Texto(c.Cur_Nombre) AS Curso,
           g.Sec_Id, app.FN_Temario_Texto(s.Sec_Descripcion) AS Seccion,
           g.Mda_Id, app.FN_Temario_Texto(md.Mda_Descripcion) AS Jornada,
           t.Sem_Id, t.Tem_Anio,
           g.Total, g.Dados, g.Parciales, g.Omitidos, g.Esperados, g.Atrasados, g.SemanaActual,
           CASE WHEN g.Total = 0 THEN 0 ELSE CAST(ROUND(g.Dados * 100.0 / g.Total, 0) AS int) END AS Pct,
           app.FN_Temario_Semaforo(g.Total, g.SemanaActual, g.Atrasados) AS Semaforo,
           ult.UltimaFecha, ISNULL(d.Docentes, N'') AS Docentes
    FROM app.tbTemarios t
    CROSS APPLY app.FN_Temario_AvanceGrupos(t.Tem_Id, @Hoy) g
    JOIN app.tbMaterias m ON m.Mat_Id = t.Mat_Id
    JOIN app.tbCursosNiveles cn ON cn.Cun_Id = t.Cun_Id
    LEFT JOIN app.tbNivelesEducativos n ON n.Niv_Id = cn.Niv_Id
    LEFT JOIN app.tbCursos c ON c.Cur_Id = g.Cur_Id
    LEFT JOIN app.tbSecciones s ON s.Sec_Id = g.Sec_Id
    LEFT JOIN app.tbModalidades md ON md.Mda_Id = g.Mda_Id
    OUTER APPLY (SELECT MAX(av.Tav_Fecha) AS UltimaFecha
                 FROM app.tbTemarioAvance av
                 JOIN app.tbTemarioTemas x ON x.Tet_Id = av.Tet_Id AND x.Tet_EsEliminado = 0 AND x.Tem_Id = t.Tem_Id
                 WHERE av.Cur_Id = g.Cur_Id AND av.Sec_Id = g.Sec_Id AND av.Mda_Id = g.Mda_Id) ult
    OUTER APPLY (SELECT STRING_AGG(z.Nombre, N', ') WITHIN GROUP (ORDER BY z.Nombre) AS Docentes
                 FROM (SELECT DISTINCT CONCAT_WS(N' ', p.Per_PrimerNombre, p.Per_ApellidoPaterno) AS Nombre
                       FROM app.tbHorarios h
                       JOIN app.tbEmpleados e ON e.Emp_Id = h.Emp_Id
                       JOIN app.tbPersonas p ON p.Per_Id = e.Per_Id
                       WHERE h.Mat_Id = t.Mat_Id AND h.Cun_Id = t.Cun_Id AND h.Hor_Año = t.Tem_Anio
                         AND h.Cur_Id = g.Cur_Id AND h.Sec_Id = g.Sec_Id AND h.Mda_Id = g.Mda_Id
                         AND ISNULL(h.Hor_EsEliminado, 0) = 0) z) d
    WHERE t.Tem_EsEliminado = 0
      AND t.Tem_Anio = @Anio
      AND (@Sem_Id IS NULL OR t.Sem_Id = @Sem_Id)
    ORDER BY g.Atrasados DESC, CASE WHEN g.Total = 0 THEN 0 ELSE g.Dados * 100.0 / g.Total END, cn.Niv_Id, Cun_Orden, Materia;
END
GO

-- Materias que se dan en el horario del año (y semestre) y todavía no tienen temario. Solo "Supervisar temarios".
CREATE OR ALTER PROCEDURE app.PR_tbTemarios_SinTemario
    @Usu_Id int,
    @Anio   int = NULL,
    @Sem_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM app.FN_Temario_Permisos(@Usu_Id) WHERE Supervisar = 1) RETURN;
    SET @Anio = ISNULL(@Anio, app.FN_Temario_AnioActual());

    -- Semestres a revisar: el pedido o los dos.
    DECLARE @Semestres TABLE (Sem_Id int PRIMARY KEY);
    INSERT INTO @Semestres SELECT Sem_Id FROM app.tbSemestres WHERE ISNULL(Sem_EsEliminado, 0) = 0 AND (@Sem_Id IS NULL OR Sem_Id = @Sem_Id);

    WITH h AS (
        SELECT DISTINCT h.Mat_Id, h.Cun_Id, h.Cur_Id, h.Sec_Id, h.Mda_Id, h.Sem_Id
        FROM app.tbHorarios h
        WHERE h.Hor_Año = @Anio AND ISNULL(h.Hor_EsEliminado, 0) = 0
          AND h.Mat_Id IS NOT NULL AND h.Cun_Id IS NOT NULL AND h.Cur_Id IS NOT NULL AND h.Sec_Id IS NOT NULL AND h.Mda_Id IS NOT NULL
    ),
    -- Por semestre: las del semestre; si el horario no tiene ese semestre cargado, las de todo el año.
    porSemestre AS (
        SELECT s.Sem_Id, h.Mat_Id, h.Cun_Id, h.Cur_Id, h.Sec_Id, h.Mda_Id
        FROM @Semestres s
        JOIN h ON h.Sem_Id = s.Sem_Id OR NOT EXISTS (SELECT 1 FROM h x WHERE x.Sem_Id = s.Sem_Id)
    )
    SELECT ps.Sem_Id, CONCAT(app.FN_Temario_Texto(se.Sem_Descripcion), N' semestre') AS Semestre,
           ps.Mat_Id, app.FN_Temario_Texto(m.Mat_Nombre) AS Materia,
           cn.Niv_Id, app.FN_Temario_Texto(n.Niv_Descripcion) AS Nivel,
           ps.Cun_Id, app.FN_Temario_Texto(cn.Cun_Descripcion) AS Grado, ISNULL(cn.Cun_Orden, cn.Cun_Id) AS Cun_Orden,
           COUNT(DISTINCT CONCAT(ps.Cur_Id, '-', ps.Sec_Id, '-', ps.Mda_Id)) AS Secciones
    FROM porSemestre ps
    JOIN app.tbMaterias m ON m.Mat_Id = ps.Mat_Id
    JOIN app.tbCursosNiveles cn ON cn.Cun_Id = ps.Cun_Id
    LEFT JOIN app.tbNivelesEducativos n ON n.Niv_Id = cn.Niv_Id
    LEFT JOIN app.tbSemestres se ON se.Sem_Id = ps.Sem_Id
    WHERE NOT EXISTS (SELECT 1 FROM app.tbTemarios t
                      WHERE t.Tem_EsEliminado = 0 AND t.Mat_Id = ps.Mat_Id AND t.Cun_Id = ps.Cun_Id
                        AND t.Sem_Id = ps.Sem_Id AND t.Tem_Anio = @Anio
                        AND (t.Cur_Id IS NULL OR t.Cur_Id = ps.Cur_Id))
    GROUP BY ps.Sem_Id, se.Sem_Descripcion, ps.Mat_Id, m.Mat_Nombre, cn.Niv_Id, n.Niv_Descripcion, ps.Cun_Id, cn.Cun_Descripcion, cn.Cun_Orden, cn.Cun_Id
    ORDER BY ps.Sem_Id, cn.Niv_Id, ISNULL(cn.Cun_Orden, cn.Cun_Id), app.FN_Temario_Texto(m.Mat_Nombre);
END
GO

-- Opciones de los filtros en cascada (Nivel → Grado → Curso → Materia), más semestres y años.
-- Salen del horario: el docente sin "Supervisar temarios" solo ve lo que imparte. Con @Anio se
-- limita al horario de ese año y del año en curso; sin @Anio entran todos los años y los temarios que ya ve.
CREATE OR ALTER PROCEDURE app.PR_tbTemarios_Opciones
    @Usu_Id int,
    @Tipo   varchar(10),
    @Niv_Id int = NULL,
    @Cun_Id int = NULL,
    @Cur_Id int = NULL,
    @Anio   int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Emp_Id int, @Supervisar bit, @Ver bit;
    SELECT @Emp_Id = Emp_Id, @Supervisar = Supervisar, @Ver = Ver FROM app.FN_Temario_Permisos(@Usu_Id);
    IF ISNULL(@Ver, 0) = 0 AND ISNULL(@Supervisar, 0) = 0 RETURN;
    DECLARE @Actual int = app.FN_Temario_AnioActual();

    IF @Tipo = 'semestre'
    BEGIN
        SELECT Sem_Id AS Value, CONCAT(app.FN_Temario_Texto(Sem_Descripcion), N' semestre') AS Text
        FROM app.tbSemestres WHERE ISNULL(Sem_EsEliminado, 0) = 0 ORDER BY Sem_Id;
        RETURN;
    END

    IF @Tipo = 'anio'
    BEGIN
        SELECT x.Anio AS Value, CAST(x.Anio AS nvarchar(10)) AS Text
        FROM (SELECT @Actual AS Anio UNION SELECT @Actual + 1
              UNION SELECT DISTINCT Hor_Año FROM app.tbHorarios WHERE Hor_Año BETWEEN 2000 AND 2100 AND ISNULL(Hor_EsEliminado, 0) = 0
              UNION SELECT t.Tem_Anio FROM app.FN_Temarios_Visibles(@Usu_Id) v JOIN app.tbTemarios t ON t.Tem_Id = v.Tem_Id) x
        WHERE x.Anio IS NOT NULL
        ORDER BY x.Anio DESC;
        RETURN;
    END

    DECLARE @Base TABLE (Cun_Id int, Cur_Id int, Mat_Id int);
    INSERT INTO @Base (Cun_Id, Cur_Id, Mat_Id)
    SELECT DISTINCT h.Cun_Id, h.Cur_Id, h.Mat_Id
    FROM app.tbHorarios h
    WHERE ISNULL(h.Hor_EsEliminado, 0) = 0
      AND h.Cun_Id IS NOT NULL AND h.Mat_Id IS NOT NULL
      AND (@Anio IS NULL OR h.Hor_Año IN (@Anio, @Actual))
      AND (@Supervisar = 1 OR h.Emp_Id = @Emp_Id);
    IF @Anio IS NULL
        INSERT INTO @Base (Cun_Id, Cur_Id, Mat_Id)
        SELECT t.Cun_Id, t.Cur_Id, t.Mat_Id FROM app.FN_Temarios_Visibles(@Usu_Id) v JOIN app.tbTemarios t ON t.Tem_Id = v.Tem_Id;

    IF @Tipo = 'nivel'
        SELECT n.Niv_Id AS Value, app.FN_Temario_Texto(n.Niv_Descripcion) AS Text
        FROM @Base b JOIN app.tbCursosNiveles cn ON cn.Cun_Id = b.Cun_Id JOIN app.tbNivelesEducativos n ON n.Niv_Id = cn.Niv_Id
        GROUP BY n.Niv_Id, n.Niv_Descripcion ORDER BY n.Niv_Id;
    ELSE IF @Tipo = 'grado'
        SELECT cn.Cun_Id AS Value, app.FN_Temario_Texto(cn.Cun_Descripcion) AS Text
        FROM @Base b JOIN app.tbCursosNiveles cn ON cn.Cun_Id = b.Cun_Id
        WHERE cn.Niv_Id = @Niv_Id
        GROUP BY cn.Cun_Id, cn.Cun_Descripcion, cn.Cun_Orden ORDER BY ISNULL(cn.Cun_Orden, cn.Cun_Id);
    ELSE IF @Tipo = 'curso'
        SELECT c.Cur_Id AS Value, app.FN_Temario_Texto(c.Cur_Nombre) AS Text
        FROM @Base b JOIN app.tbCursos c ON c.Cur_Id = b.Cur_Id
        WHERE b.Cun_Id = @Cun_Id
        GROUP BY c.Cur_Id, c.Cur_Nombre ORDER BY app.FN_Temario_Texto(c.Cur_Nombre);
    ELSE IF @Tipo = 'materia'
        SELECT m.Mat_Id AS Value, app.FN_Temario_Texto(m.Mat_Nombre) AS Text
        FROM @Base b JOIN app.tbMaterias m ON m.Mat_Id = b.Mat_Id
        WHERE b.Cun_Id = @Cun_Id AND (@Cur_Id IS NULL OR b.Cur_Id = @Cur_Id)
        GROUP BY m.Mat_Id, m.Mat_Nombre ORDER BY app.FN_Temario_Texto(m.Mat_Nombre);
END
GO

-- Temas del temario de un horario (misma materia, grado, curso, semestre y año) para una semana:
-- "Plan de clases" los ofrece para llenar tema, objetivos y recursos.
CREATE OR ALTER PROCEDURE app.PR_tbTemarios_TemasDeHorario
    @Hor_Id int,
    @Semana int,
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Emp_Id int, @Supervisar bit, @Ver bit;
    SELECT @Emp_Id = Emp_Id, @Supervisar = Supervisar, @Ver = Ver FROM app.FN_Temario_Permisos(@Usu_Id);
    IF @Emp_Id IS NULL AND ISNULL(@Supervisar, 0) = 0 RETURN;

    SELECT TOP (20) x.Tet_Id, x.Tem_Id, t.Tem_Nombre, x.Tet_Semana, x.Tet_Orden, x.Tet_Titulo, x.Tet_Objetivos, x.Tet_Contenido, x.Tet_Recursos
    FROM app.tbHorarios h
    JOIN app.tbTemarios t
      ON t.Tem_EsEliminado = 0 AND t.Mat_Id = h.Mat_Id AND t.Cun_Id = h.Cun_Id AND t.Tem_Anio = h.Hor_Año
     AND t.Sem_Id = h.Sem_Id AND (t.Cur_Id IS NULL OR t.Cur_Id = h.Cur_Id)
    JOIN app.tbTemarioTemas x ON x.Tem_Id = t.Tem_Id AND x.Tet_EsEliminado = 0 AND x.Tet_Semana = @Semana
    WHERE h.Hor_Id = @Hor_Id
      AND ISNULL(h.Hor_EsEliminado, 0) = 0
      AND (@Supervisar = 1 OR h.Emp_Id = @Emp_Id OR (@Ver = 1 AND EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usu_Id) v WHERE v.Tem_Id = t.Tem_Id)))
    ORDER BY x.Tet_Orden, x.Tet_Id;
END
GO

/* ---------------------------------------------------------------- Escrituras */

-- Reglas comunes al crear un temario (también al copiarlo como uno nuevo). Lanza el error; no devuelve filas.
CREATE OR ALTER PROCEDURE app.PR_tbTemarios_Validar
    @Mat_Id          int,
    @Cun_Id          int,
    @Cur_Id          int,
    @Sem_Id          int,
    @Tem_Anio        int,
    @Tem_Nombre      nvarchar(150),
    @Tem_Descripcion nvarchar(max),
    @Tem_FechaInicio date,
    @Usuario         int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Emp_Id int, @Editar bit, @Supervisar bit;
    SELECT @Emp_Id = Emp_Id, @Editar = Editar, @Supervisar = Supervisar FROM app.FN_Temario_Permisos(@Usuario);

    IF ISNULL(@Editar, 0) = 0
        THROW 50040, N'No tiene permiso para crear temarios.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbMaterias WHERE Mat_Id = @Mat_Id AND ISNULL(Mat_EsEliminado, 0) = 0)
        THROW 50041, N'Elija la materia.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbCursosNiveles WHERE Cun_Id = @Cun_Id AND ISNULL(Cun_EsEliminado, 0) = 0)
        THROW 50042, N'Elija el grado.', 1;
    IF @Cur_Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM app.tbCursos c JOIN app.tbCursosNiveles cn ON cn.Cun_Id = @Cun_Id
                                           WHERE c.Cur_Id = @Cur_Id AND ISNULL(c.Cur_EsEliminado, 0) = 0 AND c.Niv_Id = cn.Niv_Id)
        THROW 50043, N'El curso elegido no es del nivel de ese grado.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbSemestres WHERE Sem_Id = @Sem_Id AND ISNULL(Sem_EsEliminado, 0) = 0)
        THROW 50044, N'Elija el semestre.', 1;
    IF @Tem_Anio IS NULL OR @Tem_Anio NOT BETWEEN 2000 AND 2100
        THROW 50045, N'Indique el año del temario.', 1;
    IF LTRIM(RTRIM(ISNULL(@Tem_Nombre, N''))) = N''
        THROW 50046, N'Escriba el nombre del temario.', 1;
    IF LEN(@Tem_Nombre) > 150
        THROW 50046, N'El nombre admite hasta 150 caracteres.', 1;
    IF LEN(@Tem_Descripcion) > 2000
        THROW 50047, N'La descripción admite hasta 2000 caracteres.', 1;
    IF @Tem_FechaInicio IS NULL
        THROW 50048, N'Indique cuándo empiezan las clases del semestre.', 1;
    IF YEAR(@Tem_FechaInicio) <> @Tem_Anio
        THROW 50048, N'El inicio de clases debe ser una fecha del mismo año del temario.', 1;
    IF @Supervisar = 0 AND app.FN_Temario_Imparte(@Emp_Id, @Mat_Id, @Cun_Id, @Cur_Id, @Tem_Anio) = 0
        THROW 50049, N'Solo puede crear temarios de las materias que imparte en ese grado.', 1;
    IF EXISTS (SELECT 1 FROM app.tbTemarios WITH (UPDLOCK, HOLDLOCK)
               WHERE Tem_EsEliminado = 0 AND Mat_Id = @Mat_Id AND Cun_Id = @Cun_Id AND Sem_Id = @Sem_Id AND Tem_Anio = @Tem_Anio
                 AND (Cur_Id IS NULL OR @Cur_Id IS NULL OR Cur_Id = @Cur_Id))
        THROW 50050, N'Ya existe un temario de esa materia para ese grado, semestre y año. Ábralo desde la biblioteca o cópielo a otro semestre.', 1;
END
GO

-- Crear un temario vacío. Devuelve su Id.
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

-- Cambiar nombre, descripción e inicio de clases (materia, grado, semestre y año no cambian).
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

-- Quitar un temario (borrado lógico; sus temas y avance quedan guardados pero ya no se ven).
CREATE OR ALTER PROCEDURE app.PR_tbTemarios_Eliminar
    @Tem_Id  int,
    @Usuario int
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usuario) WHERE Tem_Id = @Tem_Id AND PuedeEditar = 1)
        THROW 50051, N'No puede quitar este temario: solo los de las materias que imparte.', 1;

    UPDATE app.tbTemarios
    SET Tem_EsEliminado = 1, Tem_UsuarioModifica = @Usuario, Tem_FechaModifica = app.FN_AhoraHonduras()
    WHERE Tem_Id = @Tem_Id AND Tem_EsEliminado = 0;

    SELECT @Tem_Id AS Id, @Tem_Id AS Tem_Id, 0 AS Cantidad;
END
GO

-- Copiar los temas de un temario (la "biblioteca"): sin @Tem_IdDestino crea un temario nuevo de la misma
-- materia, grado y curso para otro semestre o año; con @Tem_IdDestino agrega los temas al final de ese
-- temario (misma materia). Devuelve el temario destino y cuántos temas se copiaron.
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

-- Agregar (@Tet_Id = 0) o editar un tema. Un tema nuevo, o que cambia de semana, queda al final de su semana.
CREATE OR ALTER PROCEDURE app.PR_tbTemarioTemas_Guardar
    @Tet_Id        int = 0,
    @Tem_Id        int,
    @Tet_Semana    int,
    @Tet_Titulo    nvarchar(200),
    @Tet_Objetivos nvarchar(max) = NULL,
    @Tet_Contenido nvarchar(max) = NULL,
    @Tet_Recursos  nvarchar(max) = NULL,
    @Usuario       int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Tet_Titulo = LTRIM(RTRIM(ISNULL(@Tet_Titulo, N'')));
    SET @Tet_Objetivos = NULLIF(LTRIM(RTRIM(@Tet_Objetivos)), N'');
    SET @Tet_Contenido = NULLIF(LTRIM(RTRIM(@Tet_Contenido)), N'');
    SET @Tet_Recursos = NULLIF(LTRIM(RTRIM(@Tet_Recursos)), N'');
    DECLARE @Ahora datetime2(0) = app.FN_AhoraHonduras(), @SemanaAntes int;

    IF ISNULL(@Tet_Id, 0) > 0
    BEGIN
        SELECT @Tem_Id = Tem_Id, @SemanaAntes = Tet_Semana FROM app.tbTemarioTemas WHERE Tet_Id = @Tet_Id AND Tet_EsEliminado = 0;
        IF @SemanaAntes IS NULL
            THROW 50056, N'Ese tema ya no existe: recargue la página.', 1;
    END
    IF NOT EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usuario) WHERE Tem_Id = @Tem_Id AND PuedeEditar = 1)
        THROW 50051, N'No puede editar este temario: solo los de las materias que imparte.', 1;
    IF @Tet_Semana IS NULL OR @Tet_Semana NOT BETWEEN 1 AND 30
        THROW 50057, N'La semana debe ser un número del 1 al 30.', 1;
    IF @Tet_Titulo = N''
        THROW 50058, N'Escriba el título del tema.', 1;
    IF LEN(@Tet_Titulo) > 200
        THROW 50058, N'El título admite hasta 200 caracteres.', 1;
    IF LEN(@Tet_Objetivos) > 2000
        THROW 50059, N'Los objetivos admiten hasta 2000 caracteres.', 1;
    IF LEN(@Tet_Contenido) > 4000
        THROW 50059, N'El contenido admite hasta 4000 caracteres.', 1;
    IF LEN(@Tet_Recursos) > 1000
        THROW 50059, N'Los recursos admiten hasta 1000 caracteres.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @Orden int = (SELECT ISNULL(MAX(Tet_Orden), 0) + 1 FROM app.tbTemarioTemas WITH (UPDLOCK, HOLDLOCK) WHERE Tem_Id = @Tem_Id);

        IF ISNULL(@Tet_Id, 0) = 0
        BEGIN
            IF (SELECT COUNT(*) FROM app.tbTemarioTemas WHERE Tem_Id = @Tem_Id AND Tet_EsEliminado = 0) >= 300
                THROW 50055, N'Un temario admite hasta 300 temas.', 1;
            INSERT INTO app.tbTemarioTemas (Tem_Id, Tet_Semana, Tet_Orden, Tet_Titulo, Tet_Objetivos, Tet_Contenido, Tet_Recursos,
                                            Tet_UsuarioRegistra, Tet_FechaRegistra)
            VALUES (@Tem_Id, @Tet_Semana, @Orden, @Tet_Titulo, @Tet_Objetivos, @Tet_Contenido, @Tet_Recursos, @Usuario, @Ahora);
            SET @Tet_Id = CAST(SCOPE_IDENTITY() AS int);
        END
        ELSE
            UPDATE app.tbTemarioTemas
            SET Tet_Semana = @Tet_Semana,
                Tet_Orden = CASE WHEN @Tet_Semana <> @SemanaAntes THEN @Orden ELSE Tet_Orden END,
                Tet_Titulo = @Tet_Titulo, Tet_Objetivos = @Tet_Objetivos, Tet_Contenido = @Tet_Contenido, Tet_Recursos = @Tet_Recursos,
                Tet_UsuarioModifica = @Usuario, Tet_FechaModifica = @Ahora
            WHERE Tet_Id = @Tet_Id;

        UPDATE app.tbTemarios SET Tem_UsuarioModifica = @Usuario, Tem_FechaModifica = @Ahora WHERE Tem_Id = @Tem_Id;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Tet_Id AS Id, @Tem_Id AS Tem_Id, 0 AS Cantidad;
END
GO

-- Subir o bajar un tema dentro de su semana (cambia el orden con el tema vecino).
CREATE OR ALTER PROCEDURE app.PR_tbTemarioTemas_Mover
    @Tet_Id    int,
    @Direccion varchar(6),
    @Usuario   int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Tem_Id int, @Semana int, @Orden int, @Vecino int, @OrdenVecino int;
    SELECT @Tem_Id = Tem_Id, @Semana = Tet_Semana, @Orden = Tet_Orden FROM app.tbTemarioTemas WHERE Tet_Id = @Tet_Id AND Tet_EsEliminado = 0;

    IF @Tem_Id IS NULL
        THROW 50056, N'Ese tema ya no existe: recargue la página.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usuario) WHERE Tem_Id = @Tem_Id AND PuedeEditar = 1)
        THROW 50051, N'No puede editar este temario: solo los de las materias que imparte.', 1;
    IF @Direccion NOT IN ('arriba', 'abajo')
        THROW 50060, N'Indique si el tema sube o baja.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Direccion = 'arriba'
            SELECT TOP (1) @Vecino = Tet_Id, @OrdenVecino = Tet_Orden FROM app.tbTemarioTemas WITH (UPDLOCK)
            WHERE Tem_Id = @Tem_Id AND Tet_Semana = @Semana AND Tet_EsEliminado = 0 AND Tet_Orden < @Orden
            ORDER BY Tet_Orden DESC;
        ELSE
            SELECT TOP (1) @Vecino = Tet_Id, @OrdenVecino = Tet_Orden FROM app.tbTemarioTemas WITH (UPDLOCK)
            WHERE Tem_Id = @Tem_Id AND Tet_Semana = @Semana AND Tet_EsEliminado = 0 AND Tet_Orden > @Orden
            ORDER BY Tet_Orden;

        IF @Vecino IS NOT NULL
        BEGIN
            UPDATE app.tbTemarioTemas SET Tet_Orden = @OrdenVecino, Tet_UsuarioModifica = @Usuario, Tet_FechaModifica = app.FN_AhoraHonduras() WHERE Tet_Id = @Tet_Id;
            UPDATE app.tbTemarioTemas SET Tet_Orden = @Orden WHERE Tet_Id = @Vecino;
        END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Tet_Id AS Id, @Tem_Id AS Tem_Id, CASE WHEN @Vecino IS NULL THEN 0 ELSE 1 END AS Cantidad;
END
GO

-- Quitar un tema (borrado lógico). Cantidad = marcas de avance que dejan de contarse.
CREATE OR ALTER PROCEDURE app.PR_tbTemarioTemas_Quitar
    @Tet_Id  int,
    @Usuario int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Tem_Id int = (SELECT Tem_Id FROM app.tbTemarioTemas WHERE Tet_Id = @Tet_Id AND Tet_EsEliminado = 0);
    IF @Tem_Id IS NULL
        THROW 50056, N'Ese tema ya no existe: recargue la página.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usuario) WHERE Tem_Id = @Tem_Id AND PuedeEditar = 1)
        THROW 50051, N'No puede editar este temario: solo los de las materias que imparte.', 1;

    UPDATE app.tbTemarioTemas
    SET Tet_EsEliminado = 1, Tet_UsuarioModifica = @Usuario, Tet_FechaModifica = app.FN_AhoraHonduras()
    WHERE Tet_Id = @Tet_Id;

    SELECT @Tet_Id AS Id, @Tem_Id AS Tem_Id, (SELECT COUNT(*) FROM app.tbTemarioAvance WHERE Tet_Id = @Tet_Id) AS Cantidad;
END
GO

-- Marcar el avance de un tema en una sección: dado / parcial (con la fecha en que se dio) u omitido.
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
    SELECT @Tem_Id = t.Tem_Id, @Inicio = t.Tem_FechaInicio, @Anio = t.Tem_Anio
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

-- Quitar la marca de avance de un tema en una sección.
CREATE OR ALTER PROCEDURE app.PR_tbTemarioAvance_Quitar
    @Tet_Id  int,
    @Cur_Id  int,
    @Sec_Id  int,
    @Mda_Id  int,
    @Usuario int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Tem_Id int = (SELECT x.Tem_Id FROM app.tbTemarioTemas x JOIN app.tbTemarios t ON t.Tem_Id = x.Tem_Id AND t.Tem_EsEliminado = 0
                           WHERE x.Tet_Id = @Tet_Id AND x.Tet_EsEliminado = 0);
    IF @Tem_Id IS NULL OR NOT EXISTS (SELECT 1 FROM app.FN_Temarios_Visibles(@Usuario) WHERE Tem_Id = @Tem_Id)
        THROW 50061, N'Ese tema ya no existe o no tiene acceso a su temario.', 1;
    IF app.FN_Temario_PuedeMarcar(@Usuario, @Tem_Id, @Cur_Id, @Sec_Id, @Mda_Id) = 0
        THROW 50063, N'Solo puede marcar el avance de las secciones a las que da esta materia.', 1;

    DELETE FROM app.tbTemarioAvance WHERE Tet_Id = @Tet_Id AND Cur_Id = @Cur_Id AND Sec_Id = @Sec_Id AND Mda_Id = @Mda_Id;
    DECLARE @Quitadas int = @@ROWCOUNT;

    SELECT @Tet_Id AS Id, @Tem_Id AS Tem_Id, @Quitadas AS Cantidad;
END
GO

/* ---------------------------------------------------------------- Pantallas y permisos */
--   Temario y avance     = biblioteca, temario y avance (admin, director, Docente). El docente ve los
--                          temarios de las materias que imparte y marca el avance de SUS secciones.
--   Editar temarios      = crear, editar, copiar, temas (admin, director, Docente; el docente solo los suyos)
--   Supervisar temarios  = ver y editar todos, marcar cualquier sección y el resumen de Dirección (admin, director)
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES
    (N'Temario y avance',    N'|admin|director|docente|'),
    (N'Editar temarios',     N'|admin|director|docente|'),
    (N'Supervisar temarios', N'|admin|director|');

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
