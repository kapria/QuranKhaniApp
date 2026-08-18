import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/khani_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final khaniProvider = Provider.of<KhaniProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: RefreshIndicator(
        onRefresh: () => khaniProvider.fetchNotifications(),
        child: khaniProvider.notifications.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No notifications yet'),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: khaniProvider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = khaniProvider.notifications[index];
                  return Card(
                    color: notification.read ? null : Colors.blue[50],
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        _getIconForType(notification.type),
                        color: notification.read ? Colors.grey : Colors.blue,
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification.message),
                          Text(
                            _formatDate(notification.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: !notification.read
                          ? IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.blue),
                              onPressed: () async {
                                await khaniProvider.markNotificationAsRead(notification.id);
                              },
                            )
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'khani_started':
        return Icons.play_circle_fill;
      case 'khani_ended':
        return Icons.stop_circle;
      case 'stream_started':
        return Icons.live_tv;
      case 'stream_ended':
        return Icons.videocam_off;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
