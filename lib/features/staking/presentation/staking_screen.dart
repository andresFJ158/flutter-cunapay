import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/design_system/transaction_input_screen.dart';
import '../../../shared/widgets/staking_skeleton.dart';
import '../../../shared/widgets/design_system/transaction_header.dart';
import '../../../shared/widgets/common/info_dialog.dart';

class StakingScreen extends StatefulWidget {
  const StakingScreen({super.key});

  @override
  State<StakingScreen> createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen> {
  List<dynamic> _stakes = [];
  Map<String, dynamic>? _balance;
  bool _isLoading = true;
  double _defaultDailyRate = 0.5; // Tasa diaria por defecto en porcentaje (0.5%)
  String _filterType = 'active'; // 'active' o 'closed'

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
          final stakesData = results[0].data ?? [];
          _stakes = List.from(stakesData);
          _balance = results[1].data;
          
          // Obtener la tasa diaria del primer stake activo si existe
          if (_stakes.isNotEmpty) {
            final firstActiveStake = _stakes.firstWhere(
              (s) => _isStakeActive(s),
              orElse: () => _stakes.first,
            );
            final rate = firstActiveStake['dailyRateBp'] ?? 
                        firstActiveStake['daily_rate_bp'] ?? 50;
            _defaultDailyRate = (rate is num) ? rate.toDouble() / 100 : 0.5;
          }
          
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

  bool _isStakeActive(dynamic stake) {
    // Verificar si el stake está activo
    final status = stake['status'] ?? stake['Status'];
    final closedAt = stake['closedAt'] ?? stake['closed_at'];
    
    if (status != null) {
      return status.toString().toLowerCase() == 'active' || 
             status.toString().toLowerCase() == 'activo';
    }
    
    // Si no hay status, considerar activo si no tiene closedAt
    return closedAt == null;
  }

  String _formatBalance(num? balance) {
    if (balance == null) return '0.00';
    return balance.toStringAsFixed(2);
  }

  double _getTotalStaked() {
    double total = 0.0;
    for (var stake in _stakes) {
      if (_isStakeActive(stake)) {
        final amount = stake['amountUsdt'] ?? stake['amount_usdt'] ?? 0.0;
        total += (amount is num) ? amount.toDouble() : 0.0;
      }
    }
    return total;
  }

  List<dynamic> _getActiveStakes() {
    return _stakes.where((s) => _isStakeActive(s)).toList();
  }

  List<dynamic> _getClosedStakes() {
    return _stakes.where((s) => !_isStakeActive(s)).toList();
  }

  double _calculateAccumulatedInterest(dynamic stake) {
    try {
      final amount = stake['amountUsdt'] ?? stake['amount_usdt'] ?? 0.0;
      final amountNum = (amount is num) ? amount.toDouble() : 0.0;
      
      final dailyRate = stake['dailyRateBp'] ?? stake['daily_rate_bp'] ?? 50;
      final dailyRateNum = (dailyRate is num) ? dailyRate.toDouble() : 50.0;
      final dailyRatePercent = dailyRateNum / 100; // Convertir basis points a porcentaje
      
      // Obtener fecha de creación
      DateTime? createdAt;
      final createdAtField = stake['createdAt'] ?? stake['created_at'];
      if (createdAtField is String) {
        createdAt = DateTime.parse(createdAtField);
      } else if (createdAtField is int) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtField);
      }
      
      if (createdAt == null) return 0.0;
      
      // Calcular días transcurridos
      final now = DateTime.now();
      final daysElapsed = now.difference(createdAt).inDays;
      
      // Calcular interés acumulado (interés simple diario)
      final dailyInterest = amountNum * (dailyRatePercent / 100);
      final accumulatedInterest = dailyInterest * daysElapsed;
      
      return accumulatedInterest;
    } catch (e) {
      return 0.0;
    }
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
        Navigator.pop(context);
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
          dailyRate: _defaultDailyRate,
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
    final activeStakes = _getActiveStakes();
    final closedStakes = _getClosedStakes();

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
          ? const StakingSkeleton()
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
                          // Filtros
                          if (_stakes.isNotEmpty)
                            Row(
                              children: [
                                Expanded(
                                  child: _FilterChip(
                                    label: 'Stakes Activos',
                                    isSelected: _filterType == 'active',
                                    count: activeStakes.length,
                                    onTap: () => setState(() => _filterType = 'active'),
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _FilterChip(
                                    label: 'Stakes Cerrados',
                                    isSelected: _filterType == 'closed',
                                    count: closedStakes.length,
                                    onTap: () => setState(() => _filterType = 'closed'),
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Lista de stakes o información
                  if (_stakes.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _StakingInfoWidget(
                        isDark: isDark,
                        dailyRate: _defaultDailyRate,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final filteredStakes = _filterType == 'active' ? activeStakes : closedStakes;
                            
                            if (filteredStakes.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.only(top: AppSpacing.xl),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inbox_rounded,
                                        size: 64,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        'No hay ${_filterType == 'active' ? 'stakes activos' : 'stakes cerrados'}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            final stake = filteredStakes[index];
                            final isActive = _filterType == 'active';
                            
                            return Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.md),
                              child: _StakeCard(
                                stake: stake,
                                isDark: isDark,
                                isActive: isActive,
                                accumulatedInterest: _calculateAccumulatedInterest(stake),
                                onClose: isActive
                                    ? () => _closeStake(stake['id'] ?? stake['_id'])
                                    : null,
                              ),
                            );
                          },
                          childCount: _filterType == 'active' ? activeStakes.length : closedStakes.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.count,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF252940) : AppColors.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.textSecondary.withValues(alpha: 0.3) : AppColors.textSecondary.withValues(alpha: 0.2)),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.textPrimary
                    : (isDark ? AppColors.textPrimary : AppColors.textDark),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.textPrimary.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
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
  final bool isActive;
  final double accumulatedInterest;
  final VoidCallback? onClose;

  const _StakeCard({
    required this.stake,
    required this.isDark,
    required this.isActive,
    required this.accumulatedInterest,
    this.onClose,
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
    final closedAt = stake['closedAt'] ?? stake['closed_at'];

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppColors.secondary.withValues(alpha: 0.3)
              : AppColors.textSecondary.withValues(alpha: 0.3),
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
                    Row(
                      children: [
                        Text(
                          '${amountNum.toStringAsFixed(2)} USDT',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimary : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.secondary.withValues(alpha: 0.2)
                                : AppColors.textSecondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isActive ? 'Activo' : 'Finalizado',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isActive ? AppColors.secondary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
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
              if (isActive && onClose != null)
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
          const SizedBox(height: 12),
          // Interés acumulado
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interés acumulado',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${accumulatedInterest.toStringAsFixed(2)} USDT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          if (closedAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Cerrado: ${_formatDate(closedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StakingInfoWidget extends StatelessWidget {
  final bool isDark;
  final double dailyRate;

  const _StakingInfoWidget({
    required this.isDark,
    required this.dailyRate,
  });

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
          // Información sobre interés diario
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondary,
                  AppColors.secondary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.percent_rounded,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interés Diario',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                    Text(
                      '${dailyRate.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

class _CreateStakeScreen extends StatefulWidget {
  final double maxAmount;
  final double dailyRate;
  final Function(String) onCreateStake;

  const _CreateStakeScreen({
    required this.maxAmount,
    required this.dailyRate,
    required this.onCreateStake,
  });

  @override
  State<_CreateStakeScreen> createState() => _CreateStakeScreenState();
}

class _CreateStakeScreenState extends State<_CreateStakeScreen> {
  String _amount = '';
  double _estimatedEarnings = 0.0;
  double _dailyEarning = 0.0;

  void _calculateEarnings(String amount) {
    final amountNum = double.tryParse(amount) ?? 0.0;
    if (amountNum > 0) {
      // Calcular ganancias estimadas para diferentes períodos
      // Interés diario simple
      final dailyEarning = amountNum * (widget.dailyRate / 100);
      // Mostrar estimado para 30 días
      setState(() {
        _dailyEarning = dailyEarning;
        _estimatedEarnings = dailyEarning * 30;
      });
    } else {
      setState(() {
        _dailyEarning = 0.0;
        _estimatedEarnings = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasValidAmount = _amount.isNotEmpty && 
                          double.tryParse(_amount) != null && 
                          double.parse(_amount) > 0;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header personalizado con botón de información
            TransactionHeader(
              title: 'Crear Stake',
              onMenu: () => InfoDialog.showStakingInfo(context),
            ),
            
            // Balance y Estimador lado a lado
            Padding(
              padding: EdgeInsets.all(AppSpacing.screenHorizontal),
              child: Row(
                children: [
                  // Balance disponible
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Disponible',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.maxAmount.toStringAsFixed(2)} USDT',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Estimador de ganancias
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.secondary,
                            AppColors.secondary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calculate_rounded,
                                color: AppColors.textPrimary,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Estimado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (hasValidAmount)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_dailyEarning.toStringAsFixed(2)} USDT/día',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${_estimatedEarnings.toStringAsFixed(2)} USDT/mes',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textPrimary.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              'Ingresa monto',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary.withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Pantalla de entrada de transacción
            Expanded(
              child: TransactionInputScreen(
          title: 'Crear Stake',
          currencyCode: 'USDT',
                balance: '${widget.maxAmount.toStringAsFixed(2)} USDT',
          currencySymbol: '\$',
                buttonText: 'Crear Stake',
          showDecimal: true,
                maxAmount: widget.maxAmount,
                hideBalance: true, // Ocultar balance aquí ya que está arriba
                hideHeader: true, // Ocultar header aquí ya que está arriba
                showAmountInput: false, // Ocultar input de monto
                onAmountChanged: (amount) {
                  setState(() {
                    _amount = amount;
                  });
                  _calculateEarnings(amount);
                },
                onContinue: widget.onCreateStake,
                onInfoTap: () => InfoDialog.showStakingInfo(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
