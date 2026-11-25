/* =============================================================================
   089 - Notas ponderadas: plantillas de evaluación y actividades del cuaderno de notas
   (espejo de RosarioSIS "Assignment Types / Percent of Final Grade" y de Skuul "assessment
   templates" + "grade categories / items / entries").

   - Plantilla de evaluación (Dirección): tipos de evaluación (Examen, Tareas, Trabajos...) con su
     peso en % (suman 100) y cómo se juntan las actividades de cada tipo (suma de puntos, promedio o
     la mejor). Alcance: año + nivel (NULL = todos) + materia (NULL = todas). La del año sin nivel ni
     materia es la plantilla por defecto. Se aplica la más específica:
     materia y nivel > materia > nivel > por defecto.
   - Cuaderno de evaluación = sección x materia x semestre x parcial x año (mismo grupo que el
     cuaderno de notas del script 076). Se crea con la primera actividad y COPIA los tipos de la
     plantilla (como Skuul al aplicar una plantilla). Al guardar una plantilla, la copia se actualiza
     en los cuadernos de parciales ABIERTOS; los de parciales cerrados conservan sus pesos.
   - Actividad: nombre, tipo, puntos máximos, fecha, descripción y "no cuenta" (práctica).
   - Puntos por alumno: estado calificado (con puntos), no_entrego (cuenta 0), excusado (no cuenta)
     o vacio (sin calificar: no cuenta todavía). Vacío nunca es cero.
   - Cálculo (FN_Evaluacion_Calculo): por tipo, la parte lograda (puntos / máximo) según su forma de
     juntar; la nota = suma(parte x peso) / suma(pesos de los tipos con algo calificado) x 100.
     La nota entera (2 decimales con ,5 hacia arriba y luego el entero) se escribe en app.tbNotas DENTRO de la
     misma transacción que cambió puntos, actividades o pesos (app.PR_Evaluacion_EscribirNotas, mismas columnas
     que app.PR_tbNotas_Insert): boletín, constancias y cierre de parciales siguen igual.
   - Concurrencia: candado compartido para escribir cuadernos y exclusivo para guardar plantillas
     (app.PR_Evaluacion_Candado), y luego el cuaderno con UPDLOCK: dos pestañas no se pisan y el recálculo
     por cambio de pesos no se cruza con un docente que guarda.
   - Parcial cerrado (script 075): toda escritura llama a app.PR_CierresParcial_ValidarAbierto dentro
     de su transacción (THROW 50070).
   - Control de versión: plantilla, actividad y cada calificación llevan versión; si otra persona
     cambió lo mismo, no se guarda nada y se pide recargar.
   - Alcance: el docente solo trabaja en los grupos de su horario (app.tbHorarios); permisos
     "Cuaderno de notas" (admin, director, Docente) y "Plantillas de evaluación" (admin, director).
   - Prefijos: Ple_ (plantilla), Plt_ (tipo de plantilla), Cev_ (cuaderno), Cet_ (tipo del cuaderno),
     Act_ (actividad), Acp_ (puntos). Errores 50090-50099 (más 50070-50073 de los scripts 075/076).
   No cambia ningún procedimiento existente. Idempotente: se puede correr varias veces.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ───────────────────────────── Tablas ───────────────────────────── */

