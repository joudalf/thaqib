import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettingsPage extends StatefulWidget {
  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Function to update the email
  Future<void> _changeEmail(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateEmail(_emailController.text);
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تغيير البريد الإلكتروني بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تغيير البريد الإلكتروني')),
      );
    }
  }

  // Function to update the password
  Future<void> _changePassword(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(_newPasswordController.text);
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تغيير كلمة المرور')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title text alignment to right for RTL
        title: Text(
          'اعدادات الحساب',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.right, // Align the title text to the right
        ),
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // Removes the shadow
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // Apply RTL direction for the whole screen
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/gradient 1.png"), // Background image
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Option 1: Change Email
                ListTile(
                  title: Text(
                    'تعديل البريد الإلكتروني',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.right, // Right-aligned text
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            height: 300, // Adjust height to make the dialog shorter
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'البريد الإلكتروني الجديد',
                                    labelStyle: TextStyle(color: Colors.black),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  textAlign: TextAlign.right, // Right-aligned text input
                                ),
                                TextField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور الحالية',
                                    labelStyle: TextStyle(color: Colors.black),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  obscureText: true,
                                  textAlign: TextAlign.right, // Right-aligned text input
                                ),
                                ElevatedButton(
                                  onPressed: () => _changeEmail(context),
                                  child: Text('حفظ التعديلات'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                Divider(),

                // Option 2: Change Password
                ListTile(
                  title: Text(
                    'تعديل كلمة المرور',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.right, // Right-aligned text
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            height: 350, // Adjust height to make the dialog shorter
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور الحالية',
                                    labelStyle: TextStyle(color: Colors.black),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  obscureText: true,
                                  textAlign: TextAlign.right, // Right-aligned text input
                                ),
                                TextField(
                                  controller: _newPasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور الجديدة',
                                    labelStyle: TextStyle(color: Colors.black),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  obscureText: true,
                                  textAlign: TextAlign.right, // Right-aligned text input
                                ),
                                TextField(
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'تأكيد كلمة المرور الجديدة',
                                    labelStyle: TextStyle(color: Colors.black),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  obscureText: true,
                                  textAlign: TextAlign.right, // Right-aligned text input
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_newPasswordController.text == _confirmPasswordController.text) {
                                      _changePassword(context);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('كلمات المرور غير متطابقة')),
                                      );
                                    }
                                  },
                                  child: Text('حفظ التعديلات'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}