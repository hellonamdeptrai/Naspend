import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:naspend/data/datasources/local/database.dart';
import 'package:naspend/data/model/transaction_with_category.dart';

class NoteViewModel extends ChangeNotifier {
  final AppDatabase _database;
  final TransactionWithCategory? initialTransaction;

  late final Stream<List<Category>> expenseCategoriesStream;
  late final Stream<List<Category>> incomeCategoriesStream;

  NoteViewModel(this._database, {this.initialTransaction}) {
    expenseCategoriesStream = _database.watchCategoriesByType(TransactionType.expense);
    incomeCategoriesStream = _database.watchCategoriesByType(TransactionType.income);

    if (isEditMode) {
      _loadDataForEdit();
    }
  }

  bool get isEditMode => initialTransaction != null;

  final TextEditingController noteController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  Category? _selectedCard;
  Category? get selectedCard => _selectedCard;

  final List<Tab> tabs = <Tab>[
    Tab(text: 'Chi tiêu'),
    Tab(text: 'Thu nhập'),
  ];

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;
  String get formattedDate => DateFormat('dd/MM/yyyy (E)', 'vi_VN').format(_selectedDate);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('vi', 'VN'),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      notifyListeners();
    }
  }

  void nextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }

  void previousDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  void selectCard(Category tappedCard) {
    _selectedCard = tappedCard;
    notifyListeners();
  }

  void clearForm() {
    noteController.clear();
    amountController.clear();
    _selectedCard = null;
    notifyListeners();
  }

  void _loadDataForEdit() {
    amountController.text = initialTransaction!.transaction.amount.toStringAsFixed(0);
    noteController.text = initialTransaction!.transaction.note ?? '';
    _selectedDate = initialTransaction!.transaction.transactionDate;
    _selectedCard = initialTransaction!.category;
  }

  Future<void> saveTransaction({required TransactionType type}) async {
    final amountText = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (amountText.isEmpty) throw Exception('Vui lòng nhập số tiền.');
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) throw Exception('Số tiền không hợp lệ.');
    if (_selectedCard == null) throw Exception('Vui lòng chọn một danh mục.');

    if (isEditMode) {
      // --- CHẾ ĐỘ SỬA ---
      final updatedTransaction = TransactionsCompanion(
        id: Value(initialTransaction!.transaction.id),
        amount: Value(amount),
        transactionDate: Value(_selectedDate),
        note: Value(noteController.text.trim()),
        categoryId: Value(_selectedCard!.id),
        type: Value(initialTransaction!.transaction.type), // Giữ nguyên type
      );
      await _database.updateTransaction(updatedTransaction);
    } else {
      // --- CHẾ ĐỘ THÊM MỚI ---
      final newTransaction = TransactionsCompanion(
        amount: Value(amount),
        transactionDate: Value(_selectedDate),
        note: Value(noteController.text.trim()),
        categoryId: Value(_selectedCard!.id),
        type: Value(type),
      );
      await _database.insertTransaction(newTransaction);
      clearForm(); // Chỉ xóa form khi thêm mới
    }
  }

  Future<void> deleteTransaction(BuildContext context) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
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
        await _database.deleteTransaction(initialTransaction!.transaction.id);
        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa giao dịch thành công!'),
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

  @override
  void dispose() {
    noteController.dispose();
    amountController.dispose();
    super.dispose();
  }
}