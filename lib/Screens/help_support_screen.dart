import 'package:flutter/material.dart';
import '../theme/colors.dart';

class HelpSupportScreen extends StatelessWidget {
  static const routeName = '/help-support';

  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I add a new location?',
      'answer': 'Tap the "+" button in the Saved Locations screen or use the search bar at the top of the home screen to find and add a new location.',
    },
    {
      'question': 'How accurate is the weather data?',
      'answer': 'We use multiple reliable weather data sources and update our forecasts frequently to ensure high accuracy. However, weather predictions can sometimes vary due to rapidly changing conditions.',
    },
    {
      'question': 'Can I change the temperature unit?',
      'answer': 'Yes! Go to Settings and you can switch between Celsius and Fahrenheit.',
    },
    {
      'question': 'How do I enable notifications?',
      'answer': 'Navigate to Profile > Notification Settings and customize which alerts you want to receive.',
    },
    {
      'question': 'Why does the app need my location?',
      'answer': 'Location access helps us provide accurate weather information for your current location. You can disable this in Privacy & Security settings.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Contact Support',
            children: [
              ListTile(
                leading: Icon(Icons.email_outlined, color: primaryBlue),
                title: Text('Email Support'),
                subtitle: Text('Get help via email'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement email support
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening email client...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.chat_outlined, color: primaryBlue),
                title: Text('Live Chat'),
                subtitle: Text('Chat with our support team'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement live chat
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Live chat coming soon')),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            title: 'Frequently Asked Questions',
            children: [
              ...faqs.map((faq) => ExpansionTile(
                title: Text(
                  faq['question']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      faq['answer']!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            title: 'Additional Resources',
            children: [
              ListTile(
                leading: Icon(Icons.book_outlined, color: primaryBlue),
                title: Text('User Guide'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Open user guide
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library_outlined, color: primaryBlue),
                title: Text('Video Tutorials'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Open video tutorials
                },
              ),
              ListTile(
                leading: Icon(Icons.bug_report_outlined, color: primaryBlue),
                title: Text('Report a Bug'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement bug reporting
                },
              ),
            ],
          ),
          SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  'App Version',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '1.0.0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
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
} 