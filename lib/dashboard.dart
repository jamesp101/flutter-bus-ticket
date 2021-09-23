import 'package:busticket/home/buyticket.dart';
import 'package:busticket/home/mainpage.dart';
import 'package:busticket/home/mytickets.dart';
import 'package:busticket/home/topup.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  PageController _pageController = PageController(initialPage: 0);

  String _title = 'Bus Ticket';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('$_title')),
        drawer: drawer(),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            dashboard(),
            BuyTicketPage(),
            MyTicketsPage(),
          ],
        ));
  }

  Drawer drawer() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
          child: Text('${FirebaseAuth.instance.currentUser!.email}'),
        ),
        ListTile(
          title: Text("Dashboard"),
          onTap: () {
            setPageNumber(0, "Dashboard");
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text("Buy ticket"),
          onTap: () {
            setPageNumber(1, "Buy Ticket");
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text("My Tickets"),
          onTap: () {
            setPageNumber(2, "My Tickets");
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text("Logout"),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    ));
  }

  setPageNumber(int i, String title) {
    _pageController.jumpToPage(i);
    setState(() {
      _title = '$title';
    });
  }

  Widget dashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          

          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  setPageNumber(1, "Buy Ticket");
                });
              },
              child: Text('BUY TICKET'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setPageNumber(2, "My Tickets");
              },
              child: Text('VIEW MY TICKETS'),
            ),
          ),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('LOGOUT'),
            ),
          ),
        ],
      ),
    );
  }
}
