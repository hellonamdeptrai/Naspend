import 'package:flutter/material.dart';
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

  // Hàm để xóa một category (ví dụ)
  Future<void> deleteCategory(int id) {
    return _database.deleteCategory(id);
  }
}