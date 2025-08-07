import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:naspend/data/model/tab_item.dart';

class DashboardViewModel extends ChangeNotifier {
  final List<TabItem> tabs = const [
    TabItem(label: 'Chi tiêu'),
    TabItem(label: 'Thu nhập'),
  ];

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;
  String get formattedDate => DateFormat('MM/yyyy').format(_selectedDate);

  void nextMonth() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    notifyListeners();
  }

  void previousMonth() {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
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
      notifyListeners(); // Thông báo cho View cập nhật
    }
  }
}