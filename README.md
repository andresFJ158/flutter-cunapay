# CunaPay Flutter App

Aplicación Flutter completa y profesional para CunaPay que funciona en iOS, Android y Web.

## Características

- ✅ Autenticación (Registro y Login)
- ✅ Dashboard con balances (TRX, USDT, Disponible, En Staking)
- ✅ Envío de USDT
- ✅ Staking (Crear, Listar, Reclamar intereses, Cerrar)
- ✅ Historial de transacciones (DB y On-Chain)
- ✅ **Módulo de Noticias completo** (Listar, Crear, Ver detalles)
- ✅ UI moderna y profesional
- ✅ Tema claro/oscuro
- ✅ Navegación intuitiva
- ✅ **Multiplataforma**: iOS, Android y **Web**

## Requisitos

- Flutter SDK 3.0.0 o superior
- Dart 3.0.0 o superior
- Backend ASP.NET Core corriendo en `http://localhost:4000`

## Instalación

1. Clona o navega al directorio:
```bash
cd flutter-app
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Configura la URL de la API usando variables de entorno:

**Primera vez:**
```bash
# Copia el archivo de ejemplo
cp .env.development.example .env.development
```

**Edita `.env.development` y configura:**
```env
# Para Web o emuladores
BASE_URL=http://localhost:4000

# Para dispositivos físicos, usa la IP de tu máquina
BASE_URL=http://192.168.1.100:4000
```

**Ver documentación completa:** `CONFIGURACION_ENTORNOS.md`

## Ejecutar la Aplicación

### Web
```bash
flutter run -d chrome
```

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Todos los dispositivos disponibles
```bash
flutter devices  # Ver dispositivos disponibles
flutter run      # Elegir dispositivo
```

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── config/
│   └── api_config.dart      # Configuración de API
├── services/
│   └── api_service.dart     # Servicio de API
├── providers/
│   ├── auth_provider.dart   # Estado de autenticación
│   └── theme_provider.dart  # Estado del tema
├── routes/
│   └── app_router.dart      # Configuración de rutas
├── theme/
│   └── app_theme.dart       # Temas claro/oscuro
├── widgets/
│   ├── custom_button.dart   # Botón personalizado
│   ├── custom_input.dart    # Input personalizado
│   └── info_card.dart       # Tarjeta de información
└── screens/
    ├── auth/                # Login y Registro
    ├── home/                # Pantalla principal
    ├── wallet/              # Dashboard y Envío
    ├── staking/             # Gestión de Staking
    ├── transactions/        # Historial
    └── news/                # Módulo de Noticias
```

## Funcionalidades Implementadas

### Autenticación
- Registro de nuevos usuarios
- Login con JWT
- Logout
- Persistencia de sesión

### Wallet
- Visualización de dirección de wallet
- Balance total USDT
- Balance TRX
- USDT disponible
- USDT en staking
- Envío de USDT con validación

### Staking
- Crear nuevos stakes
- Listar todos los stakes
- Reclamar intereses
- Cerrar stakes
- Ver intereses estimados

### Transacciones
- Vista de transacciones desde DB
- Vista de transacciones on-chain
- Filtrado por fuente
- Detalles completos

### Noticias
- Listar todas las noticias
- Filtrar por categoría
- Ver detalle de noticia
- Crear nueva noticia (requiere autenticación)
- Abrir enlace externo

## Configuración para Web

Flutter Web está completamente soportado. Para ejecutar:

```bash
flutter run -d chrome
```

O para compilar para producción:

```bash
flutter build web
```

Los archivos se generarán en `build/web/`

## Notas

- La app usa Provider para gestión de estado
- GoRouter para navegación declarativa
- Dio para peticiones HTTP con interceptores
- SharedPreferences para almacenamiento local
- Material Design 3 para UI moderna

## Próximos Pasos

- [ ] Agregar notificaciones push
- [ ] Implementar biometría para login
- [ ] Agregar gráficos de historial
- [ ] Mejorar manejo de errores
- [ ] Agregar internacionalización (i18n)
- [ ] Agregar tests unitarios

## Solución de Problemas

### Error de conexión a la API
- Verifica que el backend esté corriendo
- Revisa la URL en `api_config.dart`
- Para web, asegúrate de que CORS esté configurado en el backend

### Error al compilar
```bash
flutter clean
flutter pub get
flutter run
```

### Problemas con dependencias
```bash
flutter pub upgrade
flutter pub get
```

