-- 041_DashboardCajero_SeedHoy.sql
-- Seed cobros de prueba para HOY (usa GETDATE() dinamicamente)
-- Idempotente: limpia antes de insertar.
-- Ejecutar via PowerShell SqlConnection para evitar problemas de encoding.
-- Alumnos usados: 25 (Gissela Coto), 68 (Alonso Cabrera), 69 (Jency Reyes), 314 (Kelinda Cabrera)

DECLARE @HoyDate DATE = CAST(GETDATE() AS DATE);
DECLARE @Ayer    DATE = DATEADD(DAY, -1, @HoyDate);

-- Limpiar cobros de hoy para Usu_Id=1
DELETE pd FROM finanza.tbPagosDetalle pd
 INNER JOIN finanza.tbPagos p ON p.Pag_Id = pd.Pag_Id
 WHERE p.Usu_Id=1 AND CAST(p.Pag_FechaPago AS DATE) = @HoyDate;
DELETE FROM finanza.tbPagos
 WHERE Usu_Id=1 AND CAST(Pag_FechaPago AS DATE) = @HoyDate;
DELETE FROM finanza.tbArqueosCaja
 WHERE Usu_Id=1 AND Arq_Fecha = @Ayer;
GO

DECLARE @HoyDate DATE = CAST(GETDATE() AS DATE);
DECLARE @Ayer    DATE = DATEADD(DAY, -1, @HoyDate);
DECLARE @F DATETIME2;
DECLARE @PagId INT;

-- Pago 1: 08:15 - Gissela Coto (Alu_Id=25) - Matricula - Efectivo (Fpa_Id=1) - Cco_Id=3
SET @F = DATETIMEFROMPARTS(YEAR(@HoyDate), MONTH(@HoyDate), DAY(@HoyDate), 8, 15, 0, 0);
INSERT INTO finanza.tbPagos
  (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
VALUES (25, 0, 1, 500.00, @F, N'REF-HOY-001', N'Cobro matricula', 1, 0, 1, @F);
SET @PagId = SCOPE_IDENTITY();
INSERT INTO finanza.tbPagosDetalle
  (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra)
VALUES (@PagId, 3, 500.00, 0, 1, @F);

-- Pago 2: 09:30 - Alonso Cabrera (Alu_Id=68) - Mensualidad - Tarjeta (Fpa_Id=2) - Cco_Id=4
SET @F = DATETIMEFROMPARTS(YEAR(@HoyDate), MONTH(@HoyDate), DAY(@HoyDate), 9, 30, 0, 0);
INSERT INTO finanza.tbPagos
  (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
VALUES (68, 0, 2, 800.00, @F, N'REF-HOY-002', N'Mensualidad junio', 1, 0, 1, @F);
SET @PagId = SCOPE_IDENTITY();
INSERT INTO finanza.tbPagosDetalle
  (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra)
VALUES (@PagId, 4, 800.00, 0, 1, @F);

-- Pago 3: 10:45 - Jency Reyes (Alu_Id=69) - Mensualidad - Transferencia (Fpa_Id=3) - Cco_Id=5
SET @F = DATETIMEFROMPARTS(YEAR(@HoyDate), MONTH(@HoyDate), DAY(@HoyDate), 10, 45, 0, 0);
INSERT INTO finanza.tbPagos
  (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
VALUES (69, 0, 3, 840.00, @F, N'REF-HOY-003', N'Pago transferencia BAC', 1, 0, 1, @F);
SET @PagId = SCOPE_IDENTITY();
INSERT INTO finanza.tbPagosDetalle
  (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra)
VALUES (@PagId, 5, 840.00, 0, 1, @F);

-- Pago 4: 11:20 - Gissela Coto (Alu_Id=25) - Mensualidad - Efectivo (Fpa_Id=1) - Cco_Id=41
SET @F = DATETIMEFROMPARTS(YEAR(@HoyDate), MONTH(@HoyDate), DAY(@HoyDate), 11, 20, 0, 0);
INSERT INTO finanza.tbPagos
  (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
VALUES (25, 0, 1, 850.00, @F, N'REF-HOY-004', N'Mensualidad junio', 1, 0, 1, @F);
SET @PagId = SCOPE_IDENTITY();
INSERT INTO finanza.tbPagosDetalle
  (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra)
VALUES (@PagId, 41, 850.00, 0, 1, @F);

-- Pago 5: 13:50 - Kelinda Cabrera (Alu_Id=314) - Matricula - Tarjeta (Fpa_Id=2) - Cco_Id=7
SET @F = DATETIMEFROMPARTS(YEAR(@HoyDate), MONTH(@HoyDate), DAY(@HoyDate), 13, 50, 0, 0);
INSERT INTO finanza.tbPagos
  (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
VALUES (314, 0, 2, 450.00, @F, N'REF-HOY-005', N'Matricula nueva', 1, 0, 1, @F);
SET @PagId = SCOPE_IDENTITY();
INSERT INTO finanza.tbPagosDetalle
  (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra)
VALUES (@PagId, 7, 450.00, 0, 1, @F);

-- Pago 6: 15:10 - Alonso Cabrera (Alu_Id=68) - Mensualidad - Efectivo (Fpa_Id=1) - Cco_Id=4
SET @F = DATETIMEFROMPARTS(YEAR(@HoyDate), MONTH(@HoyDate), DAY(@HoyDate), 15, 10, 0, 0);
INSERT INTO finanza.tbPagos
  (Alu_Id, Enc_Id, Fpa_Id, Pag_MontoTotal, Pag_FechaPago, Pag_NumeroReferencia, Pag_Observaciones, Usu_Id, Pag_EsEliminado, Pag_UsuarioRegistra, Pag_FechaRegistra)
VALUES (68, 0, 1, 300.00, @F, N'REF-HOY-006', N'Abono mensualidad', 1, 0, 1, @F);
SET @PagId = SCOPE_IDENTITY();
INSERT INTO finanza.tbPagosDetalle
  (Pag_Id, Cco_Id, Pde_MontoAplicado, Pde_EsEliminado, Pde_UsuarioRegistra, Pde_FechaRegistra)
VALUES (@PagId, 4, 300.00, 0, 1, @F);

-- Arqueo de ayer
INSERT INTO finanza.tbArqueosCaja
  (Usu_Id, Arq_Fecha, Arq_TotalEfectivo, Arq_TotalTransferencia, Arq_TotalTarjeta,
   Arq_Observaciones, Arq_EsEliminado, Arq_UsuarioRegistra, Arq_FechaRegistra)
VALUES (1, @Ayer, 1650.00, 840.00, 1250.00, N'Cierre de jornada sin novedades.', 0, 1, GETDATE());
GO
