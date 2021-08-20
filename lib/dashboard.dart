import 'package:busticket/home/buyticket.dart';
import 'package:busticket/home/topup.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Dashboard")),
        drawer: drawer(),
        body: PageView(
          controller: _pageController,
          children: [
            Text('hi 1'),
            BuyTicketPage(),
            TopupPage(),
            Text('hi 3'),
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
          child: Text('Drawer'),
        ),
        ListTile(
          title: Text("Dashboard"),
          onTap: () {
            setPageNumber(0);
          },
        ),
        ListTile(
          title: Text("Buy ticket"),
          onTap: () {
            setPageNumber(1);
          },
        ),
        ListTile(
          title: Text("Buy ticket"),
          onTap: () {
            setPageNumber(2);
          },
        ),
      ],
    ));
  }

  setPageNumber(int i) {
    _pageController.jumpToPage(i);
  }
}
