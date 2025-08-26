import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naspend/data/datasources/local/database.dart';
import 'package:naspend/data/model/monthly_total.dart';

class TransactionViewModel extends ChangeNotifier {
  final AppDatabase _database;
  final int categoryId;
  DateTime _currentYear;

  StreamSubscription? _monthlyTotalsSubscription;
  StreamSubscription? _transactionSubscription;

  TransactionViewModel(this._database, {
    required this.categoryId,
    required DateTime initialDate,
  }) : _currentYear = initialDate {
    _selectedMonth = initialDate.month;
    _fetchData();
  }

  // --- State ---
  bool _isLoading = true;
  Category? _category;
  List<MonthlyTotal> _monthlyTotals = [];
  List<Transaction> _transactionsForSelectedMonth = [];
  int? _selectedMonth; // Lưu tháng đang được chọn (1-12)

  // --- Getters ---
  bool get isLoading => _isLoading;
  Category? get category => _category;
  List<MonthlyTotal> get monthlyTotals => _monthlyTotals;
  List<Transaction> get transactionsForSelectedMonth => _transactionsForSelectedMonth;
  int? get selectedMonth => _selectedMonth;
  String get yearString => DateFormat('yyyy').format(_currentYear);
  double get selectedMonthTotal {
    return _transactionsForSelectedMonth.fold<double>(
        0, (sum, tx) => sum + tx.amount);
  }

  // --- Actions ---
  Future<void> _fetchData() async {
    _isLoading = true;
    notifyListeners();

    _category = await _database.getCategoryById(categoryId);

    _listenToMonthlyTotals();

    _listenToTransactions();

    _isLoading = false;
  }

  void _listenToMonthlyTotals() {
    _monthlyTotalsSubscription?.cancel();
    _monthlyTotalsSubscription = _database
        .watchMonthlyTotalsForCategory(categoryId, _currentYear.year)
        .listen((rawTotals) {
      // Logic xử lý dữ liệu (giống hàm _prepareChartData cũ)
      final totalsMap = { for (var total in rawTotals) total.month : total.total };
      final allMonthsData = List.generate(12, (index) {
        final month = index + 1;
        return MonthlyTotal(month: month, total: totalsMap[month] ?? 0.0);
      });
      _monthlyTotals = allMonthsData;
      notifyListeners(); // Cập nhật UI
    });
  }

  void _listenToTransactions() {
    _transactionSubscription?.cancel();

    if (_selectedMonth != null) {
      final monthDate = DateTime(_currentYear.year, _selectedMonth!, 1);
      _transactionSubscription = _database
          .watchTransactionsForCategoryInSpecificMonth(categoryId, monthDate)
          .listen((transactions) {
        _transactionsForSelectedMonth = transactions;
        notifyListeners();
      });
    } else {
      _transactionsForSelectedMonth = [];
      notifyListeners();
    }
  }

  void onMonthTapped(int month) {
    if (_selectedMonth == month) {
      _selectedMonth = null;
    } else {
      _selectedMonth = month;
    }
    _listenToTransactions();
  }

  void nextYear() {
    _currentYear = DateTime(_currentYear.year + 1);
    _fetchData();
  }

  void previousYear() {
    _currentYear = DateTime(_currentYear.year - 1);
    _fetchData();
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    _monthlyTotalsSubscription?.cancel();
    super.dispose();
  }
}