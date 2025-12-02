import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/wallet/presentation/dashboard_screen.dart';
import '../../features/wallet/presentation/send_screen.dart';
import '../../features/staking/presentation/staking_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/transactions/presentation/transactions_filter_screen.dart';
import '../../features/news/presentation/news_list_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/news/presentation/news_detail_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/register';
        
        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }
        
        if (isAuthenticated && isLoginRoute) {
          return '/home';
        }
      } catch (e) {
        // Si hay error accediendo al provider, redirigir al login
        return '/login';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: 'send',
            builder: (context, state) => const SendScreen(),
          ),
          GoRoute(
            path: 'staking',
            builder: (context, state) => const StakingScreen(),
          ),
          GoRoute(
            path: 'transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: 'transactions-filter',
            builder: (context, state) => const TransactionsFilterScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'news',
            builder: (context, state) => const NewsListScreen(),
            routes: [
              // Nota: El detalle de noticia ahora recibe la noticia completa desde la lista
              // La ruta detail/:id fue eliminada porque el endpoint getNewsById no existe
              // Nota: La ruta de crear noticia fue eliminada porque requiere rol Admin
              // Los usuarios normales solo pueden leer noticias
            ],
          ),
        ],
      ),
    ],
  );
}

