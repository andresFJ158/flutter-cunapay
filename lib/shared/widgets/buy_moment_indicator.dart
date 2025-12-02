import 'package:flutter/material.dart';
import '../../core/providers/exchange_rate_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Widget que muestra un indicador visual del momento de compra de USDT
/// basado en la cotización actual
class BuyMomentIndicator extends StatefulWidget {
  const BuyMomentIndicator({super.key});

  @override
  State<BuyMomentIndicator> createState() => _BuyMomentIndicatorState();
}

class _BuyMomentIndicatorState extends State<BuyMomentIndicator> {
  final ExchangeRateService _exchangeService = ExchangeRateService();
  double? _exchangeRate;
  BuyMoment? _buyMoment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExchangeRate();
  }

  Future<void> _loadExchangeRate() async {
    setState(() => _isLoading = true);
    try {
      final rate = await _exchangeService.getCurrentExchangeRate();
      final moment = await _exchangeService.getBuyMoment();
      
      if (mounted) {
        setState(() {
          _exchangeRate = rate;
          _buyMoment = moment;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getMomentColor() {
    switch (_buyMoment) {
      case BuyMoment.green:
        return AppColors.success; // Verde
      case BuyMoment.yellow:
        return AppColors.warning; // Amarillo/Naranja
      case BuyMoment.red:
        return AppColors.error; // Rojo
      case null:
        return AppColors.textSecondary; // Gris cuando hay error
    }
  }

  String _getMomentText() {
    switch (_buyMoment) {
      case BuyMoment.green:
        return 'Buen momento';
      case BuyMoment.yellow:
        return 'Momento neutral';
      case BuyMoment.red:
        return 'Mal momento';
      case null:
        return 'No disponible';
    }
  }

  IconData _getMomentIcon() {
    switch (_buyMoment) {
      case BuyMoment.green:
        return Icons.trending_down_rounded;
      case BuyMoment.yellow:
        return Icons.trending_flat_rounded;
      case BuyMoment.red:
        return Icons.trending_up_rounded;
      case null:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final momentColor = _getMomentColor();

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: momentColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: momentColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: momentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getMomentIcon(),
                  color: momentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Indicador de momento',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Text(
                            _getMomentText(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: momentColor,
                            ),
                          ),
                  ],
                ),
              ),
              if (!_isLoading && _exchangeRate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: momentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_exchangeRate!.toStringAsFixed(2)} Bs/USDT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: momentColor,
                    ),
                  ),
                ),
            ],
          ),
          if (!_isLoading && _buyMoment != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: momentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: momentColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _exchangeService.getBuyMomentMessage(_buyMoment!),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

