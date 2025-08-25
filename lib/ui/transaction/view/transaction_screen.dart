import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:naspend/core/router/app_routes.dart';
import 'package:naspend/data/datasources/local/database.dart';
import 'package:naspend/data/model/monthly_total.dart';
import 'package:naspend/data/model/transaction_with_category.dart';
import 'package:naspend/ui/transaction/view_model/transaction_view_model.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

const Widget rowDivider = SizedBox(width: 20);
const Widget colDivider = SizedBox(height: 10);

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    final String appBarTitle;
    if (viewModel.selectedMonth != null) {
      appBarTitle =
      '${viewModel.category?.name ?? ""} (T${viewModel.selectedMonth}) ${currencyFormatter.format(viewModel.selectedMonthTotal)}';
    } else {
      appBarTitle = viewModel.category?.name ?? 'Không có tên';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(onPressed: viewModel.previousYear, icon: const Icon(Icons.chevron_left)),
          Center(child: Text(viewModel.yearString)),
          IconButton(onPressed: viewModel.nextYear, icon: const Icon(Icons.chevron_right)),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildChart(context, viewModel),
          colDivider,
          Expanded(
            child: _buildTransactionList(viewModel, currencyFormatter),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, TransactionViewModel viewModel) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;
    final compactFormatter = NumberFormat.compact(locale: 'vi_VN');

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(numberFormat: NumberFormat.compact(locale: 'vi_VN')),
      series: <ColumnSeries<MonthlyTotal, String>>[
        ColumnSeries<MonthlyTotal, String>(
          dataSource: viewModel.monthlyTotals,
          xValueMapper: (MonthlyTotal data, _) {
            final year = int.parse(viewModel.yearString);
            final dateForMonth = DateTime(year, data.month);
            return DateFormat('MMM', 'vi_VN').format(dateForMonth);
          },
          yValueMapper: (MonthlyTotal data, _) => data.total,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
                int seriesIndex) {
              final monthlyData = data as MonthlyTotal;
              if (monthlyData.total > 0) {
                return Text(
                  compactFormatter.format(monthlyData.total),
                  style: fonts.labelSmall!.copyWith(color: colors.onSurface),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          pointColorMapper: (MonthlyTotal data, _) =>
          (data.month == viewModel.selectedMonth) ? colors.primary : colors.inversePrimary,
          onPointTap: (ChartPointDetails details) {
            final tappedData = viewModel.monthlyTotals[details.pointIndex!];
            viewModel.onMonthTapped(tappedData.month);
          },
        ),
      ],
    );
  }

  Widget _buildTransactionList(TransactionViewModel viewModel, NumberFormat formatter) {
    if (viewModel.selectedMonth == null) {
      return const Center(child: Text('Chọn một tháng trên biểu đồ để xem chi tiết.'));
    }
    final transactions = viewModel.transactionsForSelectedMonth;
    if (transactions.isEmpty) {
      return const Center(child: Text('Không có giao dịch trong tháng đã chọn.'));
    }

    final groupedTransactions = groupBy(
      transactions,
          (Transaction tx) => DateTime(tx.transactionDate.year, tx.transactionDate.month, tx.transactionDate.day),
    );

    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dailyTransactions = groupedTransactions[date]!;
        final dailyTotal = dailyTransactions.fold<double>(0, (sum, tx) => sum + tx.amount);

        final bool isIncome = dailyTransactions.isNotEmpty && dailyTransactions.first.type == TransactionType.income;

        return Column(
          children: [
            _buildDateHeader(date, dailyTotal, formatter, context, isIncome),
            ...dailyTransactions.map((tx) => _buildTransactionItem(tx, viewModel, formatter, context)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date, double total, NumberFormat formatter, BuildContext context, bool isIncome) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;

    return Container(
      color: colors.onInverseSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            DateFormat('d').format(date),
            style: fonts.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE', 'vi_VN').format(date),
                style: fonts.labelLarge!.copyWith(color: colors.outline),
              ),
              Text(
                DateFormat('MMMM, yyyy', 'vi_VN').format(date),
                style: fonts.labelLarge!.copyWith(color: colors.outline),
              ),
            ],
          ),
          rowDivider,
          Expanded(
            child: Text(
              '${isIncome ? '+' : '-'}${formatter.format(total)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : colors.error,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction tx, TransactionViewModel viewModel, NumberFormat formatter, BuildContext context) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;
    final category = viewModel.category;

    if (category == null) return const SizedBox.shrink();

    final txWithCategory =
    TransactionWithCategory(transaction: tx, category: category);

    final backgroundColor = Color(category.backgroundColorValue);
    final iconColor = Color(category.iconColorValue);
    final iconData = IconData(category.iconCodePoint, fontFamily: 'MaterialIcons');
    final categoryName = category.isActive ? category.name : 'Chưa phân loại';
    final isIncome = tx.type == TransactionType.income;

    return ListTile(
      onTap: () {
        context.push(AppRoutes.editTransaction, extra: txWithCategory);
      },
      leading: CircleAvatar(
        backgroundColor: backgroundColor,
        child: Icon(iconData, color: iconColor),
      ),
      title: Text(categoryName),
      subtitle: tx.note != null && tx.note!.isNotEmpty
          ? Text(tx.note!)
          : null,
      trailing: Text(
        '${isIncome ? '+' : '-'} ${formatter.format(tx.amount)}',
        style: fonts.labelLarge!.copyWith(
          color: isIncome ? Colors.green : colors.error,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
