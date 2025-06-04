import 'package:flutter/material.dart';

class WeatherAchievementsScreen extends StatelessWidget {
  const WeatherAchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Achievements'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAchievementStats(),
            const Divider(),
            _buildAchievementsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total Points', '1,250', Icons.stars),
          _buildStatCard('Achievements', '8/20', Icons.emoji_events),
          _buildStatCard('Streak', '5 days', Icons.local_fire_department),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.amber,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsList() {
    final achievements = [
      {
        'title': 'Weather Explorer',
        'description': 'Check weather for 10 different locations',
        'icon': Icons.explore,
        'progress': 0.8,
        'points': 100,
        'isUnlocked': true,
      },
      {
        'title': 'Storm Chaser',
        'description': 'Experience 5 different types of storms',
        'icon': Icons.thunderstorm,
        'progress': 0.6,
        'points': 200,
        'isUnlocked': true,
      },
      {
        'title': 'Early Bird',
        'description': 'Check weather before 6 AM for 7 days',
        'icon': Icons.wb_sunny,
        'progress': 0.4,
        'points': 150,
        'isUnlocked': false,
      },
      {
        'title': 'Weather Sage',
        'description': 'Provide accurate weather feedback 20 times',
        'icon': Icons.psychology,
        'progress': 0.3,
        'points': 300,
        'isUnlocked': false,
      },
      {
        'title': 'Social Butterfly',
        'description': 'Share weather with 10 friends',
        'icon': Icons.share,
        'progress': 0.5,
        'points': 100,
        'isUnlocked': true,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(
          achievement['title'] as String,
          achievement['description'] as String,
          achievement['icon'] as IconData,
          achievement['progress'] as double,
          achievement['points'] as int,
          achievement['isUnlocked'] as bool,
        );
      },
    );
  }

  Widget _buildAchievementCard(
    String title,
    String description,
    IconData icon,
    double progress,
    int points,
    bool isUnlocked,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.amber[100] : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isUnlocked ? Colors.amber[800] : Colors.grey,
          ),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                isUnlocked ? Colors.amber : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$points points',
              style: TextStyle(
                color: isUnlocked ? Colors.amber[800] : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: isUnlocked
            ? const Icon(
                Icons.check_circle,
                color: Colors.green,
              )
            : null,
      ),
    );
  }
} 