import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_weather/widgets/animated_button.dart';
import 'package:simple_animations/simple_animations.dart';
import './signup_screen.dart';
import '../homeScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_weather/services/auth_service.dart';

// Wave animation model
class Wave {
  late double yOffset;
  late double speed;
  late double frequency;
  late double amplitude;

  Wave({
    required this.yOffset,
    required this.speed,
    required this.frequency,
    required this.amplitude,
  });

  static Wave random(Size size) {
    return Wave(
      yOffset: math.Random().nextDouble() * size.height,
      speed: math.Random().nextDouble() * 0.8 + 0.2,
      frequency: math.Random().nextDouble() * 0.6 + 0.2,
      amplitude: math.Random().nextDouble() * 20 + 10,
    );
  }
}

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isHovering = false;
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  late AnimationController _waveAnimationController;
  late AnimationController _auroraAnimationController;
  late AnimationController _colorShiftController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _rippleAnimationController;
  late Animation<double> _rippleAnimation;
  late Animation<Color?> _colorAnimation;

  final _customTween = MovieTween()
    ..tween('opacity', Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500));

  final List<Wave> waves = [];
  final List<Bubble> bubbles = [];
  final List<RippleEffect> ripples = [];
  final List<AuroraEffect> auroras = [];
  final List<StarParticle> stars = [];

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _auroraAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _colorShiftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _colorAnimation = ColorTween(
      begin: Color(0xFF1A237E),
      end: Color(0xFF0D47A1),
    ).animate(
      CurvedAnimation(
        parent: _colorShiftController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideAnimationController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleAnimationController, curve: Curves.easeInOut),
    );

    _rippleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimationController.forward();
    _slideAnimationController.forward();

    // Initialize waves, bubbles, and ripples
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 3; i++) {
        waves.add(Wave.random(size));
      }
      for (int i = 0; i < 20; i++) {
        bubbles.add(Bubble.random(size));
      }
      for (int i = 0; i < 5; i++) {
        ripples.add(RippleEffect.random(size));
      }
      for (int i = 0; i < 3; i++) {
        auroras.add(AuroraEffect.random(size));
      }
      for (int i = 0; i < 50; i++) {
        stars.add(StarParticle.random(size));
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    _waveAnimationController.dispose();
    _rippleAnimationController.dispose();
    _auroraAnimationController.dispose();
    _colorShiftController.dispose();
    super.dispose();
  }

  void _navigateToSignup() {
    Navigator.of(context).pushNamed(SignupScreen.routeName);
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
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
    // Calculate available height excluding system UI (status bar, navigation bar)
    final availableHeight = size.height - padding.top - padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // Enhanced background with all effects
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _waveAnimationController,
                _rippleAnimationController,
                _auroraAnimationController,
                _colorShiftController,
              ]),
              builder: (context, child) {
                return Stack(
                  children: [
                    // Dynamic color background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _colorAnimation.value ?? Color(0xFF1A237E),
                            Color(0xFF0D47A1).withOpacity(0.8),
                            Color(0xFF1565C0).withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    // Stars layer
                    CustomPaint(
                      painter: StarsPainter(
                        stars: stars,
                        animation: _auroraAnimationController.value,
                      ),
                    ),
                    // Aurora effects
                    CustomPaint(
                      painter: AuroraPainter(
                        auroras: auroras,
                        animation: _auroraAnimationController.value,
                      ),
                    ),
                    // Existing effects
                    CustomPaint(
                      painter: WavesPainter(
                        waves: waves,
                        bubbles: bubbles,
                        animation: _waveAnimationController.value,
                      ),
                    ),
                    CustomPaint(
                      painter: RipplesPainter(
                        ripples: ripples,
                        animation: _rippleAnimation.value,
                      ),
                    ),
                    // Enhanced depth overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.5,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          stops: [0.4, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Login form with optimized layout
          SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: availableHeight * 0.05), // 5% of available height
                    // App logo with adjusted size
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: const Duration(seconds: 2),
                      curve: Curves.elasticOut,
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: EdgeInsets.all(availableHeight * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.cloud,
                              size: availableHeight * 0.08, // 8% of available height
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: availableHeight * 0.03), // 3% of available height
                    // Welcome text
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.white, Colors.white70],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'Welcome Back',
                        style: GoogleFonts.poppins(
                          fontSize: availableHeight * 0.035, // 3.5% of available height
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: availableHeight * 0.01), // 1% of available height
                    Text(
                      'Sign in to continue',
                      style: GoogleFonts.poppins(
                        fontSize: availableHeight * 0.02, // 2% of available height
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: availableHeight * 0.04), // 4% of available height
                    // Form container with adjusted height
                    Expanded(
                      flex: 2,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAnimatedTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                            ),
                            SizedBox(height: availableHeight * 0.02), // 2% of available height
                            _buildAnimatedTextField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: availableHeight * 0.02), // 2% of available height
                    // Forgot password button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: availableHeight * 0.01,
                          ),
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            fontSize: availableHeight * 0.018,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: availableHeight * 0.02), // 2% of available height
                    // Login button
                    MouseRegion(
                      onEnter: (_) => _scaleAnimationController.forward(),
                      onExit: (_) => _scaleAnimationController.reverse(),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: double.infinity,
                          height: availableHeight * 0.07, // 7% of available height
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.9),
                                Colors.white.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: AnimatedButton(
                            onPressed: _isLoading ? null : () {
                              _handleLogin();
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
                                : Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF1565C0),
                                      fontSize: availableHeight * 0.022,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: availableHeight * 0.02), // 2% of available height
                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: availableHeight * 0.018,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToSignup,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: availableHeight * 0.005,
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: availableHeight * 0.018,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: availableHeight * 0.02), // 2% of available height
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        final availableHeight = MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom;

        return Transform.scale(
          scale: value,
          child: TextField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: availableHeight * 0.02,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: availableHeight * 0.02,
              ),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: availableHeight * 0.02,
              ),
              prefixIcon: Icon(icon, color: Colors.white70),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: availableHeight * 0.02,
              ),
            ),
          ),
        );
      },
    );
  }
}

