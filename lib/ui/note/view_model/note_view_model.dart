import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naspend/data/datasources/local/database.dart';

class NoteViewModel extends ChangeNotifier {
  final AppDatabase _database;
  StreamSubscription? _categorySubscription;

  NoteViewModel(this._database){
    _listenToCategories();
  }

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

  void _listenToCategories() {
    _categorySubscription?.cancel();

    _categorySubscription = _database.watchAllCategories().listen((categories) {
      if (_selectedCard == null && categories.isNotEmpty) {
        _selectedCard = categories.first;
        notifyListeners();
      }
    });
  }

  void selectCard(Category tappedCard) {
    _selectedCard = tappedCard;
    notifyListeners();
  }

  void clearForm() {
    noteController.clear();
    amountController.clear();
    // Set lại category được chọn về null, hàm _listenToCategories sẽ tự động chọn lại item đầu tiên
    _selectedCard = null;
    notifyListeners();
  }

  Future<void> addTransaction() async {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      throw Exception('Vui lòng nhập số tiền.');
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount == 0) {
      throw Exception('Số tiền không hợp lệ.');
    }

    if (_selectedCard == null) {
      throw Exception('Vui lòng chọn một danh mục.');
    }

    final transaction = TransactionsCompanion(
      amount: Value(amount),
      transactionDate: Value(_selectedDate),
      note: Value(noteController.text.trim()),
      categoryId: Value(_selectedCard!.id),
    );

    await _database.insertTransaction(transaction);

    clearForm();
  }

  Stream<List<Category>> get expenseCategoriesStream =>
      _database.watchCategoriesByType(TransactionType.expense);

  Stream<List<Category>> get incomeCategoriesStream =>
      _database.watchCategoriesByType(TransactionType.income);

  @override
  void dispose() {
    _categorySubscription?.cancel();
    noteController.dispose();
    amountController.dispose();
    super.dispose();
  }
}