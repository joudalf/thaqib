import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEduDetailScreen extends StatefulWidget {
  final String id;
  const AdminEduDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<AdminEduDetailScreen> createState() => _AdminEduDetailScreenState();
}

class _AdminEduDetailScreenState extends State<AdminEduDetailScreen> {
  Future<DocumentSnapshot> fetchData() async {
    return await FirebaseFirestore.instance.collection('edu').doc(widget.id).get();
  }

  Future<void> deleteCategory() async {
    await FirebaseFirestore.instance.collection('edu').doc(widget.id).delete();
    setState(() {}); // 🔥 refresh screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم الحذف بنجاح ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 خلفية متدرجة
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
          SafeArea(
            child: FutureBuilder<DocumentSnapshot>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 زر الرجوع
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "المحتوى غير متوفر",
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 السهم وحذف المحتوى
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("تأكيد الحذف", textDirection: TextDirection.rtl ),
                                  content: const Text("هل أنت متأكد من حذف هذا المحتوى؟", textDirection: TextDirection.rtl ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("إلغاء"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("حذف"),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await deleteCategory();
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // 🔹 عرض المحتوى
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // العنوان الرئيسي
                              Text(
                                data['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 20),

                              // القسم الأول
                              Text(
                                data['section1Title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['section1Text'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 20),

                              // صور القسم 1
                              if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    boundaryMargin: const EdgeInsets.all(20),
                                    minScale: 1,
                                    maxScale: 5,
                                    child: Image.network(data['imageUrl'], fit: BoxFit.cover),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              if (data['section1Image'] != null && data['section1Image'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    boundaryMargin: const EdgeInsets.all(20),
                                    minScale: 1,
                                    maxScale: 5,
                                    child: Image.network(data['section1Image'], fit: BoxFit.cover),
                                  ),
                                ),
                              const SizedBox(height: 20),

                              // القسم الثاني
                              Text(
                                data['section2Title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['section2Text'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 20),

                              // صور القسم 2
                              if (data['section2ImageUrl'] != null && data['section2ImageUrl'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    boundaryMargin: const EdgeInsets.all(20),
                                    minScale: 1,
                                    maxScale: 5,
                                    child: Image.network(data['section2ImageUrl'], fit: BoxFit.cover),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              if (data['section2Image'] != null && data['section2Image'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    boundaryMargin: const EdgeInsets.all(20),
                                    minScale: 1,
                                    maxScale: 5,
                                    child: Image.network(data['section2Image'], fit: BoxFit.cover),
                                  ),
                                ),
                              const SizedBox(height: 20),

                              // القسم الثالث
                              if (data['section3Title'] != null || data['section3Text'] != null) ...[
                                Text(
                                  data['section3Title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data['section3Text'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 20),

                                // صورة القسم الثالث
                                if (data['section3Image'] != null && data['section3Image'].toString().isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: InteractiveViewer(
                                      panEnabled: true,
                                      boundaryMargin: const EdgeInsets.all(20),
                                      minScale: 1,
                                      maxScale: 5,
                                      child: Image.network(data['section3Image'], fit: BoxFit.cover),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}