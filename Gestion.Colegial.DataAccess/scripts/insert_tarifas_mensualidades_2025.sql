-- =============================================
-- INSERTAR TARIFAS MENSUALIDADES 2025
-- =============================================
-- Este script inserta tarifas para todas las combinaciones
-- válidas de CursoNivel + Modalidad según tbModalidades_tbCursosNiveles
-- =============================================

USE DB_GESTION_COLEGIAL
GO

-- Limpiar tarifas anteriores del año 2025 si existen (opcional)
-- DELETE FROM finanza.tbTarifasMensualidades WHERE TarMen_AnioVigencia = 2025
-- GO

-- =============================================
-- NIVEL BÁSICO (7°, 8°, 9°) - MODALIDAD MATUTINA
-- =============================================

-- Séptimo Matutina
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (1, 1, 1200.00, 2025, 1, 0, 1, GETDATE())

-- Octavo Matutina
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (2, 1, 1250.00, 2025, 1, 0, 1, GETDATE())

-- Noveno Matutina
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (3, 1, 1300.00, 2025, 1, 0, 1, GETDATE())

-- =============================================
-- NIVEL BÁSICO (7°, 8°, 9°) - MODALIDAD VESPERTINA
-- =============================================

-- Séptimo Vespertina
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (1, 2, 1100.00, 2025, 1, 0, 1, GETDATE())

-- Octavo Vespertina
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (2, 2, 1150.00, 2025, 1, 0, 1, GETDATE())

-- Noveno Vespertina
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (3, 2, 1200.00, 2025, 1, 0, 1, GETDATE())

-- =============================================
-- NIVEL BÁSICO (7°, 8°, 9°) - MODALIDAD NOCTURNA
-- =============================================

-- Séptimo Nocturna
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (1, 3, 1300.00, 2025, 1, 0, 1, GETDATE())

-- Octavo Nocturna
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (2, 3, 1350.00, 2025, 1, 0, 1, GETDATE())

-- Noveno Nocturna
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (3, 3, 1400.00, 2025, 1, 0, 1, GETDATE())

-- =============================================
-- NIVEL DIVERSIFICADO (10°, 11°, 12°) - MODALIDAD MATUTINA
-- =============================================

-- Décimo Matutina
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (4, 1, 1400.00, 2025, 1, 0, 1, GETDATE())

-- Undécimo Matutina
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (5, 1, 1450.00, 2025, 1, 0, 1, GETDATE())

-- Duodécimo Matutina
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (6, 1, 1500.00, 2025, 1, 0, 1, GETDATE())

-- =============================================
-- NIVEL DIVERSIFICADO (10°, 11°, 12°) - MODALIDAD VESPERTINA
-- =============================================

-- Décimo Vespertina
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (4, 2, 1300.00, 2025, 1, 0, 1, GETDATE())

-- Undécimo Vespertina
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (5, 2, 1350.00, 2025, 1, 0, 1, GETDATE())

-- Duodécimo Vespertina
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (6, 2, 1400.00, 2025, 1, 0, 1, GETDATE())

-- =============================================
-- NIVEL DIVERSIFICADO (10°, 11°, 12°) - MODALIDAD NOCTURNA
-- =============================================

-- Décimo Nocturna
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (4, 3, 1500.00, 2025, 1, 0, 1, GETDATE())

-- Undécimo Nocturna
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (5, 3, 1550.00, 2025, 1, 0, 1, GETDATE())

-- Duodécimo Nocturna
INSERT INTO finanza.tbTarifasMensualidades (Cun_Id, Mda_Id, TarMen_Monto, TarMen_AnioVigencia, TarMen_EsActivo, TarMen_EsEliminado, TarMen_UsuarioRegistra, TarMen_FechaRegistra)
VALUES (6, 3, 1600.00, 2025, 1, 0, 1, GETDATE())

GO

-- =============================================
-- VERIFICAR DATOS INSERTADOS
-- =============================================

SELECT
    TM.TarMen_Id,
    CN.Cun_Descripcion AS Curso,
    M.Mda_Descripcion AS Modalidad,
    TM.TarMen_Monto AS Monto,
    TM.TarMen_AnioVigencia AS Anio,
    CASE WHEN TM.TarMen_EsActivo = 1 THEN 'Activo' ELSE 'Inactivo' END AS Estado
FROM finanza.tbTarifasMensualidades TM
INNER JOIN gral.tbCursosNiveles CN ON TM.Cun_Id = CN.Cun_Id
INNER JOIN gral.tbModalidades M ON TM.Mda_Id = M.Mda_Id
WHERE TM.TarMen_AnioVigencia = 2025
ORDER BY CN.Cun_Orden, M.Mda_Id

PRINT ''
PRINT 'Total de tarifas insertadas para 2025: ' + CAST(@@ROWCOUNT AS VARCHAR(10))
GO
