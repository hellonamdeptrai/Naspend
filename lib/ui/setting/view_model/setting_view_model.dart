import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naspend/core/services/notification_service.dart';
import 'package:naspend/data/datasources/local/database.dart';

class SettingViewModel extends ChangeNotifier {
  final AppDatabase _database;
  final NotificationService _notificationService = NotificationService();

  SettingViewModel(this._database){
    _notificationService.init();
  }

  // Trạng thái bật/tắt thông báo
  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;

  // Thời gian nhận thông báo, mặc định là 8 giờ tối
  TimeOfDay _notificationTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay get notificationTime => _notificationTime;

  // Hàm để bật/tắt thông báo
  Future<void> toggleNotifications(bool value) async {
    if (value) {
      await _notificationService.requestAndroidPermissions();

      final bool permissionsGranted = await _notificationService.arePermissionsGranted();

      if (permissionsGranted) {
        await _notificationService.scheduleDailyReminder(_notificationTime);
        _notificationsEnabled = true;
      } else {
        _notificationsEnabled = false;
      }

    } else {
      await _notificationService.cancelNotifications();
      _notificationsEnabled = false;
    }
    notifyListeners();
  }

  // Hàm để chọn thời gian
  Future<void> selectNotificationTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      helpText: 'Chọn thời gian nhắc nhở',
    );

    if (pickedTime != null && pickedTime != _notificationTime) {
      _notificationTime = pickedTime;
      // Lên lịch lại thông báo với thời gian mới (nếu đang bật)
      if (_notificationsEnabled) {
        _notificationService.scheduleDailyReminder(_notificationTime);
      }
      notifyListeners();
    }
  }

  // Hàm để xóa tất cả dữ liệu
  Future<void> clearAllData(BuildContext context) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, color: colors.error),
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa toàn bộ dữ liệu không? Hành động này không thể hoàn tác.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                context.pop(false);
              },
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: colors.errorContainer,
                foregroundColor: colors.onErrorContainer,
              ),
              child: const Text('Xóa'),
              onPressed: () {
                context.pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await _database.deleteAllData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa toàn bộ dữ liệu.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}