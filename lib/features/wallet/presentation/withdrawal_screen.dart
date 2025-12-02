import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/design_system/transaction_input_screen.dart';
import '../../../shared/widgets/design_system/transaction_input_skeleton.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/common/info_dialog.dart';

/// Pantalla moderna de retiro de USDT a Bolivianos
/// 
/// Similar a la pantalla de compra, pero para retirar USDT
/// El usuario debe tener perfil completado (número de cuenta y entidad bancaria)
class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  double? _exchangeRate;
  bool _isLoadingRate = false;
  String? _errorMessage;
  Map<String, dynamic>? _balance;
  Map<String, dynamic>? _userInfo;
  bool _isProfileComplete = false;

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
      // Cargar exchange rate, balance y perfil del usuario en paralelo
      final results = await Future.wait([
        ApiService().getWithdrawalPrice(),
        ApiService().getBalance(),
        ApiService().getMe(),
      ]);

      if (mounted) {
        final priceResponse = results[0];
        final balanceResponse = results[1];
        final userResponse = results[2];

        // Procesar respuesta del precio
        if (priceResponse.data != null && priceResponse.data['price'] != null) {
          final priceValue = priceResponse.data['price'];
          if (priceValue is num) {
            _exchangeRate = priceValue.toDouble();
          } else if (priceValue is String) {
            _exchangeRate = double.tryParse(priceValue);
          } else {
            _exchangeRate = double.tryParse(priceValue.toString());
          }
          
          if (_exchangeRate == null) {
            _errorMessage = 'No se pudo obtener el tipo de cambio válido.';
          }
        } else {
          _errorMessage = 'No se pudo obtener el tipo de cambio.';
        }

        // Procesar respuesta del balance
        _balance = balanceResponse.data;

        // Verificar si el perfil está completo
        _userInfo = userResponse.data;
        final bankAccountNumber = _userInfo?['bankAccountNumber']?.toString().trim();
        final bankEntity = _userInfo?['bankEntity']?.toString().trim();
        _isProfileComplete = bankAccountNumber != null && 
                            bankAccountNumber.isNotEmpty && 
                            bankEntity != null && 
                            bankEntity.isNotEmpty;

        if (!_isProfileComplete) {
          _errorMessage = 'Debes completar tu perfil con información bancaria para poder retirar USDT.';
        }

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
    if (!_isProfileComplete) {
      _showError('Debes completar tu perfil con información bancaria para poder retirar USDT.');
      return;
    }

    if (_exchangeRate == null) {
      _showError('No se pudo obtener el tipo de cambio. Intenta de nuevo.');
      return;
    }

    final amountUsdt = double.tryParse(amount);
    if (amountUsdt == null || amountUsdt <= 0) {
      _showError('La cantidad debe ser mayor a 0');
      return;
    }

    // Verificar que el usuario tenga suficiente balance disponible
    final available = _balance?['available'] as num? ?? 0.0;
    if (amountUsdt > available) {
      _showError('No tienes suficiente balance disponible. Disponible: ${available.toStringAsFixed(2)} USDT');
      return;
    }

    // Calcular el monto en BS basado en el tipo de cambio
    final amountBs = amountUsdt * _exchangeRate!;

    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Retiro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vas a retirar: ${amountUsdt.toStringAsFixed(2)} USDT'),
            const SizedBox(height: 8),
            Text('Recibirás: ${amountBs.toStringAsFixed(2)} BS'),
            const SizedBox(height: 8),
            Text('Tipo de cambio: ${_exchangeRate!.toStringAsFixed(2)} BS/USDT'),
            const SizedBox(height: 16),
            const Text(
              'El retiro será procesado y los fondos se transferirán a tu cuenta bancaria registrada.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Crear la solicitud de retiro
    try {
      setState(() => _isLoadingRate = true);
      final response = await ApiService().createWithdrawal(amountUsdt);

      if (mounted) {
        setState(() => _isLoadingRate = false);
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud de retiro creada correctamente'),
            backgroundColor: AppColors.success,
          ),
        );

        // Regresar a la pantalla anterior
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRate = false);
        _showError('Error al crear la solicitud de retiro: $e');
      }
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
    if (_isLoadingRate && _exchangeRate == null) {
      return const TransactionInputSkeleton();
    }

    // Mostrar error si no se pudo cargar el tipo de cambio o perfil incompleto
    if (_errorMessage != null && (_exchangeRate == null || !_isProfileComplete)) {
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Retirar USDT'),
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
                if (!_isProfileComplete)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navegar a completar perfil desde el perfil
                    },
                    child: const Text('Completar Perfil'),
                  )
                else
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
      title: 'Retirar USDT',
      currencyCode: 'USDT',
      balance: '$balanceFormatted USDT',
      currencySymbol: 'Bs',
      buttonText: 'Confirmar Retiro',
      showDecimal: true,
      showAmountInput: true,
      exchangeRate: _exchangeRate,
      calculateAmountBs: _calculateAmountBs,
      onInfoTap: () => InfoDialog.showWithdrawalInfo(context),
      onContinue: (amount) {
        _handleContinue(amount);
      },
    );
  }
}

