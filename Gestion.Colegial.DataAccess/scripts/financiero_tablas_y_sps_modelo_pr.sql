/* =============================================================
   MÓDULO FINANCIERO – ESQUEMA BASE + SPs estilo PR_tbX_*
   Nomenclatura de SPs según ejemplo: PR_tbEmpleados_{List,Find,Detail,Insert,Delete}
   Auditoría común en TODAS las tablas:
     Per_EsEliminado bit NOT NULL DEFAULT(0)
     Per_UsuarioRegistra int NOT NULL
     Per_FechaRegistra  datetime2(0) NOT NULL DEFAULT(sysdatetime())
     Per_UsuarioModifica int NULL
     Per_FechaModifica  datetime2(0) NULL
   ============================================================= */

SET NOCOUNT ON;
GO

/* =========================
   0) CREACIÓN DE ESQUEMA
   ========================= */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'dbo')
    EXEC('CREATE SCHEMA dbo');
GO

/* =============================================================
   1) TABLAS DE CONFIGURACIÓN
   ============================================================= */

-- 1. tbConceptosPago
IF OBJECT_ID('finanza.tbConceptosPago','U') IS NOT NULL DROP TABLE finanza.tbConceptosPago;
CREATE TABLE finanza.tbConceptosPago (
    Cpa_Id             int IDENTITY(1,1) PRIMARY KEY,
    Cpa_Descripcion    nvarchar(120) NOT NULL,
    Cpa_EsRecurrente   bit NOT NULL DEFAULT(0),
    Cpa_EsObligatorio  bit NOT NULL DEFAULT(0),
    Cpa_EsActivo       bit NOT NULL DEFAULT(1),
    -- Auditoría
    Per_EsEliminado      bit NOT NULL DEFAULT(0),
    Per_UsuarioRegistra  int NOT NULL,
    Per_FechaRegistra    datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Per_UsuarioModifica  int NULL,
    Per_FechaModifica    datetime2(0) NULL
);
GO

-- 2. tbTarifas
IF OBJECT_ID('finanza.tbTarifas','U') IS NOT NULL DROP TABLE finanza.tbTarifas;
CREATE TABLE finanza.tbTarifas (
    Tar_Id          int IDENTITY(1,1) PRIMARY KEY,
    Cpa_Id          int NOT NULL,        -- FK -> tbConceptosPago
    Niv_Id          int NULL,            -- FK externo sugerido (Nivel Educativo)
    Cun_Id          int NULL,            -- FK externo sugerido (Curso/Nivel)
    Tar_Monto       decimal(18,2) NOT NULL,
    Tar_AnioVigencia smallint NOT NULL,
    -- Auditoría
    Per_EsEliminado      bit NOT NULL DEFAULT(0),
    Per_UsuarioRegistra  int NOT NULL,
    Per_FechaRegistra    datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Per_UsuarioModifica  int NULL,
    Per_FechaModifica    datetime2(0) NULL,
    CONSTRAINT FK_tbTarifas_tbConceptosPago
        FOREIGN KEY (Cpa_Id) REFERENCES finanza.tbConceptosPago(Cpa_Id)
);
GO

-- 3. tbFormasPago
IF OBJECT_ID('finanza.tbFormasPago','U') IS NOT NULL DROP TABLE finanza.tbFormasPago;
CREATE TABLE finanza.tbFormasPago (
    Fpa_Id          int IDENTITY(1,1) PRIMARY KEY,
    Fpa_Descripcion nvarchar(80) NOT NULL,
    Fpa_EsActivo    bit NOT NULL DEFAULT(1),
    -- Auditoría
    Per_EsEliminado      bit NOT NULL DEFAULT(0),
    Per_UsuarioRegistra  int NOT NULL,
    Per_FechaRegistra    datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Per_UsuarioModifica  int NULL,
    Per_FechaModifica    datetime2(0) NULL
);
GO

