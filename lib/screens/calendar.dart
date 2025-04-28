import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'community_screen.dart';
import 'edu_category_screen.dart';
import 'profie_page.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}


class _CalendarScreenState extends State<CalendarScreen>{
  String? calendarImageUrl; // Variable to store the fetched image URL
  int _currentIndex = 3;


  @override
  void initState() {
    super.initState();
    fetchCalendarImage(); // Fetch image when the screen loads
  }

  Future<void> fetchCalendarImage() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Calendar')
          .doc('Nov') // stored document ID
          .get();

      if (doc.exists) {
        setState(() {
          calendarImageUrl = doc['imageUrl']; // Get the image URL
        });
      }
    } catch (e) {
      print("❌ Error fetching calendar image: $e");
    }
  }


  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to different pages based on index
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CommunityScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EduCategoryScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CalendarScreen()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // Background Image
        Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/gradient 1.png"), // Background gradient image
                fit: BoxFit.cover,
              ),
            ),
          ),


          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "التقويم",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                // 🔹 Back Button


                const SizedBox(height: 10),

                // 🔹 Title
                const Text(
                  "التقويم الشهري لأهم الأحداث الفلكية",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // 🔹 Calendar Image (Fetched from Firestore)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('Calendar').doc('Nov_2024').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists || snapshot.data!['imageUrl'] == null) {
                      return const Center(
                        child: Text("لا يوجد تقويم حالي", style: TextStyle(color: Colors.white)),
                      );
                    }

                    final calendarImageUrl = snapshot.data!['imageUrl'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImageScreen(imageUrl: calendarImageUrl),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            calendarImageUrl,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.5,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );

                  },
                ),


                const SizedBox(height: 20),

                // 🔹 Previous Months Button
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to past months
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const SizedBox(width: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // 🔹 Bottom Navigation Bar
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
class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
