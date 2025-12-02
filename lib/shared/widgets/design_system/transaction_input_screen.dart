import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'transaction_header.dart';
import 'currency_selector.dart';
import 'transaction_summary_card.dart';
import 'amount_display.dart';
import 'custom_numpad.dart';
import '../common/custom_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Pantalla moderna de entrada de transacción tipo banco digital
/// 
/// Incluye numpad personalizado, display de cantidad grande,
/// selector de moneda y tarjeta de resumen
class TransactionInputScreen extends StatefulWidget {
  final String title;
  final String currencyCode;
  final String balance;
  final String currencySymbol;
  final String buttonText;
  final Function(String amount)? onAmountChanged;
  final Function(String amount)? onContinue;
  final bool showDecimal;
  final double? maxAmount;
  final String? chargesLabel;
  final String? receiveLabel;
  final Function(String amount)? calculateCharges;
  final Function(String amount)? calculateReceive;
  final double? exchangeRate;
  final Function(String amount)? calculateAmountBs;
  final bool showAmountInput;
  final bool compactBalance;
  final bool hideBalance;
  final bool hideHeader;
  final VoidCallback? onInfoTap;

  const TransactionInputScreen({
    super.key,
    required this.title,
    required this.currencyCode,
    required this.balance,
    this.currencySymbol = '\$',
    required this.buttonText,
    this.onAmountChanged,
    this.onContinue,
    this.showDecimal = true,
    this.maxAmount,
    this.chargesLabel,
    this.receiveLabel,
    this.calculateCharges,
    this.calculateReceive,
    this.exchangeRate,
    this.calculateAmountBs,
    this.showAmountInput = false,
    this.compactBalance = false,
    this.hideBalance = false,
    this.hideHeader = false,
    this.onInfoTap,
  });

  @override
  State<TransactionInputScreen> createState() => _TransactionInputScreenState();
}

