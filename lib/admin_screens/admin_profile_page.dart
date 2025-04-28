import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thaqib/screens/login.dart';
import 'admin_edit_profile.dart';       // if admins can still edit their own info
// import 'admin_dashboard.dart'; // your actual admin panel
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thaqib/screens/login.dart';
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

  Future<DocumentSnapshot> getUserData() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
  }
  Future<void> _logout(BuildContext ctx) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      ctx,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }


  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminCommunityScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminEduCategoryScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminHomePage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminCalendarScreen()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminProfilePage()));
        break;
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/gradient 1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .snapshots(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
            if (!snap.hasData || !snap.data!.exists) {
              return const Center(
                child: Text(
                  'لم يتم العثور على البيانات',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            final userData = snap.data!.data() as Map<String, dynamic>;
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userData['imageUrl'] != null
                        ? NetworkImage(userData['imageUrl']) as ImageProvider
                        : const AssetImage('assets/profile_pic.png'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userData['name'] ?? 'الاسم غير متوفر',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '@${userData['username'] ?? 'اسم المستخدم'}',
                    style:
                    const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      userData['bio'] ?? 'لا توجد نبذة.',
                      textAlign: TextAlign.center,
                      style:
                      const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // *** ADMIN BUTTON ***
                  ElevatedButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: (_) => AdminDashboardScreen()
                      // ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                    ),
                    child: const Text(
                      'لوحة التحكم',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF3D0066),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'مستكشفون',),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book),label: 'تعلم',),
          BottomNavigationBarItem(icon: SizedBox(height: 35,child: Image.asset('assets/barStar.png'),),label: 'الرئيسية',),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today),label: 'التقويم',),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: 'معلوماتي',),


        ],
      ),
    );
  }
}

