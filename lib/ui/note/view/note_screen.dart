import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naspend/core/router/app_routes.dart';
import 'package:naspend/shared/widgets/component_screen.dart';
import 'package:naspend/ui/note/view_model/note_view_model.dart';
import 'package:provider/provider.dart';

const Widget rowDivider = SizedBox(width: 20);
const Widget colDivider = SizedBox(height: 10);
const smallSpacing = 10.0;

class NoteScreen extends StatelessWidget {
  const NoteScreen({super.key});

  Widget schemeLabel(String brightness) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Text(
        brightness,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
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
                children: viewModel.tabs.map((Tab tab) {
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
                                    const Divider(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: smallSpacing, vertical: 5.0),
                                      child: TextField(
                                        controller: viewModel.controllerOutlined,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.edit_outlined),
                                          suffixIcon: ClearButton(controller: viewModel.controllerOutlined),
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
                                              controller: viewModel.controllerOutlined,
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(Icons.monetization_on_outlined),
                                                suffixIcon: ClearButton(controller: viewModel.controllerOutlined),
                                                labelText: 'Tiền chi',
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
                                  const CarouselWidget(),
                                ]
                              )
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FilledButton(
                          onPressed: () {

                          },
                          child: Center(child: Text('Lưu ${viewModel.tabs.indexOf(tab) == 0 ? 'chi tiêu' : 'thu nhập'}')),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        )
      ),
    );
  }
}

enum CardInfo {
  more('Thêm mới', Icons.add, Color(0xff201D1C), Color(0xffE3DFD8)),
  camera('Cameras', Icons.video_call, Color(0xff2354C7), Color(0xffECEFFD)),
  lighting('Lighting', Icons.lightbulb, Color(0xff806C2A), Color(0xffFAEEDF)),
  climate('Climate', Icons.thermostat, Color(0xffA44D2A), Color(0xffFAEDE7)),
  wifi('Wifi', Icons.wifi, Color(0xff417345), Color(0xffE5F4E0)),
  media('Media', Icons.library_music, Color(0xff2556C8), Color(0xffECEFFD)),
  security('Security', Icons.crisis_alert, Color(0xff794C01), Color(0xffFAEEDF)),
  safety('Safety', Icons.medical_services, Color(0xff2251C5), Color(0xffECEFFD));

  const CardInfo(this.label, this.icon, this.color, this.backgroundColor);
  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
}

class CarouselWidget extends StatelessWidget {
  const CarouselWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;

    final viewModel = context.watch<NoteViewModel>();

    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: 150),
      child: CarouselView(
        shrinkExtent: 80,
        itemExtent: 150,
        itemSnapping: true,
        onTap: (index) {
          final tappedCard = CardInfo.values[index];

          if (tappedCard == CardInfo.more) {
            context.push(AppRoutes.category);
          } else {
            context.read<NoteViewModel>().selectCard(tappedCard);
          }
        },
        children: CardInfo.values.map((info) {
          final bool isSelected = viewModel.selectedCard == info;

          return Container(
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: info.backgroundColor,
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
                    Icon(info.icon, color: info.color, size: 32.0),
                    Text(
                      info.label,
                      style: fonts.labelLarge!.copyWith(
                        color: info.color,
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
        }).toList(),
      ),
    );
  }
}