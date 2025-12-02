import '../services/api_service.dart';
import '../theme/app_colors.dart';

/// Servicio para calcular el momento de compra basado en el tipo de cambio
/// 
/// Este servicio determina si es un buen momento para comprar USDT
/// basándose en umbrales configurables del tipo de cambio.
class ExchangeRateService {
  // Umbrales configurables para determinar el momento de compra
  // Estos valores pueden ajustarse según las necesidades del negocio
  static const double _lowThreshold = 10.0;  // Por debajo de este valor = VERDE (buen momento)
  static const double _highThreshold = 13.0; // Por encima de este valor = ROJO (mal momento)
  // Entre _lowThreshold y _highThreshold (inclusive) = AMARILLO (momento neutral)
  
  /// Obtiene el precio actual de USDT en BS (Bolívares Soberanos)
  /// 
  /// Usa el endpoint /api/purchases/price que retorna el precio calculado
  /// como Binance P2P + 0.10 BS adicionales
  /// 
  /// Retorna null si hay error de conexión o el formato de respuesta no es válido
  Future<double?> getCurrentExchangeRate() async {
    try {
      final response = await ApiService().getPurchasePrice();
      
      // Verificar que la respuesta sea exitosa
      if (response.statusCode != null && 
          response.statusCode! >= 200 && 
          response.statusCode! < 300 && 
          response.data != null) {
        final data = response.data;
        
        // El nuevo endpoint retorna: { "ok": true, "price": 36.60, "currency": "BS" }
        if (data is Map) {
          // Buscar el precio en diferentes campos posibles
          final rate = data['price'] ?? 
                      data['rate'] ?? 
                      data['exchangeRate'] ?? 
                      data['usdToBob'] ??
                      data['value'];
          
          if (rate != null) {
            final parsedRate = double.tryParse(rate.toString());
            if (parsedRate != null && parsedRate > 0) {
              return parsedRate;
            }
          }
        } else if (data is num && data > 0) {
          return data.toDouble();
        } else if (data is String) {
          // Si viene como string, intentar parsearlo
          final parsedRate = double.tryParse(data);
          if (parsedRate != null && parsedRate > 0) {
            return parsedRate;
          }
        }
      }
      return null;
    } catch (e) {
      // Error de conexión o formato inválido
      // Retornar null para que la UI pueda manejar el error apropiadamente
      return null;
    }
  }
  
  /// Determina el momento de compra basado en el tipo de cambio
  /// 
  /// Retorna:
  /// - 'green': Buen momento para comprar (tipo de cambio bajo)
  /// - 'yellow': Momento incierto (tipo de cambio intermedio)
  /// - 'red': Mal momento para comprar (tipo de cambio alto)
  /// - null: No se pudo determinar (error al obtener el precio)
  Future<BuyMoment?> getBuyMoment() async {
    final rate = await getCurrentExchangeRate();
    if (rate == null) return null;
    
    if (rate < _lowThreshold) {
      // Precio < 10: Buen momento (verde)
      return BuyMoment.green;
    } else if (rate >= _lowThreshold && rate <= _highThreshold) {
      // Precio entre 10 y 13 (inclusive): Momento neutral (amarillo)
      return BuyMoment.yellow;
    } else {
      // Precio > 13: Mal momento (rojo)
      return BuyMoment.red;
    }
  }
  
  /// Obtiene el mensaje descriptivo para el momento de compra
  String getBuyMomentMessage(BuyMoment moment) {
    switch (moment) {
      case BuyMoment.green:
        return 'Buen momento para comprar USDT';
      case BuyMoment.yellow:
        return 'Momento neutral';
      case BuyMoment.red:
        return 'Mal momento para comprar USDT';
    }
  }
  
  /// Obtiene el color asociado al momento de compra
  int getBuyMomentColor(BuyMoment moment) {
    switch (moment) {
      case BuyMoment.green:
        return AppColors.green.value; // Verde - Buen momento
      case BuyMoment.yellow:
        return AppColors.greyDark.value; // Gris oscuro - Mercado estable
      case BuyMoment.red:
        return AppColors.yellow.value; // Amarillo - Mal momento
    }
  }
  
  /// Obtiene el ícono asociado al momento de compra
  String getBuyMomentIcon(BuyMoment moment) {
    switch (moment) {
      case BuyMoment.green:
        return '↓'; // Flecha hacia abajo (precio bajo)
      case BuyMoment.yellow:
        return '↔'; // Flecha bidireccional (incierto)
      case BuyMoment.red:
        return '↑'; // Flecha hacia arriba (precio alto)
    }
  }
}

/// Enum que representa el momento de compra
enum BuyMoment {
  green,   // Buen momento
  yellow,  // Momento incierto
  red,     // Mal momento
}

