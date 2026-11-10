-- =====================================================================
-- 046_PR_tbArqueosCaja_List.sql
--   Historial de arqueos de caja por usuario y/o rango de fechas.
--   Complementa PR_tbArqueosCaja_LastByUsuario (que ya trae TOP 10 pero
--   el servicio/controller lo colapsaba a 1 registro con GetSingleAsync).
--   Este SP nuevo permite listar sin límite de 10 y filtrar por rango.
-- =====================================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finanza].[PR_tbArqueosCaja_List]') AND type = 'P')
    DROP PROCEDURE [finanza].[PR_tbArqueosCaja_List];
GO
CREATE PROCEDURE [finanza].[PR_tbArqueosCaja_List]
    @Usu_Id      INT      = NULL,
    @FechaDesde  DATE     = NULL,
    @FechaHasta  DATE     = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.Arq_Id, a.Usu_Id, a.Arq_Fecha, a.Arq_TotalEfectivo, a.Arq_TotalTransferencia,
        a.Arq_TotalTarjeta, a.Arq_TotalGeneral, a.Arq_Observaciones, a.Arq_FechaRegistra,
        u.Usu_Name
    FROM [finanza].[tbArqueosCaja] a
    INNER JOIN [Seguridad].[tbUsuarios] u ON a.Usu_Id = u.Usu_Id
    WHERE a.Arq_EsEliminado = 0
      AND (@Usu_Id     IS NULL OR a.Usu_Id = @Usu_Id)
      AND (@FechaDesde  IS NULL OR a.Arq_Fecha >= @FechaDesde)
      AND (@FechaHasta  IS NULL OR a.Arq_Fecha <= @FechaHasta)
    ORDER BY a.Arq_Fecha DESC, a.Arq_FechaRegistra DESC;
END
GO
