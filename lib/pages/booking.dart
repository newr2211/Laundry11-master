import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

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
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

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

  Future<void> _cancelOldBookingAndBookNew(QueryDocumentSnapshot oldBooking) async {
    try {
      await FirebaseFirestore.instance.collection("Bookings").doc(oldBooking.id).update({
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

    Map<String, dynamic> userBookingMap = {
      "Services": widget.selectedServices,
      "Prices": widget.selectedPrices,
      "TotalPrice": widget.totalPrice,
      "Date": _selectedDate.toString().split(' ')[0],
      "Time": _selectedTime.format(context),
      "Username": name,
      "Email": email,
      "Number": phoneNumber,
      "DeliveryAddress": deliveryAddress ?? '',
      "Status": "รอดำเนินการ",
    };

    try {
      await FirebaseFirestore.instance.collection("Bookings").add(userBookingMap);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "เลือกวันที่และเวลา",
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.pink[900]),
                ),
              ),
              SizedBox(height: 30.0),
              TableCalendar(
                focusedDay: _selectedDate,
                firstDay: DateTime.now(),
                lastDay: DateTime.utc(2030, 1, 1),
                selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                onDaySelected: (day, _) => setState(() => _selectedDate = day),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                ),
              ),
              SizedBox(height: 20.0),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(color: Colors.pink[50], borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.alarm, color: Colors.pink[900]),
                      SizedBox(width: 15.0),
                      Text(_selectedTime.format(context),
                          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.pink[900])),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: _checkExistingBookingAndBook,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  backgroundColor: Colors.pink[200],
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text("จองบริการ", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
