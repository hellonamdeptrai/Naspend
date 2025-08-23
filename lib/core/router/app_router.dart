import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naspend/core/router/app_routes.dart';
import 'package:naspend/data/datasources/local/database.dart';
import 'package:naspend/ui/category/view/add_category_screen.dart';
import 'package:naspend/ui/category/view/category_screen.dart';
import 'package:naspend/ui/category/view_model/add_category_view_model.dart';
import 'package:naspend/ui/home/view/home_screen.dart';
import 'package:naspend/ui/note/view/note_screen.dart';
import 'package:naspend/ui/note/view_model/note_view_model.dart';
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
          final extra = state.extra;

          Category? initialCategory;
          TransactionType type = TransactionType.expense;

          if (extra is Category) {
            initialCategory = extra;
          } else if (extra is TransactionType) {
            type = extra;
          }

          return ChangeNotifierProvider(
            create: (context) => AddCategoryViewModel(
              context.read<AppDatabase>(),
              initialCategory: initialCategory,
              type: type,
            ),
            child: const AddCategoryScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editTransaction,
        builder: (context, state) {
          final transaction = state.extra as TransactionWithCategory?;
          if (transaction == null) {
            return const Scaffold(body: Center(child: Text('Lỗi: Không tìm thấy giao dịch')));
          }

          return ChangeNotifierProvider(
            create: (context) => NoteViewModel(
              context.read<AppDatabase>(),
              initialTransaction: transaction,
            ),
            child: const NoteScreen(),
          );
        },
      ),
    ],
  );
}