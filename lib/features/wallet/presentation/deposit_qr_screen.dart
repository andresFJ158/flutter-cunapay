import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class DepositQrScreen extends StatefulWidget {
  final double amountUsdt;
  final double amountBs;
  final double exchangeRate;

  const DepositQrScreen({
    super.key,
    required this.amountUsdt,
    required this.amountBs,
    required this.exchangeRate,
  });

  @override
  State<DepositQrScreen> createState() => _DepositQrScreenState();
}

class _DepositQrScreenState extends State<DepositQrScreen> {
  String? _purchaseId;
  bool _isLoading = true;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _createPurchase();
  }

  Future<void> _createPurchase() async {
    try {
      final response = await ApiService().createPurchase(widget.amountUsdt);
      if (mounted && response.data != null) {
        setState(() {
          _purchaseId = response.data['id']?.toString() ?? 
                       response.data['purchaseId']?.toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la compra: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmPayment() async {
    if (_purchaseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo crear la compra'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isConfirming = true);

    try {
      // El createPurchase ya crea la compra, así que solo redirigimos
      // En un caso real, aquí se llamaría a un endpoint de confirmación
      // await ApiService().confirmPurchase(_purchaseId!);
      
      if (mounted) {
        // Redirigir al home
        context.go('/home');
        
        // Mostrar notificación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'El administrador debe verificar el pago. Recibirás el saldo en tu balance una vez verificado.',
            ),
            backgroundColor: AppColors.info,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al confirmar el pago: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Realizar Pago'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Instrucciones
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tu pago debe ser de Bs ${widget.amountBs.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Equivalente a ${widget.amountUsdt.toStringAsFixed(2)} USDT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // QR del banco
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252940) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 280,
                          height: 280,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'lib/assets/qr.jpeg',
                            fit: BoxFit.contain,
                            width: 280,
                            height: 280,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Botón Ya pagué
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isConfirming || _isLoading ? null : _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isConfirming
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                          ),
                        )
                      : const Text(
                          'Ya pagué',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

