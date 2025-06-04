import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../theme/colors.dart';

class NotificationSettingsScreen extends StatelessWidget {
  static const routeName = '/notification-settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final preferences = userProvider.currentUser?.preferences ?? {};
          
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildSection(
                title: 'Weather Alerts',
                children: [
                  _buildSwitchTile(
                    context: context,
                    title: 'Severe Weather Alerts',
                    subtitle: 'Get notified about severe weather conditions',
                    value: preferences['severeWeatherAlerts'] ?? true,
                    onChanged: (value) {
                      userProvider.updatePreference('severeWeatherAlerts', value);
                    },
                  ),
                  _buildSwitchTile(
                    context: context,
                    title: 'Daily Forecast',
                    subtitle: 'Receive daily weather forecasts',
                    value: preferences['dailyForecast'] ?? false,
                    onChanged: (value) {
                      userProvider.updatePreference('dailyForecast', value);
                    },
                  ),
                  _buildSwitchTile(
                    context: context,
                    title: 'Rain Alerts',
                    subtitle: 'Get notified when rain is expected',
                    value: preferences['rainAlerts'] ?? true,
                    onChanged: (value) {
                      userProvider.updatePreference('rainAlerts', value);
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildSection(
                title: 'Location Updates',
                children: [
                  _buildSwitchTile(
                    context: context,
                    title: 'Location Changes',
                    subtitle: 'Get updates when you change location',
                    value: preferences['locationUpdates'] ?? true,
                    onChanged: (value) {
                      userProvider.updatePreference('locationUpdates', value);
                    },
                  ),
                  _buildSwitchTile(
                    context: context,
                    title: 'Saved Locations',
                    subtitle: 'Receive updates for saved locations',
                    value: preferences['savedLocationUpdates'] ?? true,
                    onChanged: (value) {
                      userProvider.updatePreference('savedLocationUpdates', value);
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildSection(
                title: 'Other Notifications',
                children: [
                  _buildSwitchTile(
                    context: context,
                    title: 'App Updates',
                    subtitle: 'Get notified about new features and updates',
                    value: preferences['appUpdates'] ?? true,
                    onChanged: (value) {
                      userProvider.updatePreference('appUpdates', value);
                    },
                  ),
                  _buildSwitchTile(
                    context: context,
                    title: 'Tips & Tricks',
                    subtitle: 'Receive weather-related tips and advice',
                    value: preferences['tipsAndTricks'] ?? false,
                    onChanged: (value) {
                      userProvider.updatePreference('tipsAndTricks', value);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: primaryBlue,
    );
  }
} 