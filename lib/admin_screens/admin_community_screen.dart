import 'package:flutter/material.dart';
import 'package:thaqib/services/firestore_service.dart';
import 'package:thaqib/admin_screens/add_category_screen.dart';
import 'package:thaqib/admin_screens/admin_category_posts_screen.dart';
import '../model/category.dart';
import 'admin_home_screen.dart';
import 'admin_calendar.dart';
import 'admin_profile_page.dart';
import 'admin_edu_category_screen.dart';



class AdminCommunityScreen extends StatefulWidget {
  @override
  _AdminCommunityScreenState createState() => _AdminCommunityScreenState();
}

class _AdminCommunityScreenState extends State<AdminCommunityScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Category> categories = [];
  int _currentIndex = 0;


  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final data = await _firestoreService.getCategories();
    setState(() {
      categories = data;
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestoreService.deleteCategory(categoryId);
    loadCategories();
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
          // خلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/gradient 1.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // عنوان + زر إضافة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 28),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddCategoryScreen()),
                          );
                          loadCategories(); // تحديث بعد العودة
                        },
                      ),
                      const Text(
                        "المستكشفون",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 28),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // قائمة التصنيفات
                  Expanded(
                    child: ListView.builder(
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
                                    builder: (_) => AdminCategoryPostsScreen(categoryId: category.id),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Stack(
                                    children: [
                                      // صورة الخلفية
                                      Image.network(
                                        category.imageUrl,
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                      // تدرج غامق من الأسفل
                                      Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.6),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      // نص العنوان
                                      Positioned(
                                        bottom: 10,
                                        right: 15,
                                        child: Text(
                                          category.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                      title: const Text('تأكيد الحذف'),
                                      content: const Text('هل أنت متأكد من حذف هذا التصنيف؟'),
                                      actions: [
                                        TextButton(
                                          child: const Text('إلغاء'),
                                          onPressed: () => Navigator.pop(context, false),
                                        ),
                                        TextButton(
                                          child: const Text('حذف'),
                                          onPressed: () => Navigator.pop(context, true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm ?? false) {
                                    await deleteCategory(category.id);
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
}
