import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // เพิ่มข้อมูลผู้ใช้รวมถึงเบอร์โทร
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    // ตรวจสอบว่า userInfoMap มีเบอร์โทรหรือไม่
    if (!userInfoMap.containsKey('Phone')) {
      userInfoMap['Phone'] = 'ไม่ระบุ'; // ตั้งค่าเริ่มต้นเป็น "ไม่ระบุ"
    }

    // เพิ่มข้อมูลผู้ใช้ลง Firestore
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(id)
        .set(userInfoMap);
  }

  // เพิ่มข้อมูลการจองรวมถึงเบอร์โทร
  Future addUserBooking(Map<String, dynamic> userInfoMap) async {
    // ตรวจสอบว่า userInfoMap มีเบอร์โทรหรือไม่
    if (!userInfoMap.containsKey('Phone')) {
      userInfoMap['Phone'] = 'ไม่ระบุ'; // ตั้งค่าเริ่มต้นเป็น "ไม่ระบุ"
    }

    // เพิ่มข้อมูลการจองลง Firestore
    return await FirebaseFirestore.instance
        .collection("Booking")
        .add(userInfoMap);
  }

  // ฟังก์ชันดึงข้อมูลการจองทั้งหมด
  Future<Stream<QuerySnapshot>> getBookings() async {
    return FirebaseFirestore.instance.collection("Booking").snapshots();
  }

  // ฟังก์ชันลบการจอง
  Future deleteBooking(String id) async {
    return await FirebaseFirestore.instance
        .collection("Booking")
        .doc(id)
        .delete();
  }

  // ฟังก์ชันสำหรับเพิ่มบริการ
  Future addService(Map<String, dynamic> serviceInfoMap) async {
    // ตรวจสอบว่ามีฟิลด์ 'isActive' หรือไม่ ถ้าไม่มีให้เพิ่ม
    if (!serviceInfoMap.containsKey('isActive')) {
      serviceInfoMap['isActive'] = true; // ค่าเริ่มต้นเป็น true (เปิดบริการ)
    }
    return await FirebaseFirestore.instance
        .collection("Services")
        .add(serviceInfoMap);
  }

  // ฟังก์ชันสำหรับแก้ไขบริการ
  Future updateService(
      String id, Map<String, dynamic> updatedServiceInfoMap) async {
    // ถ้าไม่มี 'isActive' ในข้อมูลที่ส่งมา จะตั้งค่าเป็น true
    if (!updatedServiceInfoMap.containsKey('isActive')) {
      updatedServiceInfoMap['isActive'] = true; // ค่าเริ่มต้นเป็น true
    }
    return await FirebaseFirestore.instance
        .collection("Services")
        .doc(id)
        .update(updatedServiceInfoMap);
  }

  // ฟังก์ชันสำหรับลบบริการ
  Future deleteService(String id) async {
    return await FirebaseFirestore.instance
        .collection("Services")
        .doc(id)
        .delete();
  }

  // ฟังก์ชันสำหรับดึงข้อมูลบริการทั้งหมด
  Future<Stream<QuerySnapshot>> getServices() async {
    return FirebaseFirestore.instance.collection("Services").snapshots();
  }
}
