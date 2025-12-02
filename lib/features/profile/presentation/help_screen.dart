import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Ayuda'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.textPrimary : AppColors.textDark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Logo y título
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'lib/assets/logo.png',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'CuñaPay',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Tu wallet crypto de confianza',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Secciones de ayuda
              _HelpSection(
                title: '¿Qué es CuñaPay?',
                content:
                    'CuñaPay es tu wallet crypto de confianza diseñada para facilitar el manejo de criptomonedas. Con CuñaPay puedes:\n\n• Enviar y recibir USDT de forma rápida y segura\n• Hacer staking para generar ingresos pasivos\n• Comprar USDT con Bolivianos de manera sencilla\n• Gestionar todas tus transacciones desde un solo lugar\n\nTodo esto en la red TRON, una de las blockchains más rápidas y económicas del mercado.',
                icon: Icons.info_outline_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.md),
              _HelpSection(
                title: 'Enviar USDT',
                content:
                    'Para enviar USDT a otra wallet:\n\n1. Toca el botón de envío en la parte inferior\n2. Ingresa la cantidad que deseas enviar\n3. Ingresa la dirección de destino o escanea un código QR\n4. Confirma la transacción\n\nRecibirás un comprobante que puedes descargar o compartir.',
                icon: Icons.send_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.md),
              _HelpSection(
                title: 'Recibir USDT',
                content:
                    'Para recibir USDT:\n\n1. Ve a la sección "Recibir" desde el dashboard\n2. Muestra tu código QR o comparte tu dirección de wallet\n3. El remitente escanea el código o envía a tu dirección\n\nTu balance se actualizará automáticamente cuando recibas los fondos.',
                icon: Icons.qr_code_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.md),
              _HelpSection(
                title: 'Staking',
                content:
                    'El staking te permite ganar intereses sobre tus USDT:\n\n1. Ve a la sección "Staking"\n2. Toca "Crear Stake"\n3. Ingresa la cantidad que deseas stakear\n4. Verás las ganancias estimadas\n5. Puedes cerrar tu stake en cualquier momento para recuperar tu capital más las recompensas.',
                icon: Icons.account_balance_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.md),
              _HelpSection(
                title: 'Comprar USDT',
                content:
                    'Para comprar USDT con Bolivianos:\n\n1. Ve a "Comprar USDT" desde el dashboard\n2. Ingresa la cantidad de USDT que deseas comprar\n3. Verás el equivalente en Bolivianos\n4. Escanea el código QR para realizar el pago\n5. Una vez confirmado el pago, recibirás los USDT en tu balance.',
                icon: Icons.shopping_cart_outlined,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.md),
              _HelpSection(
                title: 'Seguridad',
                content:
                    'Tu seguridad es nuestra prioridad:\n\n• Nunca compartas tu contraseña\n• Verifica siempre las direcciones antes de enviar\n• Mantén tu aplicación actualizada\n• Usa contraseñas seguras y cámbialas regularmente\n• Las transacciones son inmutables una vez confirmadas\n• Puedes cambiar tu contraseña desde Configuración en tu perfil',
                icon: Icons.security_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.md),
              _HelpSection(
                title: 'Gestión de Perfil',
                content:
                    'En tu perfil puedes:\n\n• Ver tu información personal y de cuenta\n• Consultar tu dirección de wallet y balances\n• Acceder a Configuración para cambiar tu contraseña\n• Ver esta guía de ayuda cuando lo necesites\n• Cerrar sesión de forma segura',
                icon: Icons.person_outline_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.md),
              _HelpSection(
                title: 'Soporte',
                content:
                    '¿Necesitas ayuda adicional?\n\n• Revisa esta sección de ayuda para guías detalladas\n• Verifica que tu conexión a internet esté activa\n• Asegúrate de tener la última versión de la app\n• Las transacciones pueden tardar unos minutos en confirmarse\n\nCuñaPay está diseñado para ser intuitivo y fácil de usar.',
                icon: Icons.support_agent_outlined,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool isDark;

  const _HelpSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

