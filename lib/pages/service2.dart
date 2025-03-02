import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import 'detail.dart'; // ใส่ที่อยู่ของ CartService

class Service2 extends StatefulWidget {
  @override
  _Service2State createState() => _Service2State();
}

class _Service2State extends State<Service2> {
  Map<String, int> serviceQuantities = {
    "ซักรองเท้าผ้าใบ,หนัง": 0,
    "ซักรองเท้าหนังคัตชู": 0,
    "ซักรองเท้าบูธ": 0,
    "ซักรองเท้าแบรนด์เนม": 0,
  };

  Map<String, int> servicePrices = {
    "ซักรองเท้าผ้าใบ,หนัง": 199,
    "ซักรองเท้าหนังคัตชู": 250,
    "ซักรองเท้าบูธ": 200,
    "ซักรองเท้าแบรนด์เนม": 259,
  };

  int get totalPrice {
    return serviceQuantities.entries
        .map((entry) => entry.value * (servicePrices[entry.key] ?? 0))
        .fold(0, (prev, amount) => prev + amount);
  }

  void updateServiceQuantity(String service, int change) {
    setState(() {
      serviceQuantities[service] =
          (serviceQuantities[service]! + change).clamp(0, 99);
    });
  }

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
                Image.asset("images/44.png", height: 35),
                SizedBox(width: 10),
                Text("ซักรองเท้า",
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
                    (val) => updateServiceQuantity(
                        service, val - serviceQuantities[service]!)),
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
          Text("$label คู่ละ ฿$itemPrice", style: TextStyle(fontSize: 16)),
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
