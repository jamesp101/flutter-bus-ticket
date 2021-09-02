import 'package:flutter/material.dart';

class HomeConductorPage extends StatefulWidget {
  HomeConductorPage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeConductorPage> {
  PageController _pageController = PageController(initialPage: 0);
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
          children: [dashboard()],
        ));
  }

  Drawer drawer() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          title: Text('Dashboard'),
          onTap: () {},
        ),
        ListTile(
          title: Text('Scan'),
          onTap: () {},
        ),
        ListTile(
          title: Text('Walk-in'),
          onTap: () {},
        ),
        ListTile(
          title: Text('Manual'),
          onTap: () {},
        ),
        ListTile(
          title: Text('History'),
          onTap: () {},
        ),
        ListTile(
          title: Text('Logout'),
          onTap: () {},
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
              onPressed: () {},
              child: Text('SCAN'),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('MANUAL'),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('WALK IN'),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('HISTORY'),
            ),
          ),
          Spacer(),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('LOGOUT'),
            ),
          ),
        ],
      ),
    );
  }
}
