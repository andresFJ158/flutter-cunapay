import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Pantalla de comprobante de transacción
/// Muestra los detalles de una transacción completada con opciones para descargar y compartir
class TransactionReceiptScreen extends StatefulWidget {
  final String amount;
  final String toAddress;
  final String? transactionId;
  final String? transactionHash;
  final DateTime? timestamp;

  const TransactionReceiptScreen({
    super.key,
    required this.amount,
    required this.toAddress,
    this.transactionId,
    this.transactionHash,
    this.timestamp,
  });

  @override
  State<TransactionReceiptScreen> createState() => _TransactionReceiptScreenState();
}

class _TransactionReceiptScreenState extends State<TransactionReceiptScreen> {
  final WidgetsToImageController _widgetsToImageController = WidgetsToImageController();
  final GlobalKey _receiptKey = GlobalKey();
  String? _fromAddress;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _loadWalletAddress();
  }

  Future<void> _loadWalletAddress() async {
    try {
      final response = await ApiService().getWallet();
      if (mounted) {
        setState(() {
          _fromAddress = response.data['address'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Uint8List?> _captureWidget() async {
    try {
      final imageBytes = await _widgetsToImageController.capture();
      if (imageBytes != null) return imageBytes;
    } catch (e) {
      // Fallback: usar RenderRepaintBoundary directamente
    }
    
    try {
      final RenderRepaintBoundary boundary = 
          _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<void> _downloadReceipt() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final imageBytes = await _captureWidget();
      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al capturar el comprobante'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/comprobante_$timestamp.png');
      await file.writeAsBytes(imageBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comprobante guardado en: ${file.path}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareReceipt() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      final imageBytes = await _captureWidget();
      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al capturar el comprobante'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/comprobante_$timestamp.png');
      await file.writeAsBytes(imageBytes);

      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        text: 'Comprobante de transacción CuñaPay',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado al portapapeles'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timestamp = widget.timestamp ?? DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(timestamp);
    final formattedTime = DateFormat('HH:mm:ss').format(timestamp);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Comprobante de Transacción'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.textPrimary : AppColors.textDark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.screenHorizontal),
                        child: RepaintBoundary(
                        key: _receiptKey,
                        child: WidgetsToImage(
                          controller: _widgetsToImageController,
                          child: Container(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF252940) : AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo
                              Image.asset(
                                'lib/assets/logo.png',
                                width: 80,
                                height: 80,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              // Título
                              Text(
                                'Comprobante de Transacción',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Envío de USDT',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              // Icono de éxito
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 48,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              // Monto
                              Text(
                                '${widget.amount} USDT',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              // Divider
                              Container(
                                height: 1,
                                color: AppColors.textSecondary.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              // Detalles
                              _buildDetailRow(
                                'Fecha',
                                formattedDate,
                                isDark,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _buildDetailRow(
                                'Hora',
                                formattedTime,
                                isDark,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _buildDetailRow(
                                'Desde',
                                _fromAddress ?? 'N/A',
                                isDark,
                                onTap: _fromAddress != null
                                    ? () => _copyToClipboard(_fromAddress!, 'Dirección')
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _buildDetailRow(
                                'Hacia',
                                widget.toAddress,
                                isDark,
                                onTap: () => _copyToClipboard(widget.toAddress, 'Dirección'),
                              ),
                              if (widget.transactionId != null) ...[
                                const SizedBox(height: AppSpacing.md),
                                _buildDetailRow(
                                  'ID de Transacción',
                                  widget.transactionId!,
                                  isDark,
                                  onTap: () => _copyToClipboard(widget.transactionId!, 'ID'),
                                ),
                              ],
                              if (widget.transactionHash != null) ...[
                                const SizedBox(height: AppSpacing.md),
                                _buildDetailRow(
                                  'Hash de Transacción',
                                  widget.transactionHash!,
                                  isDark,
                                  onTap: () => _copyToClipboard(widget.transactionHash!, 'Hash'),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.lg),
                              // Footer
                              Text(
                                'CuñaPay - Tu wallet crypto de confianza',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                        ),
                      ),
                    ),
                  ),
                  // Botones de acción
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.screenHorizontal),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isSaving ? null : _downloadReceipt,
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.download_rounded),
                                label: const Text('Descargar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? AppColors.textPrimary : AppColors.textDark,
                                  side: BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isSharing ? null : _shareReceipt,
                                icon: _isSharing
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                                        ),
                                      )
                                    : const Icon(Icons.share_rounded),
                                label: const Text('Compartir'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.textPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                            child: const Text('Volver al inicio'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      fontFamily: value.length > 20 ? 'monospace' : null,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.copy_rounded,
                size: 18,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

