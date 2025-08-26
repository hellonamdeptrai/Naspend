import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naspend/data/datasources/local/database.dart';

class CategoryViewModel extends ChangeNotifier {
  final AppDatabase _database;

  // Nhận instance của AppDatabase qua constructor
  CategoryViewModel(this._database);

  final List<Tab> tabs = <Tab>[
    Tab(text: 'Chi tiêu'),
    Tab(text: 'Thu nhập'),
  ];

// Cung cấp các stream dữ liệu cho View
  // Stream cho danh sách danh mục Chi tiêu
  Stream<List<Category>> get expenseCategoriesStream =>
      _database.watchCategoriesByType(TransactionType.expense);

  // Stream cho danh sách danh mục Thu nhập
  Stream<List<Category>> get incomeCategoriesStream =>
      _database.watchCategoriesByType(TransactionType.income);


  Future<void> deleteCategory(BuildContext context, int id) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa danh mục này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                context.pop(false);
              },
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: colors.errorContainer,
                foregroundColor: colors.onErrorContainer,
              ),
              child: const Text('Xóa'),
              onPressed: () {
                context.pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _database.deleteCategory(id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa danh mục thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}