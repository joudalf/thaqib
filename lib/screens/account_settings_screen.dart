import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart'; // Import EditProfileScreen if needed

class AccountSettingsPage extends StatefulWidget {
  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Function to change the email after reauthentication
  Future<void> _changeEmail(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {

        print("👤 Current Email: ${user.email}");
        print("✏️ New Email entered: ${_emailController.text}");
        print("📧 Email Verified? ${user.emailVerified}");
        // Reauthenticate with the current password entered by the user
        print("🔐 Reauthenticating...");
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _passwordController.text,
        );

        await user.reauthenticateWithCredential(credential);
        print("✅ Reauthenticated successfully");

        // Check that the new email is different from the current one
        if (_emailController.text == user.email) {
          print("⚠️ New email is same as current");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('البريد الإلكتروني الجديد هو نفسه البريد الحالي')),
          );
          return;
        }

        // Update the email address
        print("📤 Updating email...");
        await user.updateEmail(_emailController.text);
        print("✅ Email updated");
        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تغيير البريد الإلكتروني بنجاح')),
        );
      }
    } catch (e) {
      print("❌ Error during email change: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تغيير البريد الإلكتروني: ${e.toString()}')),
      );
    }
  }

  // Function to change the password
  Future<void> _changePassword(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // (Assumes the user is already recently authenticated.)
        await user.updatePassword(_newPasswordController.text);
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تغيير كلمة المرور: ${e.toString()}')),
      );
    }
  }
  @override
  void initState() {
    super.initState();

    final providerId = FirebaseAuth.instance.currentUser?.providerData.first.providerId;
    print('🪪 Logged in with provider: $providerId');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar; UI elements are placed manually for full control
      body: Directionality(
        textDirection: TextDirection.rtl, // Ensure text displays RTL
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/gradient 1.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Back arrow at the top-left that navigates back to EditProfileScreen
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(height: 20),
                // Top-right: Row containing the gear icon and then text "اعدادات الحساب"
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gear icon on the left
                      IconButton(
                        icon: Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          // Optionally, define an action or leave it inert.
                        },
                      ),
                      SizedBox(width: 8),
                      // Text "اعدادات الحساب" to the right of the gear icon
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
                // Option 1: Change Email
                ListTile(
                  title: Text(
                    'تعديل البريد الإلكتروني',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    // Show dialog for updating email
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            height: 300,
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
                                  textAlign: TextAlign.right,
                                ),
                                TextField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور الحالية',
                                    labelStyle: TextStyle(color: Colors.black),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  obscureText: true,
                                  textAlign: TextAlign.right,
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
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    // Show dialog for updating password
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            height: 350,
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
                                  textAlign: TextAlign.right,
                                ),
                                TextField(
                                  controller: _newPasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور الجديدة',
                                    labelStyle: TextStyle(color: Colors.black),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  obscureText: true,
                                  textAlign: TextAlign.right,
                                ),
                                TextField(
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'تأكيد كلمة المرور الجديدة',
                                    labelStyle: TextStyle(color: Colors.black),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  obscureText: true,
                                  textAlign: TextAlign.right,
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