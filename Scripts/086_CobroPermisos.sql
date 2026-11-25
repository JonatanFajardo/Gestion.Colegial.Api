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

/* Recibo de pago: datos completos del pago para imprimir. Si el pago aún no tiene fila en finanza.tbRecibos
   (el cobro no la crea), la crea aquí con el formato REC-AAAA-NNNN (año del pago + número del pago). */
CREATE OR ALTER PROCEDURE finanza.PR_tbPagos_GetRecibo
    @Pag_Id int
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM finanza.tbPagos WHERE Pag_Id = @Pag_Id AND Pag_EsEliminado = 0)
        RETURN;

    IF NOT EXISTS (SELECT 1 FROM finanza.tbRecibos WHERE Pag_Id = @Pag_Id AND Rec_EsEliminado = 0)
    BEGIN TRY
        INSERT INTO finanza.tbRecibos (Pag_Id, Rec_NumeroRecibo, Rec_FechaEmision, Rec_EsEliminado, Rec_UsuarioRegistra, Rec_FechaRegistra)
        SELECT p.Pag_Id,
               N'REC-' + CONVERT(nvarchar(4), YEAR(p.Pag_FechaPago)) + N'-' + FORMAT(p.Pag_Id, '0000'),  -- 4 cifras como mínimo, sin recortar Ids mayores
               p.Pag_FechaRegistra, 0, p.Pag_UsuarioRegistra, SYSDATETIME()
        FROM finanza.tbPagos p WHERE p.Pag_Id = @Pag_Id;
    END TRY
    BEGIN CATCH
        -- 2627/2601: otra consulta la creó al mismo tiempo; se sigue con la existente
        IF ERROR_NUMBER() NOT IN (2627, 2601) THROW;
    END CATCH;

    SELECT
        r.Rec_Id                    AS ReciboId,
        r.Rec_NumeroRecibo          AS NumeroRecibo,
        r.Rec_FechaEmision          AS FechaEmision,
        p.Pag_Id                    AS PagoId,
        p.Pag_FechaPago             AS FechaPago,
        p.Pag_MontoTotal            AS MontoTotal,
        p.Pag_NumeroReferencia      AS NumeroReferencia,
        p.Pag_Observaciones         AS Observaciones,
        fp.Fpa_Descripcion          AS FormaPago,
        AlumnoNombre = LTRIM(RTRIM(CONCAT(pa.Per_PrimerNombre, ' ', ISNULL(pa.Per_SegundoNombre,''), ' ',
                                          pa.Per_ApellidoPaterno, ' ', ISNULL(pa.Per_ApellidoMaterno,'')))),
        pa.Per_Identidad            AS AlumnoIdentidad,
        EncargadoNombre = CASE WHEN p.Enc_Id IS NULL THEN NULL ELSE
                          LTRIM(RTRIM(CONCAT(pe.Per_PrimerNombre, ' ', ISNULL(pe.Per_SegundoNombre,''), ' ',
                                             pe.Per_ApellidoPaterno, ' ', ISNULL(pe.Per_ApellidoMaterno,'')))) END,
        NombreCompletoUsuarioRegistra = ISNULL(u.Usu_Name, N''),
        CAST(ISNULL(p.Pag_EsAnulado, 0) AS bit) AS EsAnulado,
        p.Pag_MotivoAnulacion       AS MotivoAnulacion,
        p.Pag_FechaAnulacion        AS FechaAnulacion,
        SaldoPendiente = ISNULL((SELECT SUM(c.Cco_MontoPendiente) FROM finanza.tbCuentasCobrar c
                                 WHERE c.Alu_Id = p.Alu_Id AND c.Cco_EsEliminado = 0), 0),
        ColegioNombre   = (SELECT TOP 1 Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = N'institucion_nombre'),
        ColegioTelefono = (SELECT TOP 1 Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = N'institucion_telefono'),
        ColegioDireccion = (SELECT TOP 1 Con_Valor FROM app.tbConfiguracion WHERE Con_Clave = N'institucion_direccion'),
        Lineas = (SELECT cp.Cpa_Descripcion AS Concepto, c.Cco_Mes AS Mes, c.Cco_Anio AS Anio,
                         d.Pde_MontoAplicado AS Monto, c.Cco_MontoDescuento AS Descuento
                  FROM finanza.tbPagosDetalle d
                  JOIN finanza.tbCuentasCobrar c ON c.Cco_Id = d.Cco_Id
                  LEFT JOIN finanza.tbConceptosPago cp ON cp.Cpa_Id = c.Cpa_Id
                  WHERE d.Pag_Id = p.Pag_Id AND d.Pde_EsEliminado = 0
                  ORDER BY c.Cco_Anio, c.Cco_Mes, d.Pde_Id
                  FOR JSON PATH)
    FROM finanza.tbPagos p
    JOIN finanza.tbFormasPago fp ON fp.Fpa_Id = p.Fpa_Id
    JOIN finanza.tbRecibos r ON r.Pag_Id = p.Pag_Id AND r.Rec_EsEliminado = 0
    LEFT JOIN app.tbAlumnos a ON a.Alu_Id = p.Alu_Id
    LEFT JOIN app.tbPersonas pa ON pa.Per_Id = a.Per_Id
    LEFT JOIN app.tbEncargados e ON e.Enc_Id = p.Enc_Id
    LEFT JOIN app.tbPersonas pe ON pe.Per_Id = e.Per_Id
    LEFT JOIN seguridad.tbUsuarios u ON u.Usu_Id = p.Usu_Id
    WHERE p.Pag_Id = @Pag_Id AND p.Pag_EsEliminado = 0;
END
GO
