import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../provider/weatherProvider.dart';

class WeatherNewsScreen extends StatefulWidget {
  const WeatherNewsScreen({Key? key}) : super(key: key);

  @override
  _WeatherNewsScreenState createState() => _WeatherNewsScreenState();
}

class _WeatherNewsScreenState extends State<WeatherNewsScreen> {
  List<Map<String, dynamic>> newsArticles = [];
  bool isLoading = true;
  String selectedCategory = 'Latest';
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  String? selectedLocation;
  String? selectedCountry;
  bool showSearchResults = false;

  @override
  void initState() {
    super.initState();
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    _searchController.text = weatherProvider.weather.city;
    selectedLocation = weatherProvider.weather.city;
    selectedCountry = weatherProvider.weather.countryCode;
    fetchWeatherNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        showSearchResults = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      showSearchResults = true;
    });

    try {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=${weatherProvider.apiKey}'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          searchResults = data.map((item) => {
            'name': item['name'] ?? '',
            'state': item['state'] ?? '',
            'country': item['country'] ?? '',
            'display': [
              item['name'] ?? '',
              item['state'] ?? '',
              item['country'] ?? ''
            ].where((e) => e.isNotEmpty).join(', '),
          }).toList();
          isSearching = false;
        });
      }
    } catch (e) {
      print('Error searching locations: $e');
      setState(() {
        isSearching = false;
        searchResults = [];
      });
    }
  }

  Future<void> fetchWeatherNews() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final location = selectedLocation ?? Provider.of<WeatherProvider>(context, listen: false).weather.city;
      final country = selectedCountry ?? Provider.of<WeatherProvider>(context, listen: false).weather.countryCode;
      
      // Create category-specific queries
      String searchQuery;
      switch (selectedCategory.toLowerCase()) {
        case 'storms':
          searchQuery = Uri.encodeComponent('(storm OR thunderstorm OR hurricane OR cyclone OR tornado) weather in $location $country');
          break;
        case 'climate':
          searchQuery = Uri.encodeComponent('(climate change OR global warming OR temperature trends OR climate patterns) in $location $country');
          break;
        case 'forecasts':
          searchQuery = Uri.encodeComponent('(weather forecast OR prediction OR meteorological outlook) for $location $country');
          break;
        case 'alerts':
          searchQuery = Uri.encodeComponent('(weather warning OR alert OR severe weather OR extreme conditions) in $location $country');
          break;
        case 'latest':
        default:
          searchQuery = Uri.encodeComponent('(weather OR climate OR forecast OR temperature) in $location $country');
          break;
      }
      
      final response = await http.get(
        Uri.parse('https://newsapi.org/v2/everything?q=$searchQuery&sortBy=publishedAt&apiKey=43a57814f585498286d6467328afe9d4'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = List<Map<String, dynamic>>.from(data['articles']);
        
        final filteredArticles = articles.where((article) {
          final imageUrl = article['urlToImage']?.toString() ?? '';
          final title = article['title']?.toString().toLowerCase() ?? '';
          final description = article['description']?.toString().toLowerCase() ?? '';
          
          bool isRelevant = true;
          if (selectedCategory.toLowerCase() != 'latest') {
            final categoryKeywords = _getCategoryKeywords(selectedCategory);
            isRelevant = categoryKeywords.any((keyword) => 
              title.contains(keyword) || description.contains(keyword)
            );
          }
          
          return imageUrl.isNotEmpty && 
                 !imageUrl.contains('placeholder') && 
                 !imageUrl.contains('default') &&
                 isRelevant;
        }).toList();

        setState(() {
          newsArticles = filteredArticles;
          isLoading = false;
          showSearchResults = false;
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading news: ${e.toString()}';
      });
    }
  }

  List<String> _getCategoryKeywords(String category) {
    switch (category.toLowerCase()) {
      case 'storms':
        return [
          'storm', 'thunder', 'lightning', 'hurricane', 'cyclone', 
          'tornado', 'wind', 'rainfall', 'precipitation'
        ];
      case 'climate':
        return [
          'climate', 'global warming', 'temperature', 'trend', 
          'pattern', 'change', 'environmental', 'warming'
        ];
      case 'forecasts':
        return [
          'forecast', 'prediction', 'outlook', 'expected', 
          'meteorological', 'weather report', 'conditions'
        ];
      case 'alerts':
        return [
          'alert', 'warning', 'severe', 'extreme', 'hazard', 
          'emergency', 'caution', 'advisory'
        ];
      default:
        return ['weather', 'climate', 'forecast', 'temperature'];
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open article')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weather News'),
            Text(
              selectedLocation != null ? '$selectedLocation, $selectedCountry' : 'Select Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchWeatherNews,
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: fetchWeatherNews,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Location Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  searchResults = [];
                                  showSearchResults = false;
                                });
                              },
                            )
                          : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (value) {
                        searchLocations(value);
                      },
                    ),
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  _buildFeaturedNews(),
                  _buildNewsCategories(),
                  _buildNewsList(),
                ],
              ),
            ),
          ),
          // Search Results Overlay
          if (showSearchResults)
            Positioned(
              top: 76, // Below the search bar
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: isSearching
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final result = searchResults[index];
                          return ListTile(
                            title: Text(result['name']?.toString() ?? ''),
                            subtitle: Text(
                              [result['state']?.toString(), result['country']?.toString()]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(', '),
                            ),
                            onTap: () {
                              setState(() {
                                selectedLocation = result['name']?.toString();
                                selectedCountry = result['country']?.toString();
                                _searchController.text = result['display']?.toString() ?? '';
                                showSearchResults = false;
                              });
                              fetchWeatherNews();
                            },
                          );
                        },
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedNews() {
    if (isLoading) {
      return Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (newsArticles.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.newspaper, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No news available for this location',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final featuredArticle = newsArticles.first;
    return GestureDetector(
      onTap: () => _launchURL(featuredArticle['url'] ?? ''),
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              featuredArticle['urlToImage'] ?? 
              'https://via.placeholder.com/400x200?text=No+Image',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Featured Story',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                featuredArticle['title'] ?? 'No title available',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCategories() {
    final categories = [
      'Latest',
      'Storms',
      'Climate',
      'Forecasts',
      'Alerts',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 40,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == selectedCategory;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = category;
                    });
                    fetchWeatherNews();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                    elevation: isSelected ? 2 : 0,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(category),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (newsArticles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.newspaper, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No weather news available for this location',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: newsArticles.length,
      itemBuilder: (context, index) {
        final article = newsArticles[index];
        return _buildNewsItem(
          article['title'] ?? 'No title',
          article['description'] ?? 'No description available',
          article['urlToImage'] ?? 'https://via.placeholder.com/100x100?text=No+Image',
          article['publishedAt'] ?? '',
          article['url'] ?? '',
        );
      },
    );
  }

  Widget _buildNewsItem(
    String title,
    String description,
    String imageUrl,
    String publishedAt,
    String articleUrl,
  ) {
    final DateTime? date = DateTime.tryParse(publishedAt);
    final String timeAgo = date != null 
      ? _getTimeAgo(date)
      : 'Unknown time';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _launchURL(articleUrl),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
} 