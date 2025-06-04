import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/colors.dart';
import 'dart:ui';
import 'dart:math' as math;

class SubscriptionScreen extends StatefulWidget {
  static const routeName = '/subscription';
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _selectedPlan = 1;
  double _page = 1.0;

  final List<Map<String, dynamic>> plans = [
    {
      'name': 'Basic',
      'price': '4.99',
      'period': 'month',
      'color': Color(0xFF4A90E2),
      'features': [
        'Ad-free experience',
        '7-day forecast',
        'Basic weather alerts',
        'Standard weather maps',
      ],
      'icon': 'https://assets9.lottiefiles.com/packages/lf20_qm8eqzse.json'
    },
    {
      'name': 'Premium',
      'price': '9.99',
      'period': 'month',
      'color': Color(0xFF9B51E0),
      'features': [
        'Everything in Basic',
        '15-day forecast',
        'Advanced weather alerts',
        'Detailed weather maps',
        'Historical weather data',
        'Priority support',
      ],
      'icon': 'https://assets9.lottiefiles.com/packages/lf20_jvkjhuid.json'
    },
    {
      'name': 'Pro',
      'price': '99.99',
      'period': 'year',
      'color': Color(0xFF2ECC71),
      'features': [
        'Everything in Premium',
        '30-day forecast',
        'API access',
        'Custom alerts',
        'Weather data export',
        '24/7 Priority support',
      ],
      'icon': 'https://assets9.lottiefiles.com/packages/lf20_DMgKk1.json'
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _selectedPlan,
      viewportFraction: 0.8,
    )..addListener(() {
        setState(() {
          _page = _pageController.page ?? 0;
        });
      });

    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildFeatureItem(String feature, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check,
              color: color,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> plan, int index) {
    final double distance = (_page - index).abs();
    final isSelected = _selectedPlan == index;
    final double scale = 1 - (distance * 0.1).clamp(0.0, 0.4);
    final double verticalOffset = distance * 20;

    return Transform.translate(
      offset: Offset(0, verticalOffset),
      child: Transform.scale(
        scale: scale,
        child: Container(
          margin: EdgeInsets.fromLTRB(10, 20, 10, 40),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: plan['color'].withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header Section
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        plan['color'],
                        plan['color'].withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Lottie.network(
                          plan['icon'],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.cloud_outlined,
                                size: 60,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            );
                          },
                          frameBuilder: (context, child, composition) {
                            if (composition == null) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              );
                            }
                            return child;
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\$${plan['price']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '/${plan['period']}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Features Section
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: [
                              ...plan['features'].map<Widget>((feature) =>
                                _buildFeatureItem(feature, plan['color']),
                              ).toList(),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Subscription system coming soon!'),
                                  backgroundColor: plan['color'],
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? plan['color'] : Colors.grey[200],
                              foregroundColor: isSelected ? Colors.white : plan['color'],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              isSelected ? 'Choose Plan' : 'Select',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select the perfect plan for your weather needs',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: plans.length,
                onPageChanged: (index) {
                  setState(() => _selectedPlan = index);
                  _animationController.forward(from: 0);
                },
                itemBuilder: (context, index) {
                  return _buildSubscriptionCard(plans[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 