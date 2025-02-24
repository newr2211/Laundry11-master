import 'package:Laundry/pages/bookinghistory.dart';
import 'package:Laundry/pages/detail.dart';
import 'package:Laundry/pages/editprofile.dart';
import 'package:Laundry/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:Laundry/pages/service1.dart';
import 'package:Laundry/pages/service2.dart';
import 'package:Laundry/pages/service3.dart';
import 'package:Laundry/pages/service4.dart';
import 'package:Laundry/pages/service5.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = "User";
  String userPhoneNumber = "ไม่ระบุเบอร์โทร"; // ตัวแปรเก็บเบอร์โทร
  bool isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogIn()),
      );
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          userName = userDoc['Name'] ?? "User";
          userPhoneNumber = userDoc['PhoneNumber'] ??
              "ไม่ระบุเบอร์โทร"; // ดึงเบอร์โทรจาก Firestore
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogIn()),
      );
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              child: Container(
                padding:
                    EdgeInsets.only(left: 20, top: 80, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ยินดีให้บริการ",
                                style: TextStyle(
                                    color: Colors.pink[900],
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w500)),
                            Row(
                              children: [
                                Text(userName,
                                    style: TextStyle(
                                        color: Colors.pink[700],
                                        fontSize: 32.0,
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditProfile(),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.edit))
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.logout, color: Colors.red, size: 30),
                          onPressed: logOut,
                        )
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Divider(color: Colors.pink[200], thickness: 1.5),
                    SizedBox(height: 10.0),
                    Text("บริการ",
                        style: TextStyle(
                            color: Colors.pink[900],
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        serviceTile(
                          goto: Service1(),
                          color: Colors.blue[700]!,
                          imagePath: 'images/111.png',
                          serviceName: 'ซัก-พับ',
                        ),
                        SizedBox(width: 30.0),
                        serviceTile(
                          goto: Service2(),
                          color: Colors.pinkAccent,
                          imagePath: 'images/44.png',
                          serviceName: 'ซักรองเท้า',
                        ),
                      ],
                    ),
                    SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        serviceTile(
                          goto: Service3(),
                          color: Colors.cyanAccent,
                          imagePath: 'images/55.png',
                          serviceName: 'รีดเท่านั้น',
                        ),
                        SizedBox(width: 30.0),
                        serviceTile(
                          goto: Service4(),
                          color: Colors.yellowAccent,
                          imagePath: 'images/66.png',
                          serviceName: 'เครื่องนอนและอื่นๆ',
                        ),
                      ],
                    ),
                    SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        serviceTile(
                          goto: Service5(),
                          color: Colors.blueGrey,
                          imagePath: 'images/77.png',
                          serviceName: 'ซักชุดสูท',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class serviceTile extends StatelessWidget {
  final Widget goto;
  final Color color;
  final String imagePath, serviceName;

  const serviceTile({
    super.key,
    required this.goto,
    required this.color,
    required this.imagePath,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => goto,
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * .4,
        height: 150,
        color: color,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                imagePath, // รูปภาพที่เพิ่ม
                width: 50,
                height: 50,
              ),
              SizedBox(height: 10), // เพิ่มระยะห่าง
              Text(
                serviceName,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
