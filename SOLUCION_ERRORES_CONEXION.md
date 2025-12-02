# Solución de Errores de Conexión

## Error: "Cannot send Null" y "DioExceptionType.connectionError"

Este error generalmente ocurre cuando:
1. El servidor no está corriendo
2. Hay problemas de CORS (en web)
3. La URL del servidor es incorrecta

## Pasos para Solucionar

### 1. Verificar que el servidor esté corriendo

Abre tu navegador y visita:
```
http://localhost:4000/auth/register
```

Si ves un error o la página no carga, el servidor no está corriendo.

**Solución**: Inicia tu servidor backend en el puerto 4000.

### 2. Verificar la URL en el archivo `.env.development`

Abre el archivo `.env.development` y verifica que tenga:
```
BASE_URL=http://localhost:4000
```

**Importante**: 
- Si estás ejecutando en **web**, usa `http://localhost:4000` (no `https://`)
- Si estás ejecutando en **Android/iOS**, puedes usar `http://10.0.2.2:4000` (Android emulador) o la IP de tu computadora

### 3. Problemas de CORS (Solo para Web)

Si estás ejecutando la app en **web** y ves errores de CORS, necesitas configurar tu servidor backend para permitir solicitudes desde el origen de tu app Flutter.

**Ejemplo para Express.js**:
```javascript
const cors = require('cors');

app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:8080'], // Ajusta según tu puerto
  credentials: true
}));
```

### 4. Verificar que los datos se envíen correctamente

El código ahora limpia automáticamente los valores `null` antes de enviar las peticiones. Si aún ves el error:

1. **Revisa los logs en la consola** - Deberías ver:
   ```
   [ApiService] Register request to: http://localhost:4000/auth/register
   [ApiService] Register data (cleaned): {email: ..., password: ..., firstName: ..., lastName: ...}
   ```

2. **Verifica que todos los campos estén llenos** en el formulario de registro:
   - Nombre
   - Apellido
   - Email
   - Contraseña

### 5. Probar la conexión manualmente

Puedes probar el endpoint directamente con curl o Postman:

```bash
curl -X POST http://localhost:4000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "firstName": "Juan",
    "lastName": "Pérez"
  }'
```

Si esto funciona, el problema está en la app Flutter. Si no funciona, el problema está en el servidor.

### 6. Para desarrollo en Web

Si estás ejecutando en web y el servidor está en `localhost:4000`, asegúrate de:

1. **Ejecutar Flutter con el flag correcto**:
   ```bash
   flutter run -d chrome --web-port=8080
   ```

2. **Verificar que no haya conflictos de puerto**

3. **Usar `http://` no `https://`** en desarrollo local

## Cambios Realizados en el Código

Se han realizado las siguientes mejoras para prevenir el error "Cannot send Null":

1. ✅ **Limpieza automática de valores null** en el interceptor de Dio
2. ✅ **Validación de campos** antes de crear los datos
3. ✅ **Serialización explícita** de los datos antes de enviarlos
4. ✅ **Mejor manejo de errores** con mensajes descriptivos
5. ✅ **Logs detallados** para debugging

## Próximos Pasos

Si el error persiste después de verificar todo lo anterior:

1. Comparte los logs completos de la consola
2. Verifica la versión de Dio en `pubspec.yaml`
3. Prueba ejecutar la app en un dispositivo/emulador en lugar de web
4. Verifica que tu servidor esté respondiendo correctamente a las peticiones