-- 4. tbDescuentos
IF OBJECT_ID('finanza.tbDescuentos','U') IS NOT NULL DROP TABLE finanza.tbDescuentos;
CREATE TABLE finanza.tbDescuentos (
    Des_Id           int IDENTITY(1,1) PRIMARY KEY,
    Des_Descripcion  nvarchar(120) NOT NULL,
    Des_TipoDescuento char(1) NOT NULL, -- 'P' Porcentaje, 'M' Monto fijo
    Des_Valor        decimal(18,2) NOT NULL,
    Des_EsActivo     bit NOT NULL DEFAULT(1),
    -- Auditoría
    Per_EsEliminado      bit NOT NULL DEFAULT(0),
    Per_UsuarioRegistra  int NOT NULL,
    Per_FechaRegistra    datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Per_UsuarioModifica  int NULL,
    Per_FechaModifica    datetime2(0) NULL
);
GO

-- 5. tbEstadosPago
IF OBJECT_ID('finanza.tbEstadosPago','U') IS NOT NULL DROP TABLE finanza.tbEstadosPago;
CREATE TABLE finanza.tbEstadosPago (
    Epa_Id           int IDENTITY(1,1) PRIMARY KEY,
    Epa_Descripcion  nvarchar(50) NOT NULL,
    -- Auditoría
    Per_EsEliminado      bit NOT NULL DEFAULT(0),
    Per_UsuarioRegistra  int NOT NULL,
    Per_FechaRegistra    datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Per_UsuarioModifica  int NULL,
    Per_FechaModifica    datetime2(0) NULL
);
GO

/* =============================================================
   2) TABLAS DE GESTIÓN DE COBROS
   ============================================================= */

-- 6. tbCuentasCobrar
IF OBJECT_ID('finanza.tbCuentasCobrar','U') IS NOT NULL DROP TABLE finanza.tbCuentasCobrar;
CREATE TABLE finanza.tbCuentasCobrar (
    Cco_Id             int IDENTITY(1,1) PRIMARY KEY,
    Alu_Id             int NOT NULL,      -- FK externo sugerido (Alumno)
    Cpa_Id             int NOT NULL,      -- FK -> tbConceptosPago
    Tar_Id             int NULL,          -- FK -> tbTarifas (aplicada)
    Cco_MontoOriginal  decimal(18,2) NOT NULL,
    Cco_MontoDescuento decimal(18,2) NOT NULL DEFAULT(0),
    Cco_MontoMora      decimal(18,2) NOT NULL DEFAULT(0),
    Cco_MontoTotal     decimal(18,2) NOT NULL,
    Cco_MontoPendiente decimal(18,2) NOT NULL,
    Cco_FechaEmision   date NOT NULL,
    Cco_FechaVencimiento date NOT NULL,
    Epa_Id             int NOT NULL,      -- FK -> tbEstadosPago
    Cco_Observaciones  nvarchar(300) NULL,
    -- Auditoría
    Per_EsEliminado      bit NOT NULL DEFAULT(0),
    Per_UsuarioRegistra  int NOT NULL,
    Per_FechaRegistra    datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Per_UsuarioModifica  int NULL,
    Per_FechaModifica    datetime2(0) NULL,
    CONSTRAINT FK_tbCuentasCobrar_tbConceptosPago FOREIGN KEY (Cpa_Id) REFERENCES finanza.tbConceptosPago(Cpa_Id),
    CONSTRAINT FK_tbCuentasCobrar_tbTarifas       FOREIGN KEY (Tar_Id) REFERENCES finanza.tbTarifas(Tar_Id),
    CONSTRAINT FK_tbCuentasCobrar_tbEstadosPago   FOREIGN KEY (Epa_Id) REFERENCES finanza.tbEstadosPago(Epa_Id)
    -- Sugerido: FK externo a tbAlumnos(Alu_Id)
);
GO

