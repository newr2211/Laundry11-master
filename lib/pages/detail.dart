import 'package:Laundry/pages/bottome_nav_bar.dart';
import 'package:Laundry/pages/booking.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/cart_service.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final List<CartItem> selectedServices = cart.items;
    final currencyFormat = NumberFormat("#,##0.00", "th_TH");

    return Scaffold(
      appBar: AppBar(
        title: Text("ตะกร้าบริการ",
            style: TextStyle(
                color: Colors.pink[900],
                fontSize: 22.0,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.pink[900]),
        centerTitle: true,
        actions: [
          if (selectedServices.isNotEmpty && selectedServices.length > 1)
            TextButton(
              onPressed: () {
                cart.clear();
              },
              child: Text(
                "ยกเลิกทั้งหมด",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "บริการที่เลือก",
              style: TextStyle(
                color: Colors.pink[900],
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: ListView.separated(
                itemCount: selectedServices.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(
                        selectedServices[index].service,
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                      ),
                      subtitle: Text(
                        "฿${currencyFormat.format(selectedServices[index].price)} x ${selectedServices[index].quantity}",
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: selectedServices[index].quantity > 1
                                ? () => cart.updateQuantity(
                                    selectedServices[index].service,
                                    selectedServices[index].quantity - 1)
                                : null,
                          ),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: Text(
                              "${selectedServices[index].quantity}",
                              key: ValueKey<int>(
                                  selectedServices[index].quantity),
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => cart.updateQuantity(
                                selectedServices[index].service,
                                selectedServices[index].quantity + 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(color: Colors.pink[50], thickness: 2.0),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "รวมทั้งหมด",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[900],
                  ),
                ),
                Text(
                  "${currencyFormat.format(cart.totalPrice)}฿",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[900],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: selectedServices.isNotEmpty
                  ? () async {
                      final bool? bookingCompleted = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Booking(
                            selectedServices: selectedServices
                                .map((item) => {
                                      "service": item.service,
                                      "quantity": item.quantity,
                                      "price": item.price
                                    })
                                .toList(),
                            selectedPrices: selectedServices
                                .map((item) => item.price * item.quantity)
                                .toList(),
                            totalPrice: cart.totalPrice,
                          ),
                        ),
                      );

                      if (bookingCompleted == true) {
                        cart.clear();

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavBar()));
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  backgroundColor: Colors.pink[200],
                  minimumSize: Size(double.infinity, 48)),
              child: Text(
                "ไปที่การจอง",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
