import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({
    Key? key,
  }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final auth = FirebaseAuth.instance;

  bool isAvailableEmail = true;

  registerFirebase() async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: emailController.text, password: confirmController.text);

      print(userCredential);

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .withConverter<User>(
              fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
              toFirestore: (user, _) => user.toJson());

      await userRef.add(User(
        email: emailController.text.toString(),
      ));
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          break;
        case 'email-already-in-use':
          return "Email is already in use.";
        default:
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Spacer(),
                  Text('REGISTER'),
                  Spacer(),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email)),
                    validator: (email) {
                      if (email!.isEmpty) {
                        return 'Please enter email.';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(email)) {
                        return 'Please enter valid email';
                      }
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.password)),
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: confirmController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.password),
                    ),
                    obscureText: true,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Please enter some text';
                      }

                      if (text != passwordController.text) {
                        return 'Password mismatch';
                      }
                    },
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          EasyLoading.show(status: 'Loading');
                          final r = await registerFirebase();
                          if (r is String) {
                            EasyLoading.dismiss();
                            EasyLoading.showError(r);
                            return;
                          }
                          EasyLoading.dismiss();
                          EasyLoading.showSuccess('Sucessfully Registered');
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text("NEXT"),
                      )
                    ],
                  )
                ],
              ))),
    );
  }
}

class User {
  User({required this.email, this.coins = 0});
  String email;
  num coins;

  User.fromJson(Map<String, Object?> json)
      : this(email: json['email']! as String, coins: json['coins']! as num);

  Map<String, Object?> toJson() {
    return {'email': email, 'coins': coins};
  }
}
