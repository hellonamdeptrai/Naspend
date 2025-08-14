import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naspend/core/router/app_routes.dart';
import 'package:naspend/data/datasources/local/database.dart';
import 'package:naspend/ui/category/view_model/category_view_model.dart';
import 'package:naspend/ui/category/widgets/category_list_stream_builder.dart';
import 'package:provider/provider.dart';

const Widget rowDivider = SizedBox(width: 20);
const Widget colDivider = SizedBox(height: 10);

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;

    final viewModel = context.watch<CategoryViewModel>();

    return DefaultTabController(
      length: viewModel.tabs.length,
      child: Builder(
        builder: (newContext) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Danh mục'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final tabController = DefaultTabController.of(newContext);

                    final currentType = tabController.index == 0
                        ? TransactionType.expense
                        : TransactionType.income;

                    context.push(AppRoutes.addCategory, extra: currentType);
                  },
                  tooltip: 'Thêm danh mục',
                ),
              ],
              bottom: TabBar(tabs: viewModel.tabs),
            ),
            body: TabBarView(
              children: [
                CategoryListStreamBuilder(
                  stream: viewModel.expenseCategoriesStream,
                ),
                CategoryListStreamBuilder(
                  stream: viewModel.incomeCategoriesStream,
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
