import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:thaiqr/thaiqr.dart';
import 'package:image_picker/image_picker.dart';

class Booking extends StatefulWidget {
  final List<Map<String, dynamic>> selectedServices;
  final List<int> selectedPrices;
  final int totalPrice;

  const Booking({
    super.key,
    required this.selectedServices,
    required this.selectedPrices,
    required this.totalPrice,
  });

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String? name, email, phoneNumber, deliveryAddress;
  bool isLoading = true;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? selectedPaymentMethod;
  String? selectedDeliveryMethod;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          name = data['Name'] ?? 'ไม่ระบุชื่อ';
          email = data['Email'] ?? 'ไม่ระบุอีเมล';
          phoneNumber = data['Number'] ?? 'ไม่ระบุเบอร์โทร';
          deliveryAddress = data['Address'] ?? 'ไม่ระบุที่อยู่';
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _checkExistingBookingAndBook() async {
    if (selectedPaymentMethod == null || selectedDeliveryMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("กรุณาเลือกวิธีชำระเงินและวิธีการจัดส่ง"),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Check for an existing booking on the selected date
      QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection("Bookings")
          .where("Email", isEqualTo: email)
          .where("Date", isEqualTo: _selectedDate.toString().split(' ')[0])
          .where("Status", isEqualTo: "รอดำเนินการ")
          .get();

      if (bookingSnapshot.docs.isNotEmpty) {
        _showReplaceBookingDialog(bookingSnapshot.docs.first);
      } else {
        _confirmBooking();
      }
    } catch (error) {
      print("Error checking existing booking: $error");
    }
  }

  void _showReplaceBookingDialog(QueryDocumentSnapshot oldBooking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("แจ้งเตือนการจอง"),
          content: Text(
              "คุณมีการจองวันที่ ${_selectedDate.toString().split(' ')[0]} แล้ว ต้องการยกเลิกและจองใหม่หรือไม่?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ไม่"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelOldBookingAndBookNew(oldBooking);
              },
              child: Text("ใช่, จองใหม่"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelOldBookingAndBookNew(
      QueryDocumentSnapshot oldBooking) async {
    try {
      await FirebaseFirestore.instance
          .collection("Bookings")
          .doc(oldBooking.id)
          .update({
        "Status": "ยกเลิก",
      });
      _confirmBooking();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("เกิดข้อผิดพลาดในการยกเลิกคิวเก่า: $error"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _confirmBooking() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    int finalPrice = widget.totalPrice;
    if (selectedDeliveryMethod == "ส่งถึงที่") {
      finalPrice += 200; // Add delivery charge if selected "ส่งถึงที่"
    }

    Map<String, dynamic> userBookingMap = {
      "Services": widget.selectedServices,
      "Prices": widget.selectedPrices,
      "TotalPrice": finalPrice,
      "Date": _selectedDate.toString().split(' ')[0],
      "Time": _selectedTime.format(context),
      "Username": name,
      "Email": email,
      "Number": phoneNumber,
      "DeliveryAddress": deliveryAddress ?? '',
      "Status": "รอดำเนินการ",
      "PaymentMethod": selectedPaymentMethod,
      "DeliveryMethod": selectedDeliveryMethod,
      "StatusDate": "กำลังคำนวณเวลา",
      "Payment": getPaymentStatus(),
    };

    try {
      await FirebaseFirestore.instance
          .collection("Bookings")
          .add(userBookingMap);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("จองบริการสำเร็จ!"),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context, true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("เกิดข้อผิดพลาดในการจอง: $error"),
        backgroundColor: Colors.red,
      ));
    }
  }

  String getPaymentStatus() {
    if (selectedPaymentMethod == "พร้อมเพย์") {
      return "กำลังตรวจสอบ";
    }
    return "รอชำระ";
  }

  File? uploadedImage; // ตัวแปรเก็บไฟล์รูปที่อัปโหลดแล้ว

  void _showQRPromptPay() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // ใช้ StatefulBuilder เพื่ออัปเดต UI ภายใน Dialog
          builder: (context, setState) {
            return AlertDialog(
              title: Text("QR พร้อมเพย์"),
              content: SizedBox(
                width: 300,
                height: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ThaiQRWidget(
                      mobileOrId: "0952628431",
                      amount: (widget.totalPrice +
                              (selectedDeliveryMethod == 'ส่งถึงที่' ? 200 : 0))
                          .toString(),
                      showHeader: false,
                    ),
                    SizedBox(height: 20),
                    Text(
                        'ยอดที่ต้องชำระ: ${widget.totalPrice + (selectedDeliveryMethod == 'ส่งถึงที่' ? 200 : 0)} บาท'),
                    SizedBox(height: 20),

                    // ปุ่มอัปโหลดรูปภาพ
                    ElevatedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);

                        if (pickedFile != null) {
                          setState(() {
                            uploadedImage =
                                File(pickedFile.path); // อัปเดตรูปที่เลือก
                          });
                        }
                      },
                      icon: Icon(Icons.upload_file),
                      label: Text("อัปโหลดสลิป"),
                    ),

                    SizedBox(height: 10),

                    // แสดงตัวอย่างรูปภาพที่อัปโหลด (ถ้ามี)
                    if (uploadedImage != null)
                      Image.file(uploadedImage!,
                          height: 100, fit: BoxFit.cover),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    uploadedImage = null; // รีเซ็ตค่า
                    Navigator.pop(context);
                  },
                  child: Text("ยกเลิก"),
                ),

