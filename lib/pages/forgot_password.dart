import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // เพิ่มการใช้งาน FirebaseAuth
import 'package:Laundry/pages/home.dart'; // เพิ่มหน้า Home หรือหน้าอื่นที่ต้องการไปหลังรีเซ็ตรหัสผ่านสำเร็จ

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String? email;
  TextEditingController mailcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  // ฟังก์ชันรีเซ็ตรหัสผ่าน
  resetPassword() async {
    try {
      // ส่งอีเมลรีเซ็ตรหัสผ่าน
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email!);
      // หากสำเร็จ ให้แสดงข้อความ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ส่งอีเมลรีเซ็ตรหัสผ่านแล้ว'),
        ),
      );
      // นำทางไปที่หน้า Login หรือหน้าอื่นๆ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Home()), // ไปที่หน้า Home หรือหน้าที่ต้องการ
      );
    } catch (e) {
      // หากมีข้อผิดพลาด ให้แสดงข้อความข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "แก้ไขรหัสผ่าน",
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              "ป้อน Email ของคุณ",
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40.0),
            Form(
              key: _formkey,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: mailcontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Email",
                    hintStyle: const TextStyle(fontSize: 18.0),
                    prefixIcon: const Icon(
                      Icons.mail_outline,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40.0),
            GestureDetector(
              onTap: () async {
                if (_formkey.currentState!.validate()) {
                  setState(() {
                    email = mailcontroller.text;
                  });
                  resetPassword(); // เรียกฟังก์ชันรีเซ็ตรหัสผ่าน
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Text(
                  "ส่ง Email",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
