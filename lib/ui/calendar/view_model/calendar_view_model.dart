import 'dart:async';

import 'package:flutter/material.dart';
import 'package:naspend/data/datasources/local/database.dart';
import 'package:naspend/data/model/daily_summary.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarViewModel extends ChangeNotifier {
  final AppDatabase _database;
  StreamSubscription? _transactionsSubscription;

  CalendarViewModel(this._database) {
    final now = DateTime.now();
    _focusedDay = now;
    _listenToMonthChanges(now);
  }

  late DateTime _focusedDay;
  DateTime? _selectedDay;

  Map<DateTime, DailySummary> _dailySummaries = {};
  DailySummary _monthlySummary = DailySummary();
  Map<DateTime, List<TransactionWithCategory>> _transactionsByDay = {};

  bool _isLoading = true;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  DailySummary get monthlySummary => _monthlySummary;
  Map<DateTime, List<TransactionWithCategory>> get transactionsByDay => _transactionsByDay;
  bool get isLoading => _isLoading;

  DailySummary getSummaryForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _dailySummaries[normalizedDay] ?? DailySummary();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      notifyListeners();
    }
  }

  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    _selectedDay = null;
    _listenToMonthChanges(focusedDay);
    notifyListeners();
  }

  void _listenToMonthChanges(DateTime month) {
    _isLoading = true;
    notifyListeners();

    _transactionsSubscription?.cancel();

    _transactionsSubscription = _database.watchTransactionsInMonth(month).listen((transactions) {
      final Map<DateTime, DailySummary> newSummaries = {};
      final Map<DateTime, List<TransactionWithCategory>> newGroupedTransactions = {};
      double totalMonthIncome = 0;
      double totalMonthExpense = 0;

      for (final txWithCategory in transactions) {
        final tx = txWithCategory.transaction;
        final day = DateTime(tx.transactionDate.year, tx.transactionDate.month, tx.transactionDate.day);

        final currentSummary = newSummaries.putIfAbsent(day, () => DailySummary());
        double newIncome = currentSummary.totalIncome;
        double newExpense = currentSummary.totalExpense;

        if (tx.type == TransactionType.income) {
          newIncome += tx.amount;
          totalMonthIncome += tx.amount;
        } else {
          newExpense += tx.amount;
          totalMonthExpense += tx.amount;
        }
        newSummaries[day] = DailySummary(totalIncome: newIncome, totalExpense: newExpense);

        (newGroupedTransactions[day] ??= []).add(txWithCategory);
      }

      _dailySummaries = newSummaries;
      _monthlySummary = DailySummary(totalIncome: totalMonthIncome, totalExpense: totalMonthExpense);
      _transactionsByDay = newGroupedTransactions;
      _isLoading = false;

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    super.dispose();
  }
}