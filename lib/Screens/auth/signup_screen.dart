import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_weather/widgets/animated_button.dart';
import 'package:simple_animations/simple_animations.dart';
import './login_screen.dart';
import '../homeScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_weather/services/auth_service.dart';

// Particle system for stars and constellations
class StarParticle {
  late double x;
  late double y;
  late double size;
  late double brightness;
  late double speed;
  late bool isConstellation;
  late List<StarParticle> connectedStars;

  StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
    required this.speed,
    this.isConstellation = false,
    this.connectedStars = const [],
  });

  static StarParticle random(Size size) {
    return StarParticle(
      x: math.Random().nextDouble() * size.width,
      y: math.Random().nextDouble() * size.height,
      size: math.Random().nextDouble() * 2 + 1,
      brightness: math.Random().nextDouble(),
      speed: math.Random().nextDouble() * 0.5 + 0.1,
    );
  }
}

// Nebula effect
class NebulaCloud {
  late double x;
  late double y;
  late double size;
  late Color color;
  late double opacity;

  NebulaCloud({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.opacity,
  });

  static NebulaCloud random(Size size) {
    final colors = [
      Color(0xFF9C27B0),
      Color(0xFF3F51B5),
      Color(0xFF2196F3),
      Color(0xFF00BCD4),
    ];
    return NebulaCloud(
      x: math.Random().nextDouble() * size.width,
      y: math.Random().nextDouble() * size.height,
      size: math.Random().nextDouble() * 200 + 100,
      color: colors[math.Random().nextInt(colors.length)],
      opacity: math.Random().nextDouble() * 0.3 + 0.1,
    );
  }
}

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isHovering = false;

  late AnimationController _nebulaAnimationController;
  late AnimationController _starAnimationController;
  late Animation<Color?> _colorAnimation;
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;

  final _customTween = MovieTween()
    ..tween('opacity', Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500));

  final List<StarParticle> stars = [];
  final List<NebulaCloud> nebulaClouds = [];
  final List<StarParticle> shootingStars = [];

  @override
  void initState() {
    super.initState();
    _nebulaAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _starAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _colorAnimation = ColorTween(
      begin: Color(0xFF6A1B9A),
      end: Color(0xFF4A148C),
    ).animate(
      CurvedAnimation(
        parent: _nebulaAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideAnimationController, curve: Curves.easeOutCubic),
    );

    _slideAnimationController.forward();

    // Initialize stars and nebula clouds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 100; i++) {
        stars.add(StarParticle.random(size));
      }
      for (int i = 0; i < 5; i++) {
        nebulaClouds.add(NebulaCloud.random(size));
      }
      // Create constellations
      for (int i = 0; i < 3; i++) {
        final constellation = List.generate(
          5,
          (index) => StarParticle.random(size)..isConstellation = true,
        );
        for (int j = 0; j < constellation.length - 1; j++) {
          constellation[j].connectedStars.add(constellation[j + 1]);
        }
        stars.addAll(constellation);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _nebulaAnimationController.dispose();
    _starAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  Future<void> _handleSignup() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Starting signup process...');
      print('Email: ${_emailController.text.trim()}');
      print('Username: ${_usernameController.text.trim()}');
      
      final userCredential = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
      );
      
      print('Signup successful. User ID: ${userCredential.user?.uid}');
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    } catch (e) {
      print('Error during signup: $e');
      if (mounted) {
        String errorMessage = 'An error occurred during signup';
        
        if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'This email is already registered';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'Password is too weak';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Invalid email address';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final availableHeight = size.height - padding.top - padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // Cosmic background with nebula and stars
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _nebulaAnimationController,
                _starAnimationController,
              ]),
              builder: (context, child) {
                return CustomPaint(
                  painter: CosmicPainter(
                    stars: stars,
                    nebulaClouds: nebulaClouds,
                    starAnimation: _starAnimationController.value,
                    nebulaAnimation: _nebulaAnimationController.value,
                    baseColor: _colorAnimation.value ?? Color(0xFF6A1B9A),
                  ),
                );
              },
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Container(
              height: availableHeight,
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlayAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Text(
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    // Username field
                    _buildTextField(
                      controller: _usernameController,
                      icon: Icons.person,
                      label: 'Username',
                    ),
                    SizedBox(height: 20),
                    // Email field
                    _buildTextField(
                      controller: _emailController,
                      icon: Icons.email,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20),
                    // Password field
                    _buildTextField(
                      controller: _passwordController,
                      icon: Icons.lock,
                      label: 'Password',
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    // Confirm password field
                    _buildTextField(
                      controller: _confirmPasswordController,
                      icon: Icons.lock,
                      label: 'Confirm Password',
                      isPassword: true,
                      isPasswordVisible: _isConfirmPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    SizedBox(height: 40),
                    // Sign up button
                    _buildSignupButton(),
                    SizedBox(height: 20),
                    // Login link
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        'Already have an account? Login',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.white),
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSignupButton() {
    return AnimatedButton(
      onPressed: _isLoading ? null : () {
        _handleSignup();
      },
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

// Custom painter for cosmic effects
class CosmicPainter extends CustomPainter {
  final List<StarParticle> stars;
  final List<NebulaCloud> nebulaClouds;
  final double starAnimation;
  final double nebulaAnimation;
  final Color baseColor;

  CosmicPainter({
    required this.stars,
    required this.nebulaClouds,
    required this.starAnimation,
    required this.nebulaAnimation,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background gradient
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor,
          Color(0xFF1A237E),
          Color(0xFF000000),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw nebula clouds
    for (var cloud in nebulaClouds) {
      final cloudPaint = Paint()
        ..color = cloud.color.withOpacity(
          (cloud.opacity * (math.sin(nebulaAnimation * math.pi * 2) * 0.3 + 0.7))
              .clamp(0.0, 1.0),
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 50);

      canvas.drawCircle(
        Offset(cloud.x, cloud.y),
        cloud.size * (1 + math.sin(nebulaAnimation * math.pi) * 0.2),
        cloudPaint,
      );
    }

    // Draw stars and constellations
    for (var star in stars) {
      final brightness =
          (star.brightness * (math.sin(starAnimation * math.pi * 2) * 0.3 + 0.7))
              .clamp(0.0, 1.0);

      final starPaint = Paint()
        ..color = Colors.white.withOpacity(brightness)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size);

      canvas.drawCircle(
        Offset(star.x, star.y),
        star.size,
        starPaint,
      );

      // Draw constellation lines
      if (star.isConstellation && star.connectedStars.isNotEmpty) {
        final linePaint = Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..strokeWidth = 1;

        for (var connectedStar in star.connectedStars) {
          canvas.drawLine(
            Offset(star.x, star.y),
            Offset(connectedStar.x, connectedStar.y),
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CosmicPainter oldDelegate) {
    return starAnimation != oldDelegate.starAnimation ||
        nebulaAnimation != oldDelegate.nebulaAnimation;
  }
} 