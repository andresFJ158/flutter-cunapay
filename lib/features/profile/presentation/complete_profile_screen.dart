import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Pantalla para completar el perfil del usuario
/// Permite agregar número de cuenta bancaria y entidad bancaria
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankAccountNumberController = TextEditingController();
  final _bankEntityController = TextEditingController();
  bool _isSaving = false;
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _bankAccountNumberController.dispose();
    _bankEntityController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final response = await ApiService().getMe();
      if (mounted) {
        setState(() {
          _userInfo = response.data;
          _bankAccountNumberController.text = response.data['bankAccountNumber'] ?? '';
          _bankEntityController.text = response.data['bankEntity'] ?? '';
        });
      }
    } catch (e) {
      // Ignorar errores al cargar
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await ApiService().updateProfile(
        bankAccountNumber: _bankAccountNumberController.text.trim(),
        bankEntity: _bankEntityController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil completado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Retornar true para indicar que se completó
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Completar Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.textPrimary : AppColors.textDark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                // Alerta informativa
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.info,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Completa tu perfil para poder retirar USDT a tu cuenta bancaria',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Número de cuenta bancaria
                TextFormField(
                  controller: _bankAccountNumberController,
                  decoration: InputDecoration(
                    labelText: 'Número de Cuenta Bancaria',
                    hintText: 'Ej: 1234567890',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF252940) : AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu número de cuenta bancaria';
                    }
                    if (value.trim().length < 8) {
                      return 'El número de cuenta debe tener al menos 8 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                // Entidad bancaria
                TextFormField(
                  controller: _bankEntityController,
                  decoration: InputDecoration(
                    labelText: 'Entidad Bancaria',
                    hintText: 'Ej: Banco Nacional de Bolivia',
                    prefixIcon: Icon(Icons.account_balance_outlined, color: AppColors.primary),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF252940) : AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu entidad bancaria';
                    }
                    if (value.trim().length < 3) {
                      return 'Ingresa un nombre válido de entidad bancaria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                            ),
                          )
                        : const Text(
                            'Guardar Perfil',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

