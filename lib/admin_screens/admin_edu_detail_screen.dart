import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Color(0xFF7A1E6C)),
        onPressed: () {
          // TODO: Navigate to Add Detail Screen
        },
      ),
      body: Stack(
        children: [
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
                  return const Center(child: Text("المحتوى غير متوفر", style: TextStyle(color: Colors.white)));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("تأكيد الحذف"),
                                  content: const Text("هل أنت متأكد من حذف هذا المحتوى؟"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("حذف")),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await deleteCategory();
                              }
                            },
                          )
                        ],
                      ),
                    ),

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
                              Text(
                                data['title'] ?? '',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                data['section1Title'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['section1Text'] ?? '',
                                style: const TextStyle(fontSize: 14, color: Colors.black),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 20),
                              if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(data['imageUrl'], fit: BoxFit.cover),
                                ),
                              const SizedBox(height: 20),
                              Text(
                                data['section2Title'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['section2Text'] ?? '',
                                style: const TextStyle(fontSize: 14, color: Colors.black),
                                textAlign: TextAlign.right,
                              ),
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