import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naspend/data/model/chart_data.dart';
import 'package:naspend/shared/widgets/component_screen.dart';
import 'package:naspend/ui/dashboard/view_model/dashboard_view_model.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

const double narrowScreenWidthThreshold = 500;
const Widget rowDivider = SizedBox(width: 20);
const Widget colDivider = SizedBox(height: 10);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;

    final viewModel = context.watch<DashboardViewModel>();

    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return DefaultTabController(
      length: viewModel.tabs.length,
      child: Expanded(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: viewModel.previousMonth,
                        ),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => viewModel.pickMonth(context),
                            label: Text(viewModel.formattedDate),
                            icon: const Icon(Icons.calendar_today),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: viewModel.nextMonth,
                        ),
                      ],
                    ),
                    colDivider,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ComponentDecoration(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text('Chi tiêu', style: fonts.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                                          StreamBuilder<double>(
                                            stream: viewModel.totalExpenseStream,
                                            builder: (context, snapshot) {
                                              final total = snapshot.data ?? 0.0;
                                              return Text(
                                                '-${currencyFormatter.format(total)}',
                                                style: fonts.labelLarge!.copyWith(color: colors.error),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const VerticalDivider(),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text('Thu nhập', style: fonts.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                                          StreamBuilder<double>(
                                            stream: viewModel.totalIncomeStream,
                                            builder: (context, snapshot) {
                                              final total = snapshot.data ?? 0.0;
                                              return Text(
                                                '+${currencyFormatter.format(total)}',
                                                style: fonts.labelLarge!.copyWith(color: Colors.green),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            colDivider,
                            const Divider(),
                            colDivider,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(child: Text('Thu chi', style: fonts.titleMedium!.copyWith(fontWeight: FontWeight.bold))),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: StreamBuilder<double>(
                                    stream: viewModel.balanceStream,
                                    builder: (context, snapshot) {
                                      final balance = snapshot.data ?? 0.0;
                                      return Text(
                                        currencyFormatter.format(balance),
                                        style: fonts.titleLarge!.copyWith(
                                          color: balance >= 0 ? colors.primary : colors.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    colDivider,
                  ],
                ),
              ),
              SliverAppBar(
                pinned: true,
                primary: false,
                automaticallyImplyLeading: false,
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                titleSpacing: 0,
                title: TabBar(
                  tabs: viewModel.tabs
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildChartTab(
                context,
                stream: viewModel.expenseChartDataStream,
              ),
              _buildChartTab(
                context,
                stream: viewModel.incomeChartDataStream,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartListItem(BuildContext context, ChartData data) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    final backgroundColor = Color(data.backgroundColorValue ?? 0xffE0E0E0);
    final iconColor = Color(data.iconColorValue ?? 0xff616161);
    final iconData = IconData(data.iconCodePoint ?? Icons.help_outline.codePoint, fontFamily: 'MaterialIcons');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: backgroundColor,
        child: Icon(iconData, color: iconColor),
      ),
      title: Text(data.x, style: fonts.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormatter.format(data.y),
                style: fonts.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${data.size?.toStringAsFixed(1)}%',
                style: fonts.bodySmall!.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        ],
      ),
      onTap: () {

      },
    );
  }

  Widget _buildChartTab(BuildContext context, {required Stream<List<ChartData>> stream}) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return StreamBuilder<List<ChartData>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu cho tháng này.'));
        }

        final chartData = snapshot.data!;

        return ListView(
          children: [
            colDivider,
            SfCircularChart(
              tooltipBehavior: TooltipBehavior(
                enable: true,
                builder: (data, point, series, pointIndex, seriesIndex) {
                  final ChartData item = data;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${item.x}: ${currencyFormatter.format(item.y)} (${item.size!.toStringAsFixed(1)}%)',
                      style: fonts.labelLarge!.copyWith(
                          color: colors.onPrimary
                      ),
                    ),
                  );
                },
              ),
              series: <CircularSeries>[
                DoughnutSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, int index) => data.x,
                  yValueMapper: (ChartData data, int index) => data.y,
                  dataLabelMapper: (ChartData data, int index) =>
                  '${data.x}\n${data.size?.toStringAsFixed(1)}%',
                  radius: '70%',
                  innerRadius: '50%',
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelIntersectAction: LabelIntersectAction.shift,
                    labelPosition: ChartDataLabelPosition.outside,
                    connectorLineSettings: ConnectorLineSettings(
                        type: ConnectorType.curve,
                        length: '10%'
                    ),
                  ),
                ),
              ],
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chartData.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final data = chartData[index];
                return _buildChartListItem(context, data);
              },
            ),
          ],
        );
      },
    );
  }
}

