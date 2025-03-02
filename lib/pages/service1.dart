import 'package:Laundry/pages/bottome_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import 'detail.dart';

class Service1 extends StatefulWidget {
  @override
  _Service1State createState() => _Service1State();
}

class _Service1State extends State<Service1> {
  Map<String, int> serviceQuantities = {
    "ซักพับ": 0,
    "รีดผ้า": 0,
    "ขจัดคราบ": 0,
    "ซักแห้ง": 0,
    "ซักผ้าม่าน": 0,
    "ซักสูท": 0,
    "กางเกงสูท,กางเกง,กระโปรง": 0,
    "ชุดเดรส": 0,
    "เน็คไท,ผ้าพันคอ": 0,
  };

  Map<String, int> servicePrices = {
    "ซักพับ": 25,
    "รีดผ้า": 15,
    "ขจัดคราบ": 20,
    "ซักแห้ง": 15,
    "ซักผ้าม่าน": 15,
    "ซักสูท": 25,
    "กางเกงสูท,กางเกง,กระโปรง": 30,
    "ชุดเดรส,จั๊มป์สูท,กระโปรง": 30,
    "เน็คไท,ผ้าพันคอ": 25,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("images/111.png", height: 35),
                SizedBox(width: 10),
                Text("ซักพับ",
                    style:
                        TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 20),
            for (var service in serviceQuantities.keys) ...[
              _buildSwitch(service, serviceQuantities[service]! > 0, (value) {
                setState(() {
                  serviceQuantities[service] = value ? 1 : 0;
                });
              }),
              if (serviceQuantities[service]! > 0)
                _buildQuantitySelector(
                    service,
                    serviceQuantities[service]!,
                    (val) => setState(() {
                          serviceQuantities[service] = val;
                        })),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: () {
            final cart = Provider.of<CartService>(context, listen: false);

            serviceQuantities.forEach((service, quantity) {
              if (quantity > 0) {
                cart.addItem(service, servicePrices[service]!, quantity);
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("เพิ่มไปยังตะกร้าสำเร็จ!"),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[200],
            padding: EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text("เพิ่มไปยังตะกร้า",
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(
      String label, int quantity, Function(int) onQuantityChanged) {
    int itemPrice = servicePrices[label] ?? 0;

    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.pink, blurRadius: 5)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label ตัวละ ฿$itemPrice", style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          Row(
            children: [
              Text("฿${quantity * itemPrice}",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              Spacer(),
              IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: quantity > 0
                      ? () => onQuantityChanged(quantity - 1)
                      : null),
              Text("$quantity", style: TextStyle(fontSize: 18)),
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => onQuantityChanged(quantity + 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
