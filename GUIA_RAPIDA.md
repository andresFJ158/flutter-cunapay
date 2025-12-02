# 🚀 Guía Rápida - Cómo Ejecutar y Probar la App

## Paso 1: Verificar Flutter

Abre una terminal (PowerShell o CMD) y verifica que Flutter esté instalado:

```bash
flutter --version
```

Si no está instalado:
1. Descarga Flutter desde: https://flutter.dev/docs/get-started/install/windows
2. Extrae el ZIP en `C:\src\flutter` (o donde prefieras)
3. Agrega `C:\src\flutter\bin` a tu PATH
4. Reinicia la terminal

Verifica la instalación:
```bash
flutter doctor
```

## Paso 2: Navegar al Proyecto

```bash
cd C:\dev\cunapay\flutter-app
```

## Paso 3: Instalar Dependencias

```bash
flutter pub get
```

Esto descargará todas las dependencias necesarias (Provider, Dio, GoRouter, etc.)

## Paso 4: Configurar la URL de la API

Edita el archivo `lib/config/api_config.dart` y verifica que la URL sea correcta:

```dart
static const String baseUrl = 'http://localhost:4000';
```

**IMPORTANTE:**
- Para **Web**: `http://localhost:4000` funciona directamente
- Para **Android/iOS físico**: Usa la IP de tu máquina (ej: `http://192.168.1.100:4000`)
  - Encuentra tu IP: `ipconfig` en PowerShell
  - Busca "IPv4 Address" en la sección de tu adaptador de red

## Paso 5: Asegurar que el Backend esté Corriendo

Antes de ejecutar la app, asegúrate de que tu backend ASP.NET Core esté corriendo:

```bash
cd C:\dev\cunapay\backend-aspnet\CunaPay.Api
dotnet run
```

Deberías ver: `Now listening on: http://0.0.0.0:4000`

## Paso 6: Ejecutar la App

### Opción A: Web (Más Fácil para Probar)

```bash
cd C:\dev\cunapay\flutter-app
flutter run -d chrome
```

Esto abrirá Chrome con tu app. Es la forma más rápida de probar.

### Opción B: Android

1. Abre Android Studio
2. Configura un emulador Android (AVD Manager)
3. O conecta un dispositivo físico con USB debugging activado

Luego:
```bash
flutter run -d android
```

### Opción C: Ver Dispositivos Disponibles

```bash
flutter devices
```

Esto mostrará todos los dispositivos disponibles (Chrome, Android, etc.)

## Paso 7: Probar la App

### 1. Pantalla de Login
- Deberías ver la pantalla de login
- Si no tienes cuenta, haz clic en "Crear Cuenta"

### 2. Registrar Usuario
- Ingresa un email y contraseña
- La app creará tu cuenta y wallet automáticamente

### 3. Dashboard
- Verás tu balance (inicialmente 0)
- Dirección de tu wallet
- Opciones para enviar USDT, staking, etc.

### 4. Probar Funcionalidades

**Enviar USDT:**
- Necesitas fondos en tu wallet primero
- Ingresa una dirección TRON válida (empieza con T, 34 caracteres)

**Staking:**
- Crea un stake con un monto
- Verás el stake en la lista
- Puedes reclamar intereses o cerrar

**Noticias:**
- Ve a la pestaña "Noticias"
- Puedes crear nuevas noticias
- Filtrar por categoría
- Ver detalles

## Solución de Problemas Comunes

### ❌ Error: "Flutter not found"
**Solución:**
- Instala Flutter desde https://flutter.dev
- Agrega Flutter al PATH
- Reinicia la terminal

### ❌ Error: "No devices found"
**Solución:**
- Para web: `flutter config --enable-web`
- Para Android: Abre Android Studio y crea un emulador
- Verifica con: `flutter devices`

### ❌ Error: "Connection refused" o "Failed to connect"
**Solución:**
1. Verifica que el backend esté corriendo: `http://localhost:4000`
2. Para móvil físico, cambia la URL a tu IP local
3. Verifica CORS en el backend (debe permitir todas las orígenes)

### ❌ Error: "Package not found"
**Solución:**
```bash
flutter clean
flutter pub get
```

### ❌ Error al compilar para web
**Solución:**
```bash
flutter config --enable-web
flutter clean
flutter pub get
flutter run -d chrome
```

## Comandos Útiles

```bash
# Ver dispositivos disponibles
flutter devices

# Limpiar build
flutter clean

# Reinstalar dependencias
flutter pub get

# Ver logs detallados
flutter run -d chrome --verbose

# Hot reload (cuando la app está corriendo)
# Presiona 'r' en la terminal
# O guarda un archivo (hot reload automático)
```

## Estructura de Prueba Recomendada

1. ✅ **Primero prueba en Web** (más fácil)
   ```bash
   flutter run -d chrome
   ```

2. ✅ **Registra un usuario** y verifica que funcione

3. ✅ **Prueba todas las pantallas:**
   - Dashboard
   - Enviar USDT
   - Staking
   - Transacciones
   - Noticias

4. ✅ **Luego prueba en móvil** si quieres

## Verificar que Todo Funciona

### Backend:
- ✅ Debe estar en `http://localhost:4000`
- ✅ MongoDB debe estar corriendo
- ✅ Debes poder acceder a `http://localhost:4000/swagger`

### App Flutter:
- ✅ `flutter pub get` ejecutado sin errores
- ✅ `flutter run -d chrome` abre la app
- ✅ Puedes ver la pantalla de login
- ✅ Puedes registrar un usuario

## Siguiente Paso

Una vez que la app esté corriendo:
1. Registra un usuario de prueba
2. Explora todas las pantallas
3. Prueba crear una noticia
4. Prueba el staking
5. Verifica que los balances se actualicen

¡Listo! Tu app debería estar funcionando. 🎉

