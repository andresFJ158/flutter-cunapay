import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'complete_profile_screen.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final response = await ApiService().getMe();
      if (mounted) {
        setState(() {
          _userInfo = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user ?? _userInfo;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Información del Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.textPrimary : AppColors.textDark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    // Avatar
                    Center(
                      child: Container(
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
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Información del usuario
                    _InfoCard(
                      title: 'Email',
                      value: user?['email'] ?? 'N/A',
                      icon: Icons.email_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _InfoCard(
                      title: 'ID de Usuario',
                      value: user?['id']?.toString() ?? user?['userId']?.toString() ?? 'N/A',
                      icon: Icons.badge_outlined,
                      isDark: isDark,
                    ),
                    if (user?['firstName'] != null || user?['lastName'] != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      _InfoCard(
                        title: 'Nombre',
                        value: '${user?['firstName'] ?? ''} ${user?['lastName'] ?? ''}'.trim(),
                        icon: Icons.person_outline,
                        isDark: isDark,
                      ),
                    ],
                    if (user?['createdAt'] != null || user?['created_at'] != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      _InfoCard(
                        title: 'Fecha de Registro',
                        value: _formatDate(user?['createdAt'] ?? user?['created_at']),
                        icon: Icons.calendar_today_outlined,
                        isDark: isDark,
                      ),
                    ],
                    // Verificar si el perfil está incompleto
                    if (_isProfileIncomplete(user)) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.warning,
                                  size: 24,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    'Perfil Incompleto',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Completa tu perfil con tu información bancaria para poder retirar USDT',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CompleteProfileScreen(),
                                    ),
                                  );
                                  if (result == true && mounted) {
                                    // Recargar información del usuario
                                    _loadUserInfo();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                  foregroundColor: AppColors.textPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Completar Perfil'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Información bancaria si está completa
                    if (!_isProfileIncomplete(user)) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Información Bancaria',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimary : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (user?['bankAccountNumber'] != null)
                        _InfoCard(
                          title: 'Número de Cuenta',
                          value: user!['bankAccountNumber'],
                          icon: Icons.account_balance_wallet_outlined,
                          isDark: isDark,
                          onCopy: () {
                            Clipboard.setData(ClipboardData(text: user!['bankAccountNumber']));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Número de cuenta copiado'),
                                backgroundColor: AppColors.primary,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      if (user?['bankAccountNumber'] != null) const SizedBox(height: AppSpacing.md),
                      if (user?['bankEntity'] != null)
                        _InfoCard(
                          title: 'Entidad Bancaria',
                          value: user!['bankEntity'],
                          icon: Icons.account_balance_outlined,
                          isDark: isDark,
                        ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    // Información de la wallet
                    Text(
                      'Información de Wallet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FutureBuilder(
                      future: ApiService().getWallet(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data?.data != null) {
                          final wallet = snapshot.data!.data;
                          return _InfoCard(
                            title: 'Dirección de Wallet',
                            value: wallet['address'] ?? 'N/A',
                            icon: Icons.account_balance_wallet_outlined,
                            isDark: isDark,
                            onCopy: wallet['address'] != null
                                ? () {
                                    Clipboard.setData(ClipboardData(text: wallet['address']));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Dirección copiada al portapapeles'),
                                        backgroundColor: AppColors.primary,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                : null,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Información adicional
                    Text(
                      'Información Adicional',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FutureBuilder(
                      future: ApiService().getBalance(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data?.data != null) {
                          final balance = snapshot.data!.data;
                          return Column(
                            children: [
                              _InfoCard(
                                title: 'Balance Total USDT',
                                value: '${(balance['usdt'] ?? 0.0).toStringAsFixed(2)} USDT',
                                icon: Icons.account_balance_wallet_outlined,
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _InfoCard(
                                title: 'Balance Disponible',
                                value: '${(balance['available'] ?? 0.0).toStringAsFixed(2)} USDT',
                                icon: Icons.wallet_outlined,
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _InfoCard(
                                title: 'En Staking',
                                value: '${(balance['locked_in_staking'] ?? 0.0).toStringAsFixed(2)} USDT',
                                icon: Icons.trending_up_outlined,
                                isDark: isDark,
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  bool _isProfileIncomplete(Map<String, dynamic>? user) {
    if (user == null) return true;
    final bankAccountNumber = user['bankAccountNumber']?.toString().trim();
    final bankEntity = user['bankEntity']?.toString().trim();
    return bankAccountNumber == null || 
           bankAccountNumber.isEmpty || 
           bankEntity == null || 
           bankEntity.isEmpty;
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      if (date is String) {
        return DateTime.parse(date).toString().split(' ')[0];
      } else if (date is int) {
        return DateTime.fromMillisecondsSinceEpoch(date).toString().split(' ')[0];
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isDark;
  final VoidCallback? onCopy;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isDark,
    this.onCopy,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                    fontFamily: value.length > 20 ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: Icon(Icons.copy_rounded, size: 20, color: AppColors.primary),
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }
}

