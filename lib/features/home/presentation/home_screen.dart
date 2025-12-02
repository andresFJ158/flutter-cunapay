import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../wallet/presentation/dashboard_screen.dart';
import '../../wallet/presentation/send_screen.dart';
import '../../news/presentation/news_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocation = GoRouterState.of(context).matchedLocation;

    Widget currentScreen;
    if (currentLocation == '/home' || currentLocation == '/home/dashboard') {
      currentScreen = const DashboardScreen();
    } else if (currentLocation == '/home/send') {
      currentScreen = const SendScreen();
    } else if (currentLocation == '/home/news') {
      currentScreen = const NewsListScreen();
    } else {
      currentScreen = const DashboardScreen();
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: currentScreen,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                blurRadius: 24,
                offset: const Offset(0, -8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: _BottomNavigation(),
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none, // Permite que el botón flotante sobresalga
      alignment: Alignment.center,
      children: [
        // Contenedor del menú
        Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_rounded,
                label: 'Home',
                route: '/home/dashboard',
                isActive: currentLocation == '/home' || currentLocation == '/home/dashboard',
                isDark: isDark,
              ),
              // Espacio para el botón central sobresalido
              const SizedBox(width: 56),
              _NavItem(
                icon: Icons.article_rounded,
                label: 'Noticias',
                route: '/home/news',
                isActive: currentLocation == '/home/news',
                isDark: isDark,
              ),
            ],
          ),
        ),
        // Botón central sobresalido - mitad dentro, mitad fuera hacia arriba (z-index superior)
        Positioned(
          top: -28, // La mitad del botón (28px de 56px) está fuera hacia arriba
          child: Material(
            elevation: 8, // Elevación para z-index visual
            shadowColor: AppColors.primary.withValues(alpha: 0.5),
            shape: const CircleBorder(),
            child: _FloatingSendButton(
              isActive: currentLocation == '/home/send',
              isDark: isDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.isDark,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        context.go(widget.route);
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, // Botones aún más pequeños
              height: 36,
              decoration: BoxDecoration(
                color: widget.isActive
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: widget.isActive 
                    ? AppColors.primary 
                    : (widget.isDark ? AppColors.textSecondary : const Color(0xFF8A8A8A)),
                size: 20, // Iconos más pequeños
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 9.5, // Texto aún más pequeño
                fontWeight: FontWeight.w500,
                color: widget.isActive 
                    ? AppColors.primary 
                    : (widget.isDark ? AppColors.textSecondary : const Color(0xFF8A8A8A)),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingSendButton extends StatefulWidget {
  final bool isActive;
  final bool isDark;

  const _FloatingSendButton({
    required this.isActive,
    required this.isDark,
  });

  @override
  State<_FloatingSendButton> createState() => _FloatingSendButtonState();
}

class _FloatingSendButtonState extends State<_FloatingSendButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        context.go('/home/send');
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 56, // Tamaño del botón flotante
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary, // #00A86B según especificación
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.send_rounded,
            color: AppColors.textPrimary, // White según especificación
            size: 24,
          ),
        ),
      ),
    );
  }
}

