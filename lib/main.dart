import 'package:Laundry/admin/adminhome.dart';
import 'package:Laundry/pages/bookinghistory.dart';
import 'package:Laundry/pages/bottome_nav_bar.dart';
import 'package:Laundry/pages/detail.dart';
import 'package:Laundry/pages/editprofile.dart';
import 'package:Laundry/pages/service1.dart';
import 'package:Laundry/services/cart_service.dart';
import 'package:Laundry/services/serviceProvider.dart';
import 'package:flutter/material.dart';
import 'package:Laundry/pages/booking.dart';
import 'package:Laundry/pages/home.dart';
import 'package:Laundry/pages/login.dart';
import 'package:Laundry/pages/onboarding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Laundry/pages/signup.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue[700]!,
        ),
      ),
      home: Onboarding(),
    );
  }
}
