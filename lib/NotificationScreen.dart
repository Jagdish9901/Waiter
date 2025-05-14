import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:waiter_app/providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFB300),
        elevation: 4,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              return TextButton(
                onPressed: provider.unreadCount > 0
                    ? () => provider.markAllAsRead()
                    : null,
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        provider.unreadCount > 0 ? Colors.black : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFB300),
              Color(0xFFFFC107),
              Color(0xFFFFE082),
            ],
          ),
        ),
        child: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off,
                      size: 50,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'No new notifications',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'New ready orders will appear here',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: const Color(0xFFFFB300),
              onRefresh: () async {
                // Add your refresh logic here if needed
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return Dismissible(
                    key: Key(notification.orderNo),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      provider.removeNotification(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Notification for order #${notification.orderNo} removed"),
                          backgroundColor: Colors.red.shade400,
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          provider.markAsRead(index);
                          // Optional: Add navigation to order details
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 10.w,
                                height: 5.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  notification.isRead
                                      ? Icons.check_circle_outline
                                      : Icons.check_circle_outline,
                                  color: notification.isRead
                                      ? Colors.grey.shade600
                                      : Colors.green,
                                  size: 24.sp,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${notification.orderNo} Ready',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: notification.isRead
                                            ? Colors.grey.shade600
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Table: ${notification.tableName}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: notification.isRead
                                            ? Colors.grey.shade500
                                            : Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 8),
                                  if (!notification.isRead)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'NEW',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
              ),
            );
          },
        ),
      ),
    );
  }
}
