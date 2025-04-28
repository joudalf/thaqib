import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_edu_detail_screen.dart';
import 'admin_home_screen.dart';
import 'admin_calendar.dart';
import 'admin_community_screen.dart';
import 'admin_profile_page.dart';


class AdminEduCategoryScreen extends StatefulWidget {
  const AdminEduCategoryScreen({Key? key}) : super(key: key);

  @override
  State<AdminEduCategoryScreen> createState() => _AdminEduCategoryScreenState();
}

class _AdminEduCategoryScreenState extends State<AdminEduCategoryScreen> {
  List<Map<String, dynamic>> categories = [];
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('edu_category').get();
    setState(() {
      categories = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> deleteCategory(String id) async {
    await FirebaseFirestore.instance.collection('edu_category').doc(id).delete();
    fetchCategories();
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
          // الخلفية
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/gradient 1.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // المحتوى
          SafeArea(
            child: Column(
              children: [
                // الصف العلوي: العنوان فقط بدون زر الإضافة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "تعلّم",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // القائمة
                Expanded(
                  child: categories.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminEduDetailScreen(id: category['id']),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white),
                                image: DecorationImage(
                                  image: NetworkImage(category['imageUrl']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                category['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          // زر الحذف
                          Positioned(
                            top: 8,
                            left: 8,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("تأكيد الحذف"),
                                    content: const Text("هل أنت متأكد من حذف هذا القسم؟"),
                                    actions: [
                                      TextButton(
                                        child: const Text("إلغاء"),
                                        onPressed: () => Navigator.pop(context, false),
                                      ),
                                      TextButton(
                                        child: const Text("حذف"),
                                        onPressed: () => Navigator.pop(context, true),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm ?? false) {
                                  await deleteCategory(category['id']);
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // البار السفلي

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