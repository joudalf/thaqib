import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'account_settings_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _imageFile;
  String? existingImageUrl;
  bool isLoading = true;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      final data = doc.data();
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _bioController.text = data['bio'] ?? '';
        existingImageUrl = data['imageUrl'];
      }
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
        print("✅ Picked image path: ${file.path}");
      } else {
        print("🚫 File does not exist: ${file.path}");
      }
    } else {
      print("⚠️ No image selected");

    }
  }

 /* Future<String> _uploadImage(String uid) async {
    if (_imageFile == null || !await _imageFile!.exists()) {
      throw Exception("🚫 No image file to upload");
    }
    final ref = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
    await ref.putFile(_imageFile!);
    return await ref.getDownloadURL();
  }*/





  Future<void> _saveProfile() async {
    final uid = user?.uid;
    if (uid == null) return;

    try {
      String imageUrl = existingImageUrl ?? '';
      if (_imageFile != null) {
        print("📤 Attempting to upload image to Imgur...");
        final uploadedUrl = await uploadImageToImgur(_imageFile!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          print("❌ Failed to upload image to Imgur");
          return;
        }

        print('✅ Image uploaded successfully: $imageUrl');
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم حفظ الملف الشخصي بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('❌ Error in _saveProfile: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ حدث خطأ أثناء حفظ الملف ')),
      );
    }
  }



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
                // Back arrow button for navigation
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Text(
                  'تعديل الملف الشخصي',
                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 25),

                // Profile Image with option to edit
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

                // Gear Icon and "اعدادات الحساب" text above the "حفظ التعديلات" button
                Align(
                  alignment: Alignment.topRight,  // Position it to top-right
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end, // Align to right
                    children: [
                      Text(
                        'اعدادات الحساب',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AccountSettingsPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // The "حفظ التعديلات" button
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