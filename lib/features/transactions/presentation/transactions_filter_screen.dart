import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class TransactionsFilterScreen extends StatefulWidget {
  const TransactionsFilterScreen({super.key});

  @override
  State<TransactionsFilterScreen> createState() => _TransactionsFilterScreenState();
}

class _TransactionsFilterScreenState extends State<TransactionsFilterScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String _source = 'db';
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      // Aumentar el límite para asegurar que se obtengan todas las transacciones necesarias para el filtrado
      final response = await ApiService().getTransactions(source: _source, limit: 1000);
      
      if (!mounted) return;
      
      List<dynamic> allTransactions;
      if (_source == 'db') {
        allTransactions = List.from(response.data['items'] ?? []);
      } else {
        // Para onchain, el backend devuelve OnChainTransactionsDto con campo "items"
        allTransactions = List.from(response.data['items'] ?? []);
      }

      // Filtrar por fechas si están seleccionadas
      if (_dateFrom != null || _dateTo != null) {
        allTransactions = allTransactions.where((tx) {
          DateTime? txDate;
          try {
            // Intentar diferentes formatos de fecha
            if (tx['timestamp'] != null) {
              // Si es un número (timestamp en milisegundos o segundos)
              final timestamp = tx['timestamp'];
              if (timestamp is int) {
                // Si el timestamp es muy grande, está en milisegundos, si no, en segundos
                txDate = timestamp > 1000000000000 
                    ? DateTime.fromMillisecondsSinceEpoch(timestamp)
                    : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
              } else if (timestamp is String) {
                final parsed = int.tryParse(timestamp);
                if (parsed != null) {
                  txDate = parsed > 1000000000000 
                      ? DateTime.fromMillisecondsSinceEpoch(parsed)
                      : DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
                }
              }
            } else if (tx['created_at'] != null) {
              final createdAt = tx['created_at'];
              if (createdAt is String) {
                try {
                  txDate = DateTime.parse(createdAt);
                } catch (e) {
                  // Si falla el parse, intentar como timestamp
                  final parsed = int.tryParse(createdAt);
                  if (parsed != null) {
                    txDate = parsed > 1000000000000 
                        ? DateTime.fromMillisecondsSinceEpoch(parsed)
                        : DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
                  }
                }
              } else if (createdAt is int) {
                txDate = createdAt > 1000000000000 
                    ? DateTime.fromMillisecondsSinceEpoch(createdAt)
                    : DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
              }
            } else if (tx['createdAt'] != null) {
              final createdAt = tx['createdAt'];
              if (createdAt is String) {
                try {
                  txDate = DateTime.parse(createdAt);
                } catch (e) {
                  // Si falla el parse, intentar como timestamp
                  final parsed = int.tryParse(createdAt);
                  if (parsed != null) {
                    txDate = parsed > 1000000000000 
                        ? DateTime.fromMillisecondsSinceEpoch(parsed)
                        : DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
                  }
                }
              } else if (createdAt is int) {
                txDate = createdAt > 1000000000000 
                    ? DateTime.fromMillisecondsSinceEpoch(createdAt)
                    : DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
              }
            }
          } catch (e) {
            // Si hay error parseando, excluir la transacción del filtro
            return false;
          }
          
          if (txDate == null) return false;
          
          // Normalizar fechas a medianoche para comparación solo por día
          final dateOnly = DateTime(txDate.year, txDate.month, txDate.day);
          final fromDate = _dateFrom != null 
              ? DateTime(_dateFrom!.year, _dateFrom!.month, _dateFrom!.day)
              : null;
          final toDate = _dateTo != null
              ? DateTime(_dateTo!.year, _dateTo!.month, _dateTo!.day)
              : null;

          // Filtrar: incluir si está dentro del rango (inclusive en ambos extremos)
          // Si hay fecha desde, la transacción debe ser >= fromDate
          if (fromDate != null && dateOnly.isBefore(fromDate)) {
            return false;
          }
          // Si hay fecha hasta, la transacción debe ser <= toDate
          if (toDate != null && dateOnly.isAfter(toDate)) {
            return false;
          }
          
          return true;
        }).toList();
      }

      if (mounted) {
        setState(() {
          _transactions = allTransactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Mostrar error al usuario
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar transacciones: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _selectDateFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        _dateFrom = picked;
      });
      _loadTransactions();
    }
  }

  Future<void> _selectDateTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? (_dateFrom ?? DateTime.now()),
      firstDate: _dateFrom ?? DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && mounted) {
      // Validar que la fecha "hasta" no sea anterior a la fecha "desde"
      if (_dateFrom != null && picked.isBefore(_dateFrom!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La fecha "Hasta" no puede ser anterior a la fecha "Desde"'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      setState(() {
        _dateTo = picked;
      });
      _loadTransactions();
    }
  }

  void _clearFilters() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
    });
    _loadTransactions();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'broadcasted':
        return AppColors.warning;
      case 'pending':
        return AppColors.info;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmada';
      case 'broadcasted':
        return 'Enviada';
      case 'pending':
        return 'Pendiente';
      case 'failed':
        return 'Fallida';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'broadcasted':
        return Icons.send_rounded;
      case 'pending':
        return Icons.access_time_rounded;
      case 'failed':
        return Icons.error_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Transacciones',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        foregroundColor: isDark ? AppColors.textPrimary : AppColors.textDark,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  (isDark ? AppColors.textPrimary : AppColors.textDark).withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtros - Diseño mejorado
          Container(
            margin: EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.md,
              AppSpacing.screenHorizontal,
              AppSpacing.sm,
            ),
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252940) : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (isDark ? AppColors.textPrimary : AppColors.textDark).withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Selector de fuente - Diseño mejorado
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2130) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSourceButton(
                          'Base de Datos',
                          'db',
                          Icons.storage_rounded,
                          theme,
                          isDark,
                        ),
                      ),
                      Expanded(
                        child: _buildSourceButton(
                          'Blockchain',
                          'onchain',
                          Icons.link_rounded,
                          theme,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Filtros de fecha - Diseño mejorado
                Row(
                  children: [
                    Expanded(
                      child: _buildDateFilter(
                        label: 'Desde',
                        date: _dateFrom,
                        onTap: _selectDateFrom,
                        theme: theme,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildDateFilter(
                        label: 'Hasta',
                        date: _dateTo,
                        onTap: _selectDateTo,
                        theme: theme,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                if (_dateFrom != null || _dateTo != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _clearFilters,
                      icon: Icon(
                        Icons.clear_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        'Limpiar filtros',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Lista de transacciones
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTransactions,
                    color: AppColors.primary,
                    backgroundColor: isDark ? const Color(0xFF252940) : Colors.white,
                    child: _transactions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.history_rounded,
                                      size: 64,
                                      color: AppColors.primary.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Text(
                                    'No hay transacciones',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textPrimary : AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Tus transacciones aparecerán aquí',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                              vertical: AppSpacing.sm,
                            ),
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final tx = _transactions[index];
                              final status = tx['status'] ?? 
                                  (tx['confirmed'] == true ? 'confirmed' : 'pending');
                              final amount = tx['amount_usdt'] ?? tx['amountUsdt'] ?? 0.0;
                              final direction = tx['direction'] ?? 'out';
                              final isIncoming = direction == 'in';
                              
                              return Padding(
                                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                                child: _buildTransactionCard(tx, status, amount, isIncoming, theme, isDark),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton(String label, String value, IconData icon, ThemeData theme, bool isDark) {
    final isSelected = _source == value;
    return InkWell(
      onTap: () {
        setState(() {
          _source = value;
        });
        _loadTransactions();
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2130) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: date != null
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : (isDark ? AppColors.textPrimary : AppColors.textDark).withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                date != null
                    ? DateFormat('dd/MM/yyyy').format(date)
                    : 'Seleccionar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: date != null
                      ? (isDark ? AppColors.textPrimary : AppColors.textDark)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    dynamic tx,
    String status,
    double amount,
    bool isIncoming,
    ThemeData theme,
    bool isDark,
  ) {
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    final statusIcon = _getStatusIcon(status);
    
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

    // Colores mejorados según tipo de transacción
    final Color accentColor = isIncoming ? AppColors.secondary : AppColors.primary;
    final Color cardBackgroundColor = isDark
        ? const Color(0xFF252940)
        : Colors.white;
    
    final Color amountColor = isIncoming
        ? AppColors.secondary
        : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Mostrar detalles de la transacción
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icono de dirección mejorado
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor.withValues(alpha: 0.2),
                            accentColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isIncoming ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Monto y fecha
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${isIncoming ? '+' : '-'}${amount.toStringAsFixed(2)} USDT',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimary : AppColors.textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd/MM/yyyy • HH:mm').format(dateTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Estado mejorado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (tx['to'] != null || tx['toAddress'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          (isDark ? AppColors.textPrimary : AppColors.textDark).withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tx['to'] ?? tx['toAddress'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (tx['txid'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tx['txid'],
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

