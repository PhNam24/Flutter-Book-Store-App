import 'package:flutter/material.dart';
import 'package:flutter_application_bookstore/module/checkout/checkout_page.dart';
import 'package:flutter_application_bookstore/module/home/home_page.dart';
import 'package:flutter_application_bookstore/module/signin/signin_page.dart';
import 'package:flutter_application_bookstore/module/signup/signup_page.dart';
import 'package:flutter_application_bookstore/shared/app_color.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Store',
      theme: ThemeData(
        primarySwatch: AppColor.yellow,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => SignInPage(),
        '/sign-in': (context) => SignInPage(),
        '/sign-up': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/checkout': (context) => CheckoutPage(),
      },
    );
  }
}
