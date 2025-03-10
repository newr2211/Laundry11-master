import 'package:Laundry/admin/adminhome.dart';
import 'package:Laundry/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottome_nav_bar.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController addressController =
      TextEditingController(); // เพิ่มช่องที่อยู่

  final List<String> adminEmails = ["admin@abc.com", "admin1@abc.com"];

  Future<void> registration() async {
    if (_formKey.currentState!.validate()) {
      try {
        bool isAdmin = adminEmails.contains(emailController.text);

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

        String? id = userCredential.user?.uid;

        if (id != null) {
          Map<String, dynamic> userInfoMap = {
            "Id": id,
            "Name": nameController.text,
            "Email": emailController.text,
            "Number": numberController.text,
            "Address": addressController.text, // บันทึกที่อยู่ลง Firestore
            "Role": isAdmin ? "admin" : "user",
          };

          await FirebaseFirestore.instance
              .collection("Users")
              .doc(id)
              .set(userInfoMap);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text("สมัครสำเร็จ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavBar()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = "เกิดข้อผิดพลาด";
        if (e.code == 'weak-password') {
          message = "รหัสผ่านอ่อนเกินไป";
        } else if (e.code == 'email-already-in-use') {
          message = "อีเมลนี้มีบัญชีอยู่แล้ว";
        } else {
          message = e.message ?? "ไม่ทราบข้อผิดพลาด";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(message, style: TextStyle(fontSize: 18.0)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(top: 50.0, left: 30.0),
              height: MediaQuery.of(context).size.height / 2.5,
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40)),
              ),
              width: MediaQuery.of(context).size.width,
              child: Text(
                "สร้างบัญชีของคุณ",
                style: TextStyle(
                    color: Colors.pink[900],
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 30.0, top: 20.0, right: 30.0),
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                        "ชื่อ", nameController, Icons.person_outline),
                    SizedBox(height: 15.0),
                    _buildTextField(
                        "อีเมล", emailController, Icons.mail_outline,
                        isEmail: true),
                    SizedBox(height: 15.0),
                    _buildTextField(
                        "รหัสผ่าน", passwordController, Icons.lock_outline,
                        isPassword: true),
                    SizedBox(height: 15.0),
                    _buildTextField(
                        "เบอร์โทร", numberController, Icons.phone_outlined),
                    SizedBox(height: 15.0),
                    _buildTextField("ที่อยู่", addressController,
                        Icons.home_outlined), // ช่องที่อยู่
                    SizedBox(height: 15.0),
                    GestureDetector(
                      onTap: registration,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color(0xFFB91635),
                            Color(0Xff621d3c),
                            Color(0xFF311937)
                          ]),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "ลงทะเบียน",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("มีบัญชีอยู่แล้ว?",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LogIn()),
                            );
                          },
                          child: const Text(
                            "เข้าสู่ระบบ",
                            style: TextStyle(
                                color: Color(0Xff621d3c),
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTextField(
    String label, TextEditingController controller, IconData iconData,
    {bool isPassword = false, bool isEmail = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
            color: Color(0xFFB91635),
            fontSize: 23.0,
            fontWeight: FontWeight.w500),
      ),
      TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'กรุณาใส่ $label';
          }
          if (isEmail &&
              !RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
                  .hasMatch(value)) {
            return 'กรุณาใส่ a valid Email';
          }
          if (isPassword && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(iconData),
        ),
      ),
    ],
  );
}
