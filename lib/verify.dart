import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class VerifyPage extends StatefulWidget {
  VerifyPage({Key? key}) : super(key: key);

  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final pageController = PageController(initialPage: 0);
  final auth = FirebaseAuth.instance;

  final codeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    try {
      auth.currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: [
          verifyEmail(),
        ],
      ),
    );
  }

  Widget verifyEmail() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Text(
            'Verify your account with the code sent by your email.',
            textAlign: TextAlign.center,
          ),
          Text(
            auth.currentUser!.email.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Spacer(),
          TextFormField(
            controller: codeController,
            decoration: InputDecoration(
              labelText: 'Code',
              border: OutlineInputBorder(),
            ),
          ),
          Spacer(),
          TextButton(
            child: Text('RESEND CODE'),
            onPressed: () {
              //TODO: Add verification
            },
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                child: Text("NEXT"),
                onPressed: () {
                  //TODO: Add Next
                },
              ),
            ],
          ),
        ],
      )),
    );
  }
}
