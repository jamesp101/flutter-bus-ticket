import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final auth = FirebaseAuth.instance;

  loginFirebase() async {
    try {
      EasyLoading.show(status: "Signing in");

      await auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text);

      var user = auth.currentUser;

      if (user!.emailVerified) {
        Navigator.pushNamed(context, '/dashboard');
        return;
      }

      Navigator.pushNamed(context, '/verify');
      return;
    } on FirebaseAuthException catch (e) {
      print(e);
      EasyLoading.showError(e.message.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text("REGISTER"),
                    ),
                    ElevatedButton(
                      onPressed: loginFirebase,
                      child: Text("LOGIN"),
                    ),
                  ],
                ),
                SizedBox(height: 20)
              ],
            ))));
  }
}
