import 'package:busticket/conductor/condhistory.dart';
import 'package:busticket/conductor/scan.dart';
import 'package:busticket/conductor/walkin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class HomeConductorPage extends StatefulWidget {
  HomeConductorPage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeConductorPage> {
  PageController _pageController = PageController(initialPage: 0);

  final _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Conductor'),
        ),
        drawer: drawer(),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            dashboard(),
            ScanPage(),
            manual(),
            WalkInPage(),
            ConductorHistory()
          ],
        ));
  }

  Drawer drawer() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          title: Text('Dashboard'),
          onTap: () {
            setState(() {
              _pageController.jumpToPage(0);
            });
          },
        ),
        ListTile(
          title: Text('Scan'),
          onTap: () {
            setState(() {
              _pageController.jumpToPage(1);
            });
          },
        ),
        ListTile(
          title: Text('Walk-in'),
          onTap: () {
            setState(() {
              _pageController.jumpToPage(3);
            });
          },
        ),
        ListTile(
          title: Text('History'),
          onTap: () {
            setState(() {
              _pageController.jumpToPage(4);
            });
          },
        ),
        ListTile(
          title: Text('Logout'),
          onTap: () {
            setState(() {
              Navigator.pushReplacementNamed(context, '/login');
            });
          },
        ),
      ],
    ));
  }

  Widget dashboard() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _pageController.jumpToPage(1);
                });
              },
              child: Text('SCAN'),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _pageController.jumpToPage(3);
                });
              },
              child: Text('WALK IN'),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _pageController.jumpToPage(4);
                });
              },
              child: Text('HISTORY'),
            ),
          ),
          Spacer(),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget manual() {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Code',
            border: OutlineInputBorder(),
          )),
      ElevatedButton(
        onPressed: () {
          updateTicket();
        },
        child: Text('Find'),
      )
    ]);
  }

  updateTicket() async {
    EasyLoading.show(status: 'Loading');
    FirebaseFirestore.instance
        .collection('tickets')
        .doc(_emailController.text.toString())
        .update({'status': 'Used'}).then((value) {
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Succesfull');
    }).catchError((error) {
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Succesfull');
    });
  }
}
