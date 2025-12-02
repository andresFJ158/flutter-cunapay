import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // Umbrales con histéresis para evitar parpadeo
  static const double _darkLuxThreshold = 60; // Menos que esto → oscuro
  static const double _lightLuxThreshold = 120; // Más que esto → claro

  ThemeMode _themeMode = ThemeMode.light;
  StreamSubscription<int>? _lightSubscription;
  double? _lastLux;
  bool _sensorAvailable = false;
  bool _autoByLight = false; // Flag para controlar si el sensor puede cambiar el tema

  ThemeMode get themeMode => _themeMode;
  double? get currentLux => _lastLux;
  bool get isAutoBrightnessActive => _sensorAvailable && _autoByLight;
  bool get autoByLight => _autoByLight;

  ThemeProvider() {
    _loadTheme();
    _initAmbientLightListener();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode') ?? 'light';
    _autoByLight = prefs.getBool('auto_by_light') ?? false;
    
    switch (themeModeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
        _themeMode = ThemeMode.system;
        break;
      default:
        _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode, {bool isAuto = false}) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString().split('.').last);
    
    // Si el cambio es manual, desactivar modo automático
    if (!isAuto) {
      _autoByLight = false;
      await prefs.setBool('auto_by_light', false);
    }
    
    notifyListeners();
  }

  /// Activa el modo automático basado en luz ambiente
  Future<void> enableAutoByLight() async {
    _autoByLight = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_by_light', true);
    notifyListeners();
  }

  /// Desactiva el modo automático (permite selección manual)
  Future<void> disableAutoByLight() async {
    _autoByLight = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_by_light', false);
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  /// Inicializa el listener del sensor de luz ambiente
  Future<void> _initAmbientLightListener() async {
    if (kIsWeb) return;
    if (!_isMobilePlatform()) return;

    try {
      _sensorAvailable = await LightSensor.hasSensor();
      if (!_sensorAvailable) {
        debugPrint('Ambient light sensor not available on this device');
        return;
      }

      _lightSubscription = LightSensor.luxStream().listen(
        (lux) => _handleLuxChange(lux.toDouble()),
        onError: (error) {
          debugPrint('Ambient light sensor error: $error');
        },
      );
      
      debugPrint('Ambient light sensor initialized successfully');
    } catch (e) {
      debugPrint('Ambient light sensor unavailable: $e');
      _sensorAvailable = false;
    }
  }

  /// Maneja los cambios en el nivel de luz ambiente
  void _handleLuxChange(double lux) {
    _lastLux = lux;

    // Solo cambiar tema si el modo automático está activo
    if (!_autoByLight) return;

    // Histéresis: usar umbrales diferentes según el tema actual
    // Si está en modo claro, necesita menos luz para cambiar a oscuro
    // Si está en modo oscuro, necesita más luz para cambiar a claro
    if (_themeMode == ThemeMode.light) {
      // Si está en modo claro y la luz baja por debajo del umbral oscuro → cambiar a oscuro
      if (lux <= _darkLuxThreshold) {
        _applyAutoTheme(ThemeMode.dark);
      }
    } else if (_themeMode == ThemeMode.dark) {
      // Si está en modo oscuro y la luz sube por encima del umbral claro → cambiar a claro
      if (lux >= _lightLuxThreshold) {
        _applyAutoTheme(ThemeMode.light);
      }
    } else {
      // Si está en modo system, aplicar lógica inicial
      if (lux <= _darkLuxThreshold) {
        _applyAutoTheme(ThemeMode.dark);
      } else if (lux >= _lightLuxThreshold) {
        _applyAutoTheme(ThemeMode.light);
      }
    }
  }

  /// Aplica el tema automáticamente basado en la luz ambiente
  void _applyAutoTheme(ThemeMode mode) {
    if (_themeMode == mode) return;
    setThemeMode(mode, isAuto: true);
  }

  /// Método público para iniciar el listener (por si se necesita llamar manualmente)
  void startListeningToAmbientLight() {
    if (_lightSubscription == null) {
      _initAmbientLightListener();
    }
  }

  bool _isMobilePlatform() {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void dispose() {
    _lightSubscription?.cancel();
    super.dispose();
  }
}

