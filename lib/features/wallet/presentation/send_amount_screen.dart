import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/design_system/transaction_input_screen.dart';
import '../../../shared/widgets/design_system/transaction_input_skeleton.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/common/info_dialog.dart';
import 'send_recipient_screen.dart';

/// Pantalla moderna de entrada de cantidad para envío
/// 
/// Usa el diseño tipo banco digital con numpad personalizado
class SendAmountScreen extends StatefulWidget {
  const SendAmountScreen({super.key});

  @override
  State<SendAmountScreen> createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends State<SendAmountScreen> {
  Map<String, dynamic>? _balance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final response = await ApiService().getBalance();
      if (mounted) {
        setState(() {
          _balance = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatBalance(num balance) {
    return balance.toStringAsFixed(2);
  }

  void _handleContinue(String amount) {
    if (!mounted) return;
    
    // Validar que el monto no esté vacío
    if (amount.isEmpty || amount.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un monto'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    try {
      if (_balance == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar el balance. Por favor, intenta de nuevo.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      final amountNum = double.tryParse(amount.trim());
      if (amountNum == null || amountNum <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, ingresa un monto válido mayor a 0'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      final available = (_balance!['available'] as num?) ?? 0.0;
      if (amountNum > available) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fondos insuficientes. Disponible: ${available.toStringAsFixed(2)} USDT'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Navegar a la pantalla de envío con la cantidad
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SendRecipientScreen(amount: amount.trim()),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al continuar: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const TransactionInputSkeleton();
    }

    final available = _balance?['available'] as num? ?? 0.0;
    final balanceFormatted = _formatBalance(available);

    return TransactionInputScreen(
      title: 'Enviar fondos',
      currencyCode: 'USDT',
      balance: '$balanceFormatted USDT',
      currencySymbol: '\$',
      buttonText: 'Continuar',
      showDecimal: true,
      maxAmount: available.toDouble(),
      compactBalance: true,
      onInfoTap: () => InfoDialog.showSendUsdtInfo(context),
      onContinue: (amount) {
        _handleContinue(amount);
      },
    );
  }
}

