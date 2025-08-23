import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naspend/shared/widgets/component_screen.dart';
import 'package:naspend/ui/category/view_model/add_category_view_model.dart';
import 'package:provider/provider.dart';

const Widget rowDivider = SizedBox(width: 20);
const Widget colDivider = SizedBox(height: 10);

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;

    final viewModel = context.watch<AddCategoryViewModel>();

    final appBarTitle = viewModel.isEditMode ? 'Sửa danh mục' : 'Thêm danh mục';
    final buttonText = viewModel.isEditMode ? 'Lưu thay đổi' : 'Lưu danh mục';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ComponentDecoration(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: smallSpacing, vertical: 5.0),
                        child: TextField(
                          controller: viewModel.controllerCategoryName,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.category_outlined),
                            suffixIcon: ClearButton(controller: viewModel.controllerCategoryName),
                            labelText: 'Danh mục',
                            hintText: 'Nhập tên danh mục',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TitleTooltip(
                          label: 'Biểu tượng',
                          tooltipMessage: 'Chọn biểu tượng danh mục',
                        ),
                      ),
                      GridView.count(
                        padding: EdgeInsets.all(smallSpacing),
                        crossAxisCount: 5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        children: viewModel.icons.map((iconData) {
                          final bool isSelected =
                              viewModel.selectedIcon == iconData;

                          return IconButton.filled(
                            isSelected: isSelected,
                            icon: Icon(iconData),
                            onPressed: () {
                              viewModel.selectIcon(iconData);
                            },
                          );
                        }).toList(),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TitleTooltip(
                          label: 'Màu sắc',
                          tooltipMessage: 'Chọn màu sắc danh mục',
                        ),
                      ),
                      GridView.count(
                        padding: EdgeInsets.all(smallSpacing),
                        crossAxisCount: 5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        children: viewModel.colors.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final int color = entry.value;
                          final bool isSelected =
                              viewModel.selectedColor == color;

                          return GestureDetector(
                            onTap: () {
                              viewModel.selectColor(index);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(color),
                                border: isSelected
                                    ? Border.all(
                                  color: colors.onSurface,
                                  width: 2.5,
                                ) : null,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: () async {
                await context.read<AddCategoryViewModel>().saveCategory();
                if (context.mounted) {
                  context.pop();
                }
              },
              child: Center(child: Text(buttonText)),
            ),
          ),
        ],
      ),
    );
  }
}
