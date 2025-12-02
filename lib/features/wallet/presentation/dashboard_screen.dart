import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/dashboard_skeleton.dart';
import 'deposit_screen.dart';
import 'receive_screen.dart';
import '../../staking/presentation/staking_screen.dart';
import '../../transactions/presentation/transactions_filter_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _balance;
  List<dynamic> _transactions = [];
  bool _isLoadingBalance = true;
  bool _isLoadingTransactions = true;

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _loadTransactions();
  }

  Future<void> _loadBalance() async {
    try {
      final response = await ApiService().getBalance();
      if (mounted) {
        setState(() {
          _balance = response.data;
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBalance = false);
      }
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoadingTransactions = true);
    try {
      final response = await ApiService().getTransactions(source: 'db', limit: 10);
      if (mounted) {
        setState(() {
          _transactions = List.from(response.data['items'] ?? []);
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTransactions = false);
      }
    }
  }

  String _formatBalance(num? balance) {
    if (balance == null) return '0.00';
    return balance.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = _isLoadingBalance || _isLoadingTransactions;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: isLoading
          ? const DashboardSkeleton()
          : RefreshIndicator(
              onRefresh: () async {
                await _loadBalance();
                await _loadTransactions();
              },
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: false,
                    pinned: true,
                    backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.person_rounded),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ),
                    ),
                    title: Text(
                      'CuñaPay',
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimary : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.screenHorizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          // Balance Card
                          Container(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Balance Disponible',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_formatBalance(_balance?['available'])} USDT',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textPrimary.withValues(alpha: 0.8),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_formatBalance(_balance?['usdt'])} USDT',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: AppColors.textPrimary.withValues(alpha: 0.2),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'En Staking',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textPrimary.withValues(alpha: 0.8),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_formatBalance(_balance?['locked_in_staking'])} USDT',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.add_rounded,
                                  label: 'Comprar USDT',
                                  color: AppColors.primary,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const DepositScreen()),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.qr_code_rounded,
                                  label: 'Recibir',
                                  color: AppColors.info,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ReceiveScreen()),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.account_balance_rounded,
                                  label: 'Staking',
                                  color: AppColors.secondary,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const StakingScreen()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          // Transacciones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Transacciones',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push('/home/transactions-filter'),
                                child: const Text('Ver todas'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _transactions.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(AppSpacing.xl),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.history_rounded,
                                          size: 64,
                                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                        Text(
                                          'No hay transacciones',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: _transactions.take(5).map((tx) {
                                    final amount = tx['amount_usdt'] ?? tx['amountUsdt'] ?? 0.0;
                                    final direction = tx['direction'] ?? 'out';
                                    final isIncoming = direction == 'in';
                                    
                                    DateTime? dateTime;
                                    try {
                                      if (tx['timestamp'] != null) {
                                        dateTime = DateTime.fromMillisecondsSinceEpoch(tx['timestamp'] as int);
                                      } else if (tx['created_at'] != null || tx['createdAt'] != null) {
                                        dateTime = DateTime.parse(tx['created_at'] ?? tx['createdAt']);
                                      }
                                    } catch (e) {
                                      dateTime = DateTime.now();
                                    }
                                    dateTime ??= DateTime.now();

                                    return Padding(
                                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                                      child: _TransactionItem(
                                        amount: amount,
                                        isIncoming: isIncoming,
                                        dateTime: dateTime,
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimary : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final double amount;
  final bool isIncoming;
  final DateTime dateTime;

  const _TransactionItem({
    required this.amount,
    required this.isIncoming,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Colores diferenciados: verde para recibir, rojo/naranja para enviar
    final transactionColor = isIncoming ? AppColors.success : AppColors.error;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: transactionColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: transactionColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: transactionColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              isIncoming ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: transactionColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIncoming ? 'Recibiste' : 'Enviaste',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncoming ? '+' : '-'}${amount.toStringAsFixed(2)} USDT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: transactionColor,
            ),
          ),
        ],
      ),
    );
  }
}

