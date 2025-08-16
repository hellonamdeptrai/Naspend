import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:naspend/data/datasources/local/database.dart';
import 'package:naspend/ui/dashboard/view/dashboard_screen.dart';
import 'package:rxdart/rxdart.dart';

class DashboardViewModel extends ChangeNotifier {
  final AppDatabase _database;

  DashboardViewModel(this._database) {
    _updateDataStreams();
  }

  final List<Tab> tabs = <Tab>[
    Tab(text: 'Chi tiêu'),
    Tab(text: 'Thu nhập'),
  ];

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;
  String get formattedDate => DateFormat('MM/yyyy').format(_selectedDate);

  void nextMonth() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    _updateDataStreams();
    notifyListeners();
  }

  void previousMonth() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    _updateDataStreams();
    notifyListeners();
  }

  Future<void> pickMonth(BuildContext context) async {
    final pickedDate = await showMonthPicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      _selectedDate = pickedDate;
      _updateDataStreams();
      notifyListeners(); // Thông báo cho View cập nhật
    }
  }

  // Tạo các StreamController để quản lý luồng dữ liệu
  // BehaviorSubject sẽ giữ lại giá trị cuối cùng cho các listener mới
  final _transactionsController = BehaviorSubject<List<TransactionWithCategory>>();
  StreamSubscription? _dbSubscription;

  // Các Stream để UI lắng nghe
  Stream<List<ChartSampleData>> get expenseChartDataStream =>
      _transactionsController.stream.map(_processChartDataForType(TransactionType.expense));

  Stream<List<ChartSampleData>> get incomeChartDataStream =>
      _transactionsController.stream.map(_processChartDataForType(TransactionType.income));

  Stream<double> get totalExpenseStream =>
      _transactionsController.stream.map(_calculateTotalForType(TransactionType.expense));

  Stream<double> get totalIncomeStream =>
      _transactionsController.stream.map(_calculateTotalForType(TransactionType.income));

  Stream<double> get balanceStream =>
      Rx.combineLatest2(totalIncomeStream, totalExpenseStream, (income, expense) => income - expense);


  // Hàm xử lý dữ liệu thô từ DB thành dữ liệu cho biểu đồ
  List<ChartSampleData> Function(List<TransactionWithCategory>) _processChartDataForType(TransactionType type) {
    return (transactions) {
      // Lọc giao dịch theo loại (thu/chi)
      final filtered = transactions.where((t) => t.category.type == type.index).toList();
      if (filtered.isEmpty) return [];

      final totalValue = filtered.fold<double>(0, (sum, item) => sum + item.transaction.amount);
      if (totalValue == 0) return [];

      // Nhóm các giao dịch theo categoryId và tính tổng số tiền
      final Map<int, double> categoryTotals = {};
      for (var t in filtered) {
        categoryTotals.update(t.category.id, (value) => value + t.transaction.amount, ifAbsent: () => t.transaction.amount);
      }

      // Chuyển đổi map đã nhóm thành List<ChartSampleData>
      return categoryTotals.entries.map((entry) {
        final category = filtered.firstWhere((t) => t.category.id == entry.key).category;
        final amount = entry.value;
        final percentage = (amount / totalValue) * 100;
        return ChartSampleData(
          x: category.name,
          y: amount,
          size: percentage, // Dùng 'size' để lưu trữ %
        );
      }).toList();
    };
  }

  // Hàm tính tổng thu/chi
  double Function(List<TransactionWithCategory>) _calculateTotalForType(TransactionType type) {
    return (transactions) {
      return transactions
          .where((t) => t.category.type == type.index)
          .fold<double>(0, (sum, item) => sum + item.transaction.amount);
    };
  }

  // Hàm cập nhật luồng dữ liệu khi ngày thay đổi
  void _updateDataStreams() {

    // Hủy subscription cũ trước khi tạo cái mới
    _dbSubscription?.cancel();
    _dbSubscription = _database.watchTransactionsInMonth(_selectedDate).listen((data) {
      _transactionsController.add(data);
    });
  }

  @override
  void dispose() {
    _dbSubscription?.cancel();
    _transactionsController.close();
    super.dispose();
  }
}