"""
Genera Fase 3 — Módulo Académico (pendientes):
  - Plan de Clases / Sílabo   (app.tbPlanClases)
  - Tareas y Entregas         (app.tbTareas)
  - Mis Alumnos (galería)     (SP sobre tablas existentes)
  - Mapa de Ocupación de Aulas(SP sobre tablas existentes)

Por cada módulo produce:
  SQL   → Scripts/013_Tablas_Fase3.sql, 014_SPs_Fase3.sql, 015_Pantallas_Fase3.sql
  API   → Entity / IRepo / Repo / IService / Service / Controller
  ADM   → ADM-Service / Controller / View / JS  +  csproj y sidebar patches
  DI    → Program.cs (API)
"""
import os, re

# ── rutas base ──────────────────────────────────────────────────────────────
API_ROOT = r"C:\Users\nayel\OneDrive\Documentos\GitHub\001 Proyectos Estables\Gestion Colegial\Gestion.Colegial.Api"
ADM_ROOT = r"C:\Users\nayel\OneDrive\Documentos\GitHub\001 Proyectos Estables\Gestion Colegial\GESTION_COLEGIAL_ADM"

ENTITIES = os.path.join(API_ROOT, "Gestion.Colegial.Entities", "Entities", "dbo")
DA_INT   = os.path.join(API_ROOT, "Gestion.Colegial.DataAccess", "Interfaces")
DA_REPO  = os.path.join(API_ROOT, "Gestion.Colegial.DataAccess", "Repositories")
BIZ_INT  = os.path.join(API_ROOT, "Gestion.Colegial.Business", "Interfaces")
BIZ_SVC  = os.path.join(API_ROOT, "Gestion.Colegial.Business", "Services")
API_CTRL = os.path.join(API_ROOT, "Gestion.Colegial.Api", "Controllers")
SCRIPTS  = os.path.join(API_ROOT, "Scripts")
PROGRAM  = os.path.join(API_ROOT, "Gestion.Colegial.Api", "Program.cs")

ADM_BIZ        = os.path.join(ADM_ROOT, "GESTION_COLEGIAL.Business")
ADM_UI         = os.path.join(ADM_ROOT, "GESTION_COLEGIAL.UI")
ADM_UI_CSPROJ  = os.path.join(ADM_UI,  "GESTION_COLEGIAL.UI.csproj")
ADM_BIZ_CSPROJ = os.path.join(ADM_BIZ, "GESTION_COLEGIAL.Business.csproj")
ADM_SIDEBAR    = os.path.join(ADM_UI,  "Views", "Shared", "_sidebar.cshtml")

# ── helpers ──────────────────────────────────────────────────────────────────
def write(path, content):
    if os.path.exists(path):
        rel = os.path.relpath(path, API_ROOT if path.startswith(API_ROOT) else ADM_ROOT)
        print(f"  [SKIP] {rel}")
        return False
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    rel = os.path.relpath(path, API_ROOT if path.startswith(API_ROOT) else ADM_ROOT)
    print(f"  [OK]   {rel}")
    return True

