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
  // Chúng ta sẽ dùng TypeConverter để chuyển đổi giữa int và enum TransactionType
  IntColumn get type => integer()();
}


// Bảng TRANSACTIONS: Lưu trữ tất cả các giao dịch thu và chi
@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()(); // Số tiền, dùng Real để lưu số thực
  DateTimeColumn get transactionDate => dateTime()(); // Ngày giao dịch
  TextColumn get note => text().nullable()(); // Ghi chú, có thể trống

  // Khóa ngoại: Mỗi giao dịch phải thuộc về một danh mục
  // onDelete: Set(null) nghĩa là nếu category bị xóa, cột này sẽ được set về NULL
  // thay vì xóa luôn giao dịch (để bảo toàn dữ liệu)
  IntColumn get categoryId => integer().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
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
    return (select(categories)..where((tbl) => tbl.type.equals(type.index))).watch();
  }

  // Thêm một danh mục mới
  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  // Cập nhật một danh mục
  Future<bool> updateCategory(CategoriesCompanion category) =>
      update(categories).replace(category);

  // Xóa một danh mục
  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((tbl) => tbl.id.equals(id))).go();

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}