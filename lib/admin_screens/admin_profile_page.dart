import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thaqib/screens/login.dart';
import 'admin_edit_profile.dart';
import 'admin_home_screen.dart';
import 'admin_calendar.dart';
import 'admin_community_screen.dart';
import 'admin_edu_category_screen.dart';

class AdminProfilePage extends StatefulWidget {
  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  int _currentIndex = 4;
  String bio = ''; // Initially, no bio.

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Widget dest;
    switch (index) {
      case 0:
        dest = AdminCommunityScreen();
        break;
      case 1:
        dest = AdminEduCategoryScreen();
        break;
      case 2:
        dest = AdminHomePage();
        break;
      case 3:
        dest = AdminCalendarScreen();
        break;
      default:
        dest = AdminProfilePage();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dest),
    );
  }

  Future<void> _updateBio(BuildContext context) async {
    final newBio = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController bioController = TextEditingController(text: bio);
        return AlertDialog(
          title: Text('تعديل نبذة تعريفية'),
          content: TextField(
            controller: bioController,
            decoration: InputDecoration(hintText: 'أدخل نبذة جديدة'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, bioController.text);
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );

    if (newBio != null && newBio.isNotEmpty) {
      setState(() {
        bio = newBio;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
          onPressed: () => _logout(context),
        ),
        title: const Text(
          'معلوماتي',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/gradient 1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60), // space below AppBar
              CircleAvatar(
                radius: 50,
                backgroundImage: const AssetImage('assets/f09fef20-1294-4889-8d7b-3d011ff9ad5a 2.jpg'), // Static profile pic
              ),
              const SizedBox(height: 20),
              const Text(
                'Admin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                '@Admin1',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  bio.isEmpty ? 'مشرف تطبيق ثاقب، اهدف لنشر المعرفة حول الكون وتقديم محتوى مفيد لعشاق الاكتشاف. لنبحر معا بين النجوم ' : bio, // No default bio
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),




              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _updateBio(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text(
                  'تعديل النبذة التعريفية',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3D0066),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'مستكشفون'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'تعلم'),
          BottomNavigationBarItem(icon: SizedBox(height: 35, child: Image(image: AssetImage('assets/barStar.png'))), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'التقويم'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'معلوماتي'),
        ],
      ),
    );
  }
}