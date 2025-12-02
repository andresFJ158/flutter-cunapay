# 🔍 Prompt para Verificación de Compatibilidad Frontend-Backend

Copia y pega este prompt completo en un nuevo chat de Cursor para verificar la compatibilidad:

---

## CONTEXTO DEL PROYECTO

Estoy trabajando en una aplicación Flutter (frontend) que se conecta a un backend ASP.NET Core. Necesito que verifiques si la configuración del frontend es compatible con el backend y si todo funcionará correctamente.

## CONFIGURACIÓN DEL FRONTEND (FLUTTER)

### 1. Configuración de API (`lib/config/api_config.dart`)

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // URL base de la API - se obtiene de las variables de entorno
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? 'http://localhost:4000';
  }
  
  // Endpoints de autenticación
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  
  // Endpoints de usuario y wallet
  static const String apiMe = '/api/me';
  static const String apiWallet = '/api/me/wallet';
  static const String apiBalance = '/api/me/balance';
  static const String apiTransactions = '/api/me/transactions';
  static const String apiSend = '/api/me/send';
  
  // Endpoints de staking
  static const String apiStakes = '/api/me/stakes';
  static String stakeClaim(String stakeId) => '$apiStakes/$stakeId/claim';
  static String stakeClose(String stakeId) => '$apiStakes/$stakeId/close';
  
  // Endpoints de noticias
  static const String apiNews = '/api/news';
  static const String apiNewsCategories = '/api/news/categories';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

### 2. Servicio de API (`lib/services/api_service.dart`)

El servicio usa **Dio** con las siguientes características:

- **Base URL**: Se obtiene de `ApiConfig.baseUrl` (variable de entorno `BASE_URL`)
- **Headers por defecto**:
  - `Content-Type: application/json`
  - `Accept: application/json`
- **Interceptores**:
  - **onRequest**: Agrega automáticamente `Authorization: Bearer {token}` desde SharedPreferences
  - **onError**: Si recibe 401, limpia el token de autenticación
- **Validación de status**: Acepta códigos < 500 como válidos

### 3. Endpoints y Métodos HTTP Usados

#### Autenticación:
- `POST /auth/register` - Registro de usuario
  - Body: `{ "email": string, "password": string }`
  - Respuesta esperada: `{ "token": string, "user": object }`

- `POST /auth/login` - Login de usuario
  - Body: `{ "email": string, "password": string }`
  - Respuesta esperada: `{ "token": string, "user": object }`

#### Usuario y Wallet:
- `GET /api/me` - Obtener información del usuario autenticado
- `GET /api/me/wallet` - Obtener wallet del usuario
- `GET /api/me/balance` - Obtener balances (USDT, TRX, disponible, en staking)
- `GET /api/me/transactions` - Listar transacciones
  - Query params: `source`, `limit`, `status`, `direction`, `fingerprint`
- `POST /api/me/send` - Enviar USDT
  - Body: `{ "to": string, "amount": string }`
  - Requiere rol: `admin`

#### Staking:
- `GET /api/me/stakes` - Listar todos los stakes del usuario
- `POST /api/me/stakes` - Crear nuevo stake
  - Body: `{ "amount_usdt": number, "daily_rate_bp": number }`
  - Requiere rol: `admin`
- `POST /api/me/stakes/{id}/claim` - Reclamar intereses de un stake
  - Requiere rol: `admin`
- `POST /api/me/stakes/{id}/close` - Cerrar un stake
  - Requiere rol: `admin`

#### Noticias:
- `GET /api/news` - Listar noticias
  - Query params: `limit`, `category`
- `GET /api/news/{id}` - Obtener noticia por ID
- `POST /api/news` - Crear noticia
  - Body: `{ "title": string, "category": string, "link": string, "image": string?, "economicImpact": string }`
- `PUT /api/news/{id}` - Actualizar noticia
- `DELETE /api/news/{id}` - Eliminar noticia
- `GET /api/news/categories` - Obtener categorías de noticias

### 4. Manejo de Autenticación

- El token JWT se guarda en `SharedPreferences` con la clave `auth_token`
- Se envía automáticamente en el header `Authorization: Bearer {token}` en todas las peticiones
- Si el backend responde con 401, se limpia el token automáticamente

### 5. Variables de Entorno

- Archivo `.env.development` contiene: `BASE_URL=http://10.231.54.86:4000`
- Se carga automáticamente al iniciar la app en `main.dart`

## CONFIGURACIÓN DEL BACKEND (ASP.NET CORE)

