import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Laundry/pages/login.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String userName = "Admin";
  bool isLoading = true;

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
        var data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          userName = data['Name']?.toString() ?? "Admin";
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

  void _showBookingDetails(
      BuildContext context, Map<String, dynamic> booking, String phoneNumber) {
    List<Map<String, dynamic>> services = (booking['Services'] as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    String userName = booking['Username'] ?? 'ไม่ระบุ';
    String bookingStatus = booking['Status'] ?? 'รอดำเนินการ';

    // 🔥 ตรวจสอบให้แน่ใจว่า bookingStatus อยู่ในตัวเลือกที่กำหนด
    List<String> statusOptions = ["กำลังดำเนินการ", "ยกเลิก", "เสร็จสิ้น"];
    String selectedStatus = statusOptions.contains(bookingStatus)
        ? bookingStatus
        : "กำลังดำเนินการ";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("รายละเอียดการจอง"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("👤 ลูกค้า: $userName"),
                    Text("📅 วันที่จอง: ${booking['Date'] ?? 'ไม่ระบุ'}"),
                    Text("⏰ เวลา: ${booking['Time'] ?? 'ไม่ระบุ'}"),
                    const SizedBox(height: 10),
                    const Text("📝 รายการบริการที่เลือก:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(services.length, (index) {
                        var item = services[index];
                        String serviceName = item['service'] ?? 'ไม่ระบุ';
                        int quantity = item['quantity'] ?? 1;
                        int pricePerUnit = item['price'] ?? 0;
                        int totalPrice = quantity * pricePerUnit;

                        return Text(
                            "• $serviceName ($quantity ชิ้น) - ฿$totalPrice");
                      }),
                    ),
                    const SizedBox(height: 10),
                    Text(
                        "📍 ที่อยู่จัดส่ง: ${booking['DeliveryAddress'] ?? 'ไม่ระบุ'}"),
                    const SizedBox(height: 10),
                    // 🔥 Dropdown เปลี่ยนสถานะ (เฉพาะ 3 สถานะ)
                    const Text("📌 สถานะ:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: selectedStatus,
                      items: statusOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedStatus = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Text("📞 เบอร์โทร: $phoneNumber"),
                  ],
                ),
              ),
              actions: [
                // 🔥 ปุ่มอัปเดตสถานะ
                TextButton(
                  onPressed: () {
                    _updateBookingStatus(booking['id'], selectedStatus);
                    Navigator.of(context).pop(); // ปิด Dialog
                  },
                  child: const Text("อัปเดตสถานะ",
                      style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("ปิด", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

// ✅ ฟังก์ชันอัปเดตสถานะลง Firestore
  void _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(bookingId)
          .update({'Status': newStatus});
    } catch (e) {
      print("❌ Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
              padding:
                  const EdgeInsets.only(top: 70.0, left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 48.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LogIn()),
                          );
                        },
                        child: Icon(Icons.logout, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Divider(color: Colors.blue, thickness: 2.0),
                  SizedBox(height: 10.0),
                  Center(
                    child: Text(
                      "ข้อมูลการจองลูกค้า",
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Expanded(child: _buildBookingList(context)),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Bookings')
          .orderBy('Date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("ไม่มีคำสั่งจอง",
                style: TextStyle(color: Colors.blue, fontSize: 18)),
          );
        }

        var bookings = snapshot.data!.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            var booking = bookings[index];

            String phoneNumber = booking['Number'] ?? 'ไม่ระบุ';

            return GestureDetector(
              onTap: () {
                _showBookingDetails(context, booking, phoneNumber);
              },
              child: Card(
                color: Colors.white,
                shadowColor: Colors.blue[700],
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    "วันที่จอง: ${booking['Date']}",
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ยอดรวม: ฿${booking['TotalPrice']}",
                          style: TextStyle(color: Colors.blue[900])),
                      Text("เวลา: ${booking['Time']}",
                          style: TextStyle(color: Colors.blueGrey[800])),
                      Text("ที่อยู่จัดส่ง: ${booking['DeliveryAddress']}"),
                      Text("เบอร์โทร: $phoneNumber"),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
