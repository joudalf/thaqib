import 'package:flutter/material.dart';
import 'package:thaqib/screens/calendar.dart';
import 'community_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Home is the default selected tab
  void _onItemTapped(int index) {
    if (index == 3) { // If "التقويم" is clicked
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CalendarScreen()), // ✅ Navigate to CalendarScreen

      );
    }else if (index == 0) { // 🔹 If مستكشفون is clicked, navigate to CommunityScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CommunityScreen()),
      );
    }
    else {
      setState(() {
        _selectedIndex = index; // Update the selected index
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color to match space theme
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png', // Replace with your background image
              fit: BoxFit.cover,
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icons and greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.language, color: Colors.white, size: 30),
                      Text(
                        'مرحباً عبدالعزيز!',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Icon(Icons.account_circle, color: Colors.white, size: 30),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Notifications section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إشعاراتي',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.notifications, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Notifications List
                  _buildNotificationCard('غداً القمر في طور التربيع الأخير'),
                  _buildNotificationCard('اقتران كوكب المريخ بالقمر'),
                  _buildNotificationCard('القمر في طور التربيع الأول'),
                  _buildNotificationCard('كسوف الشمس'),

                  SizedBox(height: 20),

                  // News Section Header
                  Text(
                    'أهم الأخبار من منصة X',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // News Cards
                  _buildNewsCard('@NASA', 'An uncrewed Progress spacecraft carrying food, fuel, and supplies is set to lift off to the @Space_Station on Thursday, Nov. 21.'),
                  _buildNewsCard('@saudispace', 'تشارك #وكالة_الفضاء_السعودية في جلسة حوارية بعنوان "الكشف عن مستقبل اقتصاد الفضاء". ضمن أعمال المنتدى الدولي للفضاء.'),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF3D0066),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Calls _onItemTapped to handle navigation
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'مستكشف'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'تعلم'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'التقويم'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'معلوماتي'),
        ],

          // Handle navigation

      ),
    );
  }

  // Widget for notification cards
  Widget _buildNotificationCard(String text) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: TextStyle(color: Colors.black, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Widget for news cards
  Widget _buildNewsCard(String source, String content) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(source, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(content, style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