IF OBJECT_ID(N'app.tbPlantillasEvaluacion', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbPlantillasEvaluacion (
        Ple_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbPlantillasEvaluacion PRIMARY KEY,
        Ple_Anio            int           NOT NULL,
        Niv_Id              int           NULL CONSTRAINT FK_tbPlantillasEvaluacion_Niveles REFERENCES app.tbNivelesEducativos (Niv_Id),
        Mat_Id              int           NULL CONSTRAINT FK_tbPlantillasEvaluacion_Materias REFERENCES app.tbMaterias (Mat_Id),
        Ple_Nombre          nvarchar(100) NOT NULL,
        Ple_Descripcion     nvarchar(500) NULL,
        Ple_Version         int           NOT NULL CONSTRAINT DF_tbPlantillasEvaluacion_Version DEFAULT (1),
        Ple_EsEliminado     bit           NOT NULL CONSTRAINT DF_tbPlantillasEvaluacion_EsEliminado DEFAULT (0),
        Ple_UsuarioRegistra int           NOT NULL,
        Ple_FechaRegistra   datetime      NOT NULL,
        Ple_UsuarioModifica int           NULL,
        Ple_FechaModifica   datetime      NULL
    );
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_tbPlantillasEvaluacion_Alcance' AND object_id = OBJECT_ID(N'app.tbPlantillasEvaluacion'))
    CREATE UNIQUE INDEX UX_tbPlantillasEvaluacion_Alcance ON app.tbPlantillasEvaluacion (Ple_Anio, Niv_Id, Mat_Id) WHERE Ple_EsEliminado = 0;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_tbPlantillasEvaluacion_Nombre' AND object_id = OBJECT_ID(N'app.tbPlantillasEvaluacion'))
    CREATE UNIQUE INDEX UX_tbPlantillasEvaluacion_Nombre ON app.tbPlantillasEvaluacion (Ple_Anio, Ple_Nombre) WHERE Ple_EsEliminado = 0;
GO

IF OBJECT_ID(N'app.tbPlantillasEvaluacionTipos', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbPlantillasEvaluacionTipos (
        Plt_Id          int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbPlantillasEvaluacionTipos PRIMARY KEY,
        Ple_Id          int          NOT NULL CONSTRAINT FK_tbPlantillasEvaluacionTipos_Plantilla REFERENCES app.tbPlantillasEvaluacion (Ple_Id),
        Plt_Nombre      nvarchar(60) NOT NULL,
        Plt_Peso        decimal(5,2) NOT NULL CONSTRAINT CK_tbPlantillasEvaluacionTipos_Peso CHECK (Plt_Peso > 0 AND Plt_Peso <= 100),
        Plt_Combinacion varchar(10)  NOT NULL CONSTRAINT DF_tbPlantillasEvaluacionTipos_Comb DEFAULT ('suma')
                        CONSTRAINT CK_tbPlantillasEvaluacionTipos_Comb CHECK (Plt_Combinacion IN ('suma', 'promedio', 'mejor')),
        Plt_Orden       smallint     NOT NULL CONSTRAINT DF_tbPlantillasEvaluacionTipos_Orden DEFAULT (1),
        Plt_EsEliminado bit          NOT NULL CONSTRAINT DF_tbPlantillasEvaluacionTipos_EsEliminado DEFAULT (0)
    );
    CREATE INDEX IX_tbPlantillasEvaluacionTipos_Plantilla ON app.tbPlantillasEvaluacionTipos (Ple_Id, Plt_EsEliminado);
END
GO

IF OBJECT_ID(N'app.tbCuadernosEvaluacion', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbCuadernosEvaluacion (
        Cev_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbCuadernosEvaluacion PRIMARY KEY,
        Cev_Anio            int      NOT NULL,
        Sem_Id              int      NOT NULL,
        Pac_Id              int      NOT NULL,
        Sec_Id              int      NOT NULL,
        Mat_Id              int      NOT NULL,
        Cur_Id              int      NOT NULL,
        Cun_Id              int      NOT NULL,
        Ple_Id              int      NOT NULL CONSTRAINT FK_tbCuadernosEvaluacion_Plantilla REFERENCES app.tbPlantillasEvaluacion (Ple_Id),
        Cev_Version         int      NOT NULL CONSTRAINT DF_tbCuadernosEvaluacion_Version DEFAULT (1),
        Cev_UsuarioRegistra int      NOT NULL,
        Cev_FechaRegistra   datetime NOT NULL,
        Cev_UsuarioModifica int      NULL,
        Cev_FechaModifica   datetime NULL
    );
    CREATE UNIQUE INDEX UX_tbCuadernosEvaluacion_Grupo ON app.tbCuadernosEvaluacion (Cev_Anio, Sem_Id, Pac_Id, Sec_Id, Mat_Id, Cur_Id, Cun_Id);
    CREATE INDEX IX_tbCuadernosEvaluacion_Plantilla ON app.tbCuadernosEvaluacion (Ple_Id);
END
GO

IF OBJECT_ID(N'app.tbCuadernosEvaluacionTipos', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbCuadernosEvaluacionTipos (
        Cet_Id          int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbCuadernosEvaluacionTipos PRIMARY KEY,
        Cev_Id          int          NOT NULL CONSTRAINT FK_tbCuadernosEvaluacionTipos_Cuaderno REFERENCES app.tbCuadernosEvaluacion (Cev_Id),
        Plt_Id          int          NULL CONSTRAINT FK_tbCuadernosEvaluacionTipos_Tipo REFERENCES app.tbPlantillasEvaluacionTipos (Plt_Id),
        Cet_Nombre      nvarchar(60) NOT NULL,
        Cet_Peso        decimal(5,2) NOT NULL,
        Cet_Combinacion varchar(10)  NOT NULL,
        Cet_Orden       smallint     NOT NULL,
        Cet_EsEliminado bit          NOT NULL CONSTRAINT DF_tbCuadernosEvaluacionTipos_EsEliminado DEFAULT (0)
    );
    CREATE INDEX IX_tbCuadernosEvaluacionTipos_Cuaderno ON app.tbCuadernosEvaluacionTipos (Cev_Id, Cet_EsEliminado);
END
GO

IF OBJECT_ID(N'app.tbActividadesEvaluacion', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbActividadesEvaluacion (
        Act_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbActividadesEvaluacion PRIMARY KEY,
        Cev_Id              int           NOT NULL CONSTRAINT FK_tbActividadesEvaluacion_Cuaderno REFERENCES app.tbCuadernosEvaluacion (Cev_Id),
        Cet_Id              int           NOT NULL CONSTRAINT FK_tbActividadesEvaluacion_Tipo REFERENCES app.tbCuadernosEvaluacionTipos (Cet_Id),
        Act_Nombre          nvarchar(150) NOT NULL,
        Act_Descripcion     nvarchar(500) NULL,
        Act_PuntosMax       decimal(7,2)  NOT NULL CONSTRAINT CK_tbActividadesEvaluacion_Max CHECK (Act_PuntosMax > 0),
        Act_Fecha           date          NULL,
        Act_NoCuenta        bit           NOT NULL CONSTRAINT DF_tbActividadesEvaluacion_NoCuenta DEFAULT (0),
        Act_Orden           int           NOT NULL CONSTRAINT DF_tbActividadesEvaluacion_Orden DEFAULT (1),
        Act_Version         int           NOT NULL CONSTRAINT DF_tbActividadesEvaluacion_Version DEFAULT (1),
        Act_EsEliminado     bit           NOT NULL CONSTRAINT DF_tbActividadesEvaluacion_EsEliminado DEFAULT (0),
        Act_UsuarioRegistra int           NOT NULL,
        Act_FechaRegistra   datetime      NOT NULL,
        Act_UsuarioModifica int           NULL,
        Act_FechaModifica   datetime      NULL
    );
    CREATE INDEX IX_tbActividadesEvaluacion_Cuaderno ON app.tbActividadesEvaluacion (Cev_Id, Act_EsEliminado);
END
GO

IF OBJECT_ID(N'app.tbActividadesPuntos', N'U') IS NULL
BEGIN
    CREATE TABLE app.tbActividadesPuntos (
        Acp_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbActividadesPuntos PRIMARY KEY,
        Act_Id              int          NOT NULL CONSTRAINT FK_tbActividadesPuntos_Actividad REFERENCES app.tbActividadesEvaluacion (Act_Id),
        Alu_Id              int          NOT NULL CONSTRAINT FK_tbActividadesPuntos_Alumno REFERENCES app.tbAlumnos (Alu_Id),
        Acp_Estado          varchar(12)  NOT NULL CONSTRAINT CK_tbActividadesPuntos_Estado CHECK (Acp_Estado IN ('calificado', 'no_entrego', 'excusado', 'vacio')),
        Acp_Puntos          decimal(7,2) NULL,
        Acp_Version         int          NOT NULL CONSTRAINT DF_tbActividadesPuntos_Version DEFAULT (1),
        Acp_UsuarioRegistra int          NOT NULL,
        Acp_FechaRegistra   datetime     NOT NULL,
        Acp_UsuarioModifica int          NULL,
        Acp_FechaModifica   datetime     NULL,
        CONSTRAINT CK_tbActividadesPuntos_Puntos CHECK ((Acp_Estado = 'calificado' AND Acp_Puntos IS NOT NULL AND Acp_Puntos >= 0)
                                                    OR (Acp_Estado <> 'calificado' AND Acp_Puntos IS NULL))
    );
    CREATE UNIQUE INDEX UX_tbActividadesPuntos_ActividadAlumno ON app.tbActividadesPuntos (Act_Id, Alu_Id);
END
GO

/* ───────────────────────────── Funciones ───────────────────────────── */

-- Permisos del usuario (admin pasa todo) y su empleado si es docente (NULL = sin restricción de horario).
-- Sin fila si el usuario no existe, está inactivo o suspendido.
CREATE OR ALTER FUNCTION app.FN_Evaluacion_Permisos (@Usu_Id int)
RETURNS TABLE
AS
RETURN
    SELECT u.Usu_Id,
           app.FN_Cuaderno_EmpDocente(u.Usu_Id) AS EmpDocente,
           CAST(CASE WHEN a.EsAdmin = 1 OR EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas rp JOIN seguridad.tbPantallas p ON p.Pan_Id = rp.Pan_Id
                                                   WHERE rp.Rol_Id = u.Rol_Id AND p.Pan_Descripcion = N'Cuaderno de notas' AND ISNULL(p.Pan_EsEliminado, 0) = 0)
                     THEN 1 ELSE 0 END AS bit) AS Cuaderno,
           CAST(CASE WHEN a.EsAdmin = 1 OR EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas rp JOIN seguridad.tbPantallas p ON p.Pan_Id = rp.Pan_Id
                                                   WHERE rp.Rol_Id = u.Rol_Id AND p.Pan_Descripcion = N'Plantillas de evaluación' AND ISNULL(p.Pan_EsEliminado, 0) = 0)
                     THEN 1 ELSE 0 END AS bit) AS Plantillas
    FROM seguridad.tbUsuarios u
    JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
    CROSS APPLY (SELECT CAST(CASE WHEN LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) = 'admin' THEN 1 ELSE 0 END AS bit) AS EsAdmin) a
    WHERE u.Usu_Id = @Usu_Id
      AND ISNULL(u.Usu_EsEliminado, 0) = 0
      AND ISNULL(u.Usu_EsActivo, 1) = 1
      AND ISNULL(u.Usu_Suspendido, 0) = 0;
GO

-- Grupo del horario (año, semestre, sección, materia, curso, grado, nivel y docente).
CREATE OR ALTER FUNCTION app.FN_Evaluacion_Horario (@Hor_Id int)
RETURNS TABLE
AS
RETURN
    SELECT h.Hor_Id, h.Hor_Año AS Anio, h.Sem_Id, h.Sec_Id, h.Mat_Id, h.Cur_Id, h.Cun_Id, h.Emp_Id,
           COALESCE(c.Niv_Id, cn.Niv_Id) AS Niv_Id
    FROM app.tbHorarios h
    LEFT JOIN app.tbCursos c        ON c.Cur_Id = h.Cur_Id
    LEFT JOIN app.tbCursosNiveles cn ON cn.Cun_Id = h.Cun_Id
    WHERE h.Hor_Id = @Hor_Id AND ISNULL(h.Hor_EsEliminado, 0) = 0;
GO

-- ¿El usuario puede trabajar en el grupo? Un docente (@Emp no NULL) solo si el grupo está en su horario.
CREATE OR ALTER FUNCTION app.FN_Evaluacion_PuedeGrupo (@Emp int, @Anio int, @Sem_Id int, @Sec_Id int, @Mat_Id int, @Cur_Id int, @Cun_Id int)
RETURNS bit
AS
BEGIN
    IF @Emp IS NULL RETURN 1;
    RETURN CASE WHEN EXISTS (SELECT 1 FROM app.tbHorarios h
                             WHERE h.Hor_Año = @Anio AND h.Sem_Id = @Sem_Id AND h.Sec_Id = @Sec_Id AND h.Mat_Id = @Mat_Id
                               AND h.Cur_Id = @Cur_Id AND h.Cun_Id = @Cun_Id AND h.Emp_Id = @Emp
                               AND ISNULL(h.Hor_EsEliminado, 0) = 0)
                THEN 1 ELSE 0 END;
END
GO

-- ¿El parcial está cerrado en Cierre de parciales (script 075)? Sin fila = abierto.
CREATE OR ALTER FUNCTION app.FN_Evaluacion_Cerrado (@Anio int, @Sem_Id int, @Pac_Id int)
RETURNS bit
AS
BEGIN
    RETURN CASE WHEN EXISTS (SELECT 1 FROM app.tbCierresParcial
                             WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem_Id AND Pac_Id = @Pac_Id AND Cpa_Estado = 'cerrado')
                THEN 1 ELSE 0 END;
END
GO

-- Plantilla que corresponde: la más específica del año (materia y nivel > materia > nivel > por defecto).
CREATE OR ALTER FUNCTION app.FN_Evaluacion_PlantillaDe (@Anio int, @Niv_Id int, @Mat_Id int)
RETURNS int
AS
BEGIN
    RETURN (SELECT TOP (1) Ple_Id
            FROM app.tbPlantillasEvaluacion
            WHERE Ple_EsEliminado = 0 AND Ple_Anio = @Anio
              AND (Niv_Id IS NULL OR Niv_Id = @Niv_Id)
              AND (Mat_Id IS NULL OR Mat_Id = @Mat_Id)
            ORDER BY CASE WHEN Mat_Id IS NULL THEN 0 ELSE 2 END + CASE WHEN Niv_Id IS NULL THEN 0 ELSE 1 END DESC);
END
GO

-- Alcance de una plantilla en palabras ("Todos los niveles · Todas las materias").
CREATE OR ALTER FUNCTION app.FN_Evaluacion_Alcance (@Niv_Id int, @Mat_Id int)
RETURNS nvarchar(300)
AS
BEGIN
    RETURN CONCAT(ISNULL((SELECT LTRIM(RTRIM(Niv_Descripcion)) FROM app.tbNivelesEducativos WHERE Niv_Id = @Niv_Id), N'Todos los niveles'),
                  N' · ',
                  ISNULL((SELECT LTRIM(RTRIM(Mat_Nombre)) FROM app.tbMaterias WHERE Mat_Id = @Mat_Id), N'Todas las materias'));
END
GO

-- Alumnos activos del grupo (mismo criterio que app.PR_tbNotas_List del script 076).
CREATE OR ALTER FUNCTION app.FN_Evaluacion_Alumnos (@Anio int, @Sec_Id int, @Cur_Id int, @Cun_Id int)
RETURNS TABLE
AS
RETURN
    SELECT a.Alu_Id,
           CONCAT(LTRIM(RTRIM(CONCAT(LTRIM(RTRIM(p.Per_ApellidoPaterno)), ' ', LTRIM(RTRIM(ISNULL(p.Per_ApellidoMaterno, '')))))), ', ',
                  LTRIM(RTRIM(CONCAT(LTRIM(RTRIM(p.Per_PrimerNombre)), ' ', LTRIM(RTRIM(ISNULL(p.Per_SegundoNombre, ''))))))) AS Nombre,
           p.Per_ApellidoPaterno AS Apellido, p.Per_PrimerNombre AS PrimerNombre
    FROM app.tbAlumnos a
    JOIN app.tbPersonas p ON p.Per_Id = a.Per_Id
    WHERE a.Sec_Id = @Sec_Id AND a.Cur_Id = @Cur_Id AND a.Cun_Id = @Cun_Id
      AND a.AnioCursado = @Anio AND a.Est_Id = 1 AND p.Per_EsEliminado = 0;
GO

/* Nota calculada de cada alumno del cuaderno.
   - Cuentan las actividades no quitadas y que cuentan para la nota; de cada alumno, sus celdas
     calificadas (puntos) y "no entregó" (0). Excusado y vacío no cuentan.
   - Por tipo: suma = puntos / máximo sumados (RosarioSIS); promedio = promedio de cada actividad;
     mejor = la mejor actividad (Skuul "highest").
   - Los tipos sin nada calificado para ese alumno (o todo excusado) no entran: su peso se reparte
     entre los que sí (RosarioSIS: total / suma de los pesos de los tipos con algo). Sin nada = NULL.
   - Redondeo (el mismo en cuaderno-actividades.js, para que la nota en vivo sea la guardada):
     se calcula en float (IEEE 754, igual que JavaScript), se redondea a 2 decimales con ,5 hacia
     arriba (Nota, la que se ve) y el entero sale de esa Nota: ,50 o más sube (Entera, la del boletín).
     El 0.000001 absorbe el error de punto flotante (1/3 x 30 = 9,9999999...) y nunca cambia un
     valor que no esté pegado al límite. */
CREATE OR ALTER FUNCTION app.FN_Evaluacion_Calculo (@Cev_Id int)
RETURNS TABLE
AS
RETURN
    WITH celdas AS (
        SELECT p.Alu_Id, a.Cet_Id,
               CAST(a.Act_PuntosMax AS float) AS Maximo,
               CAST(CASE WHEN p.Acp_Estado = 'calificado' THEN p.Acp_Puntos ELSE 0 END AS float) AS Puntos
        FROM app.tbActividadesEvaluacion a
        JOIN app.tbActividadesPuntos p ON p.Act_Id = a.Act_Id
        WHERE a.Cev_Id = @Cev_Id AND a.Act_EsEliminado = 0 AND a.Act_NoCuenta = 0
          AND p.Acp_Estado IN ('calificado', 'no_entrego')
    ),
    porTipo AS (
        SELECT c.Alu_Id, CAST(t.Cet_Peso AS float) AS Peso,
               CASE t.Cet_Combinacion
                    WHEN 'promedio' THEN AVG(c.Puntos / c.Maximo)
                    WHEN 'mejor'    THEN MAX(c.Puntos / c.Maximo)
                    ELSE SUM(c.Puntos) / SUM(c.Maximo) END AS Parte
        FROM celdas c
        JOIN app.tbCuadernosEvaluacionTipos t ON t.Cet_Id = c.Cet_Id AND t.Cet_EsEliminado = 0
        GROUP BY c.Alu_Id, t.Cet_Id, t.Cet_Peso, t.Cet_Combinacion
    ),
    total AS (
        SELECT Alu_Id, SUM(Parte * Peso) / NULLIF(SUM(Peso), 0) * 100 AS Valor
        FROM porTipo
        GROUP BY Alu_Id
    ),
    centesimos AS (
        SELECT Alu_Id, CAST(FLOOR(Valor * 100 + 0.5 + 0.000001) AS int) AS Cent
        FROM total
        WHERE Valor IS NOT NULL
    )
    SELECT Alu_Id, CAST(Cent / 100.0 AS decimal(6,2)) AS Nota, (Cent + 50) / 100 AS Entera
    FROM centesimos;
GO

/* Escribe en app.tbNotas la nota entera calculada del cuaderno (solo las que cambiaron). Se llama DENTRO de
   la transacción de quien cambió puntos, actividades o pesos, después de cambiarlos: la nota del parcial
   queda igual al cálculo en el mismo COMMIT (sin carreras entre dos pestañas ni con el recálculo de una
   plantilla). Mismas columnas que app.PR_tbNotas_Insert (aula del horario, Not_Año = 1 de enero del año);
   si el alumno tiene más de una fila de nota en ese parcial, todas quedan con el mismo valor. No toca
   parciales cerrados ni otros años (el cuaderno es de un año y solo cuenta alumnos activos de ese año).
   Quien llama ya revisó permisos y alcance. */
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_EscribirNotas
    @Cev_Id   int,
    @Usuario  int,
    @Escritas int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Escritas = 0;
    DECLARE @Anio int, @Sem int, @Pac int, @Sec int, @Mat int, @Cur int, @Cun int, @Aul int;
    SELECT @Anio = Cev_Anio, @Sem = Sem_Id, @Pac = Pac_Id, @Sec = Sec_Id, @Mat = Mat_Id, @Cur = Cur_Id, @Cun = Cun_Id
    FROM app.tbCuadernosEvaluacion WHERE Cev_Id = @Cev_Id;
    IF @Anio IS NULL OR app.FN_Evaluacion_Cerrado(@Anio, @Sem, @Pac) = 1 RETURN;

    SELECT @Aul = (SELECT TOP (1) h.Aul_Id FROM app.tbHorarios h
                   WHERE h.Hor_Año = @Anio AND h.Sem_Id = @Sem AND h.Sec_Id = @Sec AND h.Mat_Id = @Mat
                     AND h.Cur_Id = @Cur AND h.Cun_Id = @Cun AND ISNULL(h.Hor_EsEliminado, 0) = 0
                   ORDER BY h.Hor_Id);

    DECLARE @Calc TABLE (Alu_Id int PRIMARY KEY, Entera int NOT NULL);
    INSERT INTO @Calc (Alu_Id, Entera)
    SELECT k.Alu_Id, k.Entera
    FROM app.FN_Evaluacion_Calculo(@Cev_Id) k
    JOIN app.FN_Evaluacion_Alumnos(@Anio, @Sec, @Cur, @Cun) al ON al.Alu_Id = k.Alu_Id
    WHERE k.Entera BETWEEN 0 AND 100;

    DECLARE @Ahora datetime = GETDATE();
    DECLARE @Cambiadas TABLE (Alu_Id int);
    UPDATE n
    SET Not_Nota = c.Entera, Not_UsuarioModifica = @Usuario, Not_FechaModifica = @Ahora
    OUTPUT inserted.Alu_Id INTO @Cambiadas (Alu_Id)
    FROM app.tbNotas n WITH (UPDLOCK, HOLDLOCK)
    JOIN @Calc c ON c.Alu_Id = n.Alu_Id
    WHERE n.Sec_Id = @Sec AND n.Mat_Id = @Mat AND n.Pac_Id = @Pac AND n.Sem_Id = @Sem
      AND YEAR(n.Not_Año) = @Anio AND n.Not_EsEliminado = 0
      AND (n.Not_Nota IS NULL OR n.Not_Nota <> c.Entera);

    INSERT INTO app.tbNotas (Alu_Id, Aul_Id, Sec_Id, Mat_Id, Sem_Id, Pac_Id, Not_Nota, Not_Año, Not_EsActivo, Not_EsEliminado,
                             Not_UsuarioRegistra, Not_FechaRegistra)
    OUTPUT inserted.Alu_Id INTO @Cambiadas (Alu_Id)
    SELECT c.Alu_Id, @Aul, @Sec, @Mat, @Sem, @Pac, c.Entera, DATEFROMPARTS(@Anio, 1, 1), 1, 0, @Usuario, @Ahora
    FROM @Calc c
    WHERE NOT EXISTS (SELECT 1 FROM app.tbNotas n WITH (UPDLOCK, HOLDLOCK)
                      WHERE n.Alu_Id = c.Alu_Id AND n.Sec_Id = @Sec AND n.Mat_Id = @Mat AND n.Pac_Id = @Pac
                        AND n.Sem_Id = @Sem AND YEAR(n.Not_Año) = @Anio AND n.Not_EsEliminado = 0);

    SET @Escritas = (SELECT COUNT(DISTINCT Alu_Id) FROM @Cambiadas);
END
GO

/* Candado de las notas ponderadas: toda escritura de cuadernos lo toma compartido (varias a la vez) y
   guardar o quitar una plantilla, exclusivo (espera a que terminen y frena las nuevas mientras recalcula).
   Va primero en la transacción, antes de cualquier otro candado: así no hay bloqueos cruzados. */
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_Candado
    @Exclusivo bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Modo nvarchar(32) = CASE WHEN @Exclusivo = 1 THEN N'Exclusive' ELSE N'Shared' END, @R int;
    EXEC @R = sp_getapplock @Resource = N'app.NotasPonderadas', @LockMode = @Modo, @LockOwner = N'Transaction', @LockTimeout = 20000;
    IF @R < 0
        THROW 50099, N'El cuaderno está ocupado con otro cambio (por ejemplo, Dirección está cambiando los pesos). Intente de nuevo en unos segundos.', 1;
END
GO

/* ───────────────────────────── Lecturas ───────────────────────────── */

/* Todo lo del cuaderno de un horario y parcial, en un JSON:
   grupo, estado del parcial, plantilla (la del cuaderno o la que tocaría), tipos con peso, actividades,
   alumnos con su nota del parcial (app.tbNotas) y la calculada, puntos y otras secciones del docente. */
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_Cuaderno
    @Hor_Id int,
    @Pac_Id int,
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Puede bit, @Emp int;
    SELECT @Puede = Cuaderno, @Emp = EmpDocente FROM app.FN_Evaluacion_Permisos(@Usu_Id);
    IF ISNULL(@Puede, 0) = 0
        THROW 50090, N'No tiene permiso para usar el cuaderno de notas.', 1;

    DECLARE @Anio int, @Sem int, @Sec int, @Mat int, @Cur int, @Cun int, @Niv int, @EmpH int;
    SELECT @Anio = Anio, @Sem = Sem_Id, @Sec = Sec_Id, @Mat = Mat_Id, @Cur = Cur_Id, @Cun = Cun_Id, @Niv = Niv_Id, @EmpH = Emp_Id
    FROM app.FN_Evaluacion_Horario(@Hor_Id);
    IF @Anio IS NULL
        THROW 50071, N'El horario seleccionado no existe.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbParciales WHERE Pac_Id = @Pac_Id AND ISNULL(Pac_EsEliminado, 0) = 0)
        THROW 50091, N'Elija un parcial válido.', 1;
    IF app.FN_Evaluacion_PuedeGrupo(@Emp, @Anio, @Sem, @Sec, @Mat, @Cur, @Cun) = 0
        THROW 50072, N'Ese horario no está asignado a su usuario.', 1;

    DECLARE @Cev int, @Version int, @Ple int, @Vigente int = app.FN_Evaluacion_PlantillaDe(@Anio, @Niv, @Mat);
    SELECT @Cev = Cev_Id, @Version = Cev_Version, @Ple = Ple_Id
    FROM app.tbCuadernosEvaluacion
    WHERE Cev_Anio = @Anio AND Sem_Id = @Sem AND Pac_Id = @Pac_Id AND Sec_Id = @Sec AND Mat_Id = @Mat AND Cur_Id = @Cur AND Cun_Id = @Cun;
    IF @Ple IS NULL SET @Ple = @Vigente;

    DECLARE @Cerrado bit = app.FN_Evaluacion_Cerrado(@Anio, @Sem, @Pac_Id);
    DECLARE @Mensaje nvarchar(400) = CASE WHEN @Cerrado = 1 THEN CONCAT(
            N'El ', LOWER(app.FN_CierresParcial_NombreParcial(@Pac_Id)),
            N' del ', LOWER(app.FN_CierresParcial_NombreSemestre(@Sem)), N' de ', @Anio,
            N' está cerrado: ya no se pueden registrar, cambiar ni quitar notas. ',
            N'Si hace falta una corrección, pida a Dirección que lo reabra.') END;

    DECLARE @Alumnos TABLE (Alu_Id int PRIMARY KEY, Nombre nvarchar(400), Apellido nvarchar(200), PrimerNombre nvarchar(200));
    INSERT INTO @Alumnos SELECT Alu_Id, Nombre, Apellido, PrimerNombre FROM app.FN_Evaluacion_Alumnos(@Anio, @Sec, @Cur, @Cun);

    DECLARE @Json nvarchar(max) = (
        SELECT @Hor_Id AS Hor_Id, @Anio AS Anio, @Sem AS Sem_Id, @Pac_Id AS Pac_Id,
               @Sec AS Sec_Id, @Mat AS Mat_Id, @Cur AS Cur_Id, @Cun AS Cun_Id, @Niv AS Niv_Id,
               LTRIM(RTRIM((SELECT Mat_Nombre FROM app.tbMaterias WHERE Mat_Id = @Mat))) AS Materia,
               LTRIM(RTRIM((SELECT Cun_Descripcion FROM app.tbCursosNiveles WHERE Cun_Id = @Cun))) AS Grado,
               LTRIM(RTRIM((SELECT Sec_Descripcion FROM app.tbSecciones WHERE Sec_Id = @Sec))) AS Seccion,
               app.FN_Temario_Texto((SELECT Cur_Nombre FROM app.tbCursos WHERE Cur_Id = @Cur)) AS Curso,
               app.FN_CierresParcial_NombreParcial(@Pac_Id) AS Parcial,
               app.FN_CierresParcial_NombreSemestre(@Sem) AS Semestre,
               @Cerrado AS Cerrado, @Mensaje AS MensajeCerrado,
               @Cev AS Cev_Id, ISNULL(@Version, 0) AS Version,
               CAST(CASE WHEN @Cev IS NOT NULL AND EXISTS (SELECT 1 FROM app.tbActividadesEvaluacion WHERE Cev_Id = @Cev AND Act_EsEliminado = 0)
                         THEN 1 ELSE 0 END AS bit) AS UsaActividades,
               JSON_QUERY((SELECT p.Ple_Id, p.Ple_Nombre AS Nombre, app.FN_Evaluacion_Alcance(p.Niv_Id, p.Mat_Id) AS Alcance
                           FROM app.tbPlantillasEvaluacion p WHERE p.Ple_Id = @Ple
                           FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS Plantilla,
               JSON_QUERY((SELECT p.Ple_Id, p.Ple_Nombre AS Nombre
                           FROM app.tbPlantillasEvaluacion p WHERE p.Ple_Id = @Vigente AND @Cev IS NOT NULL AND @Vigente <> @Ple
                           FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS PlantillaVigente,
               JSON_QUERY(ISNULL(CASE WHEN @Cev IS NOT NULL THEN
                    (SELECT t.Cet_Id, t.Plt_Id, t.Cet_Nombre AS Nombre, t.Cet_Peso AS Peso, t.Cet_Combinacion AS Combinacion, t.Cet_Orden AS Orden
                     FROM app.tbCuadernosEvaluacionTipos t WHERE t.Cev_Id = @Cev AND t.Cet_EsEliminado = 0
                     ORDER BY t.Cet_Orden, t.Cet_Id FOR JSON PATH)
                 ELSE
                    (SELECT CAST(NULL AS int) AS Cet_Id, t.Plt_Id, t.Plt_Nombre AS Nombre, t.Plt_Peso AS Peso, t.Plt_Combinacion AS Combinacion, t.Plt_Orden AS Orden
                     FROM app.tbPlantillasEvaluacionTipos t WHERE t.Ple_Id = @Ple AND t.Plt_EsEliminado = 0
                     ORDER BY t.Plt_Orden, t.Plt_Id FOR JSON PATH, INCLUDE_NULL_VALUES)
                 END, N'[]')) AS Tipos,
               JSON_QUERY(ISNULL((SELECT a.Act_Id, a.Cet_Id, a.Act_Nombre AS Nombre, a.Act_Descripcion AS Descripcion,
                                         a.Act_PuntosMax AS PuntosMax, a.Act_Fecha AS Fecha, a.Act_NoCuenta AS NoCuenta,
                                         a.Act_Version AS Version,
                                         (SELECT COUNT(*) FROM app.tbActividadesPuntos x JOIN @Alumnos al ON al.Alu_Id = x.Alu_Id
                                          WHERE x.Act_Id = a.Act_Id AND x.Acp_Estado <> 'vacio') AS Calificados
                                  FROM app.tbActividadesEvaluacion a
                                  WHERE a.Cev_Id = @Cev AND a.Act_EsEliminado = 0
                                  ORDER BY a.Act_Orden, a.Act_Id FOR JSON PATH), N'[]')) AS Actividades,
               JSON_QUERY(ISNULL((SELECT al.Alu_Id, al.Nombre, n.Not_Id, n.Not_Nota AS NotaParcial,
                                         k.Nota AS Calculada, k.Entera
                                  FROM @Alumnos al
                                  OUTER APPLY (SELECT TOP (1) x.Not_Id, x.Not_Nota FROM app.tbNotas x
                                               WHERE x.Alu_Id = al.Alu_Id AND x.Sec_Id = @Sec AND x.Mat_Id = @Mat AND x.Pac_Id = @Pac_Id
                                                 AND x.Sem_Id = @Sem AND YEAR(x.Not_Año) = @Anio AND x.Not_EsEliminado = 0
                                               ORDER BY x.Not_Id DESC) n
                                  LEFT JOIN app.FN_Evaluacion_Calculo(@Cev) k ON k.Alu_Id = al.Alu_Id
                                  ORDER BY al.Apellido, al.PrimerNombre FOR JSON PATH, INCLUDE_NULL_VALUES), N'[]')) AS Alumnos,
               JSON_QUERY(ISNULL((SELECT p.Act_Id, p.Alu_Id, p.Acp_Estado AS Estado, p.Acp_Puntos AS Puntos, p.Acp_Version AS Version
                                  FROM app.tbActividadesPuntos p
                                  JOIN app.tbActividadesEvaluacion a ON a.Act_Id = p.Act_Id AND a.Cev_Id = @Cev AND a.Act_EsEliminado = 0
                                  JOIN @Alumnos al ON al.Alu_Id = p.Alu_Id
                                  FOR JSON PATH, INCLUDE_NULL_VALUES), N'[]')) AS Puntos,
               JSON_QUERY(ISNULL((SELECT MIN(h.Hor_Id) AS Hor_Id,
                                         CONCAT(LTRIM(RTRIM(cn.Cun_Descripcion)), N' ', LTRIM(RTRIM(s.Sec_Descripcion)),
                                                N' (', app.FN_Temario_Texto(c.Cur_Nombre), N')') AS Texto
                                  FROM app.tbHorarios h
                                  JOIN app.tbSecciones s      ON s.Sec_Id = h.Sec_Id
                                  JOIN app.tbCursos c         ON c.Cur_Id = h.Cur_Id
                                  JOIN app.tbCursosNiveles cn ON cn.Cun_Id = h.Cun_Id
                                  WHERE h.Hor_Año = @Anio AND h.Sem_Id = @Sem AND h.Mat_Id = @Mat AND h.Cun_Id = @Cun
                                    AND h.Emp_Id = ISNULL(@Emp, @EmpH) AND ISNULL(h.Hor_EsEliminado, 0) = 0
                                    AND NOT (h.Sec_Id = @Sec AND h.Cur_Id = @Cur)
                                  GROUP BY h.Sec_Id, h.Cur_Id, cn.Cun_Descripcion, s.Sec_Descripcion, c.Cur_Nombre
                                  ORDER BY s.Sec_Descripcion, c.Cur_Nombre FOR JSON PATH), N'[]')) AS OtrasSecciones
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES);

    SELECT @Json AS Json;
END
GO

-- ¿El cuaderno de ese horario y parcial ya se califica con actividades? (la nota directa queda bloqueada)
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_UsaActividades
    @Hor_Id int,
    @Pac_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(CASE WHEN EXISTS (
               SELECT 1
               FROM app.FN_Evaluacion_Horario(@Hor_Id) g
               JOIN app.tbCuadernosEvaluacion c
                 ON c.Cev_Anio = g.Anio AND c.Sem_Id = g.Sem_Id AND c.Pac_Id = @Pac_Id AND c.Sec_Id = g.Sec_Id
                AND c.Mat_Id = g.Mat_Id AND c.Cur_Id = g.Cur_Id AND c.Cun_Id = g.Cun_Id
               JOIN app.tbActividadesEvaluacion a ON a.Cev_Id = c.Cev_Id AND a.Act_EsEliminado = 0)
           THEN 1 ELSE 0 END AS bit) AS UsaActividades;
END
GO

-- ¿La nota @Not_Id es de un parcial que se califica con actividades? (para editar la nota directa)
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_UsaActividadesNota
    @Not_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(CASE WHEN EXISTS (
               SELECT 1
               FROM app.tbNotas n
               JOIN app.tbAlumnos al ON al.Alu_Id = n.Alu_Id
               JOIN app.tbCuadernosEvaluacion c
                 ON c.Cev_Anio = YEAR(n.Not_Año) AND c.Sem_Id = n.Sem_Id AND c.Pac_Id = n.Pac_Id AND c.Sec_Id = n.Sec_Id
                AND c.Mat_Id = n.Mat_Id AND c.Cur_Id = al.Cur_Id AND c.Cun_Id = al.Cun_Id
               JOIN app.tbActividadesEvaluacion a ON a.Cev_Id = c.Cev_Id AND a.Act_EsEliminado = 0
               WHERE n.Not_Id = @Not_Id)
           THEN 1 ELSE 0 END AS bit) AS UsaActividades;
END
GO

-- La lectura que usaba la API para escribir nota por nota ya no hace falta (las notas se escriben en la transacción).
IF OBJECT_ID(N'app.PR_Evaluacion_NotasParaEscribir', N'P') IS NOT NULL
    DROP PROCEDURE app.PR_Evaluacion_NotasParaEscribir;
GO

/* ───────────────────────────── Escrituras del cuaderno ───────────────────────────── */

/* Cuaderno del grupo y parcial; lo crea con una copia de los tipos de la plantilla que corresponde.
   Se llama dentro de la transacción de quien escribe (UPDLOCK + HOLDLOCK: dos pestañas no crean dos). */
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_ObtenerCuaderno
    @Anio    int,
    @Sem_Id  int,
    @Pac_Id  int,
    @Sec_Id  int,
    @Mat_Id  int,
    @Cur_Id  int,
    @Cun_Id  int,
    @Niv_Id  int,
    @Usuario int,
    @Cev_Id  int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Cev_Id = NULL;
    SELECT @Cev_Id = Cev_Id
    FROM app.tbCuadernosEvaluacion WITH (UPDLOCK, HOLDLOCK)
    WHERE Cev_Anio = @Anio AND Sem_Id = @Sem_Id AND Pac_Id = @Pac_Id AND Sec_Id = @Sec_Id
      AND Mat_Id = @Mat_Id AND Cur_Id = @Cur_Id AND Cun_Id = @Cun_Id;
    IF @Cev_Id IS NOT NULL RETURN;

    DECLARE @Ple int = app.FN_Evaluacion_PlantillaDe(@Anio, @Niv_Id, @Mat_Id);
    IF @Ple IS NULL
    BEGIN
        DECLARE @Msg nvarchar(400) = CONCAT(N'Todavía no hay una plantilla de evaluación para este nivel en ', @Anio,
            N'. Pida a Dirección que la defina en Académico › Plantillas de evaluación; mientras tanto la nota se escribe directo.');
        THROW 50095, @Msg, 1;
    END

    INSERT INTO app.tbCuadernosEvaluacion (Cev_Anio, Sem_Id, Pac_Id, Sec_Id, Mat_Id, Cur_Id, Cun_Id, Ple_Id,
                                           Cev_Version, Cev_UsuarioRegistra, Cev_FechaRegistra)
    VALUES (@Anio, @Sem_Id, @Pac_Id, @Sec_Id, @Mat_Id, @Cur_Id, @Cun_Id, @Ple, 1, @Usuario, app.FN_AhoraHonduras());
    SET @Cev_Id = SCOPE_IDENTITY();

    INSERT INTO app.tbCuadernosEvaluacionTipos (Cev_Id, Plt_Id, Cet_Nombre, Cet_Peso, Cet_Combinacion, Cet_Orden)
    SELECT @Cev_Id, t.Plt_Id, t.Plt_Nombre, t.Plt_Peso, t.Plt_Combinacion, t.Plt_Orden
    FROM app.tbPlantillasEvaluacionTipos t
    WHERE t.Ple_Id = @Ple AND t.Plt_EsEliminado = 0;
END
GO

/* Crear o editar una actividad.
   Nueva (@Act_Id NULL/0): en el grupo del horario @Hor_Id y el parcial; el tipo llega como @Cet_Id (cuaderno
   ya creado) o @Plt_Id (tipo de la plantilla, primera actividad). @Otras = JSON con más Hor_Id del mismo
   docente, materia, grado y semestre donde crear la misma actividad (se omite donde ya hay una con ese
   nombre o no existe el tipo).
   Editar: control de versión; no se baja el máximo por debajo de puntos ya puestos.
   Responde Id, Cev_Id, Cantidad (actividades creadas o cambiadas) y Omitidas. */
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_GuardarActividad
    @Act_Id      int = NULL,
    @Hor_Id      int = NULL,
    @Pac_Id      int = NULL,
    @Cet_Id      int = NULL,
    @Plt_Id      int = NULL,
    @Nombre      nvarchar(200),
    @Descripcion nvarchar(600) = NULL,
    @PuntosMax   decimal(9,2),
    @Fecha       date = NULL,
    @NoCuenta    bit = 0,
    @Version     int = NULL,
    @Otras       nvarchar(max) = NULL,
    @Usuario     int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Puede bit, @Emp int, @Msg nvarchar(600);
    SELECT @Puede = Cuaderno, @Emp = EmpDocente FROM app.FN_Evaluacion_Permisos(@Usuario);
    IF ISNULL(@Puede, 0) = 0
        THROW 50090, N'No tiene permiso para usar el cuaderno de notas.', 1;

    SET @Nombre = NULLIF(LTRIM(RTRIM(@Nombre)), N'');
    SET @Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), N'');
    SET @NoCuenta = ISNULL(@NoCuenta, 0);
    IF @Nombre IS NULL
        THROW 50092, N'Escriba el nombre de la actividad.', 1;
    IF LEN(@Nombre) > 150
        THROW 50092, N'El nombre de la actividad admite hasta 150 caracteres.', 1;
    IF LEN(ISNULL(@Descripcion, N'')) > 500
        THROW 50092, N'La descripción admite hasta 500 caracteres.', 1;
    IF @PuntosMax IS NULL OR @PuntosMax <= 0 OR @PuntosMax > 1000
        THROW 50092, N'Los puntos máximos deben ser mayores que 0 y hasta 1000.', 1;

    DECLARE @Anio int, @Sem int, @Sec int, @Mat int, @Cur int, @Cun int, @Niv int, @EmpH int, @Cev int, @Pac int;
    DECLARE @Ahora datetime = app.FN_AhoraHonduras();

    /* ───── Editar ───── */
    IF ISNULL(@Act_Id, 0) > 0
    BEGIN
        SELECT @Cev = c.Cev_Id, @Anio = c.Cev_Anio, @Sem = c.Sem_Id, @Pac = c.Pac_Id, @Sec = c.Sec_Id,
               @Mat = c.Mat_Id, @Cur = c.Cur_Id, @Cun = c.Cun_Id
        FROM app.tbActividadesEvaluacion a
        JOIN app.tbCuadernosEvaluacion c ON c.Cev_Id = a.Cev_Id
        WHERE a.Act_Id = @Act_Id AND a.Act_EsEliminado = 0;
        IF @Cev IS NULL
            THROW 50093, N'La actividad ya no existe (otra persona la quitó). Recargue el cuaderno.', 1;
        IF app.FN_Evaluacion_PuedeGrupo(@Emp, @Anio, @Sem, @Sec, @Mat, @Cur, @Cun) = 0
            THROW 50072, N'Esa actividad no es de una materia asignada a su usuario.', 1;
        IF @Fecha IS NOT NULL AND YEAR(@Fecha) <> @Anio
        BEGIN
            SET @Msg = CONCAT(N'La fecha debe estar dentro del año lectivo ', @Anio, N'.');
            THROW 50092, @Msg, 1;
        END

        BEGIN TRANSACTION;
            EXEC app.PR_Evaluacion_Candado;
            DECLARE @Bloqueo int;
            SELECT @Bloqueo = Cev_Version FROM app.tbCuadernosEvaluacion WITH (UPDLOCK, HOLDLOCK) WHERE Cev_Id = @Cev;
            DECLARE @VActual int;
            SELECT @VActual = Act_Version FROM app.tbActividadesEvaluacion WITH (UPDLOCK, HOLDLOCK)
            WHERE Act_Id = @Act_Id AND Act_EsEliminado = 0;
            IF @VActual IS NULL
                THROW 50093, N'La actividad ya no existe (otra persona la quitó). Recargue el cuaderno.', 1;
            IF @VActual <> ISNULL(@Version, -1)
                THROW 50093, N'Otra persona cambió esta actividad mientras usted la editaba. Recargue el cuaderno para ver lo último.', 1;

            EXEC app.PR_CierresParcial_ValidarAbierto @Anio, @Sem, @Pac;

            IF NOT EXISTS (SELECT 1 FROM app.tbCuadernosEvaluacionTipos WHERE Cet_Id = @Cet_Id AND Cev_Id = @Cev AND Cet_EsEliminado = 0)
                THROW 50092, N'Elija el tipo de evaluación de la actividad.', 1;
            IF EXISTS (SELECT 1 FROM app.tbActividadesEvaluacion
                       WHERE Cev_Id = @Cev AND Act_EsEliminado = 0 AND Act_Id <> @Act_Id AND Act_Nombre = @Nombre)
                THROW 50092, N'Ya hay otra actividad con ese nombre en este parcial.', 1;
            IF EXISTS (SELECT 1 FROM app.tbActividadesPuntos
                       WHERE Act_Id = @Act_Id AND Acp_Estado = 'calificado' AND Acp_Puntos > @PuntosMax)
            BEGIN
                SET @Msg = CONCAT(N'Hay alumnos con más de ', FORMAT(@PuntosMax, N'0.##'),
                                  N' puntos en esta actividad: corrija esos puntos antes de bajar el máximo.');
                THROW 50092, @Msg, 1;
            END

            UPDATE app.tbActividadesEvaluacion
            SET Cet_Id = @Cet_Id, Act_Nombre = @Nombre, Act_Descripcion = @Descripcion, Act_PuntosMax = @PuntosMax,
                Act_Fecha = @Fecha, Act_NoCuenta = @NoCuenta, Act_Version = Act_Version + 1,
                Act_UsuarioModifica = @Usuario, Act_FechaModifica = @Ahora
            WHERE Act_Id = @Act_Id;

            UPDATE app.tbCuadernosEvaluacion
            SET Cev_Version = Cev_Version + 1, Cev_UsuarioModifica = @Usuario, Cev_FechaModifica = @Ahora
            WHERE Cev_Id = @Cev;

            -- Máximo, tipo o "no cuenta" cambian la nota: se escribe en el mismo COMMIT.
            DECLARE @EscritasE int = 0;
            EXEC app.PR_Evaluacion_EscribirNotas @Cev, @Usuario, @EscritasE OUTPUT;
        COMMIT TRANSACTION;

        SELECT @Act_Id AS Id, @Cev AS Cev_Id, 1 AS Cantidad, 0 AS Omitidas, @EscritasE AS NotasEscritas;
        RETURN;
    END

    /* ───── Nueva ───── */
    SELECT @Anio = Anio, @Sem = Sem_Id, @Sec = Sec_Id, @Mat = Mat_Id, @Cur = Cur_Id, @Cun = Cun_Id, @Niv = Niv_Id, @EmpH = Emp_Id
    FROM app.FN_Evaluacion_Horario(@Hor_Id);
    IF @Anio IS NULL
        THROW 50071, N'El horario seleccionado no existe.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbParciales WHERE Pac_Id = @Pac_Id AND ISNULL(Pac_EsEliminado, 0) = 0)
        THROW 50091, N'Elija un parcial válido.', 1;
    IF app.FN_Evaluacion_PuedeGrupo(@Emp, @Anio, @Sem, @Sec, @Mat, @Cur, @Cun) = 0
        THROW 50072, N'Ese horario no está asignado a su usuario.', 1;
    IF @Fecha IS NOT NULL AND YEAR(@Fecha) <> @Anio
    BEGIN
        SET @Msg = CONCAT(N'La fecha debe estar dentro del año lectivo ', @Anio, N'.');
        THROW 50092, @Msg, 1;
    END
    IF @Otras IS NOT NULL AND ISJSON(@Otras) = 0
        THROW 50092, N'La lista de otras secciones no es válida.', 1;

    DECLARE @NuevoId int, @Creadas int = 0, @Omitidas int = 0, @PltBase int, @NombreTipo nvarchar(60);

    BEGIN TRANSACTION;
        EXEC app.PR_Evaluacion_Candado;
        EXEC app.PR_CierresParcial_ValidarAbierto @Anio, @Sem, @Pac_Id;
        EXEC app.PR_Evaluacion_ObtenerCuaderno @Anio, @Sem, @Pac_Id, @Sec, @Mat, @Cur, @Cun, @Niv, @Usuario, @Cev OUTPUT;

        IF ISNULL(@Cet_Id, 0) > 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM app.tbCuadernosEvaluacionTipos WHERE Cet_Id = @Cet_Id AND Cev_Id = @Cev AND Cet_EsEliminado = 0)
                SET @Cet_Id = NULL;
        END
        ELSE
            SET @Cet_Id = (SELECT TOP (1) Cet_Id FROM app.tbCuadernosEvaluacionTipos
                           WHERE Cev_Id = @Cev AND Plt_Id = @Plt_Id AND Cet_EsEliminado = 0);
        IF @Cet_Id IS NULL
            THROW 50092, N'Elija el tipo de evaluación de la actividad (si la página es antigua, recárguela).', 1;
        SELECT @PltBase = Plt_Id, @NombreTipo = Cet_Nombre FROM app.tbCuadernosEvaluacionTipos WHERE Cet_Id = @Cet_Id;

        IF EXISTS (SELECT 1 FROM app.tbActividadesEvaluacion WHERE Cev_Id = @Cev AND Act_EsEliminado = 0 AND Act_Nombre = @Nombre)
            THROW 50092, N'Ya hay una actividad con ese nombre en este parcial.', 1;

        INSERT INTO app.tbActividadesEvaluacion (Cev_Id, Cet_Id, Act_Nombre, Act_Descripcion, Act_PuntosMax, Act_Fecha, Act_NoCuenta,
                                                 Act_Orden, Act_Version, Act_EsEliminado, Act_UsuarioRegistra, Act_FechaRegistra)
        VALUES (@Cev, @Cet_Id, @Nombre, @Descripcion, @PuntosMax, @Fecha, @NoCuenta,
                ISNULL((SELECT MAX(Act_Orden) FROM app.tbActividadesEvaluacion WHERE Cev_Id = @Cev), 0) + 1, 1, 0, @Usuario, @Ahora);
        SET @NuevoId = SCOPE_IDENTITY();
        SET @Creadas = 1;
        UPDATE app.tbCuadernosEvaluacion
        SET Cev_Version = Cev_Version + 1, Cev_UsuarioModifica = @Usuario, Cev_FechaModifica = @Ahora
        WHERE Cev_Id = @Cev;

        /* La misma actividad en otras secciones del docente (mismo grado, materia y semestre) */
        DECLARE @Otro int, @oSec int, @oCur int, @oCev int, @oCet int, @oAnio int, @oSem int, @oMat int, @oCun int, @oEmp int, @oNiv int;
        DECLARE otras CURSOR LOCAL FAST_FORWARD FOR
            SELECT DISTINCT TRY_CAST(j.[value] AS int) FROM OPENJSON(ISNULL(@Otras, N'[]')) j
            WHERE TRY_CAST(j.[value] AS int) > 0;
        OPEN otras;
        FETCH NEXT FROM otras INTO @Otro;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @oAnio = NULL, @oSec = NULL, @oCev = NULL, @oCet = NULL;
            SELECT @oAnio = Anio, @oSem = Sem_Id, @oSec = Sec_Id, @oMat = Mat_Id, @oCur = Cur_Id, @oCun = Cun_Id, @oEmp = Emp_Id, @oNiv = Niv_Id
            FROM app.FN_Evaluacion_Horario(@Otro);
            IF @oAnio IS NULL OR @oAnio <> @Anio OR @oSem <> @Sem OR @oMat <> @Mat OR @oCun <> @Cun OR (@oSec = @Sec AND @oCur = @Cur)
               OR app.FN_Evaluacion_PuedeGrupo(@Emp, @oAnio, @oSem, @oSec, @oMat, @oCur, @oCun) = 0
               OR ISNULL(@oEmp, -1) <> ISNULL(@Emp, ISNULL(@EmpH, -1))
                SET @Omitidas += 1;
            ELSE
            BEGIN
                EXEC app.PR_Evaluacion_ObtenerCuaderno @oAnio, @oSem, @Pac_Id, @oSec, @oMat, @oCur, @oCun, @oNiv, @Usuario, @oCev OUTPUT;
                SELECT TOP (1) @oCet = Cet_Id FROM app.tbCuadernosEvaluacionTipos
                WHERE Cev_Id = @oCev AND Cet_EsEliminado = 0 AND (Plt_Id = @PltBase OR Cet_Nombre = @NombreTipo)
                ORDER BY CASE WHEN Plt_Id = @PltBase THEN 0 ELSE 1 END;
                IF @oCet IS NULL OR EXISTS (SELECT 1 FROM app.tbActividadesEvaluacion
                                            WHERE Cev_Id = @oCev AND Act_EsEliminado = 0 AND Act_Nombre = @Nombre)
                    SET @Omitidas += 1;
                ELSE
                BEGIN
                    INSERT INTO app.tbActividadesEvaluacion (Cev_Id, Cet_Id, Act_Nombre, Act_Descripcion, Act_PuntosMax, Act_Fecha, Act_NoCuenta,
                                                             Act_Orden, Act_Version, Act_EsEliminado, Act_UsuarioRegistra, Act_FechaRegistra)
                    VALUES (@oCev, @oCet, @Nombre, @Descripcion, @PuntosMax, @Fecha, @NoCuenta,
                            ISNULL((SELECT MAX(Act_Orden) FROM app.tbActividadesEvaluacion WHERE Cev_Id = @oCev), 0) + 1, 1, 0, @Usuario, @Ahora);
                    UPDATE app.tbCuadernosEvaluacion
                    SET Cev_Version = Cev_Version + 1, Cev_UsuarioModifica = @Usuario, Cev_FechaModifica = @Ahora
                    WHERE Cev_Id = @oCev;
                    SET @Creadas += 1;
                END
            END
            FETCH NEXT FROM otras INTO @Otro;
        END
        CLOSE otras;
        DEALLOCATE otras;
    COMMIT TRANSACTION;

    -- Una actividad nueva no tiene puntos: no cambia ninguna nota.
    SELECT @NuevoId AS Id, @Cev AS Cev_Id, @Creadas AS Cantidad, @Omitidas AS Omitidas, 0 AS NotasEscritas;
END
GO

/* Quitar una actividad (borrado lógico; sus puntos dejan de contar). Control de versión y parcial abierto. */
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_QuitarActividad
    @Act_Id  int,
    @Version int,
    @Usuario int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Puede bit, @Emp int;
    SELECT @Puede = Cuaderno, @Emp = EmpDocente FROM app.FN_Evaluacion_Permisos(@Usuario);
    IF ISNULL(@Puede, 0) = 0
        THROW 50090, N'No tiene permiso para usar el cuaderno de notas.', 1;

    DECLARE @Cev int, @Anio int, @Sem int, @Pac int, @Sec int, @Mat int, @Cur int, @Cun int;
    SELECT @Cev = c.Cev_Id, @Anio = c.Cev_Anio, @Sem = c.Sem_Id, @Pac = c.Pac_Id, @Sec = c.Sec_Id,
           @Mat = c.Mat_Id, @Cur = c.Cur_Id, @Cun = c.Cun_Id
    FROM app.tbActividadesEvaluacion a
    JOIN app.tbCuadernosEvaluacion c ON c.Cev_Id = a.Cev_Id
    WHERE a.Act_Id = @Act_Id AND a.Act_EsEliminado = 0;
    IF @Cev IS NULL
        THROW 50093, N'La actividad ya no existe (otra persona la quitó). Recargue el cuaderno.', 1;
    IF app.FN_Evaluacion_PuedeGrupo(@Emp, @Anio, @Sem, @Sec, @Mat, @Cur, @Cun) = 0
        THROW 50072, N'Esa actividad no es de una materia asignada a su usuario.', 1;

    DECLARE @Ahora datetime = app.FN_AhoraHonduras();
    BEGIN TRANSACTION;
        EXEC app.PR_Evaluacion_Candado;
        DECLARE @Bloqueo int;
        SELECT @Bloqueo = Cev_Version FROM app.tbCuadernosEvaluacion WITH (UPDLOCK, HOLDLOCK) WHERE Cev_Id = @Cev;
        DECLARE @VActual int;
        SELECT @VActual = Act_Version FROM app.tbActividadesEvaluacion WITH (UPDLOCK, HOLDLOCK)
        WHERE Act_Id = @Act_Id AND Act_EsEliminado = 0;
        IF @VActual IS NULL
            THROW 50093, N'La actividad ya no existe (otra persona la quitó). Recargue el cuaderno.', 1;
        IF @VActual <> ISNULL(@Version, -1)
            THROW 50093, N'Otra persona cambió esta actividad mientras usted la tenía abierta. Recargue el cuaderno para ver lo último.', 1;

        EXEC app.PR_CierresParcial_ValidarAbierto @Anio, @Sem, @Pac;

        UPDATE app.tbActividadesEvaluacion
        SET Act_EsEliminado = 1, Act_Version = Act_Version + 1, Act_UsuarioModifica = @Usuario, Act_FechaModifica = @Ahora
        WHERE Act_Id = @Act_Id;
        UPDATE app.tbCuadernosEvaluacion
        SET Cev_Version = Cev_Version + 1, Cev_UsuarioModifica = @Usuario, Cev_FechaModifica = @Ahora
        WHERE Cev_Id = @Cev;

        DECLARE @Escritas int = 0;
        EXEC app.PR_Evaluacion_EscribirNotas @Cev, @Usuario, @Escritas OUTPUT;
    COMMIT TRANSACTION;

    SELECT @Act_Id AS Id, @Cev AS Cev_Id, 1 AS Cantidad, 0 AS Omitidas, @Escritas AS NotasEscritas;
END
GO

/* Guardar puntos de varias celdas a la vez. @Puntos = JSON [{a: Act_Id, u: Alu_Id, e: estado, p: puntos, v: versión leída}]
   (versión 0 = la celda no existía). Todo o nada: si otra persona cambió alguna de esas celdas, no se guarda nada. */
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_GuardarPuntos
    @Cev_Id  int,
    @Puntos  nvarchar(max),
    @Usuario int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Puede bit, @Emp int, @Msg nvarchar(600);
    SELECT @Puede = Cuaderno, @Emp = EmpDocente FROM app.FN_Evaluacion_Permisos(@Usuario);
    IF ISNULL(@Puede, 0) = 0
        THROW 50090, N'No tiene permiso para usar el cuaderno de notas.', 1;

    DECLARE @Anio int, @Sem int, @Pac int, @Sec int, @Mat int, @Cur int, @Cun int;
    SELECT @Anio = Cev_Anio, @Sem = Sem_Id, @Pac = Pac_Id, @Sec = Sec_Id, @Mat = Mat_Id, @Cur = Cur_Id, @Cun = Cun_Id
    FROM app.tbCuadernosEvaluacion WHERE Cev_Id = @Cev_Id;
    IF @Anio IS NULL
        THROW 50093, N'El cuaderno ya no existe. Recargue la página.', 1;
    IF app.FN_Evaluacion_PuedeGrupo(@Emp, @Anio, @Sem, @Sec, @Mat, @Cur, @Cun) = 0
        THROW 50072, N'Ese cuaderno no es de una materia asignada a su usuario.', 1;
    IF @Puntos IS NULL OR ISJSON(@Puntos) = 0
        THROW 50092, N'Los puntos enviados no son válidos.', 1;

    DECLARE @P TABLE (Act_Id int, Alu_Id int, Estado varchar(20), Puntos decimal(9,2), Version int, PRIMARY KEY (Act_Id, Alu_Id));
    BEGIN TRY
        INSERT INTO @P (Act_Id, Alu_Id, Estado, Puntos, Version)
        SELECT a, u, LOWER(LTRIM(RTRIM(e))), p, ISNULL(v, 0)
        FROM OPENJSON(@Puntos) WITH (a int '$.a', u int '$.u', e varchar(20) '$.e', p decimal(9,2) '$.p', v int '$.v');
    END TRY
    BEGIN CATCH
        THROW 50092, N'Los puntos enviados no son válidos (hay una celda repetida o un número fuera de rango).', 1;
    END CATCH

    DECLARE @N int = (SELECT COUNT(*) FROM @P);
    IF @N = 0
        THROW 50092, N'No hay cambios para guardar.', 1;
    IF @N > 5000
        THROW 50092, N'Son demasiados cambios a la vez: guarde por partes.', 1;
    IF EXISTS (SELECT 1 FROM @P WHERE Act_Id IS NULL OR Alu_Id IS NULL OR Estado IS NULL
                                     OR Estado NOT IN ('calificado', 'no_entrego', 'excusado', 'vacio'))
        THROW 50092, N'Hay una celda con un valor que no se entiende. Use un número, E (excusado) o NE (no entregó).', 1;
    UPDATE @P SET Puntos = NULL WHERE Estado <> 'calificado';
    IF EXISTS (SELECT 1 FROM @P WHERE Estado = 'calificado' AND (Puntos IS NULL OR Puntos < 0))
        THROW 50092, N'Los puntos no pueden ser negativos.', 1;
    IF EXISTS (SELECT 1 FROM @P x LEFT JOIN app.tbActividadesEvaluacion a ON a.Act_Id = x.Act_Id AND a.Cev_Id = @Cev_Id AND a.Act_EsEliminado = 0
               WHERE a.Act_Id IS NULL)
        THROW 50093, N'Una de las actividades ya no existe (otra persona la quitó). Recargue el cuaderno; sus cambios no se guardaron.', 1;
    DECLARE @Excede nvarchar(200) = (SELECT TOP (1) a.Act_Nombre FROM @P x JOIN app.tbActividadesEvaluacion a ON a.Act_Id = x.Act_Id
                                     WHERE x.Estado = 'calificado' AND x.Puntos > a.Act_PuntosMax);
    IF @Excede IS NOT NULL
    BEGIN
        SET @Msg = CONCAT(N'En "', @Excede, N'" hay puntos mayores que el máximo de la actividad.');
        THROW 50092, @Msg, 1;
    END
    IF EXISTS (SELECT 1 FROM @P x WHERE NOT EXISTS (SELECT 1 FROM app.FN_Evaluacion_Alumnos(@Anio, @Sec, @Cur, @Cun) al WHERE al.Alu_Id = x.Alu_Id))
        THROW 50073, N'Uno de los alumnos ya no es un alumno activo de esa sección. Recargue el cuaderno.', 1;

    DECLARE @Ahora datetime = app.FN_AhoraHonduras();
    BEGIN TRANSACTION;
        -- Candado compartido y luego el cuaderno: dos pestañas del mismo cuaderno guardan una tras otra.
        EXEC app.PR_Evaluacion_Candado;
        DECLARE @Bloqueo int;
        SELECT @Bloqueo = Cev_Version FROM app.tbCuadernosEvaluacion WITH (UPDLOCK, HOLDLOCK) WHERE Cev_Id = @Cev_Id;
        EXEC app.PR_CierresParcial_ValidarAbierto @Anio, @Sem, @Pac;

        DECLARE @Conflictos int = (
            SELECT COUNT(*)
            FROM @P x
            LEFT JOIN app.tbActividadesPuntos p WITH (UPDLOCK, HOLDLOCK) ON p.Act_Id = x.Act_Id AND p.Alu_Id = x.Alu_Id
            WHERE ISNULL(p.Acp_Version, 0) <> x.Version);
        IF @Conflictos > 0
        BEGIN
            SET @Msg = CONCAT(@Conflictos, N' calificación(es) las cambió otra persona mientras usted tenía abierto el cuaderno. ',
                              N'No se guardó nada: recargue para ver lo último y vuelva a escribir sus cambios.');
            THROW 50094, @Msg, 1;
        END

        UPDATE p
        SET Acp_Estado = x.Estado, Acp_Puntos = x.Puntos, Acp_Version = p.Acp_Version + 1,
            Acp_UsuarioModifica = @Usuario, Acp_FechaModifica = @Ahora
        FROM app.tbActividadesPuntos p
        JOIN @P x ON x.Act_Id = p.Act_Id AND x.Alu_Id = p.Alu_Id;

        INSERT INTO app.tbActividadesPuntos (Act_Id, Alu_Id, Acp_Estado, Acp_Puntos, Acp_Version, Acp_UsuarioRegistra, Acp_FechaRegistra)
        SELECT x.Act_Id, x.Alu_Id, x.Estado, x.Puntos, 1, @Usuario, @Ahora
        FROM @P x
        WHERE NOT EXISTS (SELECT 1 FROM app.tbActividadesPuntos p WHERE p.Act_Id = x.Act_Id AND p.Alu_Id = x.Alu_Id);

        UPDATE app.tbCuadernosEvaluacion
        SET Cev_Version = Cev_Version + 1, Cev_UsuarioModifica = @Usuario, Cev_FechaModifica = @Ahora
        WHERE Cev_Id = @Cev_Id;

        DECLARE @Escritas int = 0;
        EXEC app.PR_Evaluacion_EscribirNotas @Cev_Id, @Usuario, @Escritas OUTPUT;
    COMMIT TRANSACTION;

    SELECT @Cev_Id AS Id, @Cev_Id AS Cev_Id, @N AS Cantidad, 0 AS Omitidas, @Escritas AS NotasEscritas;
END
GO

/* Vuelve a escribir en app.tbNotas la nota calculada del cuaderno (por si alguien la cambió por otro camino). */
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_ActualizarNotas
    @Cev_Id  int,
    @Usuario int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Puede bit, @Emp int;
    SELECT @Puede = Cuaderno, @Emp = EmpDocente FROM app.FN_Evaluacion_Permisos(@Usuario);
    IF ISNULL(@Puede, 0) = 0
        THROW 50090, N'No tiene permiso para usar el cuaderno de notas.', 1;

    DECLARE @Anio int, @Sem int, @Pac int, @Sec int, @Mat int, @Cur int, @Cun int;
    SELECT @Anio = Cev_Anio, @Sem = Sem_Id, @Pac = Pac_Id, @Sec = Sec_Id, @Mat = Mat_Id, @Cur = Cur_Id, @Cun = Cun_Id
    FROM app.tbCuadernosEvaluacion WHERE Cev_Id = @Cev_Id;
    IF @Anio IS NULL
        THROW 50093, N'El cuaderno ya no existe. Recargue la página.', 1;
    IF app.FN_Evaluacion_PuedeGrupo(@Emp, @Anio, @Sem, @Sec, @Mat, @Cur, @Cun) = 0
        THROW 50072, N'Ese cuaderno no es de una materia asignada a su usuario.', 1;

    DECLARE @Escritas int = 0, @Bloqueo int;
    BEGIN TRANSACTION;
        EXEC app.PR_Evaluacion_Candado;
        SELECT @Bloqueo = Cev_Version FROM app.tbCuadernosEvaluacion WITH (UPDLOCK, HOLDLOCK) WHERE Cev_Id = @Cev_Id;
        EXEC app.PR_CierresParcial_ValidarAbierto @Anio, @Sem, @Pac;
        EXEC app.PR_Evaluacion_EscribirNotas @Cev_Id, @Usuario, @Escritas OUTPUT;
    COMMIT TRANSACTION;

    SELECT @Cev_Id AS Id, @Cev_Id AS Cev_Id, 0 AS Cantidad, 0 AS Omitidas, @Escritas AS NotasEscritas;
END
GO

/* ───────────────────────────── Plantillas (Dirección) ───────────────────────────── */

-- Plantillas de un año con sus tipos (JSON) y en cuántos cuadernos se usan.
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_Plantillas
    @Anio   int,
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    IF ISNULL((SELECT Plantillas FROM app.FN_Evaluacion_Permisos(@Usu_Id)), 0) = 0
        THROW 50090, N'No tiene permiso para ver las plantillas de evaluación.', 1;

    SELECT p.Ple_Id, p.Ple_Anio AS Anio, p.Niv_Id, LTRIM(RTRIM(n.Niv_Descripcion)) AS Nivel,
           p.Mat_Id, LTRIM(RTRIM(m.Mat_Nombre)) AS Materia, p.Ple_Nombre AS Nombre, p.Ple_Descripcion AS Descripcion,
           p.Ple_Version AS Version, app.FN_Evaluacion_Alcance(p.Niv_Id, p.Mat_Id) AS Alcance,
           CAST(CASE WHEN p.Niv_Id IS NULL AND p.Mat_Id IS NULL THEN 1 ELSE 0 END AS bit) AS PorDefecto,
           u.Cuadernos, u.CuadernosCerrados, u.Actividades,
           (SELECT t.Plt_Id, t.Plt_Nombre AS Nombre, t.Plt_Peso AS Peso, t.Plt_Combinacion AS Combinacion, t.Plt_Orden AS Orden,
                   (SELECT COUNT(*) FROM app.tbCuadernosEvaluacionTipos ct
                    JOIN app.tbActividadesEvaluacion a ON a.Cet_Id = ct.Cet_Id AND a.Act_EsEliminado = 0
                    WHERE ct.Plt_Id = t.Plt_Id AND ct.Cet_EsEliminado = 0) AS Actividades
            FROM app.tbPlantillasEvaluacionTipos t
            WHERE t.Ple_Id = p.Ple_Id AND t.Plt_EsEliminado = 0
            ORDER BY t.Plt_Orden, t.Plt_Id FOR JSON PATH) AS TiposJson,
           app.FN_CierresParcial_NombreUsuario(ISNULL(p.Ple_UsuarioModifica, p.Ple_UsuarioRegistra)) AS ModificadoPor,
           ISNULL(p.Ple_FechaModifica, p.Ple_FechaRegistra) AS Modificado
    FROM app.tbPlantillasEvaluacion p
    LEFT JOIN app.tbNivelesEducativos n ON n.Niv_Id = p.Niv_Id
    LEFT JOIN app.tbMaterias m ON m.Mat_Id = p.Mat_Id
    OUTER APPLY (SELECT COUNT(*) AS Cuadernos,
                        SUM(CASE WHEN app.FN_Evaluacion_Cerrado(c.Cev_Anio, c.Sem_Id, c.Pac_Id) = 1 THEN 1 ELSE 0 END) AS CuadernosCerrados,
                        (SELECT COUNT(*) FROM app.tbActividadesEvaluacion a JOIN app.tbCuadernosEvaluacion c2 ON c2.Cev_Id = a.Cev_Id
                         WHERE c2.Ple_Id = p.Ple_Id AND a.Act_EsEliminado = 0) AS Actividades
                 FROM app.tbCuadernosEvaluacion c WHERE c.Ple_Id = p.Ple_Id) u
    WHERE p.Ple_EsEliminado = 0 AND p.Ple_Anio = @Anio
    ORDER BY CASE WHEN p.Niv_Id IS NULL AND p.Mat_Id IS NULL THEN 0 ELSE 1 END, n.Niv_Descripcion, m.Mat_Nombre, p.Ple_Nombre;
END
GO

/* Opciones de los filtros y del formulario: @Tipo = anio | nivel | materia (del año y nivel, según el horario). */
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_Opciones
    @Usu_Id int,
    @Tipo   varchar(10),
    @Anio   int = NULL,
    @Niv_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Cuaderno bit, @Plantillas bit;
    SELECT @Cuaderno = Cuaderno, @Plantillas = Plantillas FROM app.FN_Evaluacion_Permisos(@Usu_Id);
    IF ISNULL(@Plantillas, 0) = 0
        THROW 50090, N'No tiene permiso para ver las plantillas de evaluación.', 1;
    DECLARE @Actual int = app.FN_Temario_AnioActual();

    IF @Tipo = 'anio'
        SELECT x.Anio AS Id, CAST(x.Anio AS nvarchar(10)) AS Texto, CAST(CASE WHEN x.Anio = @Actual THEN 1 ELSE 0 END AS bit) AS EsActual
        FROM (SELECT @Actual AS Anio UNION SELECT @Actual + 1
              UNION SELECT DISTINCT Hor_Año FROM app.tbHorarios WHERE ISNULL(Hor_EsEliminado, 0) = 0 AND Hor_Año IS NOT NULL
              UNION SELECT DISTINCT Ple_Anio FROM app.tbPlantillasEvaluacion WHERE Ple_EsEliminado = 0) x
        WHERE x.Anio BETWEEN 2000 AND 2100
        ORDER BY x.Anio DESC;
    ELSE IF @Tipo = 'nivel'
        SELECT n.Niv_Id AS Id, LTRIM(RTRIM(n.Niv_Descripcion)) AS Texto, CAST(0 AS bit) AS EsActual
        FROM app.tbNivelesEducativos n
        WHERE ISNULL(n.Niv_EsEliminado, 0) = 0 AND ISNULL(n.Niv_EsActivo, 1) = 1
        ORDER BY n.Niv_Id;
    ELSE IF @Tipo = 'materia'
        SELECT m.Mat_Id AS Id, LTRIM(RTRIM(m.Mat_Nombre)) AS Texto, CAST(0 AS bit) AS EsActual
        FROM app.tbMaterias m
        WHERE ISNULL(m.Mat_EsEliminado, 0) = 0
          AND EXISTS (SELECT 1 FROM app.tbHorarios h
                      LEFT JOIN app.tbCursos c ON c.Cur_Id = h.Cur_Id
                      LEFT JOIN app.tbCursosNiveles cn ON cn.Cun_Id = h.Cun_Id
                      WHERE h.Mat_Id = m.Mat_Id AND ISNULL(h.Hor_EsEliminado, 0) = 0
                        AND h.Hor_Año = ISNULL(@Anio, @Actual)
                        AND (@Niv_Id IS NULL OR COALESCE(c.Niv_Id, cn.Niv_Id) = @Niv_Id))
        ORDER BY LTRIM(RTRIM(m.Mat_Nombre));
    ELSE
        SELECT CAST(NULL AS int) AS Id, CAST(NULL AS nvarchar(10)) AS Texto, CAST(0 AS bit) AS EsActual WHERE 1 = 0;
END
GO

/* Crear o editar una plantilla con sus tipos. @Tipos = JSON [{id: Plt_Id (0 = nuevo), n: nombre, p: peso, c: suma|promedio|mejor}].
   Los pesos suman 100. Al guardar se actualizan los cuadernos de parciales abiertos que la usan; los de parciales
   cerrados conservan sus pesos. Con cuadernos no se cambia año, nivel ni materia, ni se quita un tipo con actividades
   en un parcial abierto. Responde Id, Version, Sincronizados y Conservados. */
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_GuardarPlantilla
    @Ple_Id      int = NULL,
    @Anio        int,
    @Niv_Id      int = NULL,
    @Mat_Id      int = NULL,
    @Nombre      nvarchar(200),
    @Descripcion nvarchar(600) = NULL,
    @Tipos       nvarchar(max),
    @Version     int = NULL,
    @Usuario     int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Msg nvarchar(600);
    IF ISNULL((SELECT Plantillas FROM app.FN_Evaluacion_Permisos(@Usuario)), 0) = 0
        THROW 50090, N'No tiene permiso para cambiar plantillas de evaluación.', 1;

    SET @Nombre = NULLIF(LTRIM(RTRIM(@Nombre)), N'');
    SET @Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), N'');
    SET @Ple_Id = NULLIF(@Ple_Id, 0);
    IF @Nombre IS NULL
        THROW 50092, N'Escriba el nombre de la plantilla.', 1;
    IF LEN(@Nombre) > 100
        THROW 50092, N'El nombre admite hasta 100 caracteres.', 1;
    IF LEN(ISNULL(@Descripcion, N'')) > 500
        THROW 50092, N'La descripción admite hasta 500 caracteres.', 1;
    IF @Anio IS NULL OR @Anio < 2000 OR @Anio > 2100
        THROW 50092, N'Elija el año lectivo.', 1;
    IF @Niv_Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM app.tbNivelesEducativos WHERE Niv_Id = @Niv_Id AND ISNULL(Niv_EsEliminado, 0) = 0)
        THROW 50092, N'Elija un nivel válido.', 1;
    IF @Mat_Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM app.tbMaterias WHERE Mat_Id = @Mat_Id AND ISNULL(Mat_EsEliminado, 0) = 0)
        THROW 50092, N'Elija una materia válida.', 1;
    IF @Tipos IS NULL OR ISJSON(@Tipos) = 0
        THROW 50092, N'Agregue los tipos de evaluación.', 1;

    DECLARE @T TABLE (Fila int IDENTITY(1,1), Plt_Id int, Nombre nvarchar(200), Peso decimal(9,2), Comb varchar(20));
    BEGIN TRY
        INSERT INTO @T (Plt_Id, Nombre, Peso, Comb)
        SELECT NULLIF(t.i, 0), NULLIF(LTRIM(RTRIM(t.n)), N''), t.p, LOWER(ISNULL(NULLIF(LTRIM(RTRIM(t.c)), ''), 'suma'))
        FROM OPENJSON(@Tipos) j
        CROSS APPLY OPENJSON(j.[value]) WITH (i int '$.id', n nvarchar(200) '$.n', p decimal(9,2) '$.p', c varchar(20) '$.c') t
        ORDER BY CAST(j.[key] AS int);
    END TRY
    BEGIN CATCH
        THROW 50092, N'Los tipos de evaluación no son válidos (revise los pesos).', 1;
    END CATCH

    DECLARE @NT int = (SELECT COUNT(*) FROM @T);
    IF @NT = 0
        THROW 50092, N'Agregue al menos un tipo de evaluación.', 1;
    IF @NT > 10
        THROW 50092, N'Una plantilla admite hasta 10 tipos de evaluación.', 1;
    IF EXISTS (SELECT 1 FROM @T WHERE Nombre IS NULL)
        THROW 50092, N'Escriba el nombre de cada tipo de evaluación.', 1;
    IF EXISTS (SELECT 1 FROM @T WHERE LEN(Nombre) > 60)
        THROW 50092, N'El nombre de un tipo admite hasta 60 caracteres.', 1;
    IF EXISTS (SELECT Nombre FROM @T GROUP BY Nombre HAVING COUNT(*) > 1)
        THROW 50092, N'Hay dos tipos de evaluación con el mismo nombre.', 1;
    IF EXISTS (SELECT 1 FROM @T WHERE Peso IS NULL OR Peso <= 0 OR Peso > 100)
        THROW 50092, N'Cada peso debe ser mayor que 0 y hasta 100.', 1;
    IF EXISTS (SELECT 1 FROM @T WHERE Comb NOT IN ('suma', 'promedio', 'mejor'))
        THROW 50092, N'Elija cómo se juntan las actividades de cada tipo.', 1;
    DECLARE @Suma decimal(9,2) = (SELECT SUM(Peso) FROM @T);
    IF @Suma <> 100
    BEGIN
        SET @Msg = CONCAT(N'Los pesos deben sumar 100 %; ahora suman ', FORMAT(@Suma, N'0.##'), N' %.');
        THROW 50092, @Msg, 1;
    END

    DECLARE @Ahora datetime = app.FN_AhoraHonduras(), @Sinc int = 0, @Conservados int = 0, @NuevaVersion int, @Escritas int = 0;
    BEGIN TRANSACTION;
        -- Exclusivo: espera a que terminen los guardados de puntos en curso y los frena mientras recalcula.
        EXEC app.PR_Evaluacion_Candado 1;
        IF @Ple_Id IS NOT NULL
        BEGIN
            DECLARE @VActual int, @AnioA int, @NivA int, @MatA int;
            SELECT @VActual = Ple_Version, @AnioA = Ple_Anio, @NivA = Niv_Id, @MatA = Mat_Id
            FROM app.tbPlantillasEvaluacion WITH (UPDLOCK, HOLDLOCK)
            WHERE Ple_Id = @Ple_Id AND Ple_EsEliminado = 0;
            IF @VActual IS NULL
                THROW 50093, N'La plantilla ya no existe (otra persona la quitó). Recargue la página.', 1;
            IF @VActual <> ISNULL(@Version, -1)
                THROW 50093, N'Otra persona cambió esta plantilla mientras usted la editaba. Recargue la página para ver lo último.', 1;
            IF EXISTS (SELECT 1 FROM @T x WHERE x.Plt_Id IS NOT NULL
                       AND NOT EXISTS (SELECT 1 FROM app.tbPlantillasEvaluacionTipos t WHERE t.Plt_Id = x.Plt_Id AND t.Ple_Id = @Ple_Id AND t.Plt_EsEliminado = 0))
                THROW 50093, N'Uno de los tipos ya no existe en la plantilla. Recargue la página.', 1;
            DECLARE @EnUso int = (SELECT COUNT(*) FROM app.tbCuadernosEvaluacion WHERE Ple_Id = @Ple_Id);
            IF @EnUso > 0 AND (@AnioA <> @Anio OR ISNULL(@NivA, -1) <> ISNULL(@Niv_Id, -1) OR ISNULL(@MatA, -1) <> ISNULL(@Mat_Id, -1))
            BEGIN
                SET @Msg = CONCAT(N'Esta plantilla ya se usa en ', @EnUso, N' cuaderno(s): no se puede cambiar su año, nivel ni materia. ',
                                  N'Cree otra plantilla para el nuevo alcance.');
                THROW 50097, @Msg, 1;
            END
            DECLARE @Quitado nvarchar(60) = (
                SELECT TOP (1) t.Plt_Nombre
                FROM app.tbPlantillasEvaluacionTipos t
                WHERE t.Ple_Id = @Ple_Id AND t.Plt_EsEliminado = 0
                  AND NOT EXISTS (SELECT 1 FROM @T x WHERE x.Plt_Id = t.Plt_Id)
                  AND EXISTS (SELECT 1 FROM app.tbCuadernosEvaluacionTipos ct
                              JOIN app.tbCuadernosEvaluacion c ON c.Cev_Id = ct.Cev_Id
                              JOIN app.tbActividadesEvaluacion a ON a.Cet_Id = ct.Cet_Id AND a.Act_EsEliminado = 0
                              WHERE ct.Plt_Id = t.Plt_Id AND ct.Cet_EsEliminado = 0
                                AND app.FN_Evaluacion_Cerrado(c.Cev_Anio, c.Sem_Id, c.Pac_Id) = 0));
            IF @Quitado IS NOT NULL
            BEGIN
                SET @Msg = CONCAT(N'El tipo "', @Quitado, N'" ya tiene actividades en parciales abiertos: no se puede quitar. ',
                                  N'Puede cambiar su nombre o su peso.');
                THROW 50098, @Msg, 1;
            END
        END

        DECLARE @Otra nvarchar(100) = (SELECT TOP (1) Ple_Nombre FROM app.tbPlantillasEvaluacion WITH (UPDLOCK, HOLDLOCK)
                                       WHERE Ple_EsEliminado = 0 AND Ple_Anio = @Anio AND ISNULL(Niv_Id, -1) = ISNULL(@Niv_Id, -1)
                                         AND ISNULL(Mat_Id, -1) = ISNULL(@Mat_Id, -1) AND Ple_Id <> ISNULL(@Ple_Id, 0));
        IF @Otra IS NOT NULL
        BEGIN
            SET @Msg = CONCAT(N'Ya hay una plantilla para ese año, nivel y materia: "', @Otra, N'". Edítela en vez de crear otra.');
            THROW 50096, @Msg, 1;
        END
        IF EXISTS (SELECT 1 FROM app.tbPlantillasEvaluacion WHERE Ple_EsEliminado = 0 AND Ple_Anio = @Anio
                   AND Ple_Nombre = @Nombre AND Ple_Id <> ISNULL(@Ple_Id, 0))
            THROW 50096, N'Ya hay otra plantilla con ese nombre en el mismo año.', 1;

        IF @Ple_Id IS NULL
        BEGIN
            INSERT INTO app.tbPlantillasEvaluacion (Ple_Anio, Niv_Id, Mat_Id, Ple_Nombre, Ple_Descripcion, Ple_Version, Ple_EsEliminado,
                                                    Ple_UsuarioRegistra, Ple_FechaRegistra)
            VALUES (@Anio, @Niv_Id, @Mat_Id, @Nombre, @Descripcion, 1, 0, @Usuario, @Ahora);
            SET @Ple_Id = SCOPE_IDENTITY();
        END
        ELSE
            UPDATE app.tbPlantillasEvaluacion
            SET Ple_Anio = @Anio, Niv_Id = @Niv_Id, Mat_Id = @Mat_Id, Ple_Nombre = @Nombre, Ple_Descripcion = @Descripcion,
                Ple_Version = Ple_Version + 1, Ple_UsuarioModifica = @Usuario, Ple_FechaModifica = @Ahora
            WHERE Ple_Id = @Ple_Id;

        -- Tipos: cambiar los que siguen, quitar (lógico) los que ya no vienen, agregar los nuevos.
        UPDATE t SET Plt_Nombre = x.Nombre, Plt_Peso = x.Peso, Plt_Combinacion = x.Comb, Plt_Orden = x.Fila
        FROM app.tbPlantillasEvaluacionTipos t JOIN @T x ON x.Plt_Id = t.Plt_Id
        WHERE t.Ple_Id = @Ple_Id;
        UPDATE t SET Plt_EsEliminado = 1
        FROM app.tbPlantillasEvaluacionTipos t
        WHERE t.Ple_Id = @Ple_Id AND t.Plt_EsEliminado = 0 AND NOT EXISTS (SELECT 1 FROM @T x WHERE x.Plt_Id = t.Plt_Id);
        INSERT INTO app.tbPlantillasEvaluacionTipos (Ple_Id, Plt_Nombre, Plt_Peso, Plt_Combinacion, Plt_Orden, Plt_EsEliminado)
        SELECT @Ple_Id, x.Nombre, x.Peso, x.Comb, x.Fila, 0 FROM @T x WHERE x.Plt_Id IS NULL;

        -- Cuadernos de parciales abiertos que usan la plantilla: se les copia lo nuevo.
        DECLARE @Abiertos TABLE (Cev_Id int PRIMARY KEY);
        INSERT INTO @Abiertos (Cev_Id)
        SELECT c.Cev_Id FROM app.tbCuadernosEvaluacion c
        WHERE c.Ple_Id = @Ple_Id
          AND NOT EXISTS (SELECT 1 FROM app.tbCierresParcial cp WITH (HOLDLOCK)
                          WHERE cp.Cpa_Anio = c.Cev_Anio AND cp.Sem_Id = c.Sem_Id AND cp.Pac_Id = c.Pac_Id AND cp.Cpa_Estado = 'cerrado');
        SET @Sinc = (SELECT COUNT(*) FROM @Abiertos);
        SET @Conservados = (SELECT COUNT(*) FROM app.tbCuadernosEvaluacion WHERE Ple_Id = @Ple_Id) - @Sinc;

        UPDATE ct SET Cet_Nombre = t.Plt_Nombre, Cet_Peso = t.Plt_Peso, Cet_Combinacion = t.Plt_Combinacion, Cet_Orden = t.Plt_Orden
        FROM app.tbCuadernosEvaluacionTipos ct
        JOIN @Abiertos o ON o.Cev_Id = ct.Cev_Id
        JOIN app.tbPlantillasEvaluacionTipos t ON t.Plt_Id = ct.Plt_Id AND t.Plt_EsEliminado = 0
        WHERE ct.Cet_EsEliminado = 0;
        UPDATE ct SET Cet_EsEliminado = 1
        FROM app.tbCuadernosEvaluacionTipos ct
        JOIN @Abiertos o ON o.Cev_Id = ct.Cev_Id
        JOIN app.tbPlantillasEvaluacionTipos t ON t.Plt_Id = ct.Plt_Id AND t.Plt_EsEliminado = 1
        WHERE ct.Cet_EsEliminado = 0;
        INSERT INTO app.tbCuadernosEvaluacionTipos (Cev_Id, Plt_Id, Cet_Nombre, Cet_Peso, Cet_Combinacion, Cet_Orden)
        SELECT o.Cev_Id, t.Plt_Id, t.Plt_Nombre, t.Plt_Peso, t.Plt_Combinacion, t.Plt_Orden
        FROM @Abiertos o
        JOIN app.tbPlantillasEvaluacionTipos t ON t.Ple_Id = @Ple_Id AND t.Plt_EsEliminado = 0
        WHERE NOT EXISTS (SELECT 1 FROM app.tbCuadernosEvaluacionTipos ct WHERE ct.Cev_Id = o.Cev_Id AND ct.Plt_Id = t.Plt_Id AND ct.Cet_EsEliminado = 0);
        UPDATE c SET Cev_Version = Cev_Version + 1, Cev_UsuarioModifica = @Usuario, Cev_FechaModifica = @Ahora
        FROM app.tbCuadernosEvaluacion c JOIN @Abiertos o ON o.Cev_Id = c.Cev_Id;

        -- Nuevos pesos = nuevas notas en los parciales abiertos (los cerrados no se tocan).
        DECLARE @Cuad int, @EscCuad int;
        DECLARE abiertos CURSOR LOCAL FAST_FORWARD FOR SELECT Cev_Id FROM @Abiertos ORDER BY Cev_Id;
        OPEN abiertos;
        FETCH NEXT FROM abiertos INTO @Cuad;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @EscCuad = 0;
            EXEC app.PR_Evaluacion_EscribirNotas @Cuad, @Usuario, @EscCuad OUTPUT;
            SET @Escritas += @EscCuad;
            FETCH NEXT FROM abiertos INTO @Cuad;
        END
        CLOSE abiertos;
        DEALLOCATE abiertos;

        SET @NuevaVersion = (SELECT Ple_Version FROM app.tbPlantillasEvaluacion WHERE Ple_Id = @Ple_Id);
    COMMIT TRANSACTION;

    SELECT @Ple_Id AS Id, @NuevaVersion AS Version, @Sinc AS Sincronizados, @Conservados AS Conservados, 0 AS Cantidad, 0 AS Omitidas,
           @Escritas AS NotasEscritas;
