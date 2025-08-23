import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:naspend/core/router/app_routes.dart';
import 'package:naspend/data/datasources/local/database.dart';
import 'package:naspend/ui/calendar/view_model/calendar_view_model.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:table_calendar/table_calendar.dart';

const Widget rowDivider = SizedBox(width: 20);
const Widget colDivider = SizedBox(height: 10);

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();

  void _scrollToDay(DateTime day, CalendarViewModel viewModel) {
    final normalizedDay = DateTime(day.year, day.month, day.day);

    final sortedDays = viewModel.transactionsByDay.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Sắp xếp giảm dần để ngày mới nhất lên đầu

    final index = sortedDays.indexOf(normalizedDay);

    if (index != -1) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarViewModel>();
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    final sortedDaysWithTransactions = viewModel.transactionsByDay.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Sắp xếp giảm dần

    return Expanded(
      child: Column(
        children: [
          _buildCalendar(viewModel),
          const Divider(height: 1, thickness: 1),
          _buildMonthlySummary(viewModel, currencyFormatter),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.transactionsByDay.isEmpty
                ? const Center(child: Text('Không có giao dịch nào trong tháng.'))
                : _buildTransactionList(viewModel, sortedDaysWithTransactions, currencyFormatter),
          ),
        ],
      ),
    );
  }

  Widget _buildCellContent(DateTime day, CalendarViewModel viewModel) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;

    final summary = viewModel.getSummaryForDay(day);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${day.day}',
          style: fonts.labelLarge!
        ),
        const SizedBox(height: 2),
        if (summary.totalIncome > 0)
          Text(
            NumberFormat.compact(locale: 'vi_VN').format(summary.totalIncome),
            style: fonts.bodySmall!.copyWith(
              color: Colors.green,
              fontSize: 9
            ),
            overflow: TextOverflow.ellipsis,
          ),
        if (summary.totalExpense > 0)
          Text(
            NumberFormat.compact(locale: 'vi_VN').format(summary.totalExpense),
            style: fonts.bodySmall!.copyWith(
                color: colors.error,
                fontSize: 9
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildCalendar(CalendarViewModel viewModel) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;

    return TableCalendar(
      locale: 'vi_VN',
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2101, 12, 31),
      focusedDay: viewModel.focusedDay,
      selectedDayPredicate: (day) => isSameDay(viewModel.selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        viewModel.onDaySelected(selectedDay, focusedDay);
        _scrollToDay(selectedDay, viewModel);
      },
      onPageChanged: viewModel.onPageChanged,
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: fonts.titleLarge!.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return _buildCellContent(day, viewModel);
        },
        selectedBuilder: (context, day, focusedDay) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
            ),
            child: _buildCellContent(day, viewModel),
          );
        },
        todayBuilder: (context, day, focusedDay) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.onInverseSurface,
            ),
            child: _buildCellContent(day, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildMonthlySummary(CalendarViewModel viewModel, NumberFormat formatter) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final total = viewModel.monthlySummary.totalIncome - viewModel.monthlySummary.totalExpense;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _summaryItem('Thu nhập', viewModel.monthlySummary.totalIncome, Colors.green, formatter),
          _summaryItem('Chi tiêu', viewModel.monthlySummary.totalExpense, colors.error, formatter),
          _summaryItem('Tổng', total, total >= 0 ? colors.primary : colors.error, formatter),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double value, Color color, NumberFormat formatter) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: fonts.labelLarge!.copyWith(color: colors.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(
          formatter.format(value),
          style: fonts.titleMedium!.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(CalendarViewModel viewModel, List<DateTime> sortedDays, NumberFormat formatter) {
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final day = sortedDays[index];
        final transactionsForDay = viewModel.transactionsByDay[day]!;
        final dailySummary = viewModel.getSummaryForDay(day);
        final dailyTotal = dailySummary.totalIncome - dailySummary.totalExpense;
        final theme = Theme.of(context);
        final fonts = theme.textTheme;
        final colors = theme.colorScheme;

        return Column(
          children: [
            // Header cho mỗi ngày
            Container(
              color: colors.onInverseSurface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Row(
                    children: [
                      Text(
                        '${day.day}',
                        style: fonts.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE', 'vi_VN').format(day),
                            style: fonts.labelLarge!.copyWith(color: colors.outline),
                          ),
                          Text(
                            DateFormat('MMMM, yyyy', 'vi_VN').format(day),
                            style: fonts.labelLarge!.copyWith(color: colors.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  rowDivider,
                  Expanded(
                    child: Text(
                      formatter.format(dailyTotal),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: dailyTotal >= 0 ? Colors.green : colors.error,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            ...transactionsForDay.map((txWithCategory) {
              final tx = txWithCategory.transaction;
              final category = txWithCategory.category;
              final isIncome = tx.type == TransactionType.income;

              final backgroundColor = Color(category?.backgroundColorValue ?? 0xffE0E0E0); // Màu xám mặc định
              final iconColor = Color(category?.iconColorValue ?? 0xff616161);
              final iconCodePoint = category?.iconCodePoint ?? Icons.help_outline.codePoint;
              final categoryName = category!.isActive ? category.name : 'Chưa phân loại';

              return ListTile(
                onTap: () {
                  context.push(AppRoutes.editTransaction, extra: txWithCategory);
                },
                leading: CircleAvatar(
                  backgroundColor: backgroundColor,
                  child: Icon(
                    IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
                    color: iconColor,
                  ),
                ),
                title: Text(categoryName),
                subtitle: tx.note != null && tx.note!.isNotEmpty ? Text(tx.note!) : null,
                trailing: Text(
                  '${isIncome ? '+' : '-'} ${formatter.format(tx.amount)}',
                  style: fonts.labelLarge!.copyWith(
                    color: isIncome ? Colors.green : colors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}