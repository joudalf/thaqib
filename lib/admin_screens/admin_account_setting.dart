import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminEditPage extends StatefulWidget {
  @override
  _AdminEditPageState createState() => _AdminEditPageState();
}

class _AdminEditPageState extends State<AdminEditPage> {
  final _uidController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();

  Future<void> _updateUserEmail(BuildContext context) async {
    final uid = _uidController.text.trim();
    final newEmail = _newEmailController.text.trim();

    if (uid.isEmpty || newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال UID والبريد الإلكتروني الجديد')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'email': newEmail,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث البريد الإلكتروني بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحديث البريد الإلكتروني: $e')),
      );
    }
  }

  Future<void> _updateUserPassword(BuildContext context) async {
    final uid = _uidController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (uid.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال UID وكلمة المرور الجديدة')),
      );
      return;
    }

    try {
      // ⚡ Passwords cannot be updated directly in Firestore.
      // You normally use Admin SDK for that on the server side.
      // Here we just warn.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚡ لا يمكن تعديل كلمة المرور هنا مباشرة. استخدم Admin SDK')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تغيير كلمة المرور: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/gradient 1.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.ltr,
                    children: const [
                      Text(
                        'تعديل بيانات المستخدم',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.admin_panel_settings, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 🔹 إدخال UID
                TextField(
                  controller: _uidController,
                  decoration: InputDecoration(
                    labelText: 'UID المستخدم',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 20),

                // 🔹 تعديل البريد الإلكتروني
                TextField(
                  controller: _newEmailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني الجديد',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _updateUserEmail(context),
                  child: Text('تحديث البريد الإلكتروني'),
                ),
                Divider(color: Colors.white70),
                const SizedBox(height: 20),

                // 🔹 تعديل كلمة المرور
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  obscureText: true,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _updateUserPassword(context),
                  child: Text('⚡ تحديث كلمة المرور (تنبيه)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}