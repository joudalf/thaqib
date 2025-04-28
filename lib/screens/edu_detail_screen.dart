import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EduDetailScreen extends StatelessWidget {
  final String id;

  const EduDetailScreen({Key? key, required this.id}) : super(key: key);

  Future<DocumentSnapshot> fetchData() async {
    return await FirebaseFirestore.instance.collection('edu').doc(id).get();
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
                  return const Center(
                    child: Text(
                      "المحتوى غير متوفر",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 سهم الرجوع والعنوان
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          Text(
                            data['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),

                    // 🔹 محتوى داخل كرت أبيض
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

                              // صورة رئيسية (imageUrl)
                              if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenImageScreen(imageUrl: data['imageUrl']),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      data['imageUrl'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),


                              const SizedBox(height: 20),

                              // صورة القسم الأول الثانية
                              if (data['section1Image'] != null && data['section1Image'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    boundaryMargin: const EdgeInsets.all(20),
                                    minScale: 1,
                                    maxScale: 5,
                                    child: Image.network(
                                      data['section1Image'],
                                      fit: BoxFit.cover,
                                    ),
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

                              // صورة القسم الثاني (section2ImageUrl)
                              if (data['section2ImageUrl'] != null &&
                                  data['section2ImageUrl'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    boundaryMargin: const EdgeInsets.all(20),
                                    minScale: 1,
                                    maxScale: 5,
                                    child: Image.network(
                                      data['section2ImageUrl'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // صورة القسم الثاني الثانية (section2Image)
                              if (data['section2Image'] != null && data['section2Image'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    boundaryMargin: const EdgeInsets.all(20),
                                    minScale: 1,
                                    maxScale: 5,
                                    child: Image.network(
                                      data['section2Image'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // القسم الثالث (اختياري)
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
