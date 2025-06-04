import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NotificationsScreen extends StatelessWidget {
  static const routeName = '/notifications';

  const NotificationsScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _mockNotifications = const [
    {
      'title': 'Weather Alert',
      'message': 'Heavy rain expected in your area',
      'time': '2 hours ago',
      'isRead': false,
      'icon': Icons.warning_amber_rounded,
    },
    {
      'title': 'Temperature Update',
      'message': 'Temperature will drop by 5°C tonight',
      'time': '5 hours ago',
      'isRead': true,
      'icon': Icons.thermostat,
    },
    {
      'title': 'Wind Alert',
      'message': 'Strong winds expected tomorrow',
      'time': '1 day ago',
      'isRead': true,
      'icon': Icons.air,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all),
            onPressed: () {
              // TODO: Implement mark all as read
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Marked all as read'))
              );
            },
          ),
        ],
      ),
      body: _mockNotifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, 
                       size: 64, 
                       color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications',
                       style: TextStyle(
                         fontSize: 18,
                         color: Colors.grey,
                       )),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _mockNotifications.length,
              itemBuilder: (context, index) {
                final notification = _mockNotifications[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notification['isRead'] 
                          ? Colors.grey[200] 
                          : primaryBlue.withOpacity(0.2),
                      child: Icon(
                        notification['icon'],
                        color: notification['isRead'] 
                            ? Colors.grey 
                            : primaryBlue,
                      ),
                    ),
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: notification['isRead'] 
                            ? FontWeight.normal 
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['message']),
                        SizedBox(height: 4),
                        Text(
                          notification['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      // TODO: Implement notification detail view
                    },
                  ),
                );
              },
            ),
    );
  }
} 