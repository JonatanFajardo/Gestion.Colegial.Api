-- =====================================================================
-- 047_ArqueosCaja_Cuadre_ALTER_PARA_REVISION.sql
-- *** SOLO PARA REVISION - NO APLICAR SIN VALIDAR CON EL EQUIPO ***
--
--   Objetivo: persistir el cuadre de caja (esperado según sistema vs.
--   lo contado por el cajero) en lugar de calcularlo solo en memoria/UI.
--
--   1) ALTER TABLE finanza.tbArqueosCaja: agrega
--        Arq_TotalEsperado DECIMAL(10,2) NULL  -- total que el sistema esperaba (pagos del día, etc.)
--        Arq_Diferencia    DECIMAL(10,2) NULL  -- Arq_TotalGeneral (contado) - Arq_TotalEsperado
--      Se dejan NULL-ables para no romper filas históricas ya insertadas.
--      Arq_Diferencia podría convertirse a columna calculada
--      (AS (Arq_TotalGeneral - Arq_TotalEsperado)) si se prefiere no
--      persistirla explícitamente; se deja como columna normal aquí para
--      simplicidad de INSERT explícito, a discutir con el equipo.
--
--   2) ALTER de PR_tbArqueosCaja_Insert para recibir @Arq_TotalEsperado
--      y calcular/guardar @Arq_Diferencia.
--
--   Follow-up UI (GESTION_COLEGIAL_ADM, no incluido en este script):
--     - ArqueosCajaAdmController / arqueosCajaAdm.js deben calcular el
--       total esperado del día (desde Pagos/HistorialTransacciones) y
--       enviarlo en el POST de creación de arqueo.
--     - Views/ArqueosCajaAdm/Index.cshtml debe mostrar el historial
--       (consumiendo el nuevo endpoint ListAsync) con columnas de
--       Esperado / Contado / Diferencia, resaltando diferencias != 0.
-- =====================================================================

-- --- 1) ALTER TABLE ---------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[finanza].[tbArqueosCaja]') AND name = 'Arq_TotalEsperado'
)
BEGIN
    ALTER TABLE [finanza].[tbArqueosCaja]
        ADD Arq_TotalEsperado DECIMAL(10,2) NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[finanza].[tbArqueosCaja]') AND name = 'Arq_Diferencia'
)
BEGIN
    ALTER TABLE [finanza].[tbArqueosCaja]
        ADD Arq_Diferencia DECIMAL(10,2) NULL;
END
GO

-- --- 2) ALTER PR_tbArqueosCaja_Insert ---------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finanza].[PR_tbArqueosCaja_Insert]') AND type = 'P')
    DROP PROCEDURE [finanza].[PR_tbArqueosCaja_Insert];
GO
CREATE PROCEDURE [finanza].[PR_tbArqueosCaja_Insert]
    @Usu_Id                INT,
    @Arq_Fecha             DATE,
    @Arq_TotalEfectivo     DECIMAL(10,2),
    @Arq_TotalTransferencia DECIMAL(10,2),
    @Arq_TotalTarjeta      DECIMAL(10,2),
    @Arq_TotalEsperado     DECIMAL(10,2) = NULL,
    @Arq_Observaciones     VARCHAR(300)  = NULL,
    @Arq_UsuarioRegistra   INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalContado DECIMAL(10,2) = @Arq_TotalEfectivo + @Arq_TotalTransferencia + @Arq_TotalTarjeta;
    DECLARE @Diferencia   DECIMAL(10,2) = CASE WHEN @Arq_TotalEsperado IS NULL THEN NULL
                                                ELSE @TotalContado - @Arq_TotalEsperado END;

    INSERT INTO [finanza].[tbArqueosCaja]
        (Usu_Id, Arq_Fecha, Arq_TotalEfectivo, Arq_TotalTransferencia, Arq_TotalTarjeta,
         Arq_TotalEsperado, Arq_Diferencia, Arq_Observaciones, Arq_UsuarioRegistra)
    VALUES
        (@Usu_Id, @Arq_Fecha, @Arq_TotalEfectivo, @Arq_TotalTransferencia, @Arq_TotalTarjeta,
         @Arq_TotalEsperado, @Diferencia, @Arq_Observaciones, @Arq_UsuarioRegistra);

    SELECT SCOPE_IDENTITY() AS Arq_Id;
END
GO

-- NOTA: PR_tbArqueosCaja_Find, PR_tbArqueosCaja_LastByUsuario y el nuevo
-- PR_tbArqueosCaja_List (046) deberían extenderse para devolver también
-- Arq_TotalEsperado y Arq_Diferencia una vez este ALTER se apruebe y aplique.
