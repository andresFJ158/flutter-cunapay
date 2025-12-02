import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'profile_info_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                user?['email'] ?? 'Usuario',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _ProfileTile(
                icon: Icons.person_outline_rounded,
                title: 'Información',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileInfoScreen(),
                    ),
                  );
                },
              ),
              _ProfileTile(
                icon: Icons.settings_outlined,
                title: 'Configuración',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              _ProfileTile(
                icon: Icons.help_outline_rounded,
                title: 'Ayuda',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Mostrar diálogo de confirmación
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          backgroundColor: isDark ? const Color(0xFF252940) : AppColors.backgroundLight,
                          title: Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              color: isDark ? AppColors.textPrimary : AppColors.textDark,
                            ),
                          ),
                          content: Text(
                            '¿Estás seguro de que deseas cerrar sesión?',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: AppColors.textPrimary,
                              ),
                              child: const Text('Cerrar Sesión'),
                            ),
                          ],
                        );
                      },
                    );
                    
                    if (confirmed == true && context.mounted) {
                      // Cerrar sesión y forzar actualización del router
                      await authProvider.logout();
                      if (context.mounted) {
                        // Forzar navegación al login y limpiar el stack
                        context.go('/login');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cerrar Sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