                // ปุ่มยืนยันการชำระเงิน (เปิดใช้งานเมื่อมีการอัปโหลดรูป)
                ElevatedButton(
                  onPressed: uploadedImage == null
                      ? null // ปิดปุ่มหากยังไม่มีรูป
                      : () {
                          Navigator.pop(context);
                          _checkExistingBookingAndBook();
                        },
                  child: Text("ยืนยันการชำระเงิน"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "เลือกวันที่และเวลา",
                        style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[900]),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    TableCalendar(
                      focusedDay: _selectedDate,
                      firstDay: DateTime.now(),
                      lastDay: DateTime.utc(2030, 1, 1),
                      selectedDayPredicate: (day) =>
                          isSameDay(day, _selectedDate),
                      onDaySelected: (day, _) =>
                          setState(() => _selectedDate = day),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                            color: Colors.blue, shape: BoxShape.circle),
                        todayDecoration: BoxDecoration(
                            color: Colors.orange, shape: BoxShape.circle),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                            color: Colors.pink[50],
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.alarm, color: Colors.pink[900]),
                            SizedBox(width: 15.0),
                            Text(_selectedTime.format(context),
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink[900])),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40.0),
                    DropdownButton<String>(
                      value: selectedPaymentMethod,
                      hint: Text("เลือกวิธีชำระเงิน"),
                      isExpanded: true,
                      onChanged: (value) =>
                          setState(() => selectedPaymentMethod = value),
                      items: ["เงินสด", "พร้อมเพย์"].map((method) {
                        return DropdownMenuItem(
                            value: method, child: Text(method));
                      }).toList(),
                    ),
                    SizedBox(height: 20.0),
                    DropdownButton<String>(
                      value: selectedDeliveryMethod,
                      hint: Text("เลือกวิธีการจัดส่ง"),
                      isExpanded: true,
                      onChanged: (value) =>
                          setState(() => selectedDeliveryMethod = value),
                      items: ["รับเอง", "ส่งถึงที่"].map((method) {
                        return DropdownMenuItem(
                            value: method, child: Text(method));
                      }).toList(),
                    ),
                    Text(
                      "*ค่าจัดส่ง 200",
                      style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    SizedBox(height: 25.0),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedPaymentMethod == "พร้อมเพย์") {
                          _showQRPromptPay();
                        } else {
                          _checkExistingBookingAndBook();
                        }
                      },
                      child: Center(
                        child: Text(
                          selectedPaymentMethod == "พร้อมเพย์"
                              ? "ชำระเงิน"
                              : "จองบริการ",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[200]),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
