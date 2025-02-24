import 'package:Laundry/pages/bottome_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Laundry/pages/home.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  bool isNameChanged = false;
  bool isNumberChanged = false;
  bool isPasswordChanged = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .get();

        if (userData.exists) {
          setState(() {
            nameController.text = userData['Name'] ?? '';
            numberController.text = userData['Number'] ?? '';
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // ตรวจสอบรหัสผ่านปัจจุบันถ้าผู้ใช้เลือกเปลี่ยนรหัสผ่าน
        if (isPasswordChanged) {
          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
              email: user!.email!, password: currentPasswordController.text);

          if (passwordController.text.isNotEmpty) {
            await user!.updatePassword(passwordController.text);
          }
        }

        // อัปเดตข้อมูลใน Firestore
        if (isNameChanged || isNumberChanged) {
          await FirebaseFirestore.instance.collection('Users').doc(user!.uid).update({
            if (isNameChanged) 'Name': nameController.text,
            if (isNumberChanged) 'Number': numberController.text,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("อัปเดตโปรไฟล์สำเร็จ")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
        );
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("รหัสผ่านปัจจุบันไม่ถูกต้อง")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("แก้ไขโปรไฟล์"),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSwitchOption(
                        "เปลี่ยนชื่อ", isNameChanged, (value) {
                      setState(() {
                        isNameChanged = value;
                      });
                    }),
                    if (isNameChanged) ...[
                      _buildTextField(
                          "ชื่อ", nameController, Icons.person, "กรุณาใส่ชื่อ"),
                      SizedBox(height: 20),
                    ],
                    _buildSwitchOption(
                        "เปลี่ยนเบอร์โทร", isNumberChanged, (value) {
                      setState(() {
                        isNumberChanged = value;
                      });
                    }),
                    if (isNumberChanged) ...[
                      _buildTextField("เบอร์โทร", numberController,
                          Icons.phone, "กรุณาใส่เบอร์โทร",
                          keyboardType: TextInputType.phone),
                      SizedBox(height: 20),
                    ],
                    _buildSwitchOption(
                        "เปลี่ยนรหัสผ่าน", isPasswordChanged, (value) {
                      setState(() {
                        isPasswordChanged = value;
                      });
                    }),
                    if (isPasswordChanged) ...[
                      _buildTextField(
                          "รหัสผ่านปัจจุบัน",
                          currentPasswordController,
                          Icons.lock,
                          "กรอกรหัสผ่านปัจจุบัน",
                          obscureText: true),
                      SizedBox(height: 20),
                      _buildTextField(
                          "รหัสผ่านใหม่",
                          passwordController,
                          Icons.lock,
                          "กรอกรหัสผ่านใหม่",
                          obscureText: true),
                      SizedBox(height: 20),
                      _buildTextField(
                          "ยืนยันรหัสผ่าน",
                          confirmPasswordController,
                          Icons.lock_outline,
                          "ยืนยันรหัสผ่าน",
                          obscureText: true),
                      SizedBox(height: 30),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "บันทึกการเปลี่ยนแปลง",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchOption(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue[700],
        ),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, String errorMessage,
      {bool obscureText = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue[700]),
            hintText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
          validator: (value) => value!.isEmpty ? errorMessage : null,
        ),
      ],
    );
  }
}
