// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:ui';
// import '../theme/colors.dart';
// import './dashboard_screen.dart';
// import './settings_screen.dart';
// import './subscription_screen.dart';

// class HomeScreen extends StatefulWidget {
//   static const routeName = '/home';

//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
//   int _currentIndex = 0;
//   late PageController _pageController;
//   late AnimationController _animationController;

//   final List<Widget> _pages = [
//     DashboardScreen(),
//     SubscriptionScreen(),
//     SettingsScreen(),
//   ];

//   final List<String> _titles = ['Dashboard', 'Premium', 'Settings'];
//   final List<IconData> _appBarIcons = [
//     Icons.dashboard_rounded,
//     Icons.star_rounded,
//     Icons.settings_rounded,
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 200),
//       vsync: this,
//     );
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _onPageChanged(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   void _onTabTapped(int index) {
//     _pageController.animateToPage(
//       index,
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   Widget _buildNavBarItem(IconData icon, String label, int index) {
//     final isSelected = _currentIndex == index;
//     return GestureDetector(
//       onTap: () => _onTabTapped(index),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           color: isSelected ? primaryBlue.withOpacity(0.1) : Colors.transparent,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? primaryBlue : Colors.grey,
//               size: 24,
//             ),
//             if (isSelected) ...[
//               SizedBox(width: 8),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: primaryBlue,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.dark,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: primaryBlue,
//           elevation: 1,
//           centerTitle: false,
//           title: Text(
//             'Weather App',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           actions: [
//             IconButton(
//               icon: Icon(Icons.dashboard_outlined, color: Colors.white, size: 24),
//               onPressed: () => _onTabTapped(0),
//               tooltip: 'Dashboard',
//             ),
//             IconButton(
//               icon: Icon(Icons.star_outline, color: Colors.white, size: 24),
//               onPressed: () => _onTabTapped(1),
//               tooltip: 'Subscriptions',
//             ),
//             IconButton(
//               icon: Icon(Icons.info_outline, color: Colors.white, size: 24),
//               onPressed: () {
//                 // Handle about page navigation
//               },
//               tooltip: 'About',
//             ),
//             IconButton(
//               icon: Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
//               onPressed: () {
//                 // Handle notifications
//               },
//               tooltip: 'Notifications',
//             ),
//             IconButton(
//               icon: Icon(Icons.person_outline, color: Colors.white, size: 24),
//               onPressed: () {
//                 // Handle profile
//               },
//               tooltip: 'Profile',
//             ),
//             SizedBox(width: 8),
//           ],
//           systemOverlayStyle: SystemUiOverlayStyle.light,
//         ),
//         body: PageView(
//           controller: _pageController,
//           onPageChanged: _onPageChanged,
//           children: _pages,
//           physics: BouncingScrollPhysics(),
//         ),
//         bottomNavigationBar: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 20,
//                 offset: Offset(0, -5),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 child: SafeArea(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildNavBarItem(Icons.dashboard_outlined, 'Dashboard', 0),
//                       _buildNavBarItem(Icons.star_outline, 'Premium', 1),
//                       _buildNavBarItem(Icons.settings_outlined, 'Settings', 2),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
