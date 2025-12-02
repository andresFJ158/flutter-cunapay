# 🔍 Verificar que el Servidor esté Corriendo

## El error "connection error" indica que no se puede conectar al servidor

### Pasos para verificar:

1. **Verifica que el backend esté corriendo:**
   ```bash
   # En la terminal del backend, deberías ver algo como:
   Now listening on: http://0.0.0.0:4000
   ```

2. **Prueba la conexión manualmente:**
   - Abre tu navegador
   - Ve a: `http://localhost:4000/auth/register`
   - Deberías ver una respuesta (aunque sea un error de método, significa que el servidor está activo)

3. **Verifica CORS en el backend:**
   
   El backend ASP.NET Core debe tener CORS configurado. En `Program.cs` o `Startup.cs`:
   
   ```csharp
   builder.Services.AddCors(options =>
   {
       options.AddPolicy("AllowAll", policy =>
       {
           policy.AllowAnyOrigin()
                 .AllowAnyMethod()
                 .AllowAnyHeader();
       });
   });
   
   // Y luego:
   app.UseCors("AllowAll");
   ```

4. **Si el servidor está en otro puerto:**
   - Edita `lib/config/api_config.dart`
   - Cambia la URL a: `http://localhost:TU_PUERTO`

5. **Para dispositivos móviles físicos:**
   - No uses `localhost`
   - Usa la IP de tu máquina: `http://192.168.1.XXX:4000`
   - Encuentra tu IP con: `ipconfig` (Windows) o `ifconfig` (Mac/Linux)

### Solución rápida:

1. Asegúrate de que el backend esté corriendo
2. Verifica que CORS esté habilitado
3. Prueba la URL en el navegador primero
4. Si funciona en el navegador pero no en la app, es un problema de CORS

