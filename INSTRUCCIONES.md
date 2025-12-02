# 🚀 Instrucciones para Ejecutar la App Flutter

## Requisitos Previos

1. **Flutter SDK** instalado (versión 3.0.0 o superior)
   - Descarga desde: https://flutter.dev/docs/get-started/install
   - Verifica instalación: `flutter doctor`

2. **Backend ASP.NET Core** corriendo
   - Debe estar en `http://localhost:4000`
   - O actualiza la URL en `lib/config/api_config.dart`

## Pasos Rápidos

### 1. Instalar Dependencias

```bash
cd flutter-app
flutter pub get
```

### 2. Configurar URL de API

Edita `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://localhost:4000';
```

**Para dispositivos móviles físicos:**
- Usa la IP de tu máquina: `http://192.168.1.100:4000`
- Encuentra tu IP: `ipconfig` (Windows) o `ifconfig` (Mac/Linux)

### 3. Ejecutar la Aplicación

#### Web (Recomendado para empezar)
```bash
flutter run -d chrome
```

#### Android
```bash
flutter run -d android
```

#### iOS (solo en Mac)
```bash
flutter run -d ios
```

#### Ver dispositivos disponibles
```bash
flutter devices
```

## Comandos Útiles

### Limpiar y Reconstruir
```bash
flutter clean
flutter pub get
flutter run
```

### Actualizar Dependencias
```bash
flutter pub upgrade
flutter pub get
```

### Verificar Configuración
```bash
flutter doctor
```

### Compilar para Producción

**Web:**
```bash
flutter build web
```
Los archivos estarán en `build/web/`

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Solución de Problemas

### Error: "No devices found"
- Para web: Asegúrate de tener Chrome instalado
- Para Android: Abre Android Studio y configura un emulador
- Para iOS: Abre Xcode y configura un simulador

### Error de conexión a la API
1. Verifica que el backend esté corriendo
2. Revisa la URL en `api_config.dart`
3. Para web, verifica CORS en el backend
4. Para móvil, usa la IP de tu máquina en lugar de `localhost`

### Error: "Package not found"
```bash
flutter clean
flutter pub get
```

### Error al compilar para web
```bash
flutter config --enable-web
flutter clean
flutter pub get
flutter run -d chrome
```

## Estructura de Carpetas

```
flutter-app/
├── lib/
│   ├── main.dart              # Punto de entrada
│   ├── config/                # Configuración
│   ├── services/              # Servicios API
│   ├── providers/             # Estado global
│   ├── routes/                # Navegación
│   ├── theme/                 # Temas
│   ├── widgets/               # Componentes reutilizables
│   └── screens/               # Pantallas
├── web/                       # Archivos web
├── pubspec.yaml               # Dependencias
└── README.md                  # Documentación
```

## Características Implementadas

✅ Autenticación completa
✅ Dashboard con balances
✅ Envío de USDT
✅ Sistema de Staking
✅ Historial de transacciones
✅ **Módulo de Noticias completo**
✅ Tema claro/oscuro
✅ Navegación intuitiva
✅ **Soporte Web completo**

## Próximos Pasos

1. Ejecuta `flutter pub get`
2. Configura la URL de la API
3. Ejecuta `flutter run -d chrome` para web
4. ¡Disfruta de tu app! 🎉

