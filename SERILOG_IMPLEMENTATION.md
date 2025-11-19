# Implementación de Serilog en Gestion.Colegial.Api

## Resumen

Este documento describe la implementación de Serilog como sistema de logging estructurado para el proyecto Gestion.Colegial.Api.

---

## 1. Configuración Inicial

### Paquetes Instalados

```xml
<PackageReference Include="Serilog.AspNetCore" Version="9.0.0" />
```

### Configuración en Program.cs

```csharp
using Serilog;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
builder.Host.UseSerilog((context, configuration) =>
{
    configuration.ReadFrom.Configuration(context.Configuration);
});
```

### Configuración en appsettings.json

```json
{
  "Serilog": {
    "Using": [ "Serilog.Sinks.Console", "Serilog.Sinks.File" ],
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Warning",
        "Microsoft.AspNetCore": "Warning",
        "Microsoft.Hosting.Lifetime": "Information"
      }
    },
    "WriteTo": [
      {
        "Name": "Console"
      },
      {
        "Name": "File",
        "Args": {
          "path": "Logs/gestion-colegial-log-.txt",
          "rollingInterval": "Day",
          "outputTemplate": "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] [{SourceContext}] {Message:lj}{NewLine}{Exception}"
        }
      }
    ],
    "Enrich": [ "FromLogContext", "WithMachineName", "WithThreadId" ]
  },
  "AllowedHosts": "*"
}
```

### Configuración en appsettings.Development.json

```json
{
  "Serilog": {
    "MinimumLevel": {
      "Default": "Debug",
      "Override": {
        "Microsoft": "Warning",
        "Microsoft.AspNetCore": "Warning",
        "Microsoft.Hosting.Lifetime": "Information",
        "Gestion.Colegial.Business.Services": "Debug",
        "Gestion.Colegial.Api.Controllers": "Debug"
      }
    }
  }
}
```

---

## 2. Patrón de Implementación por Capa

### 2.1 Controllers (Capa de API)

**Inyección de dependencias:**

```csharp
using Microsoft.AspNetCore.Mvc;

[Route("api/v1/[controller]")]
[ApiController]
public class MiController : ControllerBase
{
    private readonly IMiService _miService;
    private readonly ILogger<MiController> _logger;

    public MiController(IMiService miService, ILogger<MiController> logger)
    {
        _miService = miService;
        _logger = logger;
    }
}
```

**Uso en métodos:**

```csharp
[HttpPost]
public async Task<IActionResult> Create([FromBody] MiDTO dto)
{
    try
    {
        _logger.LogInformation("Iniciando creación de {Entidad} con nombre: {Nombre}",
            "MiEntidad", dto.Nombre);

        if (!ModelState.IsValid)
        {
            _logger.LogWarning("ModelState inválido al crear {Entidad}", "MiEntidad");
            return BadRequest(ModelState);
        }

        var result = await _miService.CreateAsync(dto);

        if (result.Access)
        {
            _logger.LogWarning("Error al crear {Entidad}. Mensaje: {Message}",
                "MiEntidad", result.Message);
            return BadRequest(result);
        }

        _logger.LogInformation("Creación exitosa de {Entidad}", "MiEntidad");
        return Ok(result);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error no controlado al crear {Entidad}", "MiEntidad");
        return StatusCode(500, new { message = "Error interno del servidor" });
    }
}
```

**Niveles de logging recomendados:**
- `LogDebug`: Información detallada para debugging (IPs, parámetros)
- `LogInformation`: Operaciones normales exitosas
- `LogWarning`: Validaciones fallidas, errores de negocio
- `LogError`: Excepciones no controladas

---

### 2.2 Services (Capa de Negocio)

**Método actual (usando clase estática Logs):**

```csharp
public async Task<Answer> CreateAsync(MiDTO dto)
{
    Answer answer = new Answer();
    try
    {
        // Lógica de negocio
        var result = await _repository.CreateAsync(entity);

        if (result.Access)
        {
            answer.Access = true;
            answer.Message = MessageShow.Error;
            return answer;
        }

        answer.Access = false;
        answer.Message = MessageShow.SuccessSave;
        return answer;
    }
    catch (Exception e)
    {
        answer.Access = true;
        answer.Message = MessageShow.Error;
        answer.Incidents(e);
        Logs.Error(answer);  // ← Esto registra el error con Serilog
        return answer;
    }
}
```

