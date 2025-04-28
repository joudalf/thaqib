import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminEditProfileScreen extends StatefulWidget {
  final String userId; // ← admin passes the user ID

  AdminEditProfileScreen({required this.userId});

  @override
  _AdminEditProfileScreenState createState() => _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState extends State<AdminEditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _imageFile;
  String? existingImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _usernameController.text = data['username'] ?? '';
      _bioController.text = data['bio'] ?? '';
      existingImageUrl = data['imageUrl'];
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      if (await file.exists()) {
        setState(() => _imageFile = file);
      }
    }
  }

  Future<void> _saveProfile() async {
    final uid = widget.userId;
    try {
      String imageUrl = existingImageUrl ?? '';
      if (_imageFile != null) {
        final uploadedUrl = await uploadImageToImgur(_imageFile!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ فشل تحميل الصورة')));
          return;
        }
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم حفظ تعديلات الملف الشخصي')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('❌ Error in _saveProfile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ حدث خطأ أثناء حفظ التعديلات')),
      );
    }
  }

  Future<String?> uploadImageToImgur(File imageFile) async {
    final clientId = 'd77955fcb453ad9'; // Your Imgur Client ID
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
      return data['data']['link'];
    } else {
      print('❌ Imgur upload error: ${response.body}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/gradient 1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Text(
                  'تعديل ملف المستخدم',
                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 25),

                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (existingImageUrl != null && existingImageUrl!.isNotEmpty)
                          ? NetworkImage(existingImageUrl!)
                          : AssetImage('assets/profile_pic.png') as ImageProvider,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text('تعديل الصورة الشخصية', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 25),
                _buildField('الاسم', _nameController),
                _buildField('اسم المستخدم', _usernameController),
                _buildField('نبذة تعريفية', _bioController),
                SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    'حفظ التعديلات',
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}