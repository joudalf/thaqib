import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'community_screen.dart';

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
          .doc('Nov_2024') // stored document ID
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
    /* case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LearnScreen()));
        break;*/
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CalendarScreen()));
        break;
    /*  case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
        break;*/
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
                // 🔹 Back Button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 10),

                // 🔹 Title
                const Text(
                  "التقويم الشهري لأهم الأحداث الفلكية",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // 🔹 Calendar Image (Fetched from Firestore)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: calendarImageUrl == null
                      ? const Center(child: CircularProgressIndicator()) // Show loading spinner
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      calendarImageUrl!,
                      width: 700,// Responsive width
                      height: MediaQuery.of(context).size.height * 0.5, // Adjust height
                      fit: BoxFit.cover,
                    ),
                  ),
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
                      const Text(
                        "تقاويم الأشهر السابقة ",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const Icon(Icons.calendar_month, color: Colors.white),
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
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF7A1E6C),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "مستكشفون"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "تعلم"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "التقويم"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "معلوماتي"),
        ],
      ),
    );
  }
}