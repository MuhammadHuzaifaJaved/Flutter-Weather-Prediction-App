import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      size: 60,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Weather App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Features'),
                  _buildFeatureItem('Real-time weather updates'),
                  _buildFeatureItem('7-day weather forecast'),
                  _buildFeatureItem('Weather comparison between cities'),
                  _buildFeatureItem('Weather statistics and charts'),
                  _buildFeatureItem('Weather sharing capabilities'),
                  _buildFeatureItem('Latest weather news'),
                  
                  const SizedBox(height: 20),
                  _buildSectionTitle('Data Sources'),
                  _buildInfoCard(
                    'OpenWeather API',
                    'Weather data provided by OpenWeather',
                    Icons.cloud_outlined,
                    () => _launchURL('https://openweathermap.org'),
                  ),
                  _buildInfoCard(
                    'News API',
                    'Weather news provided by NewsAPI',
                    Icons.newspaper,
                    () => _launchURL('https://newsapi.org'),
                  ),
                  
                  const SizedBox(height: 20),
                  _buildSectionTitle('Developer'),
                  _buildInfoCard(
                    'Created by Huzaifa Javed',
                    'Flutter Weather App',
                    Icons.code,
                    () => _launchURL('https://github.com/yourusername'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Text(feature),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
} 