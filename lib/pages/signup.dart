import 'package:Laundry/pages/home.dart';
import 'package:Laundry/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // รายการอีเมลของ admin
  final List<String> adminEmails = ["admin@abc.com", "admin1@abc.com"];

  Future<void> registration() async {
    if (_formKey.currentState!.validate()) {
      try {
        // เช็คว่าอีเมลที่ใช้สมัครตรงกับอีเมลที่กำหนดไว้ใน adminEmails หรือไม่
        bool isAdmin = adminEmails.contains(emailController.text);

        // สร้างผู้ใช้ใหม่
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

        String? id = userCredential.user?.uid;

        if (id != null) {
          // กำหนด role เป็น "admin" หากอีเมลตรงกับที่อยู่ใน adminEmails
          Map<String, dynamic> userInfoMap = {
            "Id": id,
            "Name": nameController.text,
            "Email": emailController.text,
            "Number": numberController.text,
            "Role": isAdmin ? "admin" : "user",
          };

          // บันทึกข้อมูลผู้ใช้ลงใน Firestore
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(id)
              .set(userInfoMap);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "สมัครสำเร็จ",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = "An error occurred";

        if (e.code == 'weak-password') {
          message = "Password Provided is too Weak";
        } else if (e.code == 'email-already-in-use') {
          message = "Account Already exists";
        } else {
          message = e.message ?? "Unknown error";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(message, style: TextStyle(fontSize: 18.0)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50.0, left: 30.0),
            height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40)),
            ),
            width: MediaQuery.of(context).size.width,
            child: Text(
              "สร้างบัญชีของคุณ",
              style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.all(30.0),
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
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
                  _buildTextField("ชื่อ", nameController, Icons.person_outline),
                  SizedBox(height: 20.0),
                  _buildTextField("Email", emailController, Icons.mail_outline,
                      isEmail: true),
                  SizedBox(height: 20.0),
                  _buildTextField(
                      "รหัสผ่าน", passwordController, Icons.lock_outline,
                      isPassword: true),
                  SizedBox(height: 20.0),
                  _buildTextField(
                      "เบอร์โทร", numberController, Icons.phone_outlined),
                  SizedBox(height: 40.0),
                  GestureDetector(
                    onTap: registration,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Color(0xFFB91635),
                          Color(0Xff621d3c),
                          Color(0xFF311937),
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
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "มีบัญชีอยู่แล้ว?",
                        style: TextStyle(
                            fontSize: 17.0, fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => LogIn()));
                        },
                        child: Text(
                          "เข้าสู่ระบบ",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
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
    );
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
          keyboardType:
              isEmail ? TextInputType.emailAddress : TextInputType.text,
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ],
    );
  }
}
