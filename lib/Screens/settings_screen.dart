import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/theme_provider.dart';
import '../theme/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool notificationsEnabled = true;
  bool locationEnabled = true;
  String selectedTemperature = '°C';
  String selectedLanguage = 'English';
  double searchRadius = 10.0;

  final List<String> temperatureUnits = ['°C', '°F', 'K'];
  final List<String> languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

  late final AnimationController _auroraController;

  @override
  void initState() {
    super.initState();
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _auroraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Theme(
      data: theme.copyWith(
        shadowColor: isDark ? Colors.white24 : Colors.black12,
        cardColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
      ),
      child: Scaffold(
        backgroundColor: isDark ? Color(0xFF121212) : Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, 
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        body: Stack(
          children: [
            // Animated Aurora Background
            if (isDark) AnimatedBuilder(
              animation: _auroraController,
              builder: (context, child) => CustomPaint(
                painter: _AuroraPainter(_auroraController.value),
                size: Size.infinite,
              ),
            ),
            
            // Main Content
            ListView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                _buildSection(
                  title: 'General',
                  children: [
                    _buildSettingTile(
                      title: 'Dark Mode',
                      subtitle: 'Switch between light and dark themes',
                      leading: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      trailing: Switch.adaptive(
                        value: isDark,
                        onChanged: (value) => themeProvider.toggleTheme(),
                        activeColor: theme.primaryColor,
                      ),
                    ),
                    _buildSettingTile(
                      title: 'Language',
                      subtitle: selectedLanguage,
                      leading: Icon(
                        Icons.language,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      onTap: () => _showLanguageBottomSheet(context),
                    ),
                    _buildSettingTile(
                      title: 'Temperature Unit',
                      subtitle: selectedTemperature,
                      leading: Icon(
                        Icons.thermostat,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      onTap: () => _showTemperatureUnitBottomSheet(context),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideX(),

                SizedBox(height: 24),

                _buildSection(
                  title: 'Permissions',
                  children: [
                    _buildSettingTile(
                      title: 'Notifications',
                      subtitle: 'Receive weather alerts and updates',
                      leading: Icon(
                        Icons.notifications_outlined,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      trailing: Switch.adaptive(
                        value: notificationsEnabled,
                        onChanged: (value) => setState(() => notificationsEnabled = value),
                        activeColor: theme.primaryColor,
                      ),
                    ),
                    _buildSettingTile(
                      title: 'Location Services',
                      subtitle: 'Allow access to your location',
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      trailing: Switch.adaptive(
                        value: locationEnabled,
                        onChanged: (value) => setState(() => locationEnabled = value),
                        activeColor: theme.primaryColor,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(),

                SizedBox(height: 24),

                _buildSection(
                  title: 'Search Settings',
                  children: [
                    _buildSettingTile(
                      title: 'Search Radius',
                      subtitle: '${searchRadius.toStringAsFixed(1)} km',
                      leading: Icon(
                        Icons.radar,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      customContent: Column(
                        children: [
                          SizedBox(height: 8),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: theme.primaryColor,
                              inactiveTrackColor: theme.primaryColor.withOpacity(0.2),
                              thumbColor: theme.primaryColor,
                              overlayColor: theme.primaryColor.withOpacity(0.1),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: searchRadius,
                              min: 1,
                              max: 50,
                              divisions: 49,
                              onChanged: (value) => setState(() => searchRadius = value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(),

                SizedBox(height: 24),

                _buildSection(
                  title: 'About',
                  children: [
                    _buildSettingTile(
                      title: 'Version',
                      subtitle: '1.0.0',
                      leading: Icon(
                        Icons.info_outline,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    _buildSettingTile(
                      title: 'Terms of Service',
                      leading: Icon(
                        Icons.description_outlined,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      onTap: () {
                        // Navigate to Terms of Service
                      },
                    ),
                    _buildSettingTile(
                      title: 'Privacy Policy',
                      leading: Icon(
                        Icons.privacy_tip_outlined,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      onTap: () {
                        // Navigate to Privacy Policy
                      },
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideX(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark 
              ? Color(0xFF1E1E1E).withOpacity(0.8)
              : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black12 : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark 
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: children,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    String? subtitle,
    required Widget leading,
    Widget? trailing,
    VoidCallback? onTap,
    Widget? customContent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark 
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      ),
                    ),
                    child: leading,
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                  ).shimmer(
                    duration: 2000.ms,
                    color: isDark 
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    SizedBox(width: 16),
                    trailing,
                  ],
                ],
              ),
              if (customContent != null) customContent,
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isDark 
              ? Color(0xFF1E1E1E).withOpacity(0.95)
              : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white38 : Colors.black38,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Select Language',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              ...languages.map((language) => ListTile(
                title: Text(
                  language,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: language == selectedLanguage
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () {
                  setState(() => selectedLanguage = language);
                  Navigator.pop(context);
                },
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).shimmer(
                duration: 2000.ms,
                color: isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemperatureUnitBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isDark 
              ? Color(0xFF1E1E1E).withOpacity(0.95)
              : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white38 : Colors.black38,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Select Temperature Unit',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              ...temperatureUnits.map((unit) => ListTile(
                title: Text(
                  unit,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: unit == selectedTemperature
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () {
                  setState(() => selectedTemperature = unit);
                  Navigator.pop(context);
                },
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).shimmer(
                duration: 2000.ms,
                color: isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// Aurora painter for animated background
class _AuroraPainter extends CustomPainter {
  final double animation;
  _AuroraPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height * 0.2),
        Offset(size.width, size.height * 0.8),
        [
          Colors.purpleAccent.withOpacity(0.18 + 0.12 * math.sin(animation * 2 * math.pi)),
          Colors.blueAccent.withOpacity(0.12 + 0.08 * math.cos(animation * 2 * math.pi)),
          Colors.tealAccent.withOpacity(0.10 + 0.10 * math.sin(animation * 2 * math.pi)),
        ],
      );
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.7 + 30 * math.sin((x / size.width * 2 * math.pi) + animation * 2 * math.pi);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) => true;
} 