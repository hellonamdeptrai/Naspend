import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

enum TransactionType {
  expense, // Chi tiêu
  income,  // Thu nhập
}

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get iconCodePoint => integer()();
  IntColumn get iconColorValue => integer()();
  IntColumn get backgroundColorValue => integer()();

  // Cột để phân loại: 0 cho Chi tiêu, 1 cho Thu nhập
  IntColumn get type => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

// Bảng TRANSACTIONS: Lưu trữ tất cả các giao dịch thu và chi
@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get note => text().nullable()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  IntColumn get type => integer().map(const EnumIndexConverter(TransactionType.values))();
}

class TransactionWithCategory {
  final Transaction transaction;
  final Category? category; // <-- Chuyển thành nullable

  TransactionWithCategory({
    required this.transaction,
    this.category, // <-- Bỏ required
  });
}

@DriftDatabase(tables: [Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // == CÁC TRUY VẤN CHO TRANSACTIONS ==

  // Lấy tất cả giao dịch (dùng để test)
  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  // Thêm một giao dịch mới
  Future<int> insertTransaction(TransactionsCompanion transaction) =>
      into(transactions).insert(transaction);

  // Cập nhật một giao dịch
  Future<bool> updateTransaction(TransactionsCompanion transaction) =>
      update(transactions).replace(transaction);

  // Xóa một giao dịch
  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();

  // == CÁC TRUY VẤN CHO CATEGORIES ==

  // Lấy tất cả các danh mục dưới dạng Stream (tự động cập nhật UI)
  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  // Lấy các danh mục theo loại (Chi tiêu hoặc Thu nhập)
  Stream<List<Category>> watchCategoriesByType(TransactionType type) {
    return (select(categories)
    // Thêm điều kiện lọc `isActive`
      ..where((tbl) => tbl.type.equals(type.index) & tbl.isActive.equals(true)))
        .watch();
  }

  // Thêm một danh mục mới
  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  // Cập nhật một danh mục
  Future<bool> updateCategory(CategoriesCompanion category) =>
      update(categories).replace(category);

  // Xóa một danh mục
  Future<int> deleteCategory(int id) {
    // Thay vì xóa, chúng ta cập nhật cờ isActive
    return (update(categories)..where((tbl) => tbl.id.equals(id)))
        .write(const CategoriesCompanion(
      isActive: Value(false),
    ));
  }

  Stream<List<TransactionWithCategory>> watchTransactionsInMonth(DateTime date) {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    final query = select(transactions).join([
      leftOuterJoin(categories, categories.id.equalsExp(transactions.categoryId))
    ])
      ..where(transactions.transactionDate.isBetween(Constant(startOfMonth), Constant(endOfMonth)));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(transactions),
          // SỬA Ở ĐÂY: Dùng readTableOrNull
          category: row.readTableOrNull(categories),
        );
      }).toList();
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}