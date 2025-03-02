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
    String bookingStatus = booking['Status'] ?? 'รอดดำเนินการ';
    String statusDate = booking['StatusDate'] ?? 'กำลังดำเนินการ';
    String payment = booking['Payment'] ?? 'รอดดำเนินการ';
    String paymentSelectTime =
        booking['PaymentSelectTime'] ?? 'ไม่ระบุ'; // เพิ่มข้อมูลเวลา

    List<String> statusOptions = ["กำลังดำเนินการ", "ยกเลิก", "เสร็จสิ้น"];
    String selectedBookingStatus = statusOptions.contains(bookingStatus)
        ? bookingStatus
        : "กำลังดำเนินการ";

    List<String> serviceStatusOptions = ["2-3 ชั่วโมง", "1 วัน"];
    String selectedStatusDate =
        serviceStatusOptions.contains(statusDate) ? statusDate : "2-3 ชั่วโมง";

    List<String> paymentStatusOptions = ["ชำระเสร็จสิ้น", "กำลังตรวจสอบ"];
    String selectedPaymentStatus =
        paymentStatusOptions.contains(payment) ? payment : "กำลังตรวจสอบ";

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
                    // แสดงเวลาที่เลือกชำระ ถ้าไม่ใช่การชำระเงินสด
                    if (payment != 'ชำระเงินสด') ...[
                      Text(
                        "⏳ เวลาที่เลือกชำระ: $paymentSelectTime",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                    ],
                    // สถานะการจอง
                    const Text("📌 สถานะการจอง:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: selectedBookingStatus,
                      items: statusOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedBookingStatus = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    // สถานะการบริการ
                    const Text("📌 สถานะการบริการ:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: selectedStatusDate,
                      items: serviceStatusOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedStatusDate = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    // สถานะการชำระเงิน
                    const Text("📌 สถานะการชำระเงิน:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: selectedPaymentStatus,
                      items: paymentStatusOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedPaymentStatus = newValue;
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
                TextButton(
                  onPressed: () {
                    _updateBookingStatus(
                      booking['id'],
                      selectedBookingStatus,
                      selectedStatusDate,
                      selectedPaymentStatus,
                    );
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

// ฟังก์ชันอัปเดตสถานะลง Firestore
  void _updateBookingStatus(String bookingId, String newBookingStatus,
      String newServiceStatus, String newPaymentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(bookingId)
          .update({
        'Status': newBookingStatus,
        'StatusDate': newServiceStatus,
        'Payment': newPaymentStatus,
      });
    } catch (e) {
      print("❌ Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.pink[900]))
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
                              color: Colors.pink[900],
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
                  Divider(color: Colors.pink[200], thickness: 2.0),
                  SizedBox(height: 10.0),
                  Center(
                    child: Text(
                      "ข้อมูลการจองลูกค้า",
                      style: TextStyle(
                        color: Colors.pink[900],
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
          return Center(
            child: Text("ไม่มีคำสั่งจอง",
                style: TextStyle(color: Colors.pink[900], fontSize: 18)),
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
                color: Colors.pink[50],
                shadowColor: Colors.pink[900],
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    "วันที่จอง: ${booking['Date']}",
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ยอดรวม: ฿${booking['TotalPrice']}",
                      ),
                      Text(
                        "เวลา: ${booking['Time']}",
                      ),
                      Text(
                        "ที่อยู่จัดส่ง: ${booking['DeliveryAddress']}",
                      ),
                      Text(
                        "เบอร์โทร: $phoneNumber",
                      ),
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