-- 7. tbDescuentosAplicados
IF OBJECT_ID('finanza.tbDescuentosAplicados','U') IS NOT NULL DROP TABLE finanza.tbDescuentosAplicados;
CREATE TABLE finanza.tbDescuentosAplicados (
    Dap_Id          int IDENTITY(1,1) PRIMARY KEY,
    Cco_Id          int NOT NULL,        -- FK -> tbCuentasCobrar
    Des_Id          int NOT NULL,        -- FK -> tbDescuentos
    Dap_MontoAplicado decimal(18,2) NOT NULL,
    Dap_Justificacion nvarchar(300) NULL,
    -- Auditoría
    Per_EsEliminado      bit NOT NULL DEFAULT(0),
    Per_UsuarioRegistra  int NOT NULL,
    Per_FechaRegistra    datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Per_UsuarioModifica  int NULL,
    Per_FechaModifica    datetime2(0) NULL,
    CONSTRAINT FK_tbDescuentosAplicados_tbCuentasCobrar FOREIGN KEY (Cco_Id) REFERENCES finanza.tbCuentasCobrar(Cco_Id),
    CONSTRAINT FK_tbDescuentosAplicados_tbDescuentos    FOREIGN KEY (Des_Id) REFERENCES finanza.tbDescuentos(Des_Id)
);
GO

-- 8. tbMoratorias
IF OBJECT_ID('finanza.tbMoratorias','U') IS NOT NULL DROP TABLE finanza.tbMoratorias;
CREATE TABLE finanza.tbMoratorias (
    Mor_Id          int IDENTITY(1,1) PRIMARY KEY,
    Cco_Id          int NOT NULL,        -- FK -> tbCuentasCobrar
    Mor_DiasAtraso  int NOT NULL,
    Mor_Porcentaje  decimal(9,4) NOT NULL,
    Mor_MontoMora   decimal(18,2) NOT NULL,
    Mor_FechaCalculo date NOT NULL,
    -- Auditoría
    Per_EsEliminado      bit NOT NULL DEFAULT(0),
    Per_UsuarioRegistra  int NOT NULL,
    Per_FechaRegistra    datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Per_UsuarioModifica  int NULL,
    Per_FechaModifica    datetime2(0) NULL,
    CONSTRAINT FK_tbMoratorias_tbCuentasCobrar FOREIGN KEY (Cco_Id) REFERENCES finanza.tbCuentasCobrar(Cco_Id)
);
GO

/* =============================================================
   3) REGISTRO DE PAGOS
   ============================================================= */

-- 9. tbPagos
IF OBJECT_ID('finanza.tbPagos','U') IS NOT NULL DROP TABLE finanza.tbPagos;
CREATE TABLE finanza.tbPagos (
    Pag_Id            int IDENTITY(1,1) PRIMARY KEY,
    Alu_Id            int NOT NULL,     -- FK externo (Alumno)
    Enc_Id            int NULL,         -- FK externo (Encargado que paga)
    Fpa_Id            int NOT NULL,     -- FK -> tbFormasPago
    Pag_MontoTotal    decimal(18,2) NOT NULL,
    Pag_FechaPago     datetime2(0) NOT NULL,
    Pag_NumeroReferencia nvarchar(60) NULL,
    Pag_Observaciones nvarchar(300) NULL,
    Usu_Id            int NOT NULL,     -- FK externo (Usuario que registra)
    -- Auditoría
    Per_EsEliminado      bit NOT NULL DEFAULT(0),
    Per_UsuarioRegistra  int NOT NULL,
    Per_FechaRegistra    datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Per_UsuarioModifica  int NULL,
    Per_FechaModifica    datetime2(0) NULL,
    CONSTRAINT FK_tbPagos_tbFormasPago FOREIGN KEY (Fpa_Id) REFERENCES finanza.tbFormasPago(Fpa_Id)
);
GO