**La clase `Logs.Error()` ya fue actualizada para usar Serilog global**, por lo que este patrón ya funciona correctamente.

---

### 2.3 Repositories (Capa de Acceso a Datos)

**Método actualizado en RepositoryBase:**

```csharp
using Serilog;

public async Task<Answer> Read<T>(string queryString)
{
    Answer answer = new Answer();
    try
    {
        // Lógica de acceso a datos
        using (SqlConnection connection = new SqlConnection(Connection.GetConnectionString()))
        {
            // ... código de base de datos
        }
    }
    catch (SqlException ex)
    {
        Log.Error(ex, "Error SQL en método Read<T>. Query: {QueryString}", queryString);
        answer.Access = true;
        answer.Incidents(ex);
        answer.Data = "";
        return answer;
    }
    catch (Exception e)
    {
        Log.Error(e, "Error general en método Read<T>. Query: {QueryString}", queryString);
        answer.Access = true;
        answer.Incidents(e);
        answer.Data = "";
        return answer;
    }
}
```

**Importante:** Se usa `Log.Error()` (clase estática de Serilog) porque RepositoryBase no tiene constructor para inyección de dependencias.

---

## 3. Clase Logs Actualizada

La clase `Logs` en `Gestion.Colegial.Business.Extensions.Logs` fue actualizada:

```csharp
using Serilog;

public static class Logs
{
    /// <summary>
    /// Registra un error utilizando Serilog configurado globalmente.
    /// </summary>
    public static void Error(Answer answer)
    {
        try
        {
            LogWithSerilog(answer);
        }
        catch (Exception ex)
        {
            try
            {
                LogToBackupFile(ex, answer);
            }
            catch
            {
                Console.WriteLine($"Error crítico en logging: {ex.Message}");
            }
        }
    }

    private static void LogWithSerilog(Answer answer)
    {
        string innerException = answer.InnerException?.ToString() ?? "No contiene";
        string stackTrace = answer.StackTrace ?? "No disponible";

        Log.Error(
            "Error en la aplicación. " +
            "Mensaje: {Message}, " +
            "Error General: {ErrorGeneral}, " +
            "Detalles: {ErrorDetails}, " +
            "StackTrace: {StackTrace}, " +
            "InnerException: {InnerException}",
            answer.Message,
            answer.ErrorGeneral,
            answer.ErrorDetails,
            stackTrace,
            innerException
        );
    }
}
```

---

## 4. Flujo de Logging por Tipo de Error

### 4.1 Error en Controller
```
Controller → LogError → Archivo de log (inmediato)
```

### 4.2 Error en Service
```
Service → answer.Incidents(e) → Logs.Error(answer) → Log.Error (Serilog) → Archivo de log
```

### 4.3 Error en Repository
```
Repository → answer.Incidents(e) → Log.Error (Serilog) → Archivo de log
```

---

## 5. Mejores Prácticas

### 5.1 Logging Estructurado

✅ **CORRECTO:**
```csharp
_logger.LogInformation("Usuario {Username} inició sesión desde IP {IP}", username, ip);
```

❌ **INCORRECTO:**
```csharp
_logger.LogInformation($"Usuario {username} inició sesión desde IP {ip}");
```

**Razón:** El logging estructurado permite búsquedas y filtros por propiedades.

### 5.2 Información Sensible

❌ **NO REGISTRAR:**
- Contraseñas
- Tokens completos
- Números de tarjetas de crédito
- Datos personales sensibles (excepto IDs)

✅ **SÍ REGISTRAR:**
- IDs de usuario
- Nombres de operaciones
- Timestamps
- Resultados de operaciones (éxito/fallo)
- Stack traces de excepciones

### 5.3 Niveles de Log

