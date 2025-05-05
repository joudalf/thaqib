import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thaqib/services/firestore_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _titleController = TextEditingController();
  File? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String? uploadedUrl = await uploadImageToImgur(imageFile);
      if (uploadedUrl != null) {
        setState(() {
          _selectedImage = imageFile;
          _imageUrl = uploadedUrl;
        });
      }
    }
  }

  Future<String?> uploadImageToImgur(File imageFile) async {
    final clientId = 'd77955fcb453ad9';
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
      print('❌ Imgur upload failed: ${response.body}');
      return null;
    }
  }

  Future<void> _addCategory() async {
    if (_titleController.text.isEmpty || _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال العنوان والصورة")),
      ); print("🚫 لم يتم الإدخال بسبب: العنوان أو الصورة ناقصة");
      return;
    }

    setState(() {
      _isUploading = true;
    });

    await FirestoreService().addCategory(_titleController.text, _imageUrl!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background
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
                  // 🔹 عنوان إضافة تصنيف
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "إضافة تصنيف جديد",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(height: 20),

// 🔹 عنوان حقل عنوان التصنيف
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "عنوان التصنيف",
                      style: TextStyle(color: Colors.white),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  TextField(
                    controller: _titleController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
                    decoration: InputDecoration(
                      hintText: "اكتب عنوان التصنيف",
                      hintStyle: TextStyle(color: Colors.grey[300]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),


                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "صورة التصنيف",
                      style: TextStyle(color: Colors.white),
                      textDirection: TextDirection.rtl,
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
                        onPressed: _isUploading ? null : _addCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        ),
                        child: _isUploading
                            ? const CircularProgressIndicator()
                            : const Text("إضافة", style: TextStyle(color: Color(0xFF7A1E6C))),
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
