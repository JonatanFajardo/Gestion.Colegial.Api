#!/usr/bin/env python3
"""
ejecutar_scripts.py
==============================================================
Ejecuta scripts SQL en DB_GestionColegial via pyodbc.
Divide por GO (igual que sqlcmd) y ejecuta cada bloque.

Uso:
    python tools/ejecutar_scripts.py
    python tools/ejecutar_scripts.py --server Ali
    python tools/ejecutar_scripts.py --script Scripts/006_Tablas_Funcionales.sql
    python tools/ejecutar_scripts.py --init   # crea la DB desde el script maestro

Requiere:
    pip install pyodbc
==============================================================
"""

import argparse
import re
import sys
from pathlib import Path

BASE        = Path(__file__).parent.parent
SCRIPTS_DIR = BASE / 'Scripts'
SCRIPT_INIT = BASE / 'Gestion.Colegial.DataAccess' / 'Sql' / 'V3' / '3.3 - 2019' / 'DB_GestionColegial.sql'

SCRIPTS_DEFAULT = [
    '006_Tablas_Funcionales.sql',
    '007_SPs_Funcionales.sql',
    '008_Pantallas_Funcionales.sql',
    '009_Pantallas_Expandidas.sql',
]


# ============================================================
#  CONEXION
# ============================================================

def get_connection(server: str, database: str):
    try:
        import pyodbc
    except ImportError:
        print('\n  [ERROR] pyodbc no instalado.  Ejecuta:  pip install pyodbc')
        sys.exit(1)

    conn_str = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"Server={server};"
        f"Database={database};"
        f"Trusted_Connection=yes;"
    )
    try:
        return pyodbc.connect(conn_str, autocommit=True, timeout=10)
    except Exception as e:
        print(f'\n  [ERROR] No se pudo conectar a {server}/{database}')
        print(f'          {e}')
        print()
        if 'Cannot open database' in str(e) or '4060' in str(e):
            print('  La base de datos no existe. Opciones:')
            print('    1. Restáurala desde un backup (.bak)')
            print('    2. Créala desde el script maestro:')
            print('         python tools/ejecutar_scripts.py --init')
        else:
            print('  Verifica que SQL Server esté corriendo y el servidor sea correcto.')
            print('    Servidor detectado en esta PC: Ali')
            print('    Uso: python tools/ejecutar_scripts.py --server Ali')
        sys.exit(1)


def db_existe(server: str, db: str) -> bool:
    try:
        import pyodbc
        conn_str = (
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"Server={server};Database=master;Trusted_Connection=yes;"
        )
        conn = pyodbc.connect(conn_str, autocommit=True, timeout=5)
        row = conn.cursor().execute(
            "SELECT COUNT(*) FROM sys.databases WHERE name = ?", db
        ).fetchone()
        conn.close()
        return row[0] > 0
    except Exception:
        return False


# ============================================================
#  EJECUCION DE SCRIPTS
# ============================================================

def ejecutar_sql(conn, sql_path: Path) -> bool:
    script  = sql_path.read_text(encoding='utf-8')
    bloques = re.split(r'^\s*GO\s*$', script, flags=re.MULTILINE | re.IGNORECASE)
    cursor  = conn.cursor()
    errores = 0

    for i, bloque in enumerate(bloques, 1):
        bloque = bloque.strip()
        if not bloque:
            continue
        try:
            cursor.execute(bloque)
        except Exception as e:
            print(f'\n    [WARN] Bloque {i}: {e}')
            errores += 1

    cursor.close()
    return errores == 0


def ejecutar_archivo(conn, path: Path) -> bool:
    print(f'  Ejecutando {path.name}...', end=' ', flush=True)
    ok = ejecutar_sql(conn, path)
    print('[OK]' if ok else '[con advertencias — ver arriba]')
    return ok


# ============================================================
#  MAIN
# ============================================================

def main():
    parser = argparse.ArgumentParser(description='Ejecuta scripts SQL en DB_GestionColegial')
    parser.add_argument('--server', default='(localdb)\\MSSQLLocalDB', help='Servidor SQL Server (default: (localdb)\\MSSQLLocalDB)')
    parser.add_argument('--db',     default='DB_GestionColegial', help='Nombre de la base de datos')
    parser.add_argument('--script', default=None,                help='Ejecutar un solo archivo .sql')
    parser.add_argument('--init',   action='store_true',         help='Crear la DB desde el script maestro')
    args = parser.parse_args()

    print()
    print('=' * 55)
    print(' Gestion Colegial — Ejecutor de Scripts SQL')
    print('=' * 55)
    print(f'  Servidor     : {args.server}')
    print(f'  Base de datos: {args.db}')
    print()

    # ── Modo --init: crear la base de datos desde cero ──────
    if args.init:
        if not SCRIPT_INIT.exists():
            print(f'  [ERROR] Script maestro no encontrado: {SCRIPT_INIT}')
            sys.exit(1)
        print('  Modo --init: creando base de datos desde script maestro...')
        print(f'  Archivo: {SCRIPT_INIT.name}')
        print()
        print('  Conectando a master...', end=' ', flush=True)
        conn = get_connection(args.server, 'master')
        print('[OK]')
        ejecutar_archivo(conn, SCRIPT_INIT)
        conn.close()
        print()
        print('  Base de datos creada. Ahora ejecuta sin --init para aplicar los scripts funcionales.')
        print()
        return

    # ── Verificar si la DB existe ────────────────────────────
    print('  Verificando base de datos...', end=' ', flush=True)
    if not db_existe(args.server, args.db):
        print()
        print(f'\n  [WARN] La base de datos "{args.db}" no existe en {args.server}.')
        print()
        print('  Opciones:')
        print('    1. Restáurala desde un backup (.bak) en SSMS')
        print('    2. Créala con el script maestro:')
        print(f'         python tools/ejecutar_scripts.py --init --server {args.server}')
        sys.exit(1)
    print('[OK]')

    # ── Conectar a la DB objetivo ────────────────────────────
    print('  Conectando...', end=' ', flush=True)
    conn = get_connection(args.server, args.db)
    print('[OK]')
    print()

    # ── Determinar scripts ───────────────────────────────────
    if args.script:
        scripts = [Path(args.script)]
    else:
        scripts = [SCRIPTS_DIR / s for s in SCRIPTS_DEFAULT]

    for s in scripts:
        if not s.exists():
            print(f'  [ERROR] Archivo no encontrado: {s}')
            conn.close()
            sys.exit(1)

    # ── Ejecutar ─────────────────────────────────────────────
    total_ok = 0
    for script in scripts:
        ok = ejecutar_archivo(conn, script)
        if ok:
            total_ok += 1

    conn.close()

    print()
    print('=' * 55)
    print(f'  Resultado: {total_ok}/{len(scripts)} scripts OK.')
    print('=' * 55)
    print()

    if total_ok < len(scripts):
        print('  Algunos scripts tuvieron advertencias. Revisa los [WARN] arriba.')
        print()


if __name__ == '__main__':
    main()
