import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/design_system/transaction_input_screen.dart';
import '../../../shared/widgets/design_system/transaction_input_skeleton.dart';

class StakingScreen extends StatefulWidget {
  const StakingScreen({super.key});

  @override
  State<StakingScreen> createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen> {
  List<dynamic> _stakes = [];
  Map<String, dynamic>? _balance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService().getStakes(),
        ApiService().getBalance(),
      ]);
      if (mounted) {
        setState(() {
          _stakes = List.from(results[0].data ?? []);
          _balance = results[1].data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatBalance(num? balance) {
    if (balance == null) return '0.00';
    return balance.toStringAsFixed(2);
  }

  double _getTotalStaked() {
    double total = 0.0;
    for (var stake in _stakes) {
      final amount = stake['amountUsdt'] ?? stake['amount_usdt'] ?? 0.0;
      total += (amount is num) ? amount.toDouble() : 0.0;
    }
    return total;
  }

  Future<void> _createStake(String amount) async {
    final amountNum = double.tryParse(amount);
    if (amountNum == null || amountNum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un monto válido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      await ApiService().createStake(amountNum);
      if (mounted) {
        Navigator.pop(context); // Cerrar el diálogo
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stake creado correctamente'),
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
    }
  }

  Future<void> _closeStake(String stakeId) async {
    // Confirmar antes de cerrar
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Stake'),
        content: const Text(
          '¿Estás seguro de que deseas cerrar este stake? Recibirás el principal más las recompensas acumuladas.',
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
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiService().closeStake(stakeId);
      if (mounted) {
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stake cerrado correctamente'),
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
    }
  }

  void _showCreateStakeScreen() {
    final available = _balance?['available'] as num? ?? 0.0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CreateStakeScreen(
          maxAmount: available.toDouble(),
          onCreateStake: _createStake,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final available = _balance?['available'] as num? ?? 0.0;
    final totalStaked = _getTotalStaked();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Staking',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.textPrimary : AppColors.textDark,
      ),
      body: _isLoading
          ? const TransactionInputSkeleton()
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.screenHorizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tarjetas de saldo
                          Row(
                            children: [
                              Expanded(
                                child: _BalanceCard(
                                  label: 'Disponible',
                                  amount: _formatBalance(available),
                                  color: AppColors.primary,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _BalanceCard(
                                  label: 'Stakeado',
                                  amount: _formatBalance(totalStaked),
                                  color: AppColors.secondary,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Botón para crear stake
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: available > 0 ? _showCreateStakeScreen : null,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Crear Stake'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                                disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          // Título de stakes
                          Text(
                            'Mis Stakes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimary : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Lista de stakes o información
                  if (_stakes.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _StakingInfoWidget(isDark: isDark),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final stake = _stakes[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.md),
                              child: _StakeCard(
                                stake: stake,
                                isDark: isDark,
                                onClose: () => _closeStake(stake['id'] ?? stake['_id']),
                              ),
                            );
                          },
                          childCount: _stakes.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final bool isDark;

  const _BalanceCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$amount USDT',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StakeCard extends StatelessWidget {
  final dynamic stake;
  final bool isDark;
  final VoidCallback onClose;

  const _StakeCard({
    required this.stake,
    required this.isDark,
    required this.onClose,
  });

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsed = DateTime.parse(date);
        return '${parsed.day}/${parsed.month}/${parsed.year}';
      } else if (date is int) {
        final parsed = DateTime.fromMillisecondsSinceEpoch(date);
        return '${parsed.day}/${parsed.month}/${parsed.year}';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = stake['amountUsdt'] ?? stake['amount_usdt'] ?? 0.0;
    final amountNum = (amount is num) ? amount.toDouble() : 0.0;
    final dailyRate = stake['dailyRateBp'] ?? stake['daily_rate_bp'] ?? 0;
    final dailyRateNum = (dailyRate is num) ? dailyRate.toDouble() : 0.0;
    final dailyRatePercent = dailyRateNum / 100; // Convertir basis points a porcentaje
    final createdAt = stake['createdAt'] ?? stake['created_at'];
    final estimatedRewards = stake['estimatedRewards'] ?? stake['estimated_rewards'] ?? 0.0;
    final estimatedRewardsNum = (estimatedRewards is num) ? estimatedRewards.toDouble() : 0.0;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${amountNum.toStringAsFixed(2)} USDT',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tasa diaria: ${dailyRatePercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Cerrar'),
              ),
            ],
          ),
          if (createdAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Creado: ${_formatDate(createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (estimatedRewardsNum > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recompensas estimadas: ${estimatedRewardsNum.toStringAsFixed(2)} USDT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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

class _StakingInfoWidget extends StatelessWidget {
  final bool isDark;

  const _StakingInfoWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 64,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '¿Qué es Staking?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoItem(
            icon: Icons.lock_rounded,
            title: 'Bloquea tus USDT',
            description: 'Mantén tus USDT bloqueados para generar recompensas pasivas.',
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoItem(
            icon: Icons.trending_up_rounded,
            title: 'Genera ingresos',
            description: 'Obtén recompensas diarias basadas en la tasa de interés configurada.',
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoItem(
            icon: Icons.security_rounded,
            title: 'Seguro y confiable',
            description: 'Tu capital está protegido y puedes cerrar tu stake en cualquier momento.',
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoItem(
            icon: Icons.attach_money_rounded,
            title: 'Beneficios',
            description: 'Recibe el principal más todas las recompensas acumuladas al cerrar tu stake.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDark;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
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
          color: AppColors.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateStakeScreen extends StatelessWidget {
  final double maxAmount;
  final Function(String) onCreateStake;

  const _CreateStakeScreen({
    required this.maxAmount,
    required this.onCreateStake,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Crear Stake'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: TransactionInputScreen(
        title: 'Crear Stake',
        currencyCode: 'USDT',
        balance: '${maxAmount.toStringAsFixed(2)} USDT',
        currencySymbol: '\$',
        buttonText: 'Crear Stake',
        showDecimal: true,
        maxAmount: maxAmount,
        compactBalance: true,
        onContinue: onCreateStake,
      ),
    );
  }
}
