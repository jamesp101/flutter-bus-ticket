import 'package:busticket/home/buyticket.dart';
import 'package:busticket/home/mytickets.dart';
import 'package:busticket/home/topup.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  PageController _pageController = PageController(initialPage: 0);

  String _title = 'title';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('$_title')),
        drawer: drawer(),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            Text('hik1'),
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
          child: Text('Drawer'),
        ),
        ListTile(
          title: Text("Dashboard"),
          onTap: () {
            setPageNumber(0, "Dashboard");
          },
        ),
        ListTile(
          title: Text("Buy ticket"),
          onTap: () {
            setPageNumber(1, "Buy Ticket");
          },
        ),
        ListTile(
          title: Text("My Tickets"),
          onTap: () {
            setPageNumber(2, "My Tickets");
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
}
