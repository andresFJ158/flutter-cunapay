import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/qr_scanner_screen.dart';

class SendRecipientScreen extends StatefulWidget {
  final String amount;

  const SendRecipientScreen({
    super.key,
    required this.amount,
  });

  @override
  State<SendRecipientScreen> createState() => _SendRecipientScreenState();
}

class _SendRecipientScreenState extends State<SendRecipientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _toController.dispose();
    super.dispose();
  }

  Future<void> _scanQR() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(),
      ),
    );

    if (result != null && mounted) {
      // Limpiar el resultado para obtener solo la dirección
      String address = result.trim();
      
      // Si el QR contiene una URL (tron:// o https://), extraer la dirección
      if (address.contains('tron://')) {
        // Formato: tron://Txxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        address = address.replaceFirst('tron://', '');
        if (address.contains('?')) {
          address = address.split('?').first;
        }
      } else if (address.contains('http://') || address.contains('https://')) {
        // Formato: https://example.com/Txxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        // Buscar la dirección TRON en la URL
        final regex = RegExp(r'T[1-9A-HJ-NP-Za-km-z]{33}');
        final match = regex.firstMatch(address);
        if (match != null) {
          address = match.group(0)!;
        } else {
          // Si no se encuentra, intentar extraer del path
          final uri = Uri.tryParse(address);
          if (uri != null && uri.pathSegments.isNotEmpty) {
            final lastSegment = uri.pathSegments.last;
            if (lastSegment.startsWith('T') && lastSegment.length >= 34) {
              address = lastSegment;
            }
          }
        }
      } else if (address.contains('?')) {
        // Si tiene parámetros, tomar solo la parte antes del ?
        address = address.split('?').first;
      }
      
      // Validar que sea una dirección TRON válida
      if (address.startsWith('T') && address.length >= 34) {
        // Limitar a 34 caracteres (longitud estándar de dirección TRON)
        address = address.substring(0, 34);
        _toController.text = address;
      } else {
        // Si no es válida, mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El QR escaneado no contiene una dirección TRON válida'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null && mounted) {
      String address = clipboardData!.text!.trim();
      
      // Limpiar la dirección si viene en formato de URL
      if (address.contains('tron://')) {
        address = address.replaceFirst('tron://', '');
        if (address.contains('?')) {
          address = address.split('?').first;
        }
      } else if (address.contains('http://') || address.contains('https://')) {
        final regex = RegExp(r'T[1-9A-HJ-NP-Za-km-z]{33}');
        final match = regex.firstMatch(address);
        if (match != null) {
          address = match.group(0)!;
        } else {
          final uri = Uri.tryParse(address);
          if (uri != null && uri.pathSegments.isNotEmpty) {
            final lastSegment = uri.pathSegments.last;
            if (lastSegment.startsWith('T') && lastSegment.length >= 34) {
              address = lastSegment;
            }
          }
        }
      } else if (address.contains('?')) {
        address = address.split('?').first;
      }
      
      // Validar y pegar
      if (address.startsWith('T') && address.length >= 34) {
        address = address.substring(0, 34);
        _toController.text = address;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dirección pegada desde el portapapeles'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El portapapeles no contiene una dirección TRON válida'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? const Color(0xFF252940) : AppColors.backgroundLight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Confirmar Envío',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimary : AppColors.textDark,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context, false),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Resumen de la transacción
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2130) : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Dirección de destino',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _toController.text,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                          color: isDark ? AppColors.textPrimary : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        height: 1,
                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Monto a enviar',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.amount} USDT',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Confirmar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isSending = true);
    try {
      await ApiService().sendUSDT(_toController.text.trim(), widget.amount);
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('USDT enviado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Enviar USDT'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Cantidad: ${widget.amount} USDT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _toController,
                  decoration: InputDecoration(
                    labelText: 'Dirección de destino',
                    hintText: 'Txxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
                    prefixIcon: Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
                      onPressed: _scanQR,
                      tooltip: 'Escanear QR',
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF252940) : AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la dirección de destino';
                    }
                    if (!value.trim().startsWith('T') || value.trim().length < 34) {
                      return 'Dirección TRON inválida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _scanQR,
                        icon: Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
                        label: const Text('Escanear QR'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _pasteFromClipboard,
                        icon: Icon(Icons.paste_rounded, color: AppColors.primary),
                        label: const Text('Pegar'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSending ? null : _handleSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSending
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                            ),
                          )
                        : const Text(
                            'Enviar USDT',
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
      ),
    );
  }
}

