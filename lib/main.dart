import 'package:busticket/dashboard.dart';
import 'package:busticket/payment.dart';
import 'package:busticket/verify.dart';
import 'package:flutter/material.dart';

import './register.dart';
import './login.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => DashboardPage(),
        '/verify': (context) => VerifyPage(),
        '/payment': (context) => PaymentPage(),

        // '/payment': (context)
      },
      home: LoginPage(),
      builder: EasyLoading.init(),
    );
  }
}