class _TransactionInputScreenState extends State<TransactionInputScreen> {
  String _amount = '';
  String _charges = '0.00';
  String _receive = '0.00';
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.showAmountInput) {
      _amountController.addListener(() {
        setState(() {
          _amount = _amountController.text;
          _updateCalculations();
        });
        widget.onAmountChanged?.call(_amount);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onNumberTap(String number) {
    setState(() {
      if (number == '.') {
        // Solo permitir un punto decimal
        if (!_amount.contains('.')) {
          _amount += number;
        }
      } else {
        // Limitar a 10 dígitos antes del decimal
        if (_amount.replaceAll('.', '').length < 10) {
          _amount += number;
        }
      }
      if (widget.showAmountInput) {
        _amountController.text = _amount;
      }
      _updateCalculations();
    });
    
    widget.onAmountChanged?.call(_amount);
  }

  void _onDelete() {
    setState(() {
      if (_amount.isNotEmpty) {
        _amount = _amount.substring(0, _amount.length - 1);
        if (widget.showAmountInput) {
          _amountController.text = _amount;
        }
        _updateCalculations();
      }
    });
    
    widget.onAmountChanged?.call(_amount);
  }

  void _onDeleteLongPress() {
    setState(() {
      _amount = '';
      if (widget.showAmountInput) {
        _amountController.text = '';
      }
      _updateCalculations();
    });
    
    widget.onAmountChanged?.call(_amount);
  }

  void _updateCalculations() {
    final amount = double.tryParse(_amount.isEmpty ? '0' : _amount) ?? 0.0;
    
    if (widget.calculateCharges != null) {
      _charges = widget.calculateCharges!(_amount);
    } else {
      _charges = '0.00';
    }
    
    if (widget.calculateReceive != null) {
      _receive = widget.calculateReceive!(_amount);
    } else {
      _receive = _amount.isEmpty ? '0.00' : _amount;
    }
  }

  bool get _isValidAmount {
    if (_amount.isEmpty || _amount == '0' || _amount == '0.') {
      return false;
    }
    
    final amount = double.tryParse(_amount);
    if (amount == null || amount <= 0) {
      return false;
    }
    
    if (widget.maxAmount != null && amount > widget.maxAmount!) {
      return false;
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final balanceNum = double.tryParse(widget.balance.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    final amountNum = double.tryParse(_amount.isEmpty ? '0' : _amount) ?? 0.0;
    final hasInsufficientFunds = widget.maxAmount != null && amountNum > widget.maxAmount!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            if (!widget.hideHeader)
              TransactionHeader(
                title: widget.title,
                onMenu: widget.onInfoTap,
              ),
            
            // Selector de moneda o Input de monto
            if (widget.showAmountInput)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    // Símbolo de moneda ($)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          widget.currencySymbol,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Input de monto
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,6}')),
                        ],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: isDark ? AppColors.textPrimary : AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          suffixText: ' ${widget.currencyCode}',
                          suffixStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF252940) : AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (!widget.hideBalance)
              CurrencySelector(
                currencyCode: widget.currencyCode,
                balance: widget.balance,
                compact: widget.compactBalance,
              ),
            
            // Tipo de cambio y conversión (solo si hay exchangeRate)
            if (widget.exchangeRate != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252940) : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _amount.isNotEmpty && _amount != '0' && widget.calculateAmountBs != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Tipo de cambio a la izquierda
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tipo de cambio',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.exchangeRate!.toStringAsFixed(2)} Bs/USDT',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            // Monto a pagar a la derecha
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Monto a pagar',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.calculateAmountBs!(_amount)} Bs',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tipo de cambio',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${widget.exchangeRate!.toStringAsFixed(2)} Bs/USDT',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isDark ? AppColors.textPrimary : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            
            // Tarjeta de resumen (solo si hay labels)
            if (widget.chargesLabel != null && widget.receiveLabel != null)
              TransactionSummaryCard(
                chargesLabel: widget.chargesLabel!,
                chargesValue: '${widget.currencySymbol}$_charges',
                receiveLabel: widget.receiveLabel!,
                receiveValue: '${widget.currencySymbol}$_receive',
              ),
            
            // Display de cantidad
            Expanded(
              child: AmountDisplay(
                currencySymbol: widget.currencySymbol,
                amount: _amount,
              ),
            ),
            
            // Mensaje de error si hay fondos insuficientes
            if (hasInsufficientFunds)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: Text(
                  'Fondos insuficientes',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Numpad
            CustomNumpad(
              onNumberTap: _onNumberTap,
              onDelete: _onDelete,
              onDeleteLongPress: _onDeleteLongPress,
              showDecimal: widget.showDecimal,
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Botón de acción - Estilo moderno tipo banco digital
            Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.screenHorizontal,
                right: AppSpacing.screenHorizontal,
                top: AppSpacing.lg, // 24-32px desde numpad según especificación
                bottom: AppSpacing.md, // 16-24px desde bottom según especificación
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400), // 360-400px según especificación
                  child: SizedBox(
                    width: double.infinity,
                    height: 54, // 52-56px según especificación
                    child: Opacity(
                      opacity: _isValidAmount && !hasInsufficientFunds ? 1.0 : 0.5, // Opacity según especificación
                      child: ElevatedButton(
                        onPressed: _isValidAmount && !hasInsufficientFunds
                            ? () => widget.onContinue?.call(_amount)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isValidAmount && !hasInsufficientFunds
                              ? AppColors.primary // Verde esmeralda de la paleta
                              : const Color(0xFFF5F5F5), // Light gray cuando está deshabilitado
                          foregroundColor: _isValidAmount && !hasInsufficientFunds
                              ? AppColors.textPrimary // White según especificación
                              : AppColors.textSecondary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27), // 26-28px pill shape según especificación
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          widget.buttonText,
                          style: TextStyle(
                            fontSize: 17, // 16-18px según especificación
                            fontWeight: FontWeight.w400, // 600-700 según especificación
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

