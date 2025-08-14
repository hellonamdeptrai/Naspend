import 'package:flutter/material.dart';
import 'package:naspend/data/datasources/local/database.dart';
import 'package:naspend/ui/category/view_model/category_view_model.dart';
import 'package:provider/provider.dart';

class CategoryListStreamBuilder extends StatelessWidget {
  const CategoryListStreamBuilder({super.key, required this.stream});

  final Stream<List<Category>> stream;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<CategoryViewModel>();

    return StreamBuilder<List<Category>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
        }
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return const Center(child: Text('Chưa có danh mục nào.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          itemCount: categories.length,
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, index) {
            final category = categories[index];
            final iconColor = Color(category.iconColorValue);
            final backgroundColor = Color(category.backgroundColorValue);

            return ListTile(
              onTap: () {
                // TODO: Xử lý khi nhấn vào để chỉnh sửa
              },
              leading: CircleAvatar(
                backgroundColor: backgroundColor,
                child: Icon(
                  IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                  color: iconColor,
                ),
              ),
              title: Text(category.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () {
                  viewModel.deleteCategory(category.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}