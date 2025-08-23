import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:naspend/data/datasources/local/database.dart';

class AddCategoryViewModel extends ChangeNotifier {
  final AppDatabase _database;
  final Category? initialCategory;
  late TransactionType type;

  AddCategoryViewModel(
      this._database, {
        this.initialCategory,
        TransactionType? type,
      }) {
    if (isEditMode) {
      this.type = TransactionType.values[initialCategory!.type];
      _initializeForEdit();
    } else {
      this.type = type ?? TransactionType.expense;
    }
  }

  bool get isEditMode => initialCategory != null;

  void _initializeForEdit() {
    controllerCategoryName.text = initialCategory!.name;
    _selectedIcon = IconData(initialCategory!.iconCodePoint, fontFamily: 'MaterialIcons');
    _selectedColor = initialCategory!.iconColorValue;
    _selectedBackgroundColor = initialCategory!.backgroundColorValue;
  }

  final TextEditingController controllerCategoryName = TextEditingController();

  final List<IconData> icons = const [
    Icons.home, Icons.search, Icons.settings, Icons.person,
    Icons.camera_alt, Icons.shopping_cart, Icons.favorite, Icons.music_note,
    Icons.lightbulb, Icons.movie, Icons.phone, Icons.send,
    Icons.wallet_giftcard, Icons.work, Icons.wifi, Icons.power_settings_new,
  ];

  final List<int> backgroundColors = const [
    0xffECEFFD, 0xffFAEEDF, 0xffFAEDE7, 0xffE5F4E0,
  ];

  final List<int> colors = const [
    0xff2354C7, 0xff806C2A, 0xffA44D2A, 0xff417345,
  ];

  IconData _selectedIcon = Icons.home;
  IconData get selectedIcon => _selectedIcon;

  int _selectedColor = 0xff2354C7;
  int get selectedColor => _selectedColor;

  int _selectedBackgroundColor = 0xffECEFFD;
  int get selectedBackgroundColor => _selectedBackgroundColor;

  void selectIcon(IconData icon) {
    _selectedIcon = icon;
    notifyListeners();
  }

  void selectColor(int index) {
    if (index >= 0 && index < colors.length) {
      _selectedColor = colors[index];
      _selectedBackgroundColor = backgroundColors[index];
      notifyListeners();
    }
  }

  Future<void> saveCategory() async {
    final name = controllerCategoryName.text.trim();
    if (name.isEmpty) return;

    if (isEditMode) {
      final updatedCategory = CategoriesCompanion(
        id: Value(initialCategory!.id),
        name: Value(name),
        iconColorValue: Value(selectedColor),
        backgroundColorValue: Value(selectedBackgroundColor),
        type: Value(type.index),
        iconCodePoint: Value(selectedIcon.codePoint),
      );
      await _database.updateCategory(updatedCategory);
    } else {
      final newCategory = CategoriesCompanion(
        name: Value(name),
        iconColorValue: Value(selectedColor),
        backgroundColorValue: Value(selectedBackgroundColor),
        type: Value(type.index),
        iconCodePoint: Value(selectedIcon.codePoint),
      );
      await _database.insertCategory(newCategory);
    }
  }

  @override
  void dispose() {
    controllerCategoryName.dispose();
    super.dispose();
  }
}