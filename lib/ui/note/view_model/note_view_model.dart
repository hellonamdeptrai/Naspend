import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naspend/data/datasources/local/database.dart';

class NoteViewModel extends ChangeNotifier {
  final AppDatabase _database;
  final TransactionWithCategory? initialTransaction;

  NoteViewModel(this._database, {this.initialTransaction}) {
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
    final amountText = amountController.text.trim();
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

  Stream<List<Category>> get expenseCategoriesStream =>
      _database.watchCategoriesByType(TransactionType.expense);

  Stream<List<Category>> get incomeCategoriesStream =>
      _database.watchCategoriesByType(TransactionType.income);

  Future<void> deleteTransaction() => _database.deleteTransaction(initialTransaction!.transaction.id);

  @override
  void dispose() {
    noteController.dispose();
    amountController.dispose();
    super.dispose();
  }
}