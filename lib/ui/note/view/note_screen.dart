import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naspend/core/router/app_routes.dart';
import 'package:naspend/data/datasources/local/database.dart';
import 'package:naspend/shared/widgets/component_screen.dart';
import 'package:naspend/ui/note/view_model/note_view_model.dart';
import 'package:provider/provider.dart';

const Widget rowDivider = SizedBox(width: 20);
const Widget colDivider = SizedBox(height: 10);
const smallSpacing = 10.0;

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late final Stream<List<Category>> _expenseCategoriesStream;
  late final Stream<List<Category>> _incomeCategoriesStream;

  @override
  void initState() {
    final viewModel = context.read<NoteViewModel>();
    _expenseCategoriesStream = viewModel.expenseCategoriesStream;
    _incomeCategoriesStream = viewModel.incomeCategoriesStream;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;
    final viewModel = context.watch<NoteViewModel>();

    return Expanded(
      child: DefaultTabController(
        length: viewModel.tabs.length,
        child: Column(
          children: [
            TabBar(
              tabs: viewModel.tabs,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTabContent(
                    context: context,
                    stream: _expenseCategoriesStream,
                    type: TransactionType.expense,
                  ),
                  _buildTabContent(
                    context: context,
                    stream: _incomeCategoriesStream,
                    type: TransactionType.income,
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget _buildTabContent({
    required BuildContext context,
    required Stream<List<Category>> stream,
    required TransactionType type,
  }) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;
    final viewModel = context.watch<NoteViewModel>();

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ComponentDecoration(
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: viewModel.previousDay,
                          ),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: () => viewModel.pickDate(context),
                              label: Text(viewModel.formattedDate),
                              icon: const Icon(Icons.calendar_today),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: viewModel.nextDay,
                          ),
                        ],
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: smallSpacing, vertical: 5.0),
                        child: TextField(
                          controller: viewModel.noteController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.edit_outlined),
                            suffixIcon: ClearButton(controller: viewModel.noteController),
                            labelText: 'Ghi chú',
                            hintText: 'Nhập ghi chú',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: smallSpacing, vertical: 5.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: viewModel.amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                                  suffixIcon: ClearButton(controller: viewModel.amountController),
                                  labelText: 'Tiền ${type == TransactionType.expense ? 'chi' : 'thu'}',
                                  hintText: '0',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            rowDivider,
                            Text(
                              'đ',
                              style: fonts.titleLarge!.copyWith(
                                color: colors.onSurface,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              colDivider,
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                      children: [
                        TitleTooltip(
                            label: 'Danh mục',
                            tooltipMessage: 'Danh sách các mục đã ghi chú'
                        ),
                        colDivider,
                        CarouselWidget(stream: stream),
                      ]
                  )
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: () async {
              try {
                await viewModel.addTransaction();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã lưu giao dịch thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Hiển thị thông báo lỗi nếu có
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
                      backgroundColor: colors.error,
                    ),
                  );
                }
              }

            },
            child: Center(child: Text('Lưu ${type == TransactionType.expense ? 'chi tiêu' : 'thu nhập'}'))
          ),
        ),
      ],
    );
  }
}

class CarouselWidget extends StatelessWidget {
  const CarouselWidget({super.key, required this.stream});

  final Stream<List<Category>> stream;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;

    final viewModel = context.watch<NoteViewModel>();

    return StreamBuilder<List<Category>>(
      stream: stream,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (asyncSnapshot.hasError) {
          return Center(child: Text('Đã xảy ra lỗi: ${asyncSnapshot.error}'));
        }
        final categories = asyncSnapshot.data ?? [];
        const addNewPlaceholder = 'ADD_NEW';
        final List<Object> carouselItems = [
          addNewPlaceholder,
          ...categories,
        ];
        return ConstrainedBox(
          constraints: const BoxConstraints.tightFor(height: 150),
          child: CarouselView(
            shrinkExtent: 80,
            itemExtent: 150,
            itemSnapping: true,
            onTap: (index) {
              final tappedItem = carouselItems[index];
              if (tappedItem is String && tappedItem == addNewPlaceholder) {
                context.push(AppRoutes.category);
              } else if (tappedItem is Category) {
                context.read<NoteViewModel>().selectCard(tappedItem);
              }
            },
            children: carouselItems.map((item) {
              if (item is Category) {
                final category = item;
                final bool isSelected = viewModel.selectedCard == category;
                final iconColor = Color(category.iconColorValue);
                final backgroundColor = Color(category.backgroundColorValue);

                return Container(
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(28),
                      border: isSelected ? Border.all(
                        color: colors.inversePrimary,
                        width: 6.0,
                      ) : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            IconData(
                              category.iconCodePoint,
                              fontFamily: 'MaterialIcons'
                            ),
                            color: iconColor, size: 32.0
                          ),
                          Text(
                            category.name,
                            style: fonts.labelLarge!.copyWith(
                              color: iconColor,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.clip,
                            softWrap: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container(
                  decoration: BoxDecoration(
                    color: Color(0xffE3DFD8),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 32.0, color: Color(0xff201D1C)),
                        Text(
                          'Thêm mới',
                          style: fonts.labelLarge!.copyWith(
                            color: Color(0xff201D1C),
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.clip,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                );
              }
            }).toList(),
          ),
        );
      }
    );
  }
}