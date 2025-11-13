#!/usr/bin/env python3
"""
Script para reformatear procedimientos almacenados según las reglas especificadas.
"""

# Definición de tablas y sus estructuras
TABLAS = {
    'tbFormasPago': {
        'alias': 'fp',
        'prefijo': 'Fpa',
        'campos': ['Fpa_Id', 'Fpa_Descripcion', 'Fpa_EsActivo'],
        'id_field': 'Fpa_Id',
        'desc_field': 'Fpa_Descripcion',
        'order_by': 'Fpa_Descripcion',
        'relaciones': []
    },
    'tbEstadosPago': {
        'alias': 'ep',
        'prefijo': 'Epa',
        'campos': ['Epa_Id', 'Epa_Descripcion'],
        'id_field': 'Epa_Id',
        'desc_field': 'Epa_Descripcion',
        'order_by': 'Epa_Descripcion',
        'relaciones': []
    },
    'tbConceptosPago': {
        'alias': 'cp',
        'prefijo': 'Cpa',
        'campos': ['Cpa_Id', 'Cpa_Descripcion', 'Cpa_EsRecurrente'],
        'id_field': 'Cpa_Id',
        'desc_field': 'Cpa_Descripcion',
        'order_by': 'Cpa_Descripcion',
        'relaciones': []
    },
    'tbDescuentos': {
        'alias': 'des',
        'prefijo': 'Des',
        'campos': ['Des_Id', 'Des_Descripcion', 'Des_TipoDescuento', 'Des_Valor', 'Des_EsActivo'],
        'id_field': 'Des_Id',
        'desc_field': 'Des_Descripcion',
        'order_by': 'Des_Descripcion',
        'relaciones': []
    },
    'tbTarifas': {
        'alias': 't',
        'prefijo': 'Tar',
        'campos': ['Tar_Id', 'Cpa_Id', 'Niv_Id', 'Tar_Monto', 'Tar_AnioVigencia', 'Tar_EsActivo'],
        'id_field': 'Tar_Id',
        'desc_field': None,
        'order_by': 'Tar_Id DESC',
        'relaciones': [
            {'tabla': 'tbConceptosPago', 'alias': 'cp', 'campo_fk': 'Cpa_Id', 'campo_desc': 'Cpa_Descripcion', 'desc_as': 'DescripcionConceptoPago'},
        ]
    }
}

def generar_list(tabla_info, tabla_nombre):
    """Genera procedimiento LIST"""
    alias = tabla_info['alias']
    campos = tabla_info['campos']
    order_by = tabla_info['order_by']

    # Campos a mostrar (sin IDs, sin auditoría)
    campos_select = []
    for campo in campos:
        if not campo.endswith('_Id') or campo == tabla_info.get('desc_field'):
            campos_select.append(f"        {alias}.{campo}")

    # JOINs para descripciones
    joins = ""
    for rel in tabla_info.get('relaciones', []):
        rel_alias = rel['alias']
        campo_fk = rel['campo_fk']
        joins += f"\n        INNER JOIN finanza.{rel['tabla']} {rel_alias} ON {alias}.{campo_fk} = {rel_alias}.{campo_fk}"
        campos_select.append(f"        {rel_alias}.{rel['campo_desc']} AS {rel['desc_as']}")

    proc = f"""-- ============================================================================
-- PR_{tabla_nombre}_List
-- Tipo: LIST - Sin IDs, sin auditoría, solo descripciones
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_{tabla_nombre}_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
{',\\n'.join(campos_select)}
    FROM
        finanza.{tabla_nombre} {alias}{joins}
    WHERE
        {alias}.Per_EsEliminado != 1
    ORDER BY
        {alias}.{order_by};
END
GO"""
    return proc

