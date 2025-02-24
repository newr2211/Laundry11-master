import 'package:Laundry/admin/adminhome.dart';
import 'package:Laundry/pages/bottome_nav_bar.dart';
import 'package:Laundry/pages/forgot_password.dart';
import 'package:Laundry/pages/home.dart';
import 'package:Laundry/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    checkUserLoggedIn(); // เช็คว่าผู้ใช้ล็อกอินอยู่แล้วหรือไม่
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  Future<void> checkUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // มีผู้ใช้ล็อกอินอยู่แล้ว ดึง Role จาก Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      String role = userDoc['Role'] ?? 'user';

      if (!mounted) return;

      // นำทางไปยังหน้าที่เหมาะสม
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHome()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    }
  }

  Future<void> userLogin() async {
    try {
      String mail = emailcontroller.text.trim();
      String password = passwordcontroller.text.trim();

      // ล็อกอินผู้ใช้
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail,
        password: password,
      );

      // ดึงข้อมูล Role จาก Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      String role = userDoc['Role'] ?? 'user';

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHome()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'เกิดข้อผิดพลาด';
      if (e.code == 'user-not-found') {
        errorMessage = 'ไม่พบผู้ใช้กับอีเมลนี้';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'รหัสผ่านไม่ถูกต้อง';
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50.0, left: 30.0),
            height: MediaQuery.of(context).size.height / 2,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.blue[50]),
            child: Text(
              "ลงชื่อเข้าใช้",
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(30.0),
            margin:
            EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Email",
                      style: TextStyle(
                          color: Color(0xFFB91635),
                          fontSize: 23.0,
                          fontWeight: FontWeight.w500)),
                  TextFormField(
                    controller: emailcontroller,
                    validator: (value) => value == null || value.isEmpty
                        ? 'กรุณาใส่ E-mail'
                        : null,
                    decoration: const InputDecoration(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.mail_outline)),
                  ),
                  const SizedBox(height: 40.0),
                  const Text("รหัสผ่าน",
                      style: TextStyle(
                          color: Color(0xFFB91635),
                          fontSize: 23.0,
                          fontWeight: FontWeight.w500)),
                  TextFormField(
                    controller: passwordcontroller,
                    validator: (value) => value == null || value.isEmpty
                        ? 'กรุณาใส่ Password'
                        : null,
                    decoration: const InputDecoration(
                      hintText: "รหัสผ่าน",
                      prefixIcon: Icon(Icons.password_outlined),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      child: const Text("ลืมรหัสผ่าน?",
                          style: TextStyle(
                              color: Color(0xFF311937),
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ForgotPassword()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 60.0),
                  GestureDetector(
                    onTap: () {
                      if (_formkey.currentState!.validate()) {
                        userLogin();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFFB91635),
                          Color(0Xff621d3c),
                          Color(0xFF311937)
                        ]),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          "เข้าสู่ระบบ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("ยังไม่มีบัญชี?",
                          style: TextStyle(
                              color: Color(0xFF311937),
                              fontSize: 17.0,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp()),
                          );
                        },
                        child: const Text("สมัครบัญชี",
                            style: TextStyle(
                                color: Color(0Xff621d3c),
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
