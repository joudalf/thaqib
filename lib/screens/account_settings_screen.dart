import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart'; // ← make sure this imports your login screen

class AccountSettingsPage extends StatefulWidget {
  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController    = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// Sends the verification‑before‑update link to the **old** email,
  /// then shows a confirmation in Arabic and navigates to login.
  Future<void> _changeEmail(BuildContext ctx) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('لا يوجد مستخدم مسجل الدخول')),
      );
      return;
    }

    try {
      // 1) Reauthenticate
      final cred = EmailAuthProvider.credential(
        email:    user.email!,
        password: _passwordController.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);

      // 2) No‑op check
      final newEmail = _emailController.text.trim();
      if (newEmail == user.email) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('البريد الجديد مطابق للحالي')),
        );
        return;
      }

      // 3) Build ActionCodeSettings
      final actionSettings = ActionCodeSettings(
        url: 'https://thaqib-c2d3e.firebaseapp.com/__/auth/action',
        handleCodeInApp: false,
      );

      // 4) Send link to old email
      await user.verifyBeforeUpdateEmail(newEmail, actionSettings);

      // —— NEW: show Arabic confirmation and navigate to login ——
      await showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text('تم ارسال البريد الإلكتروني بنجاح'),
          content: Text('سيتم إعادة توجيهك إلى صفحة تسجيل الدخول.'),
          actions: [
            TextButton(
              onPressed: () {
                // close dialog
                Navigator.of(ctx).pop();
                // clear stack & go to LoginPage
                Navigator.of(ctx).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                      (_) => false,
                );
              },
              child: Text('حسناً'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
    }
  }

  /// Simply updates password (user remains recently authenticated)
  Future<void> _changePassword(BuildContext ctx) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await user.updatePassword(_newPasswordController.text.trim());
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('خطأ في تغيير كلمة المرور: ${e.toString()}')),
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
                // Back arrow
                Padding(
                  padding: const EdgeInsets.only(top: 20), // مقدار النزول من الأعلى
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Transform.rotate(
                        angle: 3.14, // 180 درجة
                        child: Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),



                SizedBox(height: 20),

                // Settings title + gear
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.ltr,
                    children: [
                      Icon(Icons.settings, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'اعدادات الحساب',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),

                // ListTile: Change Email
                ListTile(
                  title: Text(
                    'تعديل البريد الإلكتروني',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _emailController,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                decoration: InputDecoration(
                                  labelText: 'البريد الإلكتروني الجديد',
                                  labelStyle: TextStyle(fontFamily: 'NotoNaskhArabic', fontSize: 16),
                                  alignLabelWithHint: true,
                                  hintTextDirection: TextDirection.rtl,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                ),
                              ),

                              TextField(
                                controller: _emailController,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور الحالية',
                                  labelStyle: TextStyle(fontFamily: 'NotoNaskhArabic', fontSize: 16),
                                  alignLabelWithHint: true,
                                  hintTextDirection: TextDirection.rtl,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                ),
                              ),


                              SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  _changeEmail(context);
                                },
                                child: Text('حفظ التعديلات'),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Divider(color: Colors.white70),

                // ListTile: Change Password
                ListTile(
                  title: Text(
                    'تعديل كلمة المرور',
                    textDirection: TextDirection.rtl, // Set Right-To-Left direction

                    style: TextStyle(

                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              TextField(
                                controller: _emailController,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور الجديدة',
                                  labelStyle: TextStyle(fontFamily: 'NotoNaskhArabic', fontSize: 16),
                                  alignLabelWithHint: true,
                                  hintTextDirection: TextDirection.rtl,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                ),
                              ),


                              TextField(
                                controller: _emailController,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                decoration: InputDecoration(
                                  labelText: 'تأكيد كلمة المرور الجديدة',
                                  labelStyle: TextStyle(fontFamily: 'NotoNaskhArabic', fontSize: 16),
                                  alignLabelWithHint: true,
                                  hintTextDirection: TextDirection.rtl,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                ),
                              ),
                              SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  if (_newPasswordController.text.trim() !=
                                      _confirmPasswordController.text.trim()) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'كلمات المرور غير متطابقة')),
                                    );
                                    return;
                                  }
                                  _changePassword(context);
                                },
                                child: Text('حفظ التعديلات'),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Divider(color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}