import 'package:flutter/material.dart';

class ServiceProvider with ChangeNotifier {
  // ตัวแปรที่เก็บข้อมูลบริการที่เลือกและราคาของบริการ
  List<Map<String, dynamic>> _selectedServices = [];
  List<int> _selectedPrices = [];

  // Getter เพื่อเข้าถึงข้อมูลบริการและราคาที่เลือก
  List<Map<String, dynamic>> get selectedServices => _selectedServices;
  List<int> get selectedPrices => _selectedPrices;

  // ฟังก์ชันสำหรับอัปเดตข้อมูลบริการที่เลือกและราคาที่เลือก
  void updateSelectedServices(
      List<Map<String, dynamic>> services, List<int> prices) {
    _selectedServices = services; // อัปเดตบริการที่เลือก
    _selectedPrices = prices; // อัปเดตราคาของบริการที่เลือก
    notifyListeners(); // แจ้งให้หน้าต่างอื่นๆ ที่ใช้ Provider ทราบ
  }

  // ฟังก์ชันสำหรับเพิ่มบริการหนึ่งรายการ
  void addService(String serviceName, int price) {
    // เพิ่มบริการที่เลือกเข้าไปใน _selectedServices และ _selectedPrices
    _selectedServices.add({
      'service': serviceName,
      'price': price,
    });
    _selectedPrices.add(price);
    notifyListeners(); // แจ้งให้หน้าต่างอื่นๆ ที่ใช้ Provider ทราบ
  }

  // ฟังก์ชันสำหรับลบบริการหนึ่งรายการ
  void removeService(String serviceName) {
    int indexToRemove = _selectedServices
        .indexWhere((service) => service['service'] == serviceName);
    if (indexToRemove != -1) {
      _selectedServices.removeAt(indexToRemove);
      _selectedPrices.removeAt(indexToRemove);
      notifyListeners(); // แจ้งให้หน้าต่างอื่นๆ ที่ใช้ Provider ทราบ
    }
  }
}