### Ubicación del Backend:
`c:\Users\DIDIER24\Downloads\CunaPay.Api (2)\CunaPay.Api\`

### Estructura del Backend:

#### Controladores:
- `AuthController.cs` - Maneja `/auth/register` y `/auth/login`
- `ApiController.cs` - Maneja todos los endpoints bajo `/api/*`
  - Ruta base: `[Route("api")]`
  - Requiere: `[Authorize]` en toda la clase
  - Algunos endpoints requieren rol: `[Authorize(Roles = "admin")]`

#### Endpoints del Backend:

**AuthController:**
- `POST /auth/register` - Registro
- `POST /auth/login` - Login

**ApiController (todos requieren autenticación):**
- `GET /api/me` - Información del usuario
- `GET /api/me/wallet` - Wallet del usuario
- `GET /api/me/balance` - Balances
- `GET /api/me/transactions` - Transacciones (query params: source, limit, status, direction, fingerprint)
- `POST /api/me/send` - Enviar USDT (requiere rol admin)
- `GET /api/me/stakes` - Listar stakes
- `POST /api/me/stakes` - Crear stake (requiere rol admin)
- `POST /api/me/stakes/{id}/claim` - Reclamar stake (requiere rol admin)
- `POST /api/me/stakes/{id}/close` - Cerrar stake (requiere rol admin)

**NewsController:**
- `GET /api/news` - Listar noticias
- `GET /api/news/{id}` - Obtener noticia
- `POST /api/news` - Crear noticia
- `PUT /api/news/{id}` - Actualizar noticia
- `DELETE /api/news/{id}` - Eliminar noticia
- `GET /api/news/categories` - Categorías

### Autenticación del Backend:

- Usa JWT (JSON Web Tokens)
- El token debe incluirse en el header: `Authorization: Bearer {token}`
- El token contiene claims: `uid` (user ID) y `email`
- Algunos endpoints requieren rol `admin` en el token

## TAREAS DE VERIFICACIÓN

Por favor, verifica lo siguiente:

1. **Compatibilidad de Endpoints:**
   - ¿Todos los endpoints del frontend existen en el backend?
   - ¿Los métodos HTTP coinciden (GET, POST, PUT, DELETE)?
   - ¿Las rutas son exactamente iguales?

2. **Estructura de Datos:**
   - ¿Los nombres de los campos en las peticiones coinciden?
     - Frontend envía: `amount_usdt`, `daily_rate_bp`
     - Backend espera: ¿`AmountUsdt`, `DailyRateBp`? (verificar naming convention)
   - ¿Los formatos de respuesta son compatibles?
     - Frontend espera: `{ "token": string, "user": object }`
     - Backend devuelve: ¿el mismo formato?

3. **Autenticación:**
   - ¿El backend acepta tokens JWT en el formato `Bearer {token}`?
   - ¿El backend valida correctamente los tokens?
   - ¿Los claims del token (`uid`, `email`) son los correctos?

4. **Query Parameters:**
   - ¿Los nombres de los query params coinciden?
   - ¿El backend acepta los mismos valores?

5. **Headers:**
   - ¿El backend acepta `Content-Type: application/json`?
   - ¿El backend acepta `Accept: application/json`?

6. **CORS (para Web):**
   - ¿El backend tiene CORS configurado para permitir peticiones desde el frontend?
   - ¿Permite el origen correcto?

7. **Errores y Códigos de Estado:**
   - ¿El backend devuelve los códigos de estado que el frontend espera?
   - ¿Los mensajes de error tienen el formato que el frontend puede procesar?

8. **Validación de Status:**
   - El frontend acepta códigos < 500 como válidos
   - ¿Esto es compatible con cómo el backend maneja errores?

9. **Roles y Permisos:**
   - ¿Los endpoints que requieren `admin` en el frontend coinciden con los del backend?
   - ¿El frontend maneja correctamente los errores 403 (Forbidden)?

10. **Timeouts:**
    - Frontend tiene timeout de 30 segundos
    - ¿Es suficiente para las operaciones del backend?

## INFORMACIÓN ADICIONAL

- **Base URL configurada**: `http://10.231.54.86:4000` (IP local para dispositivos físicos)
- **Backend debe estar escuchando en**: `0.0.0.0:4000` o `http://*:4000` para aceptar conexiones externas
- **Puerto**: 4000
- **Protocolo**: HTTP (no HTTPS en desarrollo)

## DETALLES ESPECÍFICOS DEL FRONTEND

### Formato de Datos Enviados:

**Registro (`POST /auth/register`):**
```dart
// Frontend envía:
{
  "email": "usuario@ejemplo.com",  // Se normaliza a lowercase y trim
  "password": "contraseña123"
}

// ⚠️ IMPORTANTE: El backend espera RegisterRequest con:
// - Email (string)
// - Password (string)
// - Nombre (string) - ⚠️ El frontend NO envía este campo
// - Apellido (string) - ⚠️ El frontend NO envía este campo
// 
// El backend devuelve: { token, user, wallet }
// El frontend espera: { token, user }
```

**Login (`POST /auth/login`):**
```dart
{
  "email": "usuario@ejemplo.com",  // Se normaliza a lowercase y trim
  "password": "contraseña123"
}
```

**Crear Stake (`POST /api/me/stakes`):**
```dart
{
  "amount_usdt": 100.0,      // double
  "daily_rate_bp": 25         // int (basis points, default 25)
}
```

**Enviar USDT (`POST /api/me/send`):**
```dart
{
  "to": "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t",  // Dirección TRON
  "amount": "10.5"                              // String con hasta 6 decimales
}
```

**Crear Noticia (`POST /api/news`):**
```dart
{
  "title": "Título de la noticia",
  "category": "economia",
  "link": "https://ejemplo.com/noticia",
  "image": "https://ejemplo.com/imagen.jpg",  // Opcional
  "economicImpact": "Alto impacto económico"
}

// ⚠️ IMPORTANTE: Verificar si el backend espera "economicImpact" o "EconomicImpact" (PascalCase)
```

**Listar Noticias (`GET /api/news`):**
```dart
// Frontend espera: Array directo de noticias
// Backend devuelve: { items: [...], total: number }
// ⚠️ POSIBLE INCOMPATIBILIDAD: Formato de respuesta diferente
```

### Manejo de Respuestas en el Frontend:

**Registro/Login exitoso:**
- Espera: `{ "token": string, "user": object }`
- Si no hay `user`, intenta construir desde `email` y `id`
- Valida que `token` no sea null o vacío
- Guarda token en SharedPreferences como `auth_token`
- Guarda user como JSON en SharedPreferences como `user_data`

**Errores:**
- Busca mensajes en: `error`, `message`, `msg`
- Maneja códigos: 400, 401, 404, 409, 500
- Mensajes específicos para: "email ya registrado", "credenciales inválidas", errores de conexión

## RESULTADO ESPERADO

Por favor, verifica exhaustivamente y proporciona:

1. ✅ **Lista de compatibilidades confirmadas**
   - Endpoints que coinciden perfectamente
   - Formatos de datos compatibles
   - Autenticación funcionando correctamente

2. ⚠️ **Lista de posibles problemas o incompatibilidades**
   - Endpoints que no coinciden
   - Diferencias en nombres de campos (snake_case vs PascalCase)
   - Formatos de respuesta diferentes
   - Problemas de autenticación
   - Problemas de CORS

3. 🔧 **Recomendaciones para corregir cualquier problema encontrado**
   - Cambios necesarios en el frontend
   - Cambios necesarios en el backend
   - Configuraciones adicionales requeridas

4. 📝 **Sugerencias de mejoras o ajustes necesarios**
   - Mejores prácticas
   - Optimizaciones
   - Validaciones adicionales

5. 🧪 **Checklist de pruebas recomendadas**
   - Qué probar primero
   - Escenarios de prueba críticos
   - Casos edge a verificar

---

## INSTRUCCIONES FINALES

1. **Lee completamente** el código del backend en:
   - `c:\Users\DIDIER24\Downloads\CunaPay.Api (2)\CunaPay.Api\Controllers\AuthController.cs`
   - `c:\Users\DIDIER24\Downloads\CunaPay.Api (2)\CunaPay.Api\Controllers\ApiController.cs`
   - `c:\Users\DIDIER24\Downloads\CunaPay.Api (2)\CunaPay.Api\Controllers\NewsController.cs`

2. **Compara** cada endpoint del frontend con su equivalente en el backend

3. **Verifica**:
   - Rutas exactas
   - Métodos HTTP
   - Nombres de campos (case sensitivity)
   - Tipos de datos
   - Validaciones
   - Respuestas esperadas

4. **Identifica** cualquier discrepancia o problema potencial

5. **Proporciona** un reporte detallado y accionable

---

**IMPORTANTE**: Sé específico y detallado. Si encuentras problemas, proporciona ejemplos de código o configuraciones exactas para solucionarlos.

