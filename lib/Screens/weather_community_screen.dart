import 'package:flutter/material.dart';

class WeatherCommunityScreen extends StatefulWidget {
  const WeatherCommunityScreen({Key? key}) : super(key: key);

  @override
  _WeatherCommunityScreenState createState() => _WeatherCommunityScreenState();
}

class _WeatherCommunityScreenState extends State<WeatherCommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Community'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Discussions'),
            Tab(text: 'Photos'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search community...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDiscussionsTab(),
                _buildPhotosTab(),
                _buildEventsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDiscussionsTab() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildDiscussionPost(
          'Weather Pattern Discussion $index',
          'User${index + 1}',
          'Discussion about current weather patterns and their effects...',
          DateTime.now().subtract(Duration(hours: index)),
          index * 5,
          index * 3,
        );
      },
    );
  }

  Widget _buildPhotosTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildPhotoCard(
          'Weather Photo $index',
          'User${index + 1}',
          'assets/weather_photo_placeholder.jpg',
          DateTime.now().subtract(Duration(hours: index)),
        );
      },
    );
  }

  Widget _buildEventsTab() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildEventCard(
          'Weather Watching Event ${index + 1}',
          'Join us for a community weather watching session!',
          DateTime.now().add(Duration(days: index + 1)),
          20 - index,
        );
      },
    );
  }

  Widget _buildDiscussionPost(String title, String author, String content,
      DateTime timestamp, int likes, int comments) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(author[0]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${timestamp.hour}:${timestamp.minute}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(content),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined),
                  onPressed: () {},
                ),
                Text('$likes'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {},
                ),
                Text('$comments'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(
      String title, String author, String imageUrl, DateTime timestamp) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: const Center(
                child: Icon(Icons.photo, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  author,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
      String title, String description, DateTime date, int attendees) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 4),
            Text(
              'Date: ${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('$attendees people attending'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text('Join'),
        ),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement post creation
              Navigator.pop(context);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
} 