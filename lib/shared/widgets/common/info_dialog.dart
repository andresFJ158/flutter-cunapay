import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Diálogo de información con pasos numerados
/// 
/// Muestra un diálogo modal con información estructurada en pasos
class InfoDialog extends StatelessWidget {
  final String title;
  final String description;
  final List<String> steps;

  const InfoDialog({
    super.key,
    required this.title,
    required this.description,
    required this.steps,
  });

  /// Muestra el diálogo de información para comprar USDT
  static void showBuyUsdtInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => InfoDialog(
        title: 'Cómo comprar USDT',
        description: 'Sigue estos pasos para comprar USDT de forma segura:',
        steps: [
          'Ingresa la cantidad de USDT que deseas comprar',
          'Revisa el tipo de cambio y el monto en bolivianos que deberás pagar',
          'Presiona "Continuar" para generar el código QR de pago',
          'Realiza la transferencia bancaria por el monto indicado',
          'Una vez realizado el pago, presiona "Ya pagué"',
          'Espera la verificación del administrador',
          'Los USDT se acreditarán en tu billetera una vez aprobado el pago',
        ],
      ),
    );
  }

  /// Muestra el diálogo de información para enviar USDT
  static void showSendUsdtInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => InfoDialog(
        title: 'Cómo enviar USDT',
        description: 'Sigue estos pasos para enviar USDT a otra billetera:',
        steps: [
          'Ingresa la cantidad de USDT que deseas enviar',
          'Verifica que tengas suficiente saldo disponible',
          'Presiona "Continuar" para ir a la pantalla de envío',
          'Ingresa la dirección de la billetera destino',
          'Verifica cuidadosamente la dirección antes de confirmar',
          'Revisa el resumen de la transacción',
          'Confirma el envío',
          'La transacción se procesará y los USDT serán transferidos',
        ],
      ),
    );
  }

  /// Muestra el diálogo de información para crear un stake
  static void showStakingInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => InfoDialog(
        title: 'Cómo crear un Stake',
        description: 'Sigue estos pasos para crear un stake y generar ingresos pasivos:',
        steps: [
          'Ingresa la cantidad de USDT que deseas stakear',
          'Revisa el estimado de ganancias diarias y mensuales',
          'Verifica que tengas suficiente saldo disponible',
          'Presiona "Crear Stake" para confirmar',
          'Tu USDT quedará bloqueado y comenzará a generar intereses',
          'Los intereses se acumulan diariamente según la tasa configurada',
          'Puedes cerrar tu stake en cualquier momento',
          'Al cerrar, recibirás el principal más todas las recompensas acumuladas',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: isDark ? const Color(0xFF252940) : AppColors.backgroundLight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título e icono
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
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
            const SizedBox(height: 16),
            
            // Descripción
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // Pasos
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Número del paso
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.2),
                                  AppColors.primary.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Texto del paso
                          Expanded(
                            child: Text(
                              step,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Botón de cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
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
                  'Entendido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

