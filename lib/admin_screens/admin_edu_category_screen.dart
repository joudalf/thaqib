import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_category_screen.dart';
import 'admin_edu_detail_screen.dart';

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
    // هنا ممكن تضيفي تنقل بين الشاشات
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
                // الصف العلوي: زر إضافة + العنوان + سهم وهمي يمين علشان التوسيط
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر الإضافة
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddCategoryScreen()),
                          );
                          fetchCategories(); // تحديث القائمة
                        },
                      ),
                      const Text(
                        "تعلّم",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.transparent), // لحفظ التوسيط
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
                                  builder: (_) => AdminEduDetailScreen(
                                    id: category['id'],
                                  ),
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
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF7A1E6C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "مستكشفون"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "تعلَّم"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "التقويم"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "معلوماتي"),
        ],
      ),
    );
  }
}