END
GO

/* Quitar una plantilla (borrado lógico) solo si ningún cuaderno la usa. */
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_QuitarPlantilla
    @Ple_Id  int,
    @Version int,
    @Usuario int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Msg nvarchar(400);
    IF ISNULL((SELECT Plantillas FROM app.FN_Evaluacion_Permisos(@Usuario)), 0) = 0
        THROW 50090, N'No tiene permiso para cambiar plantillas de evaluación.', 1;

    BEGIN TRANSACTION;
        EXEC app.PR_Evaluacion_Candado 1;
        DECLARE @VActual int;
        SELECT @VActual = Ple_Version FROM app.tbPlantillasEvaluacion WITH (UPDLOCK, HOLDLOCK)
        WHERE Ple_Id = @Ple_Id AND Ple_EsEliminado = 0;
        IF @VActual IS NULL
            THROW 50093, N'La plantilla ya no existe (otra persona la quitó). Recargue la página.', 1;
        IF @VActual <> ISNULL(@Version, -1)
            THROW 50093, N'Otra persona cambió esta plantilla. Recargue la página para ver lo último.', 1;
        DECLARE @EnUso int = (SELECT COUNT(*) FROM app.tbCuadernosEvaluacion WITH (HOLDLOCK) WHERE Ple_Id = @Ple_Id);
        IF @EnUso > 0
        BEGIN
            SET @Msg = CONCAT(N'Esta plantilla ya se usa en ', @EnUso, N' cuaderno(s) de notas: no se puede quitar. ',
                              N'Puede cambiar sus pesos (se aplican a los parciales abiertos).');
            THROW 50097, @Msg, 1;
        END
        UPDATE app.tbPlantillasEvaluacion
        SET Ple_EsEliminado = 1, Ple_Version = Ple_Version + 1, Ple_UsuarioModifica = @Usuario, Ple_FechaModifica = app.FN_AhoraHonduras()
        WHERE Ple_Id = @Ple_Id;
        UPDATE app.tbPlantillasEvaluacionTipos SET Plt_EsEliminado = 1 WHERE Ple_Id = @Ple_Id;
    COMMIT TRANSACTION;

    SELECT @Ple_Id AS Id, @VActual + 1 AS Version, 0 AS Sincronizados, 0 AS Conservados, 1 AS Cantidad, 0 AS Omitidas, 0 AS NotasEscritas;
