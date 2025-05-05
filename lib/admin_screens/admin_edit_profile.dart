import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class AdminEditProfileScreen extends StatefulWidget {
  @override
  _AdminEditProfileScreenState createState() => _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState extends State<AdminEditProfileScreen> {
  final _nameController = TextEditingController(text: 'Admin');
  final _usernameController = TextEditingController(text: 'Admin1');
  final _bioController = TextEditingController(text: 'This is the admin profile');
  File? _imageFile;
  String? existingImageUrl = 'assets/profile_pic.png'; // Static profile image
  bool isLoading = false;

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

  Future<void> _saveProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      String imageUrl = existingImageUrl ?? '';
      if (_imageFile != null) {
        // Here you could upload the image, but for admin, we use static data
        imageUrl = 'path_to_uploaded_image'; // Placeholder for image upload logic
      }

      // Here you would save to Firestore or similar, but for admin, we will just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم حفظ الملف الشخصي بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('❌ Error in _saveProfile: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ حدث خطأ أثناء حفظ الملف')),
      );
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
                  'تعديل الملف الشخصي',
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
                          ? AssetImage(existingImageUrl!) as ImageProvider
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

                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'اعدادات الحساب',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),

                    ],
                  ),
                ),

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