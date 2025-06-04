import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_animations/simple_animations.dart';
import 'dart:ui';
import '../../theme/colors.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';
import '../../models/user_profile.dart';
import '../edit_profile_screen.dart';
import '../saved_locations_screen.dart';
import '../notification_settings_screen.dart';
import '../privacy_security_screen.dart';
import '../help_support_screen.dart';
import '../../provider/weatherProvider.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _particleController;
  late List<ParticleModel> particles;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    particles = List.generate(20, (index) => ParticleModel());
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _handleEditProfile() {
    Navigator.pushNamed(context, '/edit-profile').then((_) {
      setState(() {}); // Refresh UI after editing profile
    });
  }

  void _handleSavedLocations() {
    Navigator.pushNamed(context, '/saved-locations');
  }

  void _handleNotificationSettings() {
    Navigator.pushNamed(context, '/notification-settings');
  }

  void _handlePrivacySecurity() {
    Navigator.pushNamed(context, '/privacy-security');
  }

  void _handleHelpSupport() {
    Navigator.pushNamed(context, '/help-support');
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<UserProvider>(context, listen: false).logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            ),
          );
        }

        final user = userProvider.currentUser;
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Please log in to view your profile'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              // Animated Background with Particles
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ParticlePainter(
                      particles: particles,
                      animation: _particleController.value,
                    ),
                    child: Container(),
                  );
                },
              ),
              CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 350,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Gradient Background
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryBlue.withOpacity(0.8),
                                  Colors.purple.withOpacity(0.7),
                                  Colors.blue.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                          // Glassmorphism Card
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 200,
                              margin: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.white.withOpacity(0.1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ScaleTransition(
                                        scale: _scaleAnimation,
                                        child: Hero(
                                          tag: 'profile_picture',
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 15,
                                                  offset: Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 50,
                                              backgroundColor: Colors.white,
                                              child: user.photoUrl != null
                                                ? CircleAvatar(
                                                    radius: 47,
                                                    backgroundImage: NetworkImage(user.photoUrl!),
                                                  )
                                                : CircleAvatar(
                                                    radius: 47,
                                                    backgroundColor: primaryBlue,
                                                    child: Text(
                                                      user.name[0].toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 32,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: ShaderMask(
                                          shaderCallback: (bounds) => LinearGradient(
                                            colors: [Colors.white, Colors.blue.shade200],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds),
                                          child: Text(
                                            user.name,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: Text(
                                          user.email,
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: AnimationLimiter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                            children: [
                              _buildStatsCard(user),
                              _buildAnimatedListTile(
                                icon: Icons.person_outline,
                                title: 'Edit Profile',
                                onTap: _handleEditProfile,
                              ),
                              _buildAnimatedListTile(
                                icon: Icons.location_on_outlined,
                                title: 'Saved Locations',
                                onTap: _handleSavedLocations,
                              ),
                              _buildAnimatedListTile(
                                icon: Icons.notifications_outlined,
                                title: 'Notification Settings',
                                onTap: _handleNotificationSettings,
                              ),
                              _buildAnimatedListTile(
                                icon: Icons.security_outlined,
                                title: 'Privacy & Security',
                                onTap: _handlePrivacySecurity,
                              ),
                              _buildAnimatedListTile(
                                icon: Icons.help_outline,
                                title: 'Help & Support',
                                onTap: _handleHelpSupport,
                              ),
                              _buildAnimatedListTile(
                                icon: Icons.logout,
                                title: 'Logout',
                                isLogout: true,
                                onTap: _handleLogout,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(UserProfile user) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryBlue.withOpacity(0.7),
            Colors.purple.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Saved\nLocations', user.savedLocations.length.toString()),
          _buildStatItem('Weather\nAlerts', user.preferences['weatherAlerts']?.toString() ?? '0'),
          _buildStatItem(
            'Days\nTracked',
            DateTime.now().difference(user.createdAt).inDays.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.person_outline;
      case 1:
        return Icons.location_on_outlined;
      case 2:
        return Icons.notifications_outlined;
      case 3:
        return Icons.security_outlined;
      case 4:
        return Icons.help_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildAnimatedListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isLogout ? Colors.red.withOpacity(0.1) : primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isLogout ? Colors.red : primaryBlue,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isLogout ? Colors.red : Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (!isLogout)
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ParticleModel {
  late Offset position;
  late double speed;
  late double theta;
  late double radius;

  ParticleModel() {
    position = Offset(
      math.Random().nextDouble() * 400,
      math.Random().nextDouble() * 800,
    );
    speed = math.Random().nextDouble() * 2.0 + 0.5;
    theta = math.Random().nextDouble() * 2 * math.pi;
    radius = math.Random().nextDouble() * 2 + 1;
  }
}

class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;
  final double animation;

  ParticlePainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.1);

    for (var particle in particles) {
      var progress = (animation * particle.speed) % 1.0;
      var offset = Offset(
        particle.position.dx + progress * 100 * math.cos(particle.theta),
        particle.position.dy + progress * 100 * math.sin(particle.theta),
      );
      canvas.drawCircle(offset, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
} 