END
GO

/* Uso de las actividades por grupo (Dirección, espejo del directorio de cuadernos de Skuul): por cada materia
   y sección del horario del semestre, qué plantilla aplica, cuántas actividades hay, cuánto se ha calificado
   y si la nota del parcial está al día con el cálculo. Las notas que faltan se ven en Cierre de parciales. */
CREATE OR ALTER PROCEDURE app.PR_Evaluacion_Avance
    @Anio   int,
    @Sem_Id int,
    @Pac_Id int,
    @Usu_Id int
AS
BEGIN
    SET NOCOUNT ON;
    IF ISNULL((SELECT Plantillas FROM app.FN_Evaluacion_Permisos(@Usu_Id)), 0) = 0
        THROW 50090, N'No tiene permiso para ver las plantillas de evaluación.', 1;

    WITH g AS (
        SELECT MIN(h.Hor_Id) AS Hor_Id, h.Mat_Id, h.Sec_Id, h.Cur_Id, h.Cun_Id
        FROM app.tbHorarios h
        WHERE h.Hor_Año = @Anio AND h.Sem_Id = @Sem_Id AND ISNULL(h.Hor_EsEliminado, 0) = 0
        GROUP BY h.Mat_Id, h.Sec_Id, h.Cur_Id, h.Cun_Id
    )
    SELECT g.Hor_Id, @Pac_Id AS Pac_Id,
           ISNULL(d.Docentes, N'Sin docente en el horario') AS Docente,
           LTRIM(RTRIM(niv.Niv_Descripcion)) AS Nivel,
           LTRIM(RTRIM(cn.Cun_Descripcion)) AS Grado, ISNULL(cn.Cun_Orden, 0) AS GradoOrden,
           LTRIM(RTRIM(s.Sec_Descripcion)) AS Seccion,
           app.FN_Temario_Texto(cur.Cur_Nombre) AS Curso,
           LTRIM(RTRIM(m.Mat_Nombre)) AS Materia,
           c.Cev_Id,
           pl.Ple_Nombre AS Plantilla,
           al.Alumnos,
           ISNULL(ac.Actividades, 0) AS Actividades,
           ISNULL(ac.Cuentan, 0) AS ActividadesQueCuentan,
           ISNULL(pu.Capturadas, 0) AS Capturadas,
           ISNULL(ac.Cuentan, 0) * al.Alumnos AS Esperadas,
           CAST(CASE WHEN ISNULL(ac.Cuentan, 0) * al.Alumnos = 0 THEN NULL
                     ELSE ROUND(100.0 * ISNULL(pu.Capturadas, 0) / (ac.Cuentan * al.Alumnos), 1) END AS decimal(5,1)) AS Porcentaje,
           ISNULL(nt.ConCalculo, 0) AS ConCalculo,
           ISNULL(nt.AlDia, 0) AS NotasAlDia,
           c.Cev_FechaModifica AS UltimoCambio,
           CASE WHEN ISNULL(ac.Actividades, 0) = 0 THEN 'directa'
                WHEN ISNULL(ac.Cuentan, 0) > 0 AND ISNULL(pu.Capturadas, 0) >= ac.Cuentan * al.Alumnos THEN 'completo'
                ELSE 'en_curso' END AS Estado
    FROM g
    JOIN app.tbMaterias m             ON m.Mat_Id = g.Mat_Id
    JOIN app.tbSecciones s            ON s.Sec_Id = g.Sec_Id
    JOIN app.tbCursos cur             ON cur.Cur_Id = g.Cur_Id
    JOIN app.tbCursosNiveles cn       ON cn.Cun_Id = g.Cun_Id
    LEFT JOIN app.tbNivelesEducativos niv ON niv.Niv_Id = COALESCE(cur.Niv_Id, cn.Niv_Id)
    LEFT JOIN app.tbCuadernosEvaluacion c
           ON c.Cev_Anio = @Anio AND c.Sem_Id = @Sem_Id AND c.Pac_Id = @Pac_Id AND c.Sec_Id = g.Sec_Id
          AND c.Mat_Id = g.Mat_Id AND c.Cur_Id = g.Cur_Id AND c.Cun_Id = g.Cun_Id
    LEFT JOIN app.tbPlantillasEvaluacion pl
           ON pl.Ple_Id = ISNULL(c.Ple_Id, app.FN_Evaluacion_PlantillaDe(@Anio, COALESCE(cur.Niv_Id, cn.Niv_Id), g.Mat_Id))
    CROSS APPLY (SELECT COUNT(*) AS Alumnos FROM app.FN_Evaluacion_Alumnos(@Anio, g.Sec_Id, g.Cur_Id, g.Cun_Id)) al
    OUTER APPLY (SELECT COUNT(*) AS Actividades, SUM(CASE WHEN a.Act_NoCuenta = 0 THEN 1 ELSE 0 END) AS Cuentan
                 FROM app.tbActividadesEvaluacion a WHERE a.Cev_Id = c.Cev_Id AND a.Act_EsEliminado = 0) ac
    OUTER APPLY (SELECT COUNT(*) AS Capturadas
                 FROM app.tbActividadesPuntos p
                 JOIN app.tbActividadesEvaluacion a ON a.Act_Id = p.Act_Id AND a.Cev_Id = c.Cev_Id AND a.Act_EsEliminado = 0 AND a.Act_NoCuenta = 0
                 JOIN app.FN_Evaluacion_Alumnos(@Anio, g.Sec_Id, g.Cur_Id, g.Cun_Id) x ON x.Alu_Id = p.Alu_Id
                 WHERE p.Acp_Estado <> 'vacio') pu
    OUTER APPLY (SELECT COUNT(*) AS ConCalculo, SUM(ISNULL(nn.Igual, 0)) AS AlDia
                 FROM app.FN_Evaluacion_Calculo(c.Cev_Id) k
                 JOIN app.FN_Evaluacion_Alumnos(@Anio, g.Sec_Id, g.Cur_Id, g.Cun_Id) x ON x.Alu_Id = k.Alu_Id
                 OUTER APPLY (SELECT TOP (1) 1 AS Igual FROM app.tbNotas n
                              WHERE n.Alu_Id = k.Alu_Id AND n.Sec_Id = g.Sec_Id AND n.Mat_Id = g.Mat_Id AND n.Pac_Id = @Pac_Id
                                AND n.Sem_Id = @Sem_Id AND YEAR(n.Not_Año) = @Anio AND n.Not_EsEliminado = 0
                                AND n.Not_Nota = k.Entera) nn) nt
    OUTER APPLY (
        SELECT STRING_AGG(x.Nombre, N', ') WITHIN GROUP (ORDER BY x.Nombre) AS Docentes
        FROM (SELECT DISTINCT LTRIM(RTRIM(CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(pe.Per_PrimerNombre)), N''),
                                                         NULLIF(LTRIM(RTRIM(pe.Per_ApellidoPaterno)), N'')))) AS Nombre
              FROM app.tbHorarios h
              JOIN app.tbEmpleados e  ON e.Emp_Id = h.Emp_Id
              JOIN app.tbPersonas  pe ON pe.Per_Id = e.Per_Id
              WHERE h.Hor_Año = @Anio AND h.Sem_Id = @Sem_Id AND ISNULL(h.Hor_EsEliminado, 0) = 0
                AND h.Mat_Id = g.Mat_Id AND h.Sec_Id = g.Sec_Id AND h.Cur_Id = g.Cur_Id AND h.Cun_Id = g.Cun_Id) x) d
    ORDER BY ISNULL(cn.Cun_Orden, 0), cn.Cun_Descripcion, s.Sec_Descripcion, cur.Cur_Nombre, m.Mat_Nombre;
END
GO

/* ───────────────────────────── Permisos ─────────────────────────────
   Plantillas de evaluación = ver, crear, editar y quitar plantillas y ver el uso por grupo (admin, director).
   El docente usa el permiso actual "Cuaderno de notas" (admin, director, Docente) para sus actividades. */
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES (N'Plantillas de evaluación', N'|admin|director|');

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

PRINT '089 Notas ponderadas OK';
GO
