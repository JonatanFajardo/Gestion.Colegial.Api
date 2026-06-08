-- =============================================
-- Script: Tablas funcionales para pantallas operativas
-- Base de datos: DB_GestionColegial
-- Requisitos: Scripts 001-005 ejecutados antes
-- =============================================

USE DB_GestionColegial;
GO

-- =============================================
-- 1. app.tbTiposDocumento
--    Catalogo de tipos de documentos exigidos en matricula
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbTiposDocumento' AND schema_id = SCHEMA_ID('app'))
BEGIN
    CREATE TABLE [app].[tbTiposDocumento] (
        TDoc_Id              INT          IDENTITY(1,1) NOT NULL,
        TDoc_Descripcion     VARCHAR(100) NOT NULL,
        TDoc_EsObligatorio   BIT          NOT NULL DEFAULT 0,
        TDoc_EsActivo        BIT          NOT NULL DEFAULT 1,
        TDoc_EsEliminado     BIT          NOT NULL DEFAULT 0,
        TDoc_UsuarioRegistra INT          NOT NULL,
        TDoc_FechaRegistra   DATETIME     NOT NULL DEFAULT GETDATE(),
        TDoc_UsuarioModifica INT          NULL,
        TDoc_FechaModifica   DATETIME     NULL,
        CONSTRAINT PK_tbTiposDocumento PRIMARY KEY (TDoc_Id)
    );
    PRINT 'Tabla app.tbTiposDocumento creada.';
END
ELSE PRINT 'app.tbTiposDocumento ya existe.';
GO

-- =============================================
-- 2. app.tbDocumentosAlumno
--    Checklist de documentos por alumno
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbDocumentosAlumno' AND schema_id = SCHEMA_ID('app'))
BEGIN
    CREATE TABLE [app].[tbDocumentosAlumno] (
        Doa_Id               INT          IDENTITY(1,1) NOT NULL,
        Alu_Id               INT          NOT NULL,
        TDoc_Id              INT          NOT NULL,
        Doa_EsEntregado      BIT          NOT NULL DEFAULT 0,
        Doa_FechaEntrega     DATE         NULL,
        Doa_Observacion      VARCHAR(200) NULL,
        Doa_EsEliminado      BIT          NOT NULL DEFAULT 0,
        Doa_UsuarioRegistra  INT          NOT NULL,
        Doa_FechaRegistra    DATETIME     NOT NULL DEFAULT GETDATE(),
        Doa_UsuarioModifica  INT          NULL,
        Doa_FechaModifica    DATETIME     NULL,
        CONSTRAINT PK_tbDocumentosAlumno       PRIMARY KEY (Doa_Id),
        CONSTRAINT FK_DocAlumno_Alumnos        FOREIGN KEY (Alu_Id)  REFERENCES [app].[tbAlumnos](Alu_Id),
        CONSTRAINT FK_DocAlumno_TiposDocumento FOREIGN KEY (TDoc_Id) REFERENCES [app].[tbTiposDocumento](TDoc_Id),
        CONSTRAINT UQ_DocAlumno_AluTDoc        UNIQUE (Alu_Id, TDoc_Id)
    );
    PRINT 'Tabla app.tbDocumentosAlumno creada.';
END
ELSE PRINT 'app.tbDocumentosAlumno ya existe.';
GO

-- =============================================
-- 3. app.tbAsistencia
--    Registro de asistencia por clase/alumno/fecha
--    Estado: P=Presente, A=Ausente, T=Tarde, J=Justificado
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbAsistencia' AND schema_id = SCHEMA_ID('app'))
BEGIN
    CREATE TABLE [app].[tbAsistencia] (
        Asi_Id               INT          IDENTITY(1,1) NOT NULL,
        Hor_Id               INT          NOT NULL,
        Alu_Id               INT          NOT NULL,
        Asi_Fecha            DATE         NOT NULL,
        Asi_Estado           CHAR(1)      NOT NULL,
        Asi_Observacion      VARCHAR(200) NULL,
        Asi_EsEliminado      BIT          NOT NULL DEFAULT 0,
        Asi_UsuarioRegistra  INT          NOT NULL,
        Asi_FechaRegistra    DATETIME     NOT NULL DEFAULT GETDATE(),
        Asi_UsuarioModifica  INT          NULL,
        Asi_FechaModifica    DATETIME     NULL,
        CONSTRAINT PK_tbAsistencia             PRIMARY KEY (Asi_Id),
        CONSTRAINT FK_Asistencia_Horario       FOREIGN KEY (Hor_Id) REFERENCES [app].[tbHorario](Hor_Id),
        CONSTRAINT FK_Asistencia_Alumnos       FOREIGN KEY (Alu_Id) REFERENCES [app].[tbAlumnos](Alu_Id),
        CONSTRAINT UQ_Asistencia_HorAluFecha   UNIQUE (Hor_Id, Alu_Id, Asi_Fecha),
        CONSTRAINT CK_Asistencia_Estado        CHECK (Asi_Estado IN ('P','A','T','J'))
    );
    PRINT 'Tabla app.tbAsistencia creada.';