class Bubble {
  late Offset position;
  late double speed;
  late double size;
  late double opacity;

  Bubble({
    required this.position,
    required this.speed,
    required this.size,
    required this.opacity,
  });

  static Bubble random(Size screenSize) {
    return Bubble(
      position: Offset(
        math.Random().nextDouble() * screenSize.width,
        math.Random().nextDouble() * screenSize.height,
      ),
      speed: math.Random().nextDouble() * 2 + 1,
      size: math.Random().nextDouble() * 15 + 5,
      opacity: math.Random().nextDouble() * 0.6 + 0.2,
    );
  }

  void update(Size size) {
    position = Offset(
      position.dx,
      (position.dy - speed) % size.height,
    );
  }
}

class WavesPainter extends CustomPainter {
  final List<Wave> waves;
  final List<Bubble> bubbles;
  final double animation;

  WavesPainter({
    required this.waves,
    required this.bubbles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint waves
    for (var wave in waves) {
      final paint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, wave.yOffset),
          Offset(size.width, wave.yOffset),
          [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.2),
          ],
          [0, 0.5, 1],
        )
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(0, size.height);

      for (double x = 0; x < size.width; x++) {
        double y = wave.yOffset +
            math.sin((x * wave.frequency + animation * wave.speed * 2 * math.pi)) *
                wave.amplitude;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }

    // Update and paint bubbles
    for (var bubble in bubbles) {
      bubble.update(size);
      final paint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, bubble.size / 3);

      // Draw bubble with gradient
      final bubbleGradient = RadialGradient(
        center: Alignment.topLeft,
        radius: 1.0,
        colors: [
          Colors.white.withOpacity(bubble.opacity),
          Colors.white.withOpacity(bubble.opacity * 0.5),
        ],
      ).createShader(Rect.fromCircle(
        center: bubble.position,
        radius: bubble.size,
      ));

