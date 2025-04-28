import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'admin_home_screen.dart';
import 'admin_community_screen.dart';
import 'admin_profile_page.dart';
import 'admin_edu_category_screen.dart';


class AdminCalendarScreen extends StatefulWidget {
  @override
  _AdminCalendarScreenState createState() => _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends State<AdminCalendarScreen> {
  String? calendarImageUrl;
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    fetchCalendarImage();
  }

  Future<void> fetchCalendarImage() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Calendar')
          .doc('Nov_2024')
          .get();

      if (doc.exists) {
        setState(() {
          calendarImageUrl = doc['imageUrl'];
        });
      }
    } catch (e) {
      print("❌ Error fetching calendar image: $e");
    }
  }

  Future<void> deleteCalendarImage() async {
    bool confirm = await _showDeleteConfirmation();
    if (!confirm) return;

    await FirebaseFirestore.instance.collection('Calendar').doc('Nov_2024').delete();
    setState(() {
      calendarImageUrl = null;
    });
  }

  Future<void> addCalendarImage(String imageUrl) async {
    await FirebaseFirestore.instance.collection('Calendar').doc('Nov_2024').set({
      'imageUrl': imageUrl,
    });
    fetchCalendarImage();
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final File imageFile = File(picked.path);
      String? imgurUrl = await uploadImageToImgur(imageFile);
      if (imgurUrl != null) {
        await addCalendarImage(imgurUrl);
      }
    }
  }

  Future<String?> uploadImageToImgur(File imageFile) async {
    const clientId = 'd77955fcb453ad9'; //
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://api.imgur.com/3/image'),
      headers: {'Authorization': 'Client-ID $clientId'},
      body: {'image': base64Image, 'type': 'base64'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['link'];
    } else {
      print('❌ Error uploading to Imgur: ${response.body}');
      return null;
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد أنك تريد حذف صورة التقويم؟"),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: const Text("نعم، حذف"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ??
        false;
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
      body: Stack(
        children: [
          // background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/gradient 1.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // add image icon
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.white),
                        onPressed: pickAndUploadImage,
                      ),
                      const Text("التقويم", style: TextStyle(color: Colors.white, fontSize: 20)),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const Text(
                  "التقويم الشهري لأهم الأحداث الفلكية",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: calendarImageUrl == null
                      ? const Center(
                    child: Text(
                      "لا يوجد تقويم حالي",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageScreen(imageUrl: calendarImageUrl!),
                              ),
                            );
                          },
                          child: Image.network(
                            calendarImageUrl!,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.5,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool confirm = await _showDeleteConfirmation();
                            if (confirm) {
                              await FirebaseFirestore.instance.collection('Calendar').doc('Nov_2024').delete();
                              setState(() {
                                calendarImageUrl = null;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )



              ],
            ),
          ),
        ],
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
}class FullScreenImageScreen extends StatelessWidget {
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
