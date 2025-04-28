
import 'admin_community_screen.dart';
import 'admin_edu_category_screen.dart';
import 'admin_calendar.dart';
import 'package:thaqib/admin_screens/admin_map_page.dart';
import 'package:thaqib/admin_screens/admin_notifi_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thaqib/screens/twitter/all_tweets_page.dart';
import 'package:thaqib/repository/twitter_repository.dart';
import 'package:thaqib/model/tweet_with_user.dart';
import 'package:thaqib/screens/twitter/twitter_card.dart';
import 'package:thaqib/screens/profie_page.dart';
import 'package:thaqib/screens/map_page.dart';
import 'package:thaqib/screens/notifi_page.dart';
//import 'package:thaqib/screens/user/twitter_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/src/messages/ar_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'admin_profile_page.dart';
import 'adminTwitterNews.dart';




class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 2;
  bool isLoading = true;
  String userName = '';
  List<TweetWithUser> tweets = [];
  String userImage = '';

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
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    fetchUserData();
    fetchTweets();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          userName = data?['name'] ?? 'مشرف';
          userImage = data?['imageUrl'] ?? '';
        });
      }
    }
  }

  Future<void> fetchTweets() async {
    try {
      final repository = TwitterRepository();
      final fetchedTweets = await repository.getTweetsFromFirestore();
      setState(() {
        tweets = fetchedTweets;
        isLoading = false;
      });
    } catch (e) {
      print('❌ خطأ في جلب التغريدات: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMapPage())),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Image.asset('assets/globe_icon.png', fit: BoxFit.contain),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "! مرحبا، $userName",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            userImage.isNotEmpty
                ? GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage())),
              child: CircleAvatar(backgroundImage: NetworkImage(userImage), radius: 18),
            )
                : IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage())),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/background.png", fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
            child: Column(
              children: [
                // إشعارات
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotifiPage())),
                            child: const Text("عرض الكل", style: TextStyle(color: Colors.white)),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.notifications, color: Colors.white),
                              SizedBox(width: 5),
                              Text("إشعاراتي", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('notifications')
                            .orderBy('timestamp', descending: true)
                            .limit(3)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text('لا توجد إشعارات حالياً', style: TextStyle(color: Colors.white));
                          }

                          final docs = snapshot.data!.docs;

                          return Column(
                            children: docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final timestamp = data['timestamp'] as Timestamp?;
                              final date = timestamp?.toDate();
                              String timeText = '';
                              if (date != null) {
                                final duration = DateTime.now().difference(date);
                                if (duration.inDays <= 7) {
                                  timeText = timeago.format(date, locale: 'ar');
                                } else {
                                  timeText = DateFormat('yyyy/MM/dd - HH:mm').format(date);
                                }
                              }

                              return Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(timeText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // قسم تويتر
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TwitterNewsAdmin())),
                            child: const Text("عرض الكل", style: TextStyle(color: Colors.white)),
                          ),
                          const Text("𝕏 أهم الأخبار من منصة", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: tweets.take(1).map((tweet) => TwitterCard(tweet: tweet)).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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