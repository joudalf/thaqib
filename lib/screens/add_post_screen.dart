import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPostScreen extends StatefulWidget {
  final String categoryId;


  const AddPostScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;
  String? _imageUrl;


  // ✅ Pick Image from Gallery
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      // 🟢  Imgur هنا بدل Firebase
      String? imageUrl = await uploadImageToImgur(imageFile);

      if (imageUrl != null) {
        setState(() {
          _selectedImage = imageFile;
          _imageUrl = imageUrl; // تخزين رابط الصورة
        });
      }
    } else {
      print("⚠️ No Image Selected");
    }
  }




  //-------------------------------------

  // ✅ Save Post to Firestore
  Future<void> _addPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى ملء جميع الحقول")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });
    print("📸 الصورة: $_imageUrl");

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try{
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    // 🔹 Save post data in Firestore
    await FirebaseFirestore.instance
        .collection('community_categories')
        .doc(widget.categoryId)
        .collection('posts')
        .add({

      'title': _titleController.text,
      'content': _contentController.text,
      'imageUrl': _imageUrl ?? '',// Use empty string if no image
      'username':userDoc.data()?['name'] ?? 'unknown', // TODO: Get actual username from authentication
      'userHandle':userDoc.data()?['username'] ?? '@unknown' ,// TODO: Replace with actual handle
      'userProfileImage': userDoc.data()?['profileImageUrl'] ?? '', // TODO: Replace with actual profile pic
      'name': userDoc.data()?['name'] ?? 'مستخدم',
      'timestamp': Timestamp.now(), // ✅ Use Firestore Timestamp
      'replies': [],
      'userId': user.uid,
    });
    print("✅ تمت إضافة البوست");
    setState(() {
      _isUploading = false;
    });

    Navigator.pop(context); // Close screen after saving
  }catch (e) {
      print("❌ Error adding post: $e");
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
    }
  }


  //--------------------------------------------

  Future<void> addReply(String postId, String categoryId, String replyText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    final reply = {
      'text': replyText,
      'timestamp': Timestamp.now(),
      'userId': user.uid,
      'username': userDoc['username'],
      'name': userDoc['name'],
      'userProfileImage': userDoc['profileImageUrl'],
    };

    await FirebaseFirestore.instance
        .collection('community_categories')
        .doc(categoryId)
        .collection('posts')
        .doc(postId)
        .update({
      'replies': FieldValue.arrayUnion([reply])
    });
  }
//-----------------------------------------

  Future<String?> uploadImageToImgur(File imageFile) async {
    final clientId = 'd77955fcb453ad9'; // استبدليه بالـ Client ID
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://api.imgur.com/3/image'),
      headers: {
        'Authorization': 'Client-ID $clientId',
      },
      body: {
        'image': base64Image,
        'type': 'base64',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['link']; // رابط الصورة النهائي
    } else {
      print('❌ Error uploading to Imgur: ${response.body}');
      return null;
    }
  }

  //------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 Background Image
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 /* const Text(
                    "التصوير الفلكي",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),*/
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "إضافة مشاركة",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Title Field
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "العنوان",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  TextField(
                    controller: _titleController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
                    decoration: InputDecoration(

                      hintText: "عنوان المشاركة",
                      hintTextDirection: TextDirection.rtl,
                      hintStyle: TextStyle(color: Colors.grey[300]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Content Field
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "محتوى المشاركة",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  TextField(
                    controller: _contentController,

                    textDirection: TextDirection.rtl, // Set Right-To-Left direction
                    textAlign: TextAlign.right, // Align text to the right
                    style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "محتوى المشاركة",
                      hintTextDirection: TextDirection.rtl,
                      hintStyle: TextStyle(color: Colors.grey[300]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Image Upload Field
              const Align(
                alignment: Alignment.centerRight,
                child: Text("إضافة صورة",  style: TextStyle(color: Colors.white),
                ),
              ),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(Icons.image, color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              _selectedImage == null ? "إضافة صورة" : "✅ تم اختيار صورة",
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        ),
                        child: const Text("إلغاء", style: TextStyle(color: Colors.black)),
                      ),
                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: _isUploading ? null : _addPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        ),
                        child: _isUploading
                            ? const CircularProgressIndicator()
                            : const Text("مشاركة", style: TextStyle(color: Color(0xFF7A1E6C))),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