-- 10. tbPagosDetalle
IF OBJECT_ID('finanza.tbPagosDetalle','U') IS NOT NULL DROP TABLE finanza.tbPagosDetalle;
CREATE TABLE finanza.tbPagosDetalle (
    Pde_Id          int IDENTITY(1,1) PRIMARY KEY,
    Pag_Id          int NOT NULL,       -- FK -> tbPagos
    Cco_Id          int NOT NULL,       -- FK -> tbCuentasCobrar
    Pde_MontoAplicado decimal(18,2) NOT NULL,
    -- Auditoría
    Per_EsEliminado      bit NOT NULL DEFAULT(0),
    Per_UsuarioRegistra  int NOT NULL,
    Per_FechaRegistra    datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Per_UsuarioModifica  int NULL,
    Per_FechaModifica    datetime2(0) NULL,
    CONSTRAINT FK_tbPagosDetalle_tbPagos        FOREIGN KEY (Pag_Id) REFERENCES finanza.tbPagos(Pag_Id),
    CONSTRAINT FK_tbPagosDetalle_tbCuentasCobrar FOREIGN KEY (Cco_Id) REFERENCES finanza.tbCuentasCobrar(Cco_Id)
);
GO

-- 11. tbRecibos
IF OBJECT_ID('finanza.tbRecibos','U') IS NOT NULL DROP TABLE finanza.tbRecibos;
CREATE TABLE finanza.tbRecibos (
    Rec_Id           int IDENTITY(1,1) PRIMARY KEY,
    Pag_Id           int NOT NULL,       -- FK -> tbPagos
    Rec_NumeroRecibo nvarchar(40) NOT NULL UNIQUE,
    Rec_FechaEmision datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Rec_RutaArchivo  nvarchar(260) NULL,
    -- Auditoría
    Per_EsEliminado      bit NOT NULL DEFAULT(0),
    Per_UsuarioRegistra  int NOT NULL,
    Per_FechaRegistra    datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Per_UsuarioModifica  int NULL,
    Per_FechaModifica    datetime2(0) NULL,
    CONSTRAINT FK_tbRecibos_tbPagos FOREIGN KEY (Pag_Id) REFERENCES finanza.tbPagos(Pag_Id)
);
GO

/* =============================================================
   4) BITÁCORAS (opcionales)
   ============================================================= */
IF OBJECT_ID('finanza.tbPagosHistorial','U') IS NOT NULL DROP TABLE finanza.tbPagosHistorial;
CREATE TABLE finanza.tbPagosHistorial (
    Pgh_Id           int IDENTITY(1,1) PRIMARY KEY,
    Pag_Id           int NOT NULL,
    Pgh_Accion       nvarchar(30) NOT NULL,   -- Insert/Update/Delete/Anulación/etc.
    Pgh_Detalle      nvarchar(400) NULL,
    Pgh_Fecha        datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Pgh_Usuario      int NOT NULL
);
GO

IF OBJECT_ID('finanza.tbCuentasCobrarHistorial','U') IS NOT NULL DROP TABLE finanza.tbCuentasCobrarHistorial;
CREATE TABLE finanza.tbCuentasCobrarHistorial (
    Cgh_Id           int IDENTITY(1,1) PRIMARY KEY,
    Cco_Id           int NOT NULL,
    Cgh_Accion       nvarchar(30) NOT NULL,
    Cgh_Detalle      nvarchar(400) NULL,
    Cgh_Fecha        datetime2(0) NOT NULL DEFAULT(sysdatetime()),
    Cgh_Usuario      int NOT NULL
);
GO

/* =============================================================
   5) ÍNDICES ÚTILES
   ============================================================= */
CREATE INDEX IX_tbTarifas_CpaAnio ON finanza.tbTarifas(Cpa_Id, Tar_AnioVigencia);
CREATE INDEX IX_tbCuentasCobrar_AlumnoEstado ON finanza.tbCuentasCobrar(Alu_Id, Epa_Id);
CREATE INDEX IX_tbPagos_Fecha ON finanza.tbPagos(Pag_FechaPago);
GO

/* =============================================================
   6) SPs – PATRÓN (plantillas reutilizables)
   Cree copias cambiando el nombre de la tabla y columnas según corresponda.
   ============================================================= */

/* =====================
   A) tbConceptosPago
   ===================== */
