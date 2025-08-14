import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:naspend/ui/note/view/note_screen.dart';

class NoteViewModel extends ChangeNotifier {
  final TextEditingController controllerOutlined = TextEditingController();
  CardInfo _selectedCard = CardInfo.camera;
  CardInfo get selectedCard => _selectedCard;

  final List<Tab> tabs = <Tab>[
    Tab(text: 'Chi tiêu'),
    Tab(text: 'Thu nhập'),
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
      notifyListeners();
    }
  }

  void selectCard(CardInfo tappedCard) {
    // --- LOGIC MỚI: Bỏ qua nếu là nút "More" ---
    if (tappedCard == CardInfo.more) {
      // Không làm gì liên quan đến việc chọn.
      // Chúng ta sẽ xử lý hành động của nút "+" ở View.
      return; // Kết thúc hàm sớm, không chạy code chọn/bỏ chọn bên dưới.
    }
    _selectedCard = tappedCard;
    notifyListeners();
  }
}