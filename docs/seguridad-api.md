# Seguridad de la API: llave compartida y usuario firmado

La API solo debe responder al ADM. Para eso las dos aplicaciones comparten una llave secreta
en la variable de entorno `GC_API_KEY`.

## Cómo funciona

| Encabezado | Lo manda el ADM | Qué hace la API |
|---|---|---|
| `X-Api-Key` | En **todas** las llamadas | Si falta o no coincide → **401** (comparación de tiempo constante). |
| `X-Gc-Usuario` | En las llamadas hechas con sesión iniciada | Valor `Usu_Id\|segundos\|firma`, con firma = HMAC-SHA256 de `Usu_Id\|segundos` usando la llave (hexadecimal). Si la firma no cuadra o tiene más de 5 minutos de diferencia → **401**. |

Con un usuario firmado válido, la API lee de la base (`seguridad.tbUsuarios`, `tbRolesPantallas`,
`tbPantallas`, caché de 60 segundos) su rol, empleado, si es admin y sus pantallas
(`Seguridad/UsuarioActual.cs`, servicio `IUsuarioActual`).

### La API ya no cree lo que le manda el ADM

Las reglas viven en atributos sobre los controllers (`Seguridad/ReglasServidor.cs`) y las aplica un
solo filtro (`Seguridad/ReglasServidorFilter.cs`) antes de llamar al procedimiento:

- `[DatoDelServidor(DatoUsuario.Usuario, "usuId", "Usuario")]`: esos campos (parámetro o propiedad del
  cuerpo) se sobrescriben con el usuario firmado. También existen `Empleado` y `Rol`.
- `[PermisoDelServidor("Gestionar planes de apoyo", "verTodos", "PuedeGestionar")]`: la bandera queda en
  `true` solo si vino en `true` **y** el usuario tiene la pantalla (el admin las tiene todas).
- `[AlcanceEmpleado("Asignar sustituciones|Ver todas las sustituciones", "empId")]`: quien tiene la
  pantalla puede pedir cualquier empleado (o todos); los demás solo ven lo propio.
- `[RequierePantalla("Editar ficha de salud")]`: sin la pantalla → **403**.

Si una acción con estas reglas llega sin usuario firmado → **401**. Las acciones sin reglas
(catálogos, login, etc.) solo piden la llave.

Módulos con reglas: Planes de apoyo, Sustituciones, Temarios, Cierre de parciales, Fichas de salud,
Lista de espera, Disciplina, Constancias, Calendario escolar, Reporte de asistencia y los campos de
usuario de Asistencia, Notas, Horarios, Plan de clases, Tareas, Entregas, Vacaciones, Anuncios,
Mensajes, Configuración, Arqueos, Pagos, Correcciones de caja, Graduación, Matrícula por año,
Notificaciones, Perfil, Bitácora, Dashboard de caja y cierre de sesión.

Para un módulo nuevo que reciba usuario o permisos: agregar el atributo que corresponda en su
controller, con el mismo nombre de pantalla que usa el ADM en `TienePantalla`.

## Configuración

Genere una llave larga y aleatoria (por ejemplo `openssl rand -hex 32`) y use **la misma** en los dos
servicios. No la guarde en el repositorio.

### Docker (`docker-compose.yml`)

```yaml
  api:
    environment:
      GC_API_KEY: "${GC_API_KEY}"
    ports:
      - "127.0.0.1:5076:5076"   # o quitar "ports": el ADM llega por la red interna (http://api:5076)

  web:
    environment:
      GC_API_KEY: "${GC_API_KEY}"
```

y en el archivo `.env` junto al `docker-compose.yml` (fuera de git): `GC_API_KEY=<la llave>`.

### Desarrollo local

```bash
# API
GC_API_KEY=<la llave> dotnet run --project Gestion.Colegial.Api
# ADM
GC_API_KEY=<la llave> GC_API_BASEURL=http://localhost:5076/api/v1/ dotnet run --project GESTION_COLEGIAL.Web
```

### Sin llave

Si `GC_API_KEY` no está configurada, la API y el ADM se comportan como antes (sin encabezados ni
validaciones) y la API escribe una advertencia al arrancar. Úselo solo en desarrollo.
Si solo uno de los dos tiene la llave, el ADM recibe 401 en todas las llamadas: configúrela en ambos.

### Otros clientes

Cualquier otro programa que llame a la API debe mandar `X-Api-Key`. Swagger (solo en desarrollo)
abre sin llave; para probar llamadas use el botón *Authorize* y pegue la llave.
