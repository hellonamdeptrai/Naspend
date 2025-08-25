import 'package:naspend/data/datasources/local/database.dart';

class TransactionWithCategory {
  final Transaction transaction;
  final Category? category;

  TransactionWithCategory({
    required this.transaction,
    this.category,
  });
}