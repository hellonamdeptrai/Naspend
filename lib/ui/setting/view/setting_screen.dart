import 'package:flutter/material.dart';
import 'package:naspend/ui/setting/view_model/setting_view_model.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;
    final viewModel = context.watch<SettingViewModel>();

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _buildSectionTitle(context, 'Thông báo'),
          Card(
            elevation: 0,
            color: colors.surfaceContainer,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Nhắc nhở hàng ngày'),
                  subtitle: const Text('Nhận thông báo để ghi chép chi tiêu'),
                  value: viewModel.notificationsEnabled,
                  onChanged: (value) => viewModel.toggleNotifications(value),
                  secondary: const Icon(Icons.notifications_active_outlined),
                ),
                if (viewModel.notificationsEnabled)
                  ListTile(
                    title: const Text('Thời gian nhắc nhở'),
                    trailing: Text(
                      viewModel.notificationTime.format(context),
                      style: fonts.titleMedium!.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    onTap: () => viewModel.selectNotificationTime(context),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Dữ liệu'),
          Card(
            elevation: 0,
            color: colors.surfaceContainer,
            child: ListTile(
              leading: Icon(Icons.delete_forever_outlined, color: colors.error),
              title: Text(
                'Xóa tất cả dữ liệu',
                style: fonts.titleMedium!.copyWith(color: colors.error),
              ),
              subtitle: const Text('Xóa toàn bộ giao dịch và danh mục'),
              onTap: () => viewModel.clearAllData(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final fonts = theme.textTheme;
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title.toUpperCase(),
        style: fonts.labelLarge!.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
