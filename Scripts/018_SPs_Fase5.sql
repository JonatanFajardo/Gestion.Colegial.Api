-- =====================================================================
-- Script 018: SPs Fase 5 — RRHH (cumpleaños, asistencia empleados)
-- Crea/reemplaza:
--   [TABLA]  app.tbAsistenciaEmpleados  — si no existe (idempotente)
--   app.PR_Empleados_Cumpleanos         — empleados con cumpleaños en el mes
--   app.PR_Empleados_Asistencia_List    — lista asistencia empleados
--   app.PR_Empleados_Asistencia_Insert  — registrar asistencia empleado
-- Convención: idempotente (DROP IF EXISTS + CREATE)
-- =====================================================================

USE [DB_GestionColegial]
GO

-- ──────────────────────────────────────────────────────────────────────
-- Tabla: app.tbAsistenciaEmpleados
-- No existe en el esquema original; la creamos para el módulo RRHH.
-- Tipo: E=Entrada, S=Salida, F=Falta, P=Permiso, T=Tardanza
-- ──────────────────────────────────────────────────────────────────────
IF NOT EXISTS (
    SELECT * FROM sys.tables
    WHERE name = 'tbAsistenciaEmpleados'
      AND schema_id = SCHEMA_ID('app')
)
BEGIN
    CREATE TABLE [app].[tbAsistenciaEmpleados] (
        [AsiEmp_Id]          INT          IDENTITY(1,1) NOT NULL,
        [Emp_Id]             INT          NOT NULL,
        [AsiEmp_Fecha]       DATE         NOT NULL,
        [AsiEmp_Tipo]        VARCHAR(20)  NOT NULL
            CONSTRAINT [DF_AsiEmp_Tipo] DEFAULT ('Presente'),
        [AsiEmp_Observacion] VARCHAR(300) NULL,
        [AsiEmp_EsEliminado] BIT          NOT NULL
            CONSTRAINT [DF_AsiEmp_EsEliminado] DEFAULT (0),
        [AsiEmp_UsuarioRegistra] INT      NOT NULL,
        [AsiEmp_FechaRegistra]   DATETIME NOT NULL
            CONSTRAINT [DF_AsiEmp_FechaRegistra] DEFAULT (GETDATE()),
        [AsiEmp_UsuarioModifica] INT      NULL,
        [AsiEmp_FechaModifica]   DATETIME NULL,
        CONSTRAINT [PK_tbAsistenciaEmpleados]
            PRIMARY KEY CLUSTERED ([AsiEmp_Id] ASC),
        CONSTRAINT [FK_AsiEmp_Empleados]
            FOREIGN KEY ([Emp_Id]) REFERENCES [app].[tbEmpleados]([Emp_Id]),
        CONSTRAINT [UQ_AsiEmp_EmpFecha]
            UNIQUE ([Emp_Id], [AsiEmp_Fecha]),
        CONSTRAINT [CK_AsiEmp_Tipo]
            CHECK ([AsiEmp_Tipo] IN ('Presente','Ausente','Tardanza','Permiso','Feriado'))
    );
    PRINT 'Tabla app.tbAsistenciaEmpleados creada.';
END
ELSE
    PRINT 'app.tbAsistenciaEmpleados ya existe.';
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_Empleados_Cumpleanos
-- Empleados que cumplen años en el mes indicado, ordenados por día.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_Empleados_Cumpleanos]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Empleados_Cumpleanos];
GO
CREATE PROCEDURE [app].[PR_Empleados_Cumpleanos]
    @Mes INT = NULL     -- 1-12; NULL usa el mes actual
AS
BEGIN
    SET NOCOUNT ON;
    IF @Mes IS NULL SET @Mes = MONTH(GETDATE());

    SELECT
        e.Emp_Id,
        e.Emp_Codigo,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre, ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        )))                         AS NombreCompleto,
        p.Per_FechaNacimiento,
        DAY(p.Per_FechaNacimiento)  AS DiaCumpleanos,
        YEAR(GETDATE()) - YEAR(p.Per_FechaNacimiento) AS Edad,
        p.Per_Telefono,
        p.Per_CorreoElectronico,
        p.Per_Imagen,
        p.Per_Sexo
    FROM [app].[tbEmpleados] e
    INNER JOIN [app].[tbPersonas] p ON e.Per_Id = p.Per_Id
    WHERE MONTH(p.Per_FechaNacimiento) = @Mes
      AND p.Per_EsActivo    = 1
      AND p.Per_EsEliminado = 0
    ORDER BY DAY(p.Per_FechaNacimiento), p.Per_ApellidoPaterno;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_Empleados_Asistencia_List
-- Lista asistencia de empleados. Filtros opcionales: empleado y/o fecha.
-- Si no se proporciona fecha, devuelve los últimos 30 días.
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_Empleados_Asistencia_List]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Empleados_Asistencia_List];
GO
CREATE PROCEDURE [app].[PR_Empleados_Asistencia_List]
    @Emp_Id INT  = NULL,
    @Fecha  DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Si no se da fecha concreta, devolver últimos 30 días
    DECLARE @FechaDesde DATE = CASE
        WHEN @Fecha IS NOT NULL THEN @Fecha
        ELSE DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
    END;
    DECLARE @FechaHasta DATE = CASE
        WHEN @Fecha IS NOT NULL THEN @Fecha
        ELSE CAST(GETDATE() AS DATE)
    END;

    SELECT
        ae.AsiEmp_Id,
        ae.Emp_Id,
        e.Emp_Codigo,
        LTRIM(RTRIM(CONCAT(
            p.Per_PrimerNombre, ' ',
            ISNULL(p.Per_SegundoNombre + ' ', ''),
            p.Per_ApellidoPaterno, ' ',
            ISNULL(p.Per_ApellidoMaterno, '')
        )))                         AS NombreEmpleado,
        p.Per_Imagen,
        ae.AsiEmp_Fecha,
        ae.AsiEmp_Tipo,
        ae.AsiEmp_Observacion,
        ae.AsiEmp_FechaRegistra
    FROM [app].[tbAsistenciaEmpleados] ae
    INNER JOIN [app].[tbEmpleados] e ON ae.Emp_Id = e.Emp_Id
    INNER JOIN [app].[tbPersonas]  p ON e.Per_Id  = p.Per_Id
    WHERE ae.AsiEmp_EsEliminado = 0
      AND (@Emp_Id IS NULL OR ae.Emp_Id = @Emp_Id)
      AND ae.AsiEmp_Fecha BETWEEN @FechaDesde AND @FechaHasta
    ORDER BY ae.AsiEmp_Fecha DESC, p.Per_ApellidoPaterno;
END
GO

-- ──────────────────────────────────────────────────────────────────────
-- PR_Empleados_Asistencia_Insert
-- Registrar o actualizar asistencia de un empleado en una fecha (UPSERT).
-- @Tipo valores válidos: 'Presente','Ausente','Tardanza','Permiso','Feriado'
-- ──────────────────────────────────────────────────────────────────────
IF OBJECT_ID('[app].[PR_Empleados_Asistencia_Insert]') IS NOT NULL
    DROP PROCEDURE [app].[PR_Empleados_Asistencia_Insert];
GO
CREATE PROCEDURE [app].[PR_Empleados_Asistencia_Insert]
    @Emp_Id          INT,
    @Fecha           DATE,
    @Tipo            VARCHAR(20),
    @UsuarioRegistra INT,
    @Observacion     VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar tipo
    IF @Tipo NOT IN ('Presente','Ausente','Tardanza','Permiso','Feriado')
    BEGIN
        SELECT 0 AS CodeResult, 'Tipo inválido. Use: Presente, Ausente, Tardanza, Permiso, Feriado' AS Mensaje;
        RETURN;
    END

    DECLARE @ExistingId INT = NULL;
    SELECT @ExistingId = AsiEmp_Id
    FROM [app].[tbAsistenciaEmpleados]
    WHERE Emp_Id = @Emp_Id AND AsiEmp_Fecha = @Fecha AND AsiEmp_EsEliminado = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @ExistingId IS NOT NULL
        BEGIN
            UPDATE [app].[tbAsistenciaEmpleados]
            SET AsiEmp_Tipo          = @Tipo,
                AsiEmp_Observacion   = @Observacion,
                AsiEmp_UsuarioModifica = @UsuarioRegistra,
                AsiEmp_FechaModifica = GETDATE()
            WHERE AsiEmp_Id = @ExistingId;

            COMMIT TRANSACTION;
            SELECT 1 AS CodeResult, @ExistingId AS AsiEmp_Id, 'Asistencia actualizada' AS Mensaje;
        END
        ELSE
        BEGIN
            INSERT INTO [app].[tbAsistenciaEmpleados]
                (Emp_Id, AsiEmp_Fecha, AsiEmp_Tipo, AsiEmp_Observacion, AsiEmp_UsuarioRegistra)
            VALUES
                (@Emp_Id, @Fecha, @Tipo, @Observacion, @UsuarioRegistra);

            DECLARE @NewId INT = SCOPE_IDENTITY();
            COMMIT TRANSACTION;
            SELECT 1 AS CodeResult, @NewId AS AsiEmp_Id, 'Asistencia registrada' AS Mensaje;
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS CodeResult, 0 AS AsiEmp_Id, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

PRINT 'Script 018 completado: SPs Fase 5 (RRHH - Cumpleanos + Asistencia Empleados) creados exitosamente.';
GO
