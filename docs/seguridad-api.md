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

Además exigen pantalla (admin o el rol que la tenga): crear, editar y quitar usuarios
(`Listado de usuarios`) y roles con sus pantallas (`Listado de roles`), Dev Tools (`PasoAsync`),
Rollover de año lectivo y Graduación (graduar y backfill, `Graduación de Alumnos`).

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

### Encabezados después de validar

Tras validarlos, la API quita `X-Api-Key` y `X-Gc-Usuario` de la petición: así no aparecen en la
página de error de desarrollo (que lista los encabezados) ni en registros.

### Sin llave

Si `GC_API_KEY` no está configurada, la API y el ADM se comportan como antes (sin encabezados ni
validaciones) y la API escribe una advertencia al arrancar. Úselo solo en desarrollo.
Si solo uno de los dos tiene la llave, el ADM recibe 401 en todas las llamadas: configúrela en ambos.

### Otros clientes

Cualquier otro programa que llame a la API debe mandar `X-Api-Key`. Swagger (solo en desarrollo)
abre sin llave; para probar llamadas use el botón *Authorize* y pegue la llave. Las acciones con reglas
de usuario responden 401 desde Swagger porque además piden `X-Gc-Usuario` firmado; para probarlas use
el ADM o una API local sin `GC_API_KEY`.

## Contraseñas e inicio de sesión

### Cómo se guardan

- Formato: `v2$iteraciones$sal$huella` = PBKDF2-HMAC-SHA256, 600 000 iteraciones, sal aleatoria de
  16 bytes por usuario, huella de 32 bytes (Base64). Se calcula en
  `Gestion.Colegial.Business/Seguridad/Contrasenas.cs`.
- Las contraseñas viejas (SHA-256 sin sal, 64 caracteres hexadecimales) se convierten solas al
  formato nuevo la próxima vez que el usuario entra con la contraseña correcta.
- Reglas para una contraseña nueva: de 8 a 128 caracteres, sin espacios al inicio o al final y
  distinta del nombre de usuario.

### Un solo camino para guardar una contraseña

Todo lo que ponga o cambie una contraseña (alta de usuario, cambio en *Mi Perfil*, restablecimiento
desde *Usuarios*, activación de cuentas del portal de padres) debe:

1. Calcular la huella con `Contrasenas.Crear(clave)` (nunca SHA-256 ni otra fórmula propia).
2. Para un usuario que ya existe, guardarla con `IUsuarioService.GuardarContrasenaAsync(...)`,
   que valida las reglas y llama a `seguridad.PR_tbUsuarios_GuardarContrasena`. Ese procedimiento
   solo acepta el formato `v2$` y puede dejar el registro en la bitácora.

Un procedimiento que cree la cuenta y su contraseña en el mismo paso (por ejemplo, la activación
del portal) recibe la huella ya calculada con `Contrasenas.Crear`.

### Límite de intentos

| Clave | Por defecto | Qué hace |
|---|---|---|
| `Login:MaxFallosUsuario` | 5 | Fallos con el mismo usuario (exista o no) antes de bloquearlo. |
| `Login:MaxFallosIp` | 20 | Fallos desde la misma IP antes de bloquearla (0 = sin límite por IP). |
| `Login:VentanaMinutos` | 15 | Tiempo en que se cuentan los fallos. |
| `Login:BloqueoMinutos` | 15 | Duración del bloqueo. |

- Se configuran en `appsettings.json` o con variables de entorno (`Login__BloqueoMinutos=1`).
- Los conteos viven en `seguridad.tbIntentosLogin`. Cada intento se cuenta **antes** de revisar
  la contraseña (`PR_tbIntentosLogin_Reservar`, en un solo paso): así varios intentos al mismo
  tiempo no pasan del máximo. Si la contraseña es correcta se descuenta: el conteo del usuario se
  borra y a la IP solo se le quita ese intento (sus fallos siguen contando).
- Los fallos de usuarios que existen y los bloqueos quedan en `seguridad.tbBitacora`.
- Mensajes siempre genéricos: "Usuario o contraseña incorrectos." o "Demasiados intentos
  fallidos. Espere N minutos…", con el mismo tiempo de respuesta exista o no el usuario.
- `POST Account/Login` responde **200** con `Success = false` cuando no deja entrar, para que el
  ADM pueda mostrar el mensaje.
- La IP es la del navegador: el ADM la manda en `IpCliente` (la API solo ve la del ADM). Si el ADM se
  publica detrás de un proxy (nginx, Cloudflare, etc.), hay que configurar ahí los encabezados
  reenviados (`ForwardedHeaders`) con la IP del proxy; si no, todos los usuarios comparten la IP
  del proxy y el límite por IP los bloquearía juntos.

### Transición con el código anterior

Mientras el ADM y la API anteriores sigan usando la misma base, al convertir una contraseña se
guarda también su huella vieja en `Usu_ContrasenaLegado` y `seguridad.UDP_tbUsuarios_Login` (el
procedimiento del código anterior) la acepta. Cuando todo corra con el código nuevo, ejecutar
una vez:

```sql
EXEC seguridad.PR_tbUsuarios_CerrarTransicionContrasenas;
```

Borra esas huellas viejas y deja de guardarlas. Correr de nuevo `Scripts/084_LoginSeguro.sql`
no reabre la transición.
