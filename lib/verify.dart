import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class VerifyPage extends StatefulWidget {
  VerifyPage({Key? key}) : super(key: key);

  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final pageController = PageController(initialPage: 0);
  final auth = FirebaseAuth.instance;

  final codeController = TextEditingController();

  void sendEmail() {
    try {
      auth.currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    sendEmail();
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
            'Verify your account with the link sent by your email.',
            textAlign: TextAlign.center,
          ),
          Text(
            auth.currentUser!.email.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextButton(
            child: Text('RESEND EMAIL'),
            onPressed: () {
              sendEmail();
            },
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  child: Text("NEXT"),
                  onPressed: () {
                    var user = auth.currentUser;
                    EasyLoading.show(status: "");

                    if (user!.emailVerified) {
                      Navigator.pushNamed(context, '/dashboard');
                      EasyLoading.dismiss();
                      return;
                    }
                    EasyLoading.showError("User is not verified yet");
                  }),
            ],
          ),
        ],
      )),
    );
  }
}
