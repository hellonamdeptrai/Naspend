import 'package:flutter/material.dart';
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

    final List<ChartSampleData> _chartData = <ChartSampleData>[
      ChartSampleData(x: 'Food', y: 23, size: 10),
      ChartSampleData(x: 'Loan due', y: 0, size: 10),
      ChartSampleData(x: 'Medical', y: 23, size: 10),
      ChartSampleData(x: 'Movies', y: 0, size: 10),
      ChartSampleData(x: 'Travel', y: 32, size: 10),
      ChartSampleData(x: 'Savings', y: 7, size: 10),
      ChartSampleData(x: 'Others', y: 15, size: 10),
    ];

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
                                          Text(
                                            'Chi tiêu',
                                            style: fonts.titleMedium!.copyWith(
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                          Text(
                                            '-100.000đ',
                                            style: fonts.labelLarge!.copyWith(
                                              color: colors.error
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                    const VerticalDivider(),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Thu nhập',
                                            style: fonts.titleMedium!.copyWith(
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                          Text(
                                            '+250.000đ',
                                            style: fonts.labelLarge!.copyWith(
                                              color: Colors.green
                                            )
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
                                Flexible(
                                  child: Text(
                                    'Thu chi',
                                    style: fonts.titleMedium!.copyWith(
                                      fontWeight: FontWeight.bold
                                    )
                                  )
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '+250.000đ',
                                    style: fonts.titleLarge!.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold
                                    )
                                  )
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
              Column(
                children: [
                  colDivider,
                  SfCircularChart(
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      builder: (data, point, series, pointIndex, seriesIndex) {
                        final ChartSampleData item = data;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${item.x}: ${item.y!.toStringAsFixed(0)}đ (${item.size!.toStringAsFixed(1)}%)',
                            style: fonts.labelLarge!.copyWith(
                              color: colors.onPrimary
                            ),
                          ),
                        );
                      },
                    ),
                    series: <CircularSeries>[
                      PieSeries<ChartSampleData, String>(
                        dataSource: _chartData,
                        xValueMapper: (ChartSampleData data, int index) => data.x,
                        yValueMapper: (ChartSampleData data, int index) => data.y,
                        dataLabelMapper: (ChartSampleData data, int index) => data.x,
                        radius: '55%',
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelIntersectAction: LabelIntersectAction.none,
                          labelPosition: ChartDataLabelPosition.outside,
                          connectorLineSettings: ConnectorLineSettings(
                            type: ConnectorType.curve,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  Text('Nội dung của Tab Thu nhập', style: fonts.bodyLarge),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartSampleData {
  ChartSampleData({
    this.x,
    this.y,
    this.size,
  });

  final dynamic x;
  final num? y;
  final num? size;
}

