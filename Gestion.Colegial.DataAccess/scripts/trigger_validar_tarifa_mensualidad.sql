-- =============================================
-- TRIGGER PARA VALIDAR COMBINACIÓN CURSO-MODALIDAD
-- =============================================
-- Este trigger valida que la combinación de Cun_Id y Mda_Id
-- exista en tbModalidades_tbCursosNiveles antes de insertar/actualizar
-- =============================================

USE DB_GESTION_COLEGIAL
GO

-- Eliminar trigger si existe
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'TR_TarifasMensualidades_ValidarCombinacion')
    DROP TRIGGER finanza.TR_TarifasMensualidades_ValidarCombinacion
GO

CREATE TRIGGER finanza.TR_TarifasMensualidades_ValidarCombinacion
ON finanza.tbTarifasMensualidades
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar que todas las combinaciones insertadas/actualizadas sean válidas
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE NOT EXISTS (
            SELECT 1
            FROM gral.tbModalidades_tbCursosNiveles MN
            WHERE MN.Cun_Id = i.Cun_Id
              AND MN.Mda_Id = i.Mda_Id
        )
    )
    BEGIN
        RAISERROR('La combinación de CursoNivel y Modalidad no es válida. Verifique la tabla tbModalidades_tbCursosNiveles.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
END
GO

PRINT 'Trigger finanza.TR_TarifasMensualidades_ValidarCombinacion creado exitosamente'
GO
