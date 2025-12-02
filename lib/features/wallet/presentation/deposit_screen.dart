import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/design_system/transaction_input_screen.dart';
import '../../../shared/widgets/design_system/transaction_input_skeleton.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/common/info_dialog.dart';
import 'deposit_qr_screen.dart';

/// Pantalla moderna de compra de USDT con estilo tipo banco digital
/// 
/// Usa el diseño moderno con numpad personalizado, display grande de cantidad
/// y cálculo en tiempo real del tipo de cambio
class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  double? _exchangeRate;
  bool _isLoadingRate = false;
  String? _errorMessage;
  Map<String, dynamic>? _balance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Carga todos los datos en paralelo para optimizar el rendimiento
  Future<void> _loadData() async {
    setState(() {
      _isLoadingRate = true;
      _errorMessage = null;
    });

    try {
      // Cargar exchange rate y balance en paralelo
      final results = await Future.wait([
        ApiService().getPurchasePrice(),
        ApiService().getBalance(),
      ]);

      if (mounted) {
        final priceResponse = results[0];
        final balanceResponse = results[1];

        // Procesar respuesta del precio
        if (priceResponse.data != null && priceResponse.data['price'] != null) {
          _exchangeRate = double.tryParse(priceResponse.data['price'].toString());
        } else {
          _errorMessage = 'No se pudo obtener el tipo de cambio.';
        }

        // Procesar respuesta del balance
        _balance = balanceResponse.data;

        setState(() {
          _isLoadingRate = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRate = false;
          _errorMessage = 'Error al cargar datos: $e';
        });
      }
    }
  }

  String _formatBalance(num balance) {
    return balance.toStringAsFixed(2);
  }

  String _calculateAmountBs(String amount) {
    final amountNum = double.tryParse(amount.isEmpty ? '0' : amount) ?? 0.0;
    if (_exchangeRate == null || amountNum <= 0) return '0.00';
    
    // Calcular monto en BS: cantidad USDT * tipo de cambio
    final amountBs = amountNum * _exchangeRate!;
    return amountBs.toStringAsFixed(2);
  }

  Future<void> _handleContinue(String amount) async {
    if (_exchangeRate == null) {
      _showError('No se pudo obtener el tipo de cambio. Intenta de nuevo.');
      return;
    }

    final amountUsdt = double.tryParse(amount);
    if (amountUsdt == null || amountUsdt <= 0) {
      _showError('La cantidad debe ser mayor a 0');
      return;
    }

    // Calcular el monto en BS basado en el tipo de cambio
    final amountBs = amountUsdt * _exchangeRate!;

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DepositQrScreen(
            amountUsdt: amountUsdt,
            amountBs: amountBs,
            exchangeRate: _exchangeRate!,
          ),
        ),
      );
    }
  }

  void _showError(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onError,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: theme.colorScheme.onError),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar skeleton mientras se cargan los datos
    if (_isLoadingRate) {
      return const TransactionInputSkeleton();
    }

    // Mostrar error si no se pudo cargar el tipo de cambio
    if (_errorMessage != null && _exchangeRate == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Comprar USDT'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _loadData();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Obtener balance disponible (si está disponible)
    final available = _balance?['available'] as num? ?? 0.0;
    final balanceFormatted = _formatBalance(available);

    // Mostrar pantalla de entrada moderna
    return TransactionInputScreen(
      title: 'Comprar USDT',
      currencyCode: 'USDT',
      balance: '$balanceFormatted USDT',
      currencySymbol: '\$',
      buttonText: 'Continuar',
      showDecimal: true,
      showAmountInput: true,
      exchangeRate: _exchangeRate,
      calculateAmountBs: _calculateAmountBs,
      onInfoTap: () => InfoDialog.showBuyUsdtInfo(context),
      onContinue: (amount) {
        _handleContinue(amount);
      },
    );
  }
}