IF OBJECT_ID('finanza.PR_tbConceptosPago_List','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbConceptosPago_List;
GO
CREATE PROCEDURE finanza.PR_tbConceptosPago_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Cpa_Id, Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo,
           Per_EsEliminado, Per_UsuarioRegistra, Per_FechaRegistra, Per_UsuarioModifica, Per_FechaModifica
    FROM finanza.tbConceptosPago
    WHERE Per_EsEliminado = 0
    ORDER BY Cpa_Descripcion;
END
GO

IF OBJECT_ID('finanza.PR_tbConceptosPago_Find','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbConceptosPago_Find;
GO
CREATE PROCEDURE finanza.PR_tbConceptosPago_Find
    @Cpa_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM finanza.tbConceptosPago
    WHERE Cpa_Id = @Cpa_Id AND Per_EsEliminado = 0;
END
GO

IF OBJECT_ID('finanza.PR_tbConceptosPago_Detail','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbConceptosPago_Detail;
GO
CREATE PROCEDURE finanza.PR_tbConceptosPago_Detail
    @Cpa_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT cp.*, COUNT(t.Tar_Id) AS CantTarifas
    FROM finanza.tbConceptosPago cp
    LEFT JOIN finanza.tbTarifas t ON t.Cpa_Id = cp.Cpa_Id AND t.Per_EsEliminado = 0
    WHERE cp.Cpa_Id = @Cpa_Id AND cp.Per_EsEliminado = 0
    GROUP BY cp.Cpa_Id, cp.Cpa_Descripcion, cp.Cpa_EsRecurrente, cp.Cpa_EsObligatorio, cp.Cpa_EsActivo,
             cp.Per_EsEliminado, cp.Per_UsuarioRegistra, cp.Per_FechaRegistra, cp.Per_UsuarioModifica, cp.Per_FechaModifica;
END
GO

IF OBJECT_ID('finanza.PR_tbConceptosPago_Insert','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbConceptosPago_Insert;
GO
CREATE PROCEDURE finanza.PR_tbConceptosPago_Insert
    @Cpa_Descripcion   nvarchar(120),
    @Cpa_EsRecurrente  bit,
    @Cpa_EsObligatorio bit,
    @Cpa_EsActivo      bit,
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbConceptosPago (Cpa_Descripcion, Cpa_EsRecurrente, Cpa_EsObligatorio, Cpa_EsActivo,
                                     Per_UsuarioRegistra)
    VALUES (@Cpa_Descripcion, @Cpa_EsRecurrente, @Cpa_EsObligatorio, @Cpa_EsActivo, @Per_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO

IF OBJECT_ID('finanza.PR_tbConceptosPago_Delete','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbConceptosPago_Delete;
GO
CREATE PROCEDURE finanza.PR_tbConceptosPago_Delete
    @Cpa_Id int,
    @Per_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbConceptosPago
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Per_UsuarioModifica,
        Per_FechaModifica = sysdatetime()
    WHERE Cpa_Id = @Cpa_Id;
END
GO

/* =====================
   B) tbCuentasCobrar (ejemplo con joins)
   ===================== */
IF OBJECT_ID('finanza.PR_tbCuentasCobrar_List','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbCuentasCobrar_List;
GO
CREATE PROCEDURE finanza.PR_tbCuentasCobrar_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT cco.Cco_Id, cco.Alu_Id, cco.Cpa_Id, cco.Tar_Id,
           cco.Cco_MontoOriginal, cco.Cco_MontoDescuento, cco.Cco_MontoMora,
           cco.Cco_MontoTotal, cco.Cco_MontoPendiente,
           cco.Cco_FechaEmision, cco.Cco_FechaVencimiento, cco.Epa_Id,
           cp.Cpa_Descripcion, epa.Epa_Descripcion,
           cco.Per_EsEliminado, cco.Per_UsuarioRegistra, cco.Per_FechaRegistra,
           cco.Per_UsuarioModifica, cco.Per_FechaModifica
    FROM finanza.tbCuentasCobrar cco
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = cco.Cpa_Id
    INNER JOIN finanza.tbEstadosPago epa ON epa.Epa_Id = cco.Epa_Id
    WHERE cco.Per_EsEliminado = 0
    ORDER BY cco.Cco_FechaVencimiento DESC, cco.Cco_Id DESC;
END
GO

IF OBJECT_ID('finanza.PR_tbCuentasCobrar_Find','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbCuentasCobrar_Find;
GO
CREATE PROCEDURE finanza.PR_tbCuentasCobrar_Find
    @Cco_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM finanza.tbCuentasCobrar WHERE Cco_Id = @Cco_Id AND Per_EsEliminado = 0;
END
GO

IF OBJECT_ID('finanza.PR_tbCuentasCobrar_Detail','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbCuentasCobrar_Detail;
GO
CREATE PROCEDURE finanza.PR_tbCuentasCobrar_Detail
    @Cco_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT cco.*, cp.Cpa_Descripcion, epa.Epa_Descripcion,
           ISNULL(SUM(pd.Pde_MontoAplicado),0) AS TotalPagado
    FROM finanza.tbCuentasCobrar cco
    INNER JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = cco.Cpa_Id
    INNER JOIN finanza.tbEstadosPago epa ON epa.Epa_Id = cco.Epa_Id
    LEFT  JOIN finanza.tbPagosDetalle pd ON pd.Cco_Id = cco.Cco_Id AND pd.Per_EsEliminado = 0
    WHERE cco.Cco_Id = @Cco_Id
    GROUP BY cco.Cco_Id, cco.Alu_Id, cco.Cpa_Id, cco.Tar_Id, cco.Cco_MontoOriginal, cco.Cco_MontoDescuento,
             cco.Cco_MontoMora, cco.Cco_MontoTotal, cco.Cco_MontoPendiente, cco.Cco_FechaEmision, cco.Cco_FechaVencimiento,
             cco.Epa_Id, cco.Cco_Observaciones, cco.Per_EsEliminado, cco.Per_UsuarioRegistra, cco.Per_FechaRegistra,
             cco.Per_UsuarioModifica, cco.Per_FechaModifica, cp.Cpa_Descripcion, epa.Epa_Descripcion;
END
GO

IF OBJECT_ID('finanza.PR_tbCuentasCobrar_Insert','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbCuentasCobrar_Insert;
GO
CREATE PROCEDURE finanza.PR_tbCuentasCobrar_Insert
    @Alu_Id int,
    @Cpa_Id int,
    @Tar_Id int = NULL,
    @Cco_MontoOriginal decimal(18,2),
    @Cco_MontoDescuento decimal(18,2) = 0,
    @Cco_MontoMora decimal(18,2) = 0,
    @Cco_MontoTotal decimal(18,2),
    @Cco_MontoPendiente decimal(18,2),
    @Cco_FechaEmision date,
    @Cco_FechaVencimiento date,
    @Epa_Id int,
    @Cco_Observaciones nvarchar(300) = NULL,
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbCuentasCobrar (
        Alu_Id, Cpa_Id, Tar_Id, Cco_MontoOriginal, Cco_MontoDescuento, Cco_MontoMora,
        Cco_MontoTotal, Cco_MontoPendiente, Cco_FechaEmision, Cco_FechaVencimiento,
        Epa_Id, Cco_Observaciones, Per_UsuarioRegistra)
    VALUES (
        @Alu_Id, @Cpa_Id, @Tar_Id, @Cco_MontoOriginal, @Cco_MontoDescuento, @Cco_MontoMora,
        @Cco_MontoTotal, @Cco_MontoPendiente, @Cco_FechaEmision, @Cco_FechaVencimiento,
        @Epa_Id, @Cco_Observaciones, @Per_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO

IF OBJECT_ID('finanza.PR_tbCuentasCobrar_Delete','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbCuentasCobrar_Delete;
GO
CREATE PROCEDURE finanza.PR_tbCuentasCobrar_Delete
    @Cco_Id int,
    @Per_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbCuentasCobrar
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Per_UsuarioModifica,
        Per_FechaModifica = sysdatetime()
    WHERE Cco_Id = @Cco_Id;
END
GO

/* =====================
   C) tbPagos (otro ejemplo)
   ===================== */
IF OBJECT_ID('finanza.PR_tbPagos_List','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbPagos_List;
GO
CREATE PROCEDURE finanza.PR_tbPagos_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Pag_Id, p.Alu_Id, p.Enc_Id, p.Fpa_Id, fp.Fpa_Descripcion,
           p.Pag_MontoTotal, p.Pag_FechaPago, p.Pag_NumeroReferencia, p.Pag_Observaciones,
           p.Usu_Id, p.Per_EsEliminado, p.Per_UsuarioRegistra, p.Per_FechaRegistra, p.Per_UsuarioModifica, p.Per_FechaModifica
    FROM finanza.tbPagos p
    INNER JOIN finanza.tbFormasPago fp ON fp.Fpa_Id = p.Fpa_Id
    WHERE p.Per_EsEliminado = 0
    ORDER BY p.Pag_FechaPago DESC, p.Pag_Id DESC;
END
GO

IF OBJECT_ID('finanza.PR_tbPagos_Find','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbPagos_Find;
GO
CREATE PROCEDURE finanza.PR_tbPagos_Find
    @Pag_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM finanza.tbPagos WHERE Pag_Id = @Pag_Id AND Per_EsEliminado = 0;
END
GO

IF OBJECT_ID('finanza.PR_tbPagos_Detail','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbPagos_Detail;
GO
CREATE PROCEDURE finanza.PR_tbPagos_Detail
    @Pag_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.*, fp.Fpa_Descripcion,
           (SELECT ISNULL(SUM(pd.Pde_MontoAplicado),0) FROM finanza.tbPagosDetalle pd WHERE pd.Pag_Id = p.Pag_Id AND pd.Per_EsEliminado = 0) AS TotalDistribuido
    FROM finanza.tbPagos p
    INNER JOIN finanza.tbFormasPago fp ON fp.Fpa_Id = p.Fpa_Id
    WHERE p.Pag_Id = @Pag_Id AND p.Per_EsEliminado = 0;
END
GO

IF OBJECT_ID('finanza.PR_tbPagos_Insert','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbPagos_Insert;
GO
CREATE PROCEDURE finanza.PR_tbPagos_Insert
    @Alu_Id int,
    @Enc_Id int = NULL,
    @Fpa_Id int,
    @Pag_MontoTotal decimal(18,2),
    @Pag_FechaPago datetime2(0),
    @Pag_NumeroReferencia nvarchar(60) = NULL,
    @Pag_Observaciones nvarchar(300) = NULL,
    @Usu_Id int,
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbPagos (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Per_UsuarioRegistra)
    VALUES (@Alu_Id, @Enc_Id, @Fpa_Id, @Pag_MontoTotal, @Pag_FechaPago, @Pag_NumeroReferencia, @Pag_Observaciones, @Usu_Id, @Per_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS NewId;
END
GO

IF OBJECT_ID('finanza.PR_tbPagos_Delete','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbPagos_Delete;
GO
CREATE PROCEDURE finanza.PR_tbPagos_Delete
    @Pag_Id int,
    @Per_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbPagos
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Per_UsuarioModifica,
        Per_FechaModifica = sysdatetime()
    WHERE Pag_Id = @Pag_Id;
END
GO

/* =====================
   D) tbPagosDetalle (breve)
   ===================== */
IF OBJECT_ID('finanza.PR_tbPagosDetalle_List','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbPagosDetalle_List;
GO
CREATE PROCEDURE finanza.PR_tbPagosDetalle_List
    @Pag_Id int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pd.*
    FROM finanza.tbPagosDetalle pd
    WHERE pd.Per_EsEliminado = 0
      AND (@Pag_Id IS NULL OR pd.Pag_Id = @Pag_Id)
    ORDER BY pd.Pde_Id DESC;
END
GO

IF OBJECT_ID('finanza.PR_tbPagosDetalle_Insert','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbPagosDetalle_Insert;
GO
CREATE PROCEDURE finanza.PR_tbPagosDetalle_Insert
    @Pag_Id int,
    @Cco_Id int,
    @Pde_MontoAplicado decimal(18,2),
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbPagosDetalle (Pag_Id, Cco_Id, Pde_MontoAplicado, Per_UsuarioRegistra)
    VALUES (@Pag_Id, @Cco_Id, @Pde_MontoAplicado, @Per_UsuarioRegistra);
    SELECT SCOPE_IDENTITY() AS NewId;
END
GO

IF OBJECT_ID('finanza.PR_tbPagosDetalle_Delete','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbPagosDetalle_Delete;
GO
CREATE PROCEDURE finanza.PR_tbPagosDetalle_Delete
    @Pde_Id int,
    @Per_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbPagosDetalle
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Per_UsuarioModifica,
        Per_FechaModifica = sysdatetime()
    WHERE Pde_Id = @Pde_Id;
END
GO

/* =====================
   E) tbRecibos (breve)
   ===================== */
IF OBJECT_ID('finanza.PR_tbRecibos_List','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbRecibos_List;
GO
CREATE PROCEDURE finanza.PR_tbRecibos_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM finanza.tbRecibos WHERE Per_EsEliminado = 0 ORDER BY Rec_FechaEmision DESC, Rec_Id DESC;
END
GO

IF OBJECT_ID('finanza.PR_tbRecibos_Find','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbRecibos_Find;
GO
CREATE PROCEDURE finanza.PR_tbRecibos_Find
    @Rec_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM finanza.tbRecibos WHERE Rec_Id = @Rec_Id AND Per_EsEliminado = 0;
END
GO

IF OBJECT_ID('finanza.PR_tbRecibos_Insert','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbRecibos_Insert;
GO
CREATE PROCEDURE finanza.PR_tbRecibos_Insert
    @Pag_Id int,
    @Rec_NumeroRecibo nvarchar(40),
    @Rec_RutaArchivo nvarchar(260) = NULL,
    @Per_UsuarioRegistra int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO finanza.tbRecibos (Pag_Id, Rec_NumeroRecibo, Rec_RutaArchivo, Per_UsuarioRegistra)
    VALUES (@Pag_Id, @Rec_NumeroRecibo, @Rec_RutaArchivo, @Per_UsuarioRegistra);
    SELECT SCOPE_IDENTITY() AS NewId;
END
GO

IF OBJECT_ID('finanza.PR_tbRecibos_Delete','P') IS NOT NULL DROP PROCEDURE finanza.PR_tbRecibos_Delete;
GO
CREATE PROCEDURE finanza.PR_tbRecibos_Delete
    @Rec_Id int,
    @Per_UsuarioModifica int
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE finanza.tbRecibos
    SET Per_EsEliminado = 1,
        Per_UsuarioModifica = @Per_UsuarioModifica,
        Per_FechaModifica = sysdatetime()
    WHERE Rec_Id = @Rec_Id;
END
GO

/* =====================
   F) Pendiente de copiar el patrón para:
      - tbTarifas
      - tbFormasPago
      - tbDescuentos
      - tbEstadosPago
      - tbDescuentosAplicados
      - tbMoratorias
   Siga el mismo esquema de {List,Find,Detail(opcional),Insert,Delete}.
   ===================== */

/* =============================================================
   7) EJEMPLOS RÁPIDOS DE USO
   =============================================================
   -- Insertar un concepto
   EXEC finanza.PR_tbConceptosPago_Insert @Cpa_Descripcion='Mensualidad', @Cpa_EsRecurrente=1, @Cpa_EsObligatorio=1, @Cpa_EsActivo=1, @Per_UsuarioRegistra=1;

   -- Listar cuentas por cobrar
   EXEC finanza.PR_tbCuentasCobrar_List;

   -- Borrar lógico un pago
   EXEC finanza.PR_tbPagos_Delete @Pag_Id=1, @Per_UsuarioModifica=1;
*/
