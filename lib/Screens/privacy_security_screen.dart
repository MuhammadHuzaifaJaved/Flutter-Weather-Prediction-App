import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../theme/colors.dart';

class PrivacySecurityScreen extends StatelessWidget {
  static const routeName = '/privacy-security';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy & Security'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final preferences = userProvider.currentUser?.preferences ?? {};

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildSection(
                title: 'Privacy Settings',
                children: [
                  _buildSwitchTile(
                    context: context,
                    title: 'Location Services',
                    subtitle: 'Allow app to access your location',
                    value: preferences['locationEnabled'] ?? true,
                    onChanged: (value) {
                      userProvider.updatePreference('locationEnabled', value);
                    },
                  ),
                  _buildSwitchTile(
                    context: context,
                    title: 'Share Analytics',
                    subtitle: 'Help improve the app by sharing usage data',
                    value: preferences['shareAnalytics'] ?? true,
                    onChanged: (value) {
                      userProvider.updatePreference('shareAnalytics', value);
                    },
                  ),
                  _buildSwitchTile(
                    context: context,
                    title: 'Personalized Content',
                    subtitle: 'Receive personalized weather insights',
                    value: preferences['personalizedContent'] ?? true,
                    onChanged: (value) {
                      userProvider.updatePreference('personalizedContent', value);
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildSection(
                title: 'Security',
                children: [
                  _buildSwitchTile(
                    context: context,
                    title: 'Biometric Authentication',
                    subtitle: 'Use fingerprint or face ID to secure the app',
                    value: preferences['biometricAuth'] ?? false,
                    onChanged: (value) {
                      userProvider.updatePreference('biometricAuth', value);
                    },
                  ),
                  _buildSwitchTile(
                    context: context,
                    title: 'Remember Login',
                    subtitle: 'Stay logged in on this device',
                    value: preferences['rememberLogin'] ?? true,
                    onChanged: (value) {
                      userProvider.updatePreference('rememberLogin', value);
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildSection(
                title: 'Data Management',
                children: [
                  ListTile(
                    title: Text('Clear Search History'),
                    subtitle: Text('Remove all your search history'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Clear Search History'),
                          content: Text(
                            'Are you sure you want to clear your search history? This action cannot be undone.'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Implement clear search history
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Search history cleared')),
                                );
                              },
                              child: Text(
                                'Clear',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Download My Data'),
                    subtitle: Text('Get a copy of your personal data'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implement data download
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('This feature is coming soon'),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Delete Account'),
                    subtitle: Text('Permanently delete your account and data'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Account'),
                          content: Text(
                            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Implement account deletion
                                Navigator.pop(context);
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
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