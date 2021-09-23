import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginConductorPage extends StatefulWidget {
  LoginConductorPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginConductorPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Conductor Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bus Ticketing',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Conductor Login',
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            SizedBox(height: 50),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person)),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password)),
              obscureText: true,
            ),
            SizedBox(
              height: 25,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  EasyLoading.show(status: "Logging in");
                  var x = await FirebaseFirestore.instance
                      .collection('conductor')
                      .where('username', isEqualTo: emailController.text)
                      .where('password', isEqualTo: passwordController.text)
                      .get();

                  if (x.size == 0){
                    EasyLoading.showError("Username or password not found");
                    return;
                  }
                  EasyLoading.dismiss();
                  Navigator.pushNamed(context, '/conductor/home');
                },
                child: Text('LOGIN'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