def overwrite(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    rel = os.path.relpath(path, API_ROOT if path.startswith(API_ROOT) else ADM_ROOT)
    print(f"  [OW]   {rel}")

def add_to_csproj(csproj, entries, anchor):
    with open(csproj, encoding="utf-8") as f:
        txt = f.read()
    added = []
    for entry in entries:
        tag = f'<Compile Include="{entry}" />'
        if tag in txt:
            continue
        txt = txt.replace(anchor, tag + "\n    " + anchor, 1)
        added.append(entry)
    if added:
        with open(csproj, "w", encoding="utf-8") as f:
            f.write(txt)
        for e in added:
            print(f"  [CSPROJ] {e}")

def patch_program_cs(repo_lines, svc_lines):
    with open(PROGRAM, encoding="utf-8") as f:
        txt = f.read()
    repo_anchor = "// Repositorios Fase 1 (Infraestructura compartida)"
    svc_anchor  = "// Servicios Fase 1 (Infraestructura compartida)"
    changed = False
    for line in repo_lines:
        if line.strip() in txt:
            continue
        txt = txt.replace(repo_anchor, line + "\n" + repo_anchor, 1)
        print(f"  [Program.cs] {line.strip()}")
        changed = True
    for line in svc_lines:
        if line.strip() in txt:
            continue
        txt = txt.replace(svc_anchor, line + "\n" + svc_anchor, 1)
        print(f"  [Program.cs] {line.strip()}")
        changed = True
    if changed:
        with open(PROGRAM, "w", encoding="utf-8") as f:
            f.write(txt)


# ═══════════════════════════════════════════════════════════════════════════════
# 1. SCRIPTS SQL
# ═══════════════════════════════════════════════════════════════════════════════
def gen_sql_tablas():
    write(os.path.join(SCRIPTS, "013_Tablas_Fase3.sql"), """\
USE [DB_GestionColegial]
GO

-- ── tbPlanClases ─────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbPlanClases' AND schema_id = SCHEMA_ID('app'))
BEGIN
    CREATE TABLE [app].[tbPlanClases] (
        [Pla_Id]             INT IDENTITY(1,1)  NOT NULL,
        [Hor_Id]             INT                NOT NULL,
        [Pla_Semana]         SMALLINT           NOT NULL,
        [Pla_Tema]           NVARCHAR(200)      NOT NULL,
        [Pla_Objetivos]      NVARCHAR(MAX)      NULL,
        [Pla_Recursos]       NVARCHAR(300)      NULL,
        [Pla_Estado]         NVARCHAR(20)       NOT NULL CONSTRAINT [DF_tbPlanClases_Estado] DEFAULT ('Pendiente'),
        [Pla_EsEliminado]    BIT                NOT NULL CONSTRAINT [DF_tbPlanClases_EsEliminado] DEFAULT (0),
        [Pla_UsuarioRegistra] INT               NOT NULL,
        [Pla_FechaRegistra]  DATETIME           NOT NULL CONSTRAINT [DF_tbPlanClases_FechaRegistra] DEFAULT (GETDATE()),
        [Pla_UsuarioModifica] INT               NULL,
        [Pla_FechaModifica]  DATETIME           NULL,
        CONSTRAINT [PK_tbPlanClases] PRIMARY KEY CLUSTERED ([Pla_Id] ASC),
        CONSTRAINT [FK_tbPlanClases_Hor_Id] FOREIGN KEY ([Hor_Id]) REFERENCES [app].[tbHorarios]([Hor_Id])
    );
    PRINT 'tbPlanClases creada.';
END
ELSE
    PRINT 'tbPlanClases ya existe.';
GO

-- ── tbTareas ─────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbTareas' AND schema_id = SCHEMA_ID('app'))
BEGIN
    CREATE TABLE [app].[tbTareas] (
        [Tar_Id]             INT IDENTITY(1,1)  NOT NULL,
        [Hor_Id]             INT                NOT NULL,
        [Tar_Titulo]         NVARCHAR(200)      NOT NULL,
        [Tar_Descripcion]    NVARCHAR(MAX)      NULL,
        [Tar_FechaEntrega]   DATE               NOT NULL,
        [Tar_Punteo]         DECIMAL(5,2)       NOT NULL CONSTRAINT [DF_tbTareas_Punteo] DEFAULT (100),
        [Tar_Estado]         NVARCHAR(20)       NOT NULL CONSTRAINT [DF_tbTareas_Estado] DEFAULT ('Activa'),
        [Tar_EsEliminado]    BIT                NOT NULL CONSTRAINT [DF_tbTareas_EsEliminado] DEFAULT (0),
        [Tar_UsuarioRegistra] INT               NOT NULL,
        [Tar_FechaRegistra]  DATETIME           NOT NULL CONSTRAINT [DF_tbTareas_FechaRegistra] DEFAULT (GETDATE()),
        [Tar_UsuarioModifica] INT               NULL,
        [Tar_FechaModifica]  DATETIME           NULL,
        CONSTRAINT [PK_tbTareas] PRIMARY KEY CLUSTERED ([Tar_Id] ASC),
        CONSTRAINT [FK_tbTareas_Hor_Id] FOREIGN KEY ([Hor_Id]) REFERENCES [app].[tbHorarios]([Hor_Id])
    );
    PRINT 'tbTareas creada.';
END
ELSE
    PRINT 'tbTareas ya existe.';
GO
""")


def gen_sql_sps():
    write(os.path.join(SCRIPTS, "014_SPs_Fase3.sql"), r"""USE [DB_GestionColegial]
GO

-- ╔══════════════════════════════════════════════════════╗
-- ║  PLAN DE CLASES                                      ║
-- ╚══════════════════════════════════════════════════════╝

IF OBJECT_ID('[app].[PR_tbPlanClases_List]') IS NOT NULL DROP PROCEDURE [app].[PR_tbPlanClases_List]; GO
CREATE PROCEDURE [app].[PR_tbPlanClases_List] @Hor_Id INT AS BEGIN
    SET NOCOUNT ON;
    SELECT p.Pla_Id, p.Hor_Id, p.Pla_Semana, p.Pla_Tema,
           p.Pla_Objetivos, p.Pla_Recursos, p.Pla_Estado, p.Pla_FechaRegistra,
           m.Mat_Nombre, s.Sec_Descripcion
    FROM   [app].[tbPlanClases] p
    INNER JOIN [app].[tbHorarios]  h ON p.Hor_Id = h.Hor_Id
    INNER JOIN [app].[tbMaterias]  m ON h.Mat_Id = m.Mat_Id
    INNER JOIN [app].[tbSecciones] s ON h.Sec_Id = s.Sec_Id
    WHERE  p.Pla_EsEliminado = 0 AND p.Hor_Id = @Hor_Id
    ORDER BY p.Pla_Semana;
END
GO

IF OBJECT_ID('[app].[PR_tbPlanClases_Find]') IS NOT NULL DROP PROCEDURE [app].[PR_tbPlanClases_Find]; GO
CREATE PROCEDURE [app].[PR_tbPlanClases_Find] @Pla_Id INT AS BEGIN
    SET NOCOUNT ON;
    SELECT p.Pla_Id, p.Hor_Id, p.Pla_Semana, p.Pla_Tema,
           p.Pla_Objetivos, p.Pla_Recursos, p.Pla_Estado
    FROM   [app].[tbPlanClases] p
    WHERE  p.Pla_Id = @Pla_Id AND p.Pla_EsEliminado = 0;
END
GO

IF OBJECT_ID('[app].[PR_tbPlanClases_Insert]') IS NOT NULL DROP PROCEDURE [app].[PR_tbPlanClases_Insert]; GO
CREATE PROCEDURE [app].[PR_tbPlanClases_Insert]
    @Hor_Id INT, @Pla_Semana SMALLINT, @Pla_Tema NVARCHAR(200),
    @Pla_Objetivos NVARCHAR(MAX) = NULL, @Pla_Recursos NVARCHAR(300) = NULL,
    @Pla_UsuarioRegistra INT
AS BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO [app].[tbPlanClases]
            (Hor_Id, Pla_Semana, Pla_Tema, Pla_Objetivos, Pla_Recursos, Pla_UsuarioRegistra, Pla_FechaRegistra)
        VALUES (@Hor_Id, @Pla_Semana, @Pla_Tema, @Pla_Objetivos, @Pla_Recursos, @Pla_UsuarioRegistra, GETDATE());
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH ROLLBACK; SELECT 0 AS CodeResult; END CATCH
END
GO

IF OBJECT_ID('[app].[PR_tbPlanClases_Update]') IS NOT NULL DROP PROCEDURE [app].[PR_tbPlanClases_Update]; GO
CREATE PROCEDURE [app].[PR_tbPlanClases_Update]
    @Pla_Id INT, @Pla_Semana SMALLINT, @Pla_Tema NVARCHAR(200),
    @Pla_Objetivos NVARCHAR(MAX) = NULL, @Pla_Recursos NVARCHAR(300) = NULL,
    @Pla_Estado NVARCHAR(20), @Pla_UsuarioModifica INT
AS BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE [app].[tbPlanClases]
        SET    Pla_Semana = @Pla_Semana, Pla_Tema = @Pla_Tema,
               Pla_Objetivos = @Pla_Objetivos, Pla_Recursos = @Pla_Recursos,
               Pla_Estado = @Pla_Estado,
               Pla_UsuarioModifica = @Pla_UsuarioModifica, Pla_FechaModifica = GETDATE()
        WHERE  Pla_Id = @Pla_Id;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH ROLLBACK; SELECT 0 AS CodeResult; END CATCH
END
GO

IF OBJECT_ID('[app].[PR_tbPlanClases_Delete]') IS NOT NULL DROP PROCEDURE [app].[PR_tbPlanClases_Delete]; GO
CREATE PROCEDURE [app].[PR_tbPlanClases_Delete] @Pla_Id INT, @Pla_UsuarioModifica INT AS BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE [app].[tbPlanClases]
        SET    Pla_EsEliminado = 1, Pla_UsuarioModifica = @Pla_UsuarioModifica, Pla_FechaModifica = GETDATE()
        WHERE  Pla_Id = @Pla_Id;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH ROLLBACK; SELECT 0 AS CodeResult; END CATCH
END
GO

-- ╔══════════════════════════════════════════════════════╗
-- ║  TAREAS Y ENTREGAS                                   ║
-- ╚══════════════════════════════════════════════════════╝

IF OBJECT_ID('[app].[PR_tbTareas_List]') IS NOT NULL DROP PROCEDURE [app].[PR_tbTareas_List]; GO
CREATE PROCEDURE [app].[PR_tbTareas_List] @Hor_Id INT AS BEGIN
    SET NOCOUNT ON;
    SELECT t.Tar_Id, t.Hor_Id, t.Tar_Titulo, t.Tar_Descripcion,
           t.Tar_FechaEntrega, t.Tar_Punteo, t.Tar_Estado, t.Tar_FechaRegistra,
           m.Mat_Nombre, s.Sec_Descripcion
    FROM   [app].[tbTareas] t
    INNER JOIN [app].[tbHorarios]  h ON t.Hor_Id = h.Hor_Id
    INNER JOIN [app].[tbMaterias]  m ON h.Mat_Id = m.Mat_Id
    INNER JOIN [app].[tbSecciones] s ON h.Sec_Id = s.Sec_Id
    WHERE  t.Tar_EsEliminado = 0 AND t.Hor_Id = @Hor_Id
    ORDER BY t.Tar_FechaEntrega;
END
GO

IF OBJECT_ID('[app].[PR_tbTareas_Find]') IS NOT NULL DROP PROCEDURE [app].[PR_tbTareas_Find]; GO
CREATE PROCEDURE [app].[PR_tbTareas_Find] @Tar_Id INT AS BEGIN
    SET NOCOUNT ON;
    SELECT t.Tar_Id, t.Hor_Id, t.Tar_Titulo, t.Tar_Descripcion,
           t.Tar_FechaEntrega, t.Tar_Punteo, t.Tar_Estado
    FROM   [app].[tbTareas] t WHERE t.Tar_Id = @Tar_Id AND t.Tar_EsEliminado = 0;
END
GO

IF OBJECT_ID('[app].[PR_tbTareas_Insert]') IS NOT NULL DROP PROCEDURE [app].[PR_tbTareas_Insert]; GO
CREATE PROCEDURE [app].[PR_tbTareas_Insert]
    @Hor_Id INT, @Tar_Titulo NVARCHAR(200), @Tar_Descripcion NVARCHAR(MAX) = NULL,
    @Tar_FechaEntrega DATE, @Tar_Punteo DECIMAL(5,2) = 100, @Tar_UsuarioRegistra INT
AS BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO [app].[tbTareas]
            (Hor_Id, Tar_Titulo, Tar_Descripcion, Tar_FechaEntrega, Tar_Punteo, Tar_UsuarioRegistra, Tar_FechaRegistra)
        VALUES (@Hor_Id, @Tar_Titulo, @Tar_Descripcion, @Tar_FechaEntrega, @Tar_Punteo, @Tar_UsuarioRegistra, GETDATE());
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH ROLLBACK; SELECT 0 AS CodeResult; END CATCH
END
GO

IF OBJECT_ID('[app].[PR_tbTareas_Update]') IS NOT NULL DROP PROCEDURE [app].[PR_tbTareas_Update]; GO
CREATE PROCEDURE [app].[PR_tbTareas_Update]
    @Tar_Id INT, @Tar_Titulo NVARCHAR(200), @Tar_Descripcion NVARCHAR(MAX) = NULL,
    @Tar_FechaEntrega DATE, @Tar_Punteo DECIMAL(5,2), @Tar_Estado NVARCHAR(20),
    @Tar_UsuarioModifica INT
AS BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE [app].[tbTareas]
        SET    Tar_Titulo = @Tar_Titulo, Tar_Descripcion = @Tar_Descripcion,
               Tar_FechaEntrega = @Tar_FechaEntrega, Tar_Punteo = @Tar_Punteo,
               Tar_Estado = @Tar_Estado,
               Tar_UsuarioModifica = @Tar_UsuarioModifica, Tar_FechaModifica = GETDATE()
        WHERE  Tar_Id = @Tar_Id;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH ROLLBACK; SELECT 0 AS CodeResult; END CATCH
END
GO

IF OBJECT_ID('[app].[PR_tbTareas_Delete]') IS NOT NULL DROP PROCEDURE [app].[PR_tbTareas_Delete]; GO
CREATE PROCEDURE [app].[PR_tbTareas_Delete] @Tar_Id INT, @Tar_UsuarioModifica INT AS BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE [app].[tbTareas]
        SET    Tar_EsEliminado = 1, Tar_UsuarioModifica = @Tar_UsuarioModifica, Tar_FechaModifica = GETDATE()
        WHERE  Tar_Id = @Tar_Id;
        SELECT 1 AS CodeResult;
    END TRY
    BEGIN CATCH ROLLBACK; SELECT 0 AS CodeResult; END CATCH
END
GO

-- ╔══════════════════════════════════════════════════════╗
-- ║  MIS ALUMNOS (DOCENTE)                               ║
-- ╚══════════════════════════════════════════════════════╝

IF OBJECT_ID('[app].[PR_Docente_MisAlumnos]') IS NOT NULL DROP PROCEDURE [app].[PR_Docente_MisAlumnos]; GO
CREATE PROCEDURE [app].[PR_Docente_MisAlumnos] @Hor_Id INT AS BEGIN
    SET NOCOUNT ON;
    DECLARE @Sec_Id INT;
    SELECT @Sec_Id = Sec_Id FROM [app].[tbHorarios] WHERE Hor_Id = @Hor_Id AND Hor_EsEliminado = 0;

    SELECT a.Alu_Id,
           LTRIM(RTRIM(CONCAT(
               p.Per_PrimerNombre, ' ',
               ISNULL(p.Per_SegundoNombre + ' ', ''),
               p.Per_ApellidoPaterno, ' ',
               ISNULL(p.Per_ApellidoMaterno, '')
           ))) AS NombreCompleto,
           p.Per_Imagen,
           s.Sec_Descripcion
    FROM   [app].[tbAlumnos]   a
    INNER JOIN [app].[tbPersonas]  p ON a.Per_Id  = p.Per_Id
    INNER JOIN [app].[tbSecciones] s ON a.Sec_Id  = s.Sec_Id
    WHERE  a.Sec_Id = @Sec_Id AND a.Alu_EsEliminado = 0
    ORDER BY p.Per_ApellidoPaterno, p.Per_PrimerNombre;
END
GO

-- ╔══════════════════════════════════════════════════════╗
-- ║  MAPA DE OCUPACIÓN DE AULAS                          ║
-- ╚══════════════════════════════════════════════════════╝

IF OBJECT_ID('[app].[PR_Aulas_MapaOcupacion]') IS NOT NULL DROP PROCEDURE [app].[PR_Aulas_MapaOcupacion]; GO
CREATE PROCEDURE [app].[PR_Aulas_MapaOcupacion] AS BEGIN
    SET NOCOUNT ON;
    SELECT a.Aul_Id,
           a.Aul_Descripcion,
           COUNT(h.Hor_Id)                                                    AS Horarios_Total,
           SUM(CASE WHEN h.Hor_Año = YEAR(GETDATE()) THEN 1 ELSE 0 END)      AS Horarios_Anio_Actual,
           (SELECT COUNT(*) FROM [app].[tbHorarios] h2
            WHERE h2.Aul_Id = a.Aul_Id AND h2.Hor_Año = YEAR(GETDATE())
              AND h2.Hor_EsEliminado = 0)                                     AS HorariosActuales
    FROM   [app].[tbAulas] a
    LEFT JOIN [app].[tbHorarios] h ON a.Aul_Id = h.Aul_Id AND h.Hor_EsEliminado = 0
    GROUP BY a.Aul_Id, a.Aul_Descripcion
    ORDER BY Horarios_Anio_Actual DESC, a.Aul_Descripcion;
END
GO
""")


def gen_sql_pantallas():
    write(os.path.join(SCRIPTS, "015_Pantallas_Fase3.sql"), """\
USE [DB_GestionColegial]
GO

DECLARE @PanId INT;

-- Plan de Clases
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Nombre = 'Plan de clases')
BEGIN
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Nombre) VALUES ('Plan de clases');
    SET @PanId = SCOPE_IDENTITY();

    DECLARE @RolId INT;
    SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'director';
    IF @RolId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
        INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
END
GO
DECLARE @PanId INT, @RolId INT;
SELECT @PanId = Pan_Id FROM [Seguridad].[tbPantallas] WHERE Pan_Nombre = 'Plan de clases';
SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'docente';
IF @RolId IS NOT NULL AND @PanId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
    INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
GO

-- Tareas y entregas
DECLARE @PanId INT;
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Nombre = 'Tareas y entregas')
BEGIN
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Nombre) VALUES ('Tareas y entregas');
    SET @PanId = SCOPE_IDENTITY();
    DECLARE @RolId INT;
    SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'docente';
    IF @RolId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
        INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
END
GO
DECLARE @PanId INT, @RolId INT;
SELECT @PanId = Pan_Id FROM [Seguridad].[tbPantallas] WHERE Pan_Nombre = 'Tareas y entregas';
SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'director';
IF @RolId IS NOT NULL AND @PanId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
    INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
GO

-- Mis alumnos
DECLARE @PanId INT;
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Nombre = 'Mis alumnos')
BEGIN
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Nombre) VALUES ('Mis alumnos');
    SET @PanId = SCOPE_IDENTITY();
    DECLARE @RolId INT;
    SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'docente';
    IF @RolId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
        INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
END
GO
DECLARE @PanId INT, @RolId INT;
SELECT @PanId = Pan_Id FROM [Seguridad].[tbPantallas] WHERE Pan_Nombre = 'Mis alumnos';
SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'director';
IF @RolId IS NOT NULL AND @PanId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
    INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
GO

-- Mapa de aulas
DECLARE @PanId INT;
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[tbPantallas] WHERE Pan_Nombre = 'Mapa de aulas')
BEGIN
    INSERT INTO [Seguridad].[tbPantallas] (Pan_Nombre) VALUES ('Mapa de aulas');
    SET @PanId = SCOPE_IDENTITY();
    DECLARE @RolId INT;
    SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'director';
    IF @RolId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
        INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
END
GO
DECLARE @PanId INT, @RolId INT;
SELECT @PanId = Pan_Id FROM [Seguridad].[tbPantallas] WHERE Pan_Nombre = 'Mapa de aulas';
SELECT @RolId = Rol_Id FROM [Seguridad].[tbRoles] WHERE Rol_Descripcion = 'secretaria';
IF @RolId IS NOT NULL AND @PanId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Seguridad].[tbRolesPantallas] WHERE Rol_Id = @RolId AND Pan_Id = @PanId)
    INSERT INTO [Seguridad].[tbRolesPantallas] (Rol_Id, Pan_Id) VALUES (@RolId, @PanId);
GO
""")


# ═══════════════════════════════════════════════════════════════════════════════
# 2. API — PLAN DE CLASES
# ═══════════════════════════════════════════════════════════════════════════════
def gen_api_plan_clases():
    # Entity
    write(os.path.join(ENTITIES, "PR_tbPlanClases_ListResult.cs"), """\
using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbPlanClases_ListResult
    {
        public int    Pla_Id           { get; set; }
        public int    Hor_Id           { get; set; }
        public short  Pla_Semana       { get; set; }
        public string Pla_Tema         { get; set; }
        public string Pla_Objetivos    { get; set; }
        public string Pla_Recursos     { get; set; }
        public string Pla_Estado       { get; set; }
        public DateTime Pla_FechaRegistra { get; set; }
        public string Mat_Nombre       { get; set; }
        public string Sec_Descripcion  { get; set; }
    }
}
""")
    write(os.path.join(ENTITIES, "PR_tbPlanClases_FindResult.cs"), """\
namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbPlanClases_FindResult
    {
        public int    Pla_Id        { get; set; }
        public int    Hor_Id        { get; set; }
        public short  Pla_Semana    { get; set; }
        public string Pla_Tema      { get; set; }
        public string Pla_Objetivos { get; set; }
        public string Pla_Recursos  { get; set; }
        public string Pla_Estado    { get; set; }
    }
}
""")

    # DataAccess interface
    write(os.path.join(DA_INT, "IPlanClasesRepository.cs"), """\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IPlanClasesRepository
    {
        Task<Answer> List(int Hor_Id);
        Task<Answer> Find(int Pla_Id);
        Task<Answer> Insert(int Hor_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, int usuarioRegistra);
        Task<Answer> Update(int Pla_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, string Pla_Estado, int usuarioModifica);
        Task<Answer> Delete(int Pla_Id, int usuarioModifica);
    }
}
""")

    # DataAccess repository
    write(os.path.join(DA_REPO, "PlanClasesRepository.cs"), """\
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class PlanClasesRepository : RepositoryBase, IPlanClasesRepository
    {
        public async Task<Answer> List(int Hor_Id)
        {
            const string sql = "PR_tbPlanClases_List";
            SqlParameter[] p = { new SqlParameter { ParameterName = "@Hor_Id", DbType = DbType.Int32, Value = Hor_Id } };
            return await SearchAll<PR_tbPlanClases_ListResult>(sql, p);
        }

        public async Task<Answer> Find(int Pla_Id)
        {
            const string sql = "PR_tbPlanClases_Find";
            SqlParameter[] p = { new SqlParameter { ParameterName = "@Pla_Id", DbType = DbType.Int32, Value = Pla_Id } };
            return await Search<PR_tbPlanClases_FindResult>(sql, p);
        }

        public async Task<Answer> Insert(int Hor_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, int usuarioRegistra)
        {
            const string sql = "PR_tbPlanClases_Insert";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Hor_Id",              DbType = DbType.Int32,  Value = Hor_Id },
                new SqlParameter { ParameterName = "@Pla_Semana",          DbType = DbType.Int16,  Value = Pla_Semana },
                new SqlParameter { ParameterName = "@Pla_Tema",            DbType = DbType.String, Value = Pla_Tema },
                new SqlParameter { ParameterName = "@Pla_Objetivos",       DbType = DbType.String, Value = (object)Pla_Objetivos ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@Pla_Recursos",        DbType = DbType.String, Value = (object)Pla_Recursos  ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@Pla_UsuarioRegistra", DbType = DbType.Int32,  Value = usuarioRegistra },
            };
            return await New(sql, p);
        }

        public async Task<Answer> Update(int Pla_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, string Pla_Estado, int usuarioModifica)
        {
            const string sql = "PR_tbPlanClases_Update";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Pla_Id",              DbType = DbType.Int32,  Value = Pla_Id },
                new SqlParameter { ParameterName = "@Pla_Semana",          DbType = DbType.Int16,  Value = Pla_Semana },
                new SqlParameter { ParameterName = "@Pla_Tema",            DbType = DbType.String, Value = Pla_Tema },
                new SqlParameter { ParameterName = "@Pla_Objetivos",       DbType = DbType.String, Value = (object)Pla_Objetivos ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@Pla_Recursos",        DbType = DbType.String, Value = (object)Pla_Recursos  ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@Pla_Estado",          DbType = DbType.String, Value = Pla_Estado },
                new SqlParameter { ParameterName = "@Pla_UsuarioModifica", DbType = DbType.Int32,  Value = usuarioModifica },
            };
            return await Update(sql, p);
        }

        public async Task<Answer> Delete(int Pla_Id, int usuarioModifica)
        {
            const string sql = "PR_tbPlanClases_Delete";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Pla_Id",              DbType = DbType.Int32, Value = Pla_Id },
                new SqlParameter { ParameterName = "@Pla_UsuarioModifica", DbType = DbType.Int32, Value = usuarioModifica },
            };
            return await Delete(sql, p);
        }
    }
}
""")

    # Business interface
    write(os.path.join(BIZ_INT, "IPlanClasesService.cs"), """\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IPlanClasesService
    {
        Task<Answer> List(int Hor_Id);
        Task<Answer> Find(int Pla_Id);
        Task<Answer> Insert(int Hor_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, int usuarioRegistra);
        Task<Answer> Update(int Pla_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, string Pla_Estado, int usuarioModifica);
        Task<Answer> Delete(int Pla_Id, int usuarioModifica);
    }
}
""")

    # Business service
    write(os.path.join(BIZ_SVC, "PlanClasesService.cs"), """\
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class PlanClasesService : IPlanClasesService
    {
        private readonly IPlanClasesRepository _r;
        public PlanClasesService(IPlanClasesRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> task, string msg = null)
        {
            var a = await task;
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } else if (msg != null) a.Message = msg; }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); }
            return a;
        }

        public Task<Answer> List(int Hor_Id)   => Wrap(_r.List(Hor_Id));
        public Task<Answer> Find(int Pla_Id)   => Wrap(_r.Find(Pla_Id));
        public Task<Answer> Insert(int Hor_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, int usuarioRegistra)
            => Wrap(_r.Insert(Hor_Id, Pla_Semana, Pla_Tema, Pla_Objetivos, Pla_Recursos, usuarioRegistra), MessageShow.SuccessSave);
        public Task<Answer> Update(int Pla_Id, short Pla_Semana, string Pla_Tema, string Pla_Objetivos, string Pla_Recursos, string Pla_Estado, int usuarioModifica)
            => Wrap(_r.Update(Pla_Id, Pla_Semana, Pla_Tema, Pla_Objetivos, Pla_Recursos, Pla_Estado, usuarioModifica), MessageShow.SuccessEdit);
        public Task<Answer> Delete(int Pla_Id, int usuarioModifica)
            => Wrap(_r.Delete(Pla_Id, usuarioModifica), MessageShow.SuccessDelete);
    }
}
""")

    # API Controller
    write(os.path.join(API_CTRL, "PlanClasesController.cs"), """\
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class PlanClasesController : ControllerBase
    {
        private readonly IPlanClasesService _service;
        public PlanClasesController(IPlanClasesService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Hor_Id)
        {
            Answer answer = await _service.List(Hor_Id);
            return Ok(answer.Data);
        }

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int Pla_Id)
        {
            Answer answer = await _service.Find(Pla_Id);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] PlanClasesCreateRequest req)
        {
            Answer answer = await _service.Insert(req.Hor_Id, req.Pla_Semana, req.Pla_Tema,
                req.Pla_Objetivos, req.Pla_Recursos, req.UsuarioRegistra);
            return Ok(answer);
        }

        [HttpPut("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] PlanClasesEditRequest req)
        {
            Answer answer = await _service.Update(req.Pla_Id, req.Pla_Semana, req.Pla_Tema,
                req.Pla_Objetivos, req.Pla_Recursos, req.Pla_Estado, req.UsuarioModifica);
            return Ok(answer);
        }

        [HttpDelete("DeleteAsync")]
        public async Task<IActionResult> Delete(int Pla_Id, int UsuarioModifica)
        {
            Answer answer = await _service.Delete(Pla_Id, UsuarioModifica);
            return Ok(answer);
        }
    }

    public class PlanClasesCreateRequest
    {
        public int    Hor_Id          { get; set; }
        public short  Pla_Semana      { get; set; }
        public string Pla_Tema        { get; set; }
        public string Pla_Objetivos   { get; set; }
        public string Pla_Recursos    { get; set; }
        public int    UsuarioRegistra  { get; set; }
    }

    public class PlanClasesEditRequest
    {
        public int    Pla_Id          { get; set; }
        public short  Pla_Semana      { get; set; }
        public string Pla_Tema        { get; set; }
        public string Pla_Objetivos   { get; set; }
        public string Pla_Recursos    { get; set; }
        public string Pla_Estado      { get; set; }
        public int    UsuarioModifica  { get; set; }
    }
}
""")


# ═══════════════════════════════════════════════════════════════════════════════
# 3. API — TAREAS
# ═══════════════════════════════════════════════════════════════════════════════
def gen_api_tareas():
    write(os.path.join(ENTITIES, "PR_tbTareas_ListResult.cs"), """\
using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbTareas_ListResult
    {
        public int      Tar_Id           { get; set; }
        public int      Hor_Id           { get; set; }
        public string   Tar_Titulo       { get; set; }
        public string   Tar_Descripcion  { get; set; }
        public DateTime Tar_FechaEntrega { get; set; }
        public decimal  Tar_Punteo       { get; set; }
        public string   Tar_Estado       { get; set; }
        public DateTime Tar_FechaRegistra { get; set; }
        public string   Mat_Nombre       { get; set; }
        public string   Sec_Descripcion  { get; set; }
    }
}
""")
    write(os.path.join(ENTITIES, "PR_tbTareas_FindResult.cs"), """\
using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbTareas_FindResult
    {
        public int      Tar_Id           { get; set; }
        public int      Hor_Id           { get; set; }
        public string   Tar_Titulo       { get; set; }
        public string   Tar_Descripcion  { get; set; }
        public DateTime Tar_FechaEntrega { get; set; }
        public decimal  Tar_Punteo       { get; set; }
        public string   Tar_Estado       { get; set; }
    }
}
""")

    write(os.path.join(DA_INT, "ITareasRepository.cs"), """\
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface ITareasRepository
    {
        Task<Answer> List(int Hor_Id);
        Task<Answer> Find(int Tar_Id);
        Task<Answer> Insert(int Hor_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, int usuarioRegistra);
        Task<Answer> Update(int Tar_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, string Tar_Estado, int usuarioModifica);
        Task<Answer> Delete(int Tar_Id, int usuarioModifica);
    }
}
""")

    write(os.path.join(DA_REPO, "TareasRepository.cs"), """\
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class TareasRepository : RepositoryBase, ITareasRepository
    {
        public async Task<Answer> List(int Hor_Id)
        {
            const string sql = "PR_tbTareas_List";
            SqlParameter[] p = { new SqlParameter { ParameterName = "@Hor_Id", DbType = DbType.Int32, Value = Hor_Id } };
            return await SearchAll<PR_tbTareas_ListResult>(sql, p);
        }

        public async Task<Answer> Find(int Tar_Id)
        {
            const string sql = "PR_tbTareas_Find";
            SqlParameter[] p = { new SqlParameter { ParameterName = "@Tar_Id", DbType = DbType.Int32, Value = Tar_Id } };
            return await Search<PR_tbTareas_FindResult>(sql, p);
        }

        public async Task<Answer> Insert(int Hor_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, int usuarioRegistra)
        {
            const string sql = "PR_tbTareas_Insert";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Hor_Id",             DbType = DbType.Int32,   Value = Hor_Id },
                new SqlParameter { ParameterName = "@Tar_Titulo",         DbType = DbType.String,  Value = Tar_Titulo },
                new SqlParameter { ParameterName = "@Tar_Descripcion",    DbType = DbType.String,  Value = (object)Tar_Descripcion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Tar_FechaEntrega",   DbType = DbType.Date,    Value = Tar_FechaEntrega },
                new SqlParameter { ParameterName = "@Tar_Punteo",         DbType = DbType.Decimal, Value = Tar_Punteo },
                new SqlParameter { ParameterName = "@Tar_UsuarioRegistra",DbType = DbType.Int32,   Value = usuarioRegistra },
            };
            return await New(sql, p);
        }

        public async Task<Answer> Update(int Tar_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, string Tar_Estado, int usuarioModifica)
        {
            const string sql = "PR_tbTareas_Update";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Tar_Id",              DbType = DbType.Int32,   Value = Tar_Id },
                new SqlParameter { ParameterName = "@Tar_Titulo",          DbType = DbType.String,  Value = Tar_Titulo },
                new SqlParameter { ParameterName = "@Tar_Descripcion",     DbType = DbType.String,  Value = (object)Tar_Descripcion ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Tar_FechaEntrega",    DbType = DbType.Date,    Value = Tar_FechaEntrega },
                new SqlParameter { ParameterName = "@Tar_Punteo",          DbType = DbType.Decimal, Value = Tar_Punteo },
                new SqlParameter { ParameterName = "@Tar_Estado",          DbType = DbType.String,  Value = Tar_Estado },
                new SqlParameter { ParameterName = "@Tar_UsuarioModifica", DbType = DbType.Int32,   Value = usuarioModifica },
            };
            return await Update(sql, p);
        }

        public async Task<Answer> Delete(int Tar_Id, int usuarioModifica)
        {
            const string sql = "PR_tbTareas_Delete";
            SqlParameter[] p = {
                new SqlParameter { ParameterName = "@Tar_Id",              DbType = DbType.Int32, Value = Tar_Id },
                new SqlParameter { ParameterName = "@Tar_UsuarioModifica", DbType = DbType.Int32, Value = usuarioModifica },
            };
            return await Delete(sql, p);
        }
    }
}
""")

    write(os.path.join(BIZ_INT, "ITareasService.cs"), """\
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface ITareasService
    {
        Task<Answer> List(int Hor_Id);
        Task<Answer> Find(int Tar_Id);
        Task<Answer> Insert(int Hor_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, int usuarioRegistra);
        Task<Answer> Update(int Tar_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, string Tar_Estado, int usuarioModifica);
        Task<Answer> Delete(int Tar_Id, int usuarioModifica);
    }
}
""")

    write(os.path.join(BIZ_SVC, "TareasService.cs"), """\
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class TareasService : ITareasService
    {
        private readonly ITareasRepository _r;
        public TareasService(ITareasRepository r) { _r = r; }

        private async Task<Answer> Wrap(Task<Answer> task, string msg = null)
        {
            var a = await task;
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } else if (msg != null) a.Message = msg; }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); }
            return a;
        }

        public Task<Answer> List(int Hor_Id)  => Wrap(_r.List(Hor_Id));
        public Task<Answer> Find(int Tar_Id)  => Wrap(_r.Find(Tar_Id));
        public Task<Answer> Insert(int Hor_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, int usuarioRegistra)
            => Wrap(_r.Insert(Hor_Id, Tar_Titulo, Tar_Descripcion, Tar_FechaEntrega, Tar_Punteo, usuarioRegistra), MessageShow.SuccessSave);
        public Task<Answer> Update(int Tar_Id, string Tar_Titulo, string Tar_Descripcion, DateTime Tar_FechaEntrega, decimal Tar_Punteo, string Tar_Estado, int usuarioModifica)
            => Wrap(_r.Update(Tar_Id, Tar_Titulo, Tar_Descripcion, Tar_FechaEntrega, Tar_Punteo, Tar_Estado, usuarioModifica), MessageShow.SuccessEdit);
        public Task<Answer> Delete(int Tar_Id, int usuarioModifica)
            => Wrap(_r.Delete(Tar_Id, usuarioModifica), MessageShow.SuccessDelete);
    }
}
""")

    write(os.path.join(API_CTRL, "TareasController.cs"), """\
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class TareasController : ControllerBase
    {
        private readonly ITareasService _service;
        public TareasController(ITareasService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Hor_Id)
        {
            Answer answer = await _service.List(Hor_Id);
            return Ok(answer.Data);
        }

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int Tar_Id)
        {
            Answer answer = await _service.Find(Tar_Id);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] TareaCreateRequest req)
        {
            Answer answer = await _service.Insert(req.Hor_Id, req.Tar_Titulo, req.Tar_Descripcion,
                req.Tar_FechaEntrega, req.Tar_Punteo, req.UsuarioRegistra);
            return Ok(answer);
        }

        [HttpPut("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] TareaEditRequest req)
        {
            Answer answer = await _service.Update(req.Tar_Id, req.Tar_Titulo, req.Tar_Descripcion,
                req.Tar_FechaEntrega, req.Tar_Punteo, req.Tar_Estado, req.UsuarioModifica);
            return Ok(answer);
        }

        [HttpDelete("DeleteAsync")]
        public async Task<IActionResult> Delete(int Tar_Id, int UsuarioModifica)
        {
            Answer answer = await _service.Delete(Tar_Id, UsuarioModifica);
            return Ok(answer);
        }
    }

    public class TareaCreateRequest
    {
        public int      Hor_Id           { get; set; }
        public string   Tar_Titulo       { get; set; }
        public string   Tar_Descripcion  { get; set; }
        public DateTime Tar_FechaEntrega { get; set; }
        public decimal  Tar_Punteo       { get; set; }
        public int      UsuarioRegistra  { get; set; }
    }

    public class TareaEditRequest
    {
        public int      Tar_Id           { get; set; }
        public string   Tar_Titulo       { get; set; }
        public string   Tar_Descripcion  { get; set; }
        public DateTime Tar_FechaEntrega { get; set; }
        public decimal  Tar_Punteo       { get; set; }
        public string   Tar_Estado       { get; set; }
        public int      UsuarioModifica  { get; set; }
    }
}
""")


# ═══════════════════════════════════════════════════════════════════════════════
# 4. API — MIS ALUMNOS
# ═══════════════════════════════════════════════════════════════════════════════
def gen_api_mis_alumnos():
    write(os.path.join(ENTITIES, "PR_Docente_MisAlumnosResult.cs"), """\
namespace Gestion.Colegial.Entities.Entities
{
    public class PR_Docente_MisAlumnosResult
    {
        public int    Alu_Id          { get; set; }
        public string NombreCompleto  { get; set; }
        public string Per_Imagen      { get; set; }
        public string Sec_Descripcion { get; set; }
    }
}
""")

    write(os.path.join(DA_INT, "IMisAlumnosRepository.cs"), """\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IMisAlumnosRepository
    {
        Task<Answer> GetByHorario(int Hor_Id);
    }
}
""")

    write(os.path.join(DA_REPO, "MisAlumnosRepository.cs"), """\
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class MisAlumnosRepository : RepositoryBase, IMisAlumnosRepository
    {
        public async Task<Answer> GetByHorario(int Hor_Id)
        {
            const string sql = "PR_Docente_MisAlumnos";
            SqlParameter[] p = { new SqlParameter { ParameterName = "@Hor_Id", DbType = DbType.Int32, Value = Hor_Id } };
            return await SearchAll<PR_Docente_MisAlumnosResult>(sql, p);
        }
    }
}
""")

    write(os.path.join(BIZ_INT, "IMisAlumnosService.cs"), """\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IMisAlumnosService
    {
        Task<Answer> GetByHorario(int Hor_Id);
    }
}
""")

    write(os.path.join(BIZ_SVC, "MisAlumnosService.cs"), """\
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class MisAlumnosService : IMisAlumnosService
    {
        private readonly IMisAlumnosRepository _r;
        public MisAlumnosService(IMisAlumnosRepository r) { _r = r; }

        public async Task<Answer> GetByHorario(int Hor_Id)
        {
            var a = await _r.GetByHorario(Hor_Id);
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); }
            return a;
        }
    }
}
""")

    write(os.path.join(API_CTRL, "MisAlumnosController.cs"), """\
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class MisAlumnosController : ControllerBase
    {
        private readonly IMisAlumnosService _service;
        public MisAlumnosController(IMisAlumnosService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Hor_Id)
        {
            Answer answer = await _service.GetByHorario(Hor_Id);
            return Ok(answer.Data);
        }
    }
}
""")


# ═══════════════════════════════════════════════════════════════════════════════
# 5. API — MAPA DE AULAS
# ═══════════════════════════════════════════════════════════════════════════════
def gen_api_mapa_aulas():
    write(os.path.join(ENTITIES, "PR_Aulas_MapaOcupacionResult.cs"), """\
namespace Gestion.Colegial.Entities.Entities
{
    public class PR_Aulas_MapaOcupacionResult
    {
        public int    Aul_Id              { get; set; }
        public string Aul_Descripcion     { get; set; }
        public int    Horarios_Total      { get; set; }
        public int    HorariosActuales    { get; set; }
    }
}
""")

    write(os.path.join(DA_INT, "IMapaAulasRepository.cs"), """\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IMapaAulasRepository
    {
        Task<Answer> GetMapa();
    }
}
""")

    write(os.path.join(DA_REPO, "MapaAulasRepository.cs"), """\
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class MapaAulasRepository : RepositoryBase, IMapaAulasRepository
    {
        public async Task<Answer> GetMapa()
        {
            const string sql = "PR_Aulas_MapaOcupacion";
            return await Read<PR_Aulas_MapaOcupacionResult>(sql);
        }
    }
}
""")

    write(os.path.join(BIZ_INT, "IMapaAulasService.cs"), """\
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IMapaAulasService
    {
        Task<Answer> GetMapa();
    }
}
""")

    write(os.path.join(BIZ_SVC, "MapaAulasService.cs"), """\
using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class MapaAulasService : IMapaAulasService
    {
        private readonly IMapaAulasRepository _r;
        public MapaAulasService(IMapaAulasRepository r) { _r = r; }

        public async Task<Answer> GetMapa()
        {
            var a = await _r.GetMapa();
            try { if (a.Access) { a.Message = MessageShow.Error; Logs.Error(a); } }
            catch (Exception e) { a.Access = true; a.Message = MessageShow.Error; a.Incidents(e); Logs.Error(a); }
            return a;
        }
    }
}
""")

    write(os.path.join(API_CTRL, "MapaAulasController.cs"), """\
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class MapaAulasController : ControllerBase
    {
        private readonly IMapaAulasService _service;
        public MapaAulasController(IMapaAulasService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _service.GetMapa();
            return Ok(answer.Data);
        }
    }
}
""")


# ═══════════════════════════════════════════════════════════════════════════════
# 6. ADM — PLAN DE CLASES
# ═══════════════════════════════════════════════════════════════════════════════
def gen_adm_plan_clases():
    write(os.path.join(ADM_BIZ, "Services", "PlanClasesAdmService.cs"), """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class PlanClasesAdmService
    {
        public async Task<List<dynamic>> ListAsync(int Hor_Id)
            => await SendHttpClient.GetAsync<dynamic>($"PlanClases/ListAsync?Hor_Id={Hor_Id}");

        public async Task<bool> CreateAsync(dynamic model)
            => await SendHttpClient.PostAsync("PlanClases/CreateAsync", model);

        public async Task<bool> EditAsync(dynamic model)
            => await SendHttpClient.PutAsync("PlanClases/EditAsync", model);

        public async Task<bool> DeleteAsync(int Pla_Id, int usuarioModifica)
            => await SendHttpClient.DeleteAsync($"PlanClases/DeleteAsync?Pla_Id={Pla_Id}&UsuarioModifica={usuarioModifica}");
    }
}
""")

    write(os.path.join(ADM_UI, "Controllers", "PlanClasesAdmController.cs"), """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Extensions;
using GESTION_COLEGIAL.UI.Filters;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Plan de clases")]
    public class PlanClasesAdmController : BaseController
    {
        private readonly PlanClasesAdmService _service  = new PlanClasesAdmService();
        private readonly HorariosService      _horarios = new HorariosService();

        public ActionResult Index() => View();

        public async Task<ActionResult> DropdownsAsync()
        {
            var horarios = await _horarios.ListAsync();
            return Json(new
            {
                horarios = horarios.Select(h => new {
                    id    = h.Hor_Id,
                    texto = h.Dia_Descripcion + " " + h.Hor_HoraInicioDescripcion + " — " + h.Mat_Nombre + " (" + h.Sec_Descripcion + ")"
                })
            }, JsonRequestBehavior.AllowGet);
        }

        public async Task<ActionResult> ListAsync(int Hor_Id)
        {
            var result = await _service.ListAsync(Hor_Id);
            return AjaxResult(result);
        }

        [HttpPost]
        public async Task<ActionResult> CreateAsync(int Hor_Id, short Pla_Semana, string Pla_Tema,
            string Pla_Objetivos, string Pla_Recursos)
        {
            bool err = await _service.CreateAsync(new {
                Hor_Id, Pla_Semana, Pla_Tema, Pla_Objetivos, Pla_Recursos,
                UsuarioRegistra = GetUsuarioId()
            });
            return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessInsert);
        }

        [HttpPost]
        public async Task<ActionResult> EditAsync(int Pla_Id, short Pla_Semana, string Pla_Tema,
            string Pla_Objetivos, string Pla_Recursos, string Pla_Estado)
        {
            bool err = await _service.EditAsync(new {
                Pla_Id, Pla_Semana, Pla_Tema, Pla_Objetivos, Pla_Recursos, Pla_Estado,
                UsuarioModifica = GetUsuarioId()
            });
            return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessUpdate);
        }

        [HttpPost]
        public async Task<ActionResult> DeleteAsync(int Pla_Id)
        {
            bool err = await _service.DeleteAsync(Pla_Id, GetUsuarioId());
            return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessDelete);
        }
    }
}
""")

    os.makedirs(os.path.join(ADM_UI, "Views", "PlanClasesAdm"), exist_ok=True)
    write(os.path.join(ADM_UI, "Views", "PlanClasesAdm", "Index.cshtml"), """\
@{
    ViewBag.Title = "Plan de Clases";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{
    <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" />
    <link href="~/Content/css/modal-catalogos.css" rel="stylesheet" />
}
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Plan de Clases</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-book-open" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Plan de Clases / Sílabo</h1>
                <p>Gestione el plan de contenidos por semana para cada horario</p>
            </div>
        </div>
        <div class="header-action-catalogo">
            <button class="btn-nuevo-catalogo" id="btn-nuevo" disabled>
                <i class="mdi mdi-plus-circle-outline"></i> Nuevo Tema
            </button>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="card mb-3 p-3">
        <div class="row g-2">
            <div class="col-md-7">
                <select id="f-hor" class="form-control"><option value="">-- Seleccione Horario --</option></select>
            </div>
            <div class="col-md-2">
                <button class="btn btn-primary w-100" id="btn-cargar">
                    <i class="fa-solid fa-magnifying-glass"></i> Cargar
                </button>
            </div>
        </div>
    </div>
    <div class="card-listado-catalogo">
        <div class="card-body-listado-catalogo">
            <div class="table-responsive">
                <table class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th>Semana</th><th>Tema</th><th>Objetivos</th>
                            <th>Recursos</th><th>Estado</th><th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="tbody-plan"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<!-- Modal -->
<div class="modal fade" id="modal-plan" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content modal-content-catalogo">
            <div class="modal-header-catalogo">
                <div><h5 class="modal-title-catalogo" id="modal-titulo">Nuevo Tema</h5></div>
                <button type="button" class="close close-catalogo" data-dismiss="modal">&times;</button>
            </div>
            <form id="form-plan">
                <input type="hidden" name="Pla_Id" id="Pla_Id" value="0">
                <input type="hidden" name="Hor_Id" id="Hor_Id_hidden">
                <div class="modal-body-catalogo">
                    <div class="form-card-catalogo">
                        <div class="row">
                            <div class="col-md-3 form-group-catalogo">
                                <label class="form-label-catalogo">Semana *</label>
                                <input type="number" name="Pla_Semana" class="form-control form-input-catalogo" min="1" max="52" required>
                            </div>
                            <div class="col-md-9 form-group-catalogo">
                                <label class="form-label-catalogo">Tema *</label>
                                <input type="text" name="Pla_Tema" class="form-control form-input-catalogo" maxlength="200" required>
                            </div>
                            <div class="col-md-12 form-group-catalogo">
                                <label class="form-label-catalogo">Objetivos</label>
                                <textarea name="Pla_Objetivos" class="form-control form-input-catalogo" rows="3"></textarea>
                            </div>
                            <div class="col-md-8 form-group-catalogo">
                                <label class="form-label-catalogo">Recursos / Materiales</label>
                                <input type="text" name="Pla_Recursos" class="form-control form-input-catalogo" maxlength="300">
                            </div>
                            <div class="col-md-4 form-group-catalogo" id="div-estado" style="display:none;">
                                <label class="form-label-catalogo">Estado</label>
                                <select name="Pla_Estado" class="form-control form-input-catalogo">
                                    <option value="Pendiente">Pendiente</option>
                                    <option value="Impartido">Impartido</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer-catalogo">
                    <button type="button" class="btn-cancel-catalogo" data-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn-save-catalogo">Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/planclasesadm.js"></script>
    <script>
        PlanClasesAdm.init(
            "@Url.Action("ListAsync")",
            "@Url.Action("CreateAsync")",
            "@Url.Action("EditAsync")",
            "@Url.Action("DeleteAsync")",
            "@Url.Action("DropdownsAsync")"
        );
    </script>
}
""")

    write(os.path.join(ADM_UI, "Content", "js", "pages", "planclasesadm.js"), """\
var PlanClasesAdm = (function () {
    var obj = {};
    var urlList, urlCreate, urlEdit, urlDelete;
    var horActual = 0;

    function llenarHorarios(sel, items) {
        sel.empty().append('<option value="">-- Seleccione Horario --</option>');
        $.each(items, function (_, h) {
            sel.append('<option value="' + h.id + '">' + h.texto + '</option>');
        });
    }

    function estadoBadge(est) {
        return est === 'Impartido'
            ? '<span class="badge badge-success">Impartido</span>'
            : '<span class="badge badge-warning">Pendiente</span>';
    }

    function cargar() {
        horActual = $("#f-hor").val();
        if (!horActual) { alert("Seleccione un horario."); return; }
        $.getJSON(urlList, { Hor_Id: horActual }, function (data) {
            var rows = data || [];
            var tbody = $("#tbody-plan").empty();
            if (!rows.length) {
                tbody.append('<tr><td colspan="6" class="text-center text-muted">Sin contenido registrado.</td></tr>');
                return;
            }
            $.each(rows, function (_, r) {
                tbody.append(
                    '<tr data-id="' + r.Pla_Id + '">' +
                    '<td>' + r.Pla_Semana + '</td>' +
                    '<td>' + r.Pla_Tema + '</td>' +
                    '<td class="text-truncate" style="max-width:200px" title="' + (r.Pla_Objetivos||'') + '">' + (r.Pla_Objetivos||'—') + '</td>' +
                    '<td>' + (r.Pla_Recursos||'—') + '</td>' +
                    '<td>' + estadoBadge(r.Pla_Estado) + '</td>' +
                    '<td>' +
                        '<button class="btn btn-xs btn-primary btn-editar me-1" data-row=\'' + JSON.stringify(r) + '\'>Editar</button>' +
                        '<button class="btn btn-xs btn-danger btn-eliminar">Eliminar</button>' +
                    '</td></tr>'
                );
            });
        });
    }

    obj.init = function (ul, uc, ue, ud, urlDD) {
        urlList = ul; urlCreate = uc; urlEdit = ue; urlDelete = ud;

        $.getJSON(urlDD, function (data) { llenarHorarios($("#f-hor"), data.horarios); });

        $("#btn-cargar").on("click", function () { cargar(); $("#btn-nuevo").prop("disabled", false); });

        $("#btn-nuevo").on("click", function () {
            $("#modal-titulo").text("Nuevo Tema");
            $("#form-plan")[0].reset();
            $("#Pla_Id").val(0);
            $("#Hor_Id_hidden").val(horActual);
            $("#div-estado").hide();
            $("#modal-plan").modal("show");
        });

        $(document).on("click", ".btn-editar", function () {
            var r = $(this).data("row");
            $("#modal-titulo").text("Editar Tema");
            $("#Pla_Id").val(r.Pla_Id);
            $("#Hor_Id_hidden").val(r.Hor_Id);
            $("[name='Pla_Semana']").val(r.Pla_Semana);
            $("[name='Pla_Tema']").val(r.Pla_Tema);
            $("[name='Pla_Objetivos']").val(r.Pla_Objetivos);
            $("[name='Pla_Recursos']").val(r.Pla_Recursos);
            $("[name='Pla_Estado']").val(r.Pla_Estado);
            $("#div-estado").show();
            $("#modal-plan").modal("show");
        });

        $(document).on("click", ".btn-eliminar", function () {
            var id = $(this).closest("tr").data("id");
            if (!confirm("¿Eliminar este tema?")) return;
            $.post(urlDelete, { Pla_Id: id }, function (res) { if (res && res.success) cargar(); });
        });

        $("#form-plan").on("submit", function (e) {
            e.preventDefault();
            var id  = parseInt($("#Pla_Id").val());
            var url = id ? urlEdit : urlCreate;
            $.post(url, $(this).serialize(), function (res) {
                if (res && res.success) { $("#modal-plan").modal("hide"); cargar(); }
            });
        });
    };

    return obj;
}());
""")


# ═══════════════════════════════════════════════════════════════════════════════
# 7. ADM — TAREAS
# ═══════════════════════════════════════════════════════════════════════════════
def gen_adm_tareas():
    write(os.path.join(ADM_BIZ, "Services", "TareasAdmService.cs"), """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class TareasAdmService
    {
        public async Task<List<dynamic>> ListAsync(int Hor_Id)
            => await SendHttpClient.GetAsync<dynamic>($"Tareas/ListAsync?Hor_Id={Hor_Id}");

        public async Task<bool> CreateAsync(dynamic model)
            => await SendHttpClient.PostAsync("Tareas/CreateAsync", model);

        public async Task<bool> EditAsync(dynamic model)
            => await SendHttpClient.PutAsync("Tareas/EditAsync", model);

        public async Task<bool> DeleteAsync(int Tar_Id, int usuarioModifica)
            => await SendHttpClient.DeleteAsync($"Tareas/DeleteAsync?Tar_Id={Tar_Id}&UsuarioModifica={usuarioModifica}");
    }
}
""")

    write(os.path.join(ADM_UI, "Controllers", "TareasAdmController.cs"), """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Extensions;
using GESTION_COLEGIAL.UI.Filters;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Tareas y entregas")]
    public class TareasAdmController : BaseController
    {
        private readonly TareasAdmService _service  = new TareasAdmService();
        private readonly HorariosService  _horarios = new HorariosService();

        public ActionResult Index() => View();

        public async Task<ActionResult> DropdownsAsync()
        {
            var horarios = await _horarios.ListAsync();
            return Json(new
            {
                horarios = horarios.Select(h => new {
                    id    = h.Hor_Id,
                    texto = h.Dia_Descripcion + " " + h.Hor_HoraInicioDescripcion + " — " + h.Mat_Nombre + " (" + h.Sec_Descripcion + ")"
                })
            }, JsonRequestBehavior.AllowGet);
        }

        public async Task<ActionResult> ListAsync(int Hor_Id)
        {
            var result = await _service.ListAsync(Hor_Id);
            return AjaxResult(result);
        }

        [HttpPost]
        public async Task<ActionResult> CreateAsync(int Hor_Id, string Tar_Titulo, string Tar_Descripcion,
            string Tar_FechaEntrega, decimal Tar_Punteo)
        {
            bool err = await _service.CreateAsync(new {
                Hor_Id, Tar_Titulo, Tar_Descripcion, Tar_FechaEntrega, Tar_Punteo,
                UsuarioRegistra = GetUsuarioId()
            });
            return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessInsert);
        }

        [HttpPost]
        public async Task<ActionResult> EditAsync(int Tar_Id, string Tar_Titulo, string Tar_Descripcion,
            string Tar_FechaEntrega, decimal Tar_Punteo, string Tar_Estado)
        {
            bool err = await _service.EditAsync(new {
                Tar_Id, Tar_Titulo, Tar_Descripcion, Tar_FechaEntrega, Tar_Punteo, Tar_Estado,
                UsuarioModifica = GetUsuarioId()
            });
            return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessUpdate);
        }

        [HttpPost]
        public async Task<ActionResult> DeleteAsync(int Tar_Id)
        {
            bool err = await _service.DeleteAsync(Tar_Id, GetUsuarioId());
            return err ? AjaxResult(false, AlertMessage.AlertMessageCustomType.Error)
                       : AjaxResult(true,  AlertMessage.AlertMessageCustomType.SuccessDelete);
        }
    }
}
""")

    os.makedirs(os.path.join(ADM_UI, "Views", "TareasAdm"), exist_ok=True)
    write(os.path.join(ADM_UI, "Views", "TareasAdm", "Index.cshtml"), """\
@{
    ViewBag.Title = "Tareas y Entregas";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{
    <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" />
    <link href="~/Content/css/modal-catalogos.css" rel="stylesheet" />
}
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Tareas y Entregas</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-clipboard-list" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Tareas y Entregas</h1>
                <p>Asigne tareas por horario y realice seguimiento de entregas</p>
            </div>
        </div>
        <div class="header-action-catalogo">
            <button class="btn-nuevo-catalogo" id="btn-nuevo" disabled>
                <i class="mdi mdi-plus-circle-outline"></i> Nueva Tarea
            </button>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="card mb-3 p-3">
        <div class="row g-2">
            <div class="col-md-7">
                <select id="f-hor" class="form-control"><option value="">-- Seleccione Horario --</option></select>
            </div>
            <div class="col-md-2">
                <button class="btn btn-primary w-100" id="btn-cargar">
                    <i class="fa-solid fa-magnifying-glass"></i> Cargar
                </button>
            </div>
        </div>
    </div>
    <div class="card-listado-catalogo">
        <div class="card-body-listado-catalogo">
            <div class="table-responsive">
                <table class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th>Título</th><th>Descripción</th><th>Entrega</th>
                            <th>Punteo</th><th>Estado</th><th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="tbody-tareas"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<!-- Modal -->
<div class="modal fade" id="modal-tarea" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content modal-content-catalogo">
            <div class="modal-header-catalogo">
                <div><h5 class="modal-title-catalogo" id="modal-titulo">Nueva Tarea</h5></div>
                <button type="button" class="close close-catalogo" data-dismiss="modal">&times;</button>
            </div>
            <form id="form-tarea">
                <input type="hidden" name="Tar_Id" id="Tar_Id" value="0">
                <input type="hidden" name="Hor_Id" id="Hor_Id_hidden">
                <div class="modal-body-catalogo">
                    <div class="form-card-catalogo">
                        <div class="row">
                            <div class="col-md-8 form-group-catalogo">
                                <label class="form-label-catalogo">Título *</label>
                                <input type="text" name="Tar_Titulo" class="form-control form-input-catalogo" maxlength="200" required>
                            </div>
                            <div class="col-md-4 form-group-catalogo">
                                <label class="form-label-catalogo">Fecha de Entrega *</label>
                                <input type="date" name="Tar_FechaEntrega" class="form-control form-input-catalogo" required>
                            </div>
                            <div class="col-md-12 form-group-catalogo">
                                <label class="form-label-catalogo">Descripción</label>
                                <textarea name="Tar_Descripcion" class="form-control form-input-catalogo" rows="3"></textarea>
                            </div>
                            <div class="col-md-4 form-group-catalogo">
                                <label class="form-label-catalogo">Punteo máximo</label>
                                <input type="number" step="0.01" name="Tar_Punteo" class="form-control form-input-catalogo" value="100">
                            </div>
                            <div class="col-md-4 form-group-catalogo" id="div-estado" style="display:none;">
                                <label class="form-label-catalogo">Estado</label>
                                <select name="Tar_Estado" class="form-control form-input-catalogo">
                                    <option value="Activa">Activa</option>
                                    <option value="Cerrada">Cerrada</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer-catalogo">
                    <button type="button" class="btn-cancel-catalogo" data-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn-save-catalogo">Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/tareasadm.js"></script>
    <script>
        TareasAdm.init(
            "@Url.Action("ListAsync")",
            "@Url.Action("CreateAsync")",
            "@Url.Action("EditAsync")",
            "@Url.Action("DeleteAsync")",
            "@Url.Action("DropdownsAsync")"
        );
    </script>
}
""")

    write(os.path.join(ADM_UI, "Content", "js", "pages", "tareasadm.js"), """\
var TareasAdm = (function () {
    var obj = {};
    var urlList, urlCreate, urlEdit, urlDelete;
    var horActual = 0;

    function estadoBadge(est) {
        return est === 'Cerrada'
            ? '<span class="badge badge-secondary">Cerrada</span>'
            : '<span class="badge badge-success">Activa</span>';
    }

    function cargar() {
        horActual = $("#f-hor").val();
        if (!horActual) { alert("Seleccione un horario."); return; }
        $.getJSON(urlList, { Hor_Id: horActual }, function (data) {
            var rows = data || [];
            var tbody = $("#tbody-tareas").empty();
            if (!rows.length) {
                tbody.append('<tr><td colspan="6" class="text-center text-muted">Sin tareas registradas.</td></tr>');
                return;
            }
            $.each(rows, function (_, r) {
                var fecha = r.Tar_FechaEntrega ? r.Tar_FechaEntrega.substring(0, 10) : '—';
                tbody.append(
                    '<tr data-id="' + r.Tar_Id + '">' +
                    '<td>' + r.Tar_Titulo + '</td>' +
                    '<td class="text-truncate" style="max-width:180px" title="' + (r.Tar_Descripcion||'') + '">' + (r.Tar_Descripcion||'—') + '</td>' +
                    '<td>' + fecha + '</td>' +
                    '<td>' + r.Tar_Punteo + '</td>' +
                    '<td>' + estadoBadge(r.Tar_Estado) + '</td>' +
                    '<td>' +
                        '<button class="btn btn-xs btn-primary btn-editar me-1" data-row=\'' + JSON.stringify(r) + '\'>Editar</button>' +
                        '<button class="btn btn-xs btn-danger btn-eliminar">Eliminar</button>' +
                    '</td></tr>'
                );
            });
        });
    }

    obj.init = function (ul, uc, ue, ud, urlDD) {
        urlList = ul; urlCreate = uc; urlEdit = ue; urlDelete = ud;

        $.getJSON(urlDD, function (data) {
            var sel = $("#f-hor").empty().append('<option value="">-- Seleccione Horario --</option>');
            $.each(data.horarios, function (_, h) { sel.append('<option value="' + h.id + '">' + h.texto + '</option>'); });
        });

        $("#btn-cargar").on("click", function () { cargar(); $("#btn-nuevo").prop("disabled", false); });

        $("#btn-nuevo").on("click", function () {
            $("#modal-titulo").text("Nueva Tarea");
            $("#form-tarea")[0].reset();
            $("#Tar_Id").val(0);
            $("#Hor_Id_hidden").val(horActual);
            $("#div-estado").hide();
            $("#modal-tarea").modal("show");
        });

        $(document).on("click", ".btn-editar", function () {
            var r = $(this).data("row");
            $("#modal-titulo").text("Editar Tarea");
            $("#Tar_Id").val(r.Tar_Id);
            $("#Hor_Id_hidden").val(r.Hor_Id);
            $("[name='Tar_Titulo']").val(r.Tar_Titulo);
            $("[name='Tar_Descripcion']").val(r.Tar_Descripcion);
            $("[name='Tar_FechaEntrega']").val(r.Tar_FechaEntrega ? r.Tar_FechaEntrega.substring(0,10) : '');
            $("[name='Tar_Punteo']").val(r.Tar_Punteo);
            $("[name='Tar_Estado']").val(r.Tar_Estado);
            $("#div-estado").show();
            $("#modal-tarea").modal("show");
        });

        $(document).on("click", ".btn-eliminar", function () {
            var id = $(this).closest("tr").data("id");
            if (!confirm("¿Eliminar esta tarea?")) return;
            $.post(urlDelete, { Tar_Id: id }, function (res) { if (res && res.success) cargar(); });
        });

        $("#form-tarea").on("submit", function (e) {
            e.preventDefault();
            var id  = parseInt($("#Tar_Id").val());
            var url = id ? urlEdit : urlCreate;
            $.post(url, $(this).serialize(), function (res) {
                if (res && res.success) { $("#modal-tarea").modal("hide"); cargar(); }
            });
        });
    };

    return obj;
}());
""")


# ═══════════════════════════════════════════════════════════════════════════════
# 8. ADM — MIS ALUMNOS
# ═══════════════════════════════════════════════════════════════════════════════
def gen_adm_mis_alumnos():
    write(os.path.join(ADM_BIZ, "Services", "MisAlumnosAdmService.cs"), """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class MisAlumnosAdmService
    {
        public async Task<List<dynamic>> ListAsync(int Hor_Id)
            => await SendHttpClient.GetAsync<dynamic>($"MisAlumnos/ListAsync?Hor_Id={Hor_Id}");
    }
}
""")

    write(os.path.join(ADM_UI, "Controllers", "MisAlumnosAdmController.cs"), """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Mis alumnos")]
    public class MisAlumnosAdmController : BaseController
    {
        private readonly MisAlumnosAdmService _service  = new MisAlumnosAdmService();
        private readonly HorariosService      _horarios = new HorariosService();

        public ActionResult Index() => View();

        public async Task<ActionResult> DropdownsAsync()
        {
            var horarios = await _horarios.ListAsync();
            return Json(new
            {
                horarios = horarios.Select(h => new {
                    id    = h.Hor_Id,
                    texto = h.Dia_Descripcion + " " + h.Hor_HoraInicioDescripcion + " — " + h.Mat_Nombre + " (" + h.Sec_Descripcion + ")"
                })
            }, JsonRequestBehavior.AllowGet);
        }

        public async Task<ActionResult> ListAsync(int Hor_Id)
        {
            var result = await _service.ListAsync(Hor_Id);
            return AjaxResult(result);
        }
    }
}
""")

    os.makedirs(os.path.join(ADM_UI, "Views", "MisAlumnosAdm"), exist_ok=True)
    write(os.path.join(ADM_UI, "Views", "MisAlumnosAdm", "Index.cshtml"), """\
@{
    ViewBag.Title = "Mis Alumnos";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{ <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" /> }
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Mis Alumnos</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-users" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Mis Alumnos</h1>
                <p>Galería de alumnos por horario asignado</p>
            </div>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="card mb-3 p-3">
        <div class="row g-2">
            <div class="col-md-7">
                <select id="f-hor" class="form-control"><option value="">-- Seleccione Horario --</option></select>
            </div>
            <div class="col-md-2">
                <button class="btn btn-primary w-100" id="btn-cargar">
                    <i class="fa-solid fa-magnifying-glass"></i> Ver Alumnos
                </button>
            </div>
        </div>
    </div>
    <div id="panel-alumnos" class="row g-3" style="display:none;"></div>
    <div id="panel-vacio" class="text-center text-muted py-5" style="display:none;">
        <i class="fa-solid fa-users-slash fa-3x mb-3 opacity-25"></i>
        <p>No se encontraron alumnos para este horario.</p>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/misalumnosadm.js"></script>
    <script>
        MisAlumnosAdm.init(
            "@Url.Action("ListAsync")",
            "@Url.Action("DropdownsAsync")"
        );
    </script>
}
""")

    write(os.path.join(ADM_UI, "Content", "js", "pages", "misalumnosadm.js"), """\
var MisAlumnosAdm = (function () {
    var obj = {};

    obj.init = function (urlList, urlDD) {
        $.getJSON(urlDD, function (data) {
            var sel = $("#f-hor");
            $.each(data.horarios, function (_, h) { sel.append('<option value="' + h.id + '">' + h.texto + '</option>'); });
        });

        $("#btn-cargar").on("click", function () {
            var id = $("#f-hor").val();
            if (!id) { alert("Seleccione un horario."); return; }

            $.getJSON(urlList, { Hor_Id: id }, function (data) {
                var rows = data || [];
                var panel = $("#panel-alumnos").empty().hide();
                $("#panel-vacio").hide();

                if (!rows.length) { $("#panel-vacio").show(); return; }

                $.each(rows, function (_, a) {
                    var img = a.Per_Imagen
                        ? '<img src="' + a.Per_Imagen + '" class="rounded-circle mb-2" width="64" height="64" style="object-fit:cover;">'
                        : '<div class="rounded-circle bg-secondary d-flex align-items-center justify-content-center mb-2" style="width:64px;height:64px;font-size:24px;color:#fff;margin:0 auto;"><i class="fa-solid fa-user"></i></div>';
                    panel.append(
                        '<div class="col-6 col-md-3 col-lg-2">' +
                            '<div class="card text-center p-3 h-100">' +
                                img +
                                '<div class="fw-semibold small">' + a.NombreCompleto + '</div>' +
                                '<div class="text-muted" style="font-size:11px;">' + (a.Sec_Descripcion||'') + '</div>' +
                            '</div>' +
                        '</div>'
                    );
                });
                panel.show();
            });
        });
    };

    return obj;
}());
""")


# ═══════════════════════════════════════════════════════════════════════════════
# 9. ADM — MAPA DE AULAS
# ═══════════════════════════════════════════════════════════════════════════════
def gen_adm_mapa_aulas():
    write(os.path.join(ADM_BIZ, "Services", "MapaAulasAdmService.cs"), """\
using GESTION_COLEGIAL.Business.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GESTION_COLEGIAL.Business.Services
{
    public class MapaAulasAdmService
    {
        public async Task<List<dynamic>> GetAsync()
            => await SendHttpClient.GetAsync<dynamic>("MapaAulas/ListAsync");
    }
}
""")

    write(os.path.join(ADM_UI, "Controllers", "MapaAulasAdmController.cs"), """\
using GESTION_COLEGIAL.Business.Services;
using GESTION_COLEGIAL.UI.Filters;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace GESTION_COLEGIAL.UI.Controllers
{
    [SessionManager("Mapa de aulas")]
    public class MapaAulasAdmController : BaseController
    {
        private readonly MapaAulasAdmService _service = new MapaAulasAdmService();

        public ActionResult Index() => View();

        public async Task<ActionResult> GetAsync()
        {
            var result = await _service.GetAsync();
            return AjaxResult(result);
        }
    }
}
""")

    os.makedirs(os.path.join(ADM_UI, "Views", "MapaAulasAdm"), exist_ok=True)
    write(os.path.join(ADM_UI, "Views", "MapaAulasAdm", "Index.cshtml"), """\
@{
    ViewBag.Title = "Mapa de Aulas";
    Layout = "~/Views/Shared/_Layout.cshtml";
}
@section Styles{ <link href="~/Content/css/listado-catalogos.css" rel="stylesheet" /> }
<div class="breadcrumb-wrapper-content">
    <nav class="breadcrumb-style-one" aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Inicio</a></li>
            <li class="breadcrumb-item active">Mapa de Aulas</li>
        </ol>
    </nav>
</div>
<div class="page-header-catalogo">
    <div class="header-content-wrapper-catalogo">
        <div class="header-left-catalogo">
            <div class="header-icon-catalogo"><i class="fa-solid fa-map-location-dot" style="font-size:32px;"></i></div>
            <div class="header-text-catalogo">
                <h1>Mapa de Ocupación de Aulas</h1>
                <p>Visualice la asignación de horarios por aula en el año actual</p>
            </div>
        </div>
    </div>
</div>
<div class="fluid-container">
    <div class="row g-3" id="panel-aulas">
        <div class="col-12 text-center py-5 text-muted" id="estado-carga">
            <i class="fa-solid fa-spinner fa-spin fa-2x mb-2"></i><p>Cargando...</p>
        </div>
    </div>
</div>
@section Scripts{
    <script src="~/Content/js/pages/mapaaulasadm.js"></script>
    <script>MapaAulasAdm.init("@Url.Action("GetAsync")");</script>
}
""")

    write(os.path.join(ADM_UI, "Content", "js", "pages", "mapaaulasadm.js"), """\
var MapaAulasAdm = (function () {
    var obj = {};

    function nivelOcupacion(actuales) {
        if (actuales === 0) return { cls: 'success', label: 'Libre' };
        if (actuales <= 2) return { cls: 'info',    label: 'Baja' };
        if (actuales <= 4) return { cls: 'warning', label: 'Media' };
        return { cls: 'danger', label: 'Alta' };
    }

    obj.init = function (urlGet) {
        $.getJSON(urlGet, function (data) {
            var rows = data || [];
            var panel = $("#panel-aulas").empty();

            if (!rows.length) {
                panel.html('<div class="col-12 text-center text-muted py-5">No hay aulas registradas.</div>');
                return;
            }

            $.each(rows, function (_, a) {
                var nivel = nivelOcupacion(a.HorariosActuales);
                panel.append(
                    '<div class="col-6 col-md-4 col-lg-3">' +
                        '<div class="card p-3 h-100 border-' + nivel.cls + '">' +
                            '<div class="d-flex justify-content-between align-items-start mb-2">' +
                                '<h6 class="fw-bold mb-0">' + a.Aul_Descripcion + '</h6>' +
                                '<span class="badge badge-' + nivel.cls + '">' + nivel.label + '</span>' +
                            '</div>' +
                            '<div class="text-muted small">Horarios año actual: <strong>' + a.HorariosActuales + '</strong></div>' +
                            '<div class="text-muted small">Total histórico: ' + a.Horarios_Total + '</div>' +
                        '</div>' +
                    '</div>'
                );
            });
        });
    };

    return obj;
}());
""")


# ═══════════════════════════════════════════════════════════════════════════════
# 10. PATCHES
# ═══════════════════════════════════════════════════════════════════════════════
def patch_program_cs_di():
    patch_program_cs(
        repo_lines=[
            'builder.Services.AddScoped<IPlanClasesRepository, PlanClasesRepository>();',
            'builder.Services.AddScoped<ITareasRepository, TareasRepository>();',
            'builder.Services.AddScoped<IMisAlumnosRepository, MisAlumnosRepository>();',
            'builder.Services.AddScoped<IMapaAulasRepository, MapaAulasRepository>();',
        ],
        svc_lines=[
            'builder.Services.AddScoped<IPlanClasesService, PlanClasesService>();',
            'builder.Services.AddScoped<ITareasService, TareasService>();',
            'builder.Services.AddScoped<IMisAlumnosService, MisAlumnosService>();',
            'builder.Services.AddScoped<IMapaAulasService, MapaAulasService>();',
        ]
    )


def patch_adm_csproj():
    ui_controllers = [
        r"Controllers\PlanClasesAdmController.cs",
        r"Controllers\TareasAdmController.cs",
        r"Controllers\MisAlumnosAdmController.cs",
        r"Controllers\MapaAulasAdmController.cs",
    ]
    biz_services = [
        r"Services\PlanClasesAdmService.cs",
        r"Services\TareasAdmService.cs",
        r"Services\MisAlumnosAdmService.cs",
        r"Services\MapaAulasAdmService.cs",
    ]
    anchor_ui  = '<Compile Include="Controllers\\AlumnosController.cs" />'
    anchor_biz = '<Compile Include="Services\\AccountService.cs" />'
    add_to_csproj(ADM_UI_CSPROJ,  ui_controllers,  anchor_ui)
    add_to_csproj(ADM_BIZ_CSPROJ, biz_services,     anchor_biz)


def patch_adm_sidebar():
    with open(ADM_SIDEBAR, encoding="utf-8") as f:
        txt = f.read()

    changed = False

    # Plan de Clases + Tareas + Mis Alumnos → Académico section
    if 'PlanClasesAdm' not in txt:
        txt = txt.replace(
            '@if (tiene("Pase de lista"))',
            '@if (tiene("Plan de clases"))   { <li>@Html.ActionLink("Plan de Clases", "Index", "PlanClasesAdm")</li> }\n                        '
            '@if (tiene("Tareas y entregas")) { <li>@Html.ActionLink("Tareas",         "Index", "TareasAdm")</li> }\n                        '
            '@if (tiene("Mis alumnos"))       { <li>@Html.ActionLink("Mis Alumnos",    "Index", "MisAlumnosAdm")</li> }\n                        '
            '@if (tiene("Pase de lista"))'
        )
        changed = True

    # Mapa de Aulas → after Aulas in Catalogos or create new Infraestructura section
    if 'MapaAulasAdm' not in txt:
        txt = txt.replace(
            '@if (tiene("Pase de lista"))',
            '@if (tiene("Mapa de aulas"))     { <li>@Html.ActionLink("Mapa de Aulas",  "Index", "MapaAulasAdm")</li> }\n                        '
            '@if (tiene("Pase de lista"))'
        )
        changed = True

    if changed:
        with open(ADM_SIDEBAR, "w", encoding="utf-8") as f:
            f.write(txt)
        print("  [OK]   _sidebar.cshtml parcheado (Fase 3)")
    else:
        print("  [SKIP] _sidebar.cshtml ya tiene entradas Fase 3")


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    print("\n=== SQL — Tablas ===")
    gen_sql_tablas()

    print("\n=== SQL — Stored Procedures ===")
    gen_sql_sps()

    print("\n=== SQL — Pantallas ===")
    gen_sql_pantallas()

    print("\n=== API — Plan de Clases ===")
    gen_api_plan_clases()

    print("\n=== API — Tareas ===")
    gen_api_tareas()

    print("\n=== API — Mis Alumnos ===")
    gen_api_mis_alumnos()

    print("\n=== API — Mapa de Aulas ===")
    gen_api_mapa_aulas()

    print("\n=== ADM — Plan de Clases ===")
    gen_adm_plan_clases()

    print("\n=== ADM — Tareas ===")
    gen_adm_tareas()

    print("\n=== ADM — Mis Alumnos ===")
    gen_adm_mis_alumnos()

    print("\n=== ADM — Mapa de Aulas ===")
    gen_adm_mapa_aulas()

    print("\n=== Parchando Program.cs (DI) ===")
    patch_program_cs_di()

    print("\n=== Parchando ADM .csproj ===")
    patch_adm_csproj()

    print("\n=== Parchando _sidebar.cshtml ===")
    patch_adm_sidebar()

    print("\n=== FASE 3 COMPLETA ===")
