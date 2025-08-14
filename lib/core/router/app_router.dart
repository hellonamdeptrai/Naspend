import 'package:go_router/go_router.dart';
import 'package:naspend/core/router/app_routes.dart';
import 'package:naspend/data/datasources/local/database.dart';
import 'package:naspend/ui/category/view/add_category_screen.dart';
import 'package:naspend/ui/category/view/category_screen.dart';
import 'package:naspend/ui/category/view_model/add_category_view_model.dart';
import 'package:naspend/ui/home/view/home_screen.dart';
import 'package:provider/provider.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.category,
        builder: (context, state) {
          return const CategoryScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.addCategory,
        builder: (context, state) {
          final type = state.extra as TransactionType? ?? TransactionType.expense;

          return ChangeNotifierProvider(
            create: (context) => AddCategoryViewModel(
              context.read<AppDatabase>(),
              type
            ),
            child: const AddCategoryScreen(),
          );
        },
      ),
    ],
  );
}