| Nivel | Cuándo usar |
|-------|-------------|
| **Debug** | Información detallada para debugging (solo en Development) |
| **Information** | Flujo normal de la aplicación |
| **Warning** | Situaciones anormales que no son errores (validaciones fallidas) |
| **Error** | Errores y excepciones |
| **Critical** | Errores críticos que requieren atención inmediata |

---

## 6. Archivos de Log

### Ubicación
```
Logs/gestion-colegial-log-YYYYMMDD.txt
```

### Rotación
- **Intervalo:** Diario
- **Formato de nombre:** `gestion-colegial-log-20250117.txt`

### Formato de salida
```
2025-01-17 15:30:45.123 -06:00 [ERR] [Gestion.Colegial.Api.Controllers.AccountController] Error en el proceso de login para usuario: admin
System.Exception: Credenciales inválidas
   at Gestion.Colegial.Business.Services.UsuarioService.AuthenticateAsync(...)
```

---

## 7. Ejemplo Completo de Implementación

### Controller
```csharp
[HttpPost]
public async Task<IActionResult> Create([FromBody] AlumnoDTO dto)
{
    try
    {
        _logger.LogInformation("Iniciando creación de alumno: {Nombre}", dto.Nombre);

        var result = await _alumnoService.CreateAsync(dto);

        if (result.Access)
        {
            _logger.LogWarning("Error al crear alumno. Mensaje: {Message}", result.Message);
            return BadRequest(result);
        }

        _logger.LogInformation("Alumno creado exitosamente. ID: {Id}", result.Data);
        return Ok(result);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error no controlado al crear alumno");
        return StatusCode(500, new { message = "Error interno del servidor" });
    }
}
```

### Service
```csharp
public async Task<Answer> CreateAsync(AlumnoDTO dto)
{
    Answer answer = new Answer();
    try
    {
        var entity = _mapper.Map<Alumno>(dto);
        var result = await _alumnoRepository.CreateAsync(entity);

        if (result.Access)
        {
            answer.Access = true;
            answer.Message = "Error al crear alumno";
            return answer;
        }

        answer.Access = false;
        answer.Message = "Alumno creado exitosamente";
        answer.Data = result.Data;
        return answer;
    }
    catch (Exception e)
    {
        answer.Access = true;
        answer.Message = "Error al crear alumno";
        answer.Incidents(e);
        Logs.Error(answer);
        return answer;
    }
}
```

### Repository
```csharp
public async Task<Answer> CreateAsync(Alumno alumno)
{
    Answer answer = new Answer();
    try
    {
        // Lógica de base de datos
        return answer;
    }
    catch (SqlException ex)
    {
        Log.Error(ex, "Error SQL al crear alumno. Procedimiento: {SP}", "SP_InsertarAlumno");
        answer.Access = true;
        answer.Incidents(ex);
        return answer;
    }
}
```

---

## 8. Próximos Pasos Recomendados

1. **Aplicar el patrón de logging a todos los controllers**
   - Inyectar `ILogger<T>`
   - Agregar logging en métodos principales

2. **Revisar todos los servicios**
   - Verificar que usen `Logs.Error(answer)` en catch blocks

3. **Actualizar RepositoryBase**
   - Agregar logging en los catch blocks restantes
   - Seguir el patrón del método `Read<T>`

4. **Monitoreo**
   - Revisar archivos de log periódicamente
   - Configurar alertas para errores críticos (futuro)

5. **Limpieza de logs antiguos**
   - Implementar política de retención
   - Considerar archivado de logs antiguos

---

## 9. Troubleshooting

### Los logs no se escriben en el archivo

1. Verificar que la carpeta `Logs/` existe o que la aplicación tiene permisos para crearla
2. Revisar la configuración en `appsettings.json`
3. Verificar que Serilog está configurado en `Program.cs`

### No veo logs en Development

Verificar `appsettings.Development.json` y asegurar que el nivel mínimo sea `Debug`.

### Archivos de log muy grandes

Ajustar el nivel de logging o implementar políticas de retención más agresivas.

---

## Referencias

- [Serilog Documentation](https://serilog.net/)
- [Structured Logging Best Practices](https://github.com/serilog/serilog/wiki/Structured-Data)
- [ASP.NET Core Logging](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/logging/)