END
ELSE PRINT 'app.tbAsistencia ya existe.';
GO

-- =============================================
-- 4. app.tbVacaciones
--    Solicitudes de vacaciones/permisos de empleados
--    Tipo: V=Vacaciones, P=Permiso, I=Incapacidad
--    Estado: P=Pendiente, A=Aprobado, R=Rechazado
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbVacaciones' AND schema_id = SCHEMA_ID('app'))
BEGIN
    CREATE TABLE [app].[tbVacaciones] (
        Vac_Id               INT          IDENTITY(1,1) NOT NULL,
        Emp_Id               INT          NOT NULL,
        Vac_Tipo             CHAR(1)      NOT NULL,
        Vac_FechaInicio      DATE         NOT NULL,
        Vac_FechaFin         DATE         NOT NULL,
        Vac_DiasTotal        AS           DATEDIFF(DAY, Vac_FechaInicio, Vac_FechaFin) + 1,
        Vac_Estado           CHAR(1)      NOT NULL DEFAULT 'P',
        Vac_Motivo           VARCHAR(300) NULL,
        Vac_EsEliminado      BIT          NOT NULL DEFAULT 0,
        Vac_UsuarioRegistra  INT          NOT NULL,
        Vac_FechaRegistra    DATETIME     NOT NULL DEFAULT GETDATE(),
        Vac_UsuarioModifica  INT          NULL,
        Vac_FechaModifica    DATETIME     NULL,
        CONSTRAINT PK_tbVacaciones          PRIMARY KEY (Vac_Id),
        CONSTRAINT FK_Vacaciones_Empleados  FOREIGN KEY (Emp_Id) REFERENCES [app].[tbEmpleados](Emp_Id),
        CONSTRAINT CK_Vacaciones_Tipo       CHECK (Vac_Tipo   IN ('V','P','I')),
        CONSTRAINT CK_Vacaciones_Estado     CHECK (Vac_Estado IN ('P','A','R'))
    );
    PRINT 'Tabla app.tbVacaciones creada.';
END
ELSE PRINT 'app.tbVacaciones ya existe.';
GO

-- =============================================
-- 5. app.tbNotificaciones
--    Notificaciones en sistema por usuario
--    Tipo: I=Informacion, A=Alerta, E=Error
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbNotificaciones' AND schema_id = SCHEMA_ID('app'))
BEGIN
    CREATE TABLE [app].[tbNotificaciones] (
        Not_Id               INT          IDENTITY(1,1) NOT NULL,
        Usu_Id               INT          NOT NULL,
        Not_Titulo           VARCHAR(100) NOT NULL,
        Not_Mensaje          VARCHAR(500) NOT NULL,
        Not_Tipo             CHAR(1)      NOT NULL DEFAULT 'I',
        Not_EsLeida          BIT          NOT NULL DEFAULT 0,
        Not_UrlDestino       VARCHAR(200) NULL,
        Not_FechaEnvio       DATETIME     NOT NULL DEFAULT GETDATE(),
        Not_FechaLectura     DATETIME     NULL,
        Not_EsEliminado      BIT          NOT NULL DEFAULT 0,
        Not_UsuarioRegistra  INT          NOT NULL,
        Not_FechaRegistra    DATETIME     NOT NULL DEFAULT GETDATE(),
        CONSTRAINT PK_tbNotificaciones          PRIMARY KEY (Not_Id),
        CONSTRAINT FK_Notificaciones_Usuarios   FOREIGN KEY (Usu_Id) REFERENCES [Seguridad].[tbUsuarios](Usu_Id),
        CONSTRAINT CK_Notificaciones_Tipo       CHECK (Not_Tipo IN ('I','A','E'))
    );
    PRINT 'Tabla app.tbNotificaciones creada.';