def generar_find(tabla_info, tabla_nombre):
    """Genera procedimiento FIND"""
    alias = tabla_info['alias']
    id_field = tabla_info['id_field']
    campos = tabla_info['campos']

    # Todos los campos con IDs, sin auditoría
    campos_select = [f"        {alias}.{campo}" for campo in campos]

    # JOINs para descripciones
    joins = ""
    for rel in tabla_info.get('relaciones', []):
        rel_alias = rel['alias']
        campo_fk = rel['campo_fk']
        joins += f"\n        INNER JOIN finanza.{rel['tabla']} {rel_alias} ON {alias}.{campo_fk} = {rel_alias}.{campo_fk}"
        campos_select.append(f"        {rel_alias}.{rel['campo_desc']} AS {rel['desc_as']}")

    proc = f"""-- ============================================================================
-- PR_{tabla_nombre}_Find
-- Tipo: FIND - Con IDs y descripciones, sin auditoría
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_{tabla_nombre}_Find]
    @{id_field} int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
{',\\n'.join(campos_select)}
    FROM
        finanza.{tabla_nombre} {alias}{joins}
    WHERE
        {alias}.{id_field} = @{id_field}
        AND {alias}.Per_EsEliminado != 1;
END
GO"""
    return proc

def generar_detail(tabla_info, tabla_nombre):
    """Genera procedimiento DETAIL"""
    alias = tabla_info['alias']
    id_field = tabla_info['id_field']
    campos = tabla_info['campos']

    # Todos los campos con IDs
    campos_select = [f"        {alias}.{campo}" for campo in campos]

    # JOINs para descripciones
    joins = ""
    for rel in tabla_info.get('relaciones', []):
        rel_alias = rel['alias']
        campo_fk = rel['campo_fk']
        joins += f"\n        INNER JOIN finanza.{rel['tabla']} {rel_alias} ON {alias}.{campo_fk} = {rel_alias}.{campo_fk}"
        campos_select.append(f"        {rel_alias}.{rel['campo_desc']} AS {rel['desc_as']}")

    # Agregar campos de auditoría
    campos_select.extend([
        f"        -- Campos de auditoría",
        f"        {alias}.Per_EsEliminado",
        f"        {alias}.Per_UsuarioRegistra",
        f"        usuarioRegistra.Usu_Name AS NombreCompletoUsuarioRegistra",
        f"        {alias}.Per_FechaRegistra",
        f"        {alias}.Per_UsuarioModifica",
        f"        usuarioModificacion.Usu_Name AS NombreCompletoUsuarioModifica",
        f"        {alias}.Per_FechaModifica"
    ])

    # JOINs para auditoría
    joins += f"""
        -- JOINs para auditoría
        LEFT JOIN seguridad.tbUsuarios AS usuarioRegistra
            ON {alias}.Per_UsuarioRegistra = usuarioRegistra.Usu_Id
        LEFT JOIN seguridad.tbUsuarios AS usuarioModificacion
            ON {alias}.Per_UsuarioModifica = usuarioModificacion.Usu_Id"""

    proc = f"""-- ============================================================================
-- PR_{tabla_nombre}_Detail
-- Tipo: DETAIL - Con IDs, descripciones y auditoría completa
-- ============================================================================
ALTER PROCEDURE [finanza].[PR_{tabla_nombre}_Detail]
    @{id_field} int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
{',\\n'.join(campos_select)}
    FROM
        finanza.{tabla_nombre} {alias}{joins}
    WHERE
        {alias}.{id_field} = @{id_field}
        AND {alias}.Per_EsEliminado != 1;
END
GO"""
    return proc

# Generar todos los procedimientos
print("-- ============================================================================")
print("-- PROCEDIMIENTOS REFORMATEADOS - CATÁLOGOS SIMPLES")
print("-- ============================================================================")
print()

for tabla_nombre, tabla_info in TABLAS.items():
    print(f"-- Tabla: {tabla_nombre}")
    print()
    print(generar_list(tabla_info, tabla_nombre))
    print()
    print(generar_find(tabla_info, tabla_nombre))
    print()
    print(generar_detail(tabla_info, tabla_nombre))
    print()
    print()
