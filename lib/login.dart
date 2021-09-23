import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
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
    } catch (e) {
      EasyLoading.showError('Something went wrong!');
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
                Spacer(),
                ShaderMask(
                  shaderCallback: (bounds) => RadialGradient(
                          center: Alignment.bottomRight,
                          radius: 0.5,
                          colors: [
                            Theme.of(context).accentColor,
                            Theme.of(context).primaryColor,
                          ],
                          tileMode: TileMode.mirror)
                      .createShader(bounds),
                  child: Icon(
                    Icons.directions_bus_filled_rounded,
                    size: 150,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Bus Ticketing',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
                SizedBox(
                  height: 32,
                ),
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
                Spacer(),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/conductor/login');
                    },
                    child: Text('CONDUCTOR'))
              ],
            ))));
  }
}
