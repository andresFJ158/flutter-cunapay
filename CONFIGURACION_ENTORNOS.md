# 🔧 Configuración de Entornos con Variables de Entorno

Este proyecto usa `flutter_dotenv` para manejar diferentes configuraciones según el entorno (desarrollo, producción, etc.).

## 📋 Requisitos Previos

1. Instalar dependencias:
```bash
flutter pub get
```

## 🚀 Configuración Inicial

### Paso 1: Crear archivos de entorno

Copia los archivos de ejemplo y renómbralos:

```bash
# Para desarrollo (recomendado)
cp .env.development.example .env.development

# Para producción
cp .env.production.example .env.production

# O crea un .env genérico
cp .env.example .env
```

### Paso 2: Configurar la URL de la API

Edita el archivo `.env.development` (o el que vayas a usar):

```env
# Para Web o emuladores
BASE_URL=http://localhost:4000

# Para dispositivos físicos, usa la IP de tu máquina
# Encuentra tu IP con:
# - Windows: ipconfig
# - Mac/Linux: ifconfig
BASE_URL=http://192.168.1.100:4000
```

## 📱 Entornos Disponibles

### Desarrollo (`.env.development`)

**Uso:** Desarrollo local, testing, debugging

**Configuración:**
- Web: `http://localhost:4000`
- Dispositivos físicos: `http://TU_IP_LOCAL:4000`

**Cómo usar:**
El archivo `.env.development` se carga automáticamente al iniciar la app.

### Producción (`.env.production`)

**Uso:** Despliegue en producción

**Configuración:**
- URL del servidor de producción: `https://api.cunapay.com`

**Cómo usar:**
Para usar este entorno, modifica `main.dart` temporalmente:

```dart
await dotenv.load(fileName: '.env.production');
```

O crea un script de build que cargue el archivo correcto.

## 🔍 Cómo Encontrar tu IP Local

### Windows (PowerShell o CMD)
```powershell
ipconfig
```
Busca "IPv4 Address" en tu adaptador activo (Wi-Fi o Ethernet).

### Mac / Linux
```bash
ifconfig
# O más moderno:
ip addr show
```
Busca "inet" en tu interfaz activa.

### Ejemplo de salida:
```
Wi-Fi adapter:
   IPv4 Address. . . . . . . . . . . : 192.168.1.100
```

## 🛠️ Cambiar entre Entornos

### Opción 1: Modificar main.dart (temporal)

En `lib/main.dart`, cambia el nombre del archivo:

```dart
// Para desarrollo
await dotenv.load(fileName: '.env.development');

// Para producción
await dotenv.load(fileName: '.env.production');
```

### Opción 2: Usar argumentos de compilación (avanzado)

Puedes usar `--dart-define` para pasar variables:

```bash
flutter run --dart-define=ENV_FILE=.env.production
```

Y modificar `main.dart` para leer este argumento.

## 📝 Variables Disponibles

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `BASE_URL` | URL base de la API | `http://localhost:4000` |

## ⚠️ Seguridad

**IMPORTANTE:** Los archivos `.env` están en `.gitignore` y **NO** deben subirse al repositorio.

- ✅ **SÍ** subir: `.env.example`, `.env.development.example`
- ❌ **NO** subir: `.env`, `.env.development`, `.env.production`

## 🐛 Solución de Problemas

### Error: "No se puede cargar .env"

**Solución:** Asegúrate de que:
1. El archivo `.env` existe en la raíz del proyecto
2. El archivo está listado en `pubspec.yaml` en la sección `assets`
3. Ejecutaste `flutter pub get` después de agregar la dependencia

### La app no se conecta al backend

**Solución:**
1. Verifica que el backend esté corriendo
2. Revisa la URL en tu archivo `.env`
3. Para dispositivos físicos, asegúrate de usar la IP correcta
4. Verifica que el firewall no esté bloqueando la conexión

### Cambios en .env no se reflejan

**Solución:**
1. Detén la app completamente
2. Ejecuta `flutter clean`
3. Ejecuta `flutter pub get`
4. Reinicia la app

## 📚 Referencias

- [flutter_dotenv documentation](https://pub.dev/packages/flutter_dotenv)
- [Flutter environment variables](https://docs.flutter.dev/deployment/environment-variables)