END
ELSE PRINT 'app.tbNotificaciones ya existe.';
GO

-- =============================================
-- 6. finanza.tbArqueosCaja
--    Cierre de caja diario por cajero
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbArqueosCaja' AND schema_id = SCHEMA_ID('finanza'))
BEGIN
    CREATE TABLE [finanza].[tbArqueosCaja] (
        Arq_Id                 INT           IDENTITY(1,1) NOT NULL,
        Usu_Id                 INT           NOT NULL,
        Arq_Fecha              DATE          NOT NULL,
        Arq_TotalEfectivo      DECIMAL(10,2) NOT NULL DEFAULT 0,
        Arq_TotalTransferencia DECIMAL(10,2) NOT NULL DEFAULT 0,
        Arq_TotalTarjeta       DECIMAL(10,2) NOT NULL DEFAULT 0,
        Arq_TotalGeneral       AS            (Arq_TotalEfectivo + Arq_TotalTransferencia + Arq_TotalTarjeta),
        Arq_Observaciones      VARCHAR(300)  NULL,
        Arq_EsEliminado        BIT           NOT NULL DEFAULT 0,
        Arq_UsuarioRegistra    INT           NOT NULL,
        Arq_FechaRegistra      DATETIME      NOT NULL DEFAULT GETDATE(),
        Arq_UsuarioModifica    INT           NULL,
        Arq_FechaModifica      DATETIME      NULL,
        CONSTRAINT PK_tbArqueosCaja         PRIMARY KEY (Arq_Id),
        CONSTRAINT FK_ArqueosCaja_Usuarios  FOREIGN KEY (Usu_Id) REFERENCES [Seguridad].[tbUsuarios](Usu_Id)
    );
    PRINT 'Tabla finanza.tbArqueosCaja creada.';
END
ELSE PRINT 'finanza.tbArqueosCaja ya existe.';
GO

-- =============================================
-- 7. Seguridad.tbBitacora
--    Registro de todas las acciones del sistema
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tbBitacora' AND schema_id = SCHEMA_ID('Seguridad'))
BEGIN
    CREATE TABLE [Seguridad].[tbBitacora] (
        Bit_Id               INT          IDENTITY(1,1) NOT NULL,
        Usu_Id               INT          NOT NULL,
        Bit_Accion           VARCHAR(50)  NOT NULL,
        Bit_Tabla            VARCHAR(100) NULL,
        Bit_RegistroId       INT          NULL,
        Bit_Descripcion      VARCHAR(500) NULL,
        Bit_Ip               VARCHAR(45)  NULL,
        Bit_Fecha            DATETIME     NOT NULL DEFAULT GETDATE(),
        CONSTRAINT PK_tbBitacora        PRIMARY KEY (Bit_Id),
        CONSTRAINT FK_Bitacora_Usuarios FOREIGN KEY (Usu_Id) REFERENCES [Seguridad].[tbUsuarios](Usu_Id)
    );
    PRINT 'Tabla Seguridad.tbBitacora creada.';
END
ELSE PRINT 'Seguridad.tbBitacora ya existe.';
GO

-- =============================================
-- Datos iniciales: tbTiposDocumento
-- =============================================
IF NOT EXISTS (SELECT 1 FROM [app].[tbTiposDocumento])
BEGIN
    INSERT INTO [app].[tbTiposDocumento] (TDoc_Descripcion, TDoc_EsObligatorio, TDoc_UsuarioRegistra) VALUES
    ('Fotocopia de identidad',           1, 1),
    ('Foto tamaño carnet',               1, 1),
    ('Partida de nacimiento',            1, 1),
    ('Certificado de notas anterior',    0, 1),
    ('Constancia de buena conducta',     0, 1),
    ('Boleta de calificaciones',         0, 1);
    PRINT 'Datos iniciales de tbTiposDocumento insertados.';
END
GO

PRINT 'Script 006 ejecutado exitosamente - tablas funcionales creadas.';
GO
