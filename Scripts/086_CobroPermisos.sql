/* 086 - Permiso para escribir en los catálogos de cobranza (conceptos, formas de pago, descuentos, tarifas).
   La API lo exige en sus altas, cambios y bajas. Roles: admin (1) y contador (1006). Idempotente. */
USE DB_GestionColegial;
GO
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(100));
INSERT INTO @Pantallas VALUES (N'Editar catálogos de cobranza', N'|1|1006|');

INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
SELECT x.Nombre, 1, 0, 'Financiero'
FROM @Pantallas x
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas p WHERE p.Pan_Descripcion = x.Nombre);

INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN @Pantallas x ON x.Nombre = p.Pan_Descripcion
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0
                        AND x.Roles LIKE N'%|' + CONVERT(nvarchar(10), r.Rol_Id) + N'|%'
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas y WHERE y.Rol_Id = r.Rol_Id AND y.Pan_Id = p.Pan_Id);
GO
