import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingHistory extends StatelessWidget {
  const BookingHistory({Key? key}) : super(key: key);

  // ฟังก์ชันแสดงรายละเอียดการจอง
  void _showBookingDetails(BuildContext context, Map<String, dynamic> booking, String phoneNumber, String docId) {
    List<Map<String, dynamic>> services = (booking['Services'] as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("รายละเอียดการจอง"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📅 วันที่จอง: ${booking['Date'] ?? 'ไม่ระบุ'}"),
                Text("⏰ เวลา: ${booking['Time'] ?? 'ไม่ระบุ'}"),
                const SizedBox(height: 10),
                const Text("📝 รายการบริการที่เลือก:", style: TextStyle(fontWeight: FontWeight.bold)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(services.length, (index) {
                    var item = services[index];
                    String serviceName = item['service'] ?? 'ไม่ระบุ';
                    int quantity = item['quantity'] ?? 1;
                    int pricePerUnit = item['price'] ?? 0;
                    int totalPrice = quantity * pricePerUnit;
                    return Text("• $serviceName ($quantity ชิ้น) - ฿$totalPrice");
                  }),
                ),
                const SizedBox(height: 10),
                Text("📍 ที่อยู่จัดส่ง: ${booking['DeliveryAddress'] ?? 'ไม่ระบุ'}"),
                const SizedBox(height: 10),
                Text("📌 สถานะ: ${booking['Status'] ?? 'รอดำเนินการ'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("📞 เบอร์โทร: $phoneNumber"),
              ],
            ),
          ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("ปิด", style: TextStyle(color: Colors.red)),
              ),
              // แสดงปุ่มลบถ้า Status ไม่ใช่ "กำลังดำเนินการ" หรือ "รอดำเนินการ"
              if (booking['Status'] != 'กำลังดำเนินการ' && booking['Status'] != 'รอดำเนินการ')
                TextButton(
                  onPressed: () => _deleteBooking(context, docId),
                  child: const Text("ลบ", style: TextStyle(color: Colors.red)),
                ),
              // แสดงปุ่มยกเลิกถ้า Status ไม่ใช่ "ยกเลิก"
              if (booking['Status'] != 'ยกเลิก')
                TextButton(
                  onPressed: () => _cancelBooking(context, docId),
                  child: const Text("ยกเลิก", style: TextStyle(color: Colors.red)),
                ),
            ]
        );
      },
    );
  }

  // ฟังก์ชันลบประวัติการจอง (เปลี่ยนสถานะเป็น "ผู้ใช้ลบแล้ว")
  void _deleteBooking(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('Bookings').doc(docId).update({
        "Status": "ผู้ใช้ลบแล้ว",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ลบประวัติการจองสำเร็จ!"), backgroundColor: Colors.green),
      );

      Navigator.of(context).pop(); // ปิด Dialog
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $error"), backgroundColor: Colors.red),
      );
    }
  }
  void _cancelBooking(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('Bookings').doc(docId).update({
        "Status": "ยกเลิก",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ยกเลิกการจองสำเร็จ!"), backgroundColor: Colors.green),
      );

      Navigator.of(context).pop(); // ปิด Dialog
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $error"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userEmail = FirebaseAuth.instance.currentUser?.email ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text("ประวัติการจอง", style: TextStyle(color: Colors.pink[900],
            fontSize: 22.0,
            fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Bookings')
            .where('Email', isEqualTo: userEmail)
            .where('Status', isNotEqualTo: 'ผู้ใช้ลบแล้ว') // ซ่อนข้อมูลที่ถูกลบ
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("ไม่มีประวัติการจอง"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final booking = doc.data() as Map<String, dynamic>;

              String phoneNumber = booking['Number'] ?? 'ไม่ระบุ';

              return GestureDetector(
                onTap: () {
                  _showBookingDetails(context, booking, phoneNumber, doc.id);
                },
                child: Card(
                  color: Colors.pink[50],
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("วันที่จอง: ${booking['Date']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ยอดรวม: ฿${booking['TotalPrice']}"),
                        Text("เวลา: ${booking['Time']}"),
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
      ),
    );
  }
}