      final bubblePaint = Paint()
        ..shader = bubbleGradient
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, bubble.size / 5);

      canvas.drawCircle(bubble.position, bubble.size, bubblePaint);

      // Add highlight to bubble
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity * 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          bubble.position.dx - bubble.size * 0.3,
          bubble.position.dy - bubble.size * 0.3,
        ),
        bubble.size * 0.2,
        highlightPaint,
      );
    }

    // Add light rays effect
    final rayPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height),
        [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.0),
        ],
      );

    for (var i = 0; i < 5; i++) {
      final path = Path();
      final startX = size.width * (i / 4);
      path.moveTo(startX, 0);
      path.lineTo(startX + 50, size.height);
      path.lineTo(startX - 50, size.height);
      path.close();

      canvas.save();
      canvas.translate(0, animation * 100);
      canvas.drawPath(path, rayPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RippleEffect {
  final Offset center;
  final Color color;
  final double maxRadius;
  final double speed;

  RippleEffect({
    required this.center,
    required this.color,
    required this.maxRadius,
    required this.speed,
  });

  static RippleEffect random(Size size) {
    return RippleEffect(
      center: Offset(
        math.Random().nextDouble() * size.width,
        math.Random().nextDouble() * size.height,
      ),
      color: Colors.white.withOpacity(math.Random().nextDouble() * 0.3),
      maxRadius: math.Random().nextDouble() * 100 + 50,
      speed: math.Random().nextDouble() * 0.5 + 0.5,
    );
  }
}

class RipplesPainter extends CustomPainter {
  final List<RippleEffect> ripples;
  final double animation;

  RipplesPainter({
    required this.ripples,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var ripple in ripples) {
      final paint = Paint()
        ..color = ripple.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final progress = (animation * ripple.speed) % 1.0;
      final radius = progress * ripple.maxRadius;
      final opacity = (1.0 - progress);
      paint.color = ripple.color.withOpacity(opacity);

      canvas.drawCircle(ripple.center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StarParticle {
  final Offset position;
  final double size;
  final double blinkSpeed;
  final double opacity;

  StarParticle({
    required this.position,
    required this.size,
    required this.blinkSpeed,
    required this.opacity,
  });

  static StarParticle random(Size size) {
    return StarParticle(
      position: Offset(
        math.Random().nextDouble() * size.width,
        math.Random().nextDouble() * size.height,
      ),
      size: math.Random().nextDouble() * 2 + 1,
      blinkSpeed: math.Random().nextDouble() * 2 + 0.5,
      opacity: math.Random().nextDouble() * 0.5 + 0.5,
    );
  }
}

class StarsPainter extends CustomPainter {
  final List<StarParticle> stars;
  final double animation;

  StarsPainter({required this.stars, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(
          (math.sin(animation * star.blinkSpeed * math.pi * 2) + 1) / 2 * star.opacity,
        )
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size / 2);

      canvas.drawCircle(star.position, star.size, paint);

      // Add star twinkle effect
      final twinklePaint = Paint()
        ..color = Colors.white.withOpacity(
          (math.cos(animation * star.blinkSpeed * math.pi * 2) + 1) / 4 * star.opacity,
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(star.position, star.size * 1.5, twinklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AuroraEffect {
  final double yOffset;
  final List<Color> colors;
  final double speed;
  final double frequency;
  final double amplitude;

  AuroraEffect({
    required this.yOffset,
    required this.colors,
    required this.speed,
    required this.frequency,
    required this.amplitude,
  });

  static AuroraEffect random(Size size) {
    final baseHue = math.Random().nextDouble() * 360;
    return AuroraEffect(
      yOffset: math.Random().nextDouble() * size.height * 0.7,
      colors: List.generate(
        3,
        (index) => HSLColor.fromAHSL(
          0.3,
          (baseHue + index * 30) % 360,
          0.8,
          0.5,
        ).toColor(),
      ),
      speed: math.Random().nextDouble() * 0.5 + 0.2,
      frequency: math.Random().nextDouble() * 0.02 + 0.01,
      amplitude: math.Random().nextDouble() * 50 + 30,
    );
  }
}

class AuroraPainter extends CustomPainter {
  final List<AuroraEffect> auroras;
  final double animation;

  AuroraPainter({required this.auroras, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (var aurora in auroras) {
      final path = Path();
      path.moveTo(0, size.height);

      final points = List.generate(
        (size.width / 2).ceil(),
        (index) {
          final x = index * 2.0;
          final normalizedX = x / size.width;
          final phase = animation * aurora.speed * 2 * math.pi;
          
          return Offset(
            x,
            aurora.yOffset +
                math.sin(normalizedX * aurora.frequency * 50 + phase) * aurora.amplitude +
                math.sin(normalizedX * aurora.frequency * 30 + phase * 1.2) * aurora.amplitude * 0.5,
          );
        },
      );

      path.addPolygon(points, false);
      path.lineTo(size.width, size.height);
      path.close();

      final gradient = ui.Gradient.linear(
        Offset(0, aurora.yOffset),
        Offset(size.width, aurora.yOffset + aurora.amplitude),
        aurora.colors,
        [0.0, 0.5, 1.0],
        TileMode.clamp,
        Matrix4.rotationZ(math.pi / 6).storage,
      );

      final paint = Paint()
        ..shader = gradient